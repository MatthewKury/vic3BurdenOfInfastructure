# Public Works hub: balance log (plan 12)

Started 2026-11-13 on branch `script-update`, game version 1.15.1. Design:
[plan 11](../../plans/11_PUBLIC_WORKS_HUB_DESIGN.md) parts 13–14; build:
[plan 12](../../plans/12_PUBLIC_WORKS_HUB_IMPLEMENTATION.md).

**Limits set by the user:** script tests under 3 years; then at most three 10-year games
(1836–1846), iterating between them.

**Success, as the user put it:**
- slow the hockey-stick growth a little;
- make rapid growth cause complications;
- make the player think about infrastructure as more than "I need more subsidised
  railways".

Measures: world GDP 5–15% below vanilla by 1846, not more; temporary shortages and
market-access dips that recover; railway levels and steel near vanilla; the hub bill a
noticeable share of spending; AI Mode choices and cab adoption.

**Baseline:** vanilla 1.15.0 ensemble `vanilla115_1836_1936_all` (13 members at 1846).

## Setup before game 1

- Railways and ports back to vanilla (infrastructure and AI).
- Penalty −30% incorporated / −10% unincorporated, on both the flat and the floor.
- One hub per state; CAP 20 chargeable use per level. Per-level inputs at base prices:
  Cart Roads £150, Macadam £200, Rail-Fed £190, Steel Rail £230, Motor £210, Highways
  £280, plus coastal Harbour £30–120.
- Cab Ranks and Carting on urban centres (3 horses → 5 transportation, +3 infrastructure
  a level).
- Survey discount 5–10% a survey, capped at 30%.
- The 1836 hub seed is measured in a two-month run (below), so big cities start at their
  needed level and staffed.

## Pre-game checks

- **Seed measurement**, run `20261113-113926_mod` (two months, `-PwSeed`): 898 states logged
  their January 1836 target. At CAP 20, 51 were above level 1: Home Counties 9, Yorkshire 6,
  Lancashire, Île-de-France and West Bengal 5.
- **Sanity check**, run `20261113-114128_mod` (to April 1836):
  - Seeded hubs were fully staffed, and the input trim matched the arithmetic: London bought
    96% of its per-level inputs; idle states bought 5%, less the law discount.
  - **20 of 22 British hubs were short of an input** (horses), so the first rule (cancel only
    60% when short) left Britain carrying 12% of the penalty. Russia had none short.
  - Changed to 80% before game 1.

## Game 1: `boi_pw_g1`, run `20261113-114316_mod`

Settings as above, with CAP 20 and shortage 0.8. The game reached 1846.1.15 with no BOI error
lines and 0 "Duplicated key" lines.

At January 1846, against vanilla 1.15.0 (`vanilla115_1836_1936_all`, 13 games) and the old
design (`steel_iter3`, 2 games):

| Metric | Old BOI | Game 1 |
|---|---:|---:|
| World GDP | −9.8% | **−10.9%** |
| Construction levels | −26.5% | **−9.6%** |
| Railway levels | −10.3% | **+13.9%** |
| Transportation sold | −12.5% | +9.4% |
| Steel sold | −7.2% | −8.1% |
| Engines bought | −11.6% | −27.3% |
| Iron sold | −10.3% | −17.2% |
| States short of infrastructure | −43% (17.5) | **+351% (139 against 30.8)** |
| Countries in debt | +7% | **−28%** |
| Pop-weighted market access | −0.2% | −0.6% |

**Readings:**
- **GDP is inside the 5–15% band.** The gap is essentially the old one, so it comes from the
  rest of BOI (housing, horses), not the hub.
- **Construction and railways recovered,** as plan 07 hoped: no works in the queue, and
  railways are worth building again.
- **Engines and iron fell** with the works' engine and iron inputs. Steel didn't recover.
- **The short states are spread thinly:** 139 states, at most eight per country, mostly
  incorporated, usually 2–4 points short, holding 5.7% of world population. That is
  background friction from the part of the penalty that isn't cancelled (occupancy, and
  input shortages at 0.8).
- **The hub bill is too light.**
  - Upkeep share (population-weighted) was 90–100% in every major power, so the penalty was
    nearly always cancelled.
  - Goods at base prices and full use came to about 3–5% of national expenses. After the
    trim and the law discounts it is about 1%.
  - So 28% fewer countries were in debt than in vanilla: the treasury burden is lighter than
    vanilla's railway subsidies.
- **Chargeable use hardly grew:** Britain 530 → 579, France 176 → 89, as the floor rises
  with technology. So there were few growing pains in 1836–46.
- **Mode choice follows prices:**
  - Macadam where horses are dear and tools cheap (USA 45 levels, France 32, Prussia 14);
  - Cart Roads in Russia, Turkey, Brazil and Mexico;
  - Rail-Fed only in Prussia (2) and Sweden (1), since transportation is still scarce.

