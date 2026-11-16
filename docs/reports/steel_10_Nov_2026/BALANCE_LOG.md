# Balance log: steel demand (10 Nov 2026)

In the 9 November games ([phase 6 log](../phase6_9_Nov_2026/BALANCE_LOG.md)), steel sold 34% below vanilla at 1876 and engines 37% below, at about vanilla's price. BOI railways give no infrastructure, so fewer were built, and they are the main buyers of engines, which are made from steel.

You asked for the following:
- four changes (below);
- short check games to confirm the setup, including Statute Labour's new dependents modifier;
- then up to 3 iterations of two 40-year games, with a short report and balance changes after each.

Between iterations I tune the new features and the railway AI. If another feature shows a strong problem, I note it here and try a change.

**Settings for every 40-year game:**
- One ensemble member each: `-Ensemble -NoFixtures -LongRun`, to 1876.
- **No `-RailSurvey`**, at your request: its fixture made Britain survey from 1836 and clear its slums in 1837, which drove it into revolt. Every country is plain AI.
- Exactly two launches per iteration. A crashed game is salvaged up to its last complete snapshot.
- **Comparisons:**
  - `vanilla115_1836_1936_all`: 13 vanilla 1.15 games at 1846, 10 at 1856, 6 at 1876;
  - `p6_iter4`: BOI on 9 November, with `-RailSurvey`, so not a like-for-like comparison for Britain;
  - `boi115_pass4`: BOI on 6 November without fixtures, to 1846 only.

## The changes (before any game)

| # | Change | Files |
| --- | --- | --- |
| 1 | **Rail Works** buy one same-era vanilla railway level's transportation: 20 / 25 / 35 / 45 by tier (was 8 / 10 / 12 / 15). Permanent Way also buys 3 iron; Steel Track 4 steel, Electric Signalling 5, National Rail Grid 6 | `50_boi_rail_works.txt` |
| 2 | **Harbour Works** buy no merchant marine. Coastal Lighters: 3 clippers (no steamers exist in 1836). Steam Lighters: 3 steamers, 2 steel, 3 coal. Electrified Quays: 3 steamers, 3 steel, 4 electricity. The AI's price signal for them reads clippers, then steamers from `gantry_cranes` | `50_boi_harbour_works.txt`, `50_boi_ai_values.txt`, `50_boi_buildings.txt`, `boi_ai_infrastructure_events.txt` |
| 3 | **Dear horses pull railways:** the railway's AI score ×1.15 where horses are 25% dear, ×1.3 where 50% dear; a railway also auto-expands where horses are 50% dear | `00_boi_railway_ai_override.txt`, `50_boi_ai_values.txt` |
| 4 | **Roads burn engines** from Steam-Rolled Roads on: 2 a level on Steam-Rolled Roads (horses 12 → 9), Motor Roads and Modern Highways | `50_boi_infrastructure.txt` |

**Sizing**, from the last 9 November game (`20261109-165010_mod`), world totals in 1875: 697 Road Works levels, 63 Rail Works, 365 Harbour Works and 425 railways. Rail Works are few, so most of their effect is the transportation they buy, which should pull railways. Steel bought directly by the works will be modest, perhaps 1,000–1,500 a week by 1876 against a 7,500 gap. In iteration 3 of 9 November, with railways only 19% below vanilla, steel ended above vanilla's, so the railways are the main lever.

`Validate-All.ps1`: PASS.

## Check games

Both with `-Checks -LongRun` to March 1838. The checks module gained three checks:
- `.10`: every 3 months, the workforce and dependents of each peasant, laborer and farmer pop in the largest state of the two largest Statute Labour countries (China, British India) and the two largest others (Britain, France);
- `.11` and `.12`: in March 1836, give Britain `gantry_cranes` and `steam_donkey`, switch its Harbour Works to Steam Lighters and its Road Works to Steam-Rolled Roads, and log its market's buy orders before and three months after.

