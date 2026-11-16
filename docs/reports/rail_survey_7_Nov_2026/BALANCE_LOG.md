# Balance log: Rail Network Survey (7 Nov 2026)

The first games with the Rail Network Survey prototype ([proposal](../../plans/01_RAIL_SURVEY_PROPOSAL.md)). Each pass is 2 games to 1851, run as an ensemble with `-RailSurvey`. In every game, Britain, Prussia, the USA and Belgium act as players: they survey their capital's strategic region from March 1836, and start another survey as soon as one ends. The AI answers the survey's events by `ai_chance`. Every other country is plain AI, so its Rail Works cap rises only through the yearly AI pass.

Comparisons:

- **Vanilla:** `vanilla115_1836_1936_all`, whose 10 members that reach 1851 are used (`--horizon 1851`).
- **BOI before this change:** `boi115_pass4` (2 games), at `--horizon 1846`, since the boi115 passes stop there.

With 2 games against 10, differences under about 3% in world GDP are noise (see the 6 Nov log).

Regenerate a pass's reports with:

```powershell
& "$env:LOCALAPPDATA/Programs/Python/Python312/python.exe" tools/ensembles/Make-EnsembleReport.py --ensemble vanilla115_1836_1936_all --compare rs_passN --horizon 1851 --out docs/reports/rs_passN
& "$env:LOCALAPPDATA/Programs/Python/Python312/python.exe" tools/Get-RailSurveySummary.py <run> <run>
```

**What "balanced" means here:**

- the economy stays where BOI already was, or better: GDP no further below vanilla, and short states no higher;
- a survey takes about 2 to 4 years and costs about 1–2% of spending;
- quality varies from survey to survey;
- AI caps keep up with the stand-in players' without running ahead of them;
- 0 BOI errors, and no state above its cap.

## Smoke runs

| Run | Length | Result | What it showed |
| --- | --- | --- | --- |
| `20261107-130030_mod` | to 1836.7 | FAIL, 3 errors | Two counters written only by `change_variable` counted as never set, and the journal entry needed an `activation_description`. Fixed. Every state got its cap modifier. `create_building` ignores the cap: it built 4 levels where the cap was 2. That test has been removed from the fixture. |
| `20261107-130305_mod` | to 1838.3 | PASS, 0 BOI errors | All four surveys started. Belgium finished in 16 months at quality 60, +4 levels in each of 3 states, then started a second survey with a goal 1.5× the first. |

Survey sizes at the start (smoke run 2):

| Country | States | Goal (months at base rate) | Rate | Weekly cost | Share of expenses |
| --- | ---: | ---: | ---: | ---: | ---: |
| Britain | 13 | 92 | 1.00 | £1,768 | 0.7% |
| Belgium | 3 | 20 | 1.11 | £357 | 1.3% |
| USA | 27 | 167 | 1.22 | £3,029 | 3.4% |
| Prussia | 8 | 51 | 1.13 | £994 | 1.1% |

The goal grows with the number of states, so a big country's home region takes 7 to 11 years.

## Pass 1: as designed (2 games, plus 1 left out)

**Settings:** the prototype as built. Rail Works 3×, cap 2/4/6, AI pass one year in four (+3 levels to up to 5 states), goal 6 + urban share per state, flat rate 1 + bureaucracy bonus, costs £100 per state plus GDP/50,000 a week. Ensemble `rs_pass1`, runs `20261107-132857_mod` and `20261107-135103_mod`. The first game, `20261107-130717_mod`, finished but was marked FAIL for one `Failed creating backing building` assertion on a Horse Ranch in Ica. That's the known, harmless assertion (lessons file §20), but the ensemble runner leaves FAIL games out, so a third game was played. Its survey data is used below, alongside the second game. Report: [rs_pass1](../rs_pass1/REPORT.md).

**Errors:** 0 BOI errors in the passing games, 0 states over the cap, every state with its cap modifier.

