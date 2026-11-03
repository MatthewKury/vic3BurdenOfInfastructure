# Burden of Infrastructure: Housing Tiers Proposal

Written 2026-11-01. **Implemented 2026-11-03, with changes:** 1836 bite at the recommended setting; Light and Heat added as the one changeable PM; slums and Town Houses cost 200 points, not 100 and 400; no scripted AI replacement, because no effect can remove one level; Municipal Estates get a small AI event; no cap on works. Back to [plan 4](04_HOUSING.md).

Replace the five permanent housing buildings with 15 in three ladders, each step unlocked by an existing vanilla technology, raise housing's infrastructure cost by about 1.8 times, and cut construction costs for most dense housing. Every step needs less infrastructure per unit of housing, and no building can change type, so the only way to recover infrastructure without building more is to demolish old stock and rebuild.

**Decisions needed from you:**

1. How hard infrastructure should bite in 1836. I recommend the middle setting, which takes short states from 22 to 46.
2. Whether old building types stay buildable until a law bans them. I recommend yes, because that is what history did.
3. Whether the AI gets a scripted replacement event. I recommend yes, because nothing else in the engine will make it redevelop.
4. Whether to limit Public Works per state. I recommend testing cheaper housing construction first: on my estimates, replacing at today's cost takes about 37 years to pay back against Public Works, and about 10 at the proposed cost.

**Assumption to confirm:** I took "what we have now" to mean the mod's current buildings, not modern housing.

## What history shows

Housing was almost never upgraded in place: a form was built, then banned for new construction, then lingered for decades until someone paid to clear it. That is the same loop you want in the game.

