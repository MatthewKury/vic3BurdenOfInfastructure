# Ensemble report: vanilla115_1836_1936_all

Generated 2026-11-05 by `tools/ensembles/Make-EnsembleReport.py` from `tools/ensembles/ensembles.sqlite`. 5 members, 1836-01-02 to 1886-01-01, quarterly; game 1.15.0.

Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; shown as % of the mean.

## Key findings

- World GDP grows +263.7% over 50 years (member spread 6.0% cv); pop-weighted SoL rises 9.02 → 9.05 and unemployment goes ×6.8 (7.33 M → 50 M).
- With 5 vs 5 members the minimum detectable effect is 3%–15% for world GDP, SoL, infrastructure usage, urban centers and ranches; 19%–65% for unemployment, construction and gold; 22%–52% for deficit states and railways. Wars are untestable (MDE 150%). Clamped prices (transport) look precise only because they can't move.
- Power trajectories differ a lot in predictability: GDP cv at the end is lowest for RUS, GBR, BRZ, CHI and highest for AUS, NET, TUR, FRA. The GDP top five is the same set of countries in 1/5 members, and in exactly the order CHI > GBR > RUS > USA > SPA in 1/5.
- Infrastructure is slack in aggregate (world utilization 36% → 44%) but shortages spread: states with usage > supply go 8.25 → 34 (cv 25.6%). Railways grow 18 → 995 levels with ~11% spread, the noisiest infrastructure metric.
- Industrialisation squeezes inputs: the biggest world price rises are glass +127%, engines +73%, ammunition +45%, dye +42%, lead +39%; plantation goods glut (tea -51%, sugar -42%, coffee -41%, fruit -32%).
- Transportation is the standout shortage good for BOI: world supply covers only 12% of demand at the start and 60% at the end, and 99% → 23% of transport demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; watch orders and the at-ceiling share instead.

