# Decide which states get a seeded Horse Ranch.
#
# Inputs, in order:
#   1 pairs.txt            STATE \t TAG        (all owners; first = primary)
#   2 tag_cultures.txt     TAG   \t "c1 c2"
#   3 state_homelands.txt  STATE \t " h1 h2"
#   4 industry_by_state.txt STATE \t N
#   5 owned_regions.txt    STATE \t port \t arable
#
# A state qualifies only if ALL hold:
#   CORE          owner's primary culture is a homeland culture of the state
#                 (proxy for "incorporated" - the real driver of a state's
#                 arable land, which cannot be read statically)
#   LOW INDUSTRY  vanilla seeds <= MAXIND industrial buildings there
#   ARABLE        state region declares arable_land >= MINARABLE
#   SOLE OWNER    the state region is not split between countries
#                 (split regions share arable land)

BEGIN { FS = "\t"; MAXIND = 1; MINARABLE = 25 }

FILENAME ~ /pairs/        { if (!($1 in owner)) owner[$1] = $2; nown[$1]++; next }
FILENAME ~ /tag_cultures/ { cult[$1] = " " $2 " "; next }
FILENAME ~ /homelands/    { home[$1] = $2 " "; next }
FILENAME ~ /industry/     { ind[$1] = $2 + 0; next }
FILENAME ~ /owned_regions/{ port[$1] = $2; arable[$1] = $3 + 0; st[$1] = 1; next }

END {
    for (s in st) {
        if (!(s in owner)) continue
        tag = owner[s]

        core = 0
        if ((tag in cult) && (s in home)) {
            n = split(cult[tag], cs, " ")
            for (i = 1; i <= n; i++) {
                if (cs[i] != "" && index(home[s], " " cs[i] " ") > 0) { core = 1; break }
            }
        }

        sole    = (nown[s] == 1)
        lowind  = (ind[s] + 0 <= MAXIND)
        bigland = (arable[s] >= MINARABLE)

        if (core && sole && lowind && bigland) {
            print s "\tRANCH"
            q++
        } else {
            print s "\tno\tcore=" core " sole=" sole " lowind=" lowind " arable=" arable[s]
        }
    }
    printf "qualified: %d\n", q > "/dev/stderr"
}
