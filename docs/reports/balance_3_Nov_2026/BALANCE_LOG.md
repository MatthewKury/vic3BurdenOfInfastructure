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
