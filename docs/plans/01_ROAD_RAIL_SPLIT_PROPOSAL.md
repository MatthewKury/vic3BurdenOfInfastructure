# Burden of Infrastructure: Road Works and Rail Works Proposal

Written 2026-11-01, revised the same day with your answers. **Implemented 2026-11-03, with changes:** no `required_input_goods` on automobiles (it only works on local goods), and the floor is at 125,000 as a trial. All new numbers are test values. Back to [plan 1](01_CORE_INFRASTRUCTURE_AND_HORSES.md).

Split Public Works into two buildings that can sit side by side in a state. **Road Works** is available everywhere and runs on horses, then automobiles. **Rail Works** needs a railway in the state and runs on transportation alone. Harbour Works stays. All three pay about 50% more per point of infrastructure than they do today, and the financing laws apply to all three.

**Decided:**

- Rail Works requires a railway in the same state.
- Motor Roads keep 3 horses per level, so automobiles replace horses gradually.
- Financing laws apply to all the works buildings, not just roads.
- Infrastructure should cost more. The evidence agrees, as set out below.

**One decision left, on your design rule:** the population floor gives most of the world's infrastructure for free, and you set a rule on 2026-08-16 to leave it alone. Price alone won't make infrastructure bite, because so few points have to be bought. I recommend keeping the floor unchanged for now, then testing a small cut (`INDIVIDUALS_PER_POP_INFRASTRUCTURE` from 100,000 to 125,000) once the higher prices have been run. Are you willing to relax that rule for a test?

**The test that could change the numbers:** nobody has checked whether an input shortage reduces the infrastructure a building gives. Transportation is short almost everywhere, so this decides how much Rail Works delivers. A one-year headless run takes about 2 minutes, so it comes first.

## Is infrastructure too cheap?

Yes, in two separate ways, and the second matters more. All figures come from the kept BOI run, which ended in 1845 and is a single run, so read them as directions.

**These prices are out of date.** The 2026-11-01 horse scarcity pass ([details](../../tools/HORSE_SEED_1836.md)) raised early horse prices after this was written, for example France from about £25 to £40 in 1836. Roads now cost more than these tables show, especially in the first decade, so re-price them from `20261101-132605_mod` before setting final numbers.

**1. Each point is cheap.** On paper Cart Roads costs £20 of goods per point, but law discounts and low horse prices cut that well below £20 in many countries.

| Country (starting law) | Horse price | Cart Roads, goods per point |
| --- | --- | --- |
| USA (Turnpike Trusts) | 20.0 | £6.7 |
| Austria (Statute Labour) | 16.9 | £9.2 |
| Russia (Statute Labour) | 18.0 | £9.8 |
| Britain (Turnpike Trusts) | 45.2 | £15.1 |
| France (Public Highways) | 23.5 | £15.6 |
| Prussia (Public Highways) | 30.1 | £20.1 |

**2. Few points have to be bought at all.** This is the bigger effect.

- **Works supply about 13% of infrastructure** in the 13 countries logged: about 1,600 of 11,882 points, assuming their Public Works are on Cart Roads. Nearly all the rest is free, from the population floor and flat bonuses.
- **World usage is 49% of supply** in 1845, even with housing counted.
- **The world was only 7 points short in 1845,** spread over 10 states, after the AI event had built what it wanted.
- **Works cost about 2% of government spending** across those 13 countries: about £30,000 a week against £1.5 million. It ranges from 1.1% in the USA to about 5% in Sweden and Brazil. This uses my wage estimate of £85 per level and vanilla's budgets, because BOI's normal telemetry doesn't log spending.

For a mod whose thesis is that infrastructure is a burden, 2% of the budget isn't one. It also explains the problem behind housing decision 4, where Public Works was so cheap that replacing housing took about 37 years to pay back. At the proposed prices, my estimates are about 28 years at today's 600-point Apartments, and about 7 years at 200 points (down from 10).

## How to raise the cost

