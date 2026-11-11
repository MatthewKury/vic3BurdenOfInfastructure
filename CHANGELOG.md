# Changelog



Burden of Infrastructure has not had a public release yet. This log starts with the feature-complete work of 8 November 2026. Earlier history is in git and in [docs/OVERVIEW.md](docs/OVERVIEW.md). All balance numbers are test values.



## Unreleased: steel demand (2026-11-10)

BOI railways give no infrastructure, so fewer were built than in vanilla, and engines and steel fell with them: at 1876 in the 9 November games, steel sold 34% below vanilla and engines 37%, at about vanilla's price. The works now buy iron, steel, engines and boats, and dear horses pull railways. Test values; the games are logged in [the balance log](docs/reports/steel_10_Nov_2026/BALANCE_LOG.md).

- **Rail Works buy their track and one and a half railways' worth of transportation.** Transportation 30 / 38 / 53 / 68 by tier, 1.5 times the output of one same-era vanilla railway level (was 8 / 10 / 12 / 15; 20 / 25 / 35 / 45 in iteration 1). Permanent Way also buys 3 iron; Steel Track 4 steel, Electric Signalling 5 and National Rail Grid 6.
- **Tolls and Dues is now cheap for the treasury, as intended.** Every works building is paid for by the state, wages included, and wages are weighted by pop type. The law's staff swap (60 laborers for 50 shopkeepers and 10 capitalists) raised the wage weight of those posts from 60 to 200. The swap is now 15 shopkeepers and 3 capitalists, wage-neutral, and the goods discount rises from 35% to 50%. This applies to Road, Rail and Harbour Works. Britain and the USA start on this law.
- **Harbour Works no longer buy merchant marine.** Coastal Lighters buy 3 clippers (was 4 merchant marine). Steam Lighters buy 3 steamers and 2 steel, plus their coal; Electrified Quays 3 steamers and 3 steel, plus their electricity. The AI's harbour price signal reads clippers, then steamers once the country has `gantry_cranes`.
- **Roads burn engines from Steam-Rolled Roads on:** 2 a level on Steam-Rolled Roads (which drop from 12 horses to 9), Motor Roads and Modern Highways.
- **Britain, the USA, France and Prussia get their starting road laws in country history** instead of global history. Global history runs after the pops' working-adult ratio is set, so these four started with Statute Labour's −0.02 (check run of 10 November).
- **Dear horses make railways more attractive.** The railway's AI score is multiplied by 1.15 where horses are 25% dear and 1.3 where they are 50% dear, and a railway also auto-expands where horses are 50% dear.

## Unreleased: review fixes and "Ahead of the Traffic" (2026-11-09)



From the 8 November review ([plan 6](docs/plans/06_FEATURE_COMPLETE_PLAN.md), Part C) and item D1.



### Fixes



- **The Great Fire is bounded** (C4).

  - It burns Slum Districts and Workers' Rows. Only where neither stands does it burn the *smallest* wood-heated housing, where it used to burn the largest.

  - It no longer destroys an industry building. Instead the state's industry takes −15% throughput for 3 years ("Scorched Works").

  - "Rebuild on a plan" bans new Slums and Rows in the state only once the country can build Regulated Terraces (`urban_planning`).

- **Rehousing pledges are tracked state by state** (C5).

  - Each pledged state records which country made the pledge, and has its own target.

  - Building in one state no longer makes up for another.

  - A state that changes hands leaves the pledge, and the target shrinks with it. Stale markers from a previous owner are cleared.

- **The AI's Municipal Estates event asks what the building asks** (C3): the Socialism tech and a socialist-type government, through one shared trigger.

- **Electrified Quays need electricity in the state** (C9, `required_input_goods = electricity`).

- **Rebecca Riots and the road-duty defaulters now pick the most restless state** (C12). They had picked the least restless.

- **No more `owner` errors from the plantations' AI scores.** BOI's housing shadows copy vanilla's "British dictates" `ai_value` blocks, which read `owner` while a state may have none for a moment as it changes hands. They now use `owner ?=`, with the same result.

- **The pledge's status line no longer floods error.log** (about 800 lines in 10 months while a pledge ran).

- **Rostov gets 1 Harbour Works** for its vanilla port, which the 1836 seed had missed: 140 Harbour Works (142 levels).



