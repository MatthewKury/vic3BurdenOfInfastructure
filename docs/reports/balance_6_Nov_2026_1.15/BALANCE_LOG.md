# Balance log: BOI on 1.15.0 (6 Nov 2026)

These are the first BOI games on 1.15.0 after the patch work ([PATCHING.md](../../../PATCHING.md), "1.15.0 patch log"). Games run to 1846 as ensembles: 4 in pass 1, then 2 per pass, for 10 in total. Each pass is compared with `vanilla115_1836_1936_all`, which holds 13 vanilla 1.15.0 games to 1846. The aim is the same as the [1.13 balance log](../balance_3_Nov_2026/BALANCE_LOG.md): bite without collapse, meaning GDP within about 5% of vanilla, radicals and civil wars near vanilla, and housing supply just under demand.

Regenerate a pass report with:

```powershell
& "$env:LOCALAPPDATA/Programs/Python/Python312/python.exe" tools/ensembles/Make-EnsembleReport.py --ensemble vanilla115_1836_1936_all --compare boi115_passN --horizon 1846 --out docs/reports/boi115_passN
```

With 2 BOI games against 13 vanilla games, a difference smaller than about 3% in world GDP, or 8% in unemployment, can't be told apart from noise. Pooling passes with the same settings helps; pooling passes with different settings doesn't.

## Pass 1: BOI as patched (4 games)

**Settings:** as at the end of the 1.13 work. Population floor 125,000, slums and Town Houses at 200 construction points, basic housing seed coverage 0.92, Light and Heat +10/+30/+60%, AI works event gated on `scaled_debt < 0.75`. 1.15 seeds: 20 Public Works (40 levels), 139 Harbour Works (141), 216 Horse Ranches (491). Ensemble `boi115_pass1`; report [boi115_pass1](../boi115_pass1/REPORT.md).

**Result:** all 4 games passed, with 0 BOI-attributed errors and the expected 65 shadow lines.

| At 1846 (BOI against vanilla) | Change | Significant? |
| --- | ---: | --- |
| World GDP | -9.1% | yes (p < 0.001) |
| GDP of 13 major powers (single-game tables) | about -4% | |
| Population | -1.5% | yes |
| SoL, population-weighted | -2.6% | no |
| Unemployed | -12.4% | yes |
| Radicals | -15.5% | no |
| Turmoil | -14.2% | no |
| Construction sector levels | -23.9% | yes |
| Railway levels | -32.7% | yes |
| Infrastructure usage / supply | 58% against 42% | yes |
| Basic housing supply/demand, world, 1836–1841 | 0.81–0.84 | |

**Findings:**

