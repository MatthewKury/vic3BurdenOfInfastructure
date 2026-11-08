# Ensemble report: vanilla115_1836_1936_all vs rs_pass4

Generated 2026-11-08 by `tools/ensembles/Make-EnsembleReport.py` from `tools/ensembles/ensembles.sqlite`. 10 members (A) vs 1 (B), 1836-01-02 to 1851-01-01, quarterly; game 1.15.0.

Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; shown as % of the mean.

## Key findings

- World GDP grows +66.4% over 15 years (member spread 2.6% cv); pop-weighted SoL falls 9.02 → 8.31 and unemployment goes ×3.7 (7.33 M → 26.9 M): the world gets richer in total and poorer per head.
- With 10 vs 10 members the minimum detectable effect is 3%–6% for world GDP, SoL, infrastructure usage, urban centers and ranches; 7%–25% for unemployment, construction and gold; 4%–21% for deficit states and railways. Wars are untestable (MDE 91%). Clamped prices (transport) look precise only because they can't move.
- Power trajectories differ a lot in predictability: GDP cv at the end is lowest for JAP, SIA, FRA, SPA and highest for PAN, NET, BEL, CHI. The GDP top five is the same set of countries in 10/10 members, and in exactly the order CHI > GBR > RUS > FRA > USA in 8/10.
- Infrastructure is slack in aggregate (world utilization 36% → 44%) but shortages spread: states with usage > supply go 8.67 → 43.3 (cv 15.6%). Railways grow 18 → 162 levels with ~3% spread, the noisiest infrastructure metric.
- Industrialisation squeezes inputs: the biggest world price rises are engines +69%, iron +46%, ammunition +45%, glass +41%, explosives +37%; plantation goods glut (tea -42%, sugar -41%, coffee -32%, fruit -21%).
- Transportation is the standout shortage good for BOI: world supply covers only 12% of demand at the start and 29% at the end, and 99% → 83% of transport demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; watch orders and the at-ceiling share instead.

