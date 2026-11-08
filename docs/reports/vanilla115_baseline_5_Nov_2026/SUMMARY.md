# Vanilla 1.15 baseline: summary (5 Nov 2026)

These are vanilla Victoria 3 **1.15.0** observer games (`-handsoff`, all DLC, no mods). They're
the yardstick for Burden of Infrastructure on 1.15. Data is in `tools/ensembles/ensembles.sqlite`
and the full reports are in this folder:

| Report | Question | Games |
|---|---|---|
| [1846_vs_1.13](1846_vs_1.13/REPORT.md) | How does 1.15 differ from 1.13 after 10 years? | 10 (1.13) vs 13 (1.15) |
| [to_1856](to_1856/REPORT.md) | What does a 20-year 1.15 game look like? | 10 |
| [to_1886](to_1886/REPORT.md) | What does a 50-year game look like? | 5 |
| [to_1898](to_1898/REPORT.md) | The first 62 years | 2, a rough guide only |

## What was run

The plan was 3 ten-year games, 3 twenty-year, 2 fifty-year and 2 hundred-year games.

| Length | Planned | Passed | Crashed |
|---|---|---|---|
| 10 years (to 1846) | 3 | 3 | 0 |
| 20 years (to 1856) | 3 | 3 | 0 |
| 50 years (to 1886) | 2 | 2 | 1, in 1872 (replaced) |
| 100 years (to 1936) | 2 | **0** | 4, in 1896, 1928, 1886 and 1899 |

There are two ensembles:
- `vanilla115_1836_1936` holds the 8 games that passed. It's the clean baseline.
- `vanilla115_1836_1936_all` adds the 5 crashed games, each up to its last complete snapshot.
  The reports use this one.

The crashes are an engine access violation at one address, inside the telemetry's per-state
logging. Nothing suggests they depend on how a game develops, so a crashed game's data before the
crash should be as good as any other's. Collection was stopped after the fourth 100-year attempt,
as asked. The crash investigation is in `VIC3_MODDING_LESSONS.md`, under "Unsolved".

**Games still running in each year:** 13 in 1846, 10 in 1856, 7 in 1866, 6 in 1876, 5 in 1886,
2 in 1896, and 1 from 1906 to 1928. Any figure after 1896 comes from a single game.

## 1.15 compared with 1.13, January 1846

10 games on 1.13.11 against 13 on 1.15.0. These are the differences most likely to be real:
p ≤ 0.003, and larger than the smallest effect these sample sizes can detect.

| Metric | 1.13 | 1.15 | Change | p |
|---|--:|--:|--:|--:|
| World GDP | 529 M | 543 M | +2.6% | 0.001 |
| Literacy (pop-weighted) | 28.4% | 29.7% | +4.6% | 0.003 |
| Urbanization | 103 k | 104 k | +1.4% | 0.002 |
| Construction sector levels | 588 | 679 | +15.4% | <0.001 |
| Countries in debt | 99.6 | 74.6 | -25.1% | <0.001 |
| States short of infrastructure | 27.1 | 30.9 | +13.8% | 0.003 |
| Infrastructure usage | | | +2.2% | 0.001 |
| Transportation demand | | | +6.4% | <0.001 |
| Grain price | | | +5.4% | 0.001 |
| Wood price | | | +4.4% | 0.002 |
| Tools price | | | -4.0% | 0.003 |
| Wage (pop-weighted) | 0.643 | 0.533 | -17.1% | <0.001 |

Weaker differences, p between 0.01 and 0.05:
- standard of living −2.4%;
- gold reserves +7.1%;
- groceries price +3.0%;
- ranches and urban centres both up by 1–2%.

The report tests about 60 metrics, so expect two or three of these to be chance. Population, unemployment, the number of countries, radicals and turmoil don't differ measurably.

**What it means for BOI:** on 1.15, infrastructure is somewhat tighter by 1846. Demand for
transport and use of infrastructure are higher, and more states are short. More is being built,
and governments are in better financial shape. BOI's numbers were tuned on 1.13, so expect its
effects on infrastructure to be a little stronger on 1.15.

**Caveats:**
- **Wage** is logged to one decimal place on values of about 0.2–1.5, so each state's figure
  is coarse. The drop shows in every major power, though: Britain 1.58→1.42, France 1.17→0.97,
  China 0.25→0.18. That makes it probably real, but measured roughly.
- **Country comparisons** are muddied by the redrawn 1836 map: 897 states against 888, and new
  borders around Poland. For example, Austria's GDP is +37% and Prussia's −16%. Compare
  countries only within 1.15.

## The world over time on 1.15

Mean of the games still running. The number of games falls as you read right.

