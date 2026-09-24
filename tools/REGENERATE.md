# Regenerating the two generated file sets

Both must be re-run after every Victoria 3 patch, or they silently drift from
vanilla. Set `GAME` first:

```bash
GAME="/c/Program Files (x86)/Steam/steamapps/common/Victoria 3/game"
MOD="/c/Users/mkury/Documents/Paradox Interactive/Victoria 3/mod/BurdenOfInfastructure"
```

## 1. State regions — the arable whitelist

A building whose group has `land_usage = rural` can only be built in states
whose `arable_resources` list names it. `building_boi_horse_ranch` must be
inserted into all 675 lists or it cannot be built anywhere on Earth.

```bash
mkdir -p "$MOD/map_data/state_regions"
for f in "$GAME"/map_data/state_regions/*.txt; do
  grep -q "arable_resources" "$f" || continue
  sed -E 's/(arable_resources = \{[^}]*)\}/\1"building_boi_horse_ranch" }/' \
    "$f" > "$MOD/map_data/state_regions/$(basename "$f")"
done

# Reapply the 12 Horse-Breeding Traditions assignments after copying vanilla.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File \
  "$MOD/tools/Add-HorseBreedingTrait.ps1"
```

Expect **16 files**, **675** Horse Ranch whitelist insertions, and **12**
Horse-Breeding Traditions assignments:

```bash
grep -h "building_boi_horse_ranch" "$MOD"/map_data/state_regions/*.txt | wc -l
grep -h "state_trait_boi_horse_breeding_traditions" "$MOD"/map_data/state_regions/*.txt | wc -l
```

## 2. The 1836 world seed

Seeded through history rather than a scripted effect because **only buildings
created during world initialization start staffed**.

Extract the two inputs, then generate:

```bash
# state -> owner (1147 actual pairs, 675 unique states; comments excluded)
awk '
  { sub(/#.*/, "") }
  /^[[:space:]]*"?s:STATE_[A-Z_]+"?[[:space:]]*=/ { s=$1; gsub(/"/,"",s); sub(/^s:/,"",s); st=s }
  /country[[:space:]]*=[[:space:]]*"?c:/ { if (match($0,/c:[A-Z_]+/)) print st"\t"substr($0,RSTART+2,RLENGTH-2) }
' "$GAME/common/history/states/00_states.txt" > /tmp/pairs.txt

# state -> coastal, arable_land   (the sub() strips the BOM, which otherwise
# defeats the ^ anchor and drops the first state of every file)
awk '
  { sub(/^\357\273\277/, "") }
  /^[[:space:]]*"?STATE_[A-Z_]+"?[[:space:]]*=[[:space:]]*\{/ { s=$1; gsub(/"/,"",s); st=s; port[st]=0; arable[st]=0; seen[st]=1 }
  /^[[:space:]]*port[[:space:]]*=/ { port[st]=1 }
  /^[[:space:]]*arable_land[[:space:]]*=/ { gsub(/[^0-9]/,"",$3); arable[st]=$3+0 }
  END { for (s in seen) print s"\t"port[s]"\t"arable[s] }
' "$GAME"/map_data/state_regions/*.txt | sort > /tmp/regions.txt

# keep only owned states
awk -F'\t' 'NR==FNR{o[$1];next} $1 in o' \
  <(cut -f1 /tmp/pairs.txt | sort -u) /tmp/regions.txt > /tmp/owned_regions.txt

# --- curation inputs for Horse Ranches (see note below) ---

# country -> primary cultures
awk '
  { sub(/^\357\273\277/,"") }
  /^[A-Z0-9_]{3}[[:space:]]*=[[:space:]]*\{/ { tag=$1 }
  /^[[:space:]]*cultures[[:space:]]*=[[:space:]]*\{/ {
    line=$0; sub(/.*\{/,"",line); sub(/\}.*/,"",line);
    gsub(/^[ \t]+|[ \t]+$/,"",line);
    if (tag!="" && line!="") print tag"\t"line
  }
' "$GAME"/common/country_definitions/*.txt | sort -u > /tmp/tag_cultures.txt

# state -> homeland cultures
awk '
  { sub(/^\357\273\277/,"") }
  /^[[:space:]]*"?s:STATE_[A-Z_]+"?[[:space:]]*=/ { if (match($0,/STATE_[A-Z_]+/)) st=substr($0,RSTART,RLENGTH) }
  /add_homeland[[:space:]]*=[[:space:]]*"?cu:/ { if (match($0,/cu:[a-z_]+/)) h[st]=h[st]" "substr($0,RSTART+3,RLENGTH-3) }
  END { for (s in h) print s"\t"h[s] }
' "$GAME/common/history/states/00_states.txt" | sort > /tmp/state_homelands.txt

# state -> count of vanilla-seeded industrial buildings
awk '/^building_[a-z_]* = \{/{n=$1} /building_group = bg_(light|heavy|military)_industry/{print n}' \
  "$GAME"/common/buildings/*.txt | sort -u > /tmp/industry.txt
awk 'NR==FNR{ind[$1]=1;next}
     { sub(/^\357\273\277/,"") }
     /s:STATE_[A-Z_]+/{ if (match($0,/STATE_[A-Z_]+/)) st=substr($0,RSTART,RLENGTH); if(!(seen[st]++)) cnt[st]=0 }
     /building="building_[a-z_]*"/{ if (match($0,/building_[a-z_]+/)) { b=substr($0,RSTART,RLENGTH); if (b in ind) cnt[st]++ } }
     END{ for(s in seen) print s"\t"cnt[s] }' \
  /tmp/industry.txt "$GAME"/common/history/buildings/*.txt | sort > /tmp/industry_by_state.txt

# decide which states get a ranch
awk -f "$MOD/tools/curate.awk" /tmp/pairs.txt /tmp/tag_cultures.txt \
    /tmp/state_homelands.txt /tmp/industry_by_state.txt /tmp/owned_regions.txt \
  | sort > /tmp/curated.txt
grep "	RANCH" /tmp/curated.txt | cut -f1 | sort > /tmp/ranch.txt

awk -f "$MOD/tools/gen_seed.awk" /tmp/pairs.txt /tmp/ranch.txt /tmp/owned_regions.txt \
  "$MOD/tools/horse_seed_additions.tsv" "$MOD/tools/horse_seed_holds.tsv" \
  "$MOD/tools/infrastructure_seed_plan.tsv" "$MOD/tools/horse_seed_reductions.tsv" \
  > "$MOD/common/history/buildings/zz_boi_buildings.txt"
```

