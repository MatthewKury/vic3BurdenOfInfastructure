"""Generate common/history/buildings/zz_boi_public_works_seed_generated.txt.

One Public Works hub for every state that exists at the 1836 start (plan 12). History
seeding is used because only buildings created at world initialisation start staffed
(VIC3_MODDING_LESSONS.md, "Seeding buildings at game start"), and the user asked for
the hub to be staffed from day one.

- Every create_state in vanilla common/history/states/00_states.txt gets one hub,
  owned by that state's country.
- Coastal Public Works where vanilla's own history gives that region_state a
  building_port. Those states are certainly coastal, so the coastal building's
  potential (is_coastal = yes) holds. Every other state gets the inland building,
  which has no potential, so a coastal state without a port is still valid. Script
  places the right type for states that appear later.
- Levels come from tools/public_works_seed_levels.tsv (STATE \t TAG \t levels), measured
  in a short headless run (the hub's monthly update logs BOIPW|target lines); any state
  not listed starts at 1.

    python tools/Build-PublicWorksSeed.py [--game PATH] [--from-run RUN_FOLDER_NAME]

--from-run first rebuilds tools/public_works_seed_levels.tsv from a run made with
Test-Headless.ps1 -PwSeed (BOIPWSEED lines; state names are mapped back to keys
through vanilla's states_l_english.yml).
"""
import argparse
import os
import re
import sys

ap = argparse.ArgumentParser()
ap.add_argument('--game', default=r'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game')
ap.add_argument('--from-run')
ap.add_argument('--cap', type=float, default=None, help='recompute levels as ceil(chargeable / CAP) instead of the logged target (the hub CAP in common/script_values/57_boi_public_works_values.txt)')
args = ap.parse_args()
GAME = args.game
MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATES = os.path.join(GAME, 'common', 'history', 'states', '00_states.txt')
HIST_BUILDINGS = os.path.join(GAME, 'common', 'history', 'buildings')
LEVELS = os.path.join(MOD, 'tools', 'public_works_seed_levels.tsv')
OUT = os.path.join(MOD, 'common', 'history', 'buildings', 'zz_boi_public_works_seed_generated.txt')


def blocks(text, key_re):
    """Yield (key, body) for each `key = { body }` matching key_re at the current depth."""
    for m in re.finditer(key_re + r'\s*=\s*\{', text):
        depth = 0
        for j in range(text.index('{', m.start()), len(text)):
            if text[j] == '{':
                depth += 1
            elif text[j] == '}':
                depth -= 1
                if depth == 0:
                    yield m.group(1), text[text.index('{', m.start()) + 1:j]
                    break


def strip_comments(text):
    return re.sub(r'#[^\n]*', '', text)


states_text = strip_comments(open(STATES, encoding='utf-8-sig').read())
pairs = []  # (STATE_X, TAG) in file order
for state, body in blocks(states_text, r'\bs:(STATE_[A-Z0-9_]+)'):
    for m in re.finditer(r'create_state\s*=\s*\{[^{}]*?country\s*=\s*c:([A-Z0-9_]+)', body):
        pairs.append((state, m.group(1)))

ports = set()
for name in sorted(os.listdir(HIST_BUILDINGS)):
    if not name.endswith('.txt'):
        continue
    text = strip_comments(open(os.path.join(HIST_BUILDINGS, name), encoding='utf-8-sig').read())
    for state, body in blocks(text, r'\bs:(STATE_[A-Z0-9_]+)'):
        for tag, rbody in blocks(body, r'\bregion_state:([A-Z0-9_]+)'):
            if re.search(r'building\s*=\s*"?building_port"?', rbody):
                ports.add((state, tag))

