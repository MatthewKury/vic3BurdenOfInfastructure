# Balance log: feature-complete pass (8 Nov 2026)

Two 20-year games (1836 to 1856.1.15) after building [plan 6](../../plans/06_FEATURE_COMPLETE_PLAN.md). You asked for game 1, then fixes for any obvious balance issues, then game 2. Each game is one ensemble member with `-RailSurvey`:

- Britain, Prussia, the USA and Belgium act as players for the Rail Network Survey.
- Britain is also forced into Minimum Residential Standards on 1837.1.1 and modernises its home region (Western Europe: 10 British states). That's the City Modernisation fixture.
- Everyone else is plain AI.

**Comparisons:**
- `vanilla115_1836_1936_all`: 8 vanilla games that reach 1846, 5 that reach 1851 and 1856.
- `rs_pass4`: BOI before this work, one game to 1851.

With one game against five, differences under about 3% in world GDP are noise. Population is nearly deterministic (cv 0.4%), so a gap there of 1% or more is meaningful. Wars vary hugely from game to game.

Regenerate with:

```powershell
& "$env:LOCALAPPDATA/Programs/Python/Python312/python.exe" tools/ensembles/Compare-Headline.py vanilla115_1836_1936_all rs_pass4 fc_game1 fc_game2 --years 1846 1851 1856
& "$env:LOCALAPPDATA/Programs/Python/Python312/python.exe" tools/ensembles/Make-EnsembleReport.py --ensemble vanilla115_1836_1936_all --compare fc_gameN --horizon 1856 --out docs/reports/fc_gameN
```

## Smoke runs before game 1

| Run | Length | Result | What it showed |
| --- | --- | --- | --- |
| `20261108-130549_mod` | to 1838.7 | FAIL, 10 lines | 9 new script files had no BOM: `lexer.cpp: … should be in utf8-bom encoding`. `building_group_bg_boi_residential_construction_efficiency_add` is "defined in script but not in code": the engine creates group modifiers for vanilla groups only. The City Modernisation bonus moved to `state_construction_mult`. The modernisation itself ran. There was no `Failed creating backing building` with the 34 new city-type files. |
| `20261108-131100_mod` | to 1837.3 | PASS, 0 BOI errors | 67 `Duplicated key` lines, as expected (65 plus the 2 ownership buildings). |

## Game 1

**Settings:** everything in plan 6 as built. Ensemble `fc_game1`, run `20261108-131318_mod`. PASS, 0 BOI errors, 27 minutes.

| World, against vanilla | 1846 | 1851 | 1856 |
| --- | ---: | ---: | ---: |
| GDP | – | −3.6% (rs_pass4 −6.7%) | −3.8% |
| Population | – | −2.8% (rs_pass4 −2.2%) | −3.9% |
| SoL | – | −4.9% (rs_pass4 −3.9%) | −2.1% |
| Radicals | – | −30% | −41% |
| Short states | 27 (vanilla 30) | 13 (vanilla 41) | 25 (vanilla 38) |
| Railway levels | – | −30% | −28% |
| Countries at war | 42 (vanilla 10) | 16 (vanilla 22) | 2 (vanilla 20) |

**Findings:**

1. **The economy is no worse, and GDP may be better.** World GDP was 3.6–3.8% below vanilla, against 6.7% in rs_pass4. That fits cheaper works and private housing investment. It's one game, so treat it as no worse until more games agree.
2. **Population is about 1% lower than in BOI before.** Most of that is France: 41.9 million in 1850, against 44.8 million in rs_pass4. The other major powers are within 1.3%. A war wave around 1846 hit this game: 42 countries at war, against 10 in vanilla. Company housing is not the cause. Work Camps were 50 levels across the major powers in 1850, against 57 in rs_pass4, beside about 1,600 levels with no company housing. The Labour Rights mapping therefore changed little before 1856. **Not changed. It needs more games.**
3. **Private capital builds housing now.** Major powers' privately owned housing in 1850 was 368 levels, against 229 in rs_pass4 (+61%). Private-type housing in total was 435, against 364.
4. **City Modernisation works, and the AI uses it.**
   - Britain's (fixture) ran 1837–1842, 60 months, and cleared 19 levels in 10 states. Its expensive-housing states rose from 14–15 to 21 in 1839, then fell to 16–17 by 1843, below rs_pass4's 18. That's the shock, then the recovery.
   - The AI took the decision three times by itself, and each finished: Hungary (1848–52, 5 states, 8 levels), Sardinia (1851–54, 3 states, 5 levels) and Finland (by 1855, 5 states, 5 levels).
