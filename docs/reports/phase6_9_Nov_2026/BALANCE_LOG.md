# Balance log: review fixes and 40-year games (9 Nov 2026)

After the 8 November review was added to [plan 6](../../plans/06_FEATURE_COMPLETE_PLAN.md) (Part C), you asked for the following:
- carry on with the plan;
- run fewer than 8 check games to confirm assumptions;
- run up to four iterations of two 40-year games, fixing problems and balance between them while keeping the mod's core;
- compare subsistence buildings against vanilla in the reports.

**Settings for every game:**
- Each game is one ensemble member with `-RailSurvey`, as in the [8 Nov games](../feature_complete_8_Nov_2026/BALANCE_LOG.md). Britain, Prussia, the USA and Belgium are stand-in players for the Rail Network Survey, and Britain modernises its home region.
- Everyone else is plain AI.
- **Comparisons:**
  - `vanilla115_1836_1936_all`: 13 vanilla 1.15 games at 1846, 10 at 1856, and 5 that reach 1876;
  - `fc_game1` and `fc_game2`: BOI on 8 Nov, to 1856.

**Noise:** with two games against five, a world GDP difference under about 3% is noise. Population barely varies between games, so a gap of 1% or more there is real.

## Phase 6 fixes (before any game)

All in the [changelog](../../../CHANGELOG.md), under 2026-11-09.

| Item | Fix | How it was checked |
| --- | --- | --- |
| C1 | The works plan = `infrastructure_seed_baseline.tsv` + `infrastructure_seed_adjustments.tsv` (24 hand-made rows, +47 Road Works levels) | `Test-Seed.ps1`: the plan equals the sum, and the baseline matches vanilla. Regenerated, the seed has the same content plus Rostov's Harbour Works |
| C1, found on the way | Regeneration had failed since 1.15: the ranch list named Galich and Tartaria and lacked Kostroma and Oryol | It regenerates again |
| C1, found on the way | Rostov's vanilla port (3 infrastructure) had nothing to replace it | 140 Harbour Works (142 levels) |
| C2 | A manifest in `Test-Housing.ps1`, in place of the 22-file count | The full suite passes, including the checks the count used to block |
| C3 | Municipal Estates and the AI event share `boi_hev_socialist_government` | Static check in `Test-Housing.ps1` |
| C4 | The Great Fire: Slums and Rows burn; else the smallest wood-heated housing; industry takes −15% throughput for 3 years instead of burning; the permanent ban needs `urban_planning` | Check runs (below) |
| C5 | Pledges per state: the country on each marker, per-state targets and progress, lost states drop out | Check runs (below) |
| C9 | `required_input_goods = electricity` on Electrified Quays | Loads without error |
| C12 | Only 2 of the 18 blocks needed it: Rebecca Riots and the defaulters, now `position = 0` | Check runs (below) |
| D1 | "Ahead of the Traffic", as agreed | Check runs (below) |

`Validate-All.ps1`: PASS.

## Check runs (2 of the 8 allowed)

Both were run with a new `checks` telemetry module (`Test-Headless.ps1 -Checks`), which forces each mechanism once.

| Run | Length | Result | What it showed |
| --- | --- | --- | --- |
| `20261109-072458_mod` | to 1838.1 | FAIL, 5 BOI lines | The pledge's status line had no context: `JournalEntry.GetCountry…` logged about 800 errors in 10 months. This was an old bug, unseen because no pledge had fired before. Also one unused variable in the checks module. Everything else passed. |
| `20261109-072912_mod` | to 1837.8 | **PASS, 0 BOI errors** | After the status-line fix (`SCOPE.GetRootScope.GetCountry`). |

**What the two runs confirmed:**

- **C12:** an `ordered_scope_state` without `position` ran on all 29 French states and saved the last one, Guyana (23,545 people). With `position = 0` it saved Normandy (2.7 million).
- **D1:**
  - 8–10 states qualified in January 1837: 6–8 fit the town version, 5 the country version.
  - Forced for three countries in each run (British India, Prussia and France, then Japan, Prussia and France), it applied a modifier and set the cooldown every time. The AI chose mills, charter, hinterland and the government's works.
  - The yearly roll fired once by the end of 1836.
  - The legitimacy multiplier: Moldavia, under Right of Assembly (×2), went from 28 to 34.
- **C5:** a pledge in one British state with a target of 2 counted the 1 level of Regulated Terraces built there. It ignored the 3 levels built in another British state.
- **C4:** forced in West Bengal (9 Slum and Rows levels, 16 industry levels), the Great Fire left 0 low-tier levels, 16 industry levels and Scorched Works. In New York: 2 → 0 low-tier levels, 15 industry levels kept.