### Balance, from the 40-year test games ([balance log](docs/reports/phase6_9_Nov_2026/BALANCE_LOG.md))



- **Housing harms are no longer mortality** (2026-11-10, untested).

  - Slum Districts: no mortality (was +10% per state plus +2% per staffed level); pollution +75 per staffed level (was +50). Migration −0.2% per level, unchanged.

  - Tenement Blocks: no mortality (was +0.1% per level). Migration unchanged.

  - Work Camp: no flat +15% mortality on its workers; it now lowers the state's migration attraction by 0.2% per staffed level. Work Town: no flat +7.5% mortality, and no other penalty.

  - Emergency Accommodation decree: no +10% mortality; +10% radicals from political movements instead.

- **Statute Labour's human cost and estate bonus are on the law, country-wide** (C8, revised 2026-11-10).

  - The law gives every state +5% farm and ranch throughput. In place of mortality, households keep fewer working adults: −0.02 to the working-adult ratio of every pop type (`state_working_adult_ratio_add`, base 0.25, so about 8% fewer workers and more dependents). Days owed on the roads are days not worked at home. The per-pop-type keys for peasants and laborers were tried first; the engine doesn't know them ("Unknown modifier type", check run of 10 November).

  - The works keep only their per-level costs: 30% fewer goods bought, and −2 (Road), −6.25 (Rail) and −1.5 (Harbour) infrastructure per staffed level.

  - Before, the works carried the mortality per staffed level: Road and Rail +3%, Harbour +1%, with +1% farm and ranch throughput. In the first games, states with 8 or more Road Works lost population while states without grew. A taper (+2% per state plus +1% per level) fixed that in iteration 2. It was replaced by the flat law modifier so the cost no longer depends on which works a state has, and can't stack across the three works buildings.

- **The AI builds the housing it pledges.** Each month an AI country with a rehousing pledge queues one level of Regulated Terraces in the pledge state furthest short, never more in a state than that state's target. In the first games, Britain's AI never built its pledged housing.

- **A broken pledge radicalises only the states that fell short,** in proportion to how short each fell. It used to radicalise 20% of the poor in every pledge state. In both first games this preceded a revolution in Britain.

- **The AI no longer tries to queue Rail Works over the cap.** A level still in the queue now counts against it, including a state's first level while it is still being built. The AI event also asks the engine (`can_construct_building`) and waits for its last queued level to be built before queueing another.

- **Railways get some of their pull back.** BOI railways give no infrastructure, so the AI lost vanilla's reason to build them in a state short of infrastructure. In every BOI test game railways ran 23–40% below vanilla, and heavy industry with them.

  - A railway now expands on its own when transportation is 25% dear; vanilla's line is 50%. World transportation sits at about +50%.

  - The AI's railway priority now scales from 0.9 to 1.4 with the transportation price, 1.15 at normal prices. It was 0.8 to 1.2, 1 at normal prices.

  - Railways still give no infrastructure.



### New



- **"Ahead of the Traffic"** (D1, `events/boi_infrastructure_surplus_events.txt`).

  - It fires for a state with at least 30 spare infrastructure, at least 1.5 times its usage, and a works building.

  - The odds are a 10% yearly roll, with a 15-year cooldown per country and 10 years per state.

  - **The town version** (industry in the state):

    - +10% manufacturing throughput (Industrialists);

    - a market-town charter (Petty Bourgeoisie);

    - +3 legitimacy for each step of press control (+3 to +12).

  - **The country version** (farms, plus a mine or logging camp):

    - +10% mining and logging throughput (Industrialists);

    - +10% farm, ranch and plantation throughput (Landowners);

    - −5% mortality (Rural Folk).

  - Every option lasts 5 years.



### Tooling



- **Regenerating the seed keeps the balance work** (C1). The works plan is now built from `tools/infrastructure_seed_baseline.tsv` (vanilla replacement, regenerated) plus `tools/infrastructure_seed_adjustments.tsv` (hand-made changes, never regenerated), by `tools/Merge-InfrastructurePlan.ps1`. `Test-Seed.ps1` checks the plan against both, and checks the baseline against vanilla.

- **Regeneration works again on 1.15.** `tools/horse_seed_baseline.txt` still named two 1.13 states (Galich, Tartaria) and lacked Kostroma and Oryol.