| Run | Result | What it showed |
| --- | --- | --- |
| `20261110-074919_mod` | FAIL, 2 BOI lines | `state_peasants_working_adult_ratio_add` and `state_laborers_working_adult_ratio_add` are "Unknown modifier type". Peasants under Statute Labour kept a working share of exactly 0.250 for two years (Britain and France: 0.300, from their laws). The new inputs work: Britain's switch took in 2 Harbour Works states and 9 Road Works states, and its market's engine orders rose from 129 to 235 and steamer orders from 0 to 5. No other errors. |

| `20261110-075313_mod` | FAIL, 0 BOI lines, 1 fixture | With the universal key (below), Statute Labour countries were at 0.230 from February 1836. But **Britain and France were at 0.280 too, not 0.300**, recovering only to 0.283 by December 1837. One fixture failed: `pledge_per_state` (below). |
| `20261110-075852_mod` | **PASS, 0 BOI errors, 23/23 fixtures** | After both fixes: Britain and France at 0.300 throughout, Statute Labour countries at 0.230. Pledge kept early. New inputs again: Britain's engine orders 109 → 216. |

**Fixes between the check games:**
- **Statute Labour uses `state_working_adult_ratio_add = -0.02`,** the universal key the rights-of-women and welfare laws use, as you asked. It hits every pop type, not just peasants and laborers.
- **Britain, the USA, France and Prussia get their road laws in country history.** Every country starts under Statute Labour, the first law in its group. BOI's global history then moved these four to Turnpike Trusts or Public Highways, but global history runs after the working-adult ratio is set. So they started with Statute Labour's −0.02 and would have taken about 15 years to recover. The four lines moved to a new `common/history/countries/zz_boi_road_financing.txt`. A law change mid-game also moves the ratio only slowly, through pop growth, so enacting or repealing Statute Labour takes years to show fully.
- **The pledge check was out of date.** It was written before the AI pledge builder existed (9 November, iteration 2). Now the AI builds the pledged second level, and the pledge is kept before the July check, which clears the state's markers. The check now also passes when the pledge was kept (trade unions pleased, 2 or more levels in the pledge state). This was the check, not the mod.

Check games used: 3.

## Iteration 1: `steel_iter1`, two games to 1876

Runs `20261110-080215_mod` and `20261110-084920_mod`. Both PASS: 0 BOI error lines, no crash, 47 and 43 minutes.

**Headline against vanilla** (vanilla 1.15, 6 games at 1876; `p6_iter4` is 9 November, with `-RailSurvey`):

| At 1876 | Vanilla | `p6_iter4` | `steel_iter1` |
| --- | ---: | ---: | ---: |
| GDP | £1,024M | −20.6% | −18.5% |
| Population | 1,368M | −4.9% | +0.3% |
| SoL | 8.81 | −6.2% | −3.4% |
| Radicals | 165M | −20% | +15% |
| Railway levels | 678 | 438 | 444 |
| Construction sector levels | 836 | 695 | 670 |
| Steel-mill levels | 162 | 125 | 86 |
| Heavy industry levels | 336 | 225 | 185 |

**Goods, weekly buy orders at 1876 (price):**

| Good | Vanilla | `p6_iter4` | `steel_iter1` |
| --- | ---: | ---: | ---: |
| Steel | 21,641 (63.2) | 14,483 (60.2) | 11,863 (**68.1**) |
| Engines | 8,669 (82.3) | 5,603 (86.9) | 5,182 (**90.0**) |
| Iron | 34,071 (41.6) | 26,181 (45.9) | 22,752 (45.9) |
| Coal | 53,400 (35.5) | 39,996 (33.2) | 31,609 (38.7) |
| Transportation | 47,570 (45.0) | 32,900 (45.4) | 32,621 (45.7) |
| Steamers | 3,202 (63.5) | 2,257 (63.0) | 2,720 (70.5) |
| Clippers | 5,753 (50.9) | 4,850 (53.7) | 4,930 (50.9) |
| Merchant marine | 7,399 (49.0) | 6,878 (54.6) | 6,052 (49.6) |

