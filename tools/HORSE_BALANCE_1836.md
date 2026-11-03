# 1836 horse production and consumption

Static weekly estimate at full staffing and full cavalry strength, using the installed game history and current mod seed. These are goods units, not individual animals.

| Source | Horses per week |
| --- | ---: |
| Horse Ranch production (216 ranches, 492 levels) | 5904 |
| Public Works consumption | 400 |
| Extraction haulage consumption | 7059 |
| Crop farm draft consumption | 2257 |
| Cavalry consumption | 778 |
| Other known consumption | 0 |
| **Known consumption** | **10494** |
| **Ranch output minus known consumption** | **-4590** |

Ranch output covers 56.3% of known demand. The world total is not a playable market balance: goods move within markets, and subjects may share markets with other countries.

## Largest country-level gaps

Country tags aggregate owner states; they do not represent market boundaries.

| Owner | Ranch output | Known demand | Difference |
| --- | ---: | ---: | ---: |
| CHI | 540 | 1593 | -1053 |
| BIC | 0 | 711 | -711 |
| GBR | 168 | 617 | -449 |
| FRA | 408 | 792 | -384 |
| DEI | 0 | 230 | -230 |
| JAP | 48 | 205 | -157 |
| AUS | 96 | 238 | -142 |
| BRZ | 156 | 284 | -128 |
| EGY | 48 | 173 | -125 |
| BEL | 0 | 121 | -121 |
| TUR | 240 | 341 | -101 |
| AWA | 0 | 86 | -86 |

## Largest country-level surpluses

| Owner | Ranch output | Known demand | Difference |
| --- | ---: | ---: | ---: |
| HUN | 408 | 77 | +331 |
| MEX | 348 | 102 | +246 |
| PER | 264 | 106 | +158 |
| ARG | 132 | 25 | +107 |
| URU | 84 | 6 | +78 |
| MOR | 72 | 9 | +63 |
| BOR | 60 | 4 | +56 |
| PNI | 60 | 9 | +51 |
| KOR | 84 | 43 | +41 |
| KOK | 48 | 8 | +40 |
| BUK | 48 | 8 | +40 |
| VNZ | 60 | 23 | +37 |

## Scope

The calculation multiplies seeded ranch levels by their activated PM output, and seeded building levels and cavalry counts by their horse inputs. It excludes output modifiers, subsistence pasture output, dynamically created Urban Center demand, staffing changes, and in-game market access. Therefore the signed difference is a baseline estimate, not an observed shortage or surplus. For the demand method and defaulted PMs, see [HORSE_CONSUMPTION_1836.md](HORSE_CONSUMPTION_1836.md).

Detailed results: [owner-state CSV](horse_balance_1836_by_owner_state.csv) and [country CSV](horse_balance_1836_by_country.csv).

Regenerate with `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Get-HorseBalance.ps1`.
