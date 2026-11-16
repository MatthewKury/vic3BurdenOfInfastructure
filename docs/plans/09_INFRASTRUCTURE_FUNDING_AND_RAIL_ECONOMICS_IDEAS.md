# Infrastructure funding and railway economics (for discussion)

> **Status (end of 2026-11-13):** the open decisions here were answered while designing
> [11_PUBLIC_WORKS_HUB_DESIGN.md](11_PUBLIC_WORKS_HUB_DESIGN.md) (parts 13–14):
> - railways and ports go back to vanilla;
> - one Public Works / Coastal Public Works building per state replaces the three works and
>   buys transportation as railways spread;
> - the construction-sector idea is dropped;
> - urban centres get a horse option.
>
> The levy and railway-ownership law ideas (part 4) are parked in `docs/OVERVIEW.md` §6a.
> Keep this file for its research (parts 1, 3 and 5).

Written 2026-11-13 from a design discussion. **Nothing here is decided or implemented.**
It follows [07_STEEL_AND_CONSTRUCTION_IDEAS.md](07_STEEL_AND_CONSTRUCTION_IDEAS.md) (ideas A–N)
and [08_TRANSPORT_PROGRESSION_AND_UPKEEP_IDEAS.md](08_TRANSPORT_PROGRESSION_AND_UPKEEP_IDEAS.md).
A plan goes in `docs/plans/` before any code changes.

**The user's thoughts (2026-11-13):**
1. Infrastructure is the main reason railways exist, yet in normal games the user has to
   subsidise railways because they aren't profitable. BOI should solve that.
2. Move much of what the works do into the **construction sector**: new production methods
   for distant and local transport, inheriting the works' ideas, that stand for the
   infrastructure support a country needs. Possibly tie urban districts in too.
   - 2.1. Laws that set the public/private split of construction would then also shift who
     pays for infrastructure upkeep.
   - 2.2. Keep an infrastructure law; ideas for it are below.

**Where to resume:** part 6 lists the open decisions.

---

## 1. Engine facts gathered for this discussion

All read from vanilla 1.15 files on 2026-11-13 and added to `VIC3_MODDING_LESSONS.md` §13.
None measured in-game.

- **Who pays for construction.**
  - The treasury pays all construction-sector costs, wages and goods
    (`bg_construction` is `is_government_funded`).
  - The investment pool pays the treasury back for the share spent on buildings the economic
    system lets it fund ("investment income").
  - The split of construction points comes from `country_private_construction_allocation_mult`
    on the economic-system laws: 0.1 under command economy, 0.25 / 0.35 / 0.5 in between,
    0.75 under laissez-faire.
- **A construction sector buys no goods while construction is paused** (UI string
  `CONSTRUCTION_SECTOR_OUTPUT_PAUSED_INPUT_FACTOR`).
- **Infrastructure keys exist only in state scope.** There is no country-wide infrastructure
  modifier. A PM's state modifiers reach only the state its building stands in.
- **Vanilla railways are built to need subsidies.**
  - `building_railway` has `ai_nationalization_desire = 0.5`, with the comment "likely to need
    subsidies anyway".
  - Steam trains turn £450 of inputs into £750 of transportation at base prices, with 1,000
    workers per level.
- **Urban centres** (detail in part 3).

---

## 2. Evaluation: infrastructure methods in the construction sector

**What's right about it:**
- **The public/private split comes for free.** Goods added to the construction sector are paid
  by the treasury and the investment pool in the shares the economic-system law sets. That is
  the user's 2.1, with no script.
- **The AI already prioritises construction sectors** (`ai_value = 1000`), which avoids the
  "new government building is invisible to the AI" problem (lessons file §13).
- **It would buy steel, engines and transportation** without a new building.

**What breaks it:**
1. **Location.** With no country-wide infrastructure key, a construction-sector method can
   only add infrastructure to the state the sector stands in, and sectors cluster in a few
   states. Script would have to spread the infrastructure, leaving the method as just a cost.
2. **It isn't upkeep.** Sectors buy no goods while idle, so the cost would vanish whenever
   nothing is being built. While building, every construction point would cost more, which is
   a surcharge on new building and makes the construction and steel gap from plan 07 worse.
3. **The split follows building, not use.** It also scales with how fast a country builds,
   not with how much infrastructure it uses. And a method group that only adds cost would never
   be chosen by the AI unless script forced it.

**Verdict:** the right idea about **who pays**, but the construction sector is the wrong place
for **upkeep**.

