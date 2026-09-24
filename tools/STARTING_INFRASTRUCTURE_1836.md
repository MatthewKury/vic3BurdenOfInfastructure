# 1836 infrastructure replacement audit

`infrastructure_seed_plan.tsv` replaces only the infrastructure removed from
vanilla Ports and Railways. It covers 1,147 starting state-owner records across
675 state regions in the installed game history.

At the base production methods, Public Works provides 15 infrastructure per
level and Harbour Works provides 10. The planner selects the mix with the least
capacity above the removed vanilla output, then the fewest levels. Harbour Works
is considered only where the mod's map region declares a port hub.

| Source | Levels | Infrastructure |
| --- | ---: | ---: |
| Vanilla Ports and Railways removed by the mod | 357 | 1,107 |
| Planned Public Works | 40 | 600 |
| Planned Harbour Works | 141 | 1,410 |
| **Planned replacement** | **181** | **2,010** |

The 903-infrastructure rounding surplus comes from Port entries whose active
vanilla method provides zero infrastructure and from the inability to seed a
Harbour Works in map regions without a declared port hub. The plan contains 20
Public Works buildings and 139 Harbour Works buildings across 155 state-owner
records. All other states begin without a public infrastructure building and
rely on their unchanged vanilla sources until a deficit calls for construction.

Run `Get-StartingInfrastructure.ps1` after changing game data or the mod. It
regenerates both the CSV audit and the seed plan; then run
`Regenerate-WorldSeed.ps1` to regenerate the history file.