New engine findings went into the lessons file:
- the C12 behaviour;
- saved scopes not reaching `debug_log`;
- status-line context;
- the modifier multiplier;
- the missed 1.15 remap.

## Iteration 1: `p6_iter1`, two games to 1876

The code was as after the phase 6 fixes. Runs `20261109-082338_mod` and `20261109-102742_mod`, both PASS with 0 BOI errors.

### Launches

Getting two clean games took **six launches**. The ensemble driver replaces a failed run automatically.

| Run | Result |
| --- | --- |
| `20261109-073254_mod` | Crash at `...D8509`, 1839 (5 min) |
| `20261109-073806_mod` | Crash at `...D8509`, 1867 (45 min) |
| `20261109-082338_mod` | **PASS** (game 1) |
| `20261109-091508_mod` | Crash at `...D8509`, 1843 (11 min) |
| `20261109-092614_mod` | Reached 1876; FAIL on 1 BOI error line: the AI queued Rail Works in Carnatic over its cap (fixed below) |
| `20261109-102742_mod` | **PASS** (game 2) |

The crashes are the 1.15 crash already in the lessons file ("Unsolved"). Every one came while a telemetry line was being written, and a check run with the ensemble module off crashed at the same address too (below). With BOI's telemetry, the rate is far higher than in the vanilla baseline's observer games: about 1 crash per 30 game-years, against about 1 per 200.

### Headline against vanilla

World totals; vanilla is `vanilla115_1836_1936_all` (n = 8 at 1846, 5 at 1856, 2 to 6 at 1866–76, depending on the table).

| | 1846 | 1856 | 1866 | 1876 |
| --- | ---: | ---: | ---: | ---: |
| GDP | −7.0% | −12.2% | −14.8% | −18.4% |
| Population | −1.8% | −3.0% | −5.1% | −6.7% |
| Railway levels | −23% | −38% | −40% | −38% |
| Construction levels | −19% | −24% | −16% | −17% |
| Radicals | −21% | −13% | −30% | −10% |
| Unemployed | −15% | −23% | −27% | −28% |
| **Subsistence levels** | **−0.3%** | **−0.2%** | **−0.4%** | **−0.7%** |
| Farm levels (incl. subsistence) | −0.6% | −0.6% | −0.8% | −0.7% |
| Ranching levels | +22% | +25% | +25% | +20% |

**Subsistence buildings stay within 1% of vanilla throughout,** as in the 8 November games. Ranching is about +20%, which is the Horse Ranches.

**Per game, world GDP in 1876** was 819 M and 889 M, against 949–1,075 M in the six vanilla games that reached 1876. **Population** was 1,273 M and 1,283 M, against 1,351–1,384 M. Both games are outside the vanilla range, so the gap is real, not noise.

### Finding 1: broken pledges brought down Britain

- **Revolutions:** in both games Britain had a revolution or civil war, in 1847 and in 1850; game 1 had a second in 1860. British India broke up in 1853 in game 1. In 13 vanilla games and the two 8 Nov BOI games, Britain's tag never changed.
- **Britain's radicals** went from 5.7% to 16.6% between January and July 1840 in both games (vanilla 4.2–4.3%; 8 Nov games 5–8%).
- **The pledge:** that is when Britain's City Modernisation pledge, made in 1838 for 12 levels across its 10 home states, ran out with **0 levels built**. Per-state counting (C5) made the count honest: before it, housing built anywhere in Britain counted.
- **The penalty:** a broken pledge made 20% of the poor radical in *every* pledge state, all ten of them.
- **Elsewhere:** Hungary (5 states, 1848) and Spain (15 states, 1853) made City Modernisation pledges; both countries later split.
- **Britain and British India** account for 44% of the world GDP gap in 1876.
- **The AI builds no housing for its pledges**: most yearly pledge lines show 0 levels built; the best was Spain's 4 of 15.

### Finding 2: Statute Labour's peasant mortality grows without limit

- **By region:** the population gap is spread across peasant regions, China most of all: 37% of the gap, with Chinese regions 5–13% below vanilla.
- **Jiangxi** shrank from 28.2 M (1855) to 26.8 M (1875) with 5, then 10, Road Works under Statute Labour.
- **Mortality:** Statute Labour gave +3% peasant mortality per staffed level, so 10 levels gave +30%. This is review item C8.

Population growth from 1855 to 1875 by the state's Road Works levels in 1875 (states over 1 M people):

| Road Works levels | Game 1 | Game 2 |
| --- | ---: | ---: |
| 0 | +7.5% (125 states) | +8.2% (121) |
| 1–3 | +6.9% (54) | +5.9% (68) |
| 4–7 | +2.4% (18) | −0.4% (11) |
| 8+ | −3.7% (15) | +0.9% (8) |

