r"""Summarise world horse supply, demand and prices from a headless run's
BOIHS|horses lines (housing telemetry module, one line per state per year).

    python tools/Get-HorseMarkets.py <run folder> [--year 1840] [--top 16]

Prints, for each year: world demand and supply, ranch and other supply, state
price bands by demand served, and the largest countries' balance. Supply and
demand are state sell and buy orders, and both appear to include traded horses:
"elsewhere" is mostly imports through port states, plus subsistence pasture.
Pulses are staggered, so a year's lines are not all from one day.
"""
import argparse, collections, glob, os, re

ap = argparse.ArgumentParser()
ap.add_argument('run')
ap.add_argument('--year', type=int)
ap.add_argument('--top', type=int, default=16)
args = ap.parse_args()

text = ''
for path in sorted(glob.glob(os.path.join(args.run, 'logs', 'debug*.log')), key=os.path.getmtime):
    text += open(path, encoding='utf-8', errors='ignore').read()
pat = re.compile(r'BOIHS\|horses\|([^|]*)\|([^|]*)\|([^|]*)\|ranch=([\d.,]*);buy=([\d.,]*);sell=([\d.,]*);price=([\d.,]*)')
num = lambda s: float(s.replace(',', '') or 0)
years = collections.defaultdict(dict)
for date, tag, state, ranch, buy, sell, price in pat.findall(text):
    if '[' in tag or not tag:
        continue
    state = re.sub(r'[\x00-\x1f]', '', state)
    state = re.sub(r'^.*StateRegionTooltip ', '', state).rstrip('!')
    years[int(date[-4:])][(tag, state)] = (num(ranch), num(buy), num(sell), num(price))

for year in sorted(years):
    rows = years[year]
    if len(rows) < 100 or (args.year and year != args.year):
        continue
    buy = sum(r[1] for r in rows.values())
    sell = sum(r[2] for r in rows.values())
    levels = sum(r[0] for r in rows.values())
    ranch_sell = sum(r[2] for r in rows.values() if r[0] > 0)
    bands = collections.Counter()
    for r in rows.values():
        band = '<24' if r[3] < 24 else '24-30' if r[3] < 30 else '30-36' if r[3] < 36 else '36-45' if r[3] < 45 else '45-52' if r[3] < 52 else 'ceiling'
        bands[band] += r[1]
    print(f'{year}: states {len(rows)}, demand {buy:.0f}, supply {sell:.0f} ({100*sell/buy:.0f}%), ranch levels {levels:.0f}, '
          f'supply in ranch states {ranch_sell:.0f}, elsewhere {sell-ranch_sell:.0f}')
    print('  share of demand by state price: ' + ', '.join(f'{b} {100*bands[b]/buy:.0f}%' for b in ('<24', '24-30', '30-36', '36-45', '45-52', 'ceiling')))
    by = collections.defaultdict(lambda: [0, 0, 0, 0])
    for (tag, _), r in rows.items():
        by[tag][0] += r[0]; by[tag][1] += r[1]; by[tag][2] += r[2]; by[tag][3] += r[3] * r[1]
    print('  tag   ranch  demand  supply  mean price')
    for tag, v in sorted(by.items(), key=lambda kv: -kv[1][1])[:args.top]:
        print(f'  {tag:<5} {v[0]:5.0f} {v[1]:7.0f} {v[2]:7.0f} {v[3]/v[1] if v[1] else 0:8.1f}')