| Lever | Effect | Verdict |
| --- | --- | --- |
| Cut infrastructure per level by a third | Goods, wages and construction per point all rise 50%, and horse demand only grows if more levels get built | **Do it** |
| Trim law discounts | Statute Labour -40% to -30%, Turnpike -50% to -35%. Needed anyway, because the laws now cover all the works | **Do it** |
| Raise goods inputs | Raises only goods cost, and pushes up horse demand per level at once | Keep in reserve |
| Raise construction cost | A one-off payment, not a standing burden | Only Rail Works, at 600 points |
| Raise infrastructure use | Housing's proposal already does this (about 1.8 times) | Decide there, and don't stack it blindly |
| Shrink the population floor | The only lever that changes how many points must be bought | **Your decision, after a price run** |

**Why a third.** If seeded levels stay as they are, the 1836 seed still roughly covers what railways and ports lost. Today it gives 1,946 points against the 1,107 removed. The new values give 1,193, which also eases Britain's over-seeding. Halving output would fall below 1,107.

**What it does to budgets.** If countries buy the same infrastructure at the new prices, works rise from about 2.0% to about 3.3% of government spending: Britain to 4.1%, Sweden and Brazil to over 8%. This is still modest, which is why the floor question remains. France's and the USA's debt in this run (0.44 and 0.33 of the debt ceiling) is already above vanilla's mean (0.19 and 0.08). That's one run against ten, but watch it.

### The population floor

The floor is `state_infrastructure_from_population_add` × population ÷ `INDIVIDUALS_PER_POP_INFRASTRUCTURE`, up to a tech-set cap that large states reach. Overriding that one define is a single-line change, and because of the cap it mostly leaves huge states such as China's alone.

I estimated the effect from the run's per-state data, inferring each country's floor rate from its states. These are static snapshots: they don't let the AI respond, and the rates are rough.

| Floor setting | Short states, 1836 | Points short, 1836 | People in short states, 1836 | World use, 1836 | Short states, 1845 | Points short, 1845 |
| --- | --- | --- | --- | --- | --- | --- |
| Today, today's works | 39 | 134 | 10% | 49% | 10 | 7 |
| Today, proposed works | 49 | 198 | 13% | 51% | Not simulated | Not simulated |
| **125,000, proposed works** | 83 | 479 | 15% | 57% | About 50 | About 149 |
| 150,000, proposed works | 145 | 896 | 20% | 64% | About 112 | About 459 |

The 1845 floor rows use today's works and don't include the output cut. Even at 150,000, filling every shortfall would take about 90 Road Works levels worldwide in 1836, so I don't expect a collapse. But it adds to housing's infrastructure increase, so the two shouldn't be raised together without a run in between.

## What is wrong with the single building

Public Works has one ladder, so every state climbs the same steps whatever it has locally.

| Tier today | Unlock | Inputs | Infra | Problem |
| --- | --- | --- | --- | --- |
| Cart Roads | None | 10 horses | 15 | None |
| Macadam Roads | `mechanical_tools` (era 2) | 12 horses, 3 tools | 22 | None |
| Rail Network | `steel_railway_cars` (era 3) | 8 horses, 10 transportation | 30 | Offered in every state, with or without a railway |
| Motor Roads | `combustion_engine` (era 4) | 12 transportation, 5 oil | 38 | A road tier with no vehicles, tied to local transportation |
| Modern Highways | `paved_roads` (era 5) | 15 transportation, 3 automobiles | 48 | Mostly fed by transportation, the rail good |

A state also can't use both kinds of network. The AI can't choose well either: production methods can't test whether a state has a railway, and its `most_productive` setting may simply take the highest tier.

The comment on `pm_boi_rail_network` is also wrong. It says the tier only works where a railway sits in the same state, but urban centres make transportation too.

## What the measurements say about transportation

These are means from the 10 vanilla runs. The urban centre share is my arithmetic from their base output of 2 per level, ignoring modifiers.