| World, against vanilla | 1846 BOI before (pass 3, pass 4) | 1846 pass 1 | 1851 pass 1 |
| --- | ---: | ---: | ---: |
| GDP | −8.5%, −8.1% | −8.5% | −8.8% |
| SoL | −2.7%, −2.9% | −4.6% | −4.5% |
| Radicals | +11%, −12% | −12% | +16% |
| Short states | 33, 30 (vanilla 30) | 25.5 | 30.5 (vanilla 41) |
| Railway levels | −23%, −15% | −12% | −26% |

**Findings:**

1. **The AI almost never builds Rail Works, so the cap never binds for it.** The major powers held 7–8 Rail Works levels in 1850, with 1 state at its cap in one game and none in the other, and the AI pass never fired. Earlier BOI runs had 0–4 per power by 1845 as well. Two causes: railways are still rare (about 120 levels in the world by 1851), and the AI's rule took Rail Works only where transportation wasn't dear. Transportation sits at its price ceiling almost everywhere, so the AI built roads. At 3×, Rail Works is the cheaper point even at the ceiling: about £11 a point at £52.50 transportation, against about £20 for Cart Roads.
2. **So the economy is where BOI already was.** Every difference from BOI before is within the noise of 2 games.
3. **Surveys of big regions take far too long.** The goal is the sum of the states' shares, so it grows with the number of states:

| Survey (games `130717` and `132857`) | Months | Quality | Levels gained |
| --- | ---: | ---: | ---: |
| Belgium #1–#5 (3, then 2 states) | 18–42 | 45–85 | 3–5 |
| Prussia #1–#2 (8 states) | 51–79 | 40–60 | 3–4 |
| Britain #1 (13 states) | 92–100 | 45–50 | 3 |
| USA #1 (27 states) | 155, or unfinished by 1851 | 73 | 4 |

   Median 35 months, quality median 60–62, levels median 4. Costs ran from 0.5% to 3% of expenses, highest for the USA. That's in range, but over 13 years it adds up.
4. **The stand-in players never used their new caps.** By 1850 Britain had a cap of 97 levels and 3 Rail Works levels. They're AI underneath, so they build by the AI's rule, which is finding 1 again.

**Changes for pass 2:**

- The AI takes Rail Works wherever a railway and room under the cap allow. The transportation-price test is gone (`boi_ai_state_prefers_rail_works`).
- The survey goal is divided by 1 + 0.15 for each state after the first (`boi_rs_goal_total`). In the smoke-run sizes that's about 15 months for Belgium, 25 for Prussia, 33 for Britain and 34 for the USA.

## Pass 2: AI takes Rail Works freely, faster big surveys (2 games)

**Settings:** pass 1, plus the two changes above. Ensemble `rs_pass2`, runs `20261107-141559_mod` and `20261107-143738_mod`. Both passed with 0 BOI errors. Report: [rs_pass2](../rs_pass2/REPORT.md).

| World, against vanilla | 1846 pass 1 | 1846 pass 2 | 1851 pass 1 | 1851 pass 2 |
| --- | ---: | ---: | ---: | ---: |
| GDP | −8.5% | −8.1% | −8.8% | −7.5% |
| SoL | −4.6% | −1.9% | −4.5% | −3.9% |
| Radicals | −12% | −9% | +16% | −6% |
| Turmoil | −10% | −7% | +19% | −5% |
| Short states | 25.5 | 27 | 30.5 | 31 (vanilla 41) |
| Railway levels | −12% | −30% | −26% | −34% |

**Findings:**

1. **The economy is unchanged within the noise.** GDP, SoL and short states match pass 1 and BOI before. Railway levels are lower, but that is a private build, and its spread across 2 games is about as large as the gap.
2. **Surveys now run 15–32 months the first time.** Over all 31 completed surveys in the two games, the median is 36–38 months (range 15–76), because each repeat survey of the same states is 50% longer than the last. Quality ran from 30 to 94, median 50–55, and levels gained median 3.

| First survey | Game 1 | Game 2 |
| --- | ---: | ---: |
| Belgium (3 states) | 16 months, quality 75, +4 | 15 months, 65, +4 |
| Prussia (8) | 22 months, 50, +3 | 24 months, 46, +3 |
| Britain (13) | 30 months, 50, +3 | 32 months, 30, +2 |
| USA (27) | 32 months, 30, +2 | 29 months, 60, +4 |

