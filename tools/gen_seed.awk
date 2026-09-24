# Generate the 1836 world seed.
#
# Inputs, in order:
#   1 pairs.txt          STATE \t TAG   (all owners; first occurrence = primary)
#   2 ranch.txt          STATE          (states curated for a Horse Ranch)
#   3 owned_regions.txt  STATE \t port \t arable
#   4 horse_seed_additions.tsv STATE \t levels (reviewed new ranches)
#   5 horse_seed_holds.tsv STATE \t levels (keep proven-safe unincorporated seed)
#   6 infrastructure_seed_plan.tsv STATE \t TAG \t Public Works \t Harbour Works
#   7 horse_seed_reductions.tsv STATE \t final Horse Ranch levels (0 removes)

BEGIN { FS = "\t" }

FILENAME ~ /pairs\.txt$/ {
    if (!($1 in owner)) owner[$1] = $2
    key = $1 SUBSEP $2
    state_owner[key] = 1
    owner_count[$1]++
    owner_order[$1 SUBSEP owner_count[$1]] = $2
    next
}
FILENAME ~ /ranch\.txt$/ {
    if (FNR == 1) sub(/^\357\273\277/, "", $1)
    ranch[$1] = 1
    next
}
FILENAME ~ /infrastructure_seed_plan\.tsv$/ {
    if ($1 ~ /^STATE_/ && $2 ~ /^[A-Z0-9_]+$/ && $3 ~ /^[0-9]+$/ && $4 ~ /^[0-9]+$/ && ($3 + $4) > 0) {
        key = $1 SUBSEP $2
        works[key] = $3 + 0
        harbour[key] = $4 + 0
    }
    next
}
FILENAME ~ /horse_seed_additions\.tsv$/ {
    if ($1 ~ /^STATE_/ && $2 > 0) extra[$1] = $2 + 0
    next
}
FILENAME ~ /horse_seed_holds\.tsv$/ {
    if ($1 ~ /^STATE_/ && $2 > 0) hold[$1] = $2 + 0
    next
}
FILENAME ~ /horse_seed_reductions\.tsv$/ {
    if ($1 ~ /^STATE_/ && $2 ~ /^[0-9]+$/) reduction[$1] = $2 + 0
    next
}
FILENAME ~ /owned_regions\.txt$/ {
    port[$1] = $2; arable[$1] = $3
    # Preserve the sorted input order instead of iterating an AWK associative
    # array. REGENERATE.md creates owned_regions.txt from sorted regions.txt.
    if (!($1 in states)) state_order[++state_count] = $1
    states[$1] = 1
    next
}

function bldg(name, tag, lvl, pm,   s) {
    s = "\t\t\tcreate_building = {\n"
    s = s "\t\t\t\tbuilding = \"" name "\"\n"
    s = s "\t\t\t\tadd_ownership = {\n"
    s = s "\t\t\t\t\tcountry = {\n"
    s = s "\t\t\t\t\t\tcountry = \"c:" tag "\"\n"
    s = s "\t\t\t\t\t\tlevels = " lvl "\n"
    s = s "\t\t\t\t\t}\n"
    s = s "\t\t\t\t}\n"
    s = s "\t\t\t\treserves = 1\n"
    s = s "\t\t\t\tactivate_production_methods = { \"" pm "\" }\n"
    s = s "\t\t\t}\n"
    return s
}

function base_ranch_level(s) {
    if (s in extra) return extra[s]
    if (s in hold) return hold[s]
    return (arable[s] >= 100 ? 8 : (arable[s] >= 50 ? 6 : 4))
}

function ranch_level(s) {
    if (!((s in ranch) || (s in extra))) return 0
    return (s in reduction) ? reduction[s] : base_ranch_level(s)
}

