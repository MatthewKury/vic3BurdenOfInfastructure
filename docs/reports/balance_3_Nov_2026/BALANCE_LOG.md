# Balance log, 3 Nov 2026

Short headless runs on the road/rail split and housing tiers. Each pass is one game, and games vary a lot from run to run, so small differences are noise. Aim: bite without collapse (GDP within about 5% of vanilla, civil wars and radicals near vanilla, housing supply just under demand). Vanilla is the 10-run baseline, which stops at 1846. Generate a table with `python tools/Get-BalanceSummary.py <run>`.

## Before pass 1: engine probes (`20261103-065344_mod`)

- A shortage cuts the infrastructure a building gives: +100 with no input, +65 with its input at 1% of demand, +48 with the input absent. So Rail Works does need transportation, and Road Works gives less when horses are short.
- `possible` blocks new and further levels and logs a script error, so the AI event checks it first. `start_building_construction` ignores tech, so the event checks that too.
- `required_input_goods` is only safe on electricity. Oil and automobile PMs have no supply check, only a tech gate.
- `add_building_level` isn't a working effect, so **one level can't be removed by script. As you decided, AI redevelopment falls back to new builds only.**

A first 10-year attempt (`20261103-072226_mod`) crashed in 1840 at the known `...F76C` address with `boi_states` loaded. All balance runs use `-LongRun`, without that module.

## Pass 1 (`20261103-072803_mod`, 1836–1846)

Result: PASS, 0 BOI errors, all fixtures passed.

| | 1836 | 1840 | 1845 | Vanilla 1845 |
| --- | ---: | ---: | ---: | ---: |
| GDP against vanilla, shared powers | -5.6% | -3.0% | -0.8% | |
| SoL against vanilla | -0.53 | -0.46 | -0.07 | |
| Radicals, shared powers | 3.2% | 8.1% | 9.2% | 9.7% |
| Short states, major powers | 26 | 5 | 4 | 8.9 |
| Short states, world | 56 | 39 | 33 | About 27 |
| Basic housing supply/demand | 0.96 | 0.98 | 0.99 | |
| Luxury housing supply/demand | 0.92 | 0.91 | 0.80 | |
| Works goods at base price, share of expenses | 2.5% | 3.4% | 3.5% | |

**Takeaways:**

1. **Stable.** No major civil war in this game, and no power lost states. Single game, so this needs repeating.
2. **Shortage falls on China and British India.** In 1845, 10 Chinese states hold 191M of the people in short states, and most have no works at all. The AI event's limits, or China's small construction sector, keep it from catching up. Major powers mostly solve their shortages, with 4 short states against vanilla's 8.9.
3. **Britain carries the most.** Debt 0.46 against vanilla's 0.01, no gold against about £300,000, GDP -15%, radicals 15% against 12%. Expenses run about £30,000 a week above vanilla in 1836–37, which is about what its works cost. Debt levels off, so it's a burden and not a spiral.
4. **The AI prefers slums.** 18 to 40 levels, with few new Workers' Rows (205 to 216), because slums now cost half as much to build. Slums spread flat mortality to each new state.
5. **Housing supply is at demand, not just under it,** with a mean price at base. 12% of people still pay £45 or more.
6. **New tiers appear slowly:** 13 Regulated Terraces, 7 Railway Suburbs, 3 Model Dwellings, 2 Boulevard Apartments.
7. **Wood is on 13% of levels.** A +10% bonus gives a margin of only about £9 per slum level, and the AI tends to ignore tiny margins. That's in keeping with the ladder you chose.
8. **Rail Works is a niche so far:** 19 levels against 60 railway levels worldwide, as expected before 1850.

**Corrections for pass 2:** slums back to 200 construction points, the same as Workers' Rows. Basic housing seed coverage from 1.0 to 0.92. Britain's debt and China's shortage are left for now, to see whether they repeat.

## Pass 2 (`20261103-074049_mod`, 1836–1846)

Result: PASS.

| | 1836 | 1840 | 1845 |
| --- | ---: | ---: | ---: |
| GDP against vanilla, shared powers | -4.6% | -2.8% | -4.1% |
| SoL against vanilla | -0.52 | -0.55 | -0.71 |
| Radicals, mod / vanilla | 3.1 / 2.9 | 7.3 / 6.6 | 10.1 / 9.6 |
| Short states, major powers (vanilla 8.9 in 1845) | 27 | 8 | 5 |
| Short states, world | 51 | 26 | 28 |
| People in short states | 24% | 15% | 12% |
| Basic housing supply/demand | 0.87 | 0.90 | 0.93 |
| Basic housing price | 34.3 | 32.8 | 31.6 |
| Works goods at base price, share of expenses | 2.3% | 3.3% | 3.9% |

**Takeaways:**

