# 1836 horse production and consumption

Static weekly estimate at full staffing and full cavalry strength, using the installed game history and current mod seed. These are goods units, not individual animals.

| Source | Horses per week |
| --- | ---: |
| Horse Ranch production (225 ranches, 857 levels) | 10284 |
| Public Works consumption | 400 |
| Extraction haulage consumption | 7059 |
| Crop farm draft consumption | 2257 |
| Cavalry consumption | 778 |
| Other known consumption | 0 |
| **Known consumption** | **10494** |
| **Ranch output minus known consumption** | **-210** |

Ranch output covers 98% of known demand. The world total is not a playable market balance: goods move within markets, and subjects may share markets with other countries.

## Largest country-level gaps

Country tags aggregate owner states; they do not represent market boundaries.

| Owner | Ranch output | Known demand | Difference |
| --- | ---: | ---: | ---: |
| BIC | 0 | 711 | -711 |
| CHI | 936 | 1593 | -657 |
| GBR | 228 | 617 | -389 |
| DEI | 0 | 230 | -230 |
| BEL | 0 | 121 | -121 |
| JAP | 96 | 205 | -109 |
| AWA | 0 | 86 | -86 |
| PAN | 0 | 76 | -76 |
| TUS | 0 | 66 | -66 |
| SAR | 0 | 59 | -59 |
| CLM | 0 | 57 | -57 |
| BAV | 48 | 97 | -49 |

## Largest country-level surpluses

| Owner | Ranch output | Known demand | Difference |
| --- | ---: | ---: | ---: |
| RUS | 1416 | 919 | +497 |
| MEX | 588 | 102 | +486 |
| HUN | 516 | 77 | +439 |
| USA | 1032 | 622 | +410 |
| PER | 432 | 106 | +326 |
| KOR | 252 | 43 | +209 |
| ARG | 156 | 25 | +131 |
| VNZ | 132 | 23 | +109 |
| BRZ | 384 | 284 | +100 |
| URU | 96 | 6 | +90 |
| MOR | 96 | 9 | +87 |
| PRU | 300 | 230 | +70 |

## Scope

The calculation multiplies seeded ranch levels by their activated PM output, and seeded building levels and cavalry counts by their horse inputs. It excludes output modifiers, subsistence pasture output, dynamically created Urban Center demand, staffing changes, and in-game market access. Therefore the signed difference is a baseline estimate, not an observed shortage or surplus. For the demand method and defaulted PMs, see [HORSE_CONSUMPTION_1836.md](HORSE_CONSUMPTION_1836.md).

Detailed results: [owner-state CSV](horse_balance_1836_by_owner_state.csv) and [country CSV](horse_balance_1836_by_country.csv).

Regenerate with `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Get-HorseBalance.ps1`.
