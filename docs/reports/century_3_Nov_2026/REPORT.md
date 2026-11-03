# Century runs, 3 Nov 2026

Two unattended AI games from 1836 to 1936 on branch `road-rail-housing-tiers`, with the road/rail split, the housing tiers and the settings from the [balance log](../balance_3_Nov_2026/BALANCE_LOG.md): population floor 125,000, slums and Town Houses at 200 points, basic housing seed coverage 0.92, Light and Heat +10/+30/+60%. The mod didn't change between the runs.

| | Game 1 | Game 2 |
| --- | --- | --- |
| Run folder | `20261103-081447_mod` | `20261103-101832_mod` |
| Result | Reached 1936 | Reached 1936 |
| Time | 123 minutes | 155 minutes |
| BOI-attributed errors | 0 | 0 |

## Verdict

**The mod holds up for a century.** Neither game crashed or logged a BOI script error. The works and housing ladders were used, and by 1846 both games were within the balance aim against vanilla. Nothing here looks like a mod-driven collapse, though I can't rule out a contribution to the civil wars.

Five concerns matter, and all five appeared in both games:

1. **Housing falls behind demand after about 1920,** luxury most of all.
2. **Works orders stall for decades in countries in debt,** leaving states short.
3. **The AI barely touches the reform laws,** so forced-labour financing still dominates in 1936.
4. **Municipal Estates get wiped out** whole, country by country. This looks like a bug with a one-line fix.
5. **France and early Britain carry the most strain,** though the data can't say how much of it comes from the mod.

The baseline stops at 1846, so **after 1846 nothing can be compared with vanilla.** Each figure is also one game, and the two games differ widely.

## What happened

"Major powers" are whichever countries the game ranks as major that year, and that list changes, so their totals show direction rather than exact growth. Cells read game 1 / game 2.

| | 1836 | 1846 | 1866 | 1886 | 1906 | 1926 | 1935 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| SoL, major powers | 8.8 / 8.9 | 9.1 / 9.2 | 9.8 / 9.1 | 10.4 / 10.2 | 11.1 / 10.2 | 12.6 / 11.7 | 13.1 / 12.6 |
| Radicals %, major powers | 3 / 4 | 12 / 10 | 15 / 16 | 18 / 16 | 17 / 18 | 20 / 19 | 20 / 18 |
| Short states, major powers | 47 / 47 | 7 / 9 | 5 / 1 | 9 / 6 | 13 / 12 | 12 / 20 | 14 / 13 |
| Usage as share of supply, major powers | 69 / 68% | 59 / 60% | 58 / 59% | 63 / 58% | 63 / 66% | 73 / 74% | 75 / 78% |
| Short states, world | 75 / 80 | 38 / 35 | 33 / 25 | 29 / 37 | 41 / 63 | 45 / 73 | 51 / 61 |
| People in short states, world | 27 / 28% | 23 / 13% | 3 / 1% | 4 / 8% | 4 / 10% | 6 / 9% | 5 / 10% |
| Basic housing supply/demand, world | 0.87 / 0.88 | 0.91 / 0.90 | 0.93 / 0.95 | 0.99 / 0.96 | 0.98 / 1.01 | 0.90 / 0.96 | 0.79 / 0.89 |
| Luxury housing supply/demand, world | 0.97 / 0.97 | 0.79 / 0.83 | 0.83 / 0.89 | 0.88 / 0.83 | 0.92 / 0.80 | 0.74 / 0.76 | 0.69 / 0.60 |
| Road Works levels, world | 46 / 47 | 194 / 185 | 551 / 418 | 738 / 629 | 874 / 829 | 1,019 / 1,073 | 1,202 / 1,164 |
| Rail Works levels, world | 2 / 3 | 15 / 16 | 32 / 35 | 73 / 87 | 160 / 198 | 315 / 467 | 476 / 642 |
| Harbour Works levels, world | 144 / 145 | 228 / 228 | 311 / 288 | 364 / 342 | 405 / 423 | 437 / 521 | 460 / 558 |
| Railway levels, world | 20 / 19 | 65 / 59 | 266 / 208 | 564 / 514 | 1,071 / 985 | 1,732 / 1,942 | 2,218 / 2,766 |