Contents: [Setup](#setup) · [World](#world) · [Noise and power](#noise-and-power) · [Great powers](#great-powers) · [Geopolitics](#geopolitics) · [Infrastructure](#infrastructure) · [Markets](#markets) · [Construction and urbanization](#construction-and-urbanization) · [Fiscal](#fiscal) · [BOI cheat-sheet](#boi-cheat-sheet) · [Appendix](#appendix)

## Setup

**A: `vanilla115_1836_1936_all`** (control). Every 1.15.0 game of the vanilla115_1836_1936 batch, including the 5 that crashed (in 1872, 1896, 1928, 1886 and 1899), each up to its last complete snapshot. Four crashes hit the same address in the snapshot's state loop and look unrelated to how the game develops, so the partial games add members past 1886. The 1899 game uses snapshot version 4, which starts in April 1836.

| item | value |
|:--|--:|
| members | 10 |
| snapshots per member | 61–61 of 61 (none dropped) |
| minutes per member | 21.9–142.2 (total 9.7 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | none (telemetry only) |
| telemetry modules | core, parity, ensemble |

**B: `rs_pass4`** (mod). Rail survey pass 4 (2026-11-08): Rail Works 2.5x, cap 1/2/4, repeat surveys +20%, AI pass debt check instead of gold; Horse Ranch by-product and fencing groups; housing seed privately owned; housing laws in the Social tab

| item | value |
|:--|--:|
| members | 1 |
| snapshots per member | 60–60 of 61 (1 dropped as incomplete) |
| minutes per member | 20.4–20.4 (total 0.3 h) |
| game version | 1.15.0 |
| DLC installed / disabled | 18 / 0 |
| mods | BurdenOfInfastructure @ 53ca96f5 (dirty) |
| telemetry modules | core, boi, rail_survey, housing, ensemble |

Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the second country under a tag in a member is labelled `TAG#2` (see `run_country`).

## World

![World trajectories](figures/world.svg)

| metric | 1836-01 | A 1851-01 | A growth | A sd | A cv | MDE (10 vs 1) | B 1851-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| GDP (world) | 363 M | 604 M | +66.4% | 15.9 M | 2.6% | – | 563 M | -6.9% | – | no |
| Population | 993 M | 1.16 B | +16.7% | 4.87 M | 0.4% | – | 1.13 B | -2.3% | – | no |
| Standard of living (pop-weighted) | 9.02 | 8.31 | -7.8% | 0.394 | 4.7% | – | 8.09 | -2.7% | – | no |
| Literacy (pop-weighted) | 20.8% | 31.8% | – | 1.4% | 4.4% | – | 29.4% | -7.6% | – | no |
| Unemployed working adults | 7.33 M | 26.9 M | +267.2% | 1.36 M | 5.1% | – | 23 M | -14.5% | – | no |
| Urbanization (points) | 84.1 k | 122 k | +45.1% | 2.95 k | 2.4% | – | 119 k | -2.3% | – | no |
| Countries alive | 291 | 258 | -11.3% | 3.26 | 1.3% | – | 257 | -0.5% | – | no |
| Wage (pop-weighted, /yr) | 0.435 | 0.597 | +37.4% | 0.034 | 5.6% | – | 0.577 | -3.4% | – | no |
| Radicals | 14.5 M | 100 M | +591.2% | 9.4 M | 9.4% | – | 87.3 M | -12.9% | – | no |
| Loyalists | 0 | 36.9 M | – | 2.71 M | 7.4% | – | 26.8 M | -27.2% | – | no |
| State turmoil (pop-weighted) | 1.5% | 8.6% | – | 0.8% | 9.4% | – | 7.7% | -10.9% | – | no |

CHI averages 33% of world population, so pop-weighted world SoL largely tracks it. The biggest one-quarter jump in any member (member 6, 1836-04 → 1836-07: 8.82 → 8.21) is CHI's SoL going 8.68 → 7.08. Compare SoL per country, or the powers' SoL panels, when testing welfare effects.

GDP rises +37.1% in the first half and +21.4% in the second (front-loaded). Population is nearly deterministic (cv 0.4%); welfare measures (SoL, unemployment, wage) carry 2–5% noise.

## Noise and power

![cv over time](figures/noise_cv.svg)

*Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, railways near 10%.*

![MDE by metric](figures/noise_mde.svg)

| metric | cv | MDE n=10 | n for 1% | n for 2% | n for 5% | n for 10% |
|:--|--:|--:|--:|--:|--:|--:|
| Population | 0.4% | 0.6% | 4 | 3 | 3 | 3 |
| Port levels | 0.8% | 1.1% | 12 | 4 | 3 | 3 |
| Infrastructure supply | 1.6% | 2.1% | 39 | 11 | 3 | 3 |
| Transportation price (clamped) | 1.8% | 2.3% | 51 | 14 | 4 | 3 |
| Infrastructure usage | 2.1% | 2.8% | 71 | 19 | 4 | 3 |
| Infra utilization | 2.6% | 3.5% | 109 | 28 | 6 | 3 |
| World GDP | 2.6% | 3.5% | 110 | 29 | 6 | 3 |
| Livestock ranch levels | 3.2% | 4.2% | 158 | 41 | 8 | 3 |
| Railway levels | 3.2% | 4.3% | 167 | 43 | 8 | 3 |
| Urban center levels | 3.3% | 4.3% | 169 | 43 | 8 | 3 |
| Tools price | 3.6% | 4.8% | 203 | 52 | 10 | 4 |
| Grain price | 4.1% | 5.5% | 268 | 68 | 12 | 4 |
| Literacy | 4.4% | 5.9% | 308 | 78 | 14 | 5 |
| SoL | 4.7% | 6.3% | 353 | 89 | 16 | 5 |
| Unemployed | 5.1% | 6.7% | 405 | 102 | 18 | 6 |
| Wage | 5.6% | 7.4% | 497 | 125 | 21 | 7 |
| Govt income | 7.6% | 10.0% | 896 | 225 | 37 | 11 |
| Construction levels | 7.7% | 10.2% | 926 | 233 | 38 | 11 |
| Countries in debt | 7.8% | 10.4% | 969 | 243 | 40 | 11 |
| Govt expenses | 9.0% | 12.0% | >1000 | 322 | 53 | 14 |
| Radicals | 9.4% | 12.4% | >1000 | 347 | 57 | 15 |
| Deficit states | 15.6% | 20.6% | >1000 | 951 | 153 | 39 |
| Gold reserves | 19.2% | 25.5% | >1000 | >1000 | 233 | 59 |
| Countries at war | 68.9% | 91.3% | >1000 | >1000 | >1000 | 747 |

n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), assuming the mod leaves the spread unchanged.

### Regimes: revolution waves

![Revolution-wave members](figures/regimes.svg)

## Great powers

The 17 countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP at 1851-01. Independent y-axes.

![GDP by power](figures/powers_gdp.svg)

![SoL by power](figures/powers_sol.svg)

![GDP rank distribution](figures/powers_rank.svg)

| power | GDP (median) | growth | GDP cv | SoL | railways | techs | time at war | great power at end | B GDP | B vs A | p |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| CHI | 111 M | +30.7% | 21.9% | 7.37 | 0 | 35 | 15% | 0/10 | 107 M | +5.2% | – |
| GBR | 43.7 M | +78.1% | 7.9% | 11.2 | 44.5 | 68 | 36% | 10/10 | 37.2 M | -13.7% | – |
| RUS | 32 M | +45.1% | 6.1% | 8.22 | 0 | 47 | 19% | 10/10 | 31.3 M | -2.0% | – |
| FRA | 29.1 M | +41.4% | 5.3% | 10.3 | 12 | 63.5 | 13% | 10/10 | 29.9 M | +3.8% | – |
| USA | 24.9 M | +60.6% | 8.0% | 11 | 16.5 | 66 | 10% | 9/10 | 25 M | +0.1% | – |
| AUS | 17 M | +77.5% | 17.5% | 9.59 | 10 | 59 | 6% | 10/10 | 12.6 M | -28.7% | – |
| JAP | 14.6 M | +34.6% | 4.4% | 8.68 | 0 | 42.5 | 0% | 0/10 | 16 M | +11.6% | – |
| PRU | 13.3 M | +41.5% | 13.5% | 10.1 | 13 | 64 | 3% | 8/10 | 12.7 M | -0.9% | – |
| TUR | 12.4 M | +22.2% | 11.9% | 8.61 | 0 | 37.5 | 17% | 2/10 | 12.2 M | -6.1% | – |
| SPA | 10 M | +58.9% | 5.7% | 9.64 | 1 | 49 | 24% | 8/10 | – | – | – |
| BRZ | 8.39 M | +87.6% | 6.8% | 9.14 | 0 | 46 | 16% | 0/10 | 9.13 M | +9.6% | – |
| BEL | 5.6 M | +81.5% | 28.0% | 10.9 | 4 | 66.5 | 2% | 0/10 | 4.67 M | -22.6% | – |
| SIC | 4.53 M | +26.2% | 11.8% | 8.5 | 0 | 46 | 1% | 0/10 | 6.48 M | +46.0% | – |
| PAN | 4.31 M | +43.0% | 65.4% | 9.14 | 0 | 35 | 6% | 0/10 | 1.38 M | -59.3% | – |
| NET | 3.94 M | +63.1% | 28.7% | 11.3 | 4.5 | 60.5 | 6% | 0/10 | 4.3 M | +11.7% | – |
| SWE | 3.75 M | +71.1% | 12.3% | 10.6 | 4 | 60.5 | 1% | 0/10 | 3.93 M | +5.8% | – |
| SIA | 1.56 M | +43.1% | 5.2% | 8.16 | 0 | 33 | 10% | 0/10 | 1.34 M | -14.5% | – |

## Geopolitics

![Conflict and politics](figures/conflict.svg)

Countries at war swings between 0 and 66 at any snapshot; the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.

| event | countries (members out of 10) |
|:--|--:|
| annexed/gone in every member | HER, IDA, KAF, SIN, TEX |
| gone in at least half | CRO (9), KAU (9), KUN (9), LUX (9), MOD (9), SUL (9), TKI (9), TRS (9), UNT (9), AIT (8), BGM (8), BTN (8), CON (8), HUN (8), KUT (8), KAS (7), NAG (7), NBS (7), NVS (7), BRG (6), HBC (6), HDY (6), ISQ (6), KOT (6), MAI (6), MAK (6), MNP (6), NAS (6), QUE (6), SAK (6), SHS (6), WLG (6), BAS (5), BKH (5), BRD (5), EZO (5), HAM (5), KAL (5), KFA (5), KNO (5), KOK (5), KRA (5), MAH (5), MYB (5), PAN (5), PLP (5), SDM (5), SUR (5), TRA (5), TUG (5), WAS (5), WLT (5) |
| formed (new tag) during the run | GUA (13), HON (13), NAL (13), ALT (12), COS (12), NIC (12), DOM (11), D00 (8), D01 (7), ZAN (7), D02 (6), D03 (6), LIM (6), D04 (5), D05 (5), TPG (5), KPR (4), BHT (3), RSM (3), AGJ (2), ASA (2), BUL (2), CAR (2), D06 (2), D07 (2), D08 (2), D14 (2), D15 (2), D16 (2), GAL (2), LAT (2), LOM (2), SUD (2), UKR (2), VEN (2), ABK (1), ABU (1), ACE (1), AGC (1), AIT (1), ALD (1), ALK (1), ALW (1), ANH (1), ANK (1), ARB (1), ARG (1), ARS (1), ASH (1), ASM (1), ATL (1), AUS (1), AWA (1), AWS (1), AZB (1), BAD (1), BAG (1), BAL (1), BAS (1), BAV (1), BCE (1), BEL (1), BEN (1), BER (1), BGI (1), BGL (1), BGM (1), BHN (1), BHO (1), BHU (1), BHV (1), BHW (1), BIC (1), BIK (1), BKH (1), BLG (1), BLH (1), BNJ (1), BNY (1), BOL (1), BOR (1), BOS (1), BRA (1), BRD (1), BRE (1), BRG (1), BRU (1), BRZ (1), BST (1), BTN (1), BUG (1), BUK (1), BUN (1), BUR (1), BYE (1), CAM (1), CHC (1), CHI (1), CHL (1), CHP (1), CHT (1), CIR (1), CLM (1), CMI (1), COB (1), COC (1), CON (1), COO (1), CRO (1), CUB (1), D09 (1), D10 (1), D11 (1), D12 (1), D13 (1), D17 (1), DAH (1), DAI (1), DEI (1), DEN (1), DFR (1), DHA (1), DIR (1), ECU (1), EGY (1), ELS (1), ETH (1), EZO (1), FIN (1), FRA (1), FRM (1), FTJ (1), FTR (1), FZN (1), GAR (1), GBR (1), GJM (1), GLD (1), GRE (1), GUJ (1), GWA (1), GZA (1), HAI (1), HAM (1), HAN (1), HAR (1), HAU (1), HAW (1), HBC (1), HDJ (1), HDY (1), HEK (1), HER (1), HES (1), HOH (1), HOL (1), HUN (1), HYD (1), IBL (1), IDA (1), IND (1), ION (1), IQU (1), ISQ (1), ITA (1), JAB (1), JAI (1), JAP (1), JAS (1), JEY (1), JHN (1), JMB (1), JOD (1), JOH (1), JUN (1), KAB (1), KAF (1), KAL (1), KAN (1), KAS (1), KAT (1), KAU (1), KAZ (1), KFA (1), KHI (1), KHP (1), KLT (1), KNO (1), KOK (1), KON (1), KOR (1), KOT (1), KRA (1), KRG (1), KRN (1), KRT (1), KTI (1), KUN (1), KUT (1), KZH (1), LAH (1), LAN (1), LAO (1), LIB (1), LIP (1), LIT (1), LUA (1), LUB (1), LUC (1), LUX (1), MAD (1), MAH (1), MAI (1), MAK (1), MAS (1), MBS (1), MEC (1), MEI (1), MEW (1), MEX (1), MGD (1), MJT (1), MKT (1), MLD (1), MNL (1), MNP (1), MOD (1), MOL (1), MON (1), MOR (1), MSN (1), MST (1), MUG (1), MYB (1), MYS (1), NAG (1), NAR (1), NAS (1), NAW (1), NBS (1), NEJ (1), NEP (1), NET (1), NOR (1), NPU (1), NSW (1), NVS (1), OLD (1), OMA (1), ONT (1), ORA (1), ORG (1), OYO (1), OZH (1), PAN (1), PAP (1), PAR (1), PBC (1), PCO (1), PER (1), PEU (1), PHI (1), PHL (1), PLP (1), PLY (1), PNI (1), POL (1), PON (1), POR (1), PRA (1), PRG (1), PRK (1), PRM (1), PRU (1), PTA (1), PTN (1), PUD (1), QUE (1), QWR (1), RAJ (1), ROM (1), RUS (1), RWD (1), RYU (1), SAF (1), SAK (1), SAR (1), SAS (1), SAT (1), SAX (1), SCH (1), SCM (1), SCW (1), SDM (1), SEL (1), SEQ (1), SER (1), SGU (1), SHS (1), SHW (1), SIA (1), SIC (1), SIK (1), SIL (1), SIN (1), SLO (1), SMB (1), SNA (1), SOK (1), SPA (1), SPC (1), SPU (1), SRK (1), STG (1), SUL (1), SUR (1), SVN (1), SWE (1), SWI (1), SWT (1), SWZ (1), TAS (1), TEX (1), TGI (1), TGR (1), TIB (1), TID (1), TJI (1), TKI (1), TRA (1), TRH (1), TRI (1), TRN (1), TRS (1), TUG (1), TUN (1), TUR (1), TUS (1), TWT (1), UBD (1), UCA (1), ULR (1), UNT (1), URU (1), USA (1), UYA (1), UZB (1), UZH (1), VNZ (1), WAD (1), WAL (1), WAS (1), WBL (1), WEI (1), WLD (1), WLG (1), WLT (1), WSG (1), WTU (1), WUR (1), YEM (1), YOG (1), YUG (1), ZAI (1), ZUL (1) |
| civil-war split (TAG#n) | AGC (12), AUS (7), HUN (7), JAP (7), KAT (7), MEC (7), POR (7), QUE (7), SAS (7), SIA (7), WTU (7), ALT (6), BEL (6), GRE (6), HAN (6), LAH (6), NEP (6), NSW (6), PER (6), TGI (6), ACE (5), BCE (5), BHN (5), BRA (5), DAI (5), HAM (5), HES (5), LUA (5), LUX (5), MAH (5), MST (5), NAL (5), NAS (5), ONT (5), PRU (5), SAF (5), SAR (5), SHS (5), SWE (5), WLT (5), ANH (4), BTN (4), FRA (4), HAI (4), KRA (4), KTI (4), MEI (4), NET (4), PAR (4), POL (4), PRK (4), STG (4), SWI (4), UBD (4), ASH (3), BAL (3), BAV (3), BRE (3), BUK (3), CHT (3), CIR (3), COS (3), CRO (3), DEN (3), FIN (3), FTJ (3), FTR (3), HAU (3), HAW (3), HOL (3), JAB (3), KBU (3), LIB (3), MOL (3), MYS (3), OMA (3), PAP (3), PON (3), SAX (3), SER (3), SIN (3), TRI (3), TUN (3), TUR (3), TUS (3), WSG (3), ZUL (3), ABU (2), ALK (2), BAD (2), BEN (2), BOL (2), BRZ (2), BST (2), CAM (2), CAR (2), CMI (2), DEI (2), EGY (2), EWE (2), HAR (2), HEK (2), IND (2), ION (2), JHN (2), JOH (2), KOR (2), KPR (2), MBS (2), MEW (2), NEJ (2), OLD (2), PCO (2), RSM (2), RYU (2), SCH (2), SGU (2), SIC (2), SIL (2), SUL (2), SUR (2), TAS (2), TIB (2), TRN (2), WAS (2), WUR (2), AIN (1), ALW (1), ARB (1), ATB (1), AWA (1), BAG (1), BAS (1), BER (1), BHO (1), BHT (1), BHV (1), BHW (1), BKH (1), BLH (1), BNG (1), BRN (1), BRU (1), BUG (1), BUL (1), BUN (1), BUR (1), CHC (1), CHP (1), COC (1), DAH (1), DHA (1), DIR (1), DLA (1), DOM (1), ECU (1), GAL (1), GUA (1), GZA (1), HBC (1), HDJ (1), HDY (1), HRO (1), IBO (1), IDA (1), ISQ (1), JAI (1), JAS (1), JEY (1), JUN (1), KAL (1), KBA (1), KHI (1), KNK (1), KON (1), KOT (1), KRG (1), KRT (1), LOM (1), MAD (1), MAK (1), MGD (1), MJT (1), MOD (1), MSN (1), MUG (1), MYB (1), NAR (1), NAW (1), NOR (1), OYO (1), PHI (1), PHL (1), PRG (1), PTA (1), PTN (1), RUS (1), RWD (1), SAK (1), SAT (1), SEL (1), SEQ (1), SOK (1), SPA (1), SPC (1), SWT (1), SWZ (1), TID (1), TNG (1), TPG (1), TRA (1), TSW (1), TUA (1), TUG (1), URU (1), UYA (1), VEN (1), VNZ (1), WAL (1), WBL (1), YUG (1), ZAN (1) |

Civil wars that happen in at least 80% of members are background: AGC. 

## Infrastructure

![Infrastructure](figures/infrastructure.svg)

![State infrastructure scatter](figures/states_scatter.svg)

*States with zero usage sit on the bottom edge (log scale).*

![State utilization distribution](figures/states_utilization.svg)

States short of infrastructure in at least half the members at 1851-01 (29 states; median values across members):

| state | owner | short in | supply | usage | shortfall | population |
|:--|--:|--:|--:|--:|--:|--:|
| Kenya | MBS | 10/10 | 4.1 | 5.2 | 1.1 | 32.7 k |
| Mocambique | AGC | 10/10 | 4 | 5 | 1 | 8.97 k |
| Tiflis | SVN | 10/10 | 3.6 | 4.5 | 0.9 | 28.6 k |
| Ceará | BRZ | 9/10 | 11.5 | 11.7 | 0.2 | 257 k |
| Transvaal | SWZ | 8/10 | 6.95 | 7.5 | 0.55 | 98.8 k |
| Transorangia | PHL | 8/9 | 5 | 5.5 | 0.5 | 40.9 k |
| Yemen | KAT | 8/10 | 6.15 | 6.5 | 0.35 | 52.7 k |
| Minas Gerais | BRZ | 7/10 | 31.4 | 32.9 | 1.5 | 826 k |
| Malwa | IND | 7/10 | 28.6 | 29.6 | 0.95 | 579 k |
| Yemen | MAH | 7/8 | 5.5 | 6.25 | 0.75 | 38.9 k |
| Malwa | BHO | 7/9 | 18.9 | 19.4 | 0.5 | 371 k |
| East Borneo | BNJ | 7/10 | 10.1 | 10.2 | 0.15 | 161 k |
| Beijing | CHI | 6/10 | 93 | 94.1 | 1.1 | 15.5 M |
| Yezo | EZO | 6/6 | 4.4 | 5.3 | 0.9 | 39.4 k |
| Maranhão | BRZ | 6/10 | 11.9 | 12.7 | 0.8 | 272 k |
| Mocambique | TGI | 6/10 | 4.5 | 5.2 | 0.7 | 24 k |
| Uralsk | BKH | 6/8 | 5.5 | 6.05 | 0.55 | 58.9 k |
| Kenya | WTU | 6/10 | 4.3 | 4.5 | 0.2 | 21.1 k |
| North Sumatra | JMB | 6/10 | 7.7 | 7.9 | 0.2 | 104 k |
| Western New Guinea | TID | 6/10 | 10.8 | 11 | 0.15 | 153 k |
| Paraíba | BRZ | 6/10 | 11.9 | 11.1 | -0.8 | 251 k |
| Zululand | NAL | 6/8 | 9.6 | 8.6 | -1 | 121 k |
| Pernambuco | BRZ | 6/10 | 34.8 | 32 | -2.75 | 723 k |
| Gujarat | BHV | 5/10 | 18.9 | 19.2 | 0.25 | 351 k |
| Bosnia | TUR | 5/10 | 27.4 | 27.3 | -0.1 | 801 k |

Market access is uninformative in vanilla: pop-weighted world market access stays at 99.4% (cv 0.92%). Deficits in vanilla don't yet cut states off; BOI changing that would show up here immediately.

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

| goods | price 1836-01 | price 1851-01 | change | price cv | demand/wk | supply/demand | demand at ceiling |
|:--|--:|--:|--:|--:|--:|--:|--:|
| grain | 15.8 | 17.5 | +10.6% | 4.1% | 75.5 k | 1.17 | 0% |
| wood | 20.8 | 23.6 | +13.4% | 6.4% | 63.1 k | 0.85 | 5% |
| fabric | 16.6 | 14.6 | -11.9% | 6.2% | 40.3 k | 1.38 | 0% |
| services | 19.6 | 23.5 | +20.1% | 4.6% | 33.8 k | 1.29 | 0% |
| clothes | 32.3 | 35.3 | +9.4% | 3.0% | 32.2 k | 0.84 | 3% |
| fruit | 41.8 | 33.1 | -20.8% | 2.6% | 28.5 k | 0.92 | 0% |
| furniture | 30 | 35.9 | +19.6% | 1.7% | 25.4 k | 0.83 | 6% |
| transportation | 52.4 | 51 | -2.7% | 1.8% | 24.3 k | 0.29 | 83% |
| meat | 42.8 | 34.1 | -20.4% | 2.8% | 19.6 k | 0.89 | 4% |
| paper | 34.4 | 45.5 | +32.2% | 3.2% | 18.2 k | 0.60 | 8% |
| tools | 39.4 | 51.2 | +29.7% | 3.6% | 16.2 k | 0.76 | 3% |
| fish | 19.1 | 18.8 | -1.2% | 2.2% | 14.6 k | 1.09 | 0% |
| iron | 37.4 | 54.6 | +45.8% | 6.5% | 13.9 k | 0.70 | 13% |
| tobacco | 37.5 | 30 | -20.1% | 3.7% | 13.6 k | 1.36 | 0% |
| liquor | 26.5 | 26.8 | +1.4% | 3.8% | 13.4 k | 1.17 | 4% |
| tea | 57.1 | 33.1 | -42.0% | 5.5% | 12.2 k | 1.52 | 2% |
| groceries | 45.8 | 40.8 | -10.8% | 2.2% | 11.6 k | 0.69 | 10% |
| opium | 57.9 | 49.7 | -14.2% | 8.9% | 10.8 k | 1.10 | 4% |
| coal | 30.2 | 35.1 | +16.1% | 7.8% | 10.6 k | 0.84 | 5% |
| luxury_clothes | 64.5 | 72.1 | +11.7% | 3.6% | 8.82 k | 0.84 | 11% |
| silk | 44.8 | 38.2 | -14.8% | 3.8% | 6.97 k | 1.09 | 7% |
| sugar | 33.6 | 19.9 | -40.9% | 7.9% | 6.95 k | 1.55 | 5% |
| hardwood | 49.6 | 50.5 | +1.8% | 8.3% | 5.76 k | 0.79 | 5% |
| clippers | 45 | 55.6 | +23.7% | 3.3% | 5.21 k | 1.13 | 3% |
| coffee | 60.9 | 41.5 | -31.8% | 5.2% | 5.16 k | 1.30 | 0% |
| small_arms | 69.4 | 68.2 | -1.8% | 5.6% | 4.87 k | 0.90 | 7% |
| luxury_furniture | 67.6 | 78.3 | +15.8% | 1.4% | 4.1 k | 0.69 | 22% |
| dye | 19.3 | 16.8 | -13.3% | 15.0% | 3.41 k | 2.64 | 0% |
| wine | 26.1 | 23.2 | -11.1% | 11.2% | 3.34 k | 1.82 | 0% |
| steel | 52 | 63.5 | +22.2% | 6.6% | 3.09 k | 0.78 | 0% |

## Construction and urbanization

Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes for it, and ranching (horses come from livestock).

![Construction and urbanization](figures/construction.svg)

| metric | 1836-01 | A 1851-01 | A growth | A sd | A cv | MDE (10 vs 1) | B 1851-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| Construction sector levels | 83 | 776 | +834.8% | 59.6 | 7.7% | – | 622 | -19.8% | – | no |
| Urban center levels | 601 | 1.02 k | +69.6% | 33.3 | 3.3% | – | 981 | -3.8% | – | no |
| Non-subsistence building levels | 44.5 k | 53.1 k | +19.4% | 1.51 k | 2.8% | – | 54.8 k | +3.1% | – | no |
| Light industry levels | 1 k | 1.18 k | +17.8% | 23 | 2.0% | – | 1.1 k | -7.0% | – | no |
| Heavy industry levels | 34 | 67.6 | +98.8% | 5.8 | 8.6% | – | 61 | -9.8% | – | no |
| Livestock ranch levels | 487 | 803 | +64.9% | 25.3 | 3.2% | – | 729 | -9.2% | – | no |
| Urbanization (points) | 84.1 k | 122 k | +45.1% | 2.95 k | 2.4% | – | 119 k | -2.3% | – | no |

## Fiscal

![Fiscal](figures/fiscal.svg)

| metric | 1836-01 | A 1851-01 | A growth | A sd | A cv | MDE (10 vs 1) | B 1851-01 | B vs A | p (Welch) | beyond MDE |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| Gold reserves | 16 M | 67.5 M | +322.0% | 13 M | 19.2% | – | 59.1 M | -12.4% | – | no |
| Countries in debt | 15 | 61.6 | +310.7% | 4.84 | 7.8% | – | 63 | +2.3% | – | no |
| Income /wk | 1.75 M | 3.75 M | +114.0% | 283 k | 7.6% | – | 3.63 M | -3.2% | – | no |
| Expenses /wk | 1.54 M | 3.78 M | +145.4% | 341 k | 9.0% | – | 3.56 M | -5.7% | – | no |
| Net income /wk | 209 k | -35.1 k | -116.8% | 117 k | – | – | 61.7 k | -275.9% | – | no |

World net government income goes 209 k → -35.1 k per week: spending outgrows revenue, which is the headroom BOI's road financing competes for.

## BOI cheat-sheet

Values at 1851-01. Compare a BOI ensemble's mean against these; a difference smaller than the MDE is indistinguishable from vanilla noise with 10 members per arm.

| metric | mean | sd | cv | MDE (n=10) | n for 2% | n for 5% | B mean | B vs A | p |
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| World GDP | 604 M | 15.9 M | 2.6% | 3.5% | 29 | 6 | 563 M | -6.9% | – |
| SoL | 8.31 | 0.394 | 4.7% | 6.3% | 89 | 16 | 8.09 | -2.7% | – |
| Unemployed | 26.9 M | 1.36 M | 5.1% | 6.7% | 102 | 18 | 23 M | -14.5% | – |
| Wage | 0.597 | 0.034 | 5.6% | 7.4% | 125 | 21 | 0.577 | -3.4% | – |
| Infrastructure supply | 33.3 k | 517 | 1.6% | 2.1% | 11 | 3 | 31.6 k | -5.2% | – |
| Infrastructure usage | 14.5 k | 305 | 2.1% | 2.8% | 19 | 4 | 18.3 k | +26.4% | – |
| Utilization | 43.5% | 1.1% | 2.6% | 3.5% | 28 | 6 | 58.0% | +33.3% | – |
| Deficit states | 43.3 | 6.73 | 15.6% | 20.6% | 951 | 153 | 20 | -53.8% | – |
| Railway levels | 162 | 5.27 | 3.2% | 4.3% | 43 | 8 | 108 | -33.5% | – |
| Port levels | 386 | 3.1 | 0.8% | 1.1% | 4 | 3 | 393 | +1.9% | – |
| Construction levels | 776 | 59.6 | 7.7% | 10.2% | 233 | 38 | 622 | -19.8% | – |
| Urban center levels | 1.02 k | 33.3 | 3.3% | 4.3% | 43 | 8 | 981 | -3.8% | – |
| Livestock ranch levels | 803 | 25.3 | 3.2% | 4.2% | 41 | 8 | 729 | -9.2% | – |
| Gold reserves | 67.5 M | 13 M | 19.2% | 25.5% | >1000 | 233 | 59.1 M | -12.4% | – |
| Countries in debt | 61.6 | 4.84 | 7.8% | 10.4% | 243 | 40 | 63 | +2.3% | – |
| Govt expenses | 3.78 M | 341 k | 9.0% | 12.0% | 322 | 53 | 3.56 M | -5.7% | – |
| Transportation price | 51 | 0.902 | 1.8% | 2.3% | 14 | 4 | 50.5 | -0.9% | – |
| Transport demand at ceiling | 82.6% | 5.9% | 7.2% | 9.5% | 204 | 34 | 80.3% | -2.7% | – |
| Transportation demand | 24.3 k | 1.58 k | 6.5% | 8.6% | 167 | 28 | 19.6 k | -19.4% | – |
| Merchant marine price | 51.3 | 3.05 | 6.0% | 7.9% | 141 | 24 | 57.1 | +11.3% | – |
| Services price | 23.5 | 1.08 | 4.6% | 6.1% | 84 | 15 | 18.8 | -20.1% | – |
| Wood price | 23.6 | 1.51 | 6.4% | 8.5% | 162 | 27 | 24.4 | +3.4% | – |
| Grain price | 17.5 | 0.721 | 4.1% | 5.5% | 68 | 12 | 17.3 | -1.2% | – |
| Groceries price | 40.8 | 0.916 | 2.2% | 3.0% | 21 | 5 | 40.1 | -1.7% | – |
| Tools price | 51.2 | 1.84 | 3.6% | 4.8% | 52 | 10 | 52.8 | +3.2% | – |

## Appendix

- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. It reads only the database.
- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same day; `t` counts quarters from 1836-01.
- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, wage, market access and turmoil. World goods: summed orders, demand-weighted price.
- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.
- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance of a wave changes means through that alone.
- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.