| | 1846 | 1856 | 1866 | 1876 | 1886 | 1896 | 1906 | 1916 | 1926 |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| Games | 13 | 10 | 7 | 6 | 5 | 2 | 1 | 1 | 1 |
| GDP (bn) | 0.54 | 0.68 | 0.84 | 1.02 | 1.32 | 1.70 | 2.38 | 3.38 | 4.79 |
| Population (bn) | 1.11 | 1.20 | 1.29 | 1.37 | 1.45 | 1.55 | 1.63 | 1.74 | 1.85 |
| Standard of living | 8.20 | 8.19 | 8.44 | 8.81 | 9.05 | 9.41 | 9.95 | 10.96 | 12.81 |
| Literacy | 30% | 33% | 35% | 37% | 38% | 40% | 45% | 49% | 55% |
| Unemployed (M) | 20.8 | 32.3 | 40.8 | 45.9 | 50.0 | 56.0 | 48.7 | 50.0 | 43.9 |
| Countries | 269 | 243 | 218 | 205 | 197 | 176 | 173 | 163 | 160 |
| Countries at war | 12 | 21 | 23 | 22 | 28 | 37 | 48 | 29 | 28 |
| Railway levels | 99 | 235 | 411 | 678 | 995 | 1,436 | 2,357 | 3,205 | 4,410 |
| Infrastructure supply (k) | 30.1 | 36.8 | 45.2 | 57.4 | 71.3 | 93.1 | 118.3 | 160.1 | 214.5 |
| Infrastructure usage (k) | 12.6 | 16.4 | 20.3 | 24.7 | 31.0 | 38.8 | 54.3 | 74.8 | 100.0 |
| States short of infrastructure | 31 | 45 | 49 | 38 | 34 | 24 | 18 | 26 | 36 |
| Urban centre levels (k) | 0.8 | 1.2 | 1.7 | 2.3 | 3.3 | 5.0 | 8.3 | 12.1 | 18.2 |
| Pollution generated (k) | 14 | 31 | 60 | 109 | 195 | 337 | 568 | 903 | 1,347 |

Points relevant to BOI:
- **The shortage peaks around 1866 and then eases.** States short of infrastructure climb from
  9 at the start to about 49 in 1866. Once railways spread they fall back, to 24 by 1896.
  Vanilla's crunch comes in the first 30 years, which is where BOI's pressure matters most.
- **Transportation is rationed early and relieved late.** World supply covers 12% of demand at
  the start, 34% by 1856, 60% by 1886 and 63% by 1898. The share of transport demand stuck at
  the price ceiling falls from 99% to 71% (1856), 23% (1886) and 13% (1898). The world price
  barely moves, because it's clamped, so use orders and the at-ceiling share to see shortage.
- **Standard of living falls for the first 20 years, then rises.** It goes 9.0 (1836) → 8.2
  (1846–1856) → 9.05 (1886). Most of that is China, which holds about a third of the world's
  people.
- Unemployment grows about 7-fold by 1886 (7.3 M → 50 M).

## New in this baseline (telemetry version 3)

**Copper** is a new 1.15 good. Its world price stays near 34–40 (base 40). Mines grow from 12
levels (1837) to 41 (1886) and 148 (1926, one game). Britain owns the most mines in 1886,
followed by Prussia and Russia. Buy and sell orders are flat until 1876 (about 280 bought),
then grow about 60% per decade: 439 in 1886 and 748 in 1896.

**Standard of living by class**, weighted by state population:

| | 1837 | 1846 | 1866 | 1886 | 1906 | 1926 |
|---|--:|--:|--:|--:|--:|--:|
| Poor | 8.2 | 7.7 | 7.8 | 8.3 | 8.9 | 11.3 |
| Middle | 17.2 | 17.1 | 17.1 | 17.2 | 18.1 | 19.9 |
| Rich | 35.8 | 36.2 | 36.5 | 38.8 | 42.7 | 47.1 |

The early fall in living standards is entirely among the poor. The middle class is flat until
1900, and the rich gain throughout.

**Pollution** is generated about 30 times faster by 1886 than in 1837 (6,100 → 195,000). The worst-hit states in
1886 are Yorkshire, Lancashire, the Midlands, Wallonia, the Home Counties and East Anglia, with
an impact of 0.29–0.52. The world average impact is still only 0.04 in 1886 and 0.20 in 1926.

## Planning a BOI comparison

The reports' "Noise and power" sections give the smallest difference a BOI-vs-vanilla comparison
could detect.
- **At 1846, with 10 games per side:** 1–3% for GDP, standard of living, infrastructure usage,
  urban centres and ranches. 7–8% for unemployment, construction and gold. 13–15% for states
  short of infrastructure and railways.
- **At 1856:** it's 3–5% for the first group. Railways and deficit states need 9–35%.
- **At 1886, with 5 games:** 3–15% for the first group, but 19–65% for unemployment,
  construction and gold, and 22–52% for railways and deficit states. A 50-year comparison needs
  many more games, which is hard while long games crash this often.
- **Wars** can't be tested at any length; the threshold is above 85%.

Suggested design: compare BOI and vanilla at 1846 and 1856, with at least 10 games each. Use the
longer games only to read trends. BOI must be patched for 1.15 first (`PATCHING.md`).

## Data caveats

- Five of the 13 games crashed and are included only up to their last complete snapshot.
- One crashed game, the 1899 one, used snapshot version 4. It has no January 1836 snapshot; its
  first is April 1836.
- Everything from 1906 on is one game, so read it as an example, not a typical case.
- p-values are from Welch's t-test, two-sided, with no correction for testing many metrics.