**1836–1846: the opening bite, then recovery.** GDP starts about 6% below vanilla and SoL about 0.6 lower. By 1846 GDP is +4.4% / -4.0%, SoL -0.46 / -0.33 and radicals 11.7 / 10.4% against vanilla's 9.6%. The AI's works event clears most major-power shortages within a decade. China and British India hold most of what's left, as they did in the short runs.

**1846–1896: a quiet middle.** People in short states fall to a few percent, and major powers use only 55–64% of their supply, so infrastructure bites lightly here. Carts are gone from major powers by the 1870s and Macadam by 1896. Slums and the new working-class tiers grow in step with demand.

**1896–1916: industry arrives.** Rail Works and Steam Rolled Roads expand, Oil and Electric Light and Heat spread, and shortages return in places. Late shortages sit mostly in Indian successor states and small countries. Game 2's worst is Oudh, 120 points short in 1906 and still 61 short in 1935.

**1916–1936: the late squeeze.** Usage reaches 75–78% of supply among major powers, and Austria runs at 95% in game 1. Motor Roads start with Britain in 1912 and Highways in 1931. Housing starts to fall well behind demand.

**Major powers often break apart.** Losing 25% or more of their states in one year happened 5 times in game 1 and 9 times in game 2, and many of those states come back later, which points to civil wars.

The two games end in very different places:

| GDP in 1935, £M | Game 1 | Game 2 |
| --- | ---: | ---: |
| Great Britain | 172 | 363 |
| Germany | 193 | 269 |
| Russia | 155 | 338 |
| United States | 121 | 299 |
| France | 166 | 58 |
| Spain | 72 | 110 |

World population ends at 1,675M / 1,718M.

## Major concerns

### 1. Housing falls behind demand after about 1920

The aim was supply just under demand. That held until about 1920, with basic housing at 0.93–1.03 in every snapshot from 1866 to 1916. Luxury was already below that, at 0.78–0.92.

By 1935 supply is well short:

| 1935 | Game 1 | Game 2 |
| --- | ---: | ---: |
| Basic supply/demand, world | 0.79 | 0.89 |
| Luxury supply/demand, world | 0.69 | 0.60 |
| Mean basic price (base £30) | £35.3 | £32.2 |
| Mean luxury price (base £60) | £70.1 | £72.5 |
| People paying £45 or more for basic housing | 21% | 13% |

The shortage is sharpest in the richest countries. The United States has luxury at 0.30 in both games and basic at 0.51 / 0.69. Germany's basic is 0.67 / 0.66, and Britain's is 0.57 / 0.83.

**Demand outruns building.** From 1900 to 1935:

| Change, 1900–1935 | Game 1 | Game 2 |
| --- | ---: | ---: |
| Basic demand | +121% | +131% |
| Luxury demand | +150% | +170% |
| Residential levels | +44% | +56% |
| Basic supply | +79% | +102% |
| Luxury supply | +82% | +106% |

Basic demand per person about doubles over that time, so the likely driver is wealth rather than population. About 80% of levels already burn a fuel by 1935, so Light and Heat has little left to give.

**It isn't doing visible harm yet:** SoL is at its highest in 1935. But the trend is steepening when the game ends. The likely fixes are more output from post-1900 tiers or an AI nudge to build housing, and either needs a long run to test.

### 2. Works orders stall for decades in countries in debt

The AI event queues works, but orders can then sit unbuilt for a very long time:

| Works order visibly queued | Game 1 | Game 2 |
| --- | ---: | ---: |
| 5 years or more | 28 | 17 |
| 10 years or more | 8 | 8 |
| 20 years or more | 3 | 3 |
| Longest | Provence, France: 45 years | Campania, Italy: 27 years |

**Stalls track debt closely:**

| Debt | Game 1: power-years with an order waiting 5+ years | Game 2 |
| --- | ---: | ---: |
| Under 0.1 | 1% | 0% |
| 0.1–0.25 | 4% | 1% |
| 0.25–0.5 | 15% | 14% |
| 0.5–0.75 | 36% | 47% |
| Over 0.75 | 31% | 44% |

France in game 1 shows the effect. It kept 8 Road Works levels from 1841 to 1896 and was short in up to 8 states from 1866 to 1906, with Normandy short for 33 years. Its debt ran from 0.21 to 0.98 and averaged 0.63 over the 45 years of the Provence order. Railways kept growing throughout, from 14 levels in 1866 to 49 in 1901.

