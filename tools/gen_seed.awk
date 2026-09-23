# Generate the 1836 world seed.
#
# Inputs, in order:
#   1 pairs.txt          STATE \t TAG   (all owners; first occurrence = primary)
#   2 ranch.txt          STATE          (states curated for a Horse Ranch)
#   3 owned_regions.txt  STATE \t port \t arable

BEGIN { FS = "\t" }

FILENAME ~ /pairs/         { if (!($1 in owner)) owner[$1] = $2; next }
FILENAME ~ /ranch/         { ranch[$1] = 1; next }
FILENAME ~ /owned_regions/ {
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

END {
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
    print "#  PRIMARY OWNER ONLY. 219 of the 675 owned states are split"
    print "#  between two or more countries; a state region's arable land is"
    print "#  shared, so seeding every region_state double-allocates it."
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
    print "#  Ranches are therefore restricted to states that are:"
    print "#    CORE          owner's primary culture is a homeland culture"
    print "#                  of the state (proxy for incorporated)"
    print "#    SOLE OWNER    region not split between countries"
    print "#    LOW INDUSTRY  vanilla seeds <= 1 industrial building there"
    print "#    ARABLE >= 25  declared by the state region"
    print "#  All 10 previously failing states are excluded by these gates."
    print "#"
    print "#  Public Works and Harbour Works are NOT rural and cost no"
    print "#  arable land, so they are seeded everywhere they apply."
    print "#"
    print "#  Only the base method PM is forced. Administration PMs are left"
    print "#  unset so the engine resolves them from each country's"
    print "#  Bureaucracy law."
    print "# ================================================================"
    print ""
    print "BUILDINGS = {"

    n = 0; nh = 0; nr = 0
    for (i = 1; i <= state_count; i++) {
        s = state_order[i]
        if (!(s in owner)) continue
        tag = owner[s]
        printf "\ts:%s = {\n", s
        printf "\t\tregion_state:%s = {\n", tag
        printf "%s", bldg("building_boi_infrastructure", tag, 2, "pm_boi_cart_roads")
        n++
        if (port[s] == 1) {
            printf "%s", bldg("building_boi_harbour_works", tag, 1, "pm_boi_coastal_lighters")
            nh++
        }
        if (s in ranch) {
            printf "%s", bldg("building_boi_horse_ranch", tag, 3, "pm_boi_open_pasture")
            nr++
        }
        printf "\t\t}\n"
        printf "\t}\n"
    }
    print "}"
    printf "generated: %d Public Works, %d Harbour Works, %d Horse Ranches\n", n, nh, nr > "/dev/stderr"
}