| World, vanilla | 1836 | 1846 |
| --- | --- | --- |
| Buy orders per week | 12,989 | 20,615 |
| Sell orders per week | 1,775 | 4,508 |
| Supply as a share of demand | 14% | 22% |
| Railway levels | 18 | 91 |
| States with a railway | 11 of 888 | 59 of 869 |
| Share of supply from urban centres (estimate) | About 68% | About 36% |

**Railways sit where the demand is.** In 1846 those 59 states hold 18% of the world's people and 25% of its infrastructure use. Britain has about 31 levels, France 12, British India 11, the USA 9, Prussia 8 and Austria 6. Those are vanilla figures: BOI's normal telemetry doesn't log railway levels.

**Update, 2026-11-01: railway states aren't short.** Per-state telemetry changes the picture below. In the 20-year run `20261101-151839_mod`, states with a railway have supply at 55% of demand in 1845 and 65% in 1855, with a median price of about £38–41. In 1855, 76 of 88 are above the 50% shortage line. States without one stay at 9% and the £52.50 ceiling. Requiring a railway is therefore also what keeps Rail Works out of shortage, and Permanent Way costs about £23–25 per point in those states, not the £32.3 ceiling figure. Rail Works should compete sooner than this proposal says, so re-price it from that run. The shortage-penalty test still matters, but much less.

**Shortage penalties could halve the output.** A good is in shortage when supply is below 50% of demand. The building then takes an output penalty of 5% to 50%, or 75% if the good is missing entirely (`GOODS_SHORTAGE_PENALTY_*`). In the kept BOI run, France, Prussia and the USA are above that line in 1845, Austria sits just under it at 48%, and Britain is at 32%. Most other major powers are at 23% or below. Because transportation is a local good, those market totals can hide state differences in both directions.

## Proposed buildings

All three sit in `bg_boi_public_works`, so they are government-funded and appear together. "Public Works" survives as the category name. All three use `downsizeable = no`, or AI budget cuts would demolish them.

### Road Works

This is today's building with a new display name. It keeps the 500 staff, `construction_cost_medium`, and the Bureaucracy administration group. The ladder loses transportation entirely.