**Cause not established.** My best guess is that an indebted AI stops spending on government construction, while private investment keeps paying for railways. The works event also skips a state with a visible order, so one stuck order stops that state getting another. This matters to the mod because the countries least able to pay are also the ones left short.

These counts are a minimum, because the telemetry only sees a brand-new Road or Harbour building under construction. It misses Rail Works and extra levels on an existing building.

### 3. The AI barely touches the reform laws

Autosaves show what the AI chose by 1936. These are buildings, not levels, for the whole world:

| Financing | Game 1 | Game 2 |
| --- | ---: | ---: |
| Road Works on Statute Labour | 66% | 65% |
| Rail Works on Conscripted Navvies | 59% | 52% |
| Harbour Works on Press-Ganged Dock Labour | 53% | 55% |

| Countries with the law active (about 190–200 hold states) | Game 1 | Game 2 |
| --- | ---: | ---: |
| Residential Standards | 5 | 2 |
| Protected Company Housing | 4 | 0 |
| Mandated Serviced Housing | 4 | 9 |

Law counts come from reading a binary save and are approximate, but the pattern is clear. Work Towns reach 13 / 0 buildings against 906 / 1,005 Work Camps.

So in AI hands the mod's reform story barely happens. The standards gate almost never stops slums or Workers' Rows, and the penalties of forced labour last into the 1930s. The housing laws in `common/laws/50_boi_housing.txt` have no `ai_enact_weight_modifier` at all, which probably explains their part of this. The road financing laws do have weights, so those weights look too weak or too rarely triggered.

### 4. Municipal Estates get wiped out

Levels vanish all at once, then the AI starts again:

- **Game 1:** Austria 41→0 (1932), Mexico 24→0 (1935), tag RSM 14→0 (1933), USA 11→0 (1895), and 7 smaller losses.
- **Game 2:** USA 16→0 (1907) and 17→10 (1932), USA 10→0 (1891, the year it lost 20 states), Spain 9→0 (1929), and 10 smaller losses.

**Likely cause (inferred):** this matches the budget-cut demolition already recorded for works buildings. Road, Rail and Harbour Works carry `downsizeable = no`, and Municipal Estates don't. The fix is one line in the generator. As it stands, the treasury pays to build them and then loses them.

### 5. France and early Britain carry the most strain

**France** has the most power-years with debt above 0.5 in both games (40 / 29). Its 1935 radicals are 33.5 / 32.6%, among the highest of any large power (only Japan is higher, at 36.7 / 33.4%). Its works goods are only 2–5% of expenses, so the works' direct cost isn't the main reason. Vanilla France is also troubled, with debt of 0.18 and radicals of 20% in 1845, against 0.21 / 0.40 and 21 / 25% here in 1846. Whether the later strain is the mod needs a vanilla control.

**Britain** is more clearly affected early on. Its debt in 1846 is 0.34 / 0.35 against vanilla's 0.01 (highest of 10 games: 0.08), though it's gone by 1866 in both games. Britain also lost about 10 of its 27 states in both games, in 1854 and 1844, and later recovered them. None of the 10 vanilla games had Britain below 25 states by 1846, so game 2's break is outside that range, and earlier BOI tests saw the same break (see the [housing test log](../../plans/04_HOUSING.md#test-log)). Two games aren't proof, but Britain's early works bill is worth another look.

### Smaller points

- **Old stock persists.** Slums and Workers' Rows are still 349 of 721 and 408 of 865 working-class levels in 1935, because the AI can only build new, not redevelop. So the denser tiers save less infrastructure than the ladder suggests. Slums themselves are 102 / 123 levels, about 14%, and aren't running away.
- **The AI retreats from Motor Roads when automobiles hit the price ceiling.** Levels went back to Steam Rolled 6 and 5 times, each time at a price of 170–175. The earlier fear of supply collapsing on adoption didn't show. Adopters generally gained supply, such as Germany in 1930–33 and Britain in 1934–35, and roads take only about 4% of major-power automobile demand. Germany's supply did fall 5% in 1920 as it adopted, but 6 levels can't explain that much.
- **Levels can only grow, which can be costly.** Brazil in game 2 spends 15–17% of expenses on works goods from 1906 on, with usage at 55–59%. Hungary is at 10% in game 1. Overall, 12% of works levels sit in states under 50% usage in both games, so overbuilding is mostly a problem for particular countries.
- **The middle of the game may be too easy.** Major powers use only 55–64% of supply from 1846 to 1896, even with the higher floor.
- **Pollution gets high:** over 25% impact in 29 / 44 states by 1935, and Yorkshire reaches 78 / 100%. BOI's works add none directly and railways keep their vanilla lines, so this may be vanilla behaviour, but it matters if pollution joins mortality as planned.
- **Game 2 logged about 57,000 spline graphics errors** (`jomini_spline_network_graphics_old.cpp`), none attributed to BOI. Game 1 had none, and I don't know why.

