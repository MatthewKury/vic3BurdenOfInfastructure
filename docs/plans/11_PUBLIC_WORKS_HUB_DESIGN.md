# Public Works hub: one building whose size follows infrastructure use (design draft)

Written 2026-11-13. **A draft for iteration, not an approved plan. Nothing is built.**

> **Status (end of 2026-11-13):** the design is settled for a first pass. **Read parts 13
> and 14 first.** They supersede parts 3–10 where the two disagree: one level instead of
> levels, no Standard group, railways keep their infrastructure, and so on.
> Next: plan 10's script tests, then the implementation plan
> (`12_PUBLIC_WORKS_HUB_IMPLEMENTATION.md`).
It comes after [10_SCRIPT_TOOLS_MIGRATION_PLAN.md](10_SCRIPT_TOOLS_MIGRATION_PLAN.md) and
builds on plans 07–09, in particular the Logistics Hub in plan 09, part 5.

## 1. The idea

The user's framing: LLWA's hub resembles vanilla's army and navy logistics centres. A building
in that mould would be a mechanically consistent home for most of plans 07–09. If it can drive
demand for goods as a function of infrastructure use, BOI's three works buildings (Road, Rail,
Harbour) can become **one Public Works building** again.

**Vanilla's logistics centres** (1.15, `05_military.txt`, `00_building_groups.txt`):
- `building_army_logistics_center` and `building_naval_logistics_center` are
  `buildable = no`, `expandable = no`, `downsizeable = no`.
- Their groups have `auto_place_buildings = yes`, `default_building`,
  `ignores_productivity_when_hiring = yes`, `proportionality_limit = 1.0`,
  `fired_pops_become_radical = no` and `should_auto_expand = { always = no }`.
- **Their size follows a driver.** The engine adds a level for every 10 points of base supply
  consumed by formations using the state as a supply hub (`LOGISTICS_CENTER_SUPPLY_PER_LEVEL`).
  That sizing is engine code; a mod can't point it at infrastructure, so BOI's version needs
  script for it.
- Each has one PM group, with one PM: jobs, no goods.

**The Public Works hub** follows the same pattern:
- one per state;
- placed and sized by BOI, never built by hand;
- **its level follows the state's infrastructure use**;
- its PMs decide how the load is carried and to what standard;
- the treasury pays.

## 2. Can it have PMs? Yes

- Logistics centres have one PM group, the urban centre four, BOI's works three each. A
  building that isn't buildable can still have any PM groups.