5. **Bug: the first stage cleared the whole region.** Britain lost all 19 levels in June 1838, and the later stages found nothing left. See the fixes below.
6. **Municipal Estates:** none by 1856, as expected. They need Socialism and a socialist government.
7. **Residential Standards:** 3 of 20 countries had it by 1855. The Road Fund (combustion engine) and the Epizootic (1872) are outside the window.

**Fixes before game 2.** Neither is a balance number:

- `boi_cm_clear_to_target`: `ordered_scope_state` without `max` runs on every matching state, not just the first. Game 1's first stage therefore cleared all 10 states. It now has `max = 1`, and the loop compares two variables. A check run to 1839, `20261108-135420_mod`, cleared exactly 3 of 10 states (9 levels) at the first stage.
- `boi_cm_state_eligible` now needs Slum or Workers' Rows *levels* (`boi_cm_state_low_tier_levels > 0`), not just `has_building`.
- Telemetry only: yearly prestige for the major powers (`BOIPRES|`), and a world count of each new event's cooldowns (`ev_counts`).

In the check run, 3 years in: glanders had hit 11 countries, remounts 40 (every country at war), defaulters 3 and Rebecca Riots none.

A side note: smoke run `20261108-135114_mod` crashed on 31 December 1837, inside Britain's per-state `BOIDIAG` telemetry loop. That's the known crash linked to the `boi_states` module (lessons file §20). With `-LongRun` it didn't recur. The ensemble games always use `-LongRun`.

## Game 2

**Settings:** game 1, plus the two City Modernisation fixes and the new telemetry. Ensemble `fc_game2`, run `20261108-142017_mod`. PASS, 0 BOI errors, 23 minutes.

The runner's first attempt, `20261108-135815_mod`, failed with 6 BOI errors and was left out (see below). error.log in the passing game holds 13,227 lines, against 1,290 in game 1. They're vanilla: 2,779 `Event target link 'market' returned an invalid object` from the treaty-article and trade-route scripts.

| World, against vanilla | Game 1, 1851 | Game 2, 1851 | Game 1, 1856 | Game 2, 1856 |
| --- | ---: | ---: | ---: | ---: |
| GDP | −3.6% | −4.5% | −3.8% | −6.7% |
| Population | −2.8% | −2.7% | −3.9% | −3.3% |
| SoL | −4.9% | −10.3% | −2.1% | +0.1% |
| Radicals | −30% | −17% | −41% | −25% |
| Short states (vanilla 41, 38) | 13 | 31 | 25 | 29 |
| Railway levels | −30% | −26% | −28% | −35% |
| Countries at war (vanilla 22, 20) | 16 | 9 | 2 | 20 |

**Findings:**

1. **Over the two games the economy sits where BOI was, or slightly better.**
   - GDP averages −4% against vanilla at 1851 (rs_pass4 −6.7%) and −5.3% at 1856.
   - Population is −2.7 to −3.9%.
   - SoL swings with China, which holds a third of the world's people (−10.3% in 1851, +0.1% in 1856, game 2).
   - With one game each, none of these gaps is beyond the noise. No balance number was changed.
2. **Staged clearance works.** Britain cleared 3 states (9 levels) in June 1838, 5 (13) in December 1839, 8 (17) in December 1840, and all 10 (19 levels) on completion in December 1841, after 59 months. The construction bonus covered all 10 states from the first clearance.
3. **The prestige penalty is small next to everything else.**
   - Britain's prestige went from 330 in 1837 to 517 in 1845 and 821 in 1855, with no slums or rows left after modernisation.
   - France, with 2 slum and 23–26 row levels, went 350 → 231 → 363. Russia, with 1–7 and 24–27, went 491 → 562 → 570.
   - The USA (6 and 26 by 1855) went 145 → 215.
   - So the penalty, at most about −9% for France and −10% for Russia, doesn't stop prestige growing. Raise it if you want slums to bite harder.