**Change for game 2:** CAP 20 → 10, doubling the hub's jobs and its goods per unit of use. The
seed was regenerated at CAP 10 from the same measurement (91 states above level 1; Home
Counties 17).

## Game 2: `boi_pw_g2`, run `20261113-121000_mod`

Game 1's settings with CAP 10 and the seed regenerated at CAP 10. The game reached 1846.1.15
with no BOI error lines.

| Metric (January 1846, against vanilla) | Game 1 | Game 2 |
|---|---:|---:|
| World GDP | −10.9% | **−9.9%** |
| Construction levels | −9.6% | −12.3% |
| Railway levels | +13.9% | +9.8% |
| Transportation sold | +9.4% | +9.4% |
| Steel sold | −8.1% | −17.2% |
| Engines bought | −27.3% | −28.5% |
| States short of infrastructure | 139 | 130 |
| Countries in debt | −27.6% | −23.6% |

**Readings:**
- **Much like game 1.** The differences are within one-game noise; steel's −17% is probably
  the Prussia-type variance noted in plan 07.
- **Chargeable use shrinks over the decade:** Britain 515 → 449, the USA 286 → 179, Austria
  70 → 44, France 178 → 81.
  - Population growth and technology raise the free floor faster than the economy adds use
    in 1836–46. Hub levels never fall, so later levels sit trimmed toward the 5% minimum.
  - The floor is capped per state (60–90), so chargeable use should rise once industry
    outgrows it, after this window.
  - **This is a design question for the user:** the user chose the floor as the free base. A
    partial discount (only part of the floor free) would keep the bill growing with use.
    Not changed without the user.
- **The bill doubled per unit but is still light:** Britain's actual hub goods about 1.5% of
  spending; countries in debt still 24% below vanilla.

**Change for game 3:** every Mode and Harbour input ×1.5 (Cart Roads 7.5 horses a level;
Rail-Fed 7.5 transportation and 1.5 iron, and so on), with CAP still 10. The aim is a
noticeable bill (about 2.5–3% of spending, debt nearer vanilla) with GDP still inside the band.

## Game 3: `boi_pw_g3`, run `20261113-122619_mod`

Game 2's settings with every Mode and Harbour input ×1.5. The game reached 1846.1.15 with no
BOI error lines. **These are the settings left in the mod.**

| Metric (January 1846, against vanilla) | Game 1 | Game 2 | Game 3 |
|---|---:|---:|---:|
| World GDP | −10.9% | −9.9% | **−9.4%** |
| Construction levels | −9.6% | −12.3% | −13.9% |
| Railway levels | +13.9% | +9.8% | +9.8% |
| Transportation sold | +9.4% | +9.4% | +8.6% |
| Steel sold | −8.1% | −17.2% | **−21.7%** |
| Engines bought | −27.3% | −28.5% | −22.7% |
| Iron sold | −17.2% | −22.1% | −11.4% |
| States short of infrastructure (vanilla 30.8) | 139 | 130 | 128 |
| Countries in debt | −27.6% | −23.6% | −26.3% |
| Pop-weighted market access | −0.6% | −0.4% | −0.4% |
| Population-weighted SoL | −1.4% | −0.2% | +1.3% |

**In 1845:**
- Britain had 83 hub levels for 411 chargeable use. Its goods at full use came to £24k a
  week; the actual bill after the trim and the Turnpike discount was about £6k, about 2% of
  expenses.
- The USA had 360 chargeable use and Russia 97. Upkeep share was 93–100% in the majors.

## Summary of the three games

- **Stable across all three:** GDP 9–11% below vanilla (inside the band); railways 10–14%
  above vanilla; transportation about 9% above. Construction is far closer to vanilla than
  the old design (−10 to −14% against −27%). Around 130 states are short of infrastructure
  against vanilla's 31, but by small margins, so world market access is down only about 0.5%.
- **The cost dials barely move the macro picture.** Doubling the hub's per-unit cost (CAP 10)
  and then adding 50% left GDP and debt within noise. The hub is a modest line in the budget
  (about 2% for Britain). The friction the user wanted comes from the penalty and from
  staffing and supply, not from the bill.
- **Fewer countries in debt than vanilla in every game,** which suggests that removing the
  railway subsidy burden outweighs the hub's cost in 1836–46.
- **Steel is the regression.** It fell in each game (−8, −17, −22%), with engines and iron
  down. The retired works bought them directly. The hub's rail modes, which buy iron and
  steel, are rarely the cheapest before 1846.

**Open questions for the user (not changed):**
1. **Free base.** Chargeable use shrinks through 1836–46 as the floor grows. Keep the whole
   floor free, or make only part of it free so the bill tracks growth?
2. **Steel.** Accept for now, or give the cheap early Modes a small steel or engines line (as
   Steam-Rolled Roads had), or make the rail modes win sooner?
3. **Debt.** Fewer indebted countries than vanilla: is that acceptable, or should the hub cost
   more?
4. **The cab option** wasn't measured in these games (no telemetry for it yet); the 1836–38
   probe showed wide AI adoption.
