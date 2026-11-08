"""Diff every shadowed vanilla block in BOI against the installed game.

Test-ShadowSources.ps1 only checks that each shadowed key still exists. A patch can
also change what is inside a block, and BOI's full copy then silently undoes it
(1.15 rewrote building_railway's AI logic this way). This script extracts each
shadowed block from BOI and from vanilla, drops comments and whitespace, and prints
a unified diff. Lines BOI added carry a `# BOI` tag in the source; lines tagged
that way are marked in the output so the remaining differences are vanilla drift.

Usage:
    python tools/Compare-ShadowBodies.py [--game PATH] [--key KEY] [--summary]

Exit code 0 always; read the report. Added 2026-11-06 for the 1.15 patch.
"""
import argparse
import difflib
import os
import re
import sys

DEFAULT_GAME = r"C:/Program Files (x86)/Steam/steamapps/common/Victoria 3/game"
MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# BOI shadow file -> vanilla folder holding the originals.
SHADOWS = [
    ("common/production_methods/00_boi_rail_port_overrides.txt", "common/production_methods"),
    ("common/production_methods/00_boi_transport_overrides.txt", "common/production_methods"),
    ("common/production_methods/00_boi_farm_overrides.txt", "common/production_methods"),
    ("common/production_methods/00_boi_subsistence_overrides.txt", "common/production_methods"),
    ("common/production_methods/00_boi_urban_transport_overrides.txt", "common/production_methods"),
    ("common/combat_unit_types/00_boi_cavalry_overrides.txt", "common/combat_unit_types"),
    ("common/mobilization_options/00_boi_supply_overrides.txt", "common/mobilization_options"),
    ("common/mobilization_options/00_boi_transport_overrides.txt", "common/mobilization_options"),
    ("common/buildings/00_boi_railway_ai_override.txt", "common/buildings"),
    ("common/buildings/00_boi_housing_rural_generated.txt", "common/buildings"),
]

KEY_RE = re.compile(r"^([a-z][a-z0-9_]*)\s*=\s*\{")


def read(path):
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        return f.read().splitlines()


def blocks(lines):
    """Top-level `key = { ... }` blocks: key -> list of raw lines."""
    out, key, depth, buf = {}, None, 0, []
    for line in lines:
        code = line.split("#", 1)[0]
        if key is None:
            m = KEY_RE.match(line)
            if not m:
                continue
            key, depth, buf = m.group(1), 0, []
        buf.append(line)
        depth += code.count("{") - code.count("}")
        if depth <= 0:
            out[key] = buf
            key = None
    return out


def normalise(raw, keep_tags):
    """Strip comments and whitespace. With keep_tags, mark BOI-tagged lines."""
    out = []
    for line in raw:
        code, _, comment = line.partition("#")
        code = " ".join(code.split())
        if not code:
            continue
        if keep_tags and "BOI" in comment:
            code += "   <- BOI"
        out.append(code)
    return out


def vanilla_index(game, folder):
    idx = {}
    d = os.path.join(game, folder)
    for name in sorted(os.listdir(d)):
        if name.endswith(".txt"):
            for k, v in blocks(read(os.path.join(d, name))).items():
                idx.setdefault(k, (name, v))
    return idx


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", default=DEFAULT_GAME)
    ap.add_argument("--key")
    ap.add_argument("--summary", action="store_true", help="one line per key")
    a = ap.parse_args()

    cache = {}
    changed = 0
    total = 0
    for rel, folder in SHADOWS:
        if folder not in cache:
            cache[folder] = vanilla_index(a.game, folder)
        van = cache[folder]
        for key, raw in blocks(read(os.path.join(MOD, rel))).items():
            if a.key and key != a.key:
                continue
            total += 1
            if key not in van:
                print(f"MISSING  {key}  ({rel}): no vanilla definition")
                changed += 1
                continue
            vfile, vraw = van[key]
            mine = normalise(raw, keep_tags=True)
            theirs = normalise(vraw, keep_tags=False)
            mine_plain = [l.replace("   <- BOI", "") for l in mine]
            diff = list(difflib.unified_diff(theirs, mine_plain, f"vanilla/{vfile}", f"boi/{os.path.basename(rel)}", lineterm="", n=1))
            if not diff:
                if not a.summary:
                    pass
                continue
            # Classify: BOI-only lines that aren't tagged, and vanilla lines BOI lacks.
            tagged = {l.replace("   <- BOI", "") for l in mine if l.endswith("<- BOI")}
            untagged_add = [d[1:] for d in diff if d.startswith("+") and not d.startswith("+++") and d[1:] not in tagged]
            removed = [d[1:] for d in diff if d.startswith("-") and not d.startswith("---")]
            changed += 1
            print(f"DIFF     {key}  ({rel} vs {vfile}): {len(removed)} vanilla lines absent in BOI, {len(untagged_add)} untagged BOI lines")
            if not a.summary:
                for d in diff:
                    print("    " + d)
    print(f"\n{total} shadowed blocks checked, {changed} differ from installed vanilla.")
    print("Every difference should be a documented BOI change. Anything else is vanilla drift to merge.")


if __name__ == "__main__":
    sys.exit(main())
