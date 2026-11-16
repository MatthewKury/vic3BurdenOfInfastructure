# Ensemble report: vanilla115_1836_1936_all

Generated 2026-11-05 by `tools/ensembles/Make-EnsembleReport.py` from `tools/ensembles/ensembles.sqlite`. 2 members, 1836-01-02 to 1898-01-01, quarterly; game 1.15.0.

Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; shown as % of the mean.

## Key findings

- World GDP grows +396.8% over 62 years (member spread 7.8% cv); pop-weighted SoL rises 9.01 → 9.78 and unemployment goes ×7.8 (7.33 M → 56.9 M).
- With 2 vs 2 members the minimum detectable effect is 3%–50% for world GDP, SoL, infrastructure usage, urban centers and ranches; 13%–33% for unemployment, construction and gold; 67%–214% for deficit states and railways. Wars are untestable (MDE 105%). Clamped prices (transport) look precise only because they can't move.
- Power trajectories differ a lot in predictability: GDP cv at the end is lowest for SIC, TUR, SPA, RUS and highest for SWE, FRA, BRZ, CHI. The GDP top five is the same set of countries in 1/2 members, and in exactly the order GBR > CHI > USA > PRU > FRA in 1/2.
- Infrastructure is slack in aggregate (world utilization 36% → 41%) but shortages spread: states with usage > supply go 10 → 19.5 (cv 39.9%). Railways grow 18 → 1.56 k levels with ~13% spread, the noisiest infrastructure metric.
- Industrialisation squeezes inputs: the biggest world price rises are glass +126%, engines +69%, dye +42%, lead +41%, explosives +34%; plantation goods glut (tea -48%, sugar -42%, coffee -42%, oil -37%).
- Transportation is the standout shortage good for BOI: world supply covers only 12% of demand at the start and 63% at the end, and 99% → 13% of transport demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; watch orders and the at-ceiling share instead.