| Tier | Unlock | Inputs | Goods cost | Infra (today's) | £ per infra |
| --- | --- | --- | --- | --- | --- |
| Cart Roads | None | 10 horses | £300 | 10 (15) | 30.0 |
| Macadam Roads | `mechanical_tools` (era 2) | 12 horses, 3 tools | £480 | 15 (22) | 32.0 |
| Steam-Rolled Roads (new) | `steam_donkey` (era 3) | 12 horses, 3 tools, 3 coal | £570 | 19 (30) | 30.0 |
| Motor Roads | `combustion_engine` (era 4) | 3 horses, 3 automobiles, 3 oil | £510 | 24 (38) | 21.3 |
| Modern Highways | `paved_roads` (era 5) | 5 automobiles, 5 oil | £700 | 32 (48) | 21.9 |

- **Staff stay on today's tier mix.** Steam-Rolled Roads takes Rail Network's 275 laborers, 100 machinists and 25 engineers.
- **Automobile tiers need a supply check.** Both should use `required_input_goods = automobiles`. `combustion_engine` is also the first tech that lets anyone produce automobiles, so without the check the AI could upgrade the moment it researches the tech, with no automobile supply anywhere in its market.
- **Horse demand lasts longer.** Tier 3 rises from 8 horses to 12 and tier 4 from 0 to 3. Horses then disappear at tier 5, which leaves room for the "horse's decline" idea in the overview.
- **Automobile demand is modest per level.** One level of Motor Industry makes 30 automobiles a week at its first tier, enough for 10 Motor Roads or 6 Modern Highways levels.

### Rail Works (new building)

It's unlocked by `railways` and gated by `possible = { has_building = building_railway }`. The ladder follows the same technologies as vanilla's railway, and transportation is its only input.

| Tier | Unlock | Input | Goods cost | Infra | £ per infra at base | £ per infra at price ceiling | Share of one railway level's output |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Permanent Way | `railways` (era 2) | 8 transportation | £240 | 13 | 18.5 | 32.3 | 40% |
| Steel Track | `steel_railway_cars` (era 3) | 10 transportation | £300 | 20 | 15.0 | 26.3 | 40% |
| Electric Signalling | `electric_railway` (era 4) | 12 transportation | £360 | 27 | 13.3 | 23.3 | 34% |
| National Rail Grid | `compression_ignition` (era 5) | 15 transportation | £450 | 33 | 13.6 | 23.9 | 38% |

- **Costly against what vanilla gave free.** An early vanilla railway level gave 20 infrastructure with no running cost. Here 13 points take about 40% of that railway's output, plus wages.
- **Construction `high` (600 points).** Laying track should cost more than a road, but less than the railway itself (800).
- **Staff of 500, more skilled than roads:** 300 laborers and 100 machinists at the first tier, moving to 125 laborers, 175 machinists and 100 engineers at the top. Administration has its own group with the same law gates and headcounts as roads.

### Harbour Works

Same building and inputs, with output cut by the same third: Coastal Lighters 10 to 7 (£28.6 per point), Steam Lighters 18 to 12 (£28.3), Electrified Quays 25 to 17 (£24.7).

## Financing laws on all three

This closes plan 2's question about including harbours, and it moves its "Harbour Works financing" item into this work.

**The laws can't simply be copied onto each building.** The current PMs were written for one building, and three things break:

- **Turnpike's +15% would stack.** It's a state-wide `state_infrastructure_mult`, applied once per building. Three buildings would give +45%.
- **Statute Labour's flat -4 would gut Harbour Works.** It would cut Coastal Lighters from 7 to 3.
- **Statute Labour's side effects would jump.** Peasant mortality +3% and farm throughput +1% apply per level. 108 of the 141 seeded Harbour Works levels are in Statute Labour countries, against only 16 of the 40 Public Works levels today.

So each building gets its own financing group, with the same three-way law structure:

| | Statute Labour | Tolls (Turnpike Trusts) | State funding (Public Highways) |
| --- | --- | --- | --- |
| Goods input, all three | -30% (was -40%) | -35% (was -50%) | Baseline |
| Staffing, all three | Unchanged | -60 laborers, +50 shopkeepers, +10 capitalists | Baseline |
| Infrastructure per level | Road -2, Rail -2.5, Harbour -1.5 (was -4) | Unchanged | Baseline |
| +15% of state infrastructure | No | Road Works only, so it stays once per state | No |
| Peasant mortality per level | Road and Rail +3%, Harbour +1% (replacing SoL penalties, 2026-11-01) | No | No |
| Farm and ranch throughput per level | Road and Rail +1%, Harbour none | No | No |
| PM names | Road duty, conscripted navvies, press-ganged dock labour | Turnpike tolls, railway concessions, harbour dues | Public highways, state railways, state harbours |

**Names.** The law group can't stay "Road Financing". I'd use "Public Works Financing", with Statute Labour, "Tolls and Dues" and "State Funding" as display names. The keys stay, so the starting laws, ideologies and fixtures keep working.

**Politics.** Railways are no longer an escape from road politics, as I first suggested. Instead, the law you choose now shapes every network: conscripted navvies under a Landowner government, private concessions under Industrialists, state railways under reformers. The law matters much more, so plan 2's check on Landowner lock-in becomes more important.

## How the choice plays out

I priced each option at the market prices in the kept run's final 1845 sample, under each country's starting law, using goods only. Wages are about £85 per level for all three at these tiers, on my estimate. "Best road" is the cheaper of Cart and Macadam.

| Country (starting law) | Horses | Transportation | Merchant marine | Best road, per point | Rail Works, per point | Harbour Works, per point | Cheapest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Netherlands (Statute Labour) | 50.4 | 52.5 | 36.8 | 43.9 | 28.0 | 18.7 | Harbour |
| Britain (Turnpike Trusts) | 45.2 | 52.5 | 55.0 | 29.4 | 21.0 | 20.4 | Harbour or rail |
| Sweden (Statute Labour) | 39.6 | 52.5 | 57.9 | 34.5 | 28.0 | 29.5 | Rail |
| Prussia (Public Highways) | 30.1 | 44.6 | 72.4 | 30.1 | 27.5 | 41.4 | Rail |
| Portugal (Statute Labour) | 31.8 | 52.5 | 34.4 | 27.8 | 28.0 | 17.5 | Harbour |
| France (Public Highways) | 23.5 | 49.2 | 42.6 | 23.5 | 30.3 | 24.3 | Road |
| Russia (Statute Labour) | 18.0 | 52.5 | 52.2 | 15.8 | 28.0 | 26.6 | Road |
| Austria (Statute Labour) | 16.9 | 52.5 | 56.1 | 14.8 | 28.0 | 28.6 | Road |
| USA (Turnpike Trusts) | 20.0 | 47.4 | 28.1 | 13.0 | 18.9 | 10.5 | Harbour or road |

This gives each network a real niche: ranching countries stay on roads, horse-short rail powers move to rail, and harbours help on coasts with cheap shipping.

- **A shortage could reverse it.** If the penalty does cut infrastructure, Rail Works at a 50% penalty would cost about twice these figures, and it would rarely make sense until transportation stops being short.
- **Rail Works won't attract railways at first.** Transportation is already at or near its price ceiling, so the extra demand can't raise the price or the railway's profit. It only takes transportation from mines and pops in that state.
- **Rail stays a late-game story.** Only countries with `railways` and a railway in the state can use it. Road Works will supply most land infrastructure through at least the 1850s, and no test run has reached the years when rail should matter most.
- **Late game the networks converge.** At the ceiling rail costs about the same as Motor Roads at base price. If automobiles are also at their ceiling, Motor Roads and Highways cost about £31–34 per point.

As a rough scale, one Rail Works level per railway level in 1846 would buy 728 transportation a week, using vanilla's 91 railway levels: about 4% of world demand and 16% of world supply. It would give about 1,180 infrastructure.

## AI

The engine won't build these buildings by itself, so the monthly construction event has to choose between three. I would extend it in this order, in the short state it has already picked:

1. **Rail Works**, if the owner has `railways`, the state has a railway, it has fewer Rail Works levels than railway levels, and either transportation is less than 50% above base or horses are at least 50% above base.
2. **Harbour Works**, under today's rule.
3. **Road Works** otherwise.

A pure transportation price test wouldn't work, because the price sits at the ceiling across most of the world. The horse clause covers countries like the Netherlands and Britain, where the transportation price says nothing but horses are the real pressure. The one-for-one cap stops the AI overloading a state's supply, and it's a starting value.

`boi_ai_state_wants_works` also has to count Rail Works. `boi_ai_public_works_input_price` names the Rail Network, Motor Roads and Highways tiers, so it needs rewriting. You asked to keep the `ai_value` blocks pending a reinvestigation, so Rail Works gets one in the same style.

**Costlier levels mean more of them.** A country needs 1.5 times the levels for the same infrastructure, and the event's one-level-per-year cooldown and concurrency cap stay as they are. Check whether it can keep up.

## Alternatives I rejected

- **Two PM branches on one building.** A state could use only one network at a time, and PMs can't test for a railway.
- **A PM group on vanilla's railway.** Railways are private and pick PMs by profit, and a PM with no salable output would never be chosen by an AI owner. This is the same reason Harbour Works is its own building.
- **Level caps tied to railway levels.** They would enforce the link strictly, but plan 1 warns that `has_max_level` is unverified. Transportation shortage and the AI cap should do the job first, and I would add a cap only if testing shows overbuilding.
- **One shared financing group on all three.** It's simpler, but it stacks the +15% and applies one infrastructure cut to very different outputs.

## What has to change

| Area | Change |
| --- | --- |
| `common/buildings/50_boi_buildings.txt` | Add `building_boi_rail_works`. Keep the `building_boi_infrastructure` key for Road Works so the seed and its audits still work. Add the financing group to Harbour Works |
| `common/production_methods/` | Edit the road ladder in `50_boi_infrastructure.txt` and remove `pm_boi_rail_network`. Add `50_boi_rail_works.txt`, following the Harbour Works file. Cut Harbour Works' output, and add financing PMs to both new groups |
| `common/production_method_groups/50_boi_pm_groups.txt` | Add rail method, rail administration, rail financing and harbour financing groups |
| Laws | Update the group's name and descriptions and the law tooltips. Retune the Road Works financing PMs |
| AI event, triggers and values | As described under AI, plus a Rail Works capacity value |
| Localization and art | Rename to Road Works, add Rail Works and all new PMs, and add a provisional icon |
| Telemetry | Log railway levels, Rail Works levels, PM tier counts, works spending and the automobile market in the normal modules, and update `Get-BoiDiagnostics.ps1` |
| Docs | `BALANCE.md`, `README.md`, `docs/OVERVIEW.md`, plans 1, 2 and 4, and the metadata description |

**Seed levels don't change.** All 20 seeded Public Works buildings are on Cart Roads and become Road Works, and Rail Works isn't seeded. Their output does change, so `tools/STARTING_INFRASTRUCTURE_1836.md` needs regenerating. Save compatibility isn't a concern, because the mod hasn't been released.

## Risks

| Risk | Why it matters | What to do |
| --- | --- | --- |
| The shortage penalty guts Rail Works | Most markets are short, so it could deliver half its rated output or less | Test it first. If so, lower the input or raise the output |
| The shortage penalty doesn't touch infrastructure | Then a starved Rail Works gives full infrastructure while buying little, which is close to free. The same goes for Road Works in a horse shortage | Same test. If so, the `possible` gate and AI cap matter more, and a shortage modifier may be needed |
| Higher costs push budgets over | Several countries already run more debt than vanilla in this run. It may partly be from housing | Compare debt in a 10-run ensemble. Output is the dial |
| More short states at game start | Static estimate: 39 to 49, before the AI responds | Check in the first 10-year run, especially Brazil and the USA |
| Statute Labour's reach grows | Many more levels now carry the peasant SoL penalty and throughput bonus | Compare peasant SoL and Landowner strength. Cut per-level values first |
| Rail Works starves local mines | Rail-tier extraction buys from the same local pool, and so do pops | Compare mine output and SoL in rail states with and without it |
| A state loses its railway | Rail Works can't be downsized, so it keeps paying wages for little or nothing | Check how often this happens before adding an exception or a script clean-up |
| Automobile shortages late in the game | Many Road Works could upgrade at once, and there is no measurement after 1856 | The `required_input_goods` check helps, but it needs a long run. Lower the automobile inputs if needed |
| The gates behave differently than documented | `required_input_goods` is only used on electricity in vanilla, and `possible` may also block expanding existing levels | Include both in the first test |
| Horse demand rises at era 3 | Ranch supply is only roughly balanced today, and Britain and the Netherlands are already expensive | Watch horse prices once runs reach era 3. Steam-Rolled Roads' horse input is the dial |

## Suggested order of work

1. **Run a one-year headless test** with a throwaway building or fixture. It should answer: does a shortage cut `state_infrastructure_add`, is the good's complete absence different, does `possible` block a new level and an AI-queued build, and does `required_input_goods` work on automobiles?
2. **Apply the cost changes alone first:** a third off output on today's Public Works and Harbour Works, and the trimmed discounts. Run the 10-game BOI ensemble against the vanilla baseline. This is the cheapest test of "too cheap", and it also gives the first BOI ensemble.
3. **Decide on the floor** from that ensemble, and try 125,000 if infrastructure still doesn't bite and you agree.
4. **Build the split:** buildings, financing groups, law names and telemetry. Run the static suite and a 10-year headless run. Rail barely matters by 1846, so anything large means a bug.
5. **Extend the AI event** and check that it picks Rail Works in places like Prussia, and doesn't in Russia.
6. **Run a 50-year game.** This is the real test of the split, because every run so far stops by 1856, before motor roads or automobiles exist and before steel track can matter much. It also covers plan 1's open long-run check.
