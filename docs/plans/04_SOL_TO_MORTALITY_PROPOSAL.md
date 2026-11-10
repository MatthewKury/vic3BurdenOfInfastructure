# Burden of Infrastructure: Replacing SoL Penalties with Mortality and Pollution

Written 2026-11-01, revised the same day with your answers. **The mortality swap is applied, without pollution yet.** All new numbers are test values. Back to [plan 4](04_HOUSING.md).

**Superseded in part, 2026-11-10 (your choice, untested):** the mortality below has since been removed from Slums (pollution raised to +75 per staffed level instead), Tenement Blocks, Work Camps (migration attraction instead) and Work Towns (nothing instead), the Emergency Accommodation decree (radicals instead) and Statute Labour (fewer working adults instead). The event modifiers keep their mortality. See the [changelog](../../CHANGELOG.md).

Remove every SoL penalty the mod applies directly, and charge the same harm as higher mortality, plus a small amount of pollution where it fits. I recommend doing it, and the data supports your suspicion: seeded slums cost a state about 1 SoL, and Britain has far more slum states than anyone else. I expect it to lower British radicals but not to end the revolutions on its own, because most of the core British SoL gap has another cause that isn't known yet.

**Decided:**

- Slums generate +50 pollution per staffed level. Vanilla pollution also lowers SoL, by 3 points at full impact, so mortality still does most of the work.
- Only penalties the mod applies directly are in scope. SoL also falls when pops pay more for housing, horses or anything else, and this swap doesn't touch that.

- The mod's SoL gains stay: Turnpike Trusts gives shopkeepers working in Public Works +2, and Statute Labour gives manor-house aristocrats +2.

## First test results (2026-11-01)

Two games with the swap and no pollution, `20261101-185641_mod` and `20261101-191216_mod`. Both crashed, in August 1847 and February 1849, from what looks like a telemetry problem, so neither reached 1856. Single runs vary a lot, so read these as directions.

| | Before the swap | With the swap (two games) | Vanilla |
| --- | ---: | ---: | ---: |
| Big British civil war | 4 of 5 games, all by 1846 | None in either game before the crash | None in 10 by 1846 |
| SoL gap, slum states, 1841 | -1.47 | -0.53, -0.29 | 0 |
| Home Counties SoL, 1841 | 10.6 | 13.2, 13.1 | 14.3 |
| Lancashire SoL, 1841 | 8.5 | 8.4, 9.9 | 11.3 |
| British radicals, 1840 | 19% | 15%, 15% | About 9% |
| British radicals, 1844 | 27% | 20%, 27% | 11.5% |
| Slum-state population, 1841 | 69.0M | 68.6M, 68.2M | 70.7M |

- **SoL recovered,** by about the -1 in slum states, and by more in some British ones.
- **Radicals fell early but not lastingly.** By 1844–46 Britain is back near 27% in both games. It doesn't split in either, but that may not hold: radicals remain about twice vanilla.
- **Population stayed about level,** so the mortality conversion works as intended.
- **The revolt wave still comes.** The second game has a large US civil war from 1845 (19 against 7 states), and splits in Austria, Prussia and Hungary around 1846.

## Is the SoL penalty driving revolts?

**Partly, and it fits why Britain is the outlier.**

Slums apply a flat -1 SoL to the whole state. The 1836 seed puts them in only 21 states, which gives a natural comparison. These are the gaps against the mean of the 10 vanilla runs, weighted by population, for 1841:

| Run | SoL gap, slum states | SoL gap, other states | Difference |
| --- | ---: | ---: | ---: |
| `20261101-151839_mod` | -1.47 | -0.29 | -1.18 |
| `20261101-143514_mod` | -1.16 | -0.26 | -0.90 |
| `20261101-141945_mod` | -1.36 | -0.37 | -0.99 |

The difference is almost exactly the -1 penalty, so it's doing what it says.

**Britain has 6 of the 21 slum states,** holding about 12 million of its 26 million people. France and Prussia have one each, and Russia, Austria and the USA have two, which covers a far smaller share of their people. Britain's six are its industrial core. Inside Britain, the split is stark in 1844 (`20261101-151839_mod`):