| Period | Form | What made it possible | What ended it |
| --- | --- | --- | --- |
| From 1790 | [Back-to-backs and cellar dwellings](https://en.wikipedia.org/wiki/Back-to-back_house), English factory towns: 60–75 houses and up to 300 people per acre in early Leeds | Nothing new: speculative builders and rapid town growth | Councils could ban new ones from 1875, and national law did in 1909. Mass demolition began only in the 1920s |
| 1700s on | [Chawls](https://en.wikipedia.org/wiki/Chawl), Bombay: 4–5 storeys, 8–16 one-room dwellings a floor, shared latrines | Migrant workers and scarce land | Declined slowly, and some still stand |
| 1832 on | [Balloon-frame houses](https://en.wikipedia.org/wiki/Balloon_framing), first seen in Chicago | Sawn lumber and cheap machine-made nails, so little skilled labour | Tall timber ran short by the 1920s |
| 1851–71 | [Saltaire](https://en.wikipedia.org/wiki/Saltaire), a model company town: 800 dwellings, 4,389 people | One employer's capital | Remained a one-off, not a general form |
| 1853–70 | [Haussmann's Paris](https://en.wikipedia.org/wiki/Haussmann%27s_renovation_of_Paris): 19,730 buildings demolished, 34,000 built, and lodgings up from about 120,000 to 215,300 | State expropriation, plus sewers expanded fourfold | Work continued until 1927 |
| 1862 on | [Berlin's Mietskasernen](https://en.wikipedia.org/wiki/Hobrecht-Plan): the Hobrecht Plan set streets and a 20 m height limit, and builders filled the courtyards | Minimal rules and speculative builders | City sewers, built from 1873, were finished only in 1893 |
| 1864 on | [Peabody model dwellings](https://en.wikipedia.org/wiki/Peabody_Trust), London: 57 dwellings at first, 3,500 by 1882, with shared baths and laundries | Philanthropic capital | Too small to meet demand: about 8,000 dwellings by 1939 |
| 1875 | [Cross Act](https://en.wikipedia.org/wiki/Artisans_and_Labourers_Dwellings_Improvement_Act_1875), England and Wales: councils could compel sale, demolish and redevelop | Cheap government loans, but compensation was owed | Optional, and only 10 of 87 towns had used it by 1881 |
| 1879–1901 | [Old Law dumbbell tenements](https://en.wikipedia.org/wiki/Old_Law_Tenement), New York: about 84 units and 300 people in a six-storey example; 82,000 buildings by 1900 | A window rule that builders met with airshafts | The 1901 law set new standards but required no rebuilding. Nearly 200,000 apartments were still occupied in 1988 |
| 1857–85 | [Passenger elevators](https://en.wikipedia.org/wiki/Elevator) (1857, electric 1880) and the [steel frame](https://en.wikipedia.org/wiki/Home_Insurance_Building) (Chicago, 1885) | Safety brakes, electric drive, structural steel | Still in use |
| 1887 on | [Streetcar suburbs](https://en.wikipedia.org/wiki/Streetcar_suburb): small-lot corridors within a 5–10 minute walk of the line | Horsecars by 1860, electric streetcars by 1887–88 | Cars, after the game's main period |
| 1898–1919 | [Garden cities](https://en.wikipedia.org/wiki/Garden_city_movement): Letchworth 1904, Welwyn 1919; Howard's plan was 32,000 people on 9,000 acres | Private land company, planning ideology | Few were built |
| 1919–34 | Public housing: Britain's [Addison Act](https://en.wikipedia.org/wiki/Addison_Act_1919) built 213,000 homes; [Red Vienna](https://en.wikipedia.org/wiki/Gemeindebau) built 64,000 flats for 220,000 people, paid for by a housing tax | State funding, after a reformist or socialist turn | Austerity (Britain's subsidy ended in 1922) and politics (Vienna, 1934) |

Three patterns matter for the design:

- **Density came first, quality later.** The early forms packed in the most people and were the worst to live in. In Manchester, mortality in back-to-backs ran 40% above through-houses.
- **Laws stopped new building, not old buildings.** Neither the English nor the New York bans forced rebuilding. Leeds even kept building back-to-backs until the 1930s, and still had 72,000 in 1926.
- **Technology changed what could be built, not what already stood.** Steel, elevators, trams and sewers enabled new forms. Old stock stayed as it was.

## What the mod has now

The no-PM rule already holds for almost every housing building, but the infrastructure cost is too small to force any replacement, and only one building has a tech gate.

| Building (today) | Basic + luxury per level | Infra per level | Infra per housing unit | Tech | Closest history |
| --- | --- | --- | --- | --- | --- |
| Slum Districts | 6 + 0 | 2 | 0.33 | None | Cellars and rookeries |
| Tenement Districts | 7 + 0 | 1.5 | 0.21 | None | Back-to-backs; true tenements came later |
| Apartment Blocks | 10 + 1 | 1 | 0.09 | `steel_frame_buildings` (era 3) | Steel-frame apartments |
| Luxury Apartments | 2.5 + 6 | 1.5 | 0.18 | None | Town houses in 1836 |
| Suburban Estates | 2.5 + 6 | 2.5 | 0.29 | None | Villas, with a commuting PM |
| Temporary Shelter (government) | 4 + 0 | 1.5 | 0.38 | None | Emergency relief |

Where that falls short of your goal:

- **Infrastructure does not bite.** The 1,046 seeded levels use 1,863 infrastructure against about 24,600 world supply, moving world use from 36% to 44%. The kept 10-year run had 4 short states among major powers, against vanilla's 8.9. Plan 4 already concludes that housing's complication is "price, not infrastructure".
- **The ladder has a hole.** Nothing unlocks between 1836 and era 3, and nothing after it. No country built Apartment Blocks in the 10-year run that logged it (2026-10-30).
- **Suburbs break the rule.** `pmg_boi_suburban_transport` swaps horses, rail and motor commuting by PM. That is the one in-place upgrade left among the housing buildings.
- **Replacement is untested.** Plan 4's step 3 (acquire before demolishing) has not been done, and no one has checked that demolition releases infrastructure.

## How replace-not-upgrade would work

Higher infrastructure cost alone will not make anyone replace housing, because Public Works buys the same infrastructure far more cheaply. The design needs a second change: cheaper housing construction, and possibly a limit on Public Works.

**The player's loop:**

1. A state runs short of infrastructure, or new housing demand has nowhere to fit.
2. The player either pays for Public Works or targets old housing in that state.
3. The player must own the levels first. The engine refuses otherwise: "Building cannot be downsized as there are no owned levels".
4. Demolition fires the staff, and 10% of those pops radicalize (`FIRED_POP_RADICALIZATION_FRACTION`).
5. Housing supply should dip and the local price rise until the new building finishes. That gap is the real cost, and it is the point.

**Why it needs more than infrastructure cost.** The table prices 16 infrastructure in the steel-frame era, by replacing 8 Workers' Rows with 5 Apartment Blocks (same housing). These are my estimates: £540 per construction point from `pm_steel_frame_buildings`, a wage of about £140 per 1,000 staff, and housing at base price.

| Way to get 16 infrastructure | Up front | Each week | Payback against Public Works |
| --- | --- | --- | --- |
| Public Works (Rail Network tier, 30 infra per level) | About £118,000 | Costs about £330 | n/a |
| Replace, with Apartments at today's 600 points | About £1.65M | Earns about £470 more profit | About 37 years |
| Replace, with Apartments at 400 points | About £1.1M | Earns about £470 more profit | About 24 years |
| Replace, with Apartments at 200 points | About £550,000 | Earns about £470 more profit | About 10 years |

So I recommend 200-point construction for most dense housing, which makes replacing a real investment decision. Public Works stays the quick fix: cheap now, but paid for every week.

**A stronger option: limit Public Works per state.** That would make replacement the only way out in a crowded state, which is your original idea, and it matches Haussmann: a dense city could not add street capacity without clearing buildings. The cost is that it changes BOI's core module, and the AI could get stuck short. I would test the cheaper construction first, and add a limit only if an ensemble shows replacement still is not happening. `has_max_level` looks like the simple route, and a script-value curve is the alternative.

**How hard infrastructure should bite in 1836.** I tested the seeded 1,046 levels against vanilla's mean state supply and usage at January 1836 (10 runs). Vanilla alone has 9 short states. BOI's own supply differs, and the table covers 1836 only, so an ensemble has to confirm it.

| Setting | Slums / Rows / Town Houses / Villas (infra per level) | Housing's infra | World use | Short states | People in short states |
| --- | --- | --- | --- | --- | --- |
| Today | 2 / 1.5 / 1.5 / 2.5 | 1,863 | 44% | 22 | 8% |
| Gentle | 2.5 / 2 / 2 / 3 | 2,386 | 46% | 32 | 16% |
| **Recommended** | 3.5 / 3 / 2.5 / 4 | 3,322 | 50% | 46 | 21% |
| Aggressive | 4.5 / 4 / 3.5 / 5 | 4,368 | 54% | 69 | 39% |

The aggressive setting puts 19 Chinese states among the short ones, which is why I stopped below it. At the recommended setting, the short states include 10 American, 6 Chinese, 5 in British India, 4 Russian, 3 French and 2 British.

**Rules that keep it working:**

- **One PM per building.** Commuting moves from a PM group into separate suburb buildings. Company housing keeps its PM tiers, because it sits on rural workplaces and follows law, not technology.
- **One leaf group per building.** `infrastructure_usage_per_level` lives on the building group, so each new building needs its own.
- **Infrastructure use follows levels, not staffing.** That is plan 4's rule, and it would mean an empty slum still blocks the state until removed. Fixture buildings added usage within 30 days, but zero-staff persistence is still on the test list. Unstaffed private levels do start to shrink on their own: after 6 months, one level a week.
- **Laws stop new building, never existing stock.** Residential Standards should block new Slums, Workers' Rows and Tenement Blocks while old ones keep running, as in England and New York.

## Proposed buildings

The roster has 15 permanent buildings: 5 existing ones retuned or renamed, plus 10 new. Every number is a test value. "Infra per unit" is infrastructure per level divided by total housing output, and it falls at every useful step. Break-even assumes 1836 wages and 1,000 staff per level, with luxury counted at twice basic, so later eras will sit higher.

**Working-class ladder.** This is where most replacement should happen.

| Building | Unlock | Basic + luxury | Infra | Infra per unit | Cost (points) | Inputs per level | Break-even |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Slum Districts (existing) | None | 6 + 0 | 3.5 | 0.58 | 100 | 0.3 wood, 0.1 tools, 0.2 fabric | £26 |
| Workers' Rows (today's Tenement Districts) | None | 7 + 0 | 3 | 0.43 | 200 | 0.6 wood, 0.3 tools, 0.2 fabric | £24 |
| Regulated Terraces (new) | `urban_planning` | 8 + 0 | 2.5 | 0.31 | 200 | 0.6 wood, 0.3 tools, 0.2 glass | £22 |
| Tenement Blocks (new) | `mechanized_workshops` | 10 + 0 | 2 | 0.20 | 200 | 0.6 wood, 0.3 tools, 0.2 iron | £17 |
| Model Dwellings (new) | `modern_sewerage` | 9 + 0 | 2 | 0.22 | 400 | 0.5 wood, 0.4 tools, 0.3 glass, 0.2 iron | £21 |
| Apartment Blocks (existing) | `steel_frame_buildings` | 10 + 1 | 1.5 | 0.14 | 200 | 0.4 steel, 0.4 glass, 0.5 tools, 0.3 wood | £17 |
| Municipal Estates (new, government) | `socialism` | 10 + 0 | 1.5 | 0.15 | 400 | 0.3 steel, 0.4 glass, 0.5 tools, 0.5 wood | Treasury pays |
| Elevator Apartments (new) | `elevator` | 14 + 2 | 1.5 | 0.09 | 400 | 0.6 steel, 0.5 glass, 0.5 tools, 1 electricity | £13 |

- **Workers' Rows** stands for back-to-backs and chawls. The name avoids tying a global building to one country.
- **Tenement Blocks and Model Dwellings are the one real choice on the ladder.** Blocks are the Mietskaserne and dumbbell: cheap and dense, with about +0.1% state mortality and -0.1% migration per staffed level. Model Dwellings are Peabody: no penalty, at twice the construction cost.
- **Tenement Blocks carry no SoL penalty of their own.** The agreed rule keeps one state-wide slum SoL penalty, and a second building's flat penalty would stack.
- **Municipal Estates** are Red Vienna and the Addison homes. They use the treasury instead of waiting on investors, and they need the AI construction event because the AI ignores government housing otherwise.

**Luxury ladder.**

| Building | Unlock | Basic + luxury | Infra | Infra per unit | Cost (points) | Inputs per level | Break-even |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Town Houses (today's Luxury Apartments) | None | 2.5 + 6 | 2.5 | 0.29 | 400 | 0.8 wood, 0.5 tools, 0.8 glass, 0.8 furniture | £16 |
| Boulevard Apartments (new) | `modern_sewerage` | 3 + 6 | 1.75 | 0.19 | 400 | 0.5 wood, 0.5 tools, 0.8 glass, 1 furniture, 0.2 iron | £16 |
| Elevator Residences (new) | `elevator` | 3 + 8 | 1.25 | 0.11 | 600 | 0.4 steel, 0.5 tools, 0.8 glass, 0.5 luxury furniture, 1 electricity | £14 |

Boulevard Apartments are Haussmann's, and they share a technology with Model Dwellings because sewers enabled both. Paris gives a rough sense of scale: clearing 120,000 lodgings led to about 215,300, or 1.8 times as many, and Town Houses to Boulevard Apartments cuts infrastructure per unit by about a third.

**Suburban ladder.** Each commute is its own building, which removes the last in-place upgrade.

| Building | Unlock | Basic + luxury | Infra | Infra per unit | Cost (points) | Commute input | Break-even |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Carriage Villas (today's Suburban Estates) | None | 2.5 + 6 | 4 | 0.47 | 200 | 0.6 horses | £13 |
| Railway Suburbs (new) | `railways` | 3 + 6 | 3 | 0.33 | 200 | 0.5 transportation | £13 |
| Streetcar Suburbs (new) | `electric_railway` | 6 + 4 | 2.5 | 0.25 | 200 | 0.5 transportation, 0.5 electricity | £15 |
| Motor Suburbs (new) | `combustion_engine` | 3 + 7 | 3 | 0.30 | 200 | 0.2 automobiles | £12 |

- All four also use about 0.6 wood, 0.2–0.3 tools, 0.2–0.3 glass and 0.3–0.4 furniture, and keep the +0.3% migration bonus.
- **Suburbs stay the infrastructure-hungry choice.** They trade infrastructure for migration pull, which keeps them a real alternative to dense housing.
- **Streetcar Suburbs are the one with mass-market output,** matching their history as affordable corridors for working and middle-class families.
- **Motor Suburbs take more infrastructure than Streetcar Suburbs on purpose.** The car is a step back in density and a step up in luxury.

**Temporary Shelter stays as it is,** as the emergency response outside the ladders. I left garden cities and company model towns out: garden cities were few and read as a suburb variant, and Saltaire-type towns are already covered by the Serviced Town company housing tier.

## Technologies

No new technologies are needed. All nine unlocks are existing vanilla keys, and each step sits in an era that roughly fits its history.

Bold marks today's five buildings, retuned or renamed. The rest are new.

| Ladder | 1836, no tech | Era 1 | Era 2 | Era 3 | Era 4 |
| --- | --- | --- | --- | --- | --- |
| Working class | **Slum Districts**, **Workers' Rows** | Regulated Terraces (`urban_planning`) | Tenement Blocks (`mechanized_workshops`), Model Dwellings (`modern_sewerage`) | **Apartment Blocks** (`steel_frame_buildings`), Municipal Estates (`socialism`) | Elevator Apartments (`elevator`) |
| Luxury | **Town Houses** | | Boulevard Apartments (`modern_sewerage`) | | Elevator Residences (`elevator`) |
| Suburban | **Carriage Villas** | | Railway Suburbs (`railways`) | | Streetcar Suburbs (`electric_railway`), Motor Suburbs (`combustion_engine`) |

Read left to right, each ladder reaches a lower infrastructure cost per unit of housing.

- **The strongest Western powers get a choice on day one.** Tier 1 countries (Britain, France and others) start with era 1 and `railways`, so Regulated Terraces and Railway Suburbs are open in 1836. Everything from `mechanized_workshops` onward has to be researched.
- **Four of these techs also raise infrastructure.** `urban_planning`, `modern_sewerage`, `steel_frame_buildings` and `elevator` each add +1 to `state_infrastructure_from_population_add`. Research therefore helps twice, by adding supply and by opening a more efficient building.
- **Electricity users need a different gate.** Vanilla puts `required_input_goods = electricity` on its PMs, but a one-PM building would then have no valid PM in a state without power. I suggest a `possible` check for a power plant in the state instead, for Elevator Apartments, Elevator Residences and Streetcar Suburbs.

## Risks and open questions

The biggest risk is the AI: it will not redevelop by itself, so without script help only players would feel this system.

| Risk | Why it matters | What to do |
| --- | --- | --- |
| The AI never replaces housing | It builds by profit, and only governments care about infrastructure | Extend the hidden AI construction event: in short states, remove old levels and queue the best available type |
| No proven way to remove one level by script | `remove_building` is used by vanilla but removes the whole building. `add_building_level` with `level = -1` appears only in a commented-out vanilla test event | Test it in a headless fixture first |
| AI overbuilds cheap old types | The AI ignores penalties and buys profit, and cheaper construction may speed that up | Count levels by type in an ensemble. If old types dominate, raise their inputs |
| Private owners gain nothing from freeing infrastructure | Only the state benefits, so the state pays to buy out, as under the 1875 Cross Act | Accept it as historical, and verify that buying out private levels works |
| Seeded stock is state-owned | The player can demolish it freely, and it may already be adding to debt in France, the USA and Spain (one run each) | Decide whether to seed privately owned levels |
| AI answers shortages with Public Works | The event would respond to 46 short states by spending treasury money and horses | Watch debt and horse prices in the ensemble |
| The history runs the other way | Back-to-backs were the densest housing per acre, yet here they cost the most infrastructure | Treat infrastructure as roads, drains and carting load, not land, and say so in the tooltips |

Not yet tested: all roster numbers, all payback estimates, whether `possible` also blocks expanding existing levels, and whether infrastructure is released at the moment of demolition.

**Suggested order of work:**

1. Run a headless fixture for removing one level, buying out private levels, and infrastructure release.
2. Apply the new infrastructure and construction costs to the five existing buildings, then run the 10-game BOI ensemble against the vanilla baseline. This is the cheapest test of the whole idea.
3. Add the ladders in era order, starting with the working-class one.
4. Split suburbs into separate buildings and remove `pmg_boi_suburban_transport`.
5. Extend the AI event, then run a longer campaign to see the later eras. All housing results so far stop at 1846.

Building the 10 new types also means 10 icons, 10 leaf building groups, new localization, and changes to `tools/Build-Housing.ps1` and the telemetry. I would keep the existing building keys and change only their display names, so the seed and fixtures still work.