The two games differ a lot: steel buy 10,492 and 13,234 at 1876.

**Works, world totals at the end of 1875** (game 1 / game 2): Road Works 828 / 721 levels, Rail Works 42 / 50, Harbour Works 351 / 386, railways 403 / 464. Horses sold at 38–41 on a base of 30, so the railway AI's horse factor was ×1.15 in most markets.

**Britain:** game 1 changed tag in 1851 (`GBR#2`, a revolution; its Road Works dip from 42 to 31 levels in 1850). Game 2 had none. France, Austria and Prussia also changed tag in one or both games.

### Findings

1. **Steel is short on the supply side now, not just the demand side.** Steel sells 18% below the 9 November games, but its price is 8% *above* vanilla's. Engines (90 against 82) and steamers (70.5 against 63.5) are dear too. The new inputs raise prices, but the AI does not answer with mills: 86 steel-mill levels against 125 on 9 November and vanilla's 162. Rail Works are too few (42–50 worldwide) for their transportation to matter. Railways stay 35% below vanilla, the same as on 9 November.
2. **The bottleneck is construction, and most of it is Britain** (strong signal, outside the new features):
   - In vanilla, Britain holds 61 of the world's 162 steel-mill levels at 1876. In BOI it holds 26, which is 35 of the 76 missing.
   - Britain's GDP is 41% below vanilla's at 1876, and its construction sector is 25–40% smaller from 1838 on (34 against 47 in 1838, 85 against 118 in 1876).
   - **Why:** the works cost Britain's treasury about £20k a week from the first day: fixed expenses of £185k against vanilla's £166k in April 1836. Vanilla Britain spends its £960k starting treasury on construction sectors (10 → 47 by October 1836). BOI Britain has £640k left by April and none by October, so it stops at 34. It then runs at the top tax rate and minimum wages with an empty treasury until 1842. The vanilla AI adds spending only while income is well above expenses (`MONEY_SPENDING_MIN_RATIO_TO_ADD_*` 1.2–1.4 in `00_ai.txt`), so it never catches up.
   - Britain's home states use 80–100% of their infrastructure (the Midlands and East Anglia are short), so the Road Works seed is not oversized. The bill is the mod's intended burden. Its side effect is that the world's main steel buyer industrialises late.
3. **A bug in Tolls and Dues** (Britain and the USA start on it), found while tracing the budget:
   - The state pays every wage in a works building, weighted by pop type (laborers 1, shopkeepers 3, capitalists 5).
   - The law swaps 60 laborers per level for 50 shopkeepers and 10 capitalists, so the wage weight of those posts rises from 60 to 200.
   - The law described as "cheap for the treasury" was raising the treasury's wage bill on Britain's 58 works levels.
