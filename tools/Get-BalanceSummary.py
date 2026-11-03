"""One-screen balance summary of a BOI headless run, set against the vanilla baseline.

Usage: python tools/Get-BalanceSummary.py <run folder or name> [--years 1836,1841,1846]
                                          [--out FILE]

Reads BOITM|, BOIHS| and BOIPOL| lines from the run's mirrored debug logs. Vanilla
figures come from tools/ensembles/ensembles.sqlite, which stops at 1846, so later
years show no vanilla column. Country totals cover major powers only, and which
countries those are changes over time. Where a civil war gives a tag two pulses in
a year, the larger side (by states) is kept.
"""
import argparse
import re
import sqlite3
from collections import defaultdict
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
MONTHS = {m: i + 1 for i, m in enumerate("January February March April May June July August September October November December".split())}
RESIDENTIAL = ["slum_levels", "tenement_levels", "regulated_terraces", "tenement_blocks", "model_dwellings", "apartment_levels",
               "municipal_estates", "elevator_apartments", "luxury_apartment_levels", "boulevard_apartments", "elevator_residences",
               "suburb_levels", "railway_suburbs", "streetcar_suburbs", "motor_suburbs", "shelter_levels"]


def year_of(date):
    m = re.search(r"(\d{4})", date)
    return int(m.group(1)) if m else None


def fields(text):
    out = {}
    for part in text.split(";"):
        if "=" in part:
            k, v = part.split("=", 1)
            try:
                out[k] = float(v)
            except ValueError:
                out[k] = v
    return out


def read_run(run):
    logs = sorted((run / "logs").glob("debug*.log"))
    country = defaultdict(lambda: defaultdict(dict))  # year -> tag -> metrics
    states = defaultdict(lambda: defaultdict(dict))  # year -> (tag, region) -> metrics
    pollution = defaultdict(dict)
    seen = set()
    for log in logs:
        with log.open(encoding="utf-8", errors="replace") as handle:
            for line in handle:
                i = line.find("BOITM|")
                if i >= 0:
                    body = line[i:].strip()
                    if body in seen:
                        continue
                    seen.add(body)
                    parts = body.split("|", 4)
                    if len(parts) < 5:
                        continue
                    _, group, date, tag, rest = parts
                    y = year_of(date)
                    f = fields(rest)
                    if group == "goods":
                        name = f.pop("goods", "?")
                        f = {f"{name}_{k}": v for k, v in f.items()}
                    row = country[y][tag]
                    if group == "country" and row.get("states", -1) > f.get("states", 0):
                        continue
                    row.update(f)
                    continue
                i = line.find("BOIHS|")
                if i >= 0:
                    body = line[i:].strip()
                    if body in seen:
                        continue
                    seen.add(body)
                    parts = body.split("|", 5)
                    if len(parts) < 6:
                        continue
                    _, kind, date, tag, region, rest = parts
                    m = re.search(r"StateRegionTooltip ([^\x15!]+)", region)
                    name = m.group(1).strip() if m else region
                    f = fields(rest)
                    states[year_of(date)][(tag, name)].update({f"{kind}_{k}": v for k, v in f.items()})
                    continue
                i = line.find("BOIPOL|")
                if i >= 0:
                    parts = line[i:].strip().split("|", 4)
                    if len(parts) == 5:
                        m = re.search(r"StateRegionTooltip ([^\x15!]+)", parts[3])
                        pollution[year_of(parts[1])][(parts[2], m.group(1).strip() if m else parts[3])] = fields(parts[4])
    return country, states, pollution


def vanilla_world():
    db = TOOLS / "ensembles" / "ensembles.sqlite"
    if not db.exists():
        return {}
    con = sqlite3.connect(db)
    out = defaultdict(dict)
    for date, metric, mean in con.execute(
        """SELECT s.date, w.metric, AVG(w.value) FROM world_obs w JOIN snapshot s ON s.run_id = w.run_id AND s.t = w.t
           JOIN run r ON r.run_id = w.run_id JOIN ensemble e ON e.ensemble_id = r.ensemble_id
           WHERE e.name = 'vanilla_1836_1846' AND s.date LIKE '%-10-%' OR (e.name = 'vanilla_1836_1846' AND s.date LIKE '1846-01%')
           GROUP BY s.date, w.metric"""):
        out[int(date[:4])][metric] = mean
    return out