- **`Test-Housing.ps1` uses a manifest** in place of a file count (C2). It names the keys each housing file must define, and fails on any housing file not in the manifest. It also checks the pledge, the twelve housing events, and that `Build-HousingEvents.py` reproduces the committed files.

- **Telemetry:**

  - a `checks` module (`Test-Headless.ps1 -Checks`) for one-off checks;

  - `sp_counts` and `pledge` lines in the rail-survey module, with the levels the AI pledge builder queued and the countries under a broken pledge;

  - world subsistence, farm and ranching levels in `Compare-Headline.py`, and `--include-failed` to count crashed runs up to their last whole snapshot. `Build-EnsembleDb.py` now keeps the last snapshot of a run that exited on its own but failed on an error line;

  - the road-law code logs the Dedicated Road Fund as 3; it logged as 0 (Statute Labour) before.



## Feature complete (branch `feature-complete`, 2026-11-08)



### Housing



- **Twelve housing events** (`events/boi_housing_events.txt`, generated by `tools/Build-HousingEvents.py`). Each gets a yearly 3% roll per country, with its own cooldown:

  - Employer housing: The Company Store, Tied Cottage Evictions, Disaster at the Camp, A Model Village, and The Company Town Strikes (after Pullman).

  - Residential housing: A Tenement Collapses, The Rent Strike, A Philanthropist's Offer (a grant tied to a rehousing pledge), A Royal Commission on Housing, A Suburban Building Bubble, and Red Vienna (once, for socialist governments with many Municipal Estates).

  - The Great Fire: possible wherever any housing is heated by wood, and it can't recur for 20 years. (Bounded on 2026-11-09; see above.)



- **Low housing costs prestige.** Each staffed level costs a share of the country's prestige:

  - Slum Districts −0.5%;

  - Workers' Rows −0.25%;

  - Tenement Blocks −0.125%.

- **Slums pollute:** +50 pollution per staffed level.

- **The best housing draws migrants.** Migration pull per staffed level:

  - Elevator Apartments +0.3%;

  - Elevator Residences +0.4% (was +0.2%);

  - Motor Suburbs +0.5% (was +0.3%);

  - Municipal Estates +0.4%;

  - Serviced Town company housing +0.05% (per level of its workplace).

- **Municipal Estates are now a good building, for socialist governments only.**

  - Only a council republic, Command Economy or Cooperative Ownership can build them.

  - They now give 14 basic and 2 luxury housing on 1.25 infrastructure, at low construction cost. They gave 10 and 0 on 1.5, at medium cost.

- **Company housing follows the vanilla Labour Rights law.** The Employer Housing law group is gone.

  - No Workers' Rights allows Work Camps.

  - Regulatory Bodies allows Work Towns.

  - Worker Protections allows Serviced Towns.

  - A monthly check converts buildings when the law changes. The vanilla laws are not edited.

- **Private capital builds housing.** Financial districts and manor houses now have investment scores for the private housing tiers. Capitalists prefer working- and middle-class housing, and aristocrats prefer the luxury tiers.

- **New decision: City Modernisation**, after Haussmann.

  - It needs Minimum Residential Standards, and covers one strategic region.

  - Slum Districts and Workers' Rows are pulled down, whoever owns them, a quarter of the states at a time (at 25%, 50%, 75% and 100%).

  - Three events with choices: compensate or expropriate; boulevards or workers' housing; pay as you go or borrow.

  - Cleared states can never build Slums or Workers' Rows again, even if the law is repealed.

  - From the first clearance until five years after the works finish, those states build 20% faster and draw more migrants.

  - The decision then waits five years.

  - The region picker is generated from the Rail Network Survey's (`tools/Build-ModernisationPicker.py`).

- **Housing has moved to its own construction tab.**

  - All housing tiers are now built from the Urban tab, renamed "Urban and Housing". Before, they shared the crowded Development tab.

  - Vanilla's only building in the Urban tab is the Trade Center.

  - Housing still counts as a development building: only `lens` changed, from `development` to `trade`. `category` is still `development`.

  - The rename overrides the vanilla keys `urban_lens_tab` and `urban_lens_tab_tooltip`, in `localization/english/replace/boi_replace_l_english.yml`.



### Displacement (2026-11-08)



