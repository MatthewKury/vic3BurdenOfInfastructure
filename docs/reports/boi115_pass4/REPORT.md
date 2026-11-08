# Ensemble report: vanilla115_1836_1936_all vs boi115_pass4

Generated 2026-11-06 by `tools/ensembles/Make-EnsembleReport.py` from `tools/ensembles/ensembles.sqlite`. 13 members (A) vs 2 (B), 1836-01-02 to 1846-01-01, quarterly; game 1.15.0.

Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; shown as % of the mean.

## Key findings

- World GDP grows +49.4% over 10 years (member spread 1.2% cv); pop-weighted SoL falls 9.02 → 8.2 and unemployment goes ×2.8 (7.33 M → 20.8 M): the world gets richer in total and poorer per head.
- With 13 vs 13 members the minimum detectable effect is 1%–2% for world GDP, SoL, infrastructure usage, urban centers and ranches; 4%–9% for unemployment, construction and gold; 10%–11% for deficit states and railways. Wars are untestable (MDE 108%). Clamped prices (transport) look precise only because they can't move.
- Power trajectories differ a lot in predictability: GDP cv at the end is lowest for GBR, SPA, RUS, CHI and highest for PAN, AUS, BEL, SIC. The GDP top five is the same set of countries in 13/13 members, and in exactly the order CHI > GBR > RUS > FRA > USA in 13/13.
- Infrastructure is slack in aggregate (world utilization 36% → 42%) but shortages spread: states with usage > supply go 8.67 → 30.8 (cv 8.4%). Railways grow 18 → 99.2 levels with ~10% spread, the noisiest infrastructure metric.
- Industrialisation squeezes inputs: the biggest world price rises are engines +64%, iron +56%, tools +29%, clippers +29%, ammunition +25%; plantation goods glut (sugar -40%, tea -39%, coffee -27%, fertilizer -25%).
- Transportation is the standout shortage good for BOI: world supply covers only 12% of demand at the start and 22% at the end, and 99% → 91% of transport demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; watch orders and the at-ceiling share instead.