def vanilla_countries():
    """Mean GDP, SoL and radical share per power per year, from the ensemble's October snapshots."""
    db = TOOLS / "ensembles" / "ensembles.sqlite"
    if not db.exists():
        return {}
    con = sqlite3.connect(db)
    out = defaultdict(lambda: defaultdict(dict))
    cols = {r[1] for r in con.execute("PRAGMA table_info(country_obs)")}
    wanted = [c for c in ("gdp", "sol", "population", "radicals", "states") if c in cols]
    q = f"""SELECT tag, date, {', '.join('AVG(' + c + ')' for c in wanted)} FROM v_country
            WHERE ensemble = 'vanilla_1836_1846' AND (date LIKE '%-10-%' OR date LIKE '1846-01%') GROUP BY tag, date"""
    for row in con.execute(q):
        for c, v in zip(wanted, row[2:]):
            out[int(row[1][:4])][row[0]][c] = v
    return out


def total(rows, key):
    return sum(r.get(key, 0) or 0 for r in rows)


def pop_weighted(rows, key):
    w = total(rows, "population")
    return sum((r.get(key, 0) or 0) * (r.get("population", 0) or 0) for r in rows) / w if w else 0


def summarize(run, years):
    country, states, pollution = read_run(run)
    vc = vanilla_countries()
    all_years = sorted(y for y in country if y)
    if not years:
        years = all_years
    lines = [f"# Balance summary: {run.name}", ""]
    lines.append(f"Years logged: {all_years[0] if all_years else '-'} to {all_years[-1] if all_years else '-'}. Major powers only for country columns.")
    lines.append("")

    lines += ["## World of the major powers", "",
              "| Year | Powers | GDP M | vs vanilla | SoL | vs vanilla | Radicals % | vs vanilla | States short | Usage/supply | Debt max |",
              "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for y in years:
        tags = country.get(y)
        if not tags:
            continue
        rows = list(tags.values())
        van = vc.get(y if y <= 1846 else -1, {})
        shared = [t for t in tags if t in van]
        gdp_mod = sum(tags[t].get("gdp", 0) for t in shared)
        gdp_van = sum(van[t].get("gdp", 0) for t in shared)
        sol_mod = pop_weighted([tags[t] for t in shared], "sol")
        vanrows = [van[t] for t in shared]
        sol_van = pop_weighted(vanrows, "sol") if vanrows else 0
        rad = total(rows, "radicals") / max(total(rows, "population"), 1) * 100
        rad_shared_mod = total([tags[t] for t in shared], "radicals") / max(total([tags[t] for t in shared], "population"), 1) * 100
        rad_van = total(vanrows, "radicals") / max(total(vanrows, "population"), 1) * 100 if vanrows else 0
        lines.append(
            f"| {y} | {len(rows)} | {total(rows, 'gdp') / 1e6:,.0f} | "
            + (f"{(gdp_mod / gdp_van - 1) * 100:+.1f}%" if gdp_van else "-") + f" | {pop_weighted(rows, 'sol'):.2f} | "
            + (f"{sol_mod - sol_van:+.2f}" if sol_van else "-") + f" | {rad:.1f} | "
            + (f"{rad_shared_mod:.1f} / {rad_van:.1f}" if rad_van else "-")
            + f" | {total(rows, 'deficit_states'):.0f} | {total(rows, 'usage') / max(total(rows, 'infrastructure'), 1) * 100:.0f}% | "
            + f"{max((r.get('scaled_debt', 0) or 0) for r in rows):.2f} |")
    lines += ["", "Vs vanilla uses powers present in both. The radicals vs column is mod / vanilla.", ""]

    lines += ["## Works", "",
              "| Year | Road | Rail Works | Harbour | Railways | Cart | Macadam | Steam | Motor | Highway | Goods at base, % of expenses |",
              "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for y in years:
        rows = list(country.get(y, {}).values())
        if not rows:
            continue
        lines.append(f"| {y} | {total(rows, 'public_works_levels'):.0f} | {total(rows, 'rail_works_levels'):.0f} | {total(rows, 'harbour_works_levels'):.0f} | {total(rows, 'railway_levels'):.0f} | "
                     f"{total(rows, 'road_cart'):.0f} | {total(rows, 'road_macadam'):.0f} | {total(rows, 'road_steam'):.0f} | {total(rows, 'road_motor'):.0f} | {total(rows, 'road_highway'):.0f} | "
                     f"{total(rows, 'works_goods_base') / max(total(rows, 'expenses'), 1) * 100:.1f}% |")
    lines.append("")

    lines += ["## Housing by type, major powers", "", "| Year | " + " | ".join(k.replace("_levels", "")[:9] for k in RESIDENTIAL) + " |",
              "| --- | " + " | ".join("---:" for _ in RESIDENTIAL) + " |"]
    for y in years:
        rows = list(country.get(y, {}).values())
        if rows:
            lines.append(f"| {y} | " + " | ".join(f"{total(rows, k):.0f}" for k in RESIDENTIAL) + " |")
    lines.append("")

    lines += ["## Light and Heat and company housing, major powers", "",
              "| Year | None | Wood | Oil | Electricity | No housing | Work Camp | Work Town | Serviced |",
              "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for y in years:
        rows = list(country.get(y, {}).values())
        if rows:
            lines.append(f"| {y} | {total(rows, 'fuel_none'):.0f} | {total(rows, 'fuel_wood'):.0f} | {total(rows, 'fuel_oil'):.0f} | {total(rows, 'fuel_electricity'):.0f} | "
                         f"{total(rows, 'no_housing_levels'):.0f} | {total(rows, 'work_camp_levels'):.0f} | {total(rows, 'work_town_levels'):.0f} | {total(rows, 'serviced_town_levels'):.0f} |")
    lines.append("")

    lines += ["## World, every state", "",
              "Prices are population-weighted. Short means usage above supply. Share shows people in short states.", "",
              "| Year | States | Short | People short | Worst 5 short (pts) | Housing supply/demand | Price | Luxury s/d | Price | At £45+ | Horses s/d | Price | Road | Rail Works | Harbour | Railway |",
              "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for y in years:
        st = states.get(y)
        if not st:
            continue
        rows = list(st.values())
        pop = sum(r.get("state_pop", 0) for r in rows) or 1
        short = [r for r in rows if r.get("state_usage", 0) > r.get("state_infra", 0)]
        gaps = sorted((r.get("state_usage", 0) - r.get("state_infra", 0) for r in short), reverse=True)
        def ratio(kind):
            b = sum(r.get(f"{kind}_buy", 0) for r in rows)
            return sum(r.get(f"{kind}_sell", 0) for r in rows) / b if b else 0
        def price(kind):
            return sum(r.get(f"{kind}_price", 0) * r.get("state_pop", 0) for r in rows) / pop
        dear = sum(r.get("state_pop", 0) for r in rows if r.get("housing_price", 0) >= 45) / pop * 100
        lines.append(
            f"| {y} | {len(rows)} | {len(short)} | {sum(r.get('state_pop', 0) for r in short) / pop * 100:.0f}% | {sum(gaps[:5]):.0f} | {ratio('housing'):.2f} | {price('housing'):.1f} | {ratio('luxury'):.2f} | {price('luxury'):.1f} | {dear:.0f}% | "
            f"{ratio('horses'):.2f} | {price('horses'):.1f} | {sum(r.get('works_road', 0) for r in rows):.0f} | {sum(r.get('works_rail_works', 0) for r in rows):.0f} | {sum(r.get('works_harbour', 0) for r in rows):.0f} | {sum(r.get('works_railway', 0) for r in rows):.0f} |")
    lines.append("")

    lines += ["## Market prices, mean of major powers", "", "| Year | Transport | Grain | Tools | Wood | Coal | Oil | Electricity | Automobiles | Services | Horses |",
              "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for y in years:
        rows = list(country.get(y, {}).values())
        if rows:
            n = len(rows)
            lines.append(f"| {y} | " + " | ".join(f"{total(rows, g + '_price') / n:.1f}" for g in ("transportation", "grain", "tools", "wood", "coal", "oil", "electricity", "automobiles", "services", "horses")) + " |")
    lines.append("")

    last = all_years[-1] if all_years else None
    if last:
        lines += [f"## Major powers, {last}", "", "| Tag | States | GDP M | SoL | Radicals % | Debt | Short states | Pop M |", "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
        for tag, r in sorted(country[last].items(), key=lambda kv: -kv[1].get("gdp", 0)):
            pop = r.get("population", 0) or 1
            lines.append(f"| {tag} | {r.get('states', 0):.0f} | {r.get('gdp', 0) / 1e6:,.1f} | {r.get('sol', 0):.2f} | {r.get('radicals', 0) / pop * 100:.1f} | {r.get('scaled_debt', 0):.2f} | {r.get('deficit_states', 0):.0f} | {pop / 1e6:.1f} |")
        pol = pollution.get(last, {})
        if pol:
            top = sorted(pol.items(), key=lambda kv: -kv[1].get("impact", 0))[:5]
            lines += ["", "Highest pollution impact: " + ", ".join(f"{k[1]} ({k[0]}) {v.get('impact', 0) * 100:.1f}%" for k, v in top)]
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run")
    ap.add_argument("--years")
    ap.add_argument("--out")
    args = ap.parse_args()
    run = Path(args.run)
    if not run.exists():
        run = TOOLS / "headless-runs" / args.run
    years = [int(y) for y in args.years.split(",")] if args.years else None
    text = summarize(run, years)
    if args.out:
        Path(args.out).write_text(text, encoding="utf-8")
    print(text)


if __name__ == "__main__":
    main()
