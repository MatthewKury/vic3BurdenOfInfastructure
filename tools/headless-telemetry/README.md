# Headless telemetry

Test-only script modules that `tools/Test-Headless.ps1` copies into a throwaway
mod, `BOI Headless Telemetry`, inside each run folder. They never ship.

| Module | Loaded when | Logs (`BOITM|<group>|…`) |
|---|---|---|
| `core/` | always, including `-Control` | `country` (GDP, SoL, population, states), `infrastructure` (total, usage, deficit states), `goods` for transportation, merchant marine, grain and tools |
| `boi/` | a loaded mod defines `horses` | `boi` (ranch, Public Works and Harbour Works levels; states where horses are ≥50% pricier or ≥25% cheaper), `budget` (gold reserves), `debt` (scaled debt, states with Public Works) and `goods` for horses. Also one `BOIDIAG|<date>|<tag>|<state>|…` line per state that has Public Works or Harbour Works, or is under 5 spare infrastructure (levels, queued, occupancy band, spare, AI score). Read those with `tools\Get-BoiDiagnostics.ps1 -Run <run>` |
| `housing/` | a loaded mod defines `boi_housing` | `housing` (slum, tenement, apartment, luxury, suburb and shelter levels), `housing_prices` (state price bands), and `goods` for both housing goods |

Each major power (`country_rank >= rank_value:major_power`) logs one line per
group on its `on_yearly_pulse_country`. The pulse is staggered per country.
Values are script values printed with `[THIS.ScriptValue('…')|2]`, which come
out as raw numbers. Keep one metric group per `debug_log`, because a data
function that fails blanks its whole line. The harness fails a run that has
blank values or errors mentioning `boitm`.

To add a metric:
1. Add a script value to the module's `common/script_values/` file.
2. Add `key=[THIS.ScriptValue('…')|2]` to a line in its `events/` file.
3. Add the key to `-Metrics` in `tools/Get-HeadlessReport.ps1` if it should show
   in the report.

When the housing prototype merges into BOI, nothing here needs to change. The
module is selected by the `boi_housing` good wherever it is defined.

Report: `tools\Get-HeadlessReport.ps1 -Run <mod run> -Compare <control run>`.
