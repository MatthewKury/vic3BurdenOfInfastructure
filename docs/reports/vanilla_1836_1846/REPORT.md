# Ensemble report: vanilla_1836_1846

Generated 2026-10-31 by `tools/ensembles/Make-EnsembleReport.py` from `tools/ensembles/ensembles.sqlite`. 10 members, 1836-01-02 to 1846-01-01, quarterly; game 1.13.11.

Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; shown as % of the mean.

## Key findings

- World GDP grows +44.2% over 10 years (member spread 1.7% cv), but pop-weighted SoL falls 9.05 → 8.41 and unemployment goes ×2.8 (7.17 M → 20.3 M): the decade gets richer in total and poorer per head.
- With 10 vs 10 members the minimum detectable effect is 1%–3% for world GDP, SoL, infrastructure usage, urban centers and ranches; 7%–8% for unemployment, construction and gold; 13%–15% for deficit states and railways. Wars are untestable (MDE 88%). Clamped prices (transport) look precise only because they can't move.
- 3/10 members (#2, #6, #9) hit a European revolution wave (22, 23, 23 civil-war splits vs a median of 7; 39 vs 20 countries gone). It shifts economic world totals by at most 1.6%, but country counts, radicals and gold by 4%–8%: a mod that changes the odds of a wave moves those through that alone.
- Power trajectories differ a lot in predictability: GDP cv at the end is lowest for RUS, CHI, SPA, JAP and highest for PAN, AUS, USA, PRU. The GDP top five is the same set of countries in 9/10 members, and in exactly the order CHI > GBR > RUS > FRA > USA in 8/10.
- Infrastructure is slack in aggregate (world utilization 36% → 42%) but shortages spread: states with usage > supply go 9 → 27.1 (cv 9.6%). Railways grow 18 → 91.4 levels with ~11% spread, the noisiest infrastructure metric.
- Industrialisation squeezes inputs: the biggest world price rises are engines +71%, iron +46%, clippers +42%, glass +41%, artillery +39%; plantation goods glut (sugar -39%, tea -39%, coffee -29%, dye -21%).
- Transportation is the standout shortage good for BOI: world supply covers only 14% of demand at the start and 22% at the end, and 99% → 89% of transport demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; watch orders and the at-ceiling share instead.

Contents: [Setup](#setup) · [World](#world) · [Noise and power](#noise-and-power) · [Great powers](#great-powers) · [Geopolitics](#geopolitics) · [Infrastructure](#infrastructure) · [Markets](#markets) · [Construction and urbanization](#construction-and-urbanization) · [Fiscal](#fiscal) · [BOI cheat-sheet](#boi-cheat-sheet) · [Appendix](#appendix)

## Setup

**vanilla: `vanilla_1836_1846`** (control). Vanilla Victoria 3 1.13.11 with all installed DLC and no mods (test-only telemetry only): observer -handsoff games from the 1836.1.1 bookmark to 1846.1.15, one snapshot per quarter.

| item | value |
|:--|--:|
| members | 10 |
| snapshots per member | 41–41 of 41 (none dropped) |
| minutes per member | 11.3–12.1 (total 1.9 h) |
| game version | 1.13.11 |
| DLC installed / disabled | 17 / 0 |
| mods | none (telemetry only) |
| telemetry modules | core, ensemble |

Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the second country under a tag in a member is labelled `TAG#2` (see `run_country`).

## World

![World trajectories](figures/world.svg)

| metric | 1836-01 | 1846-01 mean | growth | sd | cv | MDE (n=10 vs 10) |
|:--|--:|--:|--:|--:|--:|--:|
| GDP (world) | 367 M | 529 M | +44.2% | 8.79 M | 1.7% | 2.2% |
| Population | 994 M | 1.11 B | +11.7% | 4.99 M | 0.4% | 0.6% |
| Standard of living (pop-weighted) | 9.05 | 8.41 | -7.2% | 0.181 | 2.2% | 2.9% |
| Literacy (pop-weighted) | 20.7% | 28.4% | – | 0.9% | 3.3% | 4.4% |
| Unemployed working adults | 7.17 M | 20.3 M | +183.7% | 1.07 M | 5.3% | 7.0% |
| Urbanization (points) | 84.4 k | 103 k | +21.8% | 746 | 0.7% | 1.0% |
| Countries alive | 285 | 270 | -5.1% | 8.63 | 3.2% | 4.2% |
| Wage (pop-weighted, /yr) | 0.588 | 0.643 | +9.4% | 0.016 | 2.5% | 3.3% |
| Radicals | 14.6 M | 104 M | +614.4% | 10.5 M | 10.1% | 13.4% |
| Loyalists | 0 | 27.2 M | – | 6.89 M | 25.3% | 33.5% |
| State turmoil (pop-weighted) | 1.5% | 9.4% | – | 1.0% | 10.4% | 13.7% |

CHI averages 36% of world population, so pop-weighted world SoL largely tracks it. The biggest one-quarter jump in any member (member 3, 1839-04 → 1839-07: 8.86 → 8.39) is CHI's SoL going 8.31 → 7.08. Compare SoL per country, or the powers' SoL panels, when testing welfare effects.

GDP rises +25.7% in the first half and +14.7% in the second (front-loaded). Population is nearly deterministic (cv 0.4%); welfare measures (SoL, unemployment, wage) carry 2–5% noise.

## Noise and power

![cv over time](figures/noise_cv.svg)

*Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, railways near 10%.*

![MDE by metric](figures/noise_mde.svg)

| metric | cv | MDE n=10 | n for 1% | n for 2% | n for 5% | n for 10% |
|:--|--:|--:|--:|--:|--:|--:|
| Population | 0.4% | 0.6% | 5 | 3 | 3 | 3 |
| Transportation price (clamped) | 0.6% | 0.8% | 8 | 3 | 3 | 3 |
| Port levels | 0.7% | 0.9% | 8 | 3 | 3 | 3 |
| Urban center levels | 1.1% | 1.4% | 19 | 6 | 3 | 3 |
| Infra utilization | 1.1% | 1.4% | 20 | 6 | 3 | 3 |
| Infrastructure usage | 1.1% | 1.4% | 20 | 6 | 3 | 3 |
| Infrastructure supply | 1.3% | 1.7% | 27 | 8 | 3 | 3 |
| Livestock ranch levels | 1.3% | 1.7% | 29 | 8 | 3 | 3 |
| World GDP | 1.7% | 2.2% | 45 | 12 | 4 | 3 |
| Govt income | 1.9% | 2.5% | 56 | 15 | 4 | 3 |
| SoL | 2.2% | 2.9% | 75 | 20 | 5 | 3 |
| Tools price | 2.5% | 3.2% | 96 | 25 | 5 | 3 |
| Wage | 2.5% | 3.3% | 98 | 26 | 6 | 3 |
| Grain price | 2.9% | 3.9% | 137 | 35 | 7 | 3 |
| Literacy | 3.3% | 4.4% | 173 | 44 | 8 | 4 |
| Countries in debt | 4.2% | 5.6% | 280 | 71 | 13 | 4 |
| Govt expenses | 4.9% | 6.5% | 378 | 96 | 17 | 5 |
| Unemployed | 5.3% | 7.0% | 440 | 111 | 19 | 6 |
| Construction levels | 5.5% | 7.3% | 472 | 119 | 20 | 6 |
| Gold reserves | 6.1% | 8.1% | 589 | 148 | 25 | 7 |
| Deficit states | 9.6% | 12.7% | >1000 | 363 | 59 | 16 |
| Radicals | 10.1% | 13.4% | >1000 | 400 | 65 | 17 |
| Railway levels | 11.0% | 14.5% | >1000 | 475 | 77 | 20 |
| Countries at war | 66.3% | 87.8% | >1000 | >1000 | >1000 | 691 |

n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), assuming the mod leaves the spread unchanged.

### Regimes: revolution waves

![Revolution-wave members](figures/regimes.svg)

Members 2, 6, 9 each produced 22+ civil-war countries (median member: 7). 80% of their splits start between 1838-04 and 1844-04 (see Geopolitics for which tags). How the wave shifts world metrics at 1846-01:

| metric | other members | wave members | wave vs other |
|:--|--:|--:|--:|
| World GDP | 531 M | 524 M | -1.3% |
| SoL | 8.42 | 8.37 | -0.6% |
| Unemployed | 20.4 M | 20.1 M | -1.6% |
| Countries alive | 275 | 261 | -5.1% |
| Railway levels | 92.6 | 88.7 | -4.2% |
| Construction levels | 588 | 590 | +0.3% |
| Infrastructure usage | 12.4 k | 12.2 k | -1.1% |
| Gold | 66.5 M | 64.1 M | -3.7% |
| Radicals | 102 M | 110 M | +7.9% |

## Great powers

The 16 countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP at 1846-01. Independent y-axes.

![GDP by power](figures/powers_gdp.svg)

![SoL by power](figures/powers_sol.svg)

![GDP rank distribution](figures/powers_rank.svg)

| power | GDP (median) | growth | GDP cv | SoL | railways | techs | time at war | great power at end |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|
| CHI | 103 M | +20.6% | 4.2% | 7.16 | 0 | 31 | 4% | 0/10 |
| GBR | 35.2 M | +41.6% | 6.9% | 10.8 | 31 | 60 | 36% | 10/10 |
| RUS | 32.3 M | +40.8% | 3.4% | 8.3 | 0 | 42 | 15% | 10/10 |
| FRA | 26.7 M | +25.5% | 6.0% | 10.8 | 11.5 | 58 | 17% | 10/10 |
| USA | 21.1 M | +37.6% | 21.1% | 11.2 | 9 | 59 | 15% | 9/10 |
| PRU | 13.6 M | +41.9% | 15.6% | 10.2 | 7.5 | 59 | 5% | 10/10 |
| JAP | 13.3 M | +25.2% | 6.0% | 9.09 | 0 | 36 | 1% | 0/10 |
| AUS | 12.2 M | +24.3% | 24.3% | 8.64 | 7 | 52.5 | 7% | 8/10 |
| TUR | 11 M | +8.7% | 12.9% | 7.6 | 0 | 32 | 16% | 9/10 |
| SPA | 9.67 M | +48.7% | 4.2% | 9.87 | 0 | 44 | 40% | 10/10 |
| BRZ | 7.24 M | +77.8% | 9.3% | 9.01 | 0 | 40.5 | 10% | 0/10 |
| PER | 4.56 M | +62.0% | 11.7% | 7.47 | 0 | 28 | 8% | 0/10 |
| SWE | 3.45 M | +62.8% | 8.6% | 10.7 | 3 | 54 | 1% | 0/10 |
| NET | 3.36 M | +48.0% | 7.1% | 10.7 | 0 | 53.5 | 2% | 0/10 |
| SIA | 1.49 M | +33.1% | 14.6% | 8.9 | 0 | 27.5 | 7% | 0/10 |
| PAN | 1.22 M | -59.6% | 83.6% | 9.83 | 0 | 30 | 5% | 0/10 |

## Geopolitics

![Conflict and politics](figures/conflict.svg)

Countries at war swings between 0 and 57 at any snapshot; the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.

| event | countries (members out of 10) |
|:--|--:|
| annexed/gone in every member | FZN, LAD, PRA, SPC |
| gone in at least half | PNI (9), BTN (7), IQU (7), KAF (7), KZH (7), OZH (7), SPU (7), TEX (7), UZH (7), KAS (6), KOT (6), WLT (6), SEL (5) |
| formed (new tag) during the run | ALT (10), COS (10), GUA (10), HON (10), NAL (10), NIC (10), DOM (9), BUL (5), SLV (3), D00 (2), GAL (2), KPR (2), LIM (2), LOM (2), VEN (2), CSA (1), D01 (1) |
| civil-war split (TAG#n) | PER (9), SAS (8), WLT (7), BCE (6), AGC (4), ALT (4), QUE (4), AUS (3), CRO (3), HEK (3), MEC (3), MST (3), SWE (3), ANH (2), BTN (2), DEN (2), FIN (2), FRA (2), HAN (2), HUN (2), LAH (2), LUX (2), OLD (2), SAR (2), SUL (2), BAD (1), BAV (1), BEL (1), BNJ (1), BRA (1), BRE (1), COS (1), D00 (1), GBR (1), HOL (1), JAP (1), KAF (1), KAS (1), LAN (1), LIB (1), LOM (1), MEI (1), NET (1), ONT (1), SAX (1), SEL (1), SIN (1), VEN (1), WAS (1) |

Civil wars that happen in at least 80% of members are background: PER, SAS. Splits seen only in revolution-wave members: AUS, CRO, HEK, MEC, MST, SWE, ANH, DEN, FIN, HAN, HUN, LUX, OLD, SAR, BAD, BAV, BEL, BRA, BRE, D00, GBR, HOL, KAF, LIB, LOM, MEI, NET, ONT, SAX, SIN, VEN, WAS.

## Infrastructure

![Infrastructure](figures/infrastructure.svg)

![State infrastructure scatter](figures/states_scatter.svg)

*States with zero usage sit on the bottom edge (log scale).*

![State utilization distribution](figures/states_utilization.svg)

States short of infrastructure in at least half the members at 1846-01 (20 states; median values across members):

| state | owner | short in | supply | usage | shortfall | population |
|:--|--:|--:|--:|--:|--:|--:|
| Bahia | BRZ | 10/10 | 33.2 | 36 | 2.75 | 787 k |
| Minas Gerais | BRZ | 10/10 | 26.9 | 27.7 | 0.8 | 796 k |
| Eastern Himalayas | BHU | 10/10 | 10.8 | 11.5 | 0.7 | 187 k |
| Potosí | BOL | 9/10 | 8.65 | 10.5 | 1.85 | 152 k |
| Transvaal | SWZ | 9/10 | 5.9 | 7.6 | 1.7 | 97.9 k |
| Yemen | MAH | 9/10 | 5.5 | 6.7 | 1.2 | 38.5 k |
| Dagestan | RUS | 9/10 | 4.75 | 5.6 | 0.85 | 105 k |
| Pernambuco | BRZ | 9/10 | 28.9 | 29.6 | 0.8 | 735 k |
| South Australia | KAU | 9/10 | 4.1 | 4.4 | 0.3 | 59.9 k |
| Mocambique | AGC | 8/10 | 4 | 5 | 1 | 14 k |
| Paraíba | BRZ | 8/10 | 9.2 | 9.8 | 0.6 | 205 k |
| Moscow | RUS | 8/10 | 63.7 | 64 | 0.35 | 1.36 M |
| Yemen | KAT | 8/10 | 6 | 6.2 | 0.2 | 50.3 k |
| Zululand | NAL | 7/10 | 6.35 | 7.8 | 1.45 | 53.7 k |
| Sakhalin | ALK | 7/10 | 2.2 | 3.3 | 1.1 | 1.07 k |
| Transorangia | PHL | 7/10 | 5 | 5.2 | 0.2 | 37.8 k |
| Ceará | BRZ | 7/10 | 10.5 | 10.7 | 0.15 | 247 k |
| Hazaristan | HER | 6/9 | 5.2 | 5.4 | 0.2 | 44.1 k |
| Malwa | IND | 5/10 | 22.9 | 23.1 | 0.25 | 605 k |
| Bosnia | TUR | 5/10 | 26.1 | 25.4 | -0.7 | 766 k |

Market access is uninformative in vanilla: pop-weighted world market access stays at 99.8% (cv 0.09%). Deficits in vanilla don't yet cut states off; BOI changing that would show up here immediately.

![Railways per power](figures/railways_powers.svg)

## Markets

World prices are demand-weighted averages over markets (`world_goods`). Index = price / base price; the engine clamps market prices to base × (1 ± 0.75), i.e. index 0.25–1.75.

![Price change by goods](figures/price_change.svg)

*Red = dearer, blue = cheaper. Goods with negligible world demand are omitted.*

![Price index by goods](figures/price_index.svg)

![Share of demand at price ceiling](figures/price_cap.svg)

*Share of each good's world demand in markets whose price is at the ceiling (1.75 × base). Independent y-axes.*

A market at the ceiling can't signal a worse shortage through price, so for transport-heavy changes watch this share and the buy/sell orders, not the world price.

![Price dispersion across markets](figures/price_dispersion.svg)

Top 30 goods by world demand at the end:

| goods | price 1836-01 | price 1846-01 | change | price cv | demand/wk | supply/demand | demand at ceiling |
|:--|--:|--:|--:|--:|--:|--:|--:|
| grain | 16.1 | 16.2 | +0.9% | 2.9% | 69.8 k | 1.25 | 0% |
| wood | 20.6 | 22.7 | +10.0% | 2.4% | 54.7 k | 0.89 | 5% |
| fabric | 17.1 | 14.4 | -15.6% | 4.1% | 34.6 k | 1.40 | 0% |
| services | 19 | 23.9 | +25.6% | 1.2% | 31.5 k | 1.28 | 0% |
| clothes | 33.6 | 35.3 | +4.8% | 2.0% | 29.7 k | 0.84 | 3% |
| furniture | 32.2 | 36.1 | +12.2% | 1.1% | 24.1 k | 0.83 | 5% |
| fruit | 41.5 | 33.9 | -18.3% | 2.0% | 24 k | 0.89 | 0% |
| transportation | 52.4 | 51.7 | -1.2% | 0.6% | 20.6 k | 0.22 | 89% |
| meat | 43.5 | 36.4 | -16.4% | 1.2% | 17.1 k | 0.83 | 12% |
| paper | 34.4 | 42.4 | +23.1% | 2.1% | 14.4 k | 0.66 | 5% |
| liquor | 27.8 | 27.4 | -1.3% | 4.7% | 13.9 k | 1.15 | 4% |
| fish | 19.5 | 18.2 | -6.3% | 2.4% | 12.9 k | 1.12 | 0% |
| tools | 40.5 | 53.1 | +31.3% | 2.5% | 11.9 k | 0.72 | 3% |
| tea | 56.7 | 34.7 | -38.9% | 5.5% | 11.3 k | 1.48 | 2% |
| tobacco | 38.4 | 31.7 | -17.6% | 3.1% | 10.6 k | 1.31 | 0% |
| iron | 40.1 | 58.7 | +46.2% | 3.9% | 9.95 k | 0.61 | 17% |
| opium | 58 | 55.9 | -3.7% | 4.8% | 8.58 k | 0.99 | 22% |
| luxury_clothes | 61.6 | 74.8 | +21.5% | 2.8% | 7.58 k | 0.83 | 16% |
| groceries | 45.5 | 40.2 | -11.6% | 2.7% | 7.11 k | 0.70 | 0% |
| sugar | 37.1 | 22.6 | -39.0% | 6.9% | 7.1 k | 1.40 | 6% |
| coal | 28 | 32.8 | +17.1% | 3.2% | 6.91 k | 0.90 | 0% |
| silk | 44.8 | 41.3 | -7.8% | 1.9% | 5.95 k | 0.98 | 6% |
| hardwood | 47.9 | 50 | +4.5% | 3.7% | 5.75 k | 0.82 | 2% |
| clippers | 40.8 | 57.9 | +41.9% | 2.7% | 4.8 k | 1.08 | 4% |
| small_arms | 69.7 | 72.3 | +3.8% | 8.3% | 4.6 k | 0.83 | 11% |
| luxury_furniture | 65.2 | 78 | +19.8% | 1.9% | 4.02 k | 0.70 | 24% |
| coffee | 59.9 | 42.5 | -29.1% | 3.6% | 3.84 k | 1.27 | 1% |
| wine | 36.4 | 30.4 | -16.5% | 13.4% | 3.79 k | 1.56 | 0% |
| dye | 19.4 | 15.3 | -21.2% | 6.5% | 2.72 k | 3.28 | 0% |
| merchant_marine | 42.3 | 45.9 | +8.5% | 5.1% | 2.56 k | 1.18 | 0% |

## Construction and urbanization

Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes for it, and ranching (horses come from livestock).

![Construction and urbanization](figures/construction.svg)

| metric | 1836-01 | 1846-01 mean | growth | sd | cv | MDE (n=10 vs 10) |
|:--|--:|--:|--:|--:|--:|--:|
| Construction sector levels | 83 | 588 | +609.0% | 32.2 | 5.5% | 7.3% |
| Urban center levels | 601 | 811 | +34.9% | 8.62 | 1.1% | 1.4% |
| Non-subsistence building levels | 44.6 k | 50.7 k | +13.6% | 403 | 0.8% | 1.1% |
| Light industry levels | 1.01 k | 1.08 k | +7.7% | 17.1 | 1.6% | 2.1% |
| Heavy industry levels | 34 | 52.6 | +54.7% | 4.4 | 8.4% | 11.1% |
| Livestock ranch levels | 502 | 702 | +39.8% | 9.21 | 1.3% | 1.7% |
| Urbanization (points) | 84.4 k | 103 k | +21.8% | 746 | 0.7% | 1.0% |

## Fiscal

![Fiscal](figures/fiscal.svg)

| metric | 1836-01 | 1846-01 mean | growth | sd | cv | MDE (n=10 vs 10) |
|:--|--:|--:|--:|--:|--:|--:|
| Gold reserves | 16.1 M | 65.8 M | +307.9% | 4.02 M | 6.1% | 8.1% |
| Countries in debt | 15 | 99.6 | +564.0% | 4.2 | 4.2% | 5.6% |
| Income /wk | 1.76 M | 3.16 M | +79.8% | 58.8 k | 1.9% | 2.5% |
| Expenses /wk | 1.57 M | 3.19 M | +103.3% | 156 k | 4.9% | 6.5% |
| Net income /wk | 191 k | -24.6 k | -112.9% | 117 k | – | – |

World net government income goes 191 k → -24.6 k per week: spending outgrows revenue, which is the headroom BOI's road financing competes for.

## BOI cheat-sheet

Values at 1846-01. Compare a BOI ensemble's mean against these; a difference smaller than the MDE is indistinguishable from vanilla noise with 10 members per arm.

| metric | mean | sd | cv | MDE (n=10) | n for 2% | n for 5% |
|:--|--:|--:|--:|--:|--:|--:|
| World GDP | 529 M | 8.79 M | 1.7% | 2.2% | 12 | 4 |
| SoL | 8.41 | 0.181 | 2.2% | 2.9% | 20 | 5 |
| Unemployed | 20.3 M | 1.07 M | 5.3% | 7.0% | 111 | 19 |
| Wage | 0.643 | 0.016 | 2.5% | 3.3% | 26 | 6 |
| Infrastructure supply | 29.7 k | 382 | 1.3% | 1.7% | 8 | 3 |
| Infrastructure usage | 12.3 k | 135 | 1.1% | 1.4% | 6 | 3 |
| Utilization | 41.6% | 0.4% | 1.1% | 1.4% | 6 | 3 |
| Deficit states | 27.1 | 2.6 | 9.6% | 12.7% | 363 | 59 |
| Railway levels | 91.4 | 10 | 11.0% | 14.5% | 475 | 77 |
| Port levels | 376 | 2.45 | 0.7% | 0.9% | 3 | 3 |
| Construction levels | 588 | 32.2 | 5.5% | 7.3% | 119 | 20 |
| Urban center levels | 811 | 8.62 | 1.1% | 1.4% | 6 | 3 |
| Livestock ranch levels | 702 | 9.21 | 1.3% | 1.7% | 8 | 3 |
| Gold reserves | 65.8 M | 4.02 M | 6.1% | 8.1% | 148 | 25 |
| Countries in debt | 99.6 | 4.2 | 4.2% | 5.6% | 71 | 13 |
| Govt expenses | 3.19 M | 156 k | 4.9% | 6.5% | 96 | 17 |
| Transportation price | 51.7 | 0.327 | 0.6% | 0.8% | 3 | 3 |
| Transport demand at ceiling | 89.4% | 2.2% | 2.4% | 3.2% | 24 | 5 |
| Transportation demand | 20.6 k | 463 | 2.2% | 3.0% | 21 | 5 |
| Merchant marine price | 45.9 | 2.34 | 5.1% | 6.8% | 104 | 18 |
| Services price | 23.9 | 0.275 | 1.2% | 1.5% | 7 | 3 |
| Wood price | 22.7 | 0.552 | 2.4% | 3.2% | 25 | 5 |
| Grain price | 16.2 | 0.477 | 2.9% | 3.9% | 35 | 7 |
| Groceries price | 40.2 | 1.08 | 2.7% | 3.6% | 30 | 6 |
| Tools price | 53.1 | 1.3 | 2.5% | 3.2% | 25 | 5 |

## Appendix

- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. It reads only the database.
- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same day; `t` counts quarters from 1836-01.
- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, wage, market access and turmoil. World goods: summed orders, demand-weighted price.
- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.
- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance of a wave changes means through that alone.
- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.