### Finding 3: the AI queued Rail Works over the cap

- `boi_ai_rail_works_room` counts built levels only.
- The engine's cap also counts a level still in the queue, so the queue order failed with "Rail Works is at maximum capacity".
- It was rare (3 lines in one game), but any BOI error fails a run.

### Other observations, no change made

- **"Ahead of the Traffic" (D1):**
  - from 1845 on, 8–23 countries were in its cooldown at any time;
  - the number of qualifying states rose from 10 in 1836 to about 50–60 in 1875;
  - all six options were taken;
  - no errors.
- **The Great Fire:** 27 and 47 fires in 40 years (about 1 a year worldwide), with 2 states under Scorched Works at a time.
- **Railways run 38–40% below vanilla from 1856.** This was the case in the 8 Nov games too (−28% and −35% at 1856). I left it until the population and Britain fixes have been measured.
- **The road-law telemetry** logged the Dedicated Road Fund as Statute Labour. It is fixed for iteration 2; no country had adopted it by 1876 in either game.

### Fixes for iteration 2

| Problem | Fix | File |
| --- | --- | --- |
| Finding 2 (C8) | Statute Labour on Road Works: +2% peasant mortality per state plus +1% per staffed level, and +1% plus +0.5% per level farm and ranch throughput. At 1 level that's +3% mortality as before; at 10 levels +12% (was +30%); at 20 levels +22% (was +60%). Rail Works' Conscripted Navvies are unchanged, since their levels are capped. | `common/production_methods/50_boi_infrastructure.txt` |
| Finding 1 | The AI keeps its pledges: a monthly hidden event (`boi_ai_infrastructure.3`) queues 1 level of Regulated Terraces in the pledge state furthest short, never more in a state than its own target. | `events/boi_ai_infrastructure_events.txt`, `51_boi_ai_construction_triggers.txt` |
| Finding 1 | A broken pledge radicalises only the states that fell short, scaled by the share of the state's target left unbuilt. The culture penalty goes to the largest state that fell short. Legitimacy and the Trade Unions are unchanged. | `54_boi_displacement_effects.txt`, `54_boi_displacement_values.txt` |
| Finding 3 | `boi_ai_state_prefers_rail_works` also needs `can_queue_building_levels = 1` on an existing Rail Works building. | `51_boi_ai_construction_triggers.txt` |
| Telemetry | Road Fund logged as 3; the pledge line logs the levels queued; `sp_counts` logs the countries under a broken pledge. | `tools/headless-telemetry` |

### Check run 3 (3 of the 8 allowed)

`20261109-113228_mod`, with `-Checks`, to 1838.2. The run **crashed at `...D8509` at the end of 1837**, with the ensemble module off. The last line written was the yearly goods line for the USA. So the crash isn't specific to the ensemble snapshot.