Contents: [Setup](#setup) · [World](#world) · [Noise and power](#noise-and-power) · [Great powers](#great-powers) · [Geopolitics](#geopolitics) · [Infrastructure](#infrastructure) · [Markets](#markets) · [Construction and urbanization](#construction-and-urbanization) · [Fiscal](#fiscal) · [BOI cheat-sheet](#boi-cheat-sheet) · [Appendix](#appendix)

## Setup

**A: `vanilla115_1836_1936_all`** (control). Every 1.15.0 game of the vanilla115_1836_1936 batch, including the 5 that crashed (in 1872, 1896, 1928, 1886 and 1899), each up to its last complete snapshot. Four crashes hit the same address in the snapshot's state loop and look unrelated to how the game develops, so the partial games add members past 1886. The 1899 game uses snapshot version 4, which starts in April 1836.

| item | value |
|:--|--:|
| members | 13 |
| snapshots per member | 41–41 of 41 (none dropped) |
| minutes per member | 9.9–142.2 (total 10.2 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | none (telemetry only) |
| telemetry modules | core, parity, ensemble |

**B: `boi115_pass4`** (mod). BOI 1.15.0 pass 4: pass 3 settings plus 3 seeded English Horse Ranches (14 levels) for the British market: Midlands 6, East Anglia 4, West Country 4

| item | value |
|:--|--:|
| members | 2 |
| snapshots per member | 40–40 of 41 (2 dropped as incomplete) |
| minutes per member | 13.2–14.6 (total 0.5 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | BurdenOfInfastructure @ 53ca96f5 (dirty) |
| telemetry modules | core, boi, housing, ensemble |

Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the second country under a tag in a member is labelled `TAG#2` (see `run_country`).

## World

![World trajectories](figures/world.svg)

| metric | 1836-01 | A 1846-01 | A growth | A sd | A cv | MDE (13 vs 2) | B 1846-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| GDP (world) | 363 M | 543 M | +49.4% | 6.28 M | 1.2% | 2.2% | 499 M | -8.1% | 0.005 | yes |
| Population | 993 M | 1.11 B | +11.8% | 4.26 M | 0.4% | 1.0% | 1.09 B | -1.7% | 0.091 | yes |
| Standard of living (pop-weighted) | 9.02 | 8.2 | -9.0% | 0.167 | 2.0% | 5.7% | 7.97 | -2.8% | 0.382 | no |
| Literacy (pop-weighted) | 20.8% | 29.7% | – | 0.8% | 2.8% | 4.5% | 28.2% | -4.9% | 0.000 | yes |
| Unemployed working adults | 7.33 M | 20.8 M | +184.0% | 733 k | 3.5% | 7.4% | 17.7 M | -15.0% | 0.044 | yes |
| Urbanization (points) | 84.1 k | 104 k | +24.0% | 1.17 k | 1.1% | 2.4% | 103 k | -1.1% | 0.318 | no |
| Countries alive | 291 | 269 | -7.5% | 3.25 | 1.2% | 2.3% | 272 | +1.2% | 0.221 | no |
| Wage (pop-weighted, /yr) | 0.435 | 0.533 | +22.6% | 0.017 | 3.2% | 6.3% | 0.531 | -0.4% | 0.832 | no |
| Radicals | 14.5 M | 93.5 M | +544.6% | 17.5 M | 18.7% | 40.2% | 87.6 M | -6.2% | 0.683 | no |
| Loyalists | 0 | 32.4 M | – | 4.11 M | 12.7% | 27.8% | 29 M | -10.3% | 0.402 | no |
| State turmoil (pop-weighted) | 1.5% | 8.4% | – | 1.6% | 18.7% | 41.0% | 8.0% | -4.5% | 0.773 | no |

CHI averages 33% of world population, so pop-weighted world SoL largely tracks it. The biggest one-quarter jump in any member (member 6, 1836-04 → 1836-07: 8.82 → 8.21) is CHI's SoL going 8.68 → 7.08. Compare SoL per country, or the powers' SoL panels, when testing welfare effects.

GDP rises +25.8% in the first half and +18.8% in the second. Population is nearly deterministic (cv 0.4%); welfare measures (SoL, unemployment, wage) carry 2–5% noise.

## Noise and power

![cv over time](figures/noise_cv.svg)

*Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, railways near 10%.*

![MDE by metric](figures/noise_mde.svg)

| metric | cv | MDE n=13 | n for 1% | n for 2% | n for 5% | n for 10% |
|:--|--:|--:|--:|--:|--:|--:|
| Population | 0.4% | 0.4% | 4 | 3 | 3 | 3 |
| Transportation price (clamped) | 0.4% | 0.4% | 4 | 3 | 3 | 3 |
| Port levels | 0.6% | 0.7% | 7 | 3 | 3 | 3 |
| Infrastructure supply | 1.1% | 1.3% | 21 | 6 | 3 | 3 |
| World GDP | 1.2% | 1.3% | 23 | 7 | 3 | 3 |
| Infrastructure usage | 1.5% | 1.7% | 37 | 10 | 3 | 3 |
| Urban center levels | 1.9% | 2.2% | 58 | 16 | 4 | 3 |
| Infra utilization | 1.9% | 2.2% | 59 | 16 | 4 | 3 |
| SoL | 2.0% | 2.3% | 67 | 18 | 4 | 3 |
| Livestock ranch levels | 2.2% | 2.5% | 75 | 20 | 5 | 3 |
| Literacy | 2.8% | 3.2% | 120 | 31 | 6 | 3 |
| Govt income | 3.2% | 3.7% | 164 | 42 | 8 | 3 |
| Wage | 3.2% | 3.7% | 166 | 43 | 8 | 3 |
| Tools price | 3.3% | 3.8% | 176 | 45 | 9 | 4 |
| Grain price | 3.5% | 4.0% | 191 | 49 | 9 | 4 |
| Unemployed | 3.5% | 4.0% | 196 | 50 | 9 | 4 |
| Govt expenses | 5.5% | 6.3% | 479 | 121 | 21 | 6 |
| Construction levels | 6.0% | 6.9% | 566 | 143 | 24 | 7 |
| Gold reserves | 8.3% | 9.5% | >1000 | 271 | 45 | 12 |
| Deficit states | 8.4% | 9.6% | >1000 | 275 | 45 | 13 |
| Countries in debt | 9.2% | 10.5% | >1000 | 331 | 54 | 15 |
| Railway levels | 9.9% | 11.4% | >1000 | 389 | 63 | 17 |
| Radicals | 18.7% | 21.4% | >1000 | >1000 | 221 | 56 |
| Countries at war | 94.4% | 108.1% | >1000 | >1000 | >1000 | >1000 |

n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), assuming the mod leaves the spread unchanged.

### Regimes: revolution waves

![Revolution-wave members](figures/regimes.svg)

## Great powers

The 17 countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP at 1846-01. Independent y-axes.

![GDP by power](figures/powers_gdp.svg)

![SoL by power](figures/powers_sol.svg)

![GDP rank distribution](figures/powers_rank.svg)

| power | GDP (median) | growth | GDP cv | SoL | railways | techs | time at war | great power at end | B GDP | B vs A | p |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| CHI | 105 M | +24.1% | 3.1% | 7.17 | 0 | 31 | 18% | 0/13 | 95.2 M | -9.2% | 0.059 |
| GBR | 36.8 M | +49.8% | 2.1% | 10.7 | 34 | 60 | 32% | 13/13 | 34.8 M | -5.6% | 0.303 |
| RUS | 30.5 M | +38.3% | 2.9% | 7.38 | 0 | 42 | 17% | 13/13 | 32.2 M | +4.7% | 0.501 |
| FRA | 27.3 M | +32.0% | 3.2% | 9.54 | 10 | 58 | 10% | 13/13 | 26.3 M | -3.9% | 0.281 |
| USA | 21.8 M | +40.6% | 5.0% | 10.9 | 10 | 59 | 4% | 13/13 | 21 M | -3.6% | 0.028 |
| AUS | 14.1 M | +47.5% | 19.7% | 7.7 | 7 | 54 | 4% | 13/13 | 12.4 M | -19.9% | 0.003 |
| JAP | 12.6 M | +16.6% | 4.5% | 8.93 | 0 | 36 | 0% | 0/13 | 12.3 M | -2.7% | 0.637 |
| PRU | 12.1 M | +29.0% | 4.6% | 9.45 | 9 | 59 | 0% | 13/13 | 12.2 M | -0.5% | 0.940 |
| TUR | 11.8 M | +16.1% | 6.2% | 7.72 | 0 | 33 | 11% | 8/13 | 11.2 M | -5.6% | 0.040 |
| SPA | 9.14 M | +45.0% | 2.5% | 9.36 | 0 | 44 | 36% | 11/13 | 9.01 M | -1.0% | – |
| BRZ | 7.65 M | +71.6% | 6.0% | 8.98 | 0 | 41 | 20% | 0/13 | 7.61 M | +1.7% | 0.846 |
| BEL | 4.61 M | +49.3% | 13.7% | 10.3 | 3 | 60 | 0% | 0/13 | 3.76 M | -18.8% | 0.000 |
| SIC | 4.56 M | +27.1% | 13.5% | 8.17 | 0 | 41 | 1% | 0/13 | 4.5 M | -1.4% | 0.716 |
| PAN | 4.15 M | +37.7% | 76.2% | 9.66 | 0 | 31 | 4% | 0/13 | 4.18 M | +39.8% | – |
| NET | 3.25 M | +34.2% | 8.5% | 11.2 | 2 | 54 | 3% | 0/13 | 3.04 M | -7.5% | 0.040 |
| SWE | 3.06 M | +39.6% | 9.3% | 10.2 | 3 | 54 | 0% | 0/13 | 3.32 M | +10.2% | 0.002 |
| SIA | 1.41 M | +28.9% | 7.3% | 8.94 | 0 | 28 | 10% | 0/13 | 1.08 M | -23.7% | 0.361 |

## Geopolitics

![Conflict and politics](figures/conflict.svg)

Countries at war swings between 0 and 52 at any snapshot; the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.

| event | countries (members out of 13) |
|:--|--:|
| annexed/gone in every member | – |
| gone in at least half | FZN (12), LAD (12), PNI (12), PRA (12), SPC (12), KZH (11), OZH (11), UZH (11), IQU (10), KAF (10), KAN (10), SPU (10), HER (9), SIN (9), BUR (7), CON (7), MAS (7), TEX (7), TKI (7) |
| formed (new tag) during the run | GUA (13), HON (13), NAL (13), ALT (12), COS (12), NIC (12), DOM (11), D00 (8), D01 (7), ZAN (7), D02 (6), D03 (6), LIM (6), D04 (5), D05 (5), TPG (5), KPR (4), BHT (3), RSM (3), AGJ (2), ASA (2), BUL (2), CAR (2), D06 (2), D07 (2), D08 (2), D14 (2), D15 (2), D16 (2), GAL (2), LAT (2), LOM (2), SUD (2), UKR (2), VEN (2), ABK (1), ABU (1), ACE (1), AGC (1), AIT (1), ALD (1), ALK (1), ALW (1), ANH (1), ANK (1), ARB (1), ARG (1), ARS (1), ASH (1), ASM (1), ATL (1), AUS (1), AWA (1), AWS (1), AZB (1), BAD (1), BAG (1), BAL (1), BAS (1), BAV (1), BCE (1), BEL (1), BEN (1), BER (1), BGI (1), BGL (1), BGM (1), BHN (1), BHO (1), BHU (1), BHV (1), BHW (1), BIC (1), BIK (1), BKH (1), BLG (1), BLH (1), BNJ (1), BNY (1), BOL (1), BOR (1), BOS (1), BRA (1), BRD (1), BRE (1), BRG (1), BRU (1), BRZ (1), BST (1), BTN (1), BUG (1), BUK (1), BUN (1), BUR (1), BYE (1), CAM (1), CHC (1), CHI (1), CHL (1), CHP (1), CHT (1), CIR (1), CLM (1), CMI (1), COB (1), COC (1), CON (1), COO (1), CRO (1), CUB (1), D09 (1), D10 (1), D11 (1), D12 (1), D13 (1), D17 (1), DAH (1), DAI (1), DEI (1), DEN (1), DFR (1), DHA (1), DIR (1), ECU (1), EGY (1), ELS (1), ETH (1), EZO (1), FIN (1), FRA (1), FRM (1), FTJ (1), FTR (1), FZN (1), GAR (1), GBR (1), GJM (1), GLD (1), GRE (1), GUJ (1), GWA (1), GZA (1), HAI (1), HAM (1), HAN (1), HAR (1), HAU (1), HAW (1), HBC (1), HDJ (1), HDY (1), HEK (1), HER (1), HES (1), HOH (1), HOL (1), HUN (1), HYD (1), IBL (1), IDA (1), IND (1), ION (1), IQU (1), ISQ (1), ITA (1), JAB (1), JAI (1), JAP (1), JAS (1), JEY (1), JHN (1), JMB (1), JOD (1), JOH (1), JUN (1), KAB (1), KAF (1), KAL (1), KAN (1), KAS (1), KAT (1), KAU (1), KAZ (1), KFA (1), KHI (1), KHP (1), KLT (1), KNO (1), KOK (1), KON (1), KOR (1), KOT (1), KRA (1), KRG (1), KRN (1), KRT (1), KTI (1), KUN (1), KUT (1), KZH (1), LAH (1), LAN (1), LAO (1), LIB (1), LIP (1), LIT (1), LUA (1), LUB (1), LUC (1), LUX (1), MAD (1), MAH (1), MAI (1), MAK (1), MAS (1), MBS (1), MEC (1), MEI (1), MEW (1), MEX (1), MGD (1), MJT (1), MKT (1), MLD (1), MNL (1), MNP (1), MOD (1), MOL (1), MON (1), MOR (1), MSN (1), MST (1), MUG (1), MYB (1), MYS (1), NAG (1), NAR (1), NAS (1), NAW (1), NBS (1), NEJ (1), NEP (1), NET (1), NOR (1), NPU (1), NSW (1), NVS (1), OLD (1), OMA (1), ONT (1), ORA (1), ORG (1), OYO (1), OZH (1), PAN (1), PAP (1), PAR (1), PBC (1), PCO (1), PER (1), PEU (1), PHI (1), PHL (1), PLP (1), PLY (1), PNI (1), POL (1), PON (1), POR (1), PRA (1), PRG (1), PRK (1), PRM (1), PRU (1), PTA (1), PTN (1), PUD (1), QUE (1), QWR (1), RAJ (1), ROM (1), RUS (1), RWD (1), RYU (1), SAF (1), SAK (1), SAR (1), SAS (1), SAT (1), SAX (1), SCH (1), SCM (1), SCW (1), SDM (1), SEL (1), SEQ (1), SER (1), SGU (1), SHS (1), SHW (1), SIA (1), SIC (1), SIK (1), SIL (1), SIN (1), SLO (1), SMB (1), SNA (1), SOK (1), SPA (1), SPC (1), SPU (1), SRK (1), STG (1), SUL (1), SUR (1), SVN (1), SWE (1), SWI (1), SWT (1), SWZ (1), TAS (1), TEX (1), TGI (1), TGR (1), TIB (1), TID (1), TJI (1), TKI (1), TRA (1), TRH (1), TRI (1), TRN (1), TRS (1), TUG (1), TUN (1), TUR (1), TUS (1), TWT (1), UBD (1), UCA (1), ULR (1), UNT (1), URU (1), USA (1), UYA (1), UZB (1), UZH (1), VNZ (1), WAD (1), WAL (1), WAS (1), WBL (1), WEI (1), WLD (1), WLG (1), WLT (1), WSG (1), WTU (1), WUR (1), YEM (1), YOG (1), YUG (1), ZAI (1), ZUL (1) |
| civil-war split (TAG#n) | AGC (12), AUS (7), HUN (7), JAP (7), KAT (7), MEC (7), POR (7), QUE (7), SAS (7), SIA (7), WTU (7), ALT (6), BEL (6), GRE (6), HAN (6), LAH (6), NEP (6), NSW (6), PER (6), TGI (6), ACE (5), BCE (5), BHN (5), BRA (5), DAI (5), HAM (5), HES (5), LUA (5), LUX (5), MAH (5), MST (5), NAL (5), NAS (5), ONT (5), PRU (5), SAF (5), SAR (5), SHS (5), SWE (5), WLT (5), ANH (4), BTN (4), FRA (4), HAI (4), KRA (4), KTI (4), MEI (4), NET (4), PAR (4), POL (4), PRK (4), STG (4), SWI (4), UBD (4), ASH (3), BAL (3), BAV (3), BRE (3), BUK (3), CHT (3), CIR (3), COS (3), CRO (3), DEN (3), FIN (3), FTJ (3), FTR (3), HAU (3), HAW (3), HOL (3), JAB (3), KBU (3), LIB (3), MOL (3), MYS (3), OMA (3), PAP (3), PON (3), SAX (3), SER (3), SIN (3), TRI (3), TUN (3), TUR (3), TUS (3), WSG (3), ZUL (3), ABU (2), ALK (2), BAD (2), BEN (2), BOL (2), BRZ (2), BST (2), CAM (2), CAR (2), CMI (2), DEI (2), EGY (2), EWE (2), HAR (2), HEK (2), IND (2), ION (2), JHN (2), JOH (2), KOR (2), KPR (2), MBS (2), MEW (2), NEJ (2), OLD (2), PCO (2), RSM (2), RYU (2), SCH (2), SGU (2), SIC (2), SIL (2), SUL (2), SUR (2), TAS (2), TIB (2), TRN (2), WAS (2), WUR (2), AIN (1), ALW (1), ARB (1), ATB (1), AWA (1), BAG (1), BAS (1), BER (1), BHO (1), BHT (1), BHV (1), BHW (1), BKH (1), BLH (1), BNG (1), BRN (1), BRU (1), BUG (1), BUL (1), BUN (1), BUR (1), CHC (1), CHP (1), COC (1), DAH (1), DHA (1), DIR (1), DLA (1), DOM (1), ECU (1), GAL (1), GUA (1), GZA (1), HBC (1), HDJ (1), HDY (1), HRO (1), IBO (1), IDA (1), ISQ (1), JAI (1), JAS (1), JEY (1), JUN (1), KAL (1), KBA (1), KHI (1), KNK (1), KON (1), KOT (1), KRG (1), KRT (1), LOM (1), MAD (1), MAK (1), MGD (1), MJT (1), MOD (1), MSN (1), MUG (1), MYB (1), NAR (1), NAW (1), NOR (1), OYO (1), PHI (1), PHL (1), PRG (1), PTA (1), PTN (1), RUS (1), RWD (1), SAK (1), SAT (1), SEL (1), SEQ (1), SOK (1), SPA (1), SPC (1), SWT (1), SWZ (1), TID (1), TNG (1), TPG (1), TRA (1), TSW (1), TUA (1), TUG (1), URU (1), UYA (1), VEN (1), VNZ (1), WAL (1), WBL (1), YUG (1), ZAN (1) |

Civil wars that happen in at least 80% of members are background: AGC. 

## Infrastructure

![Infrastructure](figures/infrastructure.svg)

![State infrastructure scatter](figures/states_scatter.svg)

*States with zero usage sit on the bottom edge (log scale).*

![State utilization distribution](figures/states_utilization.svg)

States short of infrastructure in at least half the members at 1846-01 (19 states; median values across members):

| state | owner | short in | supply | usage | shortfall | population |
|:--|--:|--:|--:|--:|--:|--:|
| Bahia | BRZ | 13/13 | 33.4 | 35.9 | 2.5 | 787 k |
| Kenya | MBS | 13/13 | 4 | 5.2 | 1.2 | 31.7 k |
| Tiflis | SVN | 13/13 | 3.5 | 4.5 | 1 | 27.2 k |
| Mocambique | AGC | 13/13 | 4.2 | 5 | 0.8 | 13.7 k |
| Pernambuco | BRZ | 12/13 | 28.8 | 30.6 | 1.8 | 716 k |
| Transorangia | PHL | 12/13 | 4.5 | 5.5 | 1 | 37.6 k |
| Potosí | BOL | 11/11 | 8.9 | 10.5 | 1.6 | 157 k |
| Yemen | MAH | 10/12 | 5.45 | 6.2 | 0.75 | 38.1 k |
| Yemen | KAT | 10/13 | 6 | 6.3 | 0.3 | 50.1 k |
| Yezo | EZO | 9/11 | 4.2 | 5.2 | 1 | 36.8 k |
| Hormuz | BHN | 9/13 | 3.3 | 4 | 0.7 | 7.56 k |
| Uralsk | BKH | 9/9 | 5.4 | 5.8 | 0.4 | 56.3 k |
| Ceará | BRZ | 9/13 | 10.8 | 11.2 | 0.4 | 251 k |
| Eastern Himalayas | BHU | 9/13 | 10.8 | 9.8 | -1 | 186 k |
| Minas Gerais | BRZ | 8/13 | 28.4 | 29.8 | 1.4 | 765 k |
| Trucial Coast | BHN | 8/13 | 5.5 | 6.2 | 0.7 | 39.1 k |
| Maranhão | BRZ | 8/13 | 10.5 | 11.2 | 0.7 | 237 k |
| Zululand | NAL | 7/10 | 5.25 | 7.6 | 2.35 | 34.2 k |
| Paraíba | BRZ | 7/13 | 10 | 10 | 0 | 223 k |

Market access is uninformative in vanilla: pop-weighted world market access stays at 99.9% (cv 0.03%). Deficits in vanilla don't yet cut states off; BOI changing that would show up here immediately.

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
| grain | 15.8 | 17.1 | +7.9% | 3.5% | 70.7 k | 1.20 | 0% |
| wood | 20.8 | 23.7 | +13.9% | 3.3% | 56.7 k | 0.84 | 4% |
| fabric | 16.6 | 15.1 | -9.1% | 4.3% | 35.6 k | 1.35 | 1% |
| services | 19.6 | 24 | +22.3% | 1.9% | 31.5 k | 1.28 | 0% |
| clothes | 32.3 | 35.2 | +9.3% | 1.2% | 30.4 k | 0.84 | 3% |
| fruit | 41.8 | 34.7 | -16.9% | 3.6% | 24.5 k | 0.87 | 0% |
| furniture | 30 | 35.4 | +17.8% | 1.8% | 24 k | 0.85 | 7% |
| transportation | 52.4 | 51.9 | -0.9% | 0.4% | 21.9 k | 0.22 | 91% |
| meat | 42.8 | 36.7 | -14.3% | 1.5% | 18.8 k | 0.82 | 16% |
| paper | 34.4 | 42.6 | +23.8% | 2.6% | 15.1 k | 0.66 | 3% |
| fish | 19.1 | 19.2 | +0.6% | 2.4% | 14 k | 1.06 | 0% |
| liquor | 26.5 | 29.3 | +10.8% | 3.1% | 13.8 k | 1.07 | 4% |
| tobacco | 37.5 | 35 | -6.9% | 3.3% | 12.4 k | 1.21 | 0% |
| tools | 39.4 | 51 | +29.4% | 3.3% | 12.3 k | 0.76 | 5% |
| tea | 57.1 | 34.9 | -38.8% | 3.8% | 11.4 k | 1.46 | 2% |
| iron | 37.4 | 58.3 | +55.6% | 4.1% | 10.6 k | 0.64 | 20% |
| groceries | 45.7 | 41.4 | -9.4% | 1.8% | 9.38 k | 0.67 | 4% |
| opium | 57.8 | 56.2 | -2.8% | 5.3% | 8.81 k | 0.97 | 24% |
| coal | 30.2 | 34.9 | +15.6% | 3.3% | 8.15 k | 0.84 | 2% |
| luxury_clothes | 64.6 | 74.4 | +15.2% | 2.6% | 7.52 k | 0.83 | 21% |
| sugar | 33.6 | 20.3 | -39.6% | 6.1% | 6.04 k | 1.52 | 5% |
| silk | 44.8 | 41.2 | -8.2% | 4.3% | 5.92 k | 0.99 | 6% |
| hardwood | 49.6 | 51.6 | +4.0% | 4.0% | 5.15 k | 0.76 | 7% |
| clippers | 45 | 57.8 | +28.6% | 2.4% | 4.77 k | 1.08 | 4% |
| coffee | 60.9 | 44.7 | -26.6% | 3.8% | 4.48 k | 1.23 | 1% |
| luxury_furniture | 67.5 | 79.2 | +17.4% | 2.7% | 4.24 k | 0.69 | 26% |
| small_arms | 69.4 | 65.2 | -6.1% | 3.7% | 3.85 k | 0.95 | 7% |
| wine | 26.1 | 28.4 | +8.9% | 7.9% | 3.24 k | 1.64 | 0% |
| dye | 19.3 | 16.4 | -14.9% | 4.0% | 2.77 k | 3.05 | 0% |
| porcelain | 93.8 | 115 | +22.5% | 1.3% | 2.52 k | 0.47 | 51% |

## Construction and urbanization

Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes for it, and ranching (horses come from livestock).

![Construction and urbanization](figures/construction.svg)

| metric | 1836-01 | A 1846-01 | A growth | A sd | A cv | MDE (13 vs 2) | B 1846-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| Construction sector levels | 83 | 679 | +718.5% | 40.7 | 6.0% | 11.4% | 564 | -17.1% | 0.032 | yes |
| Urban center levels | 601 | 822 | +36.8% | 15.6 | 1.9% | 3.9% | 812 | -1.3% | 0.398 | no |
| Non-subsistence building levels | 44.5 k | 50.9 k | +14.3% | 348 | 0.7% | 1.8% | 51.7 k | +1.7% | 0.188 | no |
| Light industry levels | 1 k | 1.08 k | +7.4% | 15.1 | 1.4% | 2.8% | 1.02 k | -5.5% | 0.031 | yes |
| Heavy industry levels | 34 | 52.3 | +53.8% | 2.5 | 4.8% | 8.9% | 50 | -4.4% | 0.189 | no |
| Livestock ranch levels | 487 | 715 | +46.8% | 15.5 | 2.2% | 5.5% | 655 | -8.4% | 0.108 | yes |
| Urbanization (points) | 84.1 k | 104 k | +24.0% | 1.17 k | 1.1% | 2.4% | 103 k | -1.1% | 0.318 | no |

## Fiscal

![Fiscal](figures/fiscal.svg)

| metric | 1836-01 | A 1846-01 | A growth | A sd | A cv | MDE (13 vs 2) | B 1846-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| Gold reserves | 16 M | 70.5 M | +340.9% | 5.84 M | 8.3% | 35.0% | 60.5 M | -14.1% | 0.496 | no |
| Countries in debt | 15 | 74.6 | +397.4% | 6.84 | 9.2% | 22.6% | 74.5 | -0.2% | 0.987 | no |
| Income /wk | 1.75 M | 3.24 M | +85.3% | 104 k | 3.2% | 7.8% | 3.15 M | -2.9% | 0.440 | no |
| Expenses /wk | 1.54 M | 3.11 M | +102.2% | 172 k | 5.5% | 14.9% | 3.04 M | -2.2% | 0.745 | no |
| Net income /wk | 210 k | 128 k | -38.9% | 89.5 k | – | 182.4% | 102 k | -20.3% | 0.800 | no |

World net government income goes 210 k → 128 k per week: spending outgrows revenue, which is the headroom BOI's road financing competes for.

## BOI cheat-sheet

Values at 1846-01. Compare a BOI ensemble's mean against these; a difference smaller than the MDE is indistinguishable from vanilla noise with 13 members per arm.

| metric | mean | sd | cv | MDE (n=13) | n for 2% | n for 5% | B mean | B vs A | p |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| World GDP | 543 M | 6.28 M | 1.2% | 1.3% | 7 | 3 | 499 M | -8.1% | 0.005 |
| SoL | 8.2 | 0.167 | 2.0% | 2.3% | 18 | 4 | 7.97 | -2.8% | 0.382 |
| Unemployed | 20.8 M | 733 k | 3.5% | 4.0% | 50 | 9 | 17.7 M | -15.0% | 0.044 |
| Wage | 0.533 | 0.017 | 3.2% | 3.7% | 43 | 8 | 0.531 | -0.4% | 0.832 |
| Infrastructure supply | 30.1 k | 332 | 1.1% | 1.3% | 6 | 3 | 28.6 k | -5.0% | 0.093 |
| Infrastructure usage | 12.6 k | 189 | 1.5% | 1.7% | 10 | 3 | 16.2 k | +28.1% | 0.000 |
| Utilization | 42.0% | 0.8% | 1.9% | 2.2% | 16 | 4 | 56.6% | +34.8% | 0.010 |
| Deficit states | 30.8 | 2.58 | 8.4% | 9.6% | 275 | 45 | 30 | -2.7% | 0.556 |
| Railway levels | 99.2 | 9.86 | 9.9% | 11.4% | 389 | 63 | 81 | -18.4% | 0.018 |
| Port levels | 378 | 2.25 | 0.6% | 0.7% | 3 | 3 | 382 | +1.1% | 0.268 |
| Construction levels | 679 | 40.7 | 6.0% | 6.9% | 143 | 24 | 564 | -17.1% | 0.032 |
| Urban center levels | 822 | 15.6 | 1.9% | 2.2% | 16 | 4 | 812 | -1.3% | 0.398 |
| Livestock ranch levels | 715 | 15.5 | 2.2% | 2.5% | 20 | 5 | 655 | -8.4% | 0.108 |
| Gold reserves | 70.5 M | 5.84 M | 8.3% | 9.5% | 271 | 45 | 60.5 M | -14.1% | 0.496 |
| Countries in debt | 74.6 | 6.84 | 9.2% | 10.5% | 331 | 54 | 74.5 | -0.2% | 0.987 |
| Govt expenses | 3.11 M | 172 k | 5.5% | 6.3% | 121 | 21 | 3.04 M | -2.2% | 0.745 |
| Transportation price | 51.9 | 0.202 | 0.4% | 0.4% | 3 | 3 | 51.3 | -1.2% | 0.000 |
| Transport demand at ceiling | 90.7% | 3.1% | 3.4% | 3.9% | 48 | 9 | 85.6% | -5.6% | 0.038 |
| Transportation demand | 21.9 k | 519 | 2.4% | 2.7% | 23 | 5 | 16.8 k | -23.5% | 0.000 |
| Merchant marine price | 43.9 | 1.92 | 4.4% | 5.0% | 76 | 14 | 52.5 | +19.4% | 0.001 |
| Services price | 24 | 0.462 | 1.9% | 2.2% | 16 | 4 | 19.1 | -20.3% | 0.032 |
| Wood price | 23.7 | 0.788 | 3.3% | 3.8% | 45 | 9 | 23.7 | +0.0% | 0.996 |
| Grain price | 17.1 | 0.593 | 3.5% | 4.0% | 49 | 9 | 17.7 | +3.6% | 0.032 |
| Groceries price | 41.4 | 0.73 | 1.8% | 2.0% | 14 | 4 | 43.4 | +4.8% | 0.207 |
| Tools price | 51 | 1.7 | 3.3% | 3.8% | 45 | 9 | 50.7 | -0.6% | 0.654 |

## Appendix

- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. It reads only the database.
- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same day; `t` counts quarters from 1836-01.
- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, wage, market access and turmoil. World goods: summed orders, demand-weighted price.
- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.
- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance of a wave changes means through that alone.
- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.