- **Rehousing pledge** (new journal entry, after vanilla's promise quests):

  - Offered by two new events, *Families on the Route* (rail survey) and *Where Are They to Go?* (City Modernisation). It only appears once Urban Planning makes good housing buildable.

  - The promise: build good working-class housing in the affected states within 2 years. The target is half a level per level pulled down (cities), or one per 5 urban-centre levels (rail).

  - Kept: loyalists among the poor. Broken: heavy radicals among the poor, a culture acceptance penalty, Trade Unions angered and -10 legitimacy for 5 years.

- **Forcing people out hits a culture.** The largest poor group on the spot below the top acceptance tier loses 20 acceptance for 10 years and radicalizes. This applies to *Force Them Out*, *Clear the Village*, *Clear the Streets*, *Expropriate* and the new *Force them out now* options, and to a broken pledge.

- **The poor pay for it**, in five new events:

  - Fever in the Navvy Camps;

  - Cottagers Turned Off the Land;

  - Rents Soar in What Is Left;

  - Cholera in the Crowded Courts;

  - Barricades in the Faubourgs (likelier where a state of the works is restless).



  They cost deaths, radicals among the poor and migration, never standard of living directly.



### Infrastructure



- **Road Works and Harbour Works are cheaper to build:** construction cost low, not medium.

- **New law: Dedicated Road Fund** (Public Works Financing, needs the combustion engine). Motor taxes pay for the roads: Road Works buy 25% fewer goods, and market access costs 2% more.

- **New Public Works Financing events:**

  - Rebecca Riots (Tolls and Dues, in a restless state);

  - Defaulters on the Road Duty (Statute Labour);

  - A Highway Act (when Statute Labour ends).

  - Defaulters roll 4% a year, with a 5-year cooldown.



### Horses



- **Horse Ranch by-products:** Manure Trade and Mixed Grazing no longer buy grain. Their meat comes from slaughtered horses, so they cut horse output instead, by 3 and 6 per level (about the same value). The default by-product, Knacker's Yard (3 meat), became **Stable Manure** (3 fertilizer), so the starting method no longer implies slaughter.



- **New events:**

  - The Great Epizootic of 1872 in North America;

  - glanders in a horse-breeding state;

  - remount requisitioning in wartime (only with an army of 20+ battalions, half the years it qualifies, 4-year cooldown).



### Map



- **Map models**, copied from vanilla buildings; no new art:

  - Horse Ranch: the culture's Livestock Ranch;

  - Road Works: the Construction Sector;

  - Rail Works: the Army Logistics Centre;

  - Harbour Works: the culture's lighthouse.



  `tools/Build-CityTypes.py` copies the 34 city-type files, 15 of them from DLCs.



### Rail Network Survey (same day, before this work)



- Rail Works give 2.5× infrastructure (was 3×). The starting cap is 1/2/4 levels (was 2/4/6).

- Repeat surveys of the same states take 20% longer for each earlier survey (was 50%).

- The AI pass checks debt instead of gold.



### Fixes



- City Modernisation clears a quarter of the region per stage. In the first test it cleared everything at once (`ordered_scope_state` needed `max = 1`). A state now has to hold actual Slum or Workers' Rows levels to join.

- The Rehousing Pledge now gives a number. The three options that start one (Families on the Route, Where Are They to Go?, A Philanthropist's Offer) say how many levels of good housing it asks for, and in which state. The journal entry shows "Built X / Y levels" on its bar and as its status line, which also appears in the outliner.

- Journal-entry progress bars carry short labels ("Progress: 40%", "Quality: 55", "Built: 2 / 6 levels"). The explanations that were on them moved into the entries' descriptions (Rail Network Survey, City Modernisation, Rehousing Pledge). Not yet checked in-game.

- The building details panel no longer draws the PM row under the employment and cash-reserve bars for the 11 vanilla buildings with a fifth (company housing) PM group. Those buildings get slightly smaller PM icons (`gui/01_boi_building_details_panel.gui`). Not yet checked in-game.

- Rail Network Survey and City Modernisation no longer log errors when a country that marked a state stops existing. Such states are also unmarked, so they can be surveyed again.



### Compatibility



- The README now lists every vanilla override and the kinds of mod each conflicts with. There are two new shadowed keys (the manor house and the financial district) and 34 copied city-type files.