1. **The GDP gap is a level shift set in the first quarter.** World GDP is already 9.0% below vanilla in April 1836 and stays there (-8.7% in 1837, -8.6% in 1845), so BOI doesn't slow growth. China (-£10.3M), British India (-£9.6M), Britain (-£5.3M), Austria (-£3.2M) and Spain (-£2.6M) account for most of it.
2. **Asian markets are short of horses.** The game counts GDP net of inputs, so horse inputs subtract from it, and a shortage cuts output on top. Horse supply covers 0.00–0.07 of British India's demand at the £52.50 ceiling from 1836 to 1841, about 0.45 of China's, 0.24–0.36 of the Dutch East Indies' and 0.35–0.54 of Japan's. Russia and the USA are at 1.0–1.3. India's ceiling price was already in the 1.13 horse-scarcity measurements, but the major-power tables used then left India and China out. This contradicts the plan 1 item "every starting market has access to some horse production": British India has no ranch at all. **Left for a later pass,** because it is a seed decision with design weight.
3. **Britain opens short of infrastructure, through BOI's own housing seed.** In April 1836 BOI's Britain has 18% less infrastructure than vanilla and uses 28% more. London's housing seed uses 88 infrastructure, almost exactly London's excess (usage 242 against vanilla's 155, supply 167). Market access in London is 0.69 and its SoL 9.0 against vanilla's 12.3. In 1837 British tax income is 28% below vanilla with taxes at their maximum, SoL is 1.4 lower and radicals are three times vanilla's. By 1845 Britain recovers to SoL -0.7, but GDP stays 14% below. Across all countries, the extra usage over vanilla matches the housing seed's usage country by country. The works seed was only ever sized to replace the rail and port infrastructure BOI removes.
4. **Basic housing coverage is lower than on 1.13 (0.82 against 0.87–0.93), but not because of the seed.** Seeded states sit at 0.90, on target. The 566 small states with no seed hold 13% of demand at 32% coverage, because one tenement level (7 units) is several times their demand. Seeding them would oversupply them, so nothing changes.
5. **Services and transport demand fall about 25%.** Both enter the basket at wealth 10, and BOI's lower welfare keeps more pops below it. The services glut cuts its price by 21% and urban-centre GDP with it.
6. **Politics is near or better than vanilla, apart from Britain.** No game split Britain or another power by 1846.

**Change for pass 2:** 47 Public Works levels added to the 1836 seed in the 26 states that were short in at least 3 of 4 games in April 1836, at one level per 10 points of mean shortfall. Britain gets 21 (Home Counties 3 to 11, Yorkshire 6 to 11, Lancashire 5 to 8, West Country +2, Midlands, Jamaica and Wales +1). The USA gets 9, Brazil 7, Russia 3 (Ingria), Spain 2, France 2, and Belgium, Cuba and Sweden 1 each. British India and China were short too, but they are left out: their horse markets are at 0.05–0.45 coverage, so the new works would run at about half output and draw horses from everything else there. The seed is now 36 Public Works with 87 levels. The cost is about 470 more horses a week, 4% of world demand. Files: `tools/infrastructure_seed_plan.tsv`, regenerated `common/history/buildings/zz_boi_buildings.txt`, header text in `tools/gen_seed.awk`.

## Pass 2: works seed covers the opening shortage (2 games)

**Settings:** pass 1 plus the 47 Public Works levels. Ensemble `boi115_pass2`; report [boi115_pass2](../boi115_pass2/REPORT.md). Both games passed, with 0 BOI-attributed errors and 65 shadow lines.

| | Vanilla | Pass 1 | Pass 2 |
| --- | ---: | ---: | ---: |
| Short states, 15 powers, April 1836 | 7.4 | 47.0 | 29.0 |
| Short states, world, April 1836 | 10.7 | 59.5 | 41.0 |
| Short states, world, 1846 | 30.8 | 30.8 | 21.0 |
| World GDP against vanilla, 1846 | | -9.1% | -8.2% |
| Construction sector levels against vanilla, 1846 | | -23.9% | -18.8% |
| Railway levels against vanilla, 1846 | | -32.7% | -26.9% |
| Britain: GDP against vanilla, 1846 | | -14.4% | -7.2% |
| Britain: tax income, 1837 (£k/week) | 286 | 206 | 220 |
| Britain: radicals, 1841 | 1.19M | 3.38M | 1.79M |
| Britain: turmoil, 1841 | 4.4% | 13.0% | 6.9% |
| Britain: debt, 1841 | 0.01 | 0.22 | 0.04 |
| Brazil: GDP against vanilla, April 1836 | | -24.6% | -0.3% |
| Radicals, world, 1846 | | -15.5% | -4.4% |
| Unemployed, world, 1846 | | -12.4% | -13.9% |

**Findings:**

1. **The change did what it was for.** Opening shortages among the powers fell by 40%. Britain's radicals, turmoil and debt halved or better, and its GDP gap at 1846 halved. Brazil's opening gap disappeared. World radicals moved from 15% below vanilla to about vanilla, but with 2 games that is inside the noise (the minimum detectable effect for radicals is about 50%).
2. **British horses held.** The 21 extra British levels add about 210 horses a week of demand. Britain's coverage stayed at 1.05–1.25 (pass 1: 0.83–1.03).
3. **World GDP improved only a little** (-9.1% to -8.2%), because the remaining gap is in Asia. China is -6% to -12% through the decade and British India -12% to -15%. Their horse coverage is unchanged: British India 0.00–0.11, China 0.40–0.43, the Dutch East Indies 0.18–0.35, Japan 0.37–0.55.
4. **Britain still opens 15% down in April 1836.** The extra works only reach full output as their horses arrive, and Britain's SoL that quarter is 9.5 against vanilla's 10.1 (pass 1: 9.15).

**Change for pass 3:** four new seeded Horse Ranches, 20 levels and about 240 horses a week, in starting markets below the 0.5 horse shortage line, the point at which the shortage penalty starts:

| State | Owner | Levels | Reason |
| --- | --- | ---: | --- |
| Bihar | British India | 8 | The East India Company's cavalry stud at Pusa (from 1796) and the Sonepur horse fair. British India's only seeded ranch. |
| Shandong | China | 4 | Farm horses of the North China plain, next to Zhili's ranch |
| Beijing | China | 4 | Imperial stables and Qing horse demand |
| East Java | Dutch East Indies | 4 | Javanese pony breeding in the volcanic uplands |

Bihar and East Java are company and colonial states, never core to their owner. `Test-HorseSeedSafety.ps1` used to require core for every addition, so it now allows these two by name. Both are still sole-owner and incorporated, with 340 and 38 levels of declared headroom. Expected effect: China's coverage rises above 0.5, the Dutch East Indies' to about 0.45, and British India's from 0.05 to about 0.16. The seed is now 220 ranches with 511 levels.

## Pass 3: horses for the starved Asian markets (2 games)

**Settings:** pass 2 plus the four ranches. Ensemble `boi115_pass3`; report [boi115_pass3](../boi115_pass3/REPORT.md). Both games passed, with 0 BOI-attributed errors and 65 shadow lines.

| Horse supply/demand by owner (1837 / 1845) | Pass 2 | Pass 3 |
| --- | --- | --- |
| British India | 0.00–0.01 / 0.08–0.11 | 0.11–0.12 / 0.17–0.28 |
| China | 0.43 / 0.42–0.43 | 0.46 / 0.50–0.52 |
| Dutch East Indies | 0.34–0.35 / 0.18–0.22 | 0.43–0.47 / 0.35–0.51 |

| Against vanilla | Pass 1 | Pass 2 | Pass 3 |
| --- | ---: | ---: | ---: |
| World GDP, April 1836 | -9.0% | -8.2% | -7.1% |
| World GDP, 1837 | -8.7% | -8.1% | -7.4% |
| World GDP, 1841 | -7.6% | -7.2% | -7.1% |
| World GDP, 1846 | -9.1% | -8.2% | -8.6% |
| China GDP, 1841 / 1846 | -7.8% / -9.8% | -4.5% / -6.4% | -6.4% / -8.1% |
| British India GDP, 1841 / 1846 | -10.8% / -15.6% | -15.2% / -12.3% | -9.2% / -17.3% |
| Britain GDP, 1846 | -14.4% | -7.2% | -14.0% |
| Britain turmoil, 1846 (vanilla 4.6%) | 11.6% | 5.5% | 14.6% |

**Findings:**

1. **Horse coverage rose as predicted,** and the opening GDP gap narrowed by about a point. By 1846 the two games are back near pass 2. With 2 games, the gaps for China and British India are within their noise.
2. **Britain's turmoil follows its tax level, and the AI's choice is close to all or nothing.** Both pass 2 games kept taxes at medium all decade, and British turmoil was 5.5%. Both pass 3 games, and all four pass 1 games, raised taxes to high within the first year and held them for 28–39 of 40 quarters, with turmoil at 11–15%. Vanilla Britain also uses high taxes, but never for more than 24 quarters, and its turmoil stays at 3–9% even then. Pass 3 changed nothing British, so pass 2's medium taxes were likely luck: if 6 of 8 games go high, two lows in a row has about a 6% chance. Under BOI, British pops are about 0.8 SoL below vanilla through the 1840s, so high taxes radicalise them far more.
3. **What keeps British SoL down in 1840 is housing and horses, not infrastructure.** Market access is 1.00 in every British state by 1840. The English industrial states are 1.3–1.9 SoL below vanilla, while Ireland is about level. Their basic housing is at 0.55–0.77 of demand at £37–48 (base £30). The British AI builds almost no housing: Britain has 66–70 residential levels in 1836 and 68–74 in 1845, on 1.13 as on 1.15, while the world adds 255–324. Residential buildings are privately owned, and in Britain industry outbids them.
4. **The British market is short of horses.** At the end of 1836 Britain's market (including British India) has buy orders of about 1,935 horses against sell orders of 930, a coverage of 0.39–0.49 at the £52.50 ceiling. It is still at £45 in 1845. British India's demand is about half the market's. Every British mine, urban centre and road pays the ceiling price.
5. **The new solvency telemetry reads sensibly:** Britain at the end of 1836 shows `weeks_until_bankruptcy=654` with `taking_loans=1`.

**Change for pass 4:** three English ranches, 14 levels and about 170 horses a week, in the homelands of England's draught breeds: Midlands 6 (the Shire), East Anglia 4 (the Suffolk Punch) and West Country 4 (Exmoor and Dartmoor). All are core, sole-owner and incorporated. Ireland was the obvious historical source, but its states are unincorporated in 1836, which is where the seed caps ranches at 3 levels to avoid the arable-land crash. The aim is to lift the British market from about 0.48 to about 0.57 in 1836, above the 0.5 shortage line. The seed is now 223 ranches with 525 levels. The housing gap (finding 3) needs AI construction behaviour, not a number, so it is a next-step item.

## Pass 4: horses for the British market (2 games)

**Settings:** pass 3 plus the three English ranches. These are the settings the mod is left at. Ensemble `boi115_pass4`; report [boi115_pass4](../boi115_pass4/REPORT.md). Both games passed, with 0 BOI-attributed errors and 65 shadow lines.

| Against vanilla | Pass 1 | Pass 2 | Pass 3 | Pass 4 |
| --- | ---: | ---: | ---: | ---: |
| World GDP, April 1836 | -9.0% | -8.2% | -7.1% | -7.1% |
| World GDP, 1837 | -8.7% | -8.1% | -7.4% | -6.7% |
| World GDP, 1841 | -7.6% | -7.2% | -7.1% | -5.6% |
| World GDP, 1846 | -9.1% | -8.2% | -8.6% | -8.1% |
| Britain GDP, 1837 | -16.6% | -13.1% | -9.9% | -6.6% |
| Britain GDP, 1846 | -14.4% | -7.2% | -14.0% | -5.6% |
| Britain tax income, 1837 (vanilla £286k/week) | £206k | £220k | £246k | £256k |
| Britain turmoil, 1846 (vanilla 4.6%) | 11.6% | 5.5% | 14.6% | 10.1% |
| Britain at high tax most of the decade | 4 of 4 | 0 of 2 | 2 of 2 | 1 of 2 |
| Railway levels, 1846 | -32.7% | -26.9% | -25.9% | -18.4% |
| Construction sector levels, 1846 | -23.9% | -18.8% | -21.0% | -17.1% |
| Short states, world, 1846 (vanilla 30.8) | 30.8 | 21.0 | 33.0 | 30.0 |
| Radicals, world, 1846 | -15.5% | -4.4% | +18.7% | -6.2% |
| Population, 1846 | -1.5% | -1.5% | -1.7% | -1.7% |

Horse supply/demand in the British market: 0.46–0.51 at the end of 1836 and 0.55–0.56 in 1837 (pass 3: 0.48 and 0.54). Britain's own states moved into surplus (1.10–1.43 by owner), so some of the new supply leaves the market.

**Findings:**

1. **Britain's opening is now close to vanilla.** British GDP is 6.6% below vanilla in 1837, against 16.6% in pass 1, and tax income is within 10%. Across the passes the early British gap narrowed step by step, and each step lines up with a change: works in pass 2, then horses in passes 3 and 4.
2. **The British tax decision is still a coin toss.** One game held high taxes for 39 quarters (turmoil 13.8%) and the other none (6.3%). Over all 10 games it went high in 7.
3. **World GDP is closest to vanilla through 1841 (-5.6%), but the gap widens to about 8% by 1846 in every pass.** The widening is mostly British India and China (next steps, item 1).

## Summary after 10 games

**Changes kept** (all seed data, no script changes):

- Public Works seed: 20 states with 40 levels became 36 with 87. The 47 new levels go where the 1836 opening, mainly BOI's own housing seed, left states short.
- Horse Ranch seed: 216 ranches with 491 levels became 223 with 525. The new ranches are Bihar, Shandong, Beijing and East Java for the starved Asian markets, and the Midlands, East Anglia and West Country for the British market.

**Where BOI stands against vanilla 1.15 at 1846** (pass 4, with passes 2–3 for a sense of spread):

- World GDP about 8% lower, outside the 5% aim. It is 5.6–7% lower in 1837–1841. Most of the gap is China and British India. Their horse markets are still under the 0.5 shortage line (British India 0.11–0.28, China about 0.45–0.52).
- SoL, radicals, turmoil, countries in debt and short states are all within noise of vanilla. Unemployment is 12–14% lower, and population is 1.5–1.7% lower, as the mortality design intends.
- Railways and the construction sector are 17–27% smaller.
- Britain is no longer the outlier in its opening years, but it still runs high taxes and 10–15% turmoil in most games.

**Next steps, in order:**

1. **The 1841–1846 GDP widening is India and China.** Pooling passes 2–4 (6 games), the world gap grows from £31.3M to £45.0M. British India adds £3.6M and China £3.6M, about half of the growth, and the Indian princely states (Travancore, Mysore, Hyderabad and others) add more. These are the markets still below the 0.5 horse line, so their gap compounds rather than closes. That makes step 3 the main GDP lever. Whether the Hungry Forties crop failures add to it is still to check.
2. **AI housing construction in Britain.** Britain builds almost no housing on 1.13 or 1.15, and its industrial towns sit at 55–77% coverage. This needs an AI event like the works event (queue a basic-housing level in the worst-priced state), not a seed number.
3. **British India's horses.** One 8-level ranch moved it from 0.05 to about 0.2. Reaching 0.5 would take about 35 more levels, or AI ranch building in markets at the ceiling, like the works event. The second fits the design better.
4. **Britain's tax lock-in.** Check whether relieving housing (step 2) cuts the share of games that go to high tax. Group games by `tax_level` before judging turmoil.
5. **More games on the final settings.** Pass 4 is only 2 games. A 4–6 game batch on these settings, or a 1856 horizon, would show whether the 1846 widening keeps growing.
