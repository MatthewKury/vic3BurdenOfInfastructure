"""Headline world metrics for several ensembles at chosen years.

Usage:
  python tools/ensembles/Compare-Headline.py vanilla115_1836_1936_all boi115_pass4 rs_pass1 --years 1846 1851

Means over members from world_obs (one value per member per snapshot),
using each member's snapshot on 1 January of the year. The first ensemble
is the reference; later ones show the % change against it. Members that
don't reach a year are left out of that year. Only runs that passed count,
unless --include-failed (crashed runs salvaged by Build-EnsembleDb.py
--include-failed, up to their last whole snapshot).
"""
import argparse
import pathlib
import sqlite3
import statistics

HERE = pathlib.Path(__file__).resolve().parent
METRICS = ["gdp", "population", "sol", "radicals", "turmoil", "unemployed", "deficit_states",
           "infrastructure", "infrastructure_usage", "railway_levels", "construction_levels",
           "countries_at_war", "goods:transportation:price",
           # World sums of country_obs columns (2026-11-09: subsistence against vanilla).
           "sum:bg_subsistence_levels", "sum:bg_agriculture_levels", "sum:bg_ranching_levels"]
COUNTRY_COLUMNS = {"bg_subsistence_levels", "bg_agriculture_levels", "bg_ranching_levels"}


def values(db, ensemble, metric, year, include_failed=False):
    if metric.startswith("sum:"):
        column = metric[4:]
        assert column in COUNTRY_COLUMNS
        rows = db.execute(
            f"""select sum(c.{column}) from country_obs c
               join run r on r.run_id = c.run_id
               join ensemble e on e.ensemble_id = r.ensemble_id
               join snapshot s on s.run_id = c.run_id and s.t = c.t
               where e.name = ? and s.date = ? and (r.result = 'PASS' or ?)
               group by c.run_id""",
            (ensemble, f"{year}-01-01", include_failed)).fetchall()
        return [r[0] for r in rows if r[0] is not None]
    rows = db.execute(
        """select o.value from world_obs o
           join run r on r.run_id = o.run_id
           join ensemble e on e.ensemble_id = r.ensemble_id
           join snapshot s on s.run_id = o.run_id and s.t = o.t
           where e.name = ? and o.metric = ? and s.date = ? and (r.result = 'PASS' or ?)""",
        (ensemble, metric, f"{year}-01-01", include_failed)).fetchall()
    return [r[0] for r in rows if r[0] is not None]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ensembles", nargs="+")
    ap.add_argument("--years", nargs="+", type=int, default=[1846, 1851])
    ap.add_argument("--db", default=str(HERE / "ensembles.sqlite"))
    ap.add_argument("--include-failed", action="store_true",
                    help="also count runs that did not pass (crashed runs salvaged to their last snapshot)")
    args = ap.parse_args()
    db = sqlite3.connect(args.db)
    for year in args.years:
        print(f"\n### {year}\n")
        head = "| Metric | " + " | ".join(args.ensembles) + " |"
        print(head)
        print("|---" * (len(args.ensembles) + 1) + "|")
        for m in METRICS:
            cells = []
            ref = None
            for i, e in enumerate(args.ensembles):
                v = values(db, e, m, year, args.include_failed)
                if not v:
                    cells.append("–")
                    continue
                mean = statistics.mean(v)
                if i == 0:
                    ref = mean
                    cells.append(f"{mean:,.3g} (n={len(v)})")
                else:
                    pct = f" ({(mean / ref - 1) * 100:+.1f}%)" if ref else ""
                    cells.append(f"{mean:,.3g}{pct} (n={len(v)})")
            print(f"| {m} | " + " | ".join(cells) + " |")


if __name__ == "__main__":
    main()