| State | Slums seeded | SoL, vanilla | SoL, mod | Radicals, vanilla | Radicals, mod |
| --- | --- | ---: | ---: | ---: | ---: |
| Home Counties | Yes | 14.7 | 11.7 | 12% | 37% |
| Midlands | Yes | 11.2 | 8.3 | 14% | 41% |
| Lancashire | Yes | 11.8 | 9.1 | 13% | 43% |
| East Anglia | Yes | 11.5 | 9.1 | 14% | 43% |
| West Country | Yes | 10.2 | 7.6 | 19% | 37% |
| Yorkshire | Yes | 11.9 | 9.8 | 8% | 33% |
| Lowlands | No | 10.7 | 10.0 | 11% | 20% |
| Ulster | No | 10.2 | 9.7 | 8% | 16% |
| Wales | No | 10.3 | 9.9 | 11% | 18% |
| Highlands | No | 10.2 | 10.0 | 9% | 16% |

**But three things limit how much this can fix:**

- **The core British gap is 2–3 SoL, and the penalty is only 1.** About 1–2 points have some other cause, and the gap is already there in 1836 and then widens, because vanilla's British core gets richer and the mod's doesn't. Candidates include slower industrial growth and prices, but I can't separate them yet. Plan 4 has also recorded an unexplained SoL gap for a while.
- **The same SoL gap doesn't always mean the same radicals.** New York is 1.9 SoL below vanilla with radicals near 2%, and Bohemia is 1.7 below with radicals lower than vanilla. Literacy, laws and movements matter too.
- **Rough size of the effect.** Across 94 large Western states in three runs, each SoL point goes with about 4–5 points of radicals. That suggests radicals in Britain's core might fall by about 5 points, or up to about 10 at the steeper rate inside Britain, out of an excess near 27. It's a correlation, so treat it as a guess.

So this is worth doing, but it's one step. Britain's civil wars (4 of 5 long runs) may not stop.

## How the engine treats these

**Why mortality is safe.** Radicals come from SoL below a pop's expected SoL, from any SoL decrease, from starvation and discrimination, and from movements and events (`RADICALS_*`, `DEFAULT_SOL_CHANGE_IMPACT_FACTOR`, and the concept text). I found nothing that links mortality to radicals.

**What -1 SoL already costs in deaths.** Base mortality falls along a line from 0.45% a month at SoL 5 to 0.112% at SoL 15. So 1 SoL point is worth about **12% mortality** around SoL 9–10, 10% at SoL 7–8 and 16% at SoL 11–12. That makes the conversion simple: to keep population change about the same, replace each -1 SoL with about +12% mortality. Today's slum mortality of +0.1% per level is tiny next to what the SoL penalty already does.

**Why pollution isn't safe in bulk.** At full impact, vanilla pollution applies these to a state:

| Effect at 100% pollution impact | Value |
| --- | ---: |
| SoL | **-3** |
| Mortality | +50% |
| Migration attraction | -25% |
| Harvest disaster impact | +50% |

Pollution therefore costs 0.06 SoL for every 1% of mortality. Used alone to replace -1 SoL's mortality, it would still take about 0.7 SoL. The health part can be reduced by Health System laws, and it applies to the whole state region, spilling at least 25% into neighbours (`POLLUTION_SPREAD_TO_NEIGHBOR`). This reverses plan 4's rule against using pollution for slums.

**Pollution scale.** Impact is generated pollution ÷ (50 + 1.5 × √arable land) ÷ 255, reached over up to about 3 years. In a state with 60 arable land:

| Added pollution | Added impact | SoL | Mortality |
| ---: | ---: | ---: | ---: |
| 50 (1 slum level, decided) | 0.32% | -0.010 | +0.16% |
| 100 (a 2-level slum state) | 0.64% | -0.02 | +0.3% |
| 520 | 3.3% | -0.10 | +1.7% |

## Proposed changes