- Players switch PMs on any building in their country, and script can too
  (`activate_production_method`, verified on 1.15 in BOI's harness, 2026-11-10).
- **Limits** (lessons file §13):
  - PMs can be gated by technology, law or principle, **not by state conditions**;
  - four groups fit the building panel, a fifth overflows.
- **AI choice:** the works use `ai_selection = most_productive`, and the AI picked the
  PM giving the most infrastructure. It also dropped back when an input hit its price ceiling.
  It's government-funded, so the "AI won't pick an unprofitable PM" trap doesn't apply.

## 3. Making goods demand follow infrastructure use

Two ways. *Round 2 (part 11): the user chose **B**, a single level whose consumption
scales. The recommendation of A below is superseded.*

**A. The level follows usage (logistics-centre style).** Each month, script sets the hub's
level from the state's infrastructure use. Then everything on the PM scales natively:
- goods inputs;
- jobs;
- the infrastructure it supplies.

An input shortage cuts the infrastructure natively too (lessons file: "Input shortages cut a
PM's state modifiers too").
- Needs a reliable way to move a level up or down. To test:
  - whether `create_building` on an existing building adds levels;
  - whether `add_building_level` with a negative level works;
  - or remove-and-recreate (LLWA's method, which resets staffing).
- **Hysteresis:** change the level only when the target is more than about 10% away, so
  workers aren't hired and fired every month.
- Script-created levels start unstaffed and hire over weeks. The 1836 levels must come from
  history (lessons file: "Seeding buildings at game start — use history"). BOI's generators
  can size them from the 1836 usage measured in headless runs.

**B. Level 1, with multiplier modifiers (LLWA's way).** Script scales the inputs
(`goods_input_*_mult` or `building_goods_input_mult`) and adds infrastructure as a scripted
state modifier.
- There's no level churn.
- But jobs don't scale, and the infrastructure no longer runs through the PM, so shortages
  and tiers need more script.

## 4. Sizing: how much infrastructure the hub supplies

The hub supplies what the state uses, minus what it gets for free, adjusted by the chosen
standard:

```
target infrastructure = (usage − free supply) × coverage of the maintenance standard
levels                = target ÷ infrastructure per level of the mode PM
```

- **Free supply** is the population floor, ports, and railways if they keep any
  infrastructure. Script can read `infrastructure` and `infrastructure_usage`. It must
  subtract the hub's own contribution, which it can store in a variable when it sets the
  level, to avoid a loop.
- **The coverage comes from the maintenance PM,** through infrastructure per level, so the
  sizing script doesn't need to know the tier.
- **Where the burden lives:**
  - Infrastructure is there **if you pay for it**. The burden is the bill: goods, wages, the
    treasury.
  - Shortages come from choosing a low standard, from goods shortages (no railways means no
    transportation for the rail mode), or from going broke.
  - That is a deliberate shift from today, where shortages come from not having built enough
    works. Open decision 1.

## 5. PM groups (four, to fit the panel)

| # | Group | Methods (draft) | What it decides |
|---|---|---|---|
| 1 | **Mode** | Cart Roads → Macadam → *Rail-Fed Network* → Motor Roads → Highways, with horse methods in parallel, gated by law | Which goods carry the load. Horses, tools, engines; **transportation** plus iron/steel in the rail mode; automobiles, oil, rubber in the motor mode |
| 2 | **Standard** (plan 08 upkeep tiers) | Very Low · Low · Medium · High · Very High | Cost against coverage, for example 60% / 80% / 100% / 110% / 120% coverage for 50% / 75% / 100% / 125% / 150% goods |
| 3 | **Administration** | today's surveyors / manorial road wardens / elected boards | Staff and politics (exists) |
| 4 | **Financing** | today's statute labour / turnpike tolls / public highways / road fund, followed from the law | Who pays and how (exists) |

**What the rail mode means for railways** (plan 09):
- In the rail mode, the hub **buys transportation in proportion to the state's
  infrastructure use**. That is the LLWA effect, with the treasury paying instead of money
  from nowhere.
- Railways become profitable from that demand, without subsidies. They can stay private and
  give no infrastructure of their own: the hub carries the load and buys the haulage.
- It sorts itself out by price, as plan 08 Option 1 hoped:
  - no railways means a transportation shortage, so the rail mode is short of inputs and gives
    less;
  - the AI drops back to horses;
  - railways get built (the existing +25% price rule);
  - transportation becomes available, and the rail mode wins.
- **Price-ceiling caution** (plan 09): while transport sits at its ceiling, the rail mode adds
  demand without adding railway revenue. It unlocks with railways anyway.

**Harbours.** A PM can't be limited to port states. So either:
- port upkeep (clippers, then steamers) is a script-applied building modifier on the hub,
  scaled by the state's port levels; or
- Harbour Works stays a separate, small building.

Open decision 4.

## 6. Laws

The road-financing law group grows into **Infrastructure Policy** (plan 09, part 4):
- **Unlocks and disallows Mode PMs.** For example, Horse Haulage keeps the best horse methods;
  Railway Promotion makes the rail mode cheaper. This is plan 08, Option 3.
- **Sets who builds railways:**
  - State Railways calls `unset_available_for_autonomous_investment` for railways;
  - Concessions allows private railways and queues them with
    `start_privately_funded_building_construction`, as LLWA's AI helper does.
- **Infrastructure levy:** `tax_dividends_add` / `tax_land_add` recover part of the hub's bill
  from owners. That is the user's public/private split (plan 09, 2.1), through law instead of
  through the construction sector.

## 7. What it replaces, and what it fixes

- **Retired:**
  - `building_boi_infrastructure`, `building_boi_rail_works`, `building_boi_harbour_works`
    (perhaps not the last, see decision 4);
  - the Rail Works cap of 1/2/4 and its scripted cap;
  - the rail survey's slot role;
  - `events/boi_ai_infrastructure_events.txt`'s building logic;
  - the works' history seed, replaced by the hub's.
- **Fixes or eases:**
  - **The AI can't see government buildings** (lessons §13): the hub is placed by script, so
    the AI never has to choose to build it.
  - **Construction competition** (plan 07, idea H): no works in the construction queue frees
    the construction sector for railways, steel mills and factories.
  - **Steel demand:** it comes from the hub's running inputs (rails, engines), which scale with
    the economy, not from one-off works construction.
  - **The railway subsidy loop** (plan 09): the rail mode pays railways in proportion to use.
- **Doesn't fix by itself:** Britain's 1836 bill. That needs the phase-in (plan 07, idea F),
  for example a fading country modifier on the hub's `building_goods_input_mult`.

## 8. Risks

- **Script cost:** a monthly per-state script for about 800 states. LLWA does the same. Watch
  the telemetry crash (lessons file, "Unsolved: a yearly all-country telemetry event…").
- **Level churn:** hiring and firing as levels move; hence the hysteresis.
- **The burden could feel automatic.** If the hub always covers usage, the player's choices
  are the standard, the mode, the laws and the treasury. Decide whether that is enough
  agency (decision 1).
- **A hub's own infrastructure use:** set `infrastructure_usage_per_level = 0` on its group,
  as LLWA and vanilla's logistics centres (0.1) do.
- **Save compatibility:** retiring three buildings breaks existing saves.

## 9. Prototype before planning code

1. **Level control:** find which effect adds or removes a level of an existing building
   cleanly on 1.15.
2. **A one-state probe:** a hub with one mode PM and one standard PM, sized monthly from
   usage. Check that its goods, jobs and infrastructure move together, and that an input
   shortage cuts its infrastructure.
3. **AI PM choice:** do AI countries move to the rail mode as transportation becomes
   available, and back when it runs short?
4. **Cost check:** the hub's bill per country against today's works bill, in a 10-year
   headless game, with Britain in particular.

## 10. Open decisions

1. **Coverage model:** the hub always covers usage at the chosen standard (the burden is the
   bill), or the player or AI still sizes it, with only the inputs following usage?
2. **Railways:** private and paid by the hub's rail mode, with no infrastructure of their own
   (recommended), or keep part of their infrastructure (plan 07, idea L)?
3. **Level control:** A (levels follow usage, recommended) or B (LLWA's multiplier modifiers)?
4. **Harbours:** fold into the hub through a script modifier, or keep Harbour Works?
5. **Population floor:** keep the 125,000 define and subtract the floor from the hub's target,
   or shrink the floor and let the hub carry more?
6. **Housing:** the housing module's infrastructure use counts toward the hub automatically.
   Is that wanted?

---

## 11. Round 2 (2026-11-13): the user's decisions, and the questions they raise

**Decisions:**
1. **One building of one level** in each state. Its consumption scales with the state's
   current infrastructure use (method B in part 3).
2. **Railways get their infrastructure back.** It sets the ceiling of what a state can carry,
   not the current use. The Public Works building consumes transportation.
3. **Two building types:** *Public Works* (inland) and *Coastal Public Works*
   (`is_coastal`, as Harbour Works today). Harbour methods exist only on the coastal one.
   - Naming note: the standing rule is no "water" wording in BOI, so the coastal methods are
     named for harbours, quays, lighters and so on.
4. **Discount the base.** Consumption leaves out some "base" infrastructure, from
   technologies and similar sources, so the buildings don't consume much at game start. *This
   also does most of idea F's job (Britain's opening) without a separate phase-in.*
5. **The rail survey's new role:** the survey enables transportation consumption in the works
   building. It is blocked until the country has the technology and has surveyed that region.
   It replaces the survey's old role of raising the Rail Works cap.
6. **Urban-centre logistics:** make it more interesting if possible, with its rail methods
   also behind the survey.

**Engine constraints these run into:**
- **PMs can't be gated by state conditions,** only by technology, law or principle. A
  per-region survey gate (5, 6) therefore can't sit on a PM's unlock. It needs one of:
  - a scripted building modifier applied in surveyed states;
  - script switching the PM back where the state isn't surveyed;
  - more building variants.
- **Four PM groups fit the panel.** Mode, Standard, Administration and Financing, plus a
  harbour group, makes five on the coastal building. The urban centre already has four, so
  rail methods there must go into its existing `pmg_public_transport` (through
  `REPLACE:`/`INJECT:`, plan 10), not a new group.
- **A single level means a fixed workforce,** unless a scripted building modifier also scales
  employment. Untested.
- **Script-created buildings start unstaffed.** The 1836 buildings come from history (one
  level, so this is easy now).
- **The "base" isn't directly readable.** Script reads total `infrastructure` and
  `infrastructure_usage`. The population floor and technology parts must be computed (the
  formula is known from defines and modifiers) or approximated.

**Assumed, unless the user says otherwise:**
- Rail Works, the 1/2/4 rail cap and the three current works buildings are retired.
- Saves from before the change won't carry over.

**Questions put to the user (2026-11-13).** Record the answers here once given.
1. **What does the building give back?** With railways, ports and the base setting capacity,
   the building is the running cost. What happens when it is short of goods or money?
   - (a) The network decays. Every state carries a standing "unmaintained network" penalty,
     for example −30% infrastructure, which the building's PM cancels when staffed and
     supplied. A shortfall in its inputs brings the penalty back in proportion, natively.
     **Recommended.**
   - (b) A market-access penalty instead.
   - (c) Cost only, no consequence.
2. **Capacity before railways.** With Road Works gone, 1836–1850 capacity is just the base
   plus ports.
   - (a) The building's road methods add capped capacity: a flat amount per Mode era, scaled
     by input fulfilment. Railways add capacity beyond that. **Recommended.**
   - (b) Nothing: base and ports only until railways.
   - (c) Bring back a buildable road capacity building.
3. **How the survey gate works.**
   - (a) Automatic. Once surveyed and researched, a scripted "Surveyed Rail Network" modifier on
     the works building moves part of its horse bill to transportation. No PM to click.
     **Recommended.**
   - (b) Rail methods unlocked by technology; script switches unsurveyed states back to horses.
   - (c) A third building variant for surveyed states.
4. **Why survey?** Consuming transportation is a cost. What makes the survey worth doing?
   - For example: rail-fed upkeep is cheaper per unit of use than horses once transportation
     is available, and it is what keeps the state's railways profitable.
   - What should survey *quality* now mean (it was +1 to +5 cap levels)? For example, the share
     of the horse load moved to rail (40–100%).
5. **Jobs.** A fixed small staff, or jobs that scale with use (a scripted employment modifier,
   untested)? Today's works employ many labourers, and their wages are part of the burden.
   **Recommended: scale jobs.**
6. **The coastal building's fifth group.** What gives way?
   - (a) The Standard tier becomes a national setting (plan 08's buttons and AI rule) applied
     by script, freeing a slot on both buildings. **Recommended.**
   - (b) Administration merges into Financing.
   - (c) Harbour upkeep as a scripted modifier rather than a PM group.
7. **The free base.** Which sources count?
   - The population floor, flat technology bonuses, decrees, ports?
   - Computed exactly, or approximated as an allowance that grows with technology?
   - **Recommended:** the population floor plus technology bonuses, computed.
8. **Urban centre.** What should "more interesting" achieve? Choose any:
   - horse demand in cities early;
   - a city rail stage (horse trams, then surveyed suburban and goods railways, then motor);
   - urban centres selling transportation to the works building;
   - small infrastructure, as the vanilla streetlights do.

   The survey gate there also has to be a modifier, not a PM unlock.
9. **Railways.**
   - Vanilla infrastructure values (20 / 25 / 30 / 40 a level)?
   - Should the railway AI go back to vanilla's infrastructure-shortage rule, dropping BOI's
     +25% price override?
   - **Recommended: yes to both,** then measure.

---

## 12. Round 3 (2026-11-13): answers

1. **The building gives back:** option (a), network decay. A standing "unmaintained network"
   penalty sits on every state; a staffed, supplied Public Works cancels it. **The building
   must be staffed from day one**, so seed it through history.
2. **Capacity before railways:** urban centres get an option that raises infrastructure by
   consuming more horses. Public Works itself adds no capacity.
3. **and 4. No gating.** The survey instead applies an **efficiency modifier**, so Public Works
   costs the state less to run in surveyed regions. Transportation consumption sits in the
   ordinary Mode PMs (railways technology).
5. **Jobs:** scale slowly with use. If that doesn't work, the fallback is a maximum amount of
   use each works can maintain; above it, another works is added.
6. **Coastal Public Works also has four groups.** Its Mode group has more options, or
   different ones. To be designed.
7. **The free base** is the population floor plus technology bonuses. In vanilla these are the
   same thing: every technology infrastructure bonus is a
   `state_infrastructure_from_population_add/_max_add`. Decrees are not part of the base.
8. **Urban-centre logistics:** set aside for now. The horse option in answer 2 is enough.
9. **Railways go back to vanilla:** the building, its PMs and its AI logic. BOI's railway PM
   shadows and `00_boi_railway_ai_override.txt` are dropped.

**Engine facts found this round** (vanilla 1.15):
- `common/static_modifiers/00_code_static_modifiers.txt` has engine-applied
  `incorporated_state`, `unincorporated_state` and `coastal_state` modifiers. With `INJECT:`
  (plan 10), the decay penalty could live there, with no script and present from day one.
- Vanilla has a decree with `state_infrastructure_mult = 0.1`. Whether the mult also scales the
  population floor is still untested (plan 07, idea I).

**New questions (round 3).** Record the answers here.
1. **Ports:** back to vanilla as well (+3 / +4 / +5 a level)? Their removal sits in the same
   shadow file as the railways'.
2. **The penalty:** how large to start (say −30%)? Should it be a share of **all**
   infrastructure (`state_infrastructure_mult`, if that hits the floor), or only of
   building-provided capacity (railways, ports, urban centres)? Unincorporated states: a hub
   too, a smaller penalty, or none?
3. **What separates the Mode PMs** now that none is gated? For example: each cancels the
   penalty; later ones cost less per unit of use and/or give a small bonus on top, so the AI
   climbs, then drops back when an input runs short.
4. **The Standard tier and the AI.** With `most_productive`, the AI would always pick Very High
   (the most infrastructure). A script AI rule is needed: Medium by default, Low when broke,
   High when short. Does each tier scale both the consumption and the share of the penalty
   it cancels?
5. **Survey efficiency:** how large? For example −10% to −30% of the bill by survey quality,
   with repeat surveys stacking. On the whole bill or only part? Does the survey still need the
   railways technology?
6. **The jobs fallback:** is the extra works added automatically by script (no construction
   cost, like vanilla's logistics centres), or through the construction queue (which brings
   back the AI's blindness to government buildings)?
7. **The urban-centre horse option:** should it pay for itself by selling transportation (the
   AI only takes profitable methods on the urban centre), how much infrastructure a level, and
   from 1836? Rural states without cities get nothing extra before railways. Is that intended?
8. **The infrastructure law** (road financing → Infrastructure Policy, with levy and
   railway-ownership options): in this plan, or the next?
9. **What does success look like?** For example, the Public Works bill as a share of
   government spending, and world GDP, railways and steel against vanilla in a 40-year
   ensemble.

---

## 13. Round 4 (2026-11-13): answers, and the consolidated design

**Answers:**
1. **Ports go back to vanilla too** (+3 / +4 / +5).
2. **The penalty:** −30% infrastructure in every incorporated state, −10% in unincorporated
   states.
3. **Mode PMs:**
   - later modes cost more at base prices for more benefit;
   - local prices decide in practice, so a state with dear transportation and cheap horses
     keeps a horse mode longer;
   - the AI should pick on cost.
4. **The Standard PM group is dropped.** Consumption already follows real use. The government
   wage slider can carry the standard if needed.
5. **The survey** cuts the Public Works bill by 5–10% each time (by quality), to at most 30%.
   It unlocks with the railways technology.
6. **Extra capacity, if needed, appears automatically,** like the army supply buildings.
7. **The urban-centre horse option** sells transportation. A first-pass guess is wanted.
   Available from 1836. Rural states get nothing extra before railways.
8. **The infrastructure law is the road-financing law,** converted to the new system.
9. **Success:**
   - slow the hockey-stick growth a little;
   - make rapid growth cause complications;
   - make the player think about infrastructure as more than "I need more subsidised
     railways".

**Engine notes for these answers** (vanilla 1.15):
- **AI selection.** `ai_selection` has only `most_profitable` (the default) and
  `most_productive` (`production_method_groups.md`). For a building that sells nothing,
  `most_profitable` should mean "cheapest at local prices", which matches answer 3. Untested.
  `most_productive` is what the works use now, and picks the most infrastructure.
- **Government wages.** The slider applies `country_government_wages_mult` (−0.3 / −0.15 / 0 /
  +0.15 / +0.3, `00_code_static_modifiers.txt`), and Public Works is government-funded, so its
  wages follow the slider with no script.
- **Discounts don't multiply.** `building_goods_input_mult` values add up rather than
  compound: Road Fund's −0.25 on a PM plus a scripted +4.0 for use gives ×4.75, not ×3.75. The
  monthly script should fold the law and survey discounts into the one multiplier it applies.

### Consolidated design (first pass)

**Capacity** (how much infrastructure a state can carry):
- the population floor, which includes the technology bonuses;
- railways and ports at vanilla values;
- the urban-centre horse option;
- decrees.

**The decay penalty:** −30% infrastructure on incorporated states, −10% on unincorporated
ones. It goes on vanilla's engine-applied `incorporated_state` / `unincorporated_state`
modifiers (via `INJECT:` if plan 10's tests pass, otherwise by script).
- Untested: whether `state_infrastructure_mult` also scales the population floor. If not, the
  penalty hits only building capacity, or needs another form.

**Public Works / Coastal Public Works:**
- One per state, one level, placed like vanilla's logistics centres. Not buildable,
  expandable or downsizeable.
- Seeded through history so it is **staffed on day one**. Script places one in states that
  appear later (conquest, release).
- The group copies the logistics centres' settings:
  - `ignores_productivity_when_hiring`, `proportionality_limit = 1.0`;
  - `fired_pops_become_radical = no`;
  - `should_auto_expand = { always = no }`;
  - `infrastructure_usage_per_level = 0`.
- **Its PMs cancel the penalty** (workforce-scaled `state_infrastructure_mult` +0.30, or +0.10
  where unincorporated). Short staffing or short inputs bring part of the penalty back.
- **Consumption follows chargeable use**, which is the state's usage minus its population
  floor, never below zero. Once a month, script sets one goods multiplier on the building
  from that, with the law and survey discounts folded in.
- **Jobs scale slowly toward chargeable use.** A scripted employment modifier moves a few
  percent a month. While hiring lags, the cancellation is incomplete. **That lag is the
  intended "growing pains":** a state that grows fast runs short for a while.
  - A minimum staff keeps the penalty cancelled in states with no chargeable use.
  - **Fallback** if a scripted employment modifier doesn't work: each level maintains up to N
    use, and script adds levels automatically, like the logistics centres.
- **PM groups** (three are needed; a fourth slot is free):
  1. **Mode.** Cart Roads → Macadam → Rail-Fed (transportation, iron, then steel) → Motor →
     Highways. Each cancels the penalty. Later ones cost more at base prices and add a small
     bonus on top, for example +0 / +3% / +6% / +10% / +15%. The coastal version has extra or
     different modes (to design).
  2. **Administration** (carried over).
  3. **Financing.** The road-financing law's four PMs, carried over. They follow the law
     through `unlocking_laws` / `disallowing_laws`, as now.
- **The rail survey:** a −5% to −10% Public Works bill in the surveyed states, by quality,
  stacking to −30%. It needs the railways technology. The 1/2/4 Rail Works cap and its
  modifiers are retired.

**The urban centre** (first-pass guess). A new PM in `pmg_public_transport`, "Cab Ranks and
Carting":
- 3 horses (£90 at base) in, 5 transportation (£150) out, +3 infrastructure per level
  (workforce-scaled).
- Its margin at base prices is £60 against the base PM's £30, so the AI should take it where
  horses are affordable, and drop it where they are dear.
- Trams (railways technology) earn more, so cities will leave it once trams arrive, and lose
  the +3. Railways should be there by then.

**Retired:**
- Road Works, Rail Works, Harbour Works, their history seed and AI events;
- BOI's railway and port PM shadows;
- `00_boi_railway_ai_override.txt`;
- the horse-price railway AI factor.

**Success measures** for a 40-year ensemble, about 6 games per arm, against vanilla:
- world GDP a little below vanilla, for example 5–15% at 1876, not more;
- the count of states short of infrastructure and the dips in market access rising in
  fast-growing periods, then recovering;
- railway subsidies near zero;
- railway count and steel at or near vanilla;
- the Public Works bill a noticeable but bearable share of spending. Set the number after the
  first run.

### Draft phases (after plan 10)

1. **Prototype tests:**
   - does `state_infrastructure_mult` scale the floor;
   - can a scripted employment modifier change a building's jobs;
   - does `most_profitable` pick the cheapest PM on a building that sells nothing;
   - can script read the population-floor part;
   - a one-state hub probe.
2. **Revert railways and ports to vanilla;** remove the railway AI override.
3. **Build the Public Works buildings and group,** the penalty, the monthly script, and the
   history seed (generated).
4. **Move the road-financing and administration PMs onto the hub;** retire the three works.
5. **Rework the rail survey** into the efficiency modifier.
6. **Add the urban-centre horse PM.**
7. **Update the harness telemetry** (hub bill, penalty, market access), run 10-year smoke
   tests, then the 40-year ensemble against the success measures.

**Questions still open (round 4).** Record the answers here.
1. **AI mode choice.** `most_profitable` means "cheapest at local prices". It ignores the
   bonus, so the AI moves up only when the later mode becomes cheaper locally. That matches the
   horses story, but the AI rarely takes a bonus it would have to pay for. Accept that, or add
   a script rule that weighs cost against bonus?
2. **The free fourth slot:**
   - put harbour upkeep in a fourth **Harbour** group on Coastal Public Works, so both
     buildings share one Mode ladder (simpler);
   - or keep a separate coastal Mode ladder?
3. **Government wages:** wages only, which is automatic, or should the slider also scale the
   building's goods and the share of the penalty it cancels (script)?
4. **The road-financing laws:** carry over with their current effects first (Statute Labour,
   Turnpike Trusts, Public Highways, Road Fund), and add levy or railway-ownership ideas later?
5. **When to write the implementation plan:** now, or after plan 10's `INJECT:` tests? The
   results change how the penalty, the urban PM and the railway revert are done.

## 14. Round 5 (2026-11-13): answers. The design is settled for a first pass.

1. **AI mode choice:** run with `most_profitable` (cheapest at local prices) for now. The AI
   rarely buying a bonus is accepted.
2. **The fourth slot becomes a Harbour group on Coastal Public Works.**
   - Both buildings share Mode, Administration and Financing.
   - The coastal one adds harbour upkeep options, which makes coastal states somewhat "better",
     as the user finds fitting.
   - The coastal building replaces Harbour Works, so its harbour PMs take over Harbour Works'
     method ladder:
     - Coastal Lighters (clippers), then Steam Lighters (steamers, coal), then Electrified
       Quays;
     - each adds a small bonus on top of the shared penalty cancellation, scaled with the
       state's use as the rest of the bill is.
   - Exact numbers go in the implementation plan.
   - Keep the standing rule: harbour, quay and lighter wording only; never "water".
   - `city_type = port` needs `tools/Build-CityTypes.py` to list it, as Harbour Works does
     today.
3. **Government wages scaling the goods and the penalty share: revisit later.** For now, only
   wages follow the slider (automatic). Logged in `docs/OVERVIEW.md` §6a.
4. **The road-financing laws carry over with their current effects.** The levy and
   railway-ownership options (State Railways / Concessions) come later. Logged in
   `docs/OVERVIEW.md` §6a.
5. **The implementation plan is written after plan 10's script tests,** as
   `docs/plans/12_PUBLIC_WORKS_HUB_IMPLEMENTATION.md`. It starts with phase 1 (the prototype
   tests) of the draft phases in part 13.

**PM groups, final for the first pass:**

| Group | Public Works | Coastal Public Works |
|---|---|---|
| Mode | Cart Roads → Macadam → Rail-Fed → Motor → Highways | same |
| Administration | carried over from Road Works | same |
| Financing | the road-financing law's four PMs | same |
| Harbour | — | Coastal Lighters → Steam Lighters → Electrified Quays |