- **The pledge builder:** the forced British pledge (target 2) ended by July 1837, five months after it started, and the state's markers were gone. A lapse needs the state to change hands, which didn't happen, so the pledge was kept. That means the builder's queued level was finished. The check's own pass line ran after the cleanup and so reported 0 (the check is fixed to log without `THIS.GetName`, which doesn't exist for a state in `debug_log`).
- **The Rail Works trigger** loaded and ran without errors (0 BOI lines). Iteration 2's pledge lines log the queued levels, as the in-game confirmation.

## Iteration 2: `p6_iter2`, three launches, all crashed

The code was iteration 1's plus the fixes above.

### Launches

All three games crashed at `...D8509`, each in the middle of a telemetry line. The ensemble driver stops after 3 failures in a row, so it stopped there.

| Run | Result |
| --- | --- |
| `20261109-113710_mod` | Crash in September 1869 (53 min). 1 BOI error line: Rail Works over the cap in Montenegro (finding 3) |
| `20261109-122955_mod` | Crash in October 1867 (46 min). The same BOI error |
| `20261109-131533_mod` | Crash in October 1861 (41 min) |

That is 3 crashes in 89 game-years, the same rate as before (about 1 per 30). At that rate a 40-year game finishes only about one time in four.

**Salvaged:** `Build-EnsembleDb.py --include-failed` keeps each crashed run up to its last whole snapshot. `Compare-Headline.py` now takes `--include-failed` as well. Two of the three runs reach 1866, so iteration 2 is compared at 1846, 1856 and 1866.

From iteration 3 on, each iteration is exactly two launches, with no relaunch after a crash, and crashed runs are salvaged. This keeps within the game budget.

### Headline against vanilla

With `--include-failed`, the vanilla reference also counts its crashed games up to their crash: n = 13 at 1846, 10 at 1856 and 7 at 1866. So iteration 1's figures below differ slightly from the table above.

| | 1846 iter 1 | 1846 iter 2 | 1856 iter 1 | 1856 iter 2 | 1866 iter 1 | 1866 iter 2 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GDP | −7.1% | −7.3% | −12.6% | −10.5% | −12.8% | **−10.7%** |
| Population | −1.8% | −1.8% | −3.2% | −2.5% | −4.8% | **−3.9%** |
| Standard of living | −4.3% | −1.8% | −1.8% | −2.0% | −0.7% | −3.8% |
| Railway levels | −26% | −26% | −37% | −33% | −43% | −39% |
| Construction levels | −20% | −13% | −26% | −24% | −14% | −22% |
| Radicals | −16% | −22% | −7% | −14% | −24% | −17% |
| **Subsistence levels** | −0.3% | **−0.3%** | −0.3% | **−0.2%** | −0.5% | **+0.1%** |
| Ranching levels | +21% | +23% | +24% | +26% | +26% | +26% |

**Subsistence buildings are still within 1% of vanilla.**

### Finding 1 is fixed: Britain held together

- **Corrected after iteration 4:** Britain did not fully hold together. In games 1 and 3 a revolutionary `GBR#2` existed from 1852 to 1853, so a revolt broke out and was put down. Only game 2 was clean. The original Britain kept its tag in all three, against two successful revolutions in iteration 1. See finding 8.
- Britain's radicals in January 1841 were 5.0–9.8% of its population, against 16.3–16.4% in iteration 1.
- At 1866 Britain's GDP is 20% below vanilla, against 34% in iteration 1. British India is no longer among the largest gaps.
- **The pledge builder works.** No country was under a broken pledge at any year end. The AI built toward each of its pledges:

| Pledge | Target | Built | Queued |
| --- | ---: | ---: | ---: |
| Britain, City Modernisation, 1838 | 12 | 7 | 9 |
| Britain, rail survey, 1840 | 7 | 3 | 5 |
| Belgium, rail survey, 1846 and 1848 | 2 | 0 | 1–2 |
| USA, City Modernisation, end of 1857 | 23 | 10 | 11 |
| USA, the same pledge a year later | 23 | 22 | 22 |
| Hungary, City Modernisation, 1866 | 7 | 1 | 4 |

### Finding 2 is fixed: Road Works no longer shrink a state

Population growth from 1846 to 1866, by the state's Road Works levels in 1866 (states over 1 M people). This uses 1846–1866 because the iteration 2 games stop before 1875; iteration 1 is recomputed over the same years.

| Road Works levels | Iter 1, game 1 | Iter 1, game 2 | Iter 2, game 1 | Iter 2, game 2 |
| --- | ---: | ---: | ---: | ---: |
| 0 | +10.7% (123) | +11.6% (125) | +2.1% (140) | +2.8% (129) |
| 1–3 | +5.5% (53) | +9.8% (64) | +16.4% (58) | +7.9% (58) |
| 4–7 | +5.4% (18) | +6.8% (12) | +14.9% (3) | +6.0% (9) |
| 8+ | +3.6% (8) | +32.5% (3) | +33.9% (3) | +9.8% (4) |

- With the taper, states with more Road Works no longer grow less.
- **Unexplained:** states with no Road Works grew only 2–3% in iteration 2, against 11% in iteration 1. Nothing BOI changed touches those states. Wars, and which countries own which states, differ from game to game. Watch for this in iteration 3.
- China's regions are still 2–8% below vanilla, but they are now 26% of the world population gap, down from 37%.

### Finding 3 came back: Rail Works over the cap, in a new way

- `has_building` is false while a state's *first* level of a building is still under construction. So the guard's "no Rail Works here yet" branch let the AI queue a second level in Montenegro (cap 1) a year after the first, while the first was still being built.
- Vanilla's own railway checks pair `has_building` with `any_scope_building = { … is_under_construction = yes }` (`11_private_infrastructure.txt`). The guard now does the same.

### Finding 4: the GDP gap is Britain and the railways

- **The ten major powers** (Britain, France, Prussia, Russia, the USA, Austria, China, Japan, Turkey, Spain) are only 2% below vanilla's GDP at 1866. Most of the world gap is in smaller countries and in states that change hands in different ways from game to game. Per head, the smaller countries are no poorer than in vanilla.
- **Among the major powers, heavy industry is 20% below vanilla at 1866 and railways 32% below.** Railways are the main buyers of steel and engines.
- **Britain** is 12% below vanilla in 1846 and 20% below in 1866:
  - its income is 15% below vanilla's in 1846, while its tax level is higher;
  - its government wages sit at the minimum (vanilla raises them);
  - it has 25–28% fewer construction sectors throughout, and in 1866 half vanilla's railways (40 against 83);
  - its home states' GDP is 20–45% below vanilla's, with no infrastructure shortage, but a standard of living about 1 point lower;
  - its works buy about 21,000 a week of goods against 250,000–360,000 of total spending, 6–8% of the budget;
  - its housing runs 25–30% short of demand, at an average price about a third above base. Worldwide, the share of people living where housing is at the price ceiling falls from 16% (1836) to 5% (1866).
- **Railways:** BOI railways give no infrastructure by design. That takes away vanilla's reason for building them during an infrastructure deficit, in both the AI's construction choices and auto-expansion. Vanilla's other route, auto-expansion when transportation is 50% dear, was kept unchanged. But world transportation sits at about +50% in both vanilla and BOI, right on that line.

### Fixes for iteration 3

| Problem | Fix | File |
| --- | --- | --- |
| Finding 3 | The Rail Works guard also requires no Rail Works under construction where none is built yet | `51_boi_ai_construction_triggers.txt` |
| Finding 4 | A railway auto-expands when transportation is 25% dear (vanilla 50%). Railways still give no infrastructure | `00_boi_railway_ai_override.txt` |
| Finding 4 | The railway AI's price factor rises from 0.8–1.2 (1 at normal prices) to 0.9–1.4 (1.15 at normal prices) | `50_boi_ai_values.txt` |
| Tools | `Compare-Headline.py --include-failed` | `tools/ensembles` |

Housing, the works' cost and Britain's budget are left alone: they are the mod's core burden. Railways are the one gap that comes from something BOI took away (the infrastructure motive) without putting back a replacement.

`Validate-All.ps1`: PASS.

## Iteration 3: `p6_iter3`, two launches

Iteration 2's code plus its fixes (railway auto-expansion at +25% transportation, the railway AI price factor 0.9–1.4, and the Rail Works first-level guard). Exactly two launches.

| Run | Result |
| --- | --- |
| `20261109-140852_mod` | Reached 1876 (56 min). FAIL on 1 BOI error line: Rail Works over the cap again, in Porto Rico and Rajputana |
| `20261109-150516_mod` | Crash at `...D8509` in 1864 (44 min). 3 BOI error lines: `owner` returned nothing in the generated rural building file (below) |

**Tooling:** the database builder dropped the last snapshot of every run that didn't pass. That threw away game 1's 1876 snapshot, although the game exited on its own. It now drops the last snapshot only after a crash or timeout.

### Headline against vanilla

n = 1 at 1866 and 1876 (game 2 crashed in 1864).

| | 1856 iter 2 | 1856 iter 3 | 1866 iter 2 | 1866 iter 3 | 1876 iter 1 | 1876 iter 3 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GDP | −10.5% | −10.1% | −10.7% | −7.4% | −16.6% | **−3.2%** |
| Population | −2.5% | −2.8% | −3.9% | −3.8% | −6.5% | −4.9% |
| Standard of living | −2.0% | −0.5% | −3.8% | −0.1% | −2.5% | −1.6% |
| Railway levels | −33% | **−22%** | −39% | **−23%** | −40% | **−19%** |
| Construction levels | −24% | −22% | −22% | −12% | −14% | **−1%** |
| **Subsistence levels** | −0.2% | **0.0%** | +0.1% | **−0.1%** | −0.9% | **−0.6%** |

- **World GDP in 1876 was 991 M,** inside the range of the six vanilla games that reached 1876 (949–1,075 M). Iteration 1's games were at 819 M and 889 M.
- **Heavy industry came back with the railways.** World trade in 1876 (sold per week):

| Good | Vanilla | Iteration 1 | Iteration 3 |
| --- | ---: | ---: | ---: |
| Transportation | 26,150 | 15,694 | 21,233 |
| Steel | 17,872 | 8,967 | 19,779 |
| Iron | 33,995 | 22,067 | 40,142 |
| Coal | 45,604 | 23,708 | 51,382 |
| Engines | 5,969 | 3,640 | 5,821 |

  Transportation's price stayed where it was (45.7, vanilla 45.0), so the extra railways met demand without making transport cheap. Steel and coal are a little cheaper than in vanilla.
- **Population is now the largest gap,** at −4.9% in 1876. Population barely varies between games, so this is real.

### Finding 5: the population gap is mod-wide, not Statute Labour

Population growth from 1846 to 1876 for each region in game 1, against the same region's mean in vanilla, by the region's Road Works levels (regions over 1 M people):

| Road Works levels | All regions: BOI | All regions: vanilla | China: BOI | China: vanilla |
| --- | ---: | ---: | ---: | ---: |
| 0 | +17.3% (112) | +20.7% | +5.3% (8) | +8.3% |
| 1–3 | +17.9% (59) | +20.0% | +9.0% (6) | +12.2% |
| 4–7 | +6.4% (20) | +11.7% | +3.1% (10) | +9.6% |
| 8+ | +13.7% (11) | +11.5% | +11.6% (8) | +9.7% |

- **Regions grow about 3 points less than in vanilla at every level of Road Works,** including regions with none, and those with 8 or more do slightly better than vanilla. So the taper (C8) has done its job, and what is left isn't the Road Works.
- **China is 39% of the 1876 gap.** It kept Statute Labour all game, and its regions are 5–12% below vanilla's at about the same standard of living. It has up to 15 Road Works per state and no railways at all (vanilla China builds 1–2.5 per state when short of infrastructure).
- **The candidates are BOI's deliberate mortality costs** (plan 4 swapped standard-of-living penalties for mortality):
  - Slums: +10% state mortality, plus 2% per level;
  - Work Camps: +15% mortality for the employed professions in a building;
  - Statute Labour: +2% peasant mortality, plus 1% per level;
  - event modifiers.

  In the tracked countries, Slums and Work Camps are modest (for example, Britain had 33 Work Camp levels of 265 rural levels in 1844, France 3 of 332). The housing shortage of the first decade is another candidate: in 1836, 16% of the world's people lived where housing was at its price ceiling.
- **Not changed.** These costs are the mod's design. Whether a −5% population is the right price for them is for you to decide, not a bug fix (see the end of this log).

### Finding 6: Britain was radicalised once more, cause unknown

- In game 1, Britain's radicals went from 9% to 26% of its population between January 1851 and July 1852, while Britain was at war and its loyalists fell to almost nothing. It then had a revolution or civil war in 1856 (`GBR#2`).
- **No pledge was broken** (none was under a broken pledge at any year end), and Britain's standard of living was flat at 10.6.
- Britain was running its fifth Rail Network Survey (begun January 1850), and in late 1852 it took a rail pledge for 11 levels in one state. The survey's clearance options radicalise the poor, but the telemetry doesn't log which options were taken, so this can't be pinned on BOI.
- In game 2 (to 1864), Britain held together. (This first said "and in all three iteration 2 games" too, which was wrong: see the correction under finding 1, and finding 8.)

### Finding 3 again: Rail Works over the cap (Porto Rico, Rajputana)

The first-level guard didn't close it. Script can't read the engine's cap, and the engine's own construction AI also builds Rail Works (they give infrastructure), so a level the engine queued is invisible to the script's count. Two more guards:
- `can_construct_building = building_boi_rail_works` (a state trigger vanilla uses in `india_values.txt`). Whether it respects the max level is unverified, but it is the engine's own check;
- when the event queues a level, it records the level count it expects (`boi_ai_rw_pending`, kept for 5 years). It won't queue again in that state until that count is built.

### Finding 7: an error from vanilla code in BOI's generated rural file

- `Event target link 'owner' returned an invalid object` at three lines of `00_boi_housing_rural_generated.txt`, once each in 1864. Those lines are vanilla's "British dictates" `ai_value` blocks, copied unchanged into BOI's housing shadows of the plantations. A state has no owner for a moment while it changes hands.
- Vanilla's own games log the same class of error from vanilla files (`metro_events.txt`, `command_values.txt`, `00_infamy_values.txt`); this is the first time it landed in a BOI file.
- **Fix:** `Build-Housing.ps1` now writes `owner ?= {` in those five limits. That is false without an owner, the same result as the failed link, but without the error. `Test-Housing.ps1` undoes the change before comparing the shadows with vanilla. Regenerated: only those five lines changed.

### Iteration 4

Since iteration 3's 1876 numbers rest on one game, iteration 4 repeats it with only the two error fixes above, and no new balance changes.

`Validate-All.ps1`: PASS.

## Iteration 4: `p6_iter4`, two launches

Iteration 3's code plus the Rail Works guards (`can_construct_building`, `boi_ai_rw_pending`) and `owner ?=` in the rural shadows. No balance changes.

| Run | Result |
| --- | --- |
| `20261109-155951_mod` | Reached 1876. **PASS, 0 BOI errors** |
| `20261109-165010_mod` | Reached 1876. **PASS, 0 BOI errors** |

**Both error fixes held:** no Rail Works over the cap and no `owner` errors, in 80 game-years. This is the first iteration where neither game crashed.

### Headline against vanilla

| | 1856 iter 3 | 1856 iter 4 | 1866 iter 3 | 1866 iter 4 | 1876 iter 1 | 1876 iter 3 (n=1) | 1876 iter 4 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| GDP | −10.1% | −8.7% | −7.4% | −12.6% | −16.6% | −3.2% | **−20.6%** |
| Population | −2.8% | −2.7% | −3.8% | −3.7% | −6.5% | −4.9% | −4.9% |
| Standard of living | −0.5% | −2.6% | −0.1% | −2.0% | −2.5% | −1.6% | −6.2% |
| Railway levels | −22% | −28% | −23% | −32% | −40% | −19% | −35% |
| Construction levels | −22% | −27% | −12% | −23% | −14% | −1% | −17% |
| **Subsistence levels** | 0.0% | **+0.1%** | −0.1% | **+0.2%** | −0.9% | −0.6% | **+0.9%** |
| Ranching levels | +23% | +26% | +30% | +28% | +25% | +36% | +27% |

- **Iteration 3's 1876 GDP was one good game.** Both iteration 4 games ended at 808–817 M, below all six vanilla games (949–1,075 M).
- **69% of the 1876 GDP gap is Britain and British India:**
  - **Britain** had a revolution in game 1 (`GBR#2` from October 1846, then a failed second revolt in 1849).
  - **British India broke apart in both games.** In game 1 it had a revolution in 1873 (`BIC#2`). In game 2 Bharat (`BHT`) broke away in 1864, and the Mughals, Carnatic and Awadh took most of the rest. At 1876 the British India tag holds 37 M people, against 179 M in vanilla.
  - India breaking up also happens in vanilla: Bharat appeared in 2 of the 7 vanilla games that reached 1861. Two BOI games can't show whether BOI makes it more likely.
- **Outside the 1836 British and Indian footprint** (all state regions those two owned at the start), at 1876:

| | GDP | Railways | Population |
| --- | ---: | ---: | ---: |
| Vanilla | 746 M | 425 | 1,114 M |
| Iteration 1 | 666 M (−11%) | 220 (−48%) | 1,031 M (−7%) |
| Iteration 3 (n=1) | 731 M (−2%) | 337 (−21%) | 1,055 M (−5%) |
| Iteration 4 | 664 M (−11%) | 302 (−29%) | 1,057 M (−5%) |

  The railway change raised railway building: it took the gap from −48% to −21% to −29%. But **GDP outside the footprint is no better than in iteration 1.** About half of that −11% is the −5% population; per head the gap is −6%.
- **Heavy industry is between iteration 1 and vanilla.** World trade in 1876 (sold per week):

| Good | Vanilla | Iteration 1 | Iteration 3 (n=1) | Iteration 4 |
| --- | ---: | ---: | ---: | ---: |
| Transportation | 26,150 | 15,694 | 21,233 | 16,873 |
| Steel | 17,872 | 8,967 | 19,779 | 12,249 |
| Iron | 33,995 | 22,067 | 40,142 | 23,305 |
| Coal | 45,604 | 23,708 | 51,382 | 36,425 |
| Engines | 5,969 | 3,640 | 5,821 | 3,450 |

- **Population −4.9% at 1876 again,** the same as iteration 3, so finding 5 stands.
- **Subsistence buildings stay within 1% of vanilla at every date, in every iteration** (+0.9% at 1876 here). Ranching runs 25–36% above vanilla because of the Horse Ranches; that is BOI's own building, by design.

### Finding 8: Britain is radicalised by the housing burden from the first months

Britain's tag changed in **6 of the 9 phase 6 games**:
- successful revolutions in iteration 1 (both games), iteration 3 (game 1) and iteration 4 (game 1);
- revolts that were put down, 1852–53, in iteration 2 (games 1 and 3).

In vanilla 1.15 it never changed, in 13 games. This is the most important balance problem the iterations found.

**What the data show:**
- **The gap opens within six months, before any pledge, war or clearance.** In July 1836, Britain's standard of living is 9.4–9.5 in every BOI game, against 10.2 in vanilla. Its radicals are 1.5–2.1% of its people against 1.0%, and its loyalists 0.5–0.6% against 1.1%. By 1846 its radicals are 7.2–8.2% against 4.6%, and its loyalists 1.6–1.7% against 4.4%. Other large countries lose 0.2–0.7 points of standard of living without a rise in radicals.
- **It is England, and above all England's rich.** In July 1836:
  - Home Counties falls from 12.9 to 10.9;
  - the rich fall from 53.8 to 48.4 in Home Counties, 39.5 to 33.0 in the Midlands, and 42.7 to 32.9 in East Anglia;
  - the three southern Irish states (Munster, Leinster, Connaught) barely move.
- **The mechanism is the housing need,** which `Build-Housing.ps1` adds on top of each vanilla wealth basket (for example, 729 luxury housing on top of 1,124 services at wealth 40). Money spent on housing isn't spent on services: Britain's services demand is 26% below vanilla in 1836, and its price 11.8 against 19.0. That takes urban-centre profits and shop wages with it. Britain is the most urban country, so it pays the most.
- **It isn't new in phase 6.** Every BOI ensemble since the 1.15 patch shows it, including `boi115_pass1–4` (6 November). Those games had no stand-in fixtures and no City Modernisation, and still had radicals of 5.5–14.6% at 1846 and a standard of living of 9.9–10.2.

**The test fixture makes it worse:**
- **Corrected after iteration 4:** in this log's Settings, "Britain modernises its home region" means `-RailSurvey`'s fixture (`boitm_rs.30`). It enacts Minimum Residential Standards for Britain and starts City Modernisation on 1 January 1837 in every game. The AI never took that decision.
- In iteration 4 the fixture cleared all 19 levels of Slums and Workers' Rows in 10 English states by 1841. Britain's housing sales fell from 264 to 201 while demand rose from 311 to 396, and by 1841 42% of Britain's people lived where housing was at its price ceiling (3% in 1836).
- The same fixture also keeps Britain in a Rail Network Survey of 13 home states from March 1836 onward.

So in these games Britain plays as a player who modernises at once, on top of the base burden.

**Before 1851** a British revolution came in 3 of the 9 phase 6 games and in none of the 9 earlier BOI games that ran that far (`rs_pass1–4` to 1851, `fc_game1–2` to 1856). Those earlier games had the same fixtures and similar radicals, though. With so few games, the difference can't be pinned on any one phase 6 change.

**Tried and reverted:** I gated the AI's City Modernisation on Modern Sewerage and on housing being under 50% above base price. I took it back on finding the fixture: the AI was not taking the decision, so the gate changed nothing these games measure, and nothing showed that it was needed. One check game with it was started and stopped after a few minutes (check run 4).

**Not changed:** the housing burden is the mod's core. How much of it Britain should bear is your decision (see the end of this log).

## Closing summary

### What the four iterations changed

| Iteration | Change | Effect |
| --- | --- | --- |
| 2 | Statute Labour mortality taper (C8) | Regions with more Road Works no longer grow less |
| 2 | AI pledge builder; broken-pledge radicals scaled by shortfall | No pledge broke in iterations 2–4 |
| 2–4 | Rail Works guards (under construction, `can_construct_building`, pending order) | 0 over-cap errors in iteration 4 |
| 3 | Railway auto-expansion at +25% transportation; AI price factor 0.9–1.4 | Railways outside Britain and India: −48% → −29% of vanilla at 1876 |
| 3 | `owner ?=` in the generated rural shadows | 0 errors in iteration 4 |
| Tools | `--include-failed` salvage; the last snapshot is kept when a game exits on its own; exactly 2 launches per iteration | Crashed games still count |

### Where BOI stands against vanilla at 1876 (iteration 4)

- **World GDP −21%:** about two thirds of it is Britain's revolution and India's break-up; the rest is −11% outside the British and Indian footprint, half of which is population.
- **Population −5%:** mod-wide (finding 5).
- **Railways −35% overall, −29% outside the footprint;** heavy industry 20–40% below vanilla.
- **Subsistence buildings within 1% of vanilla throughout.**
- **0 BOI errors** in both games.

### Decisions for you

1. **Britain's housing burden (finding 8).** Options:
   - **Accept it.** The most urban country pays the most, as designed.
   - **Cushion the start.** For example, phase the rich strata's luxury housing in over the first decade, or seed more British housing so the opening price is lower.
   - **Change the test.** Move the City Modernisation fixture to the 1850s, or drop it, so the ensembles measure AI play. A player who modernises in 1837 would still face this.
2. **Population (finding 5).** Slums (+10% plus 2% a level), Work Camps (+15%) and Statute Labour cost about 5% of world population by 1876. If that is too much, halving the Slums' flat +10% is the first lever I'd try.
3. **The crash rate.** The `...D8509` telemetry crash hit 4 of the 9 phase 6 games (none in iteration 4). Long ensembles still need `-LongRun` and salvage.

### Budget used

- **Check games:** 4 of fewer than 8. The 4th was stopped within minutes; see finding 8.
- **Iterations:** 4 of 4.
- **40-year games:** 9 counted (2 + 3 + 2 + 2). Iteration 1's driver also relaunched 4 crashed games before I switched to exactly 2 launches per iteration.