`owned_regions.txt` is ordered by state because `regions.txt` is sorted above.
`gen_seed.awk` preserves that order, so identical inputs now produce byte-for-byte
identical seed output. Keep the `sort > /tmp/regions.txt` step if this procedure
is adapted.

Expected output on 1.13 — the script prints these counts to stderr:

```
generated: 20 Public Works (40 levels), 139 Harbour Works (141 levels), 225 Horse Ranches (857 levels)
```

### Why Horse Ranches are curated

Horse Ranches are rural, so they consume **arable land** — and a state's *real*
arable land depends on incorporation status and province ownership, neither of
which can be read statically. `STATE_BALUCHISTAN` declares `arable_land = 63`;
the Omani state that owns part of it actually has **1**.

Seeding by declared `arable_land` over-allocated 10 states and logged

```
State New South Welsh Northern Territory is using an excess of 3 arable land (total arable land: 0)
```

immediately before a hard crash during world initialization. `curate.awk`
therefore requires **core + sole owner + low industry + arable >= 25**, which
excludes all 10 known failures. Fifteen previously seeded states are explicitly
unincorporated despite passing the core-culture proxy. Their previously tested
three levels in `horse_seed_holds.tsv` are an upper bound. Incorporated baseline
states receive 4/6/8 levels according to declared arable land (<50 / 50-99 /
100+), then the reviewed reductions in `horse_seed_reductions.tsv` are applied.
Fourteen new core, sole-owner, incorporated states with at least 12
declared arable levels left after seeding are listed in
`horse_seed_additions.tsv`. Recheck this audit after every game patch; declared
headroom is a static proxy, not an in-game guarantee.

Sanity checks:

```bash
f="$MOD/common/history/buildings/zz_boi_buildings.txt"
grep -c '^	s:STATE_' "$f"                       # 675
echo "$(grep -o '{' "$f"|wc -l) $(grep -o '}' "$f"|wc -l)"   # must match
head -c 3 "$f" | od -An -tx1                     # ef bb bf
```

If the counts move after a patch, that is real information — Paradox added,
removed, or re-owned states. Diff the numbers before assuming the script broke.
