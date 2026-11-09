# Burden of Infrastructure: plan to feature complete

Written 2026-11-08. It starts from your four items and adds the open work from the other plans, the overview's revisit list and the balance logs. Numbers marked *test value* are first guesses, to be tuned in headless runs.

**Feature complete** here means every module the mod sets out to have is built, the AI can run it, and it has passed a long headless game. Polish and the overview's "big ideas" (§6) come after. Some of them could be pulled in; see question 6.

## Status (2026-11-08, branch `feature-complete`)

**Built:** A1, A2, A3, A4, B1, B2, B6, B10, B11, B13 (changelog only), B15 (works buildings and Horse Ranch) and B16 (Municipal Estates reworked rather than removed), plus the horse events. [CHANGELOG.md](../../CHANGELOG.md) lists every change, and the README lists every override and conflict.

Two smoke runs: `20261108-130549_mod` and `20261108-131100_mod`. The second passed with 0 BOI errors, 67 `Duplicated key` lines and no `Failed creating backing building`. The two 20-year games are in [the 8 Nov balance log](../reports/feature_complete_8_Nov_2026/BALANCE_LOG.md).

Changed from the plan while building:

- **A4 construction bonus:** it is `state_construction_mult` (+20%, and +10% more for workers' housing), so it speeds all construction in a modernised state, not housing alone. The engine only registers `building_group_*_construction_efficiency_add` for vanilla groups. The housing-only key logged "defined in script but not in code".
- **B16:** Municipal Estates were kept, at your request. They are now gated on a socialist-type government (council republic, Command Economy or Cooperative Ownership), and they are the best working-class housing: 14 basic and 2 luxury on 1.25 infrastructure, at low cost, with +0.4% migration pull per level.
- **A3:** the conversion runs from a monthly event, `boi_housing.10`, which records the law last enforced in `boi_labour_rights_level`.

**Not done:**
- B5: no housing concept text.
- B7 and B12: no long ensemble beyond the two 20-year games.
- B8: your hand playtest.
- B13: the licence and Workshop page are yours to choose.
- B3: Work Camp's role.

## Part A: your four items

### A1. Prestige penalties on the lowest housing tiers

**What:** each level of the cheapest non-employer housing takes a percentage off the country's prestige. Company housing (the employer PMs) is left out. These are your numbers (2026-11-08):

| Tier | Prestige per staffed level (doubled on 2026-11-08) |
| --- | ---: |
| Slum Districts | −0.5% |
| Workers' Rows | −0.25% |
| Tenement Blocks | −0.125% |

**How:** `country_modifiers = { workforce_scaled = { country_prestige_mult = -0.005 } }` and the like, on each tier's base PM. Vanilla uses `country_modifiers` on Government Administration and the monuments. The change goes in the roster (`tools/Housing-Tiers.ps1`), then gets regenerated with `tools/Build-Housing.ps1`.

**Size, from pass 4's 1850 counts:**

| Power | Slum and Rows levels | Prestige |
| --- | --- | ---: |
| Britain | 7 and 15 | −7.3% |
| Russia | 6 and 27 | −9.8% |
| France | 1 and 24 | −6.5% |
| USA | 2 and 19 | −5.8% |
| Prussia | 1 and 12 | −3.5% |

These are upper bounds: with only staffed levels charged, unstaffed slums cost nothing. That's one to two vanilla personality traits (−5% each). There's no cap, so a country that builds slums heavily pays more.

**Scaling (your answer, 2026-11-08):** staffed levels, through `workforce_scaled`, the shape vanilla uses.

### A2. Migration attraction on the top housing tiers

**What:** the best housing pulls migrants.

- **Employer housing:** Serviced Town (the top company-housing PM).
- **Other housing (your answer):** the top building of each ladder: Elevator Apartments, Elevator Residences and Motor Suburbs. Municipal Estates were also on the list; they are removed (see B16).

**How:** `state_migration_pull_mult` in the PM's `state_modifiers`, scaled by level. Slums already have −0.002 per level.

Company housing sits on every workplace, so a state with 200 levels of serviced industry would stack it fast. *Test values:*
- +0.0005 per level for Serviced Town;
- +0.002 per level for the housing tiers.

### A3. Employer housing laws mapped onto Labour Rights

**What:** the separate Employer Housing law group goes away, and the vanilla Labour Rights laws decide what company housing is allowed:

| Vanilla law | Tech | Housing allowed, as today's BOI law |
| --- | --- | --- |
| No Workers' Rights | – | Unregulated: No Housing or Work Camp |
| Regulatory Bodies | Labor Movement | Protected: No Housing or Work Town |
| Worker Protections | Human Rights | Mandated: No Housing or Serviced Town |

**How:**

1. The company-housing PMs' `unlocking_laws` name the vanilla laws.
2. The conversion effects (`boi_housing_enforce_*_effect`) run when a Labour Rights law is enacted.
3. `lawgroup_boi_employer_housing`, its three laws, the employer columns of the six housing stances, and its AI weights are deleted. The vanilla interest groups' own stances on Labour Rights take over.

**Conversion (your answer): no shadow.** The PMs read the vanilla laws directly. A monthly pulse records each country's Labour Rights law in a variable, and when the law changes it runs the matching conversion effect. This adds no patch debt. A building can sit on a now-illegal tier for up to a month.

**Side effects:**

- Protected housing has no tech gate today. Under the mapping it needs Labor Movement, and Serviced Town needs Human Rights as well as Modern Sewerage. No country starts with Regulatory Bodies, so in 1836 every country is on Unregulated, which is the same as now.
- **Work Town will be rarer, and later.** In the 1836–1866 run of 3 Nov, many AI countries enacted Protected housing within 30 years, because it had no tech and IG backing was easy. Regulatory Bodies needs Labor Movement and the vanilla Labour Rights politics, which the AI usually reaches later. Expect more Work Camps, and their mortality, through mid-century. Check the company-housing telemetry after phase 1.
- The Social tab loses a group, which also eases the overflow risk from moving housing there.
- Tooling to update: the fixtures, Test-Housing.ps1 and the BOILAW telemetry line.

### A4. City Modernisation (decision and journal entry)

Inspired by Haussmann's Paris.

**Decision `boi_city_modernisation`:**

- *Shown* when the country has Residential Standards (slums banned) and owns a state that still holds Slums or Workers' Rows.
- *Possible* when:
  - no modernisation is running;
  - the country is not at war;
  - debt is under a limit;
  - the cooldown has run out.
- **Scope: one strategic region (your answer).** It covers every state the country owns in that region that holds a cleared tier. The player picks it with the Rail Network Survey's continent-then-region picker, which is reused. Like the survey, the goal grows with the number of states, softened for large regions.
- **Cooldown (your answer):** on completion, the decision locks for as long as the construction bonus lasts, through a timed country variable (vanilla's expedition decisions use the same pattern). One modernisation at a time, plus the cooldown, means one every 8–10 years at most. A rail survey can run at the same time.

**Journal entry**, built the same way as the Rail Network Survey:

- **Progress bar:** about 3 to 5 years, faster with more bureaucracy and more Construction sectors in the state.
- **Weekly cost:** compensation and works, about 1–2% of spending (*test value*). There's a cancel button.
- **Clearance happens in stages, state by state.** Script can't remove single levels. `add_building_level` doesn't exist, which a BOI probe confirmed on 2026-11-03. `remove_building` removes a whole building, every level, and frees its infrastructure at once. So:
  - at 25%, 50%, 75% and 100%, about a quarter of the region's states are cleared;
  - the most crowded states go first: most Slum and Workers' Rows levels, then the highest housing price;
  - in each, `remove_building` takes out the Slum Districts and the Workers' Rows.

  The owner doesn't matter: state, aristocrats, capitalists or foreign. Tenement Blocks are left alone. In a one-state region, everything goes at the last stage.
- **An event at each stage**, with real choices:
  - *Compensate the landlords*: costs money, landowners and capitalists are happier.
  - *Expropriate*: cheap, but radicals rise among the displaced.
  - *Boulevards or workers' housing*: more prestige, or a larger construction bonus for working-class tiers.
  - *Finance by loans*: faster now, with debt later.
- **On completion:** every state in the modernisation gets *Modernised City* for 5 years (*test value*). That also sets the cooldown:
  - +25% construction efficiency for residential buildings, via `building_group_bg_boi_residential_construction_efficiency_add`. The vanilla family exists (e.g. `bg_infrastructure`); that it works for a mod group is inferred.
  - Some prestige and migration pull.
  - The modifier lasts 5 years, then expires.
- **After modernisation: no new low-tier housing (your question, 2026-11-08).** While Residential Standards holds, Slums, Workers' Rows and Tenement Blocks can't be built anywhere in the country. Their `possible` trigger already checks the law, and the decision requires it. The gap is a later repeal of the law. To close it, every cleared state gets a permanent state variable, `boi_modernised_city`. The generator then adds `NOT = { has_variable = boi_modernised_city }` to the `possible` of Slums and Workers' Rows, so neither can return to that state even if the law goes. `start_building_construction` respects `possible` (BOI probe, 2026-11-03), and so does the AI. Tenement Blocks stay law-gated only.
- **If Residential Standards is repealed during a modernisation,** the journal entry stops: no further clearance, and no bonus. States already cleared keep their ban.
- **AI:** takes it where cleared levels are a large share of a state's housing and the treasury allows, with the same debt check as the survey's AI pass. Event choices go by `ai_chance`.
- **Telemetry:** a fixture that starts one modernisation in Paris in 1836 under forced Residential Standards, and logs levels removed, cost and the modifier.

## Part B: open work from the other notes

Grouped by module. ✔ = I recommend it for feature complete; ○ = optional.

### Housing

- ✔ **B1. Private investment in housing.**
  - The private investment pool probably never builds housing. Each vanilla ownership building lists `investment_scores` per building group, and BOI's residential group is under none of them. Without a fix, every housing level built after 1836 is government-built and state-owned.
  - What the vanilla owners back now (1.15, `common/buildings/11_private_infrastructure.txt`) is in the table below. Company headquarters have empty `investment_scores`.

  | Group | What it holds | Manor House (aristocrats) | Financial District (capitalists) |
  | --- | --- | ---: | ---: |
  | `bg_agriculture` | farms | 1 (×2 under Agrarianism, Industry Banned, Extraction Economy) | 0.5 |
  | `bg_ranching` | livestock ranches, BOI Horse Ranch | 1 (×2 as above) | 0.5 (×0.5 Traditionalism) |
  | `bg_plantations` | plantations | 1 (×2 as above) | 0.75 (×0.5 Traditionalism) |
  | `bg_arts` | art academies | 0.5 | 0.5 |
  | `bg_whaling`, `bg_fishing` | wharves, whaling | 0.25 | 1 |
  | `bg_logging`, `bg_rubber` | logging camps, rubber | 0.1 | 1 |
  | `bg_manufacturing` | all industry | 0 | 1 (×0.1 Traditionalism, ×0.5 Industry Banned or Extraction Economy, ×0.75 Agrarianism) |
  | `bg_trade` | trade centres | 0 | 1 |
  | `bg_mining`, `bg_oil_extraction` | mines, oil rigs | 0 | 1 (reduced under Traditionalism and others) |
  | `bg_power` | power plants | 0 | 1 (reduced as above) |
  | `bg_infrastructure` | railways, ports | 0 | 1 (reduced as above) |

  - **Proposed fix:** shadow the two ownership buildings (two keyed blocks) and add a score for each housing tier group. Every tier has its own building group, so the two owners can prefer different tiers:
    - **Financial District:** 1 for the working- and middle-class tiers, and 0.5 for luxury tiers.
    - **Manor House:** 0.5 for Town Houses, Carriage Villas and the luxury tiers; 0.25 for working-class tiers.
    - The Temporary Shelter stays government-only, so neither owner scores it. Municipal Estates are removed (B16).
  - **Your answer (2026-11-08):** both sets of scores agreed. No Traditionalism cut for now.
  - Reparenting `bg_boi_residential` under `bg_private_infrastructure` was ruled out. It would bring that group's `stateregion_max_level`, subsidies and lens with it.
- ✔ **B2. Pollution on slums.** Agreed on 2026-11-01 (+50 per staffed level) and never added. Add it in the roster. A1 and B2 together make slums cost prestige, mortality and pollution, which is what A4 then clears.
- ○ **B3. Work Camp's role** is an open decision from plan 4. It earns little and keeps its full penalties.
- ~~**B4. Housing ownership laws**~~ (plan 4 step 7). **Dropped from scope on 2026-11-08**, as you agreed. Vanilla's economic laws already decide ownership, and B1 lets private capital in.
- ✔ **B16. Remove Municipal Estates** (your call, 2026-11-08): a government can build ordinary housing itself, so a separate government-only type adds little.
  - **What it costs:**
    - The Red Vienna flavour, and the only housing that Socialism unlocks.
    - One small AI event (`boi_ai_infrastructure_events.txt`) was written because the engine's AI ignores government-funded buildings. It goes with them.
    - Nothing else depends on the estates. The 3 Nov notes record them being repeatedly wiped out in AI hands anyway. No country holds any in 1836.
  - **Does government housing still get built?** Yes. Pass 4 shows AI governments building ordinary housing (Austria held 15 state-owned levels by 1850). Under laws that shut out private capital, the state is the only builder, as with any other building.
  - **To remove:**
    - the roster entry, then regenerate;
    - the AI event and its trigger;
    - the telemetry values and the BOITM tier line;
    - the Test-Housing checks;
    - the localisation and icon;
    - the columns in `Get-BalanceSummary.py` and `Get-CenturyDetail.py`;
    - the doc mentions.
  - The Temporary Shelter Programme is the other government-only type, the emergency one. It stays.
- ✔ **B5. Presentation:** the housing tooltips and a short explanation in the concept or encyclopedia text (plan 4 step 6). There's no new GUI.

### Infrastructure and rail

- ✔ **B6. Cheaper Road Works and Harbour Works** (revisit list item 3): `construction_cost_medium` → `construction_cost_low`. This needs one check run, because faster works change how fast short states recover.
- ✔ **B7. Rail survey long run:** a 30–50 year game, to see whether AI states reach their caps once railways spread.
- ✔ **B8. Rail survey by hand** (your playtest): the decision, the pickers, the bar text and the cancel button have never been used through the UI.
- ○ **B9. Horse Ranch map look** (`city_type = farm`): this needs mesh mappings in 34 city-type files.

### Public Works Financing (plan 2, phase 2)

- ○ **B10. Events:**
  - Rebecca Riots under Tolls and Dues;
  - road-duty defaulters under Statute Labour;
  - a "Highway Act" event on leaving Statute Labour.

  These give the law group a story, not just numbers. Harbour financing is already done.
- ○ **B11. Dedicated Road Fund** law (1909, `combustion_engine`), which discounts motor roads.

### Release gate

- ✔ **B12. A BOI ensemble to 1886 or later** (several games) against the vanilla baseline. This is plan 1's exit criterion, and it covers B7.
- ✔ **B13. CHANGELOG.md, a licence, Workshop description and thumbnail** (plan 5).
- ○ **B14. Rename the folder and ID** (`Infastructure` typo). This breaks existing paths and the mod ID, so do it once, just before the first public release, or never.

### Big ideas (overview §6), not part of feature complete unless you want them

Horse events such as the Great Epizootic of 1872, horses for artillery and supply trains, terrain traits for infrastructure cost, canals, regional draught animals, the horse's decline, and luxury horse demand.

## Order of work

Each phase ends with a short smoke run (0 BOI errors) and one 15-year game, as in the balance logs.

1. **Housing modifiers and laws:** A1, A2, B2 and B16 (roster and generator), then A3. Pass: Test-Housing, the fixtures and a smoke run.
2. **Private housing investment:** B1. The pass check is that the BOIOWN telemetry shows private levels growing after 1836.
3. **City Modernisation:** A4, with its fixture. A 15-year game with the Paris fixture.
4. **Cheaper works:** B6. One 15-year game against rs_pass4.
5. **Optional items you chose:**
   - Road Financing events (B10);
   - the Dedicated Road Fund (B11);
   - horse events (the Epizootic, glanders, remounts);
   - vanilla models for the Horse Ranch and the three works buildings (B15, which takes in B9).
6. **Release gate:** B12, then your hand playtest (B8), then B13.

After each phase I'll update BALANCE.md, the overview's status board, the plan files and the lessons file.

## Questions

Asked in the session on 2026-11-08; answers recorded below once given.

1. A3: shadow the three Labour Rights laws, or convert by monthly pulse with no shadow?
2. A4: which tiers does City Modernisation clear?
3. A4: does one modernisation cover one state, a strategic region, or every state with slums?
4. A2: what is the "top level" of the other housing?
5. B1: shadow the two ownership buildings' investment scores, or reparent the residential group?
6. Which optional items are in scope?
7. A1, A2, A4: are the test values a fair starting point?

### Answers (2026-11-08)

1. **Monthly pulse, no shadow.** The PMs read the vanilla Labour Rights laws, and a monthly check converts illegal tiers.
2. **Slums and Workers' Rows.** Tenement Blocks survive.
3. **A strategic region**, so large countries aren't held back. The decision cools down for as long as the construction bonus lasts.
4. **Top building of each ladder:** Elevator Apartments, Elevator Residences and Motor Suburbs. Municipal Estates were on the list until they were removed (B16).
5. You asked which groups manor houses and financial districts already back. The table is under B1. The proposed scores await your answer.
6. **In scope:** Road Financing events (B10), the Dedicated Road Fund (B11) and horse events. Horse events come from the big ideas: the Great Epizootic of 1872, glanders and remount requisitioning. Also asked: **map models for every new building** (see B15).
7. **Prestige is a percentage per level:** −0.25% for Slums, −0.125% for Workers' Rows and about −0.065% for Tenement Blocks (A1). Other test values stand until the first runs.
8. **Housing ownership laws are dropped.** The rest of the plan is agreed.
9. **Models:** no housing models for now. Copy vanilla models for the three works buildings and the Horse Ranch; the proposal is in B15.

### Open questions, round 2 (2026-11-08)

1. **B1 investment scores:**
   - Financial District 1 for working- and middle-class tiers, 0.5 for luxury.
   - Manor House 0.5 for Town Houses, Carriage Villas and luxury, 0.25 for working-class.
   - Municipal Estates and the Temporary Shelter stay unscored.

   Keep these, or set your own? Should Traditionalism also cut the Financial District's housing score, as it does for industry?
2. **B15 models:** lighthouse for Harbour Works (or the naval base, or nothing), and the logistics centre for Rail Works. Is that right?
3. **A4 bonus and cost:** +25% housing construction for 5 years in every state of the region, with the cooldown the same 5 years. Weekly cost about 1–2% of spending, like the survey. Keep?
4. **A1 scaling:** charge every built level (`level_scaled`), or only staffed levels (`workforce_scaled`)? Built levels is your wording. Staffed is the fallback if the engine refuses `level_scaled` here.

**Round 2 answers (2026-11-08):**

1. Scores agreed. Remove Municipal Estates (B16).
2. The models stand for now.
3. The City Modernisation numbers stand for now.
4. Staffed levels.

Also: prestige loss doubled (A1), and a ban on low-tier housing after modernisation (A4).

### B15. Map models for the new buildings (added from answer 6)

**Scope (your answer, 2026-11-08):** the Horse Ranch, Road Works, Rail Works and Harbour Works, using copies of vanilla models. Housing gets no models for now.

**How the map picks a model.**
- A building's `city_type` (city, farm, port, mine or wood) puts it in one of a state's map hubs.
- Each hub type has one file per culture group in `gfx/map/city_data/city_types/`. Each file maps a building key to one or more mesh names.
- **If a building declares a `city_type` and one of those files doesn't list it, the game asserts `Failed creating backing building`.** That's why BOI's buildings were left without one (see the note in `50_boi_buildings.txt`).
- So each building must be listed in every file of its hub type:
  - Horse Ranch: 7 farm files;
  - Road Works and Rail Works: 6 city files;
  - Harbour Works: 6 port files.

  That's 19 vanilla files, each copied whole and replaced by path. A generator script (`tools/Build-CityTypes.ps1`) would copy each file from the game folder and add BOI's lines, so a game patch needs only a re-run.

**Proposed mapping.** Mesh names are taken from vanilla 1.15. I can't view the models themselves, so the choices go by name and by what vanilla uses them for. Check them in game.

| BOI building | Hub (`city_type`) | Model copied from | Mesh per culture | `levels_per_mesh` |
| --- | --- | --- | --- | ---: |
| Horse Ranch | farm | Livestock Ranch | European `european_rural_ranch_01_mesh`; African `african_farm_ranch_01_mesh`; Arabic and South Asian `arabic_farm_ranch_01_mesh`; Asian `asian_rural_ranch_01_mesh`; Latin `latin_farm_ranch_01_mesh`; Wild West (DLC) `european_rural_ranch_01_mesh` | 50, as the Livestock Ranch |
| Road Works | city | Construction Sector (a builder's yard) | European `generic_manufactory_03_mesh`; African `african_manufactory_03_mesh`; Arabic and South Asian `arabic_factory_03_mesh`; Asian `asian_manufactory_03_mesh`; Latin `latin_manufactory_03_mesh` | 50 |
| Rail Works | city | Army Logistics Centre (a depot) | `generic_logisticscenter_01_mesh` in every culture, as vanilla does | 50 |
| Harbour Works | port | Lighthouse (a vanilla coastline map object) | European, African, Arabic, Asian and Latin `*_lighthouse_01_mesh`; South Asian uses the Arabic one, as vanilla does for its other buildings | 50 |

Notes:

- **Harbour Works:** vanilla's Port, Shipyard and Fishing Wharf have empty mesh lists in the port files, so there's no port building model to copy. A lighthouse says "harbour authority", but it's built as a coastline map object, not a building, so its scale and footprint are unknown.
  - Fallback 1: the culture's naval-base mesh (`*_port_navalbase_01_mesh`). That looks like a second naval base.
  - Fallback 2: an empty list, like the Port: mapped, but drawn as nothing.
- **Rail Works:** there's no railway station mesh in vanilla. Railways draw as track and trains. The logistics centre is the only generic depot-like model, but the late-game Army Logistics Centre shares it.
- **Road Works:** it shares its look with the Construction Sector in the same city. The alternative is the logistics centre too.
- **Wild West farm** is an American Buildings DLC city type. Its file is in the base game and must still be listed, even without the DLC.
- **Check after building it:**
  - A smoke run with 0 `Failed creating backing building` assertions.
  - A look in game at one European and one non-European state for each building. You can do that while I'm not running games.

## Proposed housing events (2026-11-08, not built)

You asked for more housing events, for both employer housing (Work Camp, Work Town, Serviced Town) and residential housing. Each one triggers from things the mod already tracks: company-housing PMs on workplaces, housing tiers and prices, the two housing law groups and Labour Rights. Each has a real choice. Costs are deaths, radicals, interest-group approval and money, not standard of living directly.

### Employer housing

| Event | Trigger | Choices |
| --- | --- | --- |
| **The Company Store** (truck wages) | Many Work Camp levels, under No Workers' Rights | Ban truck wages (Industrialists angered, Trade Unions pleased), or tolerate it (radicals among labourers in the states with the most camps) |
| **Tied Cottage Evictions** | A rural state with company housing on farms or ranches; Rural Folk hold the Tied Cottages stance | Protect the tenant's tenure (Landowners angered), or the cottage goes with the job (radicals among farmers) |
| **Disaster at the Camp** (fire or collapse at a mining or logging camp) | Work Camps on mines or logging camps | A public inquiry (cost; pushes Regulatory Bodies along through interest-group approval), or blame the men (radicals; the state's mortality rises for a while) |
| **A Model Village** (Saltaire, Bournville, Pullman) | Work Towns or Serviced Towns in a state, and an industrialist government or a strong Industrialists group | Honour the founder (prestige, migration pull for the state), or tax the village like any other (Industrialists angered) |
| **The Pullman Strike** | Many Serviced Town or Work Town levels and strong Trade Unions; wages cut but company rents not | Send the troops (heavy radicals among workers, Armed Forces pleased), or arbitrate (cost, Trade Unions pleased) |

### Residential housing

| Event | Trigger | Choices |
| --- | --- | --- |
| **A Tenement Collapses** (jerry-building) | Workers' Rows or Tenement Blocks in a crowded state, without Residential Standards | Draft building by-laws (the reformers' approval rises toward Residential Standards; the landlord groups angered), or blame the builder (radicals among the poor) |
| **The Rent Strike** (Glasgow 1915) | Housing at its price ceiling in an industrial state | Restrict rents (landlords angered, construction slows), or evict the strikers (radicals among the poor) |
| **A Philanthropist's Offer** (Peabody, Guinness trusts) | Model Dwellings unlocked, and a state with many slums | Accept (a grant toward building, Devout pleased), or decline (nothing) |
| **A Royal Commission on Housing** (1884) | Many slum levels, and the Intelligentsia or Trade Unions strong | Publish the report (some radicals now, the reformers' approval rises), or bury it (the Intelligentsia angered) |
| **The Great Fire** | A state with Slum Districts | The slums burn: their levels are removed, like a clearance, and deaths rise. Rebuild on a plan (a construction bonus and cost), or let them rebuild as they were |
| **A Suburban Building Bubble** | Luxury housing cheap (oversupplied) in several states | Bail out the building societies (cost), or let them fail (radicals among the middle strata, a construction slowdown) |
| **Red Vienna** (Karl-Marx-Hof) | A socialist government with many Municipal Estate levels | Flavour and prestige: a monument to council housing |

Notes:
- **The Great Fire** reuses City Modernisation's clearance (`remove_building`, and the `boi_modernised_city` ban if "rebuild on a plan" is chosen).
- **A Model Village** and **Red Vienna** are the positive ones; the rest are costs.
- **A Philanthropist's Offer** would give money, not build directly, because `start_building_construction` ignores technology and BOI would rather not build for the player.
