"""Detail behind a long BOI headless run: what Get-BalanceSummary.py doesn't show.

Usage: python tools/Get-CenturyDetail.py <run folder or name> [more runs]

Prints, per run: state-losing years among major powers, debt, how long works orders
stay queued and how that tracks debt, Municipal Estates wipeouts, Motor Road
reversals, housing demand per person, slum share, pollution, and the laws and PMs
in the last autosave.

Autosaves are binary with strings inline. Counting a PM's name gives the number of
buildings using it (the method and financing groups of a building type sum to the
same total). A law's record is followed by extra bytes only when it's active. Law
counts are rough: they include countries that no longer hold states, and the road
financing laws total more than one per country.
"""
import importlib.util
import re
import sys
import zipfile
from collections import Counter, defaultdict
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("balance", TOOLS / "Get-BalanceSummary.py")
balance = importlib.util.module_from_spec(spec)
spec.loader.exec_module(balance)

DIAG = re.compile(r"BOIDIAG\|[A-Za-z]+ \d+, (\d{4})\|(\w+)\|.*StateRegionTooltip ([^\x15!]+)[^|]*\|pw=(\d+);hw=(\d+);queued=(\d+);pw_occ=[-\d.]+;spare=([-\d.]+)")
LAW = re.compile(rb"(law_boi_[a-z_]+)@\(\x01\x00\x14\x00.{4}(.{2})", re.S)
PM_GROUPS = {
    "Road method": ["cart_roads", "macadam_roads", "steam_rolled_roads", "motor_roads", "modern_highways"],
    "Road financing": ["public_highways", "turnpike_tolls", "statute_labour"],
    "Rail method": ["permanent_way", "steel_track", "electric_signalling", "national_rail_grid"],
    "Rail financing": ["state_railways", "railway_concessions", "conscripted_navvies"],
    "Harbour financing": ["state_harbours", "harbour_tolls", "press_ganged_dock_labour"],
    "Company housing": ["work_camp", "work_town", "serviced_town"],
}


def num(row, key):
    return row.get(key, 0) or 0


def read_diag(run):
    rows = defaultdict(dict)
    with (run / "logs" / "debug.log").open(encoding="utf-8", errors="replace") as handle:
        for line in handle:
            if "BOIDIAG|" in line:
                m = DIAG.search(line)
                if m:
                    rows[(m.group(2), m.group(3))][int(m.group(1))] = (int(m.group(4)), int(m.group(5)), int(m.group(6)), float(m.group(7)))
    return rows


def queue_section(country, years, diag):
    stretches = []
    long_queue = defaultdict(set)
    for (tag, state), by_year in diag.items():
        streak = 0
        prev = None
        for y in sorted(by_year):
            if by_year[y][2] > 0:
                streak = streak + 1 if prev == y - 1 else 1
                if streak >= 5:
                    long_queue[y].add(tag)
            else:
                if streak:
                    stretches.append((streak, tag, state, prev - streak + 1, prev))
                streak = 0
            prev = y
        if streak:
            stretches.append((streak, tag, state, prev - streak + 1, prev))
    stretches.sort(reverse=True)
    print(f"\nWorks orders queued: 5+ years {sum(s[0] >= 5 for s in stretches)}, 10+ {sum(s[0] >= 10 for s in stretches)}, 20+ {sum(s[0] >= 20 for s in stretches)}")
    for s in stretches[:10]:
        print(f"  {s[0]:3} years {s[1]} {s[2]} {s[3]}-{s[4]}")
    print("Power-years by debt, with an order queued 5+ years:")
    for low, high in [(0, .1), (.1, .25), (.25, .5), (.5, .75), (.75, 99)]:
        rows = [(y, t) for y in years for t, r in country[y].items() if low <= num(r, "scaled_debt") < high]
        hit = sum(t in long_queue[y] for y, t in rows)
        print(f"  {low}-{high}: {hit}/{len(rows)} = {hit / max(len(rows), 1) * 100:.0f}%")
    print("States short for 8+ years with no change in Road or Harbour levels:")
    stuck = []
    for (tag, state), by_year in diag.items():
        length = 0
        base = None
        start = None
        for y in sorted(by_year):
            pw, hw, _, spare = by_year[y]
            if spare < -1 and base in (None, (pw, hw)):
                if not length:
                    start, base = y, (pw, hw)
                length += 1
            else:
                if length >= 8:
                    stuck.append((length, tag, state, start))
                length, base = 0, None
        if length >= 8:
            stuck.append((length, tag, state, start))
    for s in sorted(stuck, reverse=True)[:8]:
        print(f"  {s[0]:3} years {s[1]} {s[2]} from {s[3]}")


