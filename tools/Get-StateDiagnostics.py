r"""Summarise market connection, civil wars and unrest from a headless run's BOICT|
and BOIST| lines (boi telemetry module).

    python tools/Get-StateDiagnostics.py <run folder> [--tag GBR] [--year 1845]

Prints, per year: isolated states, states on low market access, tags held by two
countries at once, and the largest unrest. With --tag it adds one row per state for
that tag. Countries are keyed by engine id, because civil-war rebels take their
parent's tag. Lines are staggered per country. Runs before 2026-11-01 15:18 also hold
BOIST|isolated (monthly) and BOIST|shortage lines, which were later removed.
"""
import argparse, collections, os, re

ap = argparse.ArgumentParser()
ap.add_argument('run')
ap.add_argument('--tag')
ap.add_argument('--year')
args = ap.parse_args()

text = open(os.path.join(args.run, 'logs', 'debug.log'), encoding='utf-8', errors='ignore').read()


def clean(name):
    name = re.sub(r'[\x00-\x1f]', '', name)
    return re.sub(r'^.*StateRegionTooltip ', '', name).rstrip('!')


def values(body):
    out = {}
    for part in body.split(';'):
        key, _, value = part.partition('=')
        try:
            out[key] = float(value.replace(',', ''))
        except ValueError:
            out[key] = value
    return out


countries = collections.defaultdict(dict)  # (year, id) -> merged values
for kind, date, tag, cid, body in re.findall(r'BOICT\|(\w+)\|([^|]*)\|([^|]*)\|([^|]*)\|([^\r\n]*)', text):
    if tag and '[' not in tag and '[' not in body:
        row = countries[(date[-4:], cid)]
        row.update(values(body)); row['tag'] = tag; row['date'] = date

states = collections.defaultdict(dict)  # (year, id, state) -> merged values
monthly = collections.defaultdict(set)  # (tag, state) -> dates isolated
for kind, date, tag, cid, name, body in re.findall(r'BOIST\|(\w+)\|([^|]*)\|([^|]*)\|([^|]*)\|([^|]*)\|([^\r\n]*)', text):
    if not tag or '[' in tag or '[' in body:
        continue
    if kind == 'isolated':
        monthly[(tag, clean(name))].add(date)
        continue
    row = states[(date[-4:], cid, clean(name))]
    row.update({f'{kind}_{k}' if kind == 'transport' else k: v for k, v in values(body).items()})
    row['tag'] = tag

years = sorted({key[0] for key in states})
for year in years:
    if args.year and year != args.year:
        continue
    rows = {k: v for k, v in states.items() if k[0] == year}
    if len(rows) < 100:
        continue
    # Isolated states read exactly 0 market access; the trigger itself isn't logged.
    iso = [v for v in rows.values() if v.get('isolated') == 1 or v.get('access') == 0]
    low = [v for v in rows.values() if isinstance(v.get('access'), float) and v['access'] < 0.9]
    short = sum(v.get('short_buildings', 0) for v in rows.values())
    pop = sum(v.get('pop', 0) for v in rows.values()) or 1
    radicals = sum(v.get('radicals', 0) for v in rows.values())
    tags = collections.Counter(v['tag'] for k, v in countries.items() if k[0] == year)
    doubled = {t: sorted((int(v.get('states', 0)) for k, v in countries.items() if k[0] == year and v['tag'] == t), reverse=True) for t, n in tags.items() if n > 1}
    wars = sum(1 for k, v in countries.items() if k[0] == year and v.get('at_war') == 1)
    isotags = collections.Counter(v['tag'] for v in iso)
    print(f"{year}: states {len(rows)}, isolated {len(iso)} ({sum(v.get('pop', 0) for v in iso) / 1e6:.2f}M) {isotags.most_common(6)}, "
          f"access<90% {len(low)}, short buildings {short:.0f}, radicals {100 * radicals / pop:.1f}% of pop, at war {wars}, same-tag splits {doubled}")

print('--- states isolated at any monthly check')
for (tag, name), dates in sorted(monthly.items(), key=lambda kv: -len(kv[1])):
    if args.tag and tag != args.tag:
        continue
    ordered = sorted(dates, key=lambda d: (d[-4:], d))
    print(f'{tag:<6}{name:<28}{len(dates):4d} months, first in {ordered[0][-4:]}, last in {ordered[-1][-4:]}')

if args.tag:
    wanted = args.year or (years[-2] if len(years) > 1 else years[-1])
    print(f'--- {args.tag} states, {wanted}')
    print('id    state                        iso access port rail  pw  hw  pop(k) radicals turmoil short')
    for (year, cid, name), v in sorted(states.items(), key=lambda kv: (kv[0][1], -kv[1].get('pop', 0))):
        if year == wanted and v['tag'] == args.tag:
            print(f"{cid:<6}{name:<28} {v.get('isolated', 0):3.0f} {v.get('access', 0):6.2f} {v.get('port', 0):4.0f} {v.get('rail', 0):4.0f} "
                  f"{v.get('pw', 0):3.0f} {v.get('hw', 0):3.0f} {v.get('pop', 0) / 1e3:7.0f} {v.get('radicals', 0) / 1e3:7.0f}k {v.get('turmoil', 0):7.2f} {v.get('short_buildings', 0):5.0f}")
    print(f'--- {args.tag} by year and engine id')
    for (year, cid), v in sorted(countries.items()):
        if v['tag'] == args.tag:
            print(year, cid, v.get('date'), {k: v.get(k) for k in ('states', 'at_war', 'radicals', 'loyalists', 'turmoil', 'market', 'income', 'expenses', 'debt')})