4. **Private housing ownership holds up.** In 1850 the major powers held 350 fully private levels (game 1: 368; rs_pass4: 229).
5. **The AI modernises.** Norway completed one (3 states, 4 levels, 1852–55). In game 1 Hungary, Sardinia and Finland did. Each game had 1–3 AI modernisations by 1856.
6. **Event rates.** Number of countries whose cooldown was running, so roughly "fired in the last 4–5 years":

   | Event | 1840 | 1845 | 1850 | 1855 |
   | --- | ---: | ---: | ---: | ---: |
   | Road-duty defaulters | 5 | 28 | 28 | 35 |
   | Glanders | 16 | 20 | 23 | 23 |
   | Remounts | 32 | 45 | 9 | 44 |
   | Rebecca Riots | 1 | 0 | 1 | 1 |

   Remounts fire for every country at war, small wars included. Defaulters go to every Statute Labour country. Both may feel frequent to a player. Rebecca Riots are rare, because few countries hold Tolls and Dues with a restless state.

**Bug found and fixed after game 2 (not replayed).** The failed attempt `20261108-135815_mod` logged `Event target link 'var' returned an invalid object` from `boi_rs_drop_lost_states` and `boi_rs_cleanup`. A state's survey marker pointed at a country that no longer existed, and `var:boi_in_rail_survey = root` errors on a dead target. This code predates today, but City Modernisation copied the pattern.

- Both now use `?=`.
- The "lost states" cleanup now drops any state whose marker isn't its current owner's. Otherwise a state marked by a dead country could never be surveyed or modernised again.
- A load check, `20261108-144524_mod`, passed with 0 BOI errors. The dead-country case itself hasn't been replayed.

## Where it stands

You asked to stop iterating here. Open, in order:

1. **Play it by hand.** Check, through the UI:
   - City Modernisation (decision, picker, bar, cancel) and the Rail Network Survey;
   - the new map models: does the Harbour Works lighthouse sit sensibly on a port?;
   - the Social tab with the one remaining housing law group.
2. **Event frequency. Changed 2026-11-08, at your request:**
   - Remounts now needs a country at war with at least 20 battalions (raised conscripts included), and passes a 50% roll each year it qualifies. The 4-year cooldown starts only when it fires.
   - Defaulters' yearly roll went from 8% to 4%. Its 5-year cooldown was already in place.
   - Load check `20261108-145645_mod`: PASS, 0 BOI errors. After 1 year, 2 countries had Remounts running, against 6-14 before. The longer-run rates are untested.
3. **Prestige penalty strength** (finding 3). **Kept as is for now (your call, 2026-11-08); to revisit.**
4. **A longer ensemble** (several games to 1886) to see the Road Fund, Municipal Estates, the Epizootic and Serviced Towns, none of which can appear before 1856.
5. **A licence** for release (your choice), and commit the branch.

## Added after the games (2026-11-08, not balance-tested)

Your requests after the games:

- **Event frequency** (above).
- **The rehousing pledge journal entry, and a culture penalty for forcing people out.** The culture is the largest poor pop on the spot below the top acceptance tier, which was your change.
- **Five events where the poor bear the cost.**

Check run `20261108-152132_mod` (to 1839): PASS, 0 BOI errors, staged clearance as before. Untested: whether the pledge, the culture penalty or the new events fired, because no telemetry records them yet. Selecting a culture through `ordered_scope_pop` → `culture = { save_scope_as }` loads without error, but its effect hasn't been seen.

**Housing events, and the Horse Ranch by-products** (later the same day):
- Twelve housing events, generated by `tools/Build-HousingEvents.py`. Check run `20261108-153350_mod` (to 1840): PASS, 0 BOI errors. By the end of 1839, Company Store had fired once, Disaster at the Camp twice and Building Bubble twice. The Great Fire and the Philanthropist's Offer hadn't fired. No rehousing pledge had started.
- Manure Trade and Mixed Grazing now cut horse output by 3 and 6, instead of buying grain.
- A run without the rail-survey telemetry (`20261108-154029_mod`) found 6 "set but never used" warnings for the completion-text variables of the survey and modernisation. Fixed by reading them in the completion events' triggers. `20261108-154304_mod`: PASS, 0 BOI errors.
- None of this is balance-tested.