**Online, this has been tried.** A workshop mod, "Construction Sectors Create Infrastructure",
did roughly this. According to search summaries (the page itself couldn't be read), commenters
reported that it broke after a patch, and that construction sectors use more infrastructure than
they create (`bg_construction` uses 2 per level). See part 5.

---

## 3. Urban centres: how they work, and what they could carry

**How they work (vanilla 1.15, `06_urban_center.txt`):**
- **Not buildable or expandable.** The group `bg_service` has `auto_place_buildings = yes`,
  `always_self_owning = yes` and `default_building = building_urban_center`.
- **Grows from urbanisation.** Other buildings add urbanisation per level (urban facilities
  20, many others 5–10). When a state's total crosses a threshold, the engine adds a level. The
  threshold is engine code; no define was found.
- **Owned by its own workers** (`ownership_type = self`). It pays its wages and inputs from
  selling services and transportation, mostly to city pops. The treasury doesn't pay.
- **Has economy of scale.**
- **Four method groups, chosen by the country** (no `ai_selection`):

| Group | Methods | Output |
|---|---|---|
| Amenities | market stalls → squares → covered markets → arcades | Services 15 → 30; about 4,800 jobs per level |
| Street lighting | none → gas (coal) → electric | Services, plus **+1 / +2 infrastructure** |
| Public transport | none → trams (railways tech, 0.5 engines) → motor carriages (combustion, 1 automobile) | Transportation 2 → 4 → 8. BOI adds 1 horse to the base method |
| Urban clergy | set by religion laws | Clergy or clerk jobs |

**Per level, railways are far stronger:**

| Per level | Transportation | Infrastructure |
|---|---:|---:|
| Urban centre, base / trams / motor carriages | 2 / 4 / 8 | 0 |
| Urban centre, gas / electric streetlights | — | +1 / +2 |
| Railway, early / steam / electric / diesel trains | 20 / 25 / 35 / 40 | 20 / 25 / 30 / 40 |
| Railway passenger carriages (extra) | +10 / +15 | — |

- One railway level does the transport work of about 5–10 urban-centre levels, and gives
  20–40 times their infrastructure.
- **Urban centres matter only by numbers.** About 600 levels worldwide made about 68% of world
  transportation in 1836, and about 36% by 1846 (lessons file, 10 vanilla runs).

**What the urban centre could carry in BOI:**
- **For it:**
  - It is a city-scale horse → tram → motor ladder that already exists.
  - Vanilla's streetlights are a precedent for infrastructure on urban-centre methods.
  - It sits where the urban load is, and grows with it on its own.
  - Private users pay through prices.
- **Against it:**
  - There's no size lever, so it can't answer a shortage.
  - The AI may not take a costlier method that gives infrastructure. A law could force it
    with unlocking and disallowing laws, as the religion laws do for clergy.
  - It doesn't reach the countryside.
- **Conclusion: flavour and a small city floor, not a main supply.** For example: horse
  omnibuses (horses), then trams (+3 infrastructure a level), then motor buses (+5). Even then,
  a big city gets roughly what one or two railway levels give.
- **Online:** a Paradox forum thread proposed an urban-centre "dirt roads" method giving poor
  infrastructure (seen in search results; the thread couldn't be read).

---

## 4. Another way to the larger goal: infrastructure as a paid network

**The goal, as understood:**
- Infrastructure has a running cost: the burden.
- Railways pay their own way because they are rewarded for providing infrastructure.
- The cost is shared between state and private, shifting with law.
- The horses → rail → motors progression stays.
- There is an infrastructure law.

**Why railways lose money: a glut, not labour.** *Corrected 2026-11-13 after reading LLWA
(part 5). An earlier draft said the cause was labour.*
- Steam trains, per level per week, with 1,000 workers:

  | Transportation price | Sales | Margin over £450 of inputs |
  |---|---:|---:|
  | Ceiling (£52.5) | about £1,300 | about £860 |
  | Base (£30) | £750 | about £300 |
  | Floor (£7.5) | about £190 | a loss of about £260 |

  Wages are roughly £100–200 a week for 1,000 workers, if LLWA's "annual wage 5.0 per worker"
  calibration holds. That is an estimate.
- So railways pay well at the ceiling, which is where BOI's 1836–46 games sit. They lose
  money when the local transport price collapses.
- **It collapses because vanilla builds railways for infrastructure, not for transport
  demand.** Only a few building types buy transportation (rural buildings, mainly). Railways
  built to cover infrastructure flood the market, and the price falls to the floor. Online
  players describe exactly this (part 5).
- **The fix that follows: tie transport demand to infrastructure use.** This is what LLWA's
  Logistics Hub does (part 5). Then a railway built to carry the state's load also has
  customers for that load.
- **For BOI:** if railways get infrastructure back, the glut comes back with it, unless
  demand is tied to use.

### Three layers

| Layer | Provider | Who pays | Progression |
|---|---|---|---|
| City | Urban centre (private) | City pops, through prices | horse omnibuses → trams → motor buses |
| Trunk | Railways (private or state-owned) | Users buy transportation; the owner carries any loss | rail era |
| Rural | Road Works (government) | Treasury | horses → steam rollers → motors |

- **Railways get infrastructure back,** in full or in part (plan 07, ideas D/L).
- **Railways earn from traffic.** A monthly state modifier gives railways
  `building_railway_throughput_add` scaled by how busy the state's network is: infrastructure
  use against supply, in a few tiers.
  - Busy industrial lines become profitable without subsidy; empty steppe lines don't.
  - It stands for economies of traffic density.
  - It is a free productivity bonus, so it needs sizing: online, a mod that made railways
    "drastically" more profitable reports the AI over-building them (part 5).
  - Untested: whether a building-type throughput key works on a state modifier. Group keys do
    (vanilla `unincorporated_state`).
- **Ownership is the native public/private split for running costs.**
  - The economic-system laws, plus nationalisation, already decide who builds and owns
    railways.
  - A state-owned railway's profit should reach the treasury as dividends. 1.15 has
    `country_government_dividends_*` keys, but an older online complaint says the government
    didn't get profits from its own buildings. **Check before relying on it.**
  - If it holds, it gives toll income (idea E) natively.
- **Road Works stays** as the public share and the horse floor, but smaller.
- **The burden stays real:**
  - the reduced population floor (125,000);
  - steel-heavy railway construction;
  - the rural roads bill;
  - shortages wherever investors won't build.

### Infrastructure law (the user's 2.2)

Grow the existing `lawgroup_boi_road_financing` (Statute Labour, Turnpike Trusts, Public
Highways, Road Fund) into a wider Infrastructure Policy group, rather than add a new one. These
directions can be mixed into its laws:
- **Concessions:** railways get the traffic bonus and better private investment scores.
- **State railways:** railways are pushed toward state ownership, and Road Works is boosted.
- **Infrastructure levy:** `tax_dividends_add` / `tax_land_add` recover part of the works bill
  from owners in cash. This is the most direct way to make the private sector pay for public
  roads.
- **The urban transport methods** can be unlocked or disallowed per law (see part 3).
- It ties to plan 08's Transport Policy idea (Horse Haulage / Railway Promotion /
  Motorisation): one group or two is an open decision.

### First checks, whatever is chosen

1. Does `building_railway_throughput_add` work on a state modifier?
2. How do railways make or lose money in BOI today? Read railway cash and
   employment from a headless run.
3. Does an urban-centre transport method with `state_infrastructure_add` work, and does the AI
   take it?
4. Do state-owned buildings' profits reach the treasury in 1.15?

---

## 5. What others have tried (online search, 2026-11-13)

The Paradox forum and the smods.ru mirror blocked direct page reads. Items below come from
search-result summaries and the pages that did load, so treat the details as unverified. Most
mods target older versions (1.5–1.12).

**The community's diagnosis matches ours:**
- In a Steam thread, a player argues that railway infrastructure is tied to employment and isn't
  monetised, so railways need subsidies. They add that the transportation value doesn't match
  the infrastructure value, and that many industries don't buy transport.
- Since 1.5, railways' main customers are rural buildings (farms, mines, logging, plantations).
  Several players say railways became unprofitable then.
- One player reports railways need local transport at +45% to +60% to avoid subsidies, and that
  the AI auto-built railways at +75%. That is the same price-signal idea as BOI's +25% railway
  rule.
- A mod commenter's numbers: railway profitability 5 for a build cost of 800, against mines at
  25 for 400.
- **Phase matters.** BOI's measurement has transport at its price ceiling in 1836–46. Players
  describe gluts pushing it to the floor later, where few industries buy transport. A fix
  sized for 1836 may overshoot by 1880.

**Mods and what they do:**

| Mod | Approach | Relevance to BOI |
|---|---|---|
| **Make My Railway Profitable Again!** (to 1.12) | More output per worker on every railway method. A **Gauge** method group (more capacity with more staff, or less with fewer). An **Automation** group. **Market-access price impact per locomotive tier:** steam 2.5%, electric 5%, diesel 10% | The market-access bonus is idea A, with numbers. Gauge is a ready-made "light railway vs heavy line" choice |
| **Industrial Rework – Rail Transport for Industry** | Factories get a transportation input option, as mines and logging camps have | More customers for railways, so private users pay by use |
| **Radio's Automation Tweaks** (2023) | Railways give full infrastructure regardless of employment, which removes the need to subsidise them for infrastructure. Farms get transport methods ("Road Carts") | Confirms the subsidy-for-infrastructure loop is the pain point |
| **Conservative AI Growth Engine** | "Drastically" improves railway profitability. Reports major powers then obsess over railways until returns level off | **Warning:** profitable railways mean AI over-building. Size the traffic bonus with care |
| **We Need More Transportation!** | Raises transportation supply (per the summary); paired with the railway-profit mod | Low |
| **Construction Sectors Create Infrastructure** | The user's idea 2. Reportedly broke after a patch; commenters said sectors use more infrastructure than they make | Supports the evaluation in part 2 |
| **Locomotion: Land, Water, & Air** | Road, inland-canal and airport building types as infrastructure sources beside railways and ports, and a Logistics Hub that turns infrastructure use into transport demand | **High.** Read in full; see "Locomotion in detail" below |
| **Grey's Urban Synergy Unleashed** | Supersedes several railway and transport mods; reworks auto-expand | Low |

### Locomotion: Land, Water, & Air in detail

*Read from GitHub `1230james/vic3-locomotion`, v2.6.3 (4 July 2026), which targets 1.12–1.13.
Workshop id 3032533792. About 5,400 lines of script.*

**What it is:** a vanilla-plus mod that adds infrastructure sources. Its aim is the opposite of
BOI's, which makes infrastructure a burden, but several of its tools fit BOI.

**Buildings.** All are `bg_private_infrastructure` and owned by their own workers:

| Building | Base methods | Infrastructure per level | Transportation | Notes |
|---|---|---:|---:|---|
| Roadway (urbanisation tech) | hand carts → horse wagons → steam / electric / petrol trucks | 10 → 25 | 15 → 30 | Also raises the population floor's cap (`state_infrastructure_from_population_max_add` 0.5 → 2). Horse wagons eat grain; vanilla has no horse good |
| Riverway, Waterway (canal) | sailing barges → steamboats → motor vessels | 20 → 40 | 20 → 40 | Riverway needs a river; canals cost very high construction ×3 |
| Airway (zeppelins / military aviation) | airships → airplanes | 15 → 30 | 80 → 100 | |
| Freight Depot, Exchange | buy transportation or services; output a fixed-price "market connectivity" good | — | — | Raise `state_market_access_price_impact` |

- Each building also has a passenger "traffic" method group (rickshaws, stagecoaches, buses,
  ferries, air mail) that adds transportation.
- **Railways rebalanced with `REPLACE:`.** Early trains need 2 engines, not 5, but give 15
  infrastructure, not 20. Steam trains give 30 transportation and 30 infrastructure.

**The Logistics Hub ("Transportation for Infrastructure" game rule).** This is the piece most
relevant to the user's goal 1.
- Script creates one hub per state (`no_ownership`, not buildable). It **buys transportation
  equal to the state's infrastructure use** every week, rescaled monthly by script modifiers.
- It pays for that with output of a fixed-price, untradeable good that nobody consumes. Script
  sizes the output to cover its input and wage bill, so the money appears from nowhere
  (inferred; see the lessons file).
- **The effect:** railways and other transport sellers get demand in proportion to the
  infrastructure the state uses. A railway built to cover a shortage has customers for its
  output, so the glut that makes vanilla railways need subsidies goes away.

**Other tools worth reusing:**
- **"Private expansion" method group** on every infrastructure building, railways included
  (added to vanilla's railway with `INJECT:`). Setting it to "no" calls
  `unset_available_for_autonomous_investment`, so private investors stop expanding that
  building in that state.
  - A BOI infrastructure law could use the same effects: "State Railways" bars private
    railway investment, and "Concessions" allows it.
- **AI helper.** A monthly script queues privately funded railways, canals and roads with
  `start_privately_funded_building_construction`. It requires transport at +25% or more,
  urbanisation of at least 250, existing buildings fully staffed, and enough uncommitted
  investment-pool money. Railways come first when engines are affordable.
  - Compare BOI's `00_boi_railway_ai_override.txt`, which edits the auto-expand rule instead.
- **Market-access mode (optional rule).** Lowers every country's base market-access price
  impact to 0.6, and lets Freight Depots and Exchanges earn it back. That is idea A, done
  through separate buildings that are also transport customers.

**What it means for BOI:**
1. **BOI already has a partial hub.** Rail Works buy 1.5 railway levels' worth of
   transportation, paid by the treasury. LLWA's version scales demand to
   **infrastructure use** instead. A BOI hub could:
   - give railways infrastructure back;
   - have a government-funded building (the Rail Works or a new hub) buy transportation in
     proportion to the state's infrastructure use, paid by the treasury: the public burden;
   - recover part of that from owners through the infrastructure law's levy: the private share.

   Unlike LLWA's money from nowhere, this keeps the cost real, and it pays railways for
   carrying the load rather than covering their losses.
2. **Caution, the price ceiling.** Where transport is already at its ceiling (BOI 1836–46),
   extra demand adds nothing to railway revenue. The hub helps only once supply catches up,
   which is the later-game glut. Phasing it in with the railway era is probably right.
3. **`REPLACE:` / `INJECT:`** could make BOI's vanilla shadows smaller and less
   patch-sensitive. Untested on 1.15; see lessons file §1.
4. **The investment-pool effects** give the infrastructure law real teeth.
5. **Roadway design notes:** private, self-owned roads that sell transportation are the
   inverse of BOI's government Road Works. Raising the population floor's cap from a road
   method is a lever BOI hasn't used.
6. **Out of scope:** the riverway and canal buildings. BOI carries no water features.
7. **Compatibility:** LLWA `REPLACE:`s the same railway methods BOI shadows, so the two
   mods would conflict if loaded together.

**Vanilla history:**
- 1.2 switched railway auto-building from profit to infrastructure.
- A 1.9 mod changelog says vanilla then added an infrastructure check for railways.
- BOI's `00_boi_railway_ai_override.txt` replaced that rule with a price threshold (plan 07).

**What to take from it:**
- **Market access per locomotive tier** (Make My Railway Profitable Again!) is a concrete,
  tested-in-the-wild version of idea A, and could sit with the traffic bonus.
- **A Gauge-style method group** could carry BOI's horse leeway: narrow-gauge or light
  railways, cheap and horse-assisted, against standard or heavy lines.
- **More industries buying transportation** is the market-native way to make users pay. It is
  worth considering alongside the throughput bonus, with the late-game glut in mind.
- **Expect the AI to over-build** if railways become clearly profitable. Keep the debt-check
  idea from the rail survey (2026-11-08).

**Sources:**
[Steam: railways unprofitable thread](https://steamcommunity.com/app/529340/discussions/0/4201364524150025063),
[Steam: railways and automation](https://steamcommunity.com/app/529340/discussions/0/4034724270484067743),
[Make My Railway Profitable Again!](https://top-mods.com/mods/victoria-3/gameplay/16682-make-my-railway-profitable-again.html),
[Industrial Rework](https://catalogue.smods.ru/?p=447099),
[Radio's Automation Tweaks](https://catalogue.smods.ru/?p=230890),
[Conservative AI Growth Engine](https://catalogue.smods.ru/?p=455459),
[Construction Sectors Create Infrastructure](https://catalogue.smods.ru/archives/212860),
[Locomotion: Land, Water, & Air](https://catalogue.smods.ru/?p=204491),
[Forum: no realistic infrastructure before railroads](https://admin-forum.paradoxplaza.com/forum/threads/there-are-no-realistic-sources-of-infrastructure-until-railroads-now.1835099/latest),
[Dev Diary 10: Infrastructure](https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-10-infrastructure.1485696),
[Dev Diary 71: Autonomous Investment (1.2)](https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-71-autonomous-investment-in-1-2.1565414/page-5).

---

## 6. Open decisions

1. **Railways get infrastructure back?** In full (idea D), in part (idea L), or as a
   multiplier on the works (idea I)?
2. **How railways get paid:**
   - **an infrastructure-use hub (LLWA-style), funded by the treasury, with a levy for the
     private share** (added after the LLWA read; now the strongest candidate);
   - the traffic throughput bonus;
   - market access per locomotive tier;
   - more industries buying transportation;
   - or a mix.
3. **Rail Works:** keep, shrink or drop, if railways carry infrastructure again?
4. **Urban-centre layer:** add city transport methods with small infrastructure, or leave
   urban centres alone?
5. **Infrastructure law:** grow `lawgroup_boi_road_financing` into a wider policy group, or add
   plan 08's Transport Policy as a second group?
6. **Construction-sector idea:** drop it, or keep only the "who pays" part through the
   ownership split?

**Still open from plans 07 and 08:** phasing in Britain's opening bill (idea F); upkeep tiers
(plan 08, part 3).