1. **Housing is on target:** supply just under demand, price a little over base.
2. **Second game with no major civil war.** Radicals stay within a point of vanilla overall. Brazil (18% against 12%) and Britain (15% against 12%) are the high ones.
3. **Pass 1's -0.07 SoL gap was luck.** This game's -0.71 is in line with earlier runs, and the USA alone is -1.96 after taking 8 states. GDP moved from -0.8% to -4.1% with a change that shouldn't cost that much, which shows the size of single-game noise.
4. **Britain's debt repeats, but less:** 0.26 against 0.46, and vanilla's 0.01. It's a real cost of the works, not a fluke.
5. **China's shortage was partly luck too.** People in short states fall to 12%. China has 4 short states here, with 6 points missing.
6. **Slums still spread** (18 to 35), even at equal construction cost. They cost less to staff and supply. Only 8% of levels, and the rule so far is that the AI picking cheap housing is fine. Watch it in the long runs.
7. **Infrastructure still barely constrains major powers:** 5 short states against vanilla's 8.9, at about 4% of expenses, and usage at 55% of supply.

**Correction for pass 3:** test the population floor at 125,000, as agreed. Nothing else changes.

## Pass 3 (`20261103-075209_mod`, 1836–1846): floor at 125,000

Result: PASS. The define works: Aquitaine's infrastructure in December 1836 is 56.8 against 71.4, and Languedoc's 63.4 against 73.0.

| | 1836 | 1840 | 1845 | Pass 2, 1845 |
| --- | ---: | ---: | ---: | ---: |
| GDP against vanilla, shared powers | -6.3% | -1.3% | -0.9% | -4.1% |
| SoL against vanilla | -0.57 | -0.52 | -0.40 | -0.71 |
| Radicals, mod / vanilla | 3.2 / 2.8 | 8.9 / 6.5 | 11.4 / 9.6 | 10.1 / 9.6 |
| Short states, major powers | 46 | 11 | 5 | 5 |
| Short states, world | 75 | 33 | 35 | 28 |
| People in short states | 24% | 19% | 12% | 12% |
| Road / Rail / Harbour levels, world | 45 / 3 / 146 | 103 / 12 / 191 | 155 / 14 / 227 | 139 / 10 / 204 |
| Usage as share of supply, major powers | 68% | 62% | 61% | 55% |
| Works goods at base price, share of expenses | 2.6% | 3.7% | 3.8% | 3.9% |

**Takeaways:**

1. **It bites, then the AI answers.** Short states among major powers jump in 1836 and are back to 5 by 1845. The world builds about 10% more works, and usage is closer to supply. That is the behaviour the mod wants.
2. **No visible collapse,** though 1836 GDP is a little outside the 5% aim, at -6.3%.
3. **Brazil has a big loss:** 14 of 17 states, population -34%, debt 0.40, radicals 21.5%. A civil war, and Brazil was among the most-short powers in 1836 with 11 short states. Also higher radicals in Turkey (17.5% against 9.6%). One game can't separate this from the normal revolt rate, so it's a concern for the long runs.
4. **Decision: keep 125,000 as a trial.** This changes your 2026-08-16 rule, and it's one line in `common/defines/zz_boi_defines.txt` to undo.
5. **Luxury housing keeps falling short:** 0.80, 0.85 and 0.78 by 1845 in three games, with the price about £75 against a base of £60. New luxury levels are mostly villas, at 4 infrastructure each. No new Town Houses at all in this game, though they use only 2.5.

**Correction for pass 4:** Town Houses from 400 to 200 construction points, the same as villas, so the AI's cheap option is also the denser one.

## Pass 4 (`20261103-080354_mod`, 1836–1846)

Result: PASS.

| | 1836 | 1840 | 1845 |
| --- | ---: | ---: | ---: |
| GDP against vanilla, shared powers | -5.9% | -2.4% | +0.4% |
| SoL against vanilla | -0.52 | -0.42 | -0.35 |
| Radicals, mod / vanilla | 3.9 / 2.8 | 8.4 / 6.6 | 11.0 / 9.6 |
| Short states, major powers | 45 | 8 | 4 |
| Short states, world | 77 | 35 | 31 |
| People in short states | 24% | 20% | 11% |
| Basic housing supply/demand | 0.87 | 0.92 | 0.90 |
| Luxury housing supply/demand | 0.94 | 0.90 | 0.82 |
| Road / Rail / Harbour levels, world | 45 / 4 / 144 | 100 / 11 / 197 | 162 / 15 / 233 |

**Takeaways:**

1. **Within the aim on every headline by 1845,** and no power lost states. The 1836 GDP dip of about 6% stays a little outside it, but it recovers within a few years.
2. **Town Houses barely moved luxury supply:** 0.82, and the same few new levels. Luxury stays somewhat short, and a price of about £73 isn't damaging, so I've left it.
3. **Slums slowed to 20 → 27,** though that's within game-to-game noise.
4. **Britain still runs debt** (0.35), and Spain 0.40 against vanilla's 0.22. France's radicals are 25% against 20%.

