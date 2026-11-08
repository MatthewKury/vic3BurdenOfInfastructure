# Burden of Infrastructure: Rail Network Survey Proposal

Written 2026-11-07 from your idea and your answers to 16 questions, then prototyped the same day (see "Prototype" at the end). All numbers are test values. Back to [plan 1](01_CORE_INFRASTRUCTURE_AND_HORSES.md); builds on the [road and rail split](01_ROAD_RAIL_SPLIT_PROPOSAL.md).

Rail Works become three times as strong as now, but each state may hold only a few levels. To raise the limit, a country runs a **Rail Network Survey**: a decision that opens a journal entry for one strategic region. While it runs, the country pays extra expenses, and every 25% of progress an event asks for a choice. At the end, every state in the survey gains 1 to 5 extra levels of Rail Works, depending on a quality bar the choices have moved.

## Decided

| # | Question | Your answer |
| --- | --- | --- |
| 1 | Rail versus road | Raise Rail Works only, starting at 3× the infrastructure. Road Works unchanged. **2026-11-08: cut to 2.5×.** |
| 2 | Starting cap | 2 levels, 4 in large states, 6 in very large ones. **2026-11-08: 1, 2 and 4.** |
| 3 | AI | A hidden event slowly raises AI caps. The AI does not run surveys. |
| 4 | Concurrency | One survey at a time, no cooldown, one strategic region per survey. |
| 5 | Picking states | Pick a strategic region from an event. Your states in it join. |
| 6 | Goal size | Set by urban centre levels, scaled against expected endgame levels. |
| 7 | Progress rate | Flat monthly rate, plus a bonus from surplus bureaucracy. |
| 8 | Cost | A per-state amount plus a share of GDP, paid as monthly expenses. |
| 9 | Police | Boosts the quality gained from "force people to leave" options, and slightly reduces their radicals and turmoil. |
| 10 | Militarized police downside | An event that can fire, not a constant penalty. |
| 11 | Event timing | Checked at the start of each month: one new event each time progress crosses 25%, 50% and 75%. |
| 12 | Standard of living | Not used for now. |
| 13 | Interest groups | IG approval may be affected, even though it is country-wide. |
| 14 | Failure | A survey never fails. The worst result is +1 level. |
| 15 | Result | +1 to +5 levels per state, by quality. |
| 16 | Repeat surveys | Allowed. **2026-11-08: each earlier survey adds 20% to a state's share, not 50%.** |

## 1. Rail Works at three times the infrastructure

Only the infrastructure output changes. Inputs and staff stay as they are, so each level costs the same as today and gives three times as much. That efficiency is the reward for the cap.

| Production method | Now | Proposed | Transportation per level | Goods per point, proposed |
| --- | --- | --- | --- | --- |
| Permanent Way | 13 | 39 | 240 | £6.2 |
| Steel Track | 20 | 60 | 300 | £5.0 |
| Electric Signalling | 27 | 81 | 360 | £4.4 |
| National Rail Grid | 33 | 99 | 450 | £4.5 |

Prices are at transportation £30. For comparison, Cart Roads is nominally about £20 of goods per point. One capped state at 2 levels of Permanent Way gives 78 points, about the same as 8 levels of Cart Roads.

**Check this with you:** "just upscale rail" could also mean scaling inputs and staff up by 3×, so that one level does the work of three without being cheaper per point. I've assumed the cheaper version, since otherwise the cap only limits size and never pushes anyone to survey.

## 2. The cap

Rail Works gets `has_max_level = yes`, the same mechanism vanilla uses to cap barracks and conscription centres. The engine then reads the cap from a modifier, `state_building_boi_rail_works_max_level_add`, which BOI declares in `common/modifier_type_definitions/` as vanilla does for barracks.

**Starting cap, by size.** Size is the state region's province count, which script can read (`num_provinces`, used in vanilla's monthly on_actions). The thresholds come from the real distribution in BOI's own `map_data/state_regions/` files, worked out by a small tool at build time. As a starting point:

| Size band | Share of state regions | Cap |
| --- | --- | --- |
| Normal | about 75% | 2 |
| Large | about the next 20% | 4 |
| Very large | the largest 5% | 6 |

**How the cap is held:**

- The size cap is a static state modifier (`boi_rail_cap_normal`, `_large` or `_very_large`). A yearly maintenance pass re-applies it to any state missing it, because states created by splits, releases or civil wars start with no modifiers.
- Survey gains are a state variable, `boi_rail_cap_surveyed`, applied as one modifier, `boi_rail_cap_survey`, with `multiplier = var:boi_rail_cap_surveyed`. It is removed and re-added whenever it changes, per lessons §18.
- Survey gains stay with the land: if the state changes owner, the new owner keeps them.

