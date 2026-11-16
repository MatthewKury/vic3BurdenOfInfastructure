"""Summarise the Rail Network Survey lines of one or more headless runs.

Reads tools/headless-runs/<run>/logs/debug.log for:
  BOITM|rail|<date>|<TAG>|k=v;...   yearly, every major power (boi module)
  BOIFIX|<date>|rs_*|<result>|k=v;  survey fixture lines (rail_survey module)

Usage:
  python tools/Get-RailSurveySummary.py <run> [<run> ...] [--year 1850]

Prints, per run: the world-of-majors Rail Works totals for the chosen year
(default: the last year logged), the countries at their cap, and every
completed survey. Design: docs/plans/01_RAIL_SURVEY_PROPOSAL.md.
"""
import argparse
import pathlib
import re
import statistics
from collections import defaultdict

HERE = pathlib.Path(__file__).resolve().parent
RUNS = HERE / "headless-runs"


def parse_kv(text):
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
    log = RUNS / run / "logs" / "debug.log"
    rail = defaultdict(dict)  # year -> tag -> kv
    fixtures = []
    with open(log, encoding="utf-8", errors="replace") as f:
        for line in f:
            i = line.find("BOITM|rail|")
            if i >= 0:
                parts = line[i:].rstrip("\n").split("|", 4)
                if len(parts) == 5:
                    year = re.search(r"(\d{4})", parts[2])
                    if year:
                        rail[int(year.group(1))][parts[3]] = parse_kv(parts[4])
                continue
            i = line.find("BOIFIX|")
            if i >= 0 and "|rs_" in line:
                parts = line[i:].rstrip("\n").split("|", 4)
                if len(parts) == 5:
                    fixtures.append((parts[1], parts[2], parts[3], parse_kv(parts[4])))
    return rail, fixtures


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("runs", nargs="+")
    ap.add_argument("--year", type=int)
    args = ap.parse_args()

    all_complete = []
    for run in args.runs:
        rail, fixtures = read_run(run)
        print(f"## {run}")
        if rail:
            year = args.year or max(rail)
            rows = rail.get(year, {})
            keys = ["rail_works_levels", "rail_cap_total", "states_at_cap", "states_over_cap",
                    "surveyed_levels", "ai_surveys", "surveys_completed", "short_states"]
            tot = {k: sum(r.get(k, 0) for r in rows.values() if isinstance(r.get(k, 0), float)) for k in keys}
            print(f"Majors in {year} ({len(rows)} countries): " + ", ".join(f"{k}={tot[k]:.0f}" for k in keys))
            mods = sum(1 for r in rows.values() if r.get("cap_modifier_states") != r.get("states"))
            print(f"  countries with a state missing its cap modifier: {mods}")
            top = sorted(rows.items(), key=lambda kv: -kv[1].get("rail_works_levels", 0))[:10]
            print("  top Rail Works: " + ", ".join(f"{t} {r.get('rail_works_levels', 0):.0f}/{r.get('rail_cap_total', 0):.0f} (at cap {r.get('states_at_cap', 0):.0f}, AI surveys {r.get('ai_surveys', 0):.0f})" for t, r in top))
        else:
            print("No BOITM|rail lines.")
        fails = [f for f in fixtures if f[2] == "fail"]
        for date, check, result, kv in fixtures:
            if check in ("rs_cap_modifiers", "rs_lancashire_before", "rs_create_past_cap") or check.startswith("rs_ai_pass") or result == "fail":
                print(f"  {date} {check} {result} {kv}")
        starts = [f for f in fixtures if f[1] == "rs_start"]
        done = [f for f in fixtures if f[1] == "rs_complete" and f[2] == "pass"]
        print(f"  surveys started {len(starts)}, completed {len(done)}, fixture fails {len(fails)}")
        for date, check, result, kv in starts:
            print(f"    start {date} {kv.get('tag')}: states {kv.get('states', 0):.0f}, goal {kv.get('goal', 0):.1f}, rate {kv.get('rate', 0):.2f}, "
                  f"cost {kv.get('weekly_cost', 0):.0f}/wk ({kv.get('expenses_pct', 0):.2f}% of expenses), police x{kv.get('police_q', 0):.2f}")
        for date, check, result, kv in done:
            print(f"    done  {date} {kv.get('tag')} #{kv.get('n', 0):.0f}: {kv.get('months', 0):.0f} months, quality {kv.get('quality', 0):.0f}, "
                  f"+{kv.get('levels', 0):.0f} levels x {kv.get('states', 0):.0f} states, cap total {kv.get('cap_total', 0):.0f}")
            all_complete.append(kv)
        print()
    if all_complete:
        months = [k.get("months", 0) for k in all_complete]
        qual = [k.get("quality", 0) for k in all_complete]
        lv = [k.get("levels", 0) for k in all_complete]
        print(f"All completed surveys ({len(all_complete)}): months median {statistics.median(months):.0f} "
              f"(range {min(months):.0f}-{max(months):.0f}), quality median {statistics.median(qual):.0f} "
              f"(range {min(qual):.0f}-{max(qual):.0f}), levels median {statistics.median(lv):.0f}")


if __name__ == "__main__":
    main()