END {
    for (s in extra) {
        if (!(s in states) || !(s in owner) || (s in ranch) || (s in hold)) {
            printf "invalid additional Horse Ranch state: %s\n", s > "/dev/stderr"
            exit 1
        }
    }
    for (s in hold) {
        if (!(s in ranch) || !(s in states)) {
            printf "invalid held Horse Ranch state: %s\n", s > "/dev/stderr"
            exit 1
        }
    }
    for (s in reduction) {
        if (!(s in states) || !((s in ranch) || (s in extra)) ||
            reduction[s] >= base_ranch_level(s)) {
            printf "invalid Horse Ranch reduction: %s\n", s > "/dev/stderr"
            exit 1
        }
    }
    for (key in works) {
        split(key, parts, SUBSEP)
        s = parts[1]
        if (!(key in state_owner) || !(s in states) || (harbour[key] > 0 && port[s] != 1)) {
            printf "invalid infrastructure seed state-owner: %s %s (pair=%d state=%d port=%s harbour=%d owner=%s count=%d)\n", s, parts[2], (key in state_owner), (s in states), port[s], harbour[key], owner[s], owner_count[s] > "/dev/stderr"
            exit 1
        }
    }
    printf "\357\273\277"
    print "# ================================================================"
    print "#  Burden of Infrastructure - 1836 world seed   (GENERATED FILE)"
    print "#"
    print "#  DO NOT HAND-EDIT. See tools/REGENERATE.md."
    print "#"
    print "#  WHY HISTORY AND NOT A SCRIPTED EFFECT: buildings created during"
    print "#  world initialization start STAFFED. on_game_started fires after"
    print "#  init, by which point pops are already allocated, so anything"
    print "#  created there starts with zero employees and hires over several"
    print "#  weeks. create_building has no employment parameter and the game"
    print "#  has no employment effect, so history is the only way."
    print "#"
    print "#  Horse Ranches go to the primary owner only: 218 of the 675"
    print "#  owned state regions are split, and rural land is shared."
    print "#  Public Works and Harbour Works follow each actual state owner"
    print "#  in infrastructure_seed_plan.tsv, including split regions."
    print "#"
    print "#  HORSE RANCHES ARE CURATED - and this is the important part."
    print "#  A state's REAL arable land depends on incorporation status and"
    print "#  province ownership, neither of which can be read statically."
    print "#  Seeding by the state region's declared arable_land over-"
    print "#  allocated 10 states (STATE_BALUCHISTAN declares 63; the Omani"
    print "#  state actually had 1) and produced:"
    print "#      \"State X is using an excess of N arable land\""
    print "#  immediately before a hard crash during world init."
    print "#"
    print "#  The baseline curated ranches are restricted to states that are:"
    print "#    CORE          owner's primary culture is a homeland culture"
    print "#                  of the state (proxy for incorporated)"
    print "#    SOLE OWNER    region not split between countries"
    print "#    LOW INDUSTRY  vanilla seeds <= 1 industrial building there"
    print "#    ARABLE >= 25  declared by the state region"
    print "#  All 10 previously failing states are excluded by these gates."
    print "#  Incorporated baseline levels scale with declared arable land:"
    print "#  4 below 50, 6 from 50 to 99, and 8 at 100 or above. Fifteen"
    print "#  baseline states are explicitly unincorporated in game history;"
    print "#  their previously safe 3 levels are a cap (horse_seed_holds.tsv)."
    print "#  Fourteen new core, sole-owner, incorporated states with safe"
    print "#  land headroom are listed in horse_seed_additions.tsv."
    print "#  Lower 1836 levels follow horse_seed_reductions.tsv. Zero removes"
    print "#  a ranch; reductions favor less suitable breeding regions."
    print "#"
    print "#  Public Works and Harbour Works are NOT rural and cost no"
    print "#  arable land. Starting levels replace vanilla port and rail"
    print "#  infrastructure with minimal unavoidable rounding surplus."
    print "#"
    print "#  Only the base method PM is forced. Administration PMs are left"
    print "#  unset so the engine resolves them from each country's"
    print "#  Bureaucracy law."
    print "# ================================================================"
    print ""
    print "BUILDINGS = {"

    n = 0; nh = 0; nr = 0; np = 0; nhr = 0; nrl = 0
    for (i = 1; i <= state_count; i++) {
        s = state_order[i]
        if (!(s in owner)) continue
        present = (ranch_level(s) > 0)
        for (j = 1; j <= owner_count[s]; j++) {
            tag = owner_order[s SUBSEP j]
            key = s SUBSEP tag
            if (key in works) present = 1
        }
        if (!present) continue
        printf "\ts:%s = {\n", s
        for (j = 1; j <= owner_count[s]; j++) {
            tag = owner_order[s SUBSEP j]
            key = s SUBSEP tag
            if (!(key in works) && !(ranch_level(s) > 0 && tag == owner[s])) continue
            printf "\t\tregion_state:%s = {\n", tag
            if (works[key] > 0) {
                printf "%s", bldg("building_boi_infrastructure", tag, works[key], "pm_boi_cart_roads")
                n++; np += works[key]
            }
            if (harbour[key] > 0) {
                printf "%s", bldg("building_boi_harbour_works", tag, harbour[key], "pm_boi_coastal_lighters")
                nh++; nhr += harbour[key]
            }
            if (ranch_level(s) > 0 && tag == owner[s]) {
                lvl = ranch_level(s)
                printf "%s", bldg("building_boi_horse_ranch", tag, lvl, "pm_boi_open_pasture")
                nr++; nrl += lvl
            }
            printf "\t\t}\n"
        }
        printf "\t}\n"
    }
    print "}"
    printf "generated: %d Public Works (%d levels), %d Harbour Works (%d levels), %d Horse Ranches (%d levels)\n", n, np, nh, nhr, nr, nrl > "/dev/stderr"
}
