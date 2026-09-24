# 1836 horse consumption by state

The full [state table](horse_consumption_1836_by_state.csv) has one row for each
starting state with recorded horse demand. The [owner-state table](horse_consumption_1836.csv)
shows the same demand split by country where a state region is divided.

| Source | Horses per week |
| --- | ---: |
| Public Works | 400 |
| Mine, logging, plantation, and vineyard haulage | 7,059 |
| Crop farm draft animals | 2,257 |
| Cavalry remounts | 778 |
| **Total in seeded history** | **10,494** |

These are **modeled inputs at full staffing and full cavalry strength**, using
the installed Victoria 3 1.13.11 history and this mod's horse input definitions.
For each seeded building, the calculation multiplies its starting levels by
the horse input of each starting production method. For cavalry, it multiplies
starting unit counts by the mod's unit upkeep. Eight building levels omit the
relevant production method in history, so the calculation applies the first
method in their game production method group: 2 wheat farm levels, 4 maize farm
levels, and 2 vineyard levels.

The game creates Urban Centers dynamically, so their opening horse consumption
is **not** included. The starting Urban Center method consumes one horse per
level. Actual opening consumption can also differ with staffing, unit strength,
and game initialization. Subsistence pastures *produce* horses and therefore do
not enter this consumption table. This report is not a market balance or a
measurement from a running game.

Regenerate the CSV files after a game or mod data update:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Get-HorseConsumption.ps1
```