if args.from_run:
    loc = open(os.path.join(GAME, 'localization', 'english', 'map', 'states_l_english.yml'), encoding='utf-8-sig').read()
    by_name = {}
    for key, name in re.findall(r'(?m)^\s*(STATE_[A-Z0-9_]+):\d*\s*"([^"]*)"', loc):
        by_name.setdefault(name, []).append(key)
    log = os.path.join(MOD, 'tools', 'headless-runs', args.from_run, 'logs', 'debug.log')
    rows, unmatched = {}, []
    for line in open(log, encoding='utf-8', errors='replace'):
        m = re.search(r'BOIPWSEED\|([^|]*)\|([^|]*)\|target=(\d+);chargeable=([0-9.]+)', line)
        if not m:
            continue
        # GetTagName / GetName print tooltip markup, e.g.
        # "tooltippable_name tooltip:…,StateRegionTooltip Buenos Aires!!".
        tag = re.sub(r'.*\s', '', re.sub(r'[\x00-\x1f]!?', '', m.group(1)).replace('!!', '')).strip()
        name = re.sub(r'[\x00-\x1f]!?', '', m.group(2)).replace('!!', '')
        name = re.sub(r'^.*StateRegionTooltip ', '', name)
        name = name.rsplit(',', 1)[-1].strip()  # "...DATA_STATE_REGION_NAME_TOOLTIP,Transvaal"
        tag = tag.rsplit(',', 1)[-1].strip()
        target = int(m.group(3))
        if args.cap:
            import math
            target = max(1, math.ceil(float(m.group(4)) / args.cap))
        keys = by_name.get(name, [])
        if len(keys) != 1:
            unmatched.append(f'{tag} {name} ({len(keys)} keys)')
            continue
        rows[(keys[0], tag)] = target
    with open(LEVELS, 'w', encoding='utf-8', newline='\n') as f:
        f.write(f'# STATE\tTAG\tlevels; generated from run {args.from_run} by tools/Build-PublicWorksSeed.py\n')
        for (state, tag), n in sorted(rows.items()):
            if n > 1:
                f.write(f'{state}\t{tag}\t{n}\n')
    print(f'{len(rows)} states measured, {sum(1 for n in rows.values() if n > 1)} above level 1; '
          f'{len(unmatched)} names unmatched: {unmatched[:8]}')

levels = {}
if os.path.exists(LEVELS):
    for line in open(LEVELS, encoding='utf-8-sig'):
        parts = line.strip().split('\t')
        if len(parts) >= 3 and parts[0].startswith('STATE_') and parts[2].isdigit():
            levels[(parts[0], parts[1])] = max(1, int(parts[2]))

seen = set()
out = ['# ================================================================',
       '#  Burden of Infrastructure - 1836 Public Works seed   (GENERATED FILE)',
       '#  DO NOT HAND-EDIT. Rebuild with: python tools/Build-PublicWorksSeed.py',
       '#  One staffed hub per starting state; coastal where vanilla seeds a port.',
       '# ================================================================',
       'BUILDINGS = {']
coastal = inland = total_levels = 0
by_state = {}
for state, tag in pairs:
    if (state, tag) in seen:
        continue
    seen.add((state, tag))
    by_state.setdefault(state, []).append(tag)
for state, tags in by_state.items():
    out.append(f'\ts:{state} = {{')
    for tag in tags:
        is_coastal = (state, tag) in ports
        building = 'building_boi_coastal_public_works' if is_coastal else 'building_boi_public_works'
        n = levels.get((state, tag), 1)
        total_levels += n
        coastal += is_coastal
        inland += not is_coastal
        out += [f'\t\tregion_state:{tag} = {{',
                '\t\t\tcreate_building = {',
                f'\t\t\t\tbuilding = "{building}"',
                f'\t\t\t\tadd_ownership = {{ country = {{ country = "c:{tag}" levels = {n} }} }}',
                '\t\t\t\treserves = 1',
                '\t\t\t}',
                '\t\t}']
    out.append('\t}')
out.append('}')
with open(OUT, 'w', encoding='utf-8-sig', newline='\n') as f:
    f.write('\n'.join(out) + '\n')
print(f'Wrote {OUT}: {coastal} coastal + {inland} inland hubs, {total_levels} levels '
      f'({len(levels)} measured states).')