def save_section(run):
    saves = sorted((run / "saves").glob("*.v3"), key=lambda p: p.stat().st_mtime)
    if not saves:
        return
    with zipfile.ZipFile(saves[-1]) as archive:
        data = archive.read("gamestate")
    print(f"\nLast autosave ({saves[-1].name}), buildings by PM, world:")
    text = data.decode("latin1")
    for group, names in PM_GROUPS.items():
        counts = {n: len(re.findall(rf"\bpm_boi_{n}\b", text)) for n in names}
        total = sum(counts.values()) or 1
        print(f"  {group}: " + ", ".join(f"{n} {v} ({v / total * 100:.0f}%)" for n, v in counts.items()))
    active = Counter()
    for m in LAW.finditer(data):
        if m.group(2) != b"\x04\x00":
            active[m.group(1).decode()] += 1
    print("Active BOI laws, countries:", dict(sorted(active.items())))


def main(run):
    country, states, pollution = balance.read_run(run)
    years = sorted(y for y in country if y)
    print(f"\n===== {run.name}")

    print("\nMajor powers losing 25%+ of their states in a year:")
    for a, b in zip(years, years[1:]):
        for tag, row in country[a].items():
            after = country[b].get(tag)
            if after and num(row, "states") >= 4 and num(after, "states") <= num(row, "states") * .75:
                print(f"  {b} {tag} {num(row, 'states'):.0f}->{num(after, 'states'):.0f}, people {num(row, 'population') / 1e6:.1f}M->{num(after, 'population') / 1e6:.1f}M")

    debt = Counter(t for y in years for t, r in country[y].items() if num(r, "scaled_debt") > .5)
    total = sum(len(country[y]) for y in years)
    print(f"\nPower-years with debt over 0.5: {sum(debt.values())}/{total}", dict(debt.most_common(8)))

    queue_section(country, years, read_diag(run))

    print("\nMunicipal Estates lost in one year (4+ levels), major powers:")
    prev = {}
    for y in years:
        now = {t: num(r, "municipal_estates") for t, r in country[y].items()}
        for t, level in now.items():
            if prev.get(t, 0) - level >= 4:
                print(f"  {y} {t} {prev[t]:.0f}->{level:.0f}")
        prev = now

    print("\nMotor and Highway levels going back to Steam:")
    for a, b in zip(years, years[1:]):
        for tag, row in country[a].items():
            after = country[b].get(tag)
            if after:
                before_adv = num(row, "road_motor") + num(row, "road_highway")
                after_adv = num(after, "road_motor") + num(after, "road_highway")
                if before_adv - after_adv >= 2 and num(after, "road_steam") > num(row, "road_steam"):
                    print(f"  {b} {tag} {before_adv:.0f}->{after_adv:.0f}, automobile price {num(after, 'automobiles_price'):.0f}")

    print("\nHousing, world (buy, sell, demand per million people, residential levels):")
    for y in [1860, 1880, 1900, 1910, 1920, 1925, 1930, years[-1]]:
        rows = list(states.get(y, {}).values())
        if rows:
            pop = sum(r.get("state_pop", 0) for r in rows) or 1
            buy = sum(r.get("housing_buy", 0) for r in rows)
            lux = sum(r.get("luxury_buy", 0) for r in rows)
            print(f"  {y} basic {buy:.0f}/{sum(r.get('housing_sell', 0) for r in rows):.0f} per M {buy / pop * 1e6:.1f}; luxury {lux:.0f}/{sum(r.get('luxury_sell', 0) for r in rows):.0f}; levels {sum(r.get('state_res', 0) for r in rows):.0f}")

    basic = ["slum_levels", "tenement_levels", "regulated_terraces", "tenement_blocks", "model_dwellings", "apartment_levels", "municipal_estates", "elevator_apartments"]
    last = list(country[years[-1]].values())
    all_basic = sum(num(r, k) for r in last for k in basic)
    print(f"\nSlums and Workers' Rows, {years[-1]}: {sum(num(r, 'slum_levels') + num(r, 'tenement_levels') for r in last):.0f} of {all_basic:.0f} working-class levels")

    print("\nHousing by power, last year (basic and luxury supply/demand):")
    agg = defaultdict(lambda: defaultdict(float))
    for (tag, _), row in states[years[-1]].items():
        for key in ("housing_buy", "housing_sell", "luxury_buy", "luxury_sell", "state_pop"):
            agg[tag][key] += row.get(key, 0)
    for tag, a in sorted(agg.items(), key=lambda kv: -kv[1]["housing_buy"])[:10]:
        print(f"  {tag} {a['state_pop'] / 1e6:6.1f}M basic {a['housing_sell'] / max(a['housing_buy'], 1):.2f} luxury {a['luxury_sell'] / max(a['luxury_buy'], 1):.2f}")

    impacts = [v.get("impact", 0) for v in pollution.get(years[-1], {}).values()]
    print(f"\nPollution impact, last year: over 25% in {sum(i > .25 for i in impacts)} states, over 50% in {sum(i > .5 for i in impacts)}, highest {max(impacts, default=0) * 100:.0f}%")

    save_section(run)


if __name__ == "__main__":
    for name in sys.argv[1:]:
        path = Path(name)
        if not path.exists():
            path = TOOLS / "headless-runs" / name
        main(path)