3. **Rail Works are still rare without the price test:** 10–13 levels across the major powers by 1850, and 0–1 states at the cap. So the price rule wasn't the main block. The AI's works event only builds where a state is short of infrastructure, few are (0–3 among the majors), and 2 levels at 3× give 78 points, which covers most shortfalls. **The cap doesn't bind for the AI in the first 15 years, so the AI pass never fired.**
4. **Costs:** 0.6–1.7% of expenses for Britain, Prussia and Belgium, but 3–3.5% for the USA, because £100 per state dominates for a country with many states and a small budget.

**Changes for pass 3:**

- Per-state cost £100 → £60 a week (`boi_rs_weekly_cost`, and the AI pass's charge to match).
- Test-only, in the fixture: from 1837 one normal-size French state with a railway is filled to its cap of 2 Rail Works and given −300 infrastructure for 4 months. Then the real AI pass event, `boi_rail_survey.60`, is fired 8 times. That's the only way to run its code inside 15 years. It perturbs one French state.

## Pass 3: lower per-state cost, forced AI pass test (2 games)

**Settings:** pass 2, plus £60 per surveyed state a week (was £100), and the French AI-pass fixture. Ensemble `rs_pass3`, runs `20261107-150002_mod` and `20261107-152232_mod`. Both passed with 0 BOI errors and 0 states over the cap. Report: [rs_pass3](../rs_pass3/REPORT.md).

| World at 1851, against vanilla | Pass 1 | Pass 2 | Pass 3 |
| --- | ---: | ---: | ---: |
| GDP | −8.8% | −7.5% | −8.3% |
| SoL | −4.5% | −3.9% | −2.6% |
| Radicals | +16% | −6% | −20% |
| Turmoil | +19% | −5% | −18% |
| Short states (vanilla 41) | 30.5 | 31 | 23 |

**Findings:**

1. **The economy hasn't moved across the three passes.** GDP stays at −7.5% to −8.8%, where BOI was before the change. The SoL and radicals swings are the run-to-run spread of 2-game ensembles.
2. **Surveys are where they should be.**
   - First surveys: Belgium 14–15 months, Prussia 19–23, the USA 29–32, Britain 33–35.
   - All 29 completed surveys: median 35 months (range 14–75), quality median 50 (range 30–89), levels gained median 3.
   - Costs: 0.3–1.4% of expenses for Britain, Prussia and Belgium, and 1.7–2.4% for the USA, about the 1–2% aim.
3. **The AI pass never paid out, even when forced.** In both games the French test state was ready, at its cap of 2 and 236–340 points short, but 8 calls of `boi_rail_survey.60` left its cap at 2. Missing 16 times by chance (3 in 4 each time) is about a 1% chance, so something in the event blocks it. The likeliest cause is the treasury check `gold_reserves > boi_rs_ai_cost`. France would need about £60–80k in hand, and AI countries that borrow hold little gold. That would make the pass skip most AI countries. **Not fixed: iterating stopped here at your request.** The fixture now also logs France's gold, the cost and the debt at the test (`rs_ai_pass_money`), so the next run will confirm the cause.
4. **Cap pressure is still near zero in 15 years:** 9–14 Rail Works levels across the majors by 1850, 1–2 states at the cap.

## Where it stands, and next steps

Kept settings (all test values):

- Rail Works 3×, cap 2/4/6.
- Goal per state 6 + urban share, ×1.5 per earlier survey, divided by 1 + 0.15 per extra state.
- Rate 1 + bureaucracy bonus. Cost £60 per state + GDP/50,000 a week.
- AI takes Rail Works wherever a railway and cap room allow.
- AI pass one year in four, +3 to up to 5 states.

Next steps, in order:

1. **Fix the AI pass's money check.** Replace `gold_reserves > boi_rs_ai_cost` with a debt test such as `scaled_debt < 0.5`, and charge the cost even when it goes on credit. Confirm with one short run with the French fixture.
2. **A 30–50 year run** (e.g. `Invoke-HeadlessEnsemble.ps1 -Name rs_long -Runs 2 -UntilDate 1886.1.15 -RailSurvey`). Only a longer game shows whether AI states reach their caps once railways spread, and whether the AI pass keeps them level with the stand-in players.
3. **Decide whether the starting cap is low enough.** At 3×, 2 levels of Permanent Way give 78 infrastructure, which covers most states before 1850. A player has little reason to survey early. A base of 1 would make the early game bite, but that departs from your 2/4/6.
4. **Play it by hand once.** The decision, the region pickers, the bar text and the cancel button have only been driven by the fixture, never through the UI. Watch for loc errors or overflowing option lists. Region option lists run to 7 entries, plus Back and Not now.
5. **The repeat-survey growth (+50% per survey)** reached 63–75 months by the fourth survey of the same states. Leave it or soften it, as you prefer.

## 8 Nov 2026: 2.5x Rail Works, cap 1/2/4, AI pass fixed (1 game)

**Changes since pass 3:**

- Rail Works 3x → 2.5x: 32.5 / 50 / 67.5 / 82.5 infrastructure per level.
- Starting cap 2/4/6 → 1/2/4.
- Repeat surveys of the same states +50% → +20% per earlier survey.
- AI pass money check: `gold_reserves > boi_rs_ai_cost` → `scaled_debt < 0.5`. The charge goes on credit.
- Outside the survey:
  - Horse Ranch gets a by-product group (Knacker's Yard, Manure Trade, Mixed Grazing) and vanilla's fencing group.
  - The 1836 housing seed is privately owned. It was state-owned before.
  - Both housing law groups moved to the Social tab.

A smoke run, `20261108-102856_mod`, failed with 33 errors from new housing telemetry. The ownership-fraction triggers need `level > 0`. Fixed.

## Pass 4 (1 game)

**Settings:** as above. Ensemble `rs_pass4`, run `20261108-111511_mod`. PASS, 0 BOI errors, 0 states over the cap. Report: [rs_pass4](../rs_pass4/REPORT.md). It's one game against 10, so treat it as a check, not a measurement. You asked to stop iterating after this one, so passes 5 and 6 were not run.

| World at 1851, against vanilla | Pass 3 (2 games) | Pass 4 (1 game) |
| --- | ---: | ---: |
| GDP | −8.3% | −6.9% |
| SoL | −2.6% | −2.7% |
| Radicals | −20% | −13% |
| Short states | 23 | 20 (vanilla 43) |
| Railway levels | – | −33.5% |

**Findings:**

1. **The AI pass works now.**
   - At the French test state, gold was £0, the cost was £23,807, and debt was 3%.
   - With the debt check, the pass raised the cap 1 → 4 on its first fixture call (7 Mar 1837).
   - So pass 3's diagnosis was right.
2. **Surveys sit in range.**
   - First surveys: Belgium 14 months, Prussia 27, the USA 31, Britain 33.
   - All 21 completed surveys: median 33 months (range 14–61), quality median 57 (range 20–77), levels median 3.
   - At +20%, fourth and fifth surveys take 40–61 months, against 63–75 at +50%.
   - Costs: 0.3–1.4% of expenses for Britain, Prussia and Belgium, and 1.2–2.3% for the USA.
3. **Cap pressure is still low, even at cap 1.**
   - The majors held 8 Rail Works levels in 1850, and 3 states sat at their cap.
   - The AI still builds few Rail Works, because railways are rare before 1850.
   - The low cap mainly matters to a player, and to the AI after 1850.
4. **Economy: no worse than before.** GDP at −6.9% is the best of the four passes, but a single game is within the noise.
5. **Housing ownership:** 1850 figures from the yearly telemetry, major powers.
   - Britain and France: 0 levels with any state share.
   - Prussia: 2 of 29. USA: 8 of 53. Russia: 6 of 84. Austria: 15 of 46.
   - The seed stayed private. The state-owned levels are the AI government's own construction, which is vanilla behaviour.
   - Private investment doesn't seem to build housing; see the investment_scores note in the lessons file. Not changed yet.

**Kept settings:** Rail Works 2.5x, cap 1/2/4, goal ×(1 + 0.2 per earlier survey), AI pass on a debt check. Next steps 1 and 5 from 7 Nov are done. Steps 2–4 still stand.