4. **Radicals, to watch:** world radicals are 15% above vanilla at 1876 (−20% on 9 November). Most of it is British India (27% radical against vanilla's 20%) and China (10.7% against 9.3%). This appears only after 1866, in 2 games, and their SoL equals vanilla's. One candidate is Statute Labour's new working-adult ratio cut, which is new since 9 November and falls on both. The other is the larger population: there is no mortality any more. Not changed yet.

### Changes for iteration 2

| Finding | Change | File |
| --- | --- | --- |
| 1 | Rail Works transportation to 1.5 railway levels: 30 / 38 / 53 / 68 (was 20 / 25 / 35 / 45). You suggested exploring higher | `50_boi_rail_works.txt` |
| 2, 3 | Tolls and Dues: staff swap now 15 shopkeepers + 3 capitalists (wage weight 60, the same as the 60 laborers), and the goods discount goes from 35% to 50%. On Road, Rail and Harbour Works | `50_boi_infrastructure.txt`, `50_boi_rail_works.txt`, `50_boi_harbour_works.txt` |

This tests whether a lighter opening bill for Britain lets it keep more construction sectors, and so build more mills and railways. The railway AI is unchanged: its horse factor is in effect, but construction, not the AI's scores, is the limit.

`Validate-All.ps1`: PASS.

## Iteration 2: `steel_iter2`, two games, both crashed early

Runs `20261110-094115_mod` (crashed in January 1843, 12 minutes in) and `20261110-095256_mod` (crashed in October 1840, 7 minutes in). Both had 0 BOI error lines.
- Both are `EXCEPTION_ACCESS_VIOLATION`. Each was cut off in the middle of the ensemble snapshot's lines for Britain (its `budget` line and its first `state` line).
- The first is at the address ending `...8509`, the same as the known telemetry crash in the lessons file (about 1 per 30 game-years in BOI games with telemetry). The second, `...E4F6`, is new, but it struck at the same place.
- Iteration 1's two clean 40-year games were the lucky case. Nothing in this iteration's change touches script, only PM numbers.

Salvaged up to their last complete snapshots, so there is no steel result. There is enough to see whether the opening bill for Britain fell, which was what the change aimed at:

| Britain | Vanilla | `steel_iter1` | `steel_iter2` |
| --- | ---: | ---: | ---: |
| Fixed expenses, July 1836 | £179k | £187k | **£170k** |
| Gold, July 1836 | £644k | £104k | **£218k** |
| Construction sector levels, 1837–1840 | 47 | 34 | **38** |
| Tax level, 1837–1840 | 2.4–2.5 | 3.0 | **2.0–2.5** |
| Debt ratio, 1838 | 0.02 | 0.08 | 0.06 |

- The Tolls and Dues fix brings Britain's fixed expenses below vanilla's by mid-1836. Britain keeps 4 more construction sectors (38), and its taxes stay off the top rate until 1840.
- It still has £270k less gold than vanilla in April 1836. Its April expenses are £26k a week higher: £14k fixed, the rest construction and other spending. Its GDP in April is 9% lower. So the gap to vanilla's 47 sectors is only partly the works bill.
- The USA (also on Tolls and Dues) is unchanged: 26 construction sectors against vanilla's 25.

### Changes for iteration 3

**None.** Iteration 2 gave no data past 1843, so a further change couldn't be judged against it. Iteration 3 reruns the same settings to get the 40-year result of the iteration 2 changes.

## Iteration 3: `steel_iter3`, the iteration 2 settings rerun

Runs `20261110-100243_mod` (PASS, to 1876, 58 minutes) and `20261110-110053_mod` (crashed in April 1863, the same telemetry crash, salvaged to its last complete snapshot). 0 BOI error lines in both. **At 1876 there is one game.**

| At 1876 | Vanilla (6) | `p6_iter4` (2) | `steel_iter1` (2) | `steel_iter3` (1) |
| --- | ---: | ---: | ---: | ---: |
| GDP | £1,024M | −20.6% | −18.5% | −10.3% |
| SoL | 8.81 | −6.2% | −3.4% | −6.5% |
| Radicals | 165M | −20% | +15% | −12% |
| Railway levels | 678 | 438 | 444 | 452 |
| Construction sector levels | 836 | 695 | 670 | 685 |
| Steel-mill levels | 162 | 125 | 86 | 148 |
| Heavy industry levels | 336 | 225 | 185 | 269 |
| Steel bought (price) | 21,641 (63.2) | 14,483 (60.2) | 11,863 (68.1) | **18,811 (60.9)** |
| Engines | 8,669 (82.3) | 5,603 (86.9) | 5,182 (90.0) | 6,171 (89.1) |
| Iron | 34,071 (41.6) | 26,181 (45.9) | 22,752 (45.9) | 28,636 (41.8) |
| Coal | 53,400 (35.5) | 39,996 (33.2) | 31,609 (38.7) | 44,153 (34.7) |
| Transportation | 47,570 (45.0) | 32,900 (45.4) | 32,621 (45.7) | 38,174 (46.5) |
| Steamers | 3,202 (63.5) | 2,257 (63.0) | 2,720 (70.5) | 2,494 (72.7) |

Works at the end of 1875 (game 1): Road Works 674, Rail Works 42, Harbour Works 369, railways 448. Horses at 37–38.

### Findings

1. **Most of the steel gain is one game's Prussia, not the changes.** In the finished game, Prussia holds 38 steel-mill levels and 47 railways at 1876, above vanilla's own Prussia (25 and 52), and Russia holds 14. In iteration 1, Prussia had a revolution in 1872 in one game (`PRU#2`, GDP £2.8M) and has no steel in the other.
   - Up to 1863, where all four games of iterations 1 and 3 have data, steel is about the same: 5,315 and 5,679 a week in iteration 1, 6,582 and 5,663 in iteration 3.
   - Two games per arm can't separate the changes from which great power industrialises.
2. **Britain is somewhat better, as iteration 2 showed for its opening.**
   - In the finished game its GDP is £71M at 1876, against £61.5M in both iteration 1 games and vanilla's £104M.
   - Its construction sector reached 97 in 1863 (iteration 1: 70 and 99). It then fell to 60 by 1876, at the top tax rate again.
   - Its steel mills (29) and railways (48) are at the same level as in iteration 1.
3. **Railways haven't moved in any iteration:** 444, then 452, against vanilla's 678.
   - The Rail Works stay few (42 in 1875), so even 1.5 railways' worth of transportation each adds only about 1,500 a week worldwide.
   - The horse factor is in effect everywhere (horses at 1.25× base), so it is a flat ×1.15.
   - The binding limit is construction capacity, not the AI's scores.
4. **Radicals** are back below vanilla (−12%), so iteration 1's +15% looks like noise between games, not Statute Labour.
5. **Crashes:** 3 of the 6 forty-year games crashed (1840, 1843, 1863), all in the known telemetry crash. All 6 had 0 BOI error lines.

### Changes after iteration 3

None. This was the last of the three iterations you allowed.

## Summary

**What changed in the mod** (all in `CHANGELOG.md` under "steel demand"):
- Rail Works buy their track (iron, then steel) and 1.5 railway levels' transportation: 30 / 38 / 53 / 68.
- Harbour Works buy clippers, then steamers and steel, instead of merchant marine.
- Road Works burn 2 engines a level from Steam-Rolled Roads on.
- Dear horses raise the railway AI's score.
- Statute Labour's cost is `state_working_adult_ratio_add = -0.02`. The four great powers' road laws moved to country history so they start without it.
- **Tolls and Dues is now cheap for the treasury.** Its staff swap had tripled the wage bill for those posts. It is now wage-neutral, and the discount went from 35% to 50%.

**What the games show:**
- The new inputs work. Engines, steamers and steel register in the markets from the first months of the check games.
- But world steel isn't reliably higher. Over the six games it ranges from 10,500 to 18,800 a week at 1876, against vanilla's 21,600. Which great power industrialises (Prussia in one game) matters more than any of the changes.
- In iteration 1, steel and engines sold *above* vanilla's price with fewer mills. So adding more demand mainly raises prices.
- The limit is the construction sector: about 20% smaller than vanilla's in every game, and 25–40% smaller in Britain.

**Strong signal outside the new features (noted, partly addressed):** Britain's works bill empties its 1836 treasury, which costs it about a quarter of its construction sectors for 40 years. The Tolls and Dues fix gave back 4 of the 13 missing sectors in the 1830s. The rest is the works themselves (Britain's home states use 80–100% of their infrastructure, so the seed is not oversized) plus other opening costs not yet traced. Closing it would mean easing BOI's core burden for Britain, which is a design decision, so I left it.

**Suggested next steps:**
1. Decide whether Britain's opening should be eased further, for example a smaller opening works bill in 1836–1840, or vanilla's starting treasury plus the works bill's first year.
2. Run 4–6 more games on these settings before judging steel. Two-game arms are dominated by Prussia's and Britain's fortunes.
3. The telemetry crash makes a 40-year game finish only about half the time. A `-NoHousing` harness switch (the module writes 190k+ lines a game) would be worth testing to see if it lowers the rate.
