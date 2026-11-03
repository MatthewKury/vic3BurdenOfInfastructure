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
