r"""Turn a headless run's BOIHS| lines into tools/housing_seed_demand_1836.tsv.

The 1836 residential seed (tools/Build-Housing.ps1) reads that file, so that
regenerating the seed needs neither the game nor Python. Measure with a one-year
run that has no seed, so demand isn't affected by the seed it will feed:
temporarily empty common/history/buildings/zz_boi_housing_seed_generated.txt, then

    .\tools\Test-Headless.ps1 -UntilDate 1837.1.1 -Autosave never -NoSaves -NoFixtures
    python tools/Get-HousingSeedDemand.py <run folder name> --game <game folder>

Alentejo is left out because the housing fixtures build there. Owners that history
doesn't give the state in 1836 are also left out, because they formed or conquered
it during the year and a seed entry for them would not load.
"""
import argparse
import glob
import os
import re

TOOLS = os.path.dirname(os.path.abspath(__file__))
DEFAULT_GAME = 'C:/Program Files (x86)/Steam/steamapps/common/Victoria 3/game'


def region_keys(game):
    keys = {}
    for path in glob.glob(game + '/localization/english/**/*.yml', recursive=True):
        text = open(path, encoding='utf-8-sig').read()
        for key, name in re.findall(r'(?m)^\s*(STATE_[A-Z0-9_]+):\d*\s+"([^"]+)"', text):
            keys.setdefault(name, key)
    return keys


def starting_owners(game):
    text = open(game + '/common/history/states/00_states.txt', encoding='utf-8-sig').read()
    owners = {}
    region = None
    for m in re.finditer(r's:(STATE_[A-Z0-9_]+)|create_state\s*=\s*\{\s*country\s*=\s*"?c:([A-Z0-9]+)', text):
        if m.group(1):
            region = m.group(1)
        else:
            owners.setdefault(region, set()).add(m.group(2))
    return owners


def read_states(run):
    text = open(f'{TOOLS}/headless-runs/{run}/logs/debug.log', encoding='utf-8', errors='replace').read()
    states = {}
    for m in re.finditer(r'BOIHS\|(\w+)\|[^|]+\|([^|]+)\|([^\r\n]*)', text):
        kind, tag, rest = m.groups()
        head, _, values = rest.rpartition('|')
        name = re.search(r'StateRegionTooltip (.*?)\x15', head).group(1)
        record = states.setdefault((tag, name), {})
        for part in values.split(';'):
            key, _, value = part.partition('=')
            record[f'{kind}_{key}'] = float(value)
    return states


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('run')
    parser.add_argument('--game', default=DEFAULT_GAME)
    args = parser.parse_args()
    keys = region_keys(args.game)
    owners = starting_owners(args.game)
    rows = []
    for (tag, name), r in read_states(args.run).items():
        region = keys[name]
        if tag in owners.get(region, ()) and region != 'STATE_ALENTEJO':
            rows.append((region, tag, r))
    rows.sort(key=lambda row: row[:2])
    with open(f'{TOOLS}/housing_seed_demand_1836.tsv', 'w', encoding='utf-8', newline='\n') as out:
        out.write('region\towner\tpopulation\turban_center\tindustry\tresidential\thousing_demand\thousing_supply\tluxury_demand\n')
        for region, tag, r in rows:
            out.write(f"{region}\t{tag}\t{int(r['state_pop'])}\t{int(r['state_uc'])}\t{int(r['state_ind'])}\t{int(r['state_res'])}\t{r['housing_buy']}\t{r['housing_sell']}\t{r['luxury_buy']}\n")
    print(f'Wrote {len(rows)} state-owner rows.')


if __name__ == '__main__':
    main()