No further correction. Everything still untested is late-game: oil and electric Light and Heat, Motor Roads, later Rail Works tiers and later housing tiers. Those need the century runs.

**Settings carried into the century runs:** floor 125,000, slums and Town Houses at 200 points, basic seed coverage 0.92, Light and Heat +10/+30/+60%. Results are in the [century report](../century_3_Nov_2026/REPORT.md).

## After the century runs: housing law politics (two runs to 1866)

**Changed (commit `54f70ba`):** Devout, Armed Forces, Rural Folk and Petty Bourgeoisie gained housing stances, the housing laws gained AI weights, and Municipal Estates gained `downsizeable = no`. The floor stays at 125,000, now confirmed. See [the housing plan](../../plans/04_HOUSING.md#interest-group-stances).

**Runs:** `20261103-200327_mod` (40 minutes) and `20261103-204330_mod` (43 minutes), both `-LongRun -NoFixtures`. "Before" is the same dates in the two century runs. Each column is one game, and games differ widely.

| | Before 1 | Before 2 | After 1 | After 2 |
| --- | ---: | ---: | ---: | ---: |
| GDP against vanilla, 1846 | +4.4% | -4.0% | -4.6% | +0.1% |
| SoL against vanilla, 1846 | -0.46 | -0.33 | -0.29 | -0.33 |
| Radicals, 1846 (vanilla about 9.6) | 11.7 | 10.4 | 13.1 | 11.8 |
| Radicals, 1865 | 14.7 | 16.4 | 14.7 | 13.8 |
| Basic housing supply/demand, 1865 | 0.94 | 0.95 | 0.90 | 0.96 |
| Luxury housing supply/demand, 1865 | 0.83 | 0.90 | 0.88 | 0.86 |
| Power-years with debt over 0.5, to 1865 | 11 / 347 | 25 / 357 | 32 / 435 | 8 / 388 |
| Major powers losing 25%+ of their states in a year | 2 | 3 | 3 | 0 |
| Work Town levels, major powers, 1865 | 0 | 0 | 4 | 155 |
| Work Camp levels, major powers, 1865 | 363 | 431 | 591 | 151 |

| Countries with the law, of about 240 | After 1: 1845 / 1855 / 1865 | After 2: 1845 / 1855 / 1865 |
| --- | ---: | ---: |
| Protected Employer Housing | 26 / 52 / 50 | 36 / 58 / 77 |
| Minimum Residential Standards | 2 / 8 / 18 | 3 / 7 / 12 |
| Mandatory Serviced Housing | 0 / 0 / 0 | 0 / 0 / 0 |

The century runs have no yearly law logs. Their only law counts are rough figures for 1936: Protected 4 / 0, Standards 5 / 2.

**Takeaways:**

1. **The AI now uses the housing laws,** decades earlier than before. Most adopters are small countries. Among major powers, Protected reached 1 and 6, and Standards 3 and 1. Game 2 now has more Work Town levels than Work Camp levels.
2. **I can't tell how much comes from the stances and how much from the weights,** because they went in together.
3. **No sign of harm in headline balance,** though two games can't rule out small effects. GDP stays within 5% of vanilla in 1846 and SoL about where it was. The weakest figures are After 1's radicals in 1846 (13.1) and basic housing in 1865 (0.90), and After 2 doesn't repeat them.
4. **Debt needs watching.** After 1 has the most debt-heavy years (France 12, Britain 11, Bengal 8), and After 2 the fewest, so this looks like the existing game-to-game swing, though two games can't settle it. Britain's debt peaked at 1.00 in 1852, before it briefly lost 14 of its 30 states in 1855; it held 30 again by 1856. France stays in heavy debt in all four games.
5. **Municipal Estates are untested in play.** Major powers first built them around 1897-1903 in the century runs, so a run to 1866 can't show whether the wipeouts stopped. Mandated also needs a later date.
6. **Standards countries' housing is mixed:** 0.79 against 0.92 for the rest in game 1, where France and Bengal hold the law, and 1.03 against 0.96 in game 2. This is too little to judge, so check it again in a longer run.
7. **Road financing is unchanged and still stuck:** about 84% of Road Works buildings were on Statute Labour in the last autosave. This pass left those laws alone.

**One engine assertion made After 1 a harness FAIL:** `Failed creating backing building for Building Type building_boi_slums` in Rhone, around November 1861. France's yearly law log first shows Standards that December. The likely cause, inferred, is a slum order already queued when the law passed. The run continued to 1866, and a century run logged the same assertion for a vanilla coffee plantation, so I made no change.
