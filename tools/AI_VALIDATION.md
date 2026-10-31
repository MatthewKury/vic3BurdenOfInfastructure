# Infrastructure AI priorities

Implemented 2026-09-23. All custom priority values are in
`common/script_values/50_boi_ai_values.txt`, evaluated in state scope.

Public Works retains a base weight of 3000; Harbour Works retains 1500.
Both multiply this by the following factor using infrastructure minus usage:

| Spare infrastructure | Multiplier |
| --- | ---: |
| 30 or more | 0.25 |
| 15 to less than 30 | 0.75 |
| 5 to less than 15 | 1.5 |
| 0 to less than 5 | 2 |
| -20 to less than 0 | 4 |
| Less than -20 | 6 |

Consumer price factors are 0.8 at least 50% above base price, 0.9 at least 25%
above, 1.1 at least 25% below, and 1.2 at least 50% below. Between those bands
the factor is 1. Public Works uses the state's horse price unless an existing
Public Works uses Rail Network, Motor Roads or Modern Highways, in which case
it uses transportation. First construction defaults to the horse signal rather
than predicting which production method the engine will choose. Harbour Works
always uses merchant marine. Secondary inputs are not included in this heuristic.

Price factors remain small: Public Works at -1 spare infrastructure scores
9600 to 14400, versus 4800 to 7200 at zero spare. The deficit spike therefore
survives even the worst input price. The retained 2:1 base-weight ratio means
price alone cannot make Harbour Works outrank Public Works on these weights;
other engine construction scoring and eligibility still affect the final choice.

Railways apply the opposite price factors to their 2000 base weight, favoring
expensive transportation. Journal bonuses are added afterwards and preserved.
The railway building shadow removes only the infrastructure-deficit branch of
auto-expansion, retaining the vanilla transportation price threshold (>50%),
80% occupancy, reserves-or-subsidy check and construction-in-progress guard.
This rule applies whenever railroad auto-expansion is enabled, including for
players. Public Works and Harbour Works now auto-expand when spare
infrastructure is below 5, the state owner is not in default, the existing
building is at least 90% staffed, and no instance of that same building is
already under construction in the state. Their toggles remain opt-in. The railway shadow copies only `building_railway`, not the rest
of vanilla's `11_private_infrastructure.txt`; recheck this full-key override
after patches.

## Validation

Static checks cover threshold boundaries, price bounds, referenced production
methods, balanced braces, UTF-8 BOMs and preservation of unrelated railway data.
These do not establish engine acceptance or AI campaign behavior.

In-game checks still required:

1. Launch with this mod and check error.log for invalid scopes, script values,
   goods-price triggers or building definitions. Verify the railway shadow wins
   loading; expected duplicate-key messages are not proof of correct behavior.
2. Observe AI states with ample spare capacity, near-zero capacity and deficits.
   Track construction decisions, occupancy, budgets and market access over time.
3. Compare expensive and cheap horse, transportation and merchant-marine states.
   Verify early Public Works uses horses, later methods use transportation, and
   first Public Works construction remains possible.
4. Enable railroad auto-expansion in an infrastructure-deficit state with cheap
   transportation: the deficit alone must not expand railroads. Then check a
   state above the transportation threshold with all staffing/funding guards met.
5. Watch newly colonized states and PM upgrades for shortages. These priorities
   do not supply missing inputs; public auto-expansion requires 90% staffing and
   pauses only in default, not at a broader budget-health threshold.

## Scripted construction fallback (2026-10-30)

Headless observer runs (1836 to 1846, BOI plus the housing prototype, per-state
`BOIDIAG` telemetry, read with `tools/Get-BoiDiagnostics.ps1`) showed that the
priorities above do not move the engine:

- **No construction.** Home Counties and the Midlands sat at −31 spare with
  Public Works scored 14,400–16,200. In ten years the AI queued nothing there.
  The engine builds government buildings through its money-spending projects,
  and none of them claims these buildings.
- **Budget downsizing that ignores need.** GBR demolished 17 of its 20 seeded
  Public Works levels in the first six months, and Yorkshire went from 2 to 0
  at −32. Spain dropped all 7 Harbour Works in one year, and France cut 9
  levels in 1841–42.

The fix has two parts:

1. `downsizeable = no` on Public Works and Harbour Works. This also stops the
   player from downsizing them.
2. `events/boi_ai_infrastructure_events.txt`, a hidden monthly event for AI
   countries (`is_player = no`) that are not in default and have scaled debt
   under 0.75. It runs `start_building_construction` in the incorporated state
   with the largest shortfall (usage minus infrastructure, > 0), using the
   normal construction queue. It chooses Harbour Works where the state is
   coastal, horses are ≥25% above base price and merchant marine is not.
   Otherwise it chooses Public Works. Each state then gets a 365-day cooldown
   variable, because `is_under_construction` misses a level added to an
   existing building. The first version re-queued Lancashire monthly: 4 levels
   for a 20-point gap. At most 1 + (incorporated states / 10) states, capped at
   4, can be queued per 180 days. Trigger:
   `common/scripted_triggers/51_boi_ai_construction_triggers.txt`. Values:
   `common/script_values/51_boi_ai_construction_values.txt`.

Deficit states across 12 major powers at the end of 1845:

| Run | Deficit states |
| --- | ---: |
| Baseline | 26 |
| Fallback, no cooldown | 3 |
| Fallback with cooldown | 1 |

Debt stayed low (worst scaled debt 0.47, BRZ, during a secession). Single runs
diverge historically, so treat these as directions.

Open:
- With downsizing disabled, seeded levels stay where they were placed. GBR's
  home states end 1836 at +36 to +81 spare, and later tech raises that further.
  Consider re-seeding against measured 1836 need. The other option is a
  scripted AI downsize when spare is very high, but no effect is known that
  removes a single level.
- The 50- and 100-year behaviour, and PM upgrades under the fallback, are still
  untested.