Contents: [Setup](#setup) · [World](#world) · [Noise and power](#noise-and-power) · [Great powers](#great-powers) · [Geopolitics](#geopolitics) · [Infrastructure](#infrastructure) · [Markets](#markets) · [Construction and urbanization](#construction-and-urbanization) · [Fiscal](#fiscal) · [BOI cheat-sheet](#boi-cheat-sheet) · [Appendix](#appendix)

## Setup

**vanilla: `vanilla115_1836_1936_all`** (control). Every 1.15.0 game of the vanilla115_1836_1936 batch, including the 5 that crashed (in 1872, 1896, 1928, 1886 and 1899), each up to its last complete snapshot. Four crashes hit the same address in the snapshot's state loop and look unrelated to how the game develops, so the partial games add members past 1886. The 1899 game uses snapshot version 4, which starts in April 1836.

| item | value |
|:--|--:|
| members | 2 |
| snapshots per member | 249–249 of 249 (none dropped) |
| minutes per member | 83.2–142.2 (total 3.8 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | none (telemetry only) |
| telemetry modules | core, parity, ensemble |

Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the second country under a tag in a member is labelled `TAG#2` (see `run_country`).

## World

![World trajectories](figures/world.svg)

| metric | 1836-01 | 1898-01 mean | growth | sd | cv | MDE (n=2 vs 2) |
|:--|--:|--:|--:|--:|--:|--:|
| GDP (world) | 363 M | 1.8 B | +396.8% | 140 M | 7.8% | 41.6% |
| Population | 993 M | 1.57 B | +57.8% | 12.1 M | 0.8% | 4.1% |
| Standard of living (pop-weighted) | 9.01 | 9.78 | +8.5% | 0.284 | 2.9% | 15.6% |
| Literacy (pop-weighted) | 20.8% | 40.4% | – | 0.2% | 0.6% | 3.3% |
| Unemployed working adults | 7.33 M | 56.9 M | +676.4% | 1.37 M | 2.4% | 12.9% |
| Urbanization (points) | 84.1 k | 406 k | +382.5% | 32.1 k | 7.9% | 42.5% |
| Countries alive | 291 | 174 | -40.2% | 5.66 | 3.3% | 17.4% |
| Wage (pop-weighted, /yr) | 0.435 | 1.63 | +274.3% | 0.209 | 12.8% | 68.8% |
| Radicals | 14.5 M | 242 M | +1571.1% | 53 M | 21.9% | 117.2% |
| Loyalists | 0 | 48.3 M | – | 17.4 M | 35.9% | 192.6% |
| State turmoil (pop-weighted) | 1.5% | 15.5% | – | 3.3% | 21.3% | 114.0% |

CHI averages 33% of world population, so pop-weighted world SoL largely tracks it. The biggest one-quarter jump in any member (member 11, 1850-10 → 1851-01: 8.17 → 7.66) is CHI's SoL going 7.12 → 5.68. Compare SoL per country, or the powers' SoL panels, when testing welfare effects.

GDP rises +128.2% in the first half and +117.7% in the second. Population is nearly deterministic (cv 0.8%); welfare measures (SoL, unemployment, wage) carry 2–5% noise.

## Noise and power

![cv over time](figures/noise_cv.svg)

*Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, railways near 10%.*

![MDE by metric](figures/noise_mde.svg)

| metric | cv | MDE n=2 | n for 1% | n for 2% | n for 5% | n for 10% |
|:--|--:|--:|--:|--:|--:|--:|
| Transportation price (clamped) | 0.3% | 1.4% | 3 | 3 | 3 | 3 |
| Livestock ranch levels | 0.5% | 2.6% | 5 | 3 | 3 | 3 |
| Literacy | 0.6% | 3.3% | 8 | 3 | 3 | 3 |
| Population | 0.8% | 4.1% | 11 | 4 | 3 | 3 |
| Unemployed | 2.4% | 12.9% | 92 | 24 | 5 | 3 |
| Grain price | 2.7% | 14.4% | 114 | 30 | 6 | 3 |
| Tools price | 2.7% | 14.4% | 115 | 30 | 6 | 3 |
| SoL | 2.9% | 15.6% | 134 | 35 | 7 | 3 |
| Infrastructure supply | 3.1% | 16.5% | 149 | 38 | 8 | 3 |
| Infra utilization | 3.2% | 17.2% | 162 | 42 | 8 | 3 |
| Gold reserves | 3.6% | 19.3% | 206 | 53 | 10 | 4 |
| Construction levels | 6.2% | 33.0% | 597 | 150 | 25 | 8 |
| Infrastructure usage | 6.3% | 33.6% | 618 | 156 | 26 | 8 |
| World GDP | 7.8% | 41.6% | 947 | 238 | 39 | 11 |
| Urban center levels | 9.3% | 49.7% | >1000 | 339 | 55 | 15 |
| Countries in debt | 10.6% | 56.6% | >1000 | 439 | 71 | 19 |
| Govt expenses | 11.0% | 58.9% | >1000 | 474 | 77 | 20 |
| Govt income | 11.0% | 59.0% | >1000 | 476 | 77 | 20 |
| Railway levels | 12.6% | 67.4% | >1000 | 621 | 101 | 26 |
| Wage | 12.8% | 68.8% | >1000 | 648 | 105 | 27 |
| Countries at war | 19.5% | 104.6% | >1000 | >1000 | 240 | 61 |
| Port levels | 19.8% | 106.1% | >1000 | >1000 | 247 | 63 |
| Radicals | 21.9% | 117.2% | >1000 | >1000 | 302 | 76 |
| Deficit states | 39.9% | 213.9% | >1000 | >1000 | >1000 | 251 |

n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), assuming the mod leaves the spread unchanged.

### Regimes: revolution waves

![Revolution-wave members](figures/regimes.svg)

## Great powers

The 17 countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP at 1898-01. Independent y-axes.

![GDP by power](figures/powers_gdp.svg)

![SoL by power](figures/powers_sol.svg)

![GDP rank distribution](figures/powers_rank.svg)

| power | GDP (median) | growth | GDP cv | SoL | railways | techs | time at war | great power at end |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|
| GBR | 201 M | +718.7% | 19.7% | 14.8 | 151 | 124 | 50% | 2/2 |
| CHI | 163 M | +92.4% | 20.7% | 7.46 | 71.5 | 71 | 10% | 0/2 |
| PRU | 133 M | +1316.3% | 0.0% | 12.5 | 106 | 121 | 21% | 1/2 |
| USA | 124 M | +698.6% | 12.8% | 12.9 | 63 | 126 | 14% | 2/2 |
| RUS | 102 M | +361.2% | 9.4% | 9.39 | 42 | 100 | 40% | 2/2 |
| FRA | 93.6 M | +355.2% | 53.6% | 13.2 | 95 | 112 | 25% | 2/2 |
| TUR | 51.3 M | +405.0% | 8.3% | 9.21 | 48.5 | 87 | 24% | 1/2 |
| SPA | 42.1 M | +567.9% | 8.7% | 12.2 | 33.5 | 105 | 13% | 1/2 |
| SWE | 36.5 M | +1538.7% | 80.8% | 15.5 | 30 | 121 | 6% | 1/2 |
| NET | 35.6 M | +1375.2% | 0.0% | 16.8 | 29 | 128 | 23% | 0/2 |
| BEL | 30 M | +873.5% | 0.0% | 16.8 | 22 | 123 | 2% | 0/2 |
| BRZ | 24.8 M | +464.2% | 44.4% | 11.9 | 30.5 | 106 | 7% | 0/2 |
| JAP | 23.6 M | +118.8% | 0.0% | 8.8 | 20 | 88 | 2% | 0/2 |
| SIC | 13.4 M | +275.4% | 4.3% | 10.4 | 14.5 | 89.5 | 13% | 0/2 |
| SIA | 3.51 M | +220.6% | 0.0% | 7.39 | 2 | 72 | 17% | 0/2 |
| AUS | – | – | – | – | – | – | 16% | 0/2 |
| PAN | – | – | – | – | – | – | 9% | 0/2 |

## Geopolitics

![Conflict and politics](figures/conflict.svg)

Countries at war swings between 0 and 77 at any snapshot; the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.

| event | countries (members out of 2) |
|:--|--:|
| annexed/gone in every member | – |
| gone in at least half | – |
| formed (new tag) during the run | GUA (13), HON (13), NAL (13), ALT (12), COS (12), NIC (12), DOM (11), D00 (8), D01 (7), ZAN (7), D02 (6), D03 (6), LIM (6), D04 (5), D05 (5), TPG (5), KPR (4), BHT (3), RSM (3), AGJ (2), ASA (2), BUL (2), CAR (2), D06 (2), D07 (2), D08 (2), D14 (2), D15 (2), D16 (2), GAL (2), LAT (2), LOM (2), SUD (2), UKR (2), VEN (2), ABK (1), ABU (1), ACE (1), AGC (1), AIT (1), ALD (1), ALK (1), ALW (1), ANH (1), ANK (1), ARB (1), ARG (1), ARS (1), ASH (1), ASM (1), ATL (1), AUS (1), AWA (1), AWS (1), AZB (1), BAD (1), BAG (1), BAL (1), BAS (1), BAV (1), BCE (1), BEL (1), BEN (1), BER (1), BGI (1), BGL (1), BGM (1), BHN (1), BHO (1), BHU (1), BHV (1), BHW (1), BIC (1), BIK (1), BKH (1), BLG (1), BLH (1), BNJ (1), BNY (1), BOL (1), BOR (1), BOS (1), BRA (1), BRD (1), BRE (1), BRG (1), BRU (1), BRZ (1), BST (1), BTN (1), BUG (1), BUK (1), BUN (1), BUR (1), BYE (1), CAM (1), CHC (1), CHI (1), CHL (1), CHP (1), CHT (1), CIR (1), CLM (1), CMI (1), COB (1), COC (1), CON (1), COO (1), CRO (1), CUB (1), D09 (1), D10 (1), D11 (1), D12 (1), D13 (1), D17 (1), DAH (1), DAI (1), DEI (1), DEN (1), DFR (1), DHA (1), DIR (1), ECU (1), EGY (1), ELS (1), ETH (1), EZO (1), FIN (1), FRA (1), FRM (1), FTJ (1), FTR (1), FZN (1), GAR (1), GBR (1), GJM (1), GLD (1), GRE (1), GUJ (1), GWA (1), GZA (1), HAI (1), HAM (1), HAN (1), HAR (1), HAU (1), HAW (1), HBC (1), HDJ (1), HDY (1), HEK (1), HER (1), HES (1), HOH (1), HOL (1), HUN (1), HYD (1), IBL (1), IDA (1), IND (1), ION (1), IQU (1), ISQ (1), ITA (1), JAB (1), JAI (1), JAP (1), JAS (1), JEY (1), JHN (1), JMB (1), JOD (1), JOH (1), JUN (1), KAB (1), KAF (1), KAL (1), KAN (1), KAS (1), KAT (1), KAU (1), KAZ (1), KFA (1), KHI (1), KHP (1), KLT (1), KNO (1), KOK (1), KON (1), KOR (1), KOT (1), KRA (1), KRG (1), KRN (1), KRT (1), KTI (1), KUN (1), KUT (1), KZH (1), LAH (1), LAN (1), LAO (1), LIB (1), LIP (1), LIT (1), LUA (1), LUB (1), LUC (1), LUX (1), MAD (1), MAH (1), MAI (1), MAK (1), MAS (1), MBS (1), MEC (1), MEI (1), MEW (1), MEX (1), MGD (1), MJT (1), MKT (1), MLD (1), MNL (1), MNP (1), MOD (1), MOL (1), MON (1), MOR (1), MSN (1), MST (1), MUG (1), MYB (1), MYS (1), NAG (1), NAR (1), NAS (1), NAW (1), NBS (1), NEJ (1), NEP (1), NET (1), NOR (1), NPU (1), NSW (1), NVS (1), OLD (1), OMA (1), ONT (1), ORA (1), ORG (1), OYO (1), OZH (1), PAN (1), PAP (1), PAR (1), PBC (1), PCO (1), PER (1), PEU (1), PHI (1), PHL (1), PLP (1), PLY (1), PNI (1), POL (1), PON (1), POR (1), PRA (1), PRG (1), PRK (1), PRM (1), PRU (1), PTA (1), PTN (1), PUD (1), QUE (1), QWR (1), RAJ (1), ROM (1), RUS (1), RWD (1), RYU (1), SAF (1), SAK (1), SAR (1), SAS (1), SAT (1), SAX (1), SCH (1), SCM (1), SCW (1), SDM (1), SEL (1), SEQ (1), SER (1), SGU (1), SHS (1), SHW (1), SIA (1), SIC (1), SIK (1), SIL (1), SIN (1), SLO (1), SMB (1), SNA (1), SOK (1), SPA (1), SPC (1), SPU (1), SRK (1), STG (1), SUL (1), SUR (1), SVN (1), SWE (1), SWI (1), SWT (1), SWZ (1), TAS (1), TEX (1), TGI (1), TGR (1), TIB (1), TID (1), TJI (1), TKI (1), TRA (1), TRH (1), TRI (1), TRN (1), TRS (1), TUG (1), TUN (1), TUR (1), TUS (1), TWT (1), UBD (1), UCA (1), ULR (1), UNT (1), URU (1), USA (1), UYA (1), UZB (1), UZH (1), VNZ (1), WAD (1), WAL (1), WAS (1), WBL (1), WEI (1), WLD (1), WLG (1), WLT (1), WSG (1), WTU (1), WUR (1), YEM (1), YOG (1), YUG (1), ZAI (1), ZUL (1) |
| civil-war split (TAG#n) | AGC (12), AUS (7), HUN (7), JAP (7), KAT (7), MEC (7), POR (7), QUE (7), SAS (7), SIA (7), WTU (7), ALT (6), BEL (6), GRE (6), HAN (6), LAH (6), NEP (6), NSW (6), PER (6), TGI (6), ACE (5), BCE (5), BHN (5), BRA (5), DAI (5), HAM (5), HES (5), LUA (5), LUX (5), MAH (5), MST (5), NAL (5), NAS (5), ONT (5), PRU (5), SAF (5), SAR (5), SHS (5), SWE (5), WLT (5), ANH (4), BTN (4), FRA (4), HAI (4), KRA (4), KTI (4), MEI (4), NET (4), PAR (4), POL (4), PRK (4), STG (4), SWI (4), UBD (4), ASH (3), BAL (3), BAV (3), BRE (3), BUK (3), CHT (3), CIR (3), COS (3), CRO (3), DEN (3), FIN (3), FTJ (3), FTR (3), HAU (3), HAW (3), HOL (3), JAB (3), KBU (3), LIB (3), MOL (3), MYS (3), OMA (3), PAP (3), PON (3), SAX (3), SER (3), SIN (3), TRI (3), TUN (3), TUR (3), TUS (3), WSG (3), ZUL (3), ABU (2), ALK (2), BAD (2), BEN (2), BOL (2), BRZ (2), BST (2), CAM (2), CAR (2), CMI (2), DEI (2), EGY (2), EWE (2), HAR (2), HEK (2), IND (2), ION (2), JHN (2), JOH (2), KOR (2), KPR (2), MBS (2), MEW (2), NEJ (2), OLD (2), PCO (2), RSM (2), RYU (2), SCH (2), SGU (2), SIC (2), SIL (2), SUL (2), SUR (2), TAS (2), TIB (2), TRN (2), WAS (2), WUR (2), AIN (1), ALW (1), ARB (1), ATB (1), AWA (1), BAG (1), BAS (1), BER (1), BHO (1), BHT (1), BHV (1), BHW (1), BKH (1), BLH (1), BNG (1), BRN (1), BRU (1), BUG (1), BUL (1), BUN (1), BUR (1), CHC (1), CHP (1), COC (1), DAH (1), DHA (1), DIR (1), DLA (1), DOM (1), ECU (1), GAL (1), GUA (1), GZA (1), HBC (1), HDJ (1), HDY (1), HRO (1), IBO (1), IDA (1), ISQ (1), JAI (1), JAS (1), JEY (1), JUN (1), KAL (1), KBA (1), KHI (1), KNK (1), KON (1), KOT (1), KRG (1), KRT (1), LOM (1), MAD (1), MAK (1), MGD (1), MJT (1), MOD (1), MSN (1), MUG (1), MYB (1), NAR (1), NAW (1), NOR (1), OYO (1), PHI (1), PHL (1), PRG (1), PTA (1), PTN (1), RUS (1), RWD (1), SAK (1), SAT (1), SEL (1), SEQ (1), SOK (1), SPA (1), SPC (1), SWT (1), SWZ (1), TID (1), TNG (1), TPG (1), TRA (1), TSW (1), TUA (1), TUG (1), URU (1), UYA (1), VEN (1), VNZ (1), WAL (1), WBL (1), YUG (1), ZAN (1) |

Civil wars that happen in at least 80% of members are background: AGC, AUS, HUN, JAP, KAT, MEC, POR, QUE, SAS, SIA, WTU, ALT, BEL, GRE, HAN, LAH, NEP, NSW, PER, TGI, ACE, BCE, BHN, BRA, DAI, HAM, HES, LUA, LUX, MAH, MST, NAL, NAS, ONT, PRU, SAF, SAR, SHS, SWE, WLT, ANH, BTN, FRA, HAI, KRA, KTI, MEI, NET, PAR, POL, PRK, STG, SWI, UBD, ASH, BAL, BAV, BRE, BUK, CHT, CIR, COS, CRO, DEN, FIN, FTJ, FTR, HAU, HAW, HOL, JAB, KBU, LIB, MOL, MYS, OMA, PAP, PON, SAX, SER, SIN, TRI, TUN, TUR, TUS, WSG, ZUL, ABU, ALK, BAD, BEN, BOL, BRZ, BST, CAM, CAR, CMI, DEI, EGY, EWE, HAR, HEK, IND, ION, JHN, JOH, KOR, KPR, MBS, MEW, NEJ, OLD, PCO, RSM, RYU, SCH, SGU, SIC, SIL, SUL, SUR, TAS, TIB, TRN, WAS, WUR. 

## Infrastructure

![Infrastructure](figures/infrastructure.svg)

![State infrastructure scatter](figures/states_scatter.svg)

*States with zero usage sit on the bottom edge (log scale).*

![State utilization distribution](figures/states_utilization.svg)

States short of infrastructure in at least half the members at 1898-01 (36 states; median values across members):

| state | owner | short in | supply | usage | shortfall | population |
|:--|--:|--:|--:|--:|--:|--:|
| Turkmenia | KHI | 2/2 | 8.35 | 10.1 | 1.7 | 84.2 k |
| Kenya | WTU#6 | 2/2 | 4.1 | 5.55 | 1.45 | 2.51 k |
| Hail | JAB | 2/2 | 6.85 | 7.9 | 1.05 | 70 k |
| Mocambique | AGC | 1/1 | 3.7 | 13.5 | 9.8 | 2.04 k |
| Transorangia | ZUL | 1/1 | 10.9 | 20.2 | 9.3 | 152 k |
| Chiapas | ALT#5 | 1/1 | 3.7 | 10.9 | 7.2 | 644 |
| Trucial Coast | BRN#2 | 1/1 | 4 | 10.8 | 6.8 | 827 |
| Mocambique | AGC#4 | 1/1 | 4.1 | 10.6 | 6.5 | 1.4 k |
| Merv | KHI | 1/1 | 6.2 | 8 | 1.8 | 66 k |
| Transorangia | TRN | 1/2 | 12.4 | 13.6 | 1.25 | 202 k |
| Transvaal | SWZ | 1/1 | 9.6 | 10.8 | 1.2 | 107 k |
| Iceland | DEN#2 | 1/1 | 19.2 | 20.2 | 1 | 212 k |
| Senegal | FTR | 1/1 | 11.8 | 12.5 | 0.7 | 147 k |
| Kenya | WTU#5 | 1/1 | 4 | 4.6 | 0.6 | 756 |
| Yangseo | KOR | 1/1 | 92.6 | 93.1 | 0.5 | 4.74 M |
| Amhara | HAR | 1/1 | 11.7 | 12 | 0.3 | 190 k |
| Mauritania | FTR | 1/1 | 8.7 | 9 | 0.3 | 114 k |
| West Bengal | COO | 1/1 | 21.7 | 21.8 | 0.1 | 335 k |
| Hail | NEJ | 1/2 | 6.8 | 6.75 | -0.05 | 67.5 k |
| Waddai | BOR | 1/2 | 5.65 | 4.75 | -0.9 | 62.3 k |
| Hormuz | BHN | 1/2 | 5.15 | 4.2 | -0.95 | 28.3 k |
| Eastern Himalayas | SIK | 1/2 | 9.1 | 7.65 | -1.45 | 113 k |
| Chad | BOR | 1/2 | 7.95 | 6.5 | -1.45 | 96.5 k |
| Yemen | KAT | 1/2 | 10.1 | 7.25 | -2.8 | 92.8 k |
| Yemen | LAH | 1/2 | 8.3 | 4.8 | -3.5 | 53.3 k |

Market access is uninformative in vanilla: pop-weighted world market access stays at 99.7% (cv 0.27%). Deficits in vanilla don't yet cut states off; BOI changing that would show up here immediately.

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

| goods | price 1836-01 | price 1898-01 | change | price cv | demand/wk | supply/demand | demand at ceiling |
|:--|--:|--:|--:|--:|--:|--:|--:|
| coal | 30 | 30.5 | +1.7% | 0.4% | 154 k | 1.00 | 0% |
| wood | 20.8 | 18.5 | -11.0% | 5.1% | 142 k | 1.11 | 0% |
| tools | 39.5 | 43.6 | +10.3% | 2.7% | 134 k | 0.91 | 0% |
| transportation | 52.4 | 42.6 | -18.7% | 0.3% | 110 k | 0.63 | 13% |
| grain | 15.8 | 19.2 | +21.4% | 2.7% | 106 k | 1.07 | 0% |
| fabric | 16.6 | 14.3 | -13.6% | 1.0% | 99.7 k | 1.40 | 0% |
| services | 19.6 | 25.1 | +27.8% | 0.7% | 98.7 k | 1.22 | 0% |
| clothes | 32.3 | 30 | -7.0% | 3.4% | 89.6 k | 1.04 | 1% |
| iron | 37.3 | 37.9 | +1.8% | 0.6% | 84.2 k | 1.08 | 0% |
| steel | 52 | 52.5 | +0.9% | 1.8% | 79.4 k | 1.01 | 0% |
| fish | 19.1 | 19.9 | +4.4% | 4.1% | 76.9 k | 1.06 | 0% |
| paper | 34.4 | 34.5 | +0.2% | 0.2% | 67 k | 0.87 | 0% |
| fruit | 41.9 | 26.7 | -36.2% | 3.8% | 66 k | 1.15 | 0% |
| groceries | 45.6 | 33.9 | -25.8% | 2.1% | 65.1 k | 0.87 | 0% |
| furniture | 30 | 31.5 | +4.8% | 7.8% | 58.1 k | 1.02 | 1% |
| tobacco | 37.5 | 27.7 | -26.2% | 3.4% | 49 k | 1.43 | 0% |
| meat | 42.9 | 31 | -27.7% | 8.2% | 41.7 k | 0.98 | 0% |
| sugar | 33.6 | 19.5 | -42.1% | 8.3% | 31.8 k | 1.50 | 1% |
| engines | 47.7 | 80.5 | +68.5% | 9.2% | 30.9 k | 0.71 | 3% |
| glass | 23.4 | 52.8 | +125.9% | 17.9% | 29.7 k | 0.81 | 0% |
| tea | 57 | 29.5 | -48.2% | 11.2% | 26.1 k | 1.69 | 0% |
| explosives | 43.2 | 58 | +34.3% | 4.4% | 25.6 k | 0.84 | 0% |
| dye | 19.5 | 27.7 | +42.4% | 6.6% | 25.5 k | 1.45 | 0% |
| opium | 57.9 | 43.3 | -25.1% | 7.9% | 23.1 k | 1.19 | 0% |
| silk | 45 | 36.9 | -17.8% | 8.0% | 22.7 k | 1.11 | 2% |
| coffee | 61.1 | 35.4 | -42.0% | 2.7% | 22.1 k | 1.40 | 0% |
| luxury_clothes | 64.6 | 54.2 | -16.1% | 1.7% | 22.1 k | 1.16 | 1% |
| fertilizer | 40.8 | 35.1 | -14.1% | 5.1% | 18.4 k | 0.85 | 0% |
| sulfur | 51.2 | 44.4 | -13.1% | 0.6% | 17.8 k | 1.15 | 0% |
| hardwood | 49.9 | 40.8 | -18.3% | 10.1% | 17.7 k | 1.02 | 0% |

## Construction and urbanization

Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes for it, and ranching (horses come from livestock).

![Construction and urbanization](figures/construction.svg)

| metric | 1836-01 | 1898-01 mean | growth | sd | cv | MDE (n=2 vs 2) |
|:--|--:|--:|--:|--:|--:|--:|
| Construction sector levels | 83 | 1.01 k | +1116.9% | 62.2 | 6.2% | 33.0% |
| Urban center levels | 601 | 5.5 k | +815.2% | 510 | 9.3% | 49.7% |
| Non-subsistence building levels | 44.5 k | 97.9 k | +119.8% | 4.17 k | 4.3% | 22.8% |
| Light industry levels | 1 k | 4.26 k | +325.8% | 446 | 10.5% | 56.1% |
| Heavy industry levels | 34 | 1.23 k | +3530.9% | 278 | 22.5% | 120.7% |
| Livestock ranch levels | 487 | 1.29 k | +165.8% | 6.36 | 0.5% | 2.6% |
| Urbanization (points) | 84.1 k | 406 k | +382.5% | 32.1 k | 7.9% | 42.5% |

## Fiscal

![Fiscal](figures/fiscal.svg)

| metric | 1836-01 | 1898-01 mean | growth | sd | cv | MDE (n=2 vs 2) |
|:--|--:|--:|--:|--:|--:|--:|
| Gold reserves | 16 M | 139 M | +767.9% | 5 M | 3.6% | 19.3% |
| Countries in debt | 15 | 33.5 | +123.3% | 3.54 | 10.6% | 56.6% |
| Income /wk | 1.75 M | 10.2 M | +484.6% | 1.12 M | 11.0% | 59.0% |
| Expenses /wk | 1.54 M | 10.1 M | +555.2% | 1.11 M | 11.0% | 58.9% |
| Net income /wk | 204 k | 99.2 k | -51.3% | 12.8 k | 12.9% | 69.4% |

World net government income goes 204 k → 99.2 k per week: spending outgrows revenue, which is the headroom BOI's road financing competes for.

## BOI cheat-sheet

Values at 1898-01. Compare a BOI ensemble's mean against these; a difference smaller than the MDE is indistinguishable from vanilla noise with 2 members per arm.

| metric | mean | sd | cv | MDE (n=2) | n for 2% | n for 5% |
|:--|--:|--:|--:|--:|--:|--:|
| World GDP | 1.8 B | 140 M | 7.8% | 41.6% | 238 | 39 |
| SoL | 9.78 | 0.284 | 2.9% | 15.6% | 35 | 7 |
| Unemployed | 56.9 M | 1.37 M | 2.4% | 12.9% | 24 | 5 |
| Wage | 1.63 | 0.209 | 12.8% | 68.8% | 648 | 105 |
| Infrastructure supply | 98.7 k | 3.03 k | 3.1% | 16.5% | 38 | 8 |
| Infrastructure usage | 41 k | 2.57 k | 6.3% | 33.6% | 156 | 26 |
| Utilization | 41.5% | 1.3% | 3.2% | 17.2% | 42 | 8 |
| Deficit states | 19.5 | 7.78 | 39.9% | 213.9% | >1000 | >1000 |
| Railway levels | 1.56 k | 196 | 12.6% | 67.4% | 621 | 101 |
| Port levels | 808 | 160 | 19.8% | 106.1% | >1000 | 247 |
| Construction levels | 1.01 k | 62.2 | 6.2% | 33.0% | 150 | 25 |
| Urban center levels | 5.5 k | 510 | 9.3% | 49.7% | 339 | 55 |
| Livestock ranch levels | 1.29 k | 6.36 | 0.5% | 2.6% | 3 | 3 |
| Gold reserves | 139 M | 5 M | 3.6% | 19.3% | 53 | 10 |
| Countries in debt | 33.5 | 3.54 | 10.6% | 56.6% | 439 | 71 |
| Govt expenses | 10.1 M | 1.11 M | 11.0% | 58.9% | 474 | 77 |
| Transportation price | 42.6 | 0.112 | 0.3% | 1.4% | 3 | 3 |
| Transport demand at ceiling | 13.2% | 7.7% | 58.3% | 312.7% | >1000 | >1000 |
| Transportation demand | 110 k | 9.47 k | 8.6% | 46.0% | 290 | 48 |
| Merchant marine price | 39.1 | 6.71 | 17.1% | 91.9% | >1000 | 186 |
| Services price | 25.1 | 0.176 | 0.7% | 3.8% | 4 | 3 |
| Wood price | 18.5 | 0.935 | 5.1% | 27.1% | 102 | 18 |
| Grain price | 19.2 | 0.514 | 2.7% | 14.4% | 30 | 6 |
| Groceries price | 33.9 | 0.714 | 2.1% | 11.3% | 19 | 4 |
| Tools price | 43.6 | 1.17 | 2.7% | 14.4% | 30 | 6 |

## Appendix

- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. It reads only the database.
- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same day; `t` counts quarters from 1836-01.
- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, wage, market access and turmoil. World goods: summed orders, demand-weighted price.
- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.
- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance of a wave changes means through that alone.
- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.