| Source | Who it hits | Today | Proposed |
| --- | --- | --- | --- |
| Slum Districts | Whole state | -1 SoL while any level exists; +0.1% mortality per staffed level | No SoL. +10% mortality while any level exists, +2% per staffed level, and +50 pollution per staffed level |
| Work Camp | That building's staff | -1 SoL, +5% mortality | No SoL. +15% mortality, and +2 pollution per staffed level |
| Work Town | That building's staff | -0.5 SoL, +2.5% mortality | No SoL. +7.5% mortality, exactly half a Work Camp's as the validator requires, and +1 pollution per staffed level |
| Emergency Accommodation decree | Whole state | -1 SoL | No SoL. +10% mortality, and +50 pollution |
| Statute Labour | Peasants, per works level | -0.25 SoL | No SoL. +3% peasant mortality per works level (`state_peasants_mortality_mult`). **Road Works tapered 2026-11-09:** +2% per state plus +1% per staffed level (review C8; see the [9 Nov balance log](../reports/phase6_9_Nov_2026/BALANCE_LOG.md)). **Moved to the law 2026-11-10, and no longer mortality:** −0.02 working-adult ratio for peasants and laborers, country-wide, and nothing on the works (per-pop-type keys unverified) |

- **Slums keep today's shape.** The flat part still lasts until the last level is demolished, and the per-level part still follows staffing. A state with 1 level gets +12%, and West Bengal's 4 levels +18%. Migration penalties stay.
- **Work Camp stays worse than Work Town,** and it's still limited to staff, without growing per level.
- **Statute Labour** has no pollution, since road duty doesn't pollute. The [road and rail proposal](01_ROAD_RAIL_SPLIT_PROPOSAL.md) should use the same conversion: Road and Rail +3% peasant mortality per level, and Harbour +1%.
- **The SoL gains stay.**
- **Tooltips and docs** need updating to say deaths, not misery. The agreed slum rule in plan 4 changes, and the [housing tiers proposal](04_HOUSING_TIERS_PROPOSAL.md) should drop its references to a shared slum SoL penalty.

**A gameplay change to expect.** A SoL penalty was visible in politics, while higher mortality works quietly through slower population growth. Slums will feel less threatening. That's what you're asking for, but if players stop caring about slums, the fix is to raise their mortality, not to bring SoL back.

## Risks

| Risk | Why it matters | What to do |
| --- | --- | --- |
| Revolutions continue | Most of the British gap has another cause | Treat this as step one, and compare civil wars and radicals by state. Then look at the remaining gap |
| Population falls short of today's | The 12% rate depends on SoL, and mortality may stack differently | Compare population in slum states against today's runs. It should be about level |
| Fewer radicals in Britain changes other things | Fewer civil wars means more stable, richer powers, and less drama than today | Compare GDP and country counts with vanilla |
| Mortality piles up in big slum states | Per-level mortality has no cap, as plan 4 already notes | Watch West Bengal and any state with many levels |
| Pollution spills across owners | It's shared across a state region and its neighbours | Keep values small, and log pollution |
| A worse Work Camp | +15% mortality against a modest wage saving might shift what the AI picks, or it might not care at all | Count tiers in a run. Plan 4 says the AI choosing low tiers on profit is fine |

Not tested: all of it. In particular, I haven't confirmed that these mortality modifiers leave population about unchanged, or that removing -1 SoL lowers radicals.

## Suggested order of work

1. **Add telemetry:** `State.GetStateRegion.GetPollutionImpact` and `State.GetPollutionGeneration`, per state and yearly only. Run one long test, because the last telemetry addition crashed the game.
2. **Apply the swap with no pollution** and run 5 × 20-year games, about 2 hours in total. Britain's civil wars in 4 of 5 long runs give a clear baseline, so this is the cheapest way to see whether SoL penalties matter. Check radicals and SoL by state, and population in slum states.
3. **Add pollution** and confirm it stays below about 0.05 SoL in slum states. At 50 per level that takes about 5 slum levels in a state with 60 arable land, or a much smaller state.
4. **Investigate the remaining British gap,** which is probably the bigger prize. Compare British wages, prices, industry and SoL by strata against vanilla.
5. **Then run the 10-game ensemble** against the vanilla baseline for anything beyond Britain.

Files to change: `common/production_methods/50_boi_housing.txt`, `common/production_methods/50_boi_infrastructure.txt`, `common/decrees/50_boi_housing.txt`, `tools/Test-Housing.ps1` (it checks the staffing and flat effects), localization, and `docs/plans/04_HOUSING.md`.