**Risk:** if a state is split and remade, a state variable may not survive. If state-region scopes can hold variables, the gains go there instead. Otherwise we accept the loss in that rare case. A test checks this first (step 1 below).

**AI construction:** the hidden monthly AI event that builds Rail Works must stop at the cap and fall back to Road Works. It can't ask the engine for the cap, so a script value `boi_rail_cap` repeats the sum (size cap plus survey gains) and the event compares the current level with it.

## 3. Starting a survey

**Decision: Commission a Rail Network Survey.**

- Shown once `railways` is researched.
- Possible while no survey is running and at least one strategic region has an eligible state.
- No cooldown.

**Choosing the region.** The decision opens a two-step event, because the game has no way for a decision to target states.

1. **Choose a continent:** one option per vanilla continent file (Europe, Africa, East Asia, West and South Asia, North America, South America). Each option shows only if you have an eligible state there.
2. **Choose a region:** one option per land strategic region on that continent (36 in total, at most 7 per continent). Each option shows only if you have an eligible state in that region. Every option has a "back" choice.

**Eligible state:** owned by you, incorporated, and not already in a survey. A railway is not required, since a survey can come before the line. **Check this with you:** should unincorporated states be allowed too?

Each state that joins gets a `boi_in_rail_survey` variable. The journal entry reads that set for everything below.

## 4. The goal

**Goal = the sum, over the surveyed states, of the state's base amount plus its urban amount.**

- Base amount: **6** per state.
- Urban amount: **6 × (urban centre levels ÷ R)**, capped at 3R, so at most 18.
- **R** is a reference: the urban centre level of a typical developed state at the end of a century game. It is measured from a 1936 save, not guessed. World urban centre levels go from 0.8k in 1836 to 18.2k by 1936 in the vanilla 1.15 baseline (`docs/reports/vanilla115_baseline_5_Nov_2026/SUMMARY.md`), but that report gives world totals, not states. My working guess is the 90th-percentile state by urban centre level in 1936.