## What worked

- **Stability.** Without the crash-linked `boi_states` module, both century runs and all 4 full 10-year balance runs were clean. No resume from autosave was needed. This still isn't proof of the crash's cause.
- **The road/rail split.** Rail Works grows from a niche to level with Road Works among major powers by 1935 (332 against 434, and 435 against 439). The Road ladder climbs in order, and most Rail Works reach Steel Track or Electric Signalling (81% / 90% of buildings). National Rail Grid is never used, and 11% of Road Works buildings worldwide are still on Cart Roads.
- **Affordable works.** Works goods at base price are 2.4–2.7% of major-power expenses in 1836, peak at 6.5 / 5.4%, and are 4.5 / 4.6% in 1935.
- **Housing tiers all get built,** in 1935 major-power levels:

| Working class | Game 1 | Game 2 | | Luxury | Game 1 | Game 2 |
| --- | ---: | ---: | --- | --- | ---: | ---: |
| Slum Districts | 102 | 123 | | Town Houses | 239 | 303 |
| Workers' Rows | 247 | 285 | | Boulevard Apartments | 91 | 167 |
| Regulated Terraces | 92 | 104 | | Elevator Residences | 41 | 67 |
| Tenement Blocks | 59 | 67 | | Carriage Villas | 295 | 396 |
| Model Dwellings | 47 | 57 | | Railway Suburbs | 172 | 232 |
| Apartment Blocks | 109 | 125 | | Streetcar Suburbs | 34 | 48 |
| Municipal Estates | 34 | 51 | | Motor Suburbs | 39 | 68 |
| Elevator Apartments | 31 | 53 | | | | |

- **Light and Heat gets adopted without straining markets.** In 1935, major-power levels are None 341 / 412, Wood 209 / 193, Oil 588 / 498 and Electricity 494 / 1,043. Electricity supply/demand falls to 0.75 / 0.84, but its price stays near base at about £32. Oil and wood stay comfortable.
- **Goods stay steady.** Horses hold at about £37 with supply/demand near 0.8, and transportation falls from about £52 to £34–37.

## Limits of this evidence

- **No vanilla century run,** so the civil-war rate, radicals, debt and pollution after 1846 have no comparison.
- **Two games only,** with large differences between them. Trust patterns seen in both, not single numbers.
- **AI only.** Nothing here shows how the mod plays for a person.
- **Telemetry gaps:** yearly logs don't record Rail Works tiers, financing or laws. The figures for those come from the last autosave, so they show 1936 only.

## Suggested next steps

Nothing below has been applied, so the branch still matches what these runs tested.

1. **Add `downsizeable = no` to Municipal Estates.** It's one line and low risk.
2. **Give the housing laws AI weights,** and strengthen the weights that move countries off Statute Labour.
3. **Find out why orders stall,** by logging government construction spending per country, then decide how to help indebted countries.
4. **Raise late housing output or nudge the AI to build more.** I'd try this after 1–3, then test with a century run.
5. **Run a vanilla control to 1936.** Two games would take about 4–5 hours and would settle concern 5 and the civil-war question.
6. **Decide on the population floor.** I recommend keeping 125,000: it bit in 1836, the AI recovered, and neither game shows harm clearly traceable to it. It's still a change to your 2026-08-16 rule, and one line in `common/defines/zz_boi_defines.txt` undoes it.

## Reproducing this

```powershell
.\tools\Test-Headless.ps1 -UntilDate 1936.1.1 -Autosave five_year -LongRun -NoFixtures -TimeoutMinutes 600 -StallMinutes 15
python tools\Get-BalanceSummary.py <run> --years 1836,1846,1856,1866,1876,1886,1896,1906,1916,1926,1935
python tools\Get-CenturyDetail.py <run> [more runs]
```