Contents: [Setup](#setup) · [World](#world) · [Noise and power](#noise-and-power) · [Great powers](#great-powers) · [Geopolitics](#geopolitics) · [Infrastructure](#infrastructure) · [Markets](#markets) · [Construction and urbanization](#construction-and-urbanization) · [Fiscal](#fiscal) · [BOI cheat-sheet](#boi-cheat-sheet) · [Appendix](#appendix)

## Setup

**vanilla: `vanilla115_1836_1936_all`** (control). Every 1.15.0 game of the vanilla115_1836_1936 batch, including the 5 that crashed (in 1872, 1896, 1928, 1886 and 1899), each up to its last complete snapshot. Four crashes hit the same address in the snapshot's state loop and look unrelated to how the game develops, so the partial games add members past 1886. The 1899 game uses snapshot version 4, which starts in April 1836.

| item | value |
|:--|--:|
| members | 5 |
| snapshots per member | 201–201 of 201 (none dropped) |
| minutes per member | 58.5–142.2 (total 7.0 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | none (telemetry only) |
| telemetry modules | core, parity, ensemble |

Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the second country under a tag in a member is labelled `TAG#2` (see `run_country`).

## World

![World trajectories](figures/world.svg)

| metric | 1836-01 | 1886-01 mean | growth | sd | cv | MDE (n=5 vs 5) |
|:--|--:|--:|--:|--:|--:|--:|
| GDP (world) | 363 M | 1.32 B | +263.7% | 78.8 M | 6.0% | 12.0% |
| Population | 993 M | 1.45 B | +45.8% | 17 M | 1.2% | 2.4% |
| Standard of living (pop-weighted) | 9.02 | 9.05 | +0.3% | 0.135 | 1.5% | 3.0% |
| Literacy (pop-weighted) | 20.8% | 38.4% | – | 2.1% | 5.6% | 11.3% |
| Unemployed working adults | 7.33 M | 50 M | +582.3% | 4.75 M | 9.5% | 19.2% |
| Urbanization (points) | 84.1 k | 302 k | +259.1% | 19.2 k | 6.4% | 12.9% |
| Countries alive | 291 | 197 | -32.4% | 10.4 | 5.3% | 10.6% |
| Wage (pop-weighted, /yr) | 0.434 | 1.35 | +211.5% | 0.134 | 9.9% | 20.0% |
| Radicals | 14.5 M | 171 M | +1079.8% | 11.3 M | 6.6% | 13.3% |
| Loyalists | 0 | 43.9 M | – | 3.64 M | 8.3% | 16.8% |
| State turmoil (pop-weighted) | 1.5% | 11.8% | – | 0.8% | 6.7% | 13.6% |

CHI averages 33% of world population, so pop-weighted world SoL largely tracks it. The biggest one-quarter jump in any member (member 9, 1860-01 → 1860-04: 7.55 → 8.19) is CHI's SoL going 5.31 → 7.52. Compare SoL per country, or the powers' SoL panels, when testing welfare effects.

GDP rises +109.3% in the first half and +73.7% in the second. Population is nearly deterministic (cv 1.2%); welfare measures (SoL, unemployment, wage) carry 2–5% noise.

## Noise and power

![cv over time](figures/noise_cv.svg)

*Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, railways near 10%.*

![MDE by metric](figures/noise_mde.svg)

| metric | cv | MDE n=5 | n for 1% | n for 2% | n for 5% | n for 10% |
|:--|--:|--:|--:|--:|--:|--:|
| Population | 1.2% | 2.4% | 23 | 7 | 3 | 3 |
| SoL | 1.5% | 3.0% | 37 | 10 | 3 | 3 |
| Infra utilization | 3.7% | 7.6% | 222 | 57 | 10 | 4 |
| Transportation price (clamped) | 4.1% | 8.4% | 270 | 69 | 12 | 4 |
| Tools price | 4.6% | 9.3% | 333 | 84 | 15 | 5 |
| Grain price | 5.6% | 11.3% | 492 | 124 | 21 | 7 |
| Literacy | 5.6% | 11.3% | 493 | 124 | 21 | 7 |
| Infrastructure supply | 5.7% | 11.5% | 506 | 128 | 22 | 7 |
| Infrastructure usage | 5.7% | 11.6% | 518 | 131 | 22 | 7 |
| World GDP | 6.0% | 12.0% | 560 | 141 | 24 | 7 |
| Livestock ranch levels | 6.3% | 12.6% | 615 | 155 | 26 | 8 |
| Radicals | 6.6% | 13.3% | 685 | 172 | 29 | 8 |
| Govt income | 7.2% | 14.5% | 805 | 202 | 34 | 10 |
| Urban center levels | 7.6% | 15.4% | 909 | 228 | 38 | 11 |
| Port levels | 9.1% | 18.3% | >1000 | 324 | 53 | 14 |
| Govt expenses | 9.2% | 18.6% | >1000 | 335 | 55 | 15 |
| Unemployed | 9.5% | 19.2% | >1000 | 355 | 58 | 16 |
| Wage | 9.9% | 20.0% | >1000 | 386 | 63 | 17 |
| Construction levels | 10.0% | 20.2% | >1000 | 395 | 64 | 17 |
| Railway levels | 10.8% | 21.8% | >1000 | 460 | 75 | 20 |
| Countries in debt | 24.6% | 49.7% | >1000 | >1000 | 381 | 96 |
| Deficit states | 25.6% | 51.6% | >1000 | >1000 | 412 | 104 |
| Gold reserves | 32.2% | 65.1% | >1000 | >1000 | 652 | 164 |
| Countries at war | 74.3% | 150.1% | >1000 | >1000 | >1000 | 868 |

n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), assuming the mod leaves the spread unchanged.

### Regimes: revolution waves

![Revolution-wave members](figures/regimes.svg)

## Great powers

The 17 countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP at 1886-01. Independent y-axes.

![GDP by power](figures/powers_gdp.svg)

![SoL by power](figures/powers_sol.svg)

![GDP rank distribution](figures/powers_rank.svg)

| power | GDP (median) | growth | GDP cv | SoL | railways | techs | time at war | great power at end |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|
| CHI | 167 M | +97.1% | 16.7% | 6.7 | 104 | 64 | 11% | 0/5 |
| GBR | 139 M | +464.5% | 12.9% | 14.9 | 109 | 114 | 48% | 5/5 |
| USA | 76.7 M | +394.1% | 26.3% | 12.2 | 71 | 112 | 9% | 5/5 |
| PRU | 69.7 M | +637.8% | 20.4% | 11.4 | 73 | 106 | 18% | 3/5 |
| RUS | 63.2 M | +185.9% | 10.9% | 9.98 | 20 | 84 | 33% | 5/5 |
| FRA | 52.9 M | +157.0% | 37.3% | 11 | 49 | 99 | 23% | 3/5 |
| SPA | 42.6 M | +576.0% | 20.2% | 11.9 | 27 | 92 | 16% | 4/5 |
| AUS | 35.4 M | +268.5% | 74.5% | 9.98 | 33 | 98 | 16% | 1/5 |
| PAN | 27.7 M | +821.2% | 0.0% | 10 | 53 | 77 | 12% | 0/5 |
| TUR | 27.7 M | +172.5% | 43.6% | 9.49 | 21 | 76 | 29% | 2/5 |
| JAP | 20.3 M | +87.9% | 0.0% | 9.4 | 13 | 77 | 8% | 0/5 |
| BRZ | 19.9 M | +349.2% | 16.2% | 10.2 | 17 | 90 | 7% | 0/5 |
| BEL | 17.8 M | +477.9% | 36.8% | 15.4 | 14.5 | 110 | 4% | 0/5 |
| SWE | 14.7 M | +567.6% | 35.4% | 13.4 | 16 | 108 | 7% | 0/5 |
| NET | 11.5 M | +375.7% | 45.5% | 13.6 | 17.5 | 111 | 16% | 1/5 |
| SIC | 11.3 M | +216.0% | 20.7% | 9.99 | 5.5 | 80.5 | 10% | 0/5 |
| SIA | 3.69 M | +237.2% | 26.8% | 7.88 | 0.5 | 62.5 | 12% | 0/5 |

## Geopolitics

![Conflict and politics](figures/conflict.svg)

Countries at war swings between 0 and 78 at any snapshot; the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.

| event | countries (members out of 5) |
|:--|--:|
| annexed/gone in every member | – |
| gone in at least half | – |
| formed (new tag) during the run | GUA (13), HON (13), NAL (13), ALT (12), COS (12), NIC (12), DOM (11), D00 (8), D01 (7), ZAN (7), D02 (6), D03 (6), LIM (6), D04 (5), D05 (5), TPG (5), KPR (4), BHT (3), RSM (3), AGJ (2), ASA (2), BUL (2), CAR (2), D06 (2), D07 (2), D08 (2), D14 (2), D15 (2), D16 (2), GAL (2), LAT (2), LOM (2), SUD (2), UKR (2), VEN (2), ABK (1), ABU (1), ACE (1), AGC (1), AIT (1), ALD (1), ALK (1), ALW (1), ANH (1), ANK (1), ARB (1), ARG (1), ARS (1), ASH (1), ASM (1), ATL (1), AUS (1), AWA (1), AWS (1), AZB (1), BAD (1), BAG (1), BAL (1), BAS (1), BAV (1), BCE (1), BEL (1), BEN (1), BER (1), BGI (1), BGL (1), BGM (1), BHN (1), BHO (1), BHU (1), BHV (1), BHW (1), BIC (1), BIK (1), BKH (1), BLG (1), BLH (1), BNJ (1), BNY (1), BOL (1), BOR (1), BOS (1), BRA (1), BRD (1), BRE (1), BRG (1), BRU (1), BRZ (1), BST (1), BTN (1), BUG (1), BUK (1), BUN (1), BUR (1), BYE (1), CAM (1), CHC (1), CHI (1), CHL (1), CHP (1), CHT (1), CIR (1), CLM (1), CMI (1), COB (1), COC (1), CON (1), COO (1), CRO (1), CUB (1), D09 (1), D10 (1), D11 (1), D12 (1), D13 (1), D17 (1), DAH (1), DAI (1), DEI (1), DEN (1), DFR (1), DHA (1), DIR (1), ECU (1), EGY (1), ELS (1), ETH (1), EZO (1), FIN (1), FRA (1), FRM (1), FTJ (1), FTR (1), FZN (1), GAR (1), GBR (1), GJM (1), GLD (1), GRE (1), GUJ (1), GWA (1), GZA (1), HAI (1), HAM (1), HAN (1), HAR (1), HAU (1), HAW (1), HBC (1), HDJ (1), HDY (1), HEK (1), HER (1), HES (1), HOH (1), HOL (1), HUN (1), HYD (1), IBL (1), IDA (1), IND (1), ION (1), IQU (1), ISQ (1), ITA (1), JAB (1), JAI (1), JAP (1), JAS (1), JEY (1), JHN (1), JMB (1), JOD (1), JOH (1), JUN (1), KAB (1), KAF (1), KAL (1), KAN (1), KAS (1), KAT (1), KAU (1), KAZ (1), KFA (1), KHI (1), KHP (1), KLT (1), KNO (1), KOK (1), KON (1), KOR (1), KOT (1), KRA (1), KRG (1), KRN (1), KRT (1), KTI (1), KUN (1), KUT (1), KZH (1), LAH (1), LAN (1), LAO (1), LIB (1), LIP (1), LIT (1), LUA (1), LUB (1), LUC (1), LUX (1), MAD (1), MAH (1), MAI (1), MAK (1), MAS (1), MBS (1), MEC (1), MEI (1), MEW (1), MEX (1), MGD (1), MJT (1), MKT (1), MLD (1), MNL (1), MNP (1), MOD (1), MOL (1), MON (1), MOR (1), MSN (1), MST (1), MUG (1), MYB (1), MYS (1), NAG (1), NAR (1), NAS (1), NAW (1), NBS (1), NEJ (1), NEP (1), NET (1), NOR (1), NPU (1), NSW (1), NVS (1), OLD (1), OMA (1), ONT (1), ORA (1), ORG (1), OYO (1), OZH (1), PAN (1), PAP (1), PAR (1), PBC (1), PCO (1), PER (1), PEU (1), PHI (1), PHL (1), PLP (1), PLY (1), PNI (1), POL (1), PON (1), POR (1), PRA (1), PRG (1), PRK (1), PRM (1), PRU (1), PTA (1), PTN (1), PUD (1), QUE (1), QWR (1), RAJ (1), ROM (1), RUS (1), RWD (1), RYU (1), SAF (1), SAK (1), SAR (1), SAS (1), SAT (1), SAX (1), SCH (1), SCM (1), SCW (1), SDM (1), SEL (1), SEQ (1), SER (1), SGU (1), SHS (1), SHW (1), SIA (1), SIC (1), SIK (1), SIL (1), SIN (1), SLO (1), SMB (1), SNA (1), SOK (1), SPA (1), SPC (1), SPU (1), SRK (1), STG (1), SUL (1), SUR (1), SVN (1), SWE (1), SWI (1), SWT (1), SWZ (1), TAS (1), TEX (1), TGI (1), TGR (1), TIB (1), TID (1), TJI (1), TKI (1), TRA (1), TRH (1), TRI (1), TRN (1), TRS (1), TUG (1), TUN (1), TUR (1), TUS (1), TWT (1), UBD (1), UCA (1), ULR (1), UNT (1), URU (1), USA (1), UYA (1), UZB (1), UZH (1), VNZ (1), WAD (1), WAL (1), WAS (1), WBL (1), WEI (1), WLD (1), WLG (1), WLT (1), WSG (1), WTU (1), WUR (1), YEM (1), YOG (1), YUG (1), ZAI (1), ZUL (1) |
| civil-war split (TAG#n) | AGC (12), AUS (7), HUN (7), JAP (7), KAT (7), MEC (7), POR (7), QUE (7), SAS (7), SIA (7), WTU (7), ALT (6), BEL (6), GRE (6), HAN (6), LAH (6), NEP (6), NSW (6), PER (6), TGI (6), ACE (5), BCE (5), BHN (5), BRA (5), DAI (5), HAM (5), HES (5), LUA (5), LUX (5), MAH (5), MST (5), NAL (5), NAS (5), ONT (5), PRU (5), SAF (5), SAR (5), SHS (5), SWE (5), WLT (5), ANH (4), BTN (4), FRA (4), HAI (4), KRA (4), KTI (4), MEI (4), NET (4), PAR (4), POL (4), PRK (4), STG (4), SWI (4), UBD (4), ASH (3), BAL (3), BAV (3), BRE (3), BUK (3), CHT (3), CIR (3), COS (3), CRO (3), DEN (3), FIN (3), FTJ (3), FTR (3), HAU (3), HAW (3), HOL (3), JAB (3), KBU (3), LIB (3), MOL (3), MYS (3), OMA (3), PAP (3), PON (3), SAX (3), SER (3), SIN (3), TRI (3), TUN (3), TUR (3), TUS (3), WSG (3), ZUL (3), ABU (2), ALK (2), BAD (2), BEN (2), BOL (2), BRZ (2), BST (2), CAM (2), CAR (2), CMI (2), DEI (2), EGY (2), EWE (2), HAR (2), HEK (2), IND (2), ION (2), JHN (2), JOH (2), KOR (2), KPR (2), MBS (2), MEW (2), NEJ (2), OLD (2), PCO (2), RSM (2), RYU (2), SCH (2), SGU (2), SIC (2), SIL (2), SUL (2), SUR (2), TAS (2), TIB (2), TRN (2), WAS (2), WUR (2), AIN (1), ALW (1), ARB (1), ATB (1), AWA (1), BAG (1), BAS (1), BER (1), BHO (1), BHT (1), BHV (1), BHW (1), BKH (1), BLH (1), BNG (1), BRN (1), BRU (1), BUG (1), BUL (1), BUN (1), BUR (1), CHC (1), CHP (1), COC (1), DAH (1), DHA (1), DIR (1), DLA (1), DOM (1), ECU (1), GAL (1), GUA (1), GZA (1), HBC (1), HDJ (1), HDY (1), HRO (1), IBO (1), IDA (1), ISQ (1), JAI (1), JAS (1), JEY (1), JUN (1), KAL (1), KBA (1), KHI (1), KNK (1), KON (1), KOT (1), KRG (1), KRT (1), LOM (1), MAD (1), MAK (1), MGD (1), MJT (1), MOD (1), MSN (1), MUG (1), MYB (1), NAR (1), NAW (1), NOR (1), OYO (1), PHI (1), PHL (1), PRG (1), PTA (1), PTN (1), RUS (1), RWD (1), SAK (1), SAT (1), SEL (1), SEQ (1), SOK (1), SPA (1), SPC (1), SWT (1), SWZ (1), TID (1), TNG (1), TPG (1), TRA (1), TSW (1), TUA (1), TUG (1), URU (1), UYA (1), VEN (1), VNZ (1), WAL (1), WBL (1), YUG (1), ZAN (1) |

Civil wars that happen in at least 80% of members are background: AGC, AUS, HUN, JAP, KAT, MEC, POR, QUE, SAS, SIA, WTU, ALT, BEL, GRE, HAN, LAH, NEP, NSW, PER, TGI, ACE, BCE, BHN, BRA, DAI, HAM, HES, LUA, LUX, MAH, MST, NAL, NAS, ONT, PRU, SAF, SAR, SHS, SWE, WLT, ANH, BTN, FRA, HAI, KRA, KTI, MEI, NET, PAR, POL, PRK, STG, SWI, UBD. 

## Infrastructure

![Infrastructure](figures/infrastructure.svg)

![State infrastructure scatter](figures/states_scatter.svg)

*States with zero usage sit on the bottom edge (log scale).*

![State utilization distribution](figures/states_utilization.svg)

States short of infrastructure in at least half the members at 1886-01 (12 states; median values across members):

| state | owner | short in | supply | usage | shortfall | population |
|:--|--:|--:|--:|--:|--:|--:|
| Hail | JAB | 4/5 | 6.5 | 7.5 | 1 | 67.5 k |
| Mauritania | FTR | 4/4 | 7.65 | 8.1 | 0.45 | 99.7 k |
| Transvaal | SWZ | 4/4 | 9.15 | 9.45 | 0.3 | 110 k |
| Turkmenia | KHI | 4/5 | 8.3 | 8.5 | 0.2 | 83.3 k |
| Rajputana | JOD | 3/5 | 49.8 | 57.6 | 7.8 | 1.03 M |
| Bundelkhand | SUR | 3/4 | 24.1 | 27.8 | 3.65 | 484 k |
| Yemen | KAT | 3/4 | 8.45 | 11.4 | 2.9 | 83.1 k |
| Mocambique | AGC | 3/4 | 3.7 | 5.65 | 1.95 | 1.26 k |
| Senegal | FTR | 3/4 | 9.65 | 10.9 | 1.3 | 133 k |
| Eastern Himalayas | SIK | 3/4 | 8.55 | 9.35 | 0.8 | 110 k |
| Central Java | YOG | 3/5 | 6.1 | 6.8 | 0.7 | 57.4 k |
| Waddai | BGI | 3/4 | 11.2 | 11.6 | 0.4 | 165 k |

Market access is uninformative in vanilla: pop-weighted world market access stays at 99.0% (cv 1.26%). Deficits in vanilla don't yet cut states off; BOI changing that would show up here immediately.

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

| goods | price 1836-01 | price 1886-01 | change | price cv | demand/wk | supply/demand | demand at ceiling |
|:--|--:|--:|--:|--:|--:|--:|--:|
| wood | 20.8 | 20.4 | -2.3% | 4.6% | 118 k | 1.01 | 1% |
| grain | 15.8 | 19.7 | +24.6% | 5.6% | 94.6 k | 1.03 | 0% |
| coal | 30.2 | 33.3 | +10.0% | 8.6% | 94.1 k | 0.92 | 0% |
| tools | 39.5 | 45.4 | +15.2% | 4.6% | 83.6 k | 0.87 | 1% |
| fabric | 16.6 | 14.8 | -10.6% | 5.1% | 79.4 k | 1.36 | 0% |
| services | 19.6 | 26.5 | +35.0% | 2.4% | 71.9 k | 1.16 | 0% |
| clothes | 32.2 | 32.1 | -0.6% | 1.1% | 68.6 k | 0.96 | 1% |
| transportation | 52.4 | 44.1 | -15.8% | 4.1% | 68.3 k | 0.60 | 23% |
| fruit | 41.8 | 28.3 | -32.3% | 3.3% | 54.1 k | 1.09 | 2% |
| fish | 19.1 | 20 | +5.0% | 5.2% | 52.6 k | 1.04 | 0% |
| iron | 37.4 | 40.6 | +8.6% | 7.6% | 51.2 k | 1.02 | 1% |
| paper | 34.4 | 37.4 | +8.7% | 3.1% | 50.3 k | 0.79 | 1% |
| groceries | 45.8 | 35 | -23.6% | 4.9% | 49.9 k | 0.84 | 0% |
| furniture | 30 | 33.2 | +10.6% | 10.3% | 47.9 k | 0.95 | 3% |
| steel | 52 | 59.4 | +14.4% | 9.3% | 41.5 k | 0.87 | 0% |
| tobacco | 37.5 | 29.6 | -21.1% | 4.9% | 35.6 k | 1.36 | 0% |
| meat | 42.8 | 31.1 | -27.4% | 5.2% | 34.2 k | 0.98 | 1% |
| sugar | 33.7 | 19.6 | -41.9% | 2.8% | 24.5 k | 1.52 | 2% |
| tea | 57 | 28 | -50.9% | 7.5% | 23.3 k | 1.76 | 1% |
| opium | 57.8 | 41.2 | -28.8% | 6.6% | 18.2 k | 1.25 | 0% |
| luxury_clothes | 64.5 | 56.7 | -12.0% | 12.7% | 17.2 k | 1.10 | 2% |
| silk | 44.9 | 38.5 | -14.1% | 10.4% | 16.6 k | 1.07 | 3% |
| engines | 48.1 | 83.4 | +73.4% | 8.7% | 15.9 k | 0.67 | 6% |
| coffee | 60.9 | 35.9 | -41.1% | 6.6% | 15.4 k | 1.42 | 0% |
| liquor | 26.5 | 28.4 | +7.3% | 5.8% | 15 k | 1.10 | 5% |
| dye | 19.3 | 27.4 | +42.1% | 12.5% | 14.7 k | 1.57 | 0% |
| hardwood | 49.6 | 40.2 | -18.9% | 11.1% | 13.4 k | 1.06 | 2% |
| glass | 23.2 | 52.8 | +127.4% | 9.2% | 13.4 k | 0.76 | 3% |
| merchant_marine | 46.5 | 45.2 | -2.8% | 6.6% | 10.4 k | 1.19 | 1% |
| explosives | 42.6 | 57 | +34.0% | 3.6% | 10.3 k | 0.85 | 1% |

## Construction and urbanization

Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes for it, and ranching (horses come from livestock).

![Construction and urbanization](figures/construction.svg)

| metric | 1836-01 | 1886-01 mean | growth | sd | cv | MDE (n=5 vs 5) |
|:--|--:|--:|--:|--:|--:|--:|
| Construction sector levels | 83 | 892 | +975.2% | 89.3 | 10.0% | 20.2% |
| Urban center levels | 601 | 3.29 k | +447.9% | 250 | 7.6% | 15.4% |
| Non-subsistence building levels | 44.5 k | 81.4 k | +82.9% | 2.01 k | 2.5% | 5.0% |
| Light industry levels | 1 k | 3.06 k | +206.0% | 155 | 5.1% | 10.3% |
| Heavy industry levels | 34 | 619 | +1721.2% | 121 | 19.5% | 39.4% |
| Livestock ranch levels | 487 | 1.17 k | +140.9% | 73.4 | 6.3% | 12.6% |
| Urbanization (points) | 84.1 k | 302 k | +259.1% | 19.2 k | 6.4% | 12.9% |

## Fiscal

![Fiscal](figures/fiscal.svg)

| metric | 1836-01 | 1886-01 mean | growth | sd | cv | MDE (n=5 vs 5) |
|:--|--:|--:|--:|--:|--:|--:|
| Gold reserves | 16 M | 102 M | +539.4% | 32.9 M | 32.2% | 65.1% |
| Countries in debt | 15 | 39.6 | +164.0% | 9.74 | 24.6% | 49.7% |
| Income /wk | 1.75 M | 7.84 M | +348.3% | 561 k | 7.2% | 14.5% |
| Expenses /wk | 1.54 M | 8.2 M | +433.0% | 757 k | 9.2% | 18.6% |
| Net income /wk | 210 k | -364 k | -273.5% | 378 k | – | – |

World net government income goes 210 k → -364 k per week: spending outgrows revenue, which is the headroom BOI's road financing competes for.

## BOI cheat-sheet

Values at 1886-01. Compare a BOI ensemble's mean against these; a difference smaller than the MDE is indistinguishable from vanilla noise with 5 members per arm.

| metric | mean | sd | cv | MDE (n=5) | n for 2% | n for 5% |
|:--|--:|--:|--:|--:|--:|--:|
| World GDP | 1.32 B | 78.8 M | 6.0% | 12.0% | 141 | 24 |
| SoL | 9.05 | 0.135 | 1.5% | 3.0% | 10 | 3 |
| Unemployed | 50 M | 4.75 M | 9.5% | 19.2% | 355 | 58 |
| Wage | 1.35 | 0.134 | 9.9% | 20.0% | 386 | 63 |
| Infrastructure supply | 71.3 k | 4.04 k | 5.7% | 11.5% | 128 | 22 |
| Infrastructure usage | 31 k | 1.78 k | 5.7% | 11.6% | 131 | 22 |
| Utilization | 43.5% | 1.6% | 3.7% | 7.6% | 57 | 10 |
| Deficit states | 34 | 8.69 | 25.6% | 51.6% | >1000 | 412 |
| Railway levels | 995 | 108 | 10.8% | 21.8% | 460 | 75 |
| Port levels | 651 | 59 | 9.1% | 18.3% | 324 | 53 |
| Construction levels | 892 | 89.3 | 10.0% | 20.2% | 395 | 64 |
| Urban center levels | 3.29 k | 250 | 7.6% | 15.4% | 228 | 38 |
| Livestock ranch levels | 1.17 k | 73.4 | 6.3% | 12.6% | 155 | 26 |
| Gold reserves | 102 M | 32.9 M | 32.2% | 65.1% | >1000 | 652 |
| Countries in debt | 39.6 | 9.74 | 24.6% | 49.7% | >1000 | 381 |
| Govt expenses | 8.2 M | 757 k | 9.2% | 18.6% | 335 | 55 |
| Transportation price | 44.1 | 1.82 | 4.1% | 8.4% | 69 | 12 |
| Transport demand at ceiling | 23.1% | 8.7% | 37.6% | 76.0% | >1000 | 891 |
| Transportation demand | 68.3 k | 4.94 k | 7.2% | 14.6% | 207 | 34 |
| Merchant marine price | 45.2 | 2.99 | 6.6% | 13.4% | 174 | 29 |
| Services price | 26.5 | 0.636 | 2.4% | 4.9% | 24 | 5 |
| Wood price | 20.4 | 0.93 | 4.6% | 9.2% | 83 | 15 |
| Grain price | 19.7 | 1.1 | 5.6% | 11.3% | 124 | 21 |
| Groceries price | 35 | 1.72 | 4.9% | 10.0% | 97 | 17 |
| Tools price | 45.4 | 2.09 | 4.6% | 9.3% | 84 | 15 |

## Appendix

- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. It reads only the database.
- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same day; `t` counts quarters from 1836-01.
- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, wage, market access and turmoil. World goods: summed orders, demand-weighted price.
- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.
- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance of a wave changes means through that alone.
- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.