| Example | Goal | Months at the base rate |
| --- | --- | --- |
| 4 rural states | 24 | 24 |
| 5 states, 2 of them at R | 42 | 42 |
| 3 states, all at 3R (a great city's region) | 72 | 72 |

**Repeat surveys:** each earlier survey of a state adds 50% to that state's share. The second survey costs 1.5× its share, and the third 2×. *Changed 2026-11-08 to 20%: 1.2×, then 1.4×. At 50%, a fourth survey of the same states took 63–75 months.*

**Possible problem:** large regions with many states, such as European Russia, give long goals even when they're rural. If that feels wrong in play, the base amount could shrink per extra state. I've left it linear for now.

## 5. Progress and cost

**Progress per month: 1, plus a bureaucracy bonus.** Each 10% of surplus bureaucracy (surplus divided by usage) adds 0.05, up to +0.5 at 100% surplus. The bureaucracy value is read in a script value; the exact key for surplus is checked in step 1.

**Expenses.** One modifier, `boi_rail_survey_expenses` (`country_expenses_add = 1`), with a multiplier set when the survey starts and refreshed at every 25% step:

- £100 per week for each surveyed state, plus
- GDP ÷ 50,000 per week. For Britain in 1836, that's roughly £1,400 a week.

The target is about 1–2% of a mid-sized country's spending. It's checked against telemetry in step 6.

## 6. The quality bar

- Runs 0 to 100 and starts at 50. It shows on the journal entry next to the progress bar.
- Events move it. Police strengthen the "force people to leave" options (section 8).
- At the end, each surveyed state gains:

| Quality | Rail Works levels gained per state |
| --- | --- |
| 0–19 | +1 |
| 20–39 | +2 |
| 40–59 | +3 |
| 60–79 | +4 |
| 80–100 | +5 |

The survey cannot fail, so the minimum is always +1. There's no cancel button, since you said there's no failure. **Check this with you:** should there be a way to abandon a survey, for example after losing the region in a war?

**War and lost states:** a state that leaves your ownership leaves the survey and gets nothing. Its share stays in the goal, so losing land mid-survey costs you. If every surveyed state is lost, the survey ends at once with no result, which is the only way it ends without gains.

## 7. Events

**Timing:** on the first monthly pulse after progress crosses 25%, 50% and 75%, the journal entry fires one event, picked at random from that stage's pool. That makes three choices per survey. The completion event fires at 100%.

**Scope:** each event picks one surveyed state at random as its subject (`scope:survey_state`). Radicals and progress effects land there or across all surveyed states, never elsewhere. IG approval is the one country-wide effect, as agreed.

**Effect vocabulary:**

| Effect | How it's done |
| --- | --- |
| Radicals | `add_radicals_in_state` on the subject state, or on each surveyed state |
| Turmoil | Vic3 turmoil comes from radicals, so "turmoil" is extra radicals. Whether a direct turmoil effect exists is checked in step 1. |
| Money | `add_treasury`, scaled to GDP as in Boom & Bust |
| Progress set back | Takes 5–15% of the goal off the bar |
| Progress boost | Adds 5–10% of the goal |
| Quality | ±5 to ±20 |
| IG approval | A temporary approval modifier on landowners, industrialists, the rural folk and others |

**Draft event pool (about 12).** Each has 2–3 options, mostly trade-offs, with about one in four options a clear boon:

| Stage | Event | Typical options |
| --- | --- | --- |
| 25%, routes | *A Disputed Valley* | Pay for the long route (money, +quality) / take the cheap gradient (−quality) |
| 25% | *Surveyors Lost in the Hills* | Send a relief party (money) / press on (progress set back) |
| 25% | *A Gentleman Engineer Volunteers* (boon) | Accept (+quality, small money gain) |
| 25% | *Local Maps Prove Wrong* | Resurvey (progress set back, +quality) / accept the error (−quality) |
| 50%, land | *Freeholders Refuse to Sell* | **Force them out** (+quality, radicals) / pay over the odds (money) / reroute (−quality) |
| 50% | *A Village in the Way* | **Clear the village** (+quality, radicals, rural folk −approval) / bend the line (−quality) |
| 50% | *Landowners Demand Compensation* | Pay (money) / refuse (landowners −approval, radicals) |
| 50% | *Speculators Buy the Right of Way* (boon or trap) | Buy them out (money, +progress) / expose them (industrialists −approval) |
| 75%, approval | *Parliament Questions the Cost* | Defend the budget (money) / trim the survey (−quality) |
| 75% | *Navvies' Camp Unrest* | **Break the strike** (+progress, radicals) / raise pay (money) |
| 75% | *Investors Offer Backing* (boon) | Accept (money back, industrialists +approval) |
| any, Militarized police only | *Heavy-Handed Clearances* | Stand by the police (+quality, many radicals) / rein them in (−quality, fewer radicals) |

The options in **bold** are the "force people to leave" options that police strengthen.

## 8. Police

Police only change the **bold** forcing options above, as you asked. They mostly add quality, with a small cut to those options' radicals.

| Police law | Quality bonus on forcing options | Radicals from forcing options |
| --- | --- | --- |
| No Police | none | unchanged |
| Local Police | +5% per institution level | −2% per level |
| Dedicated Police | +10% per level | −4% per level |
| Militarized Police | +25% per level | −6% per level, and *Heavy-Handed Clearances* can fire |
| Secret Police | as Dedicated, plus a flat +10% | as Dedicated, plus a flat −2% |

At institution level 5, Local gives +25%, Dedicated +50% and Militarized +125%. The level is read with `institution_investment_level` on `institution_police`, which vanilla uses in about 200 places.

## 9. AI

AI countries don't use the decision. Instead, a hidden yearly pass gives each AI country a 1 in 4 chance to "complete a survey":

- It picks the strategic region where the most of its states are at the Rail Works cap with an infrastructure shortfall.
- Each of its eligible states in that region gets +3 levels, the mid-quality result.
- It pays a one-off amount equal to what the survey's expenses would have cost.

That rate is a guess. It is tuned in step 6 so that AI rail caps keep pace with a reasonable player's, without running ahead of them.

## 10. Not affected

- Road Works, Harbour Works, the population floor (125,000) and the 1836 seed. No Rail Works exist before `railways`, so 1836 doesn't change.
- Standard of living: no SoL effects, as agreed.

## Plan of work

1. **Engine checks, in one short headless run with a test fixture.** These are the four assumptions the design rests on:
   - `has_max_level` plus the declared modifier caps Rail Works per state.
   - `add_modifier` with a variable multiplier works on a state.
   - Whether a variable on a state, or on a state region, survives a state split.
   - The script keys for surplus bureaucracy, urban centre level and turmoil.
2. **Measure R** from a 1936 save, and the province-count thresholds from `map_data/state_regions/`.
3. **Rail Works at 3×, and the cap.** Includes the yearly cap-maintenance pass and the AI construction event's cap check.
4. **The decision, region-picking events, journal entry, two bars, expenses and completion.**
5. **The event pool, police scaling and localization.**
6. **AI cap event, then balance:** a 30-year headless run, then a century run. Compare Rail Works levels, AI caps, deficit states and survey cost against the boi115 passes.
7. Update `BALANCE.md`, plan 1 and the lessons file.

## Answered 2026-11-07

1. Inputs and staff stay as they are, so the 3× boost makes rail cheaper per point.
2. Unincorporated states can join a survey, for now.
3. There is a cancel button. Cancelling ends the survey with no result, and the money spent is lost.
4. Secret Police counts as Dedicated, plus a small extra bonus: +10% quality and −2% radicals on top.

## Changed 2026-11-08

Your changes after the three balance passes:

- Rail Works at **2.5×** (Permanent Way 32.5, Steel Track 50, Electric Signalling 67.5, National Rail Grid 82.5; Statute Labour −6.25).
- Starting cap **1 / 2 / 4** by size (same 70 and 230 province thresholds). One capped level of Permanent Way gives 32.5 points, so most states need a survey well before 1850.
- Repeat surveys add **20%** of a state's share per earlier survey.

Balance runs: see the 8 Nov passes in the [balance log](../reports/rail_survey_7_Nov_2026/BALANCE_LOG.md).

## Prototype, 2026-11-07

Built as described above, with these differences:

- **Statute Labour's infrastructure penalty on Rail Works was tripled too** (−2.5 to −7.5 per level), so it stays the same share of output.
- **The cap modifiers go on at game start** (`common/history/global/zz_boi_rail_survey.txt`), and the monthly event `boi_rail_survey.50` repairs any state that loses them or changes size band.
- **The AI pass doesn't use strategic regions.** One year in four, it picks up to 5 states that have a railway, Rail Works at the cap and an infrastructure shortfall, and gives each +3. It pays a year of survey expenses at once, on credit if need be, and skips the year if its scaled debt is 0.5 or more. It checked the treasury until 2026-11-08, but AI countries hold almost no gold. Regions add nothing for the AI, and this is simpler to tune.
- **Progress and quality are country variables.** The bars only mirror them, and progress is held at 99% until all three stage events have fired.
- **Events:** 13 in the pool. The third stage adds *Rookeries on the Route*, which is only offered when a surveyed state has 5 or more urban centre levels.

Files:

| What | Where |
| --- | --- |
| Cap and PMs | `common/buildings/50_boi_buildings.txt` (`has_max_level`), `common/modifier_type_definitions/50_boi_modifier_types.txt`, `common/production_methods/50_boi_rail_works.txt` |
| Values, triggers, effects | `common/script_values/52_boi_rail_survey_values.txt`, `common/scripted_triggers/52_boi_rail_survey_triggers.txt`, `common/scripted_effects/52_boi_rail_survey_effects.txt` |
| Decision, journal entry, bars, button | `common/decisions/`, `common/journal_entries/`, `common/scripted_progress_bars/`, `common/scripted_buttons/` (all `50_boi_rail_survey.txt`) |
| Modifiers | `common/static_modifiers/50_boi_rail_survey.txt` |
| Events | `events/boi_rail_survey_events.txt` |
| AI construction | `boi_ai_rail_works_room` in `common/script_values/51_boi_ai_construction_values.txt` now stops at the cap |
| Text | `localization/english/boi_rail_survey_l_english.yml` |
| Testing | `tools/headless-telemetry/rail_survey/`: Britain, Prussia, the USA and Belgium act as players and survey their capital's region (`Test-Headless.ps1 -RailSurvey`). The `boi` module logs a yearly `BOITM|rail` line. |

Balance runs and their results: [balance log](../reports/rail_survey_7_Nov_2026/BALANCE_LOG.md). Three passes of 2 games to 1851 changed three things from sections 4 and 5 above:

- **The goal is divided by 1 + 0.15 per state after the first.** Britain's home region went from 92–100 months to 30–35.
- **The cost is £60 per state a week, not £100.**
- **The AI's Rail Works rule no longer checks the transportation price.**

**Fixed 2026-11-08:** the AI pass never paid out while it checked the treasury. With the debt check, it raised the French test state's cap 1 → 4 on its first call (pass 4 in the balance log).
