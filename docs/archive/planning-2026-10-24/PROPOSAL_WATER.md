# Proposal: Water as a local good

Status: **sections 1-9 are the original proposal; section 10 (the Waterworks) is
IMPLEMENTED as of 2026-10-09, with the changes recorded at the top of section 10.**
Drafted and built against Victoria 3 1.13.11 files. Nothing here has been run
in-game. Items marked *(verify)* are inferred from source or from memory and must
be checked before building on them. Sections 3 to 6 describe the earlier plan of
water PM groups on the existing Public Works and Harbour Works; the Waterworks
replaced that approach for Local Water supply.

## 1. Thesis

Water becomes a **local good** produced by the two existing government works,
Public Works (`building_boi_infrastructure`) and Harbour Works
(`building_boi_harbour_works`). No new building is needed.

It carries the mod's theme one step further. Infrastructure is already something
a state must build and feed. Water adds the thing a growing 19th-century city
actually ran out of first, and it ties straight back into the existing economy:

- **Horses** cart water in the early tiers, and horse ranches suffer in dry regions.
- **Pollution** fouls the supply, as it did on the Irwell.
- **Infrastructure** is *spent* by water systems, because mains and pumping stations
  dig up and occupy the same road network the works are trying to expand.

Geography enters through **state traits** (section 5), because production methods
cannot test terrain (lessons §13).

## 2. Period research

What the sources support, and how each point is used. Sources are listed at the end.

| Finding | Source | Used for |
|---|---|---|
| London's New River Company still had wooden pipes and intermittent supply (three days a week) in the early 19th century | London water monopolies | Tier-1 default: unreliable, low output |
| Chelsea Waterworks installed the first slow sand filter in 1829 | Chelsea Waterworks; ICE | Filtration PM and its tech gate |
| Cholera killed 6,536 in London in 1831-32 and 14,137 in 1848-49; Snow traced the 1854 outbreak to the Broad Street pump, fed by a cesspit-contaminated well | Wikipedia; London Museum | Well contamination, outbreak events, why shallow wells carry a mortality cost |
| Metropolis Water Act 1852: intakes moved upstream of Teddington, all water filtered, reservoirs covered, 1855 deadline | ICE; Institute of Water | An "upstream intake and filtered mains" tier |
| Liverpool (completed 1847): steam engine pumped water to a reservoir, then through cast-iron pipes | Liverpool Corporation Waterworks | Steam pumping PM, with coal and a pollution cost |
| Philadelphia replaced wooden pipes with cast iron (10,000+ feet, complete by 1849) | Fairmount Water Works history | Iron as an input to mains |
| Lisbon's Alviela aqueduct (1871-80) used cast-iron pipes rather than stone | Lisbon Water and Windsor Steam | Gravity aqueduct to piped main transition |
| The Irwell was "almost proverbial for the foulness of its waters" by 1860, taking waste from cotton, bleach, dye and chemical works; fish were gone by 1850 | River Irwell; Bowler and Brimblecombe | Industry pollutes the same water it needs |
| A dyeing textile mill could use several million gallons a day; Lowell bleacheries discharged millions of gallons of waste liquor | Lowell Land Trust; USGS WSP 559 | Textile, paper and steel are the heavy water consumers |
| The Ruhr and Emscher were turned into industrial sewers from the mid-19th century | Ruhr (river); Ruhr environmental history | Coal and steel regions as the high-stress case |
| Ganges Canal built 1842-54; Nile Delta barrages begun 1843 | Ganges Canal; Egyptian Public Works | Irrigation-heritage states; why the supply side is also the farming side |
| First routine disinfection of a US public supply: Jersey City, 1908 | Round Mountain WSD history | Late treatment tier (the search did not confirm an earlier chlorination date, so 1908 is the only one used) |

Not researched, and so flagged as flavour rather than history: ship watering and
distillation at ports, and the specific irrigation heritage of Lombardy and Valencia.

## 3. The good

```
water = {
	texture = "gfx/interface/icons/goods_icons/boi_water.dds"   # new icon needed
	cost = 20
	category = staple
	local = yes
	consumption_tax_cost = 200
}
```

- `local = yes` follows services, transportation and electricity. Water cannot
  leave its state, so a state's supply and its demand must meet inside it. That is
  the entire point of the mechanic and it makes a state's geography matter.
- `cost = 20` is deliberately below electricity (30). It is bulky and cheap.
  Revisit once demand volumes are known.
- Declare `goods_input_water_add/_mult` and `goods_output_water_add/_mult` in
  `common/modifier_type_definitions/`. The good loads without them but every PM
  that references them is rejected (lessons §13, verified in-game for horses).
- A `local` good skips world trade, which keeps the market-pass cost near the low
  end of the 1-3% estimate given earlier.

## 4. Supply and demand

### Supply (all of it new files, nothing shadowed)

Two new PM groups on the existing works, one line each in the building's
`production_method_groups` (our own file):

- `building_boi_infrastructure` gets `pmg_boi_water_supply` (every state).
- `building_boi_harbour_works` gets `pmg_boi_harbour_water` (coastal only, because
  the building already has `potential = { is_coastal = yes }`).

Both buildings keep their existing infrastructure, administration and (for Public
Works) financing groups. The administration and financing groups apply to the
**whole building**, so water inherits "who pays" from the Road Financing law. A
turnpike-toll state would charge water rates too. That is good for coherence but
the law's loc wording should mention it.

### Demand, in two layers

**Layer 1 (recommended first). No vanilla production method shadowed.**

1. *Households.* A new `popneed_boi_water` in `common/pop_needs/`, entered into
   the wealth packages in `common/buy_packages/`. The housing prototype already
   generates all 99 packages, so water must be added **inside that generator** and
   not as a second competing copy of `00_buy_packages.txt`. Two files that both
   shadow it would fight, and first-read-wins would silently drop one.
   Demand grows with wealth, as the housing model does, so rich urban states need
   far more than poor rural ones.
2. *Industry, by modifier.* A hidden monthly event computes industrial draw from
   building levels and applies a scaled static modifier, instead of making
   factories consume the good. This avoids the roughly 20-30 PM shadows that
   direct consumption would need.

**Layer 2 (optional later module). Direct industrial consumption.**

Shadow a short list of vanilla PMs so the heavy users consume real water:
textile mills (bleaching, dyeing), steel mills, paper mills, chemical plants, food
industry, and steam power plants. Count the exact PM set with a script before
committing, and record each in `.metadata` as patch-sensitive. This is the point
at which the mechanic stops being approximate.

## 5. Region tags: what to alter or add

There is exactly one region-level tag mechanism: the `traits = { }` line on each
state in `map_data/state_regions/*.txt`. The mod already ships regenerated copies
of those 16 files (for the arable whitelist), and
`tools/Add-HorseBreedingTrait.ps1` is the working pattern for re-applying a trait
assignment after regeneration. There is no other per-region tag worth using.

### A. Read existing vanilla traits, change nothing

Water supply can read `has_state_trait` for traits that already exist:

- **Abundant, large rivers or lakes** (supply bonus): the river traits (Rhine,
  Elbe, Seine, Danube, Volga, Mississippi, Ohio, Ganges, Yangtze and so on), `great_lakes`,
  `lake_victoria`, `lake_maracaibo`, `st_lawrence_river`.
- **Delta and floodplain** (abundant but flood-prone): `bengal_delta`,
  `mekong_delta`, `chao_phraya_delta`, `cauvery_delta`, `mesopotamian_floodplain`.
- **Snowmelt and highland** (good supply, steep and hard to pipe): `alps_mountains`,
  `himalayas_mountains`, `rocky_mountains`, `caucasus_mountains`, `atlas_mountains`.
- **Arid** (supply malus): `sahara_desert`, `arabian_desert`, `gobi_desert`,
  `taklamakan_desert`, `atacama_desert`, `the_great_basin_desert`,
  `australian_desert`. These are the same seven traits vanilla uses in
  `is_vulnerable_to_wildfires`.
- **Irrigation-limited basins**: `murray_darling_basin`, `the_red_basin`.

### B. Add a small set of BOI traits

Vanilla has no trait for "dry summers" or "monsoon-dependent", and those are the
distinction that matters. New file `common/state_traits/51_boi_water.txt`, assigned by a new
`tools/Add-WaterTraits.ps1` cloned from the horse script. All use existing icons
(`dry_climate`, `river`, `swamp`, `waterfall`, `natural_harbors`) so no new art is
required, though a dedicated icon is nicer.

| Trait | Meaning | Static modifier (indicative) | Typical states *(to curate)* |
|---|---|---|---|
| `state_trait_boi_water_abundant` | Reliable rain and rivers | `goods_output_water_mult +0.25` | Britain, Ireland, Atlantic coast, Pacific Northwest |
| `state_trait_boi_summer_dry` | Mediterranean climate, dry summers | `goods_output_water_mult -0.25`, drought impact up | Iberia, southern Italy and Sicily, Greece, Anatolia coast, California, Cape |
| `state_trait_boi_arid_interior` | Little surface water | `goods_output_water_mult -0.5`, `goods_output_horses_mult -0.1`, drought impact up | Central Asia, the Levant interior, northern Mexico, Persian plateau |
| `state_trait_boi_monsoon_dependent` | Supply swings with the rains | drought *and* flood impact up | Peninsular India, Burma, Indochina, southern China |
| `state_trait_boi_irrigation_heritage` | Established canal and barrage system | `goods_output_water_mult +0.15`, farm throughput up | Nile valley, Punjab, the Ganges Doab, Mesopotamia |
| `state_trait_boi_brackish_aquifer` | Coastal wells salinise as they are pumped | `goods_output_water_mult -0.15`, offset by Harbour Works | Low coasts, delta mouths, Gulf states |

Why modifiers carry the supply effect: the horse-breeding trait already uses
`goods_output_horses_mult` on a state trait (verified to load in the mod), so the
same pattern lets `goods_output_water_mult` scale every water producer in the
state at once, with no script and no per-state lookup. The same trait line also
reaches horses, which is the arid-interior link in the table.

Scope: tag roughly 120 to 200 of the 675 states. Untagged states are the baseline,
which keeps the map readable and the patch burden small. The state-by-state list needs
a curation pass, as the horse list got, and the spellings must be checked against
`map_data/state_regions` (the horse script throws on an unknown name).

## 6. Production methods

Magnitudes are placeholders to calibrate against `BALANCE.md`. Ratios, signs and
gates are the design.

### Public Works: `pmg_boi_water_supply`

| # | PM | Gate | Inputs | Water | Infrastructure | Notes |
|---|---|---|---|---|---|---|
| 1 | Wells and Water Carriers (default) | none | horses 1 | low | 0 | Carts and shallow wells, with the intermittent supply of early London. Carries a small mortality cost (Broad Street): `state_mortality_mult` unscaled, rising with density. |
| 2 | Gravity Aqueducts | `urban_planning` | tools 1 | medium | -2 | Masonry conduits, no fuel, no pollution. Cannot raise output beyond the gradient. Lisbon and Croton-style schemes. |
| 3 | Steam Pumping Stations | early steam tech *(verify which)* | coal 2 | high | -3 | Liverpool 1847. Machinists arrive. `state_pollution_generation_add` +5, so water gets cheaper and the air gets worse. |
| 4 | Filtered Cast-Iron Mains | `modern_sewerage` | iron 2, coal 2 | high | -4 | Sand filtration (1829) plus iron pipe and an upstream intake (1852 Act). Cuts mortality and `state_pollution_reduction_health_mult`. |
| 5 | Treatment and Reservoirs | late society tech *(verify)* | tools 2, electricity 2 | very high | -4 | 1908-style disinfection. Largest health benefit; engineers appear. |
| 6 | Electric Pumping Grid | `electrical_generation` | electricity 3 | very high | -3 | Clean, expensive, and dependent on a power plant in the same state (`required_input_goods = electricity`, per lessons §13). |

The negative infrastructure column is the **stress of infrastructure**: every
water system occupies the network the works are trying to build. A state that
upgrades its water without expanding Public Works can lose net infrastructure and
take a market-access penalty, which pushes it to build more or fund it better.

### Harbour Works: `pmg_boi_harbour_water` (coastal only)

| # | PM | Gate | Inputs | Notes |
|---|---|---|---|---|
| 1 | Water Lighters (default) | none | merchant_marine 1 | Ships watered from barges (flavour). Small output. |
| 2 | Brackish Intake Wells | none | none | Cheap but salinises: strengthens the effect of `boi_brackish_aquifer`. |
| 3 | Distilling Condensers | steam shipping tech *(verify)* | coal 2 | Steady output even in arid coastal states, with a pollution cost. Marine distillation is **not researched**: treat as flavour. |

This is the geographic asymmetry. Coastal states in dry regions have a second
source that inland ones lack. Inland arid states depend wholly on Public Works.

### Staffing

Match the vanilla modernisation arc from lessons §13: laborers fall, machinists
rise, engineers appear last and stay small, and the clerk/bureaucrat core stays flat.

## 7. Stress and consequences

All of this uses the pattern in lessons §13 (a hidden event on
`on_monthly_pulse_state` that removes and re-adds one scaled static modifier), so
it needs no vanilla shadowing and costs at most a month of lag.

1. **Shortage tiers.** Compare water supply to demand and apply
   `boi_water_stress_low / _high` (throughput down on manufacturing and
   agriculture, standard of living down, migration pull down).
   *(verify)* `building_has_goods_shortage` exists as a trigger (building scope),
   and `market_goods_shortage_ratio_*` at market scope. Whether either reads a
   **local** good's per-state balance is untested. The fallback is to compute the
   balance from building levels and population in a script value.
2. **Pollution foul-up.** `pollution_amount` reduces usable supply. This is the
   Irwell effect: industry creates the pollution that shrinks the water industry
   needs. Treatment tiers (PMs 4 and 5) damp it.
3. **Infrastructure overload.** The stress multiplier rises when
   `infrastructure_delta < 0`, because mains in a congested network fail and leak.
   The same trigger already gates auto-expansion, so it is known to work.
4. **Horse link.** Arid traits already cut horse output, and water carts in the
   default PM consume horses. A dry state is therefore worse at the *early*
   infrastructure too. This reinforces the mod's own thesis.
5. **Outbreaks (optional event phase).** Shortage plus density plus no filtration
   triggers a cholera outbreak: mortality modifier, a newsfeed item, and a
   decision. Before the filtration tech the outbreak is blamed on foul air; after
   it, the cause is water. Gate on `is_player` per lessons §10.
6. **Fiscal.** The works are government-funded, so water spending uses the same
   treasury and the same Road Financing law. No new currency is introduced.

## 8. Phases

| Phase | Work | Risk |
|---|---|---|
| 0 | Verify the *(verify)* items: shortage triggers on a local good, tech names and eras, a spot-check that `goods_output_water_mult` loads from a trait | Low. Small probe |
| 1 | Good, modifier types, loc, `pmg_boi_water_supply` with PMs 1-3 on Public Works, 6 curated traits on ~40 states | Low |
| 2 | Household demand through the housing generator's buy packages | Medium. Must merge with the housing prototype |
| 3 | Stress modifiers (section 7, items 1-4) | Medium. Needs tuning |
| 4 | Harbour Works water group | Low |
| 5 | Full trait assignment, remaining PMs, validation scripts, README | Low |
| 6 | Outbreak events | Optional |
| 7 | Layer 2 industrial PM shadows | Optional; the real patch debt |

Each phase should land with: banner comments, loc in UTF-8 BOM, an entry in
`tools/Validate-All.ps1`, and a note in `VIC3_MODDING_LESSONS.md`.

## 9. Open questions for the author

1. Is water meant to be **felt by every state** (household demand in Layer 1), or
   only where industry concentrates (modifier only)?
2. Should the infrastructure cost of water be visible as a negative number on the
   PM (as drafted), or hidden in the stress event?
3. How harsh should mortality be, given the war-time and famine effects already in
   the base game?
4. Are Layer 2 shadows acceptable, or should the mod stay at zero new vanilla shadows?

## 10. Waterworks: one building that produces, imports and exports

*Added 2026-10-09 and IMPLEMENTED the same day. Replaces the "two PM groups on the
existing works" idea for the water good. Nothing here is tested in-game.*

**As built, and where it differs from the draft below** (decisions from the
author, 2026-10-09):

- **Private, not government-funded.** `ownership_type = self`. Water has a price,
  so the owner has a profit signal, the AI picks PMs and builds without the
  workarounds the government-funded works need, and private capital can expand
  it. The Bureaucracy-law administration group is kept, so the same three laws
  change who staffs it. The Road Financing group is not (it only prices who pays
  for roads).
- **Standalone group, not `bg_extraction`.** `bg_boi_waterworks` is a root group in
  `category = rural` (the extraction-style tab). It cannot inherit
  `bg_extraction`: that group sets `capped_by_resources = yes`, which would make
  the building unbuildable everywhere, the same trap as the arable whitelist.
  It adds `infrastructure_usage_per_level = 2` (the "stress of infrastructure").
- **Equal prices.** `water` and `bulk_water` both cost 20.
- **`tradeable = no` on Bulk Water**, as a deliberate test (verification item 4).
- **Household demand is optional.** Shipped as `tools/water-prototype/`, because a
  pop need only matters once it sits in a wealth package and that file is one
  shared whole.
- **Traits are assigned.** 6 traits defined; rivers and deserts are tagged
  automatically and about 164 states are curated (`tools/Add-WaterTraits.ps1`).
- **Tier outputs are about 4x the draft's** so supply can meet demand at the
  housing prototype's scale (24 / 36 / 50 / 60 / 70 / 75 Local Water per level).

### Two goods

| Good | `local` | Role |
|---|---|---|
| `water` (Local Water) | yes | What households and industry consume. Cannot leave the state. |
| `bulk_water` | no | Water in transit. Pools across the market and prices like any traded good. |

The only way Local Water crosses a state border is by being converted into Bulk
Water on one side and back on the other. Both conversions are lossy, so a round
trip always loses water and nobody can print money by looping a state's supply.

### One building, three PM groups

`building_boi_waterworks`, **private** (`ownership_type = self`), in its own group
`bg_boi_waterworks` (see the as-built notes above). It follows the same
Bureaucracy-law administration gates as the other works. Buildable in any state, since neither
trade direction is geography-gated. The coastal-only sources live on Harbour Works
(section 6) and still output Local Water.

Exactly one PM per group is active, so the groups combine:

```
pmg_boi_waterworks_source   - HOW the state gets water        (staffed)
pmg_boi_waterworks_export   - whether it SELLS surplus on     (unstaffed)
pmg_boi_waterworks_admin    - the existing Bureaucracy-law group
```

### Source group (choose one)

Local production and import are alternatives in one group, because they are two
answers to the same question.

| PM | Gate | Inputs | Output | Staff | Infra |
|---|---|---|---|---|---|
| **Local** Wells and Carriers (default) | none | horses 1 | water 6 | laborers heavy | 0 |
| **Local** Gravity Aqueducts | `urban_planning` | tools 1 | water 9 | laborers, few machinists | -2 |
| **Local** Steam Pumping | steam tech *(verify)* | coal 2 | water 14 | machinists | -3 |
| **Local** Filtered Mains | `modern_sewerage` | iron 2, coal 2 | water 16 | machinists, engineers | -4 |
| **Local** Treatment and Reservoirs | late society tech *(verify)* | tools 2, electricity 2 | water 18 | engineers | -4 |
| **Import** Water Wagons | none | bulk_water 6, horses 3 | water 4.5 | laborers | 0 |
| **Import** Aqueduct Intake | `urban_planning` | bulk_water 9, tools 1 | water 7 | few laborers | -2 |
| **Import** Pressure Main | `modern_sewerage` | bulk_water 14, iron 2 | water 11 | machinists | -4 |

- Import PMs are about 25% lossy before carriage, so Local production is cheaper
  where the state has water. That matches the intent: importing is a remedy for
  scarcity, not a free alternative.
- The carriage inputs are the burden. Wagons use horses, which ties back to the
  mod's horse economy. Pressure mains use iron.
- Import staffing is lower than local production, because no pumps, filters or
  wells are being run. Pipes do not need many hands.
- Numbers are placeholders. Keep the ratio: output of an Import PM below its bulk input.

### Export group (choose one)

| PM | Gate | Input | Output | Staff |
|---|---|---|---|---|
| None (default) | none | none | none | none |
| Surplus Sales | none | water 4 | bulk_water 3 | **none** |
| Bulk Sales | `urban_planning` | water 8 | bulk_water 6 | **none** |
| Aqueduct Contract | `modern_sewerage` | water 14 | bulk_water 10.5 | **none** |

- **No `building_employment_*` keys in any export PM.** Employment comes from the
  source and administration groups only, so choosing an export level changes
  nothing about hiring.
- All inputs and outputs sit in `workforce_scaled`, so export rises and falls with
  how well the building is staffed, exactly as the rest of the building does.
- Each step converts at 75% (25% lost to leakage and evaporation). Tune the loss
  against the Import PMs' loss so a round trip is clearly a net loss.

### The "fraction of Local Water" question

The engine cannot make an export PM scale to *a fraction of whatever the source PM
produces*. A PM cannot read another PM, a stock, or a price. What works is:

1. **Fixed rates (drafted above).** The export input is an absolute amount per
   building level. It is a fraction of Local output only for one source tier:
   water 4 against Wagons' 6 is 67%, against Treatment's 18 it is 22%. So an
   "export tier" is a fraction of the *low* tier, and it shrinks as the state
   modernises. I'd accept this and name the tiers by size, not by percentage.
2. **True percentage cut (alternative).** An export PM with
   `goods_output_water_mult = -0.25` removes a real 25% of the building's own
   water. But it can only pair with a **fixed** Bulk Water output, so the two
   sides lose their tie: a high source tier would lose more water than it gains in
   Bulk Water. I'd avoid it.
3. **Market-driven.** Export draws Local Water from the state's whole pool at the
   state price, not only from this building's output. So if households are short,
   the price spikes, the export becomes unprofitable, and a profit-seeking owner
   drops it. That is a feature: scarcity shows up honestly.

### Interaction rules

- **Import plus export on one building** is possible and pointless (a lossy
  round trip). Nothing in the engine can forbid the combination across groups. It
  just loses water, so leave it.
- **Selling to yourself.** A state that both produces and exports sends water to
  the market; a neighbour in the same market with an Import PM buys it. The market
  decides *which* neighbour, not the script, so there is no named donor. Directional
  river rights remain the job of the scripted River Draw.
- **The AI.** Source and export use `ai_selection = most_profitable`: both sell a
  real good, so the profit signal works on a private building. Administration uses
  `most_productive`. The building's `ai_value` adds +3000 while a state of over
  10,000 people has no Waterworks, like vanilla's power plant.

### Why a new building here, not PM groups on Public Works

- Public Works already carries a technology ladder, an administration group and a
  financing group. A fourth group would make its PM panel crowded.
- A separate building has its own level. A state can run a large Waterworks and a
  small Public Works, instead of the two being tied together by one level.
- It can be built and expanded on its own, with its own `should_auto_expand`.
- Cost: one new icon (reusing a vanilla icon in the same lens makes it invisible,
  per lessons §13) and one more entry for the AI to weigh.

### Verification probe, before building any of this

1. ~~Does a government-funded building sell its output?~~ **Moot:** the building is
   now private, so the owner sells normally. Verify that the owner earns the
   revenue and pays wages and inputs.
2. Does a PM that consumes a **local** good it did not produce (export) buy from the
   state pool as expected? Electricity consumers suggest yes.
3. How wildly does the price of a **thinly traded** good swing? Bulk Water might have
   three producers in a market. Vanilla goods with few producers are the reference.
4. Does `tradeable = no` (which only gold uses) keep a non-local good inside its
   market while blocking world-market trade? If so, Bulk Water could use it for
   the isolation you asked about. Untested.

## Sources

- [London's water supply monopolies in the early 19th century](https://www.thehistoryoflondon.co.uk/londons-water-supply-monopolies-in-the-early-19th-century/)
- [Liverpool Corporation Waterworks](https://en.wikipedia.org/wiki/Liverpool_Corporation_Waterworks)
- [Fairmount Water Works (ASME)](https://www.asme.org/wwwasmeorg/media/ResourceFiles/AboutASME/Who%20We%20Are/Engineering%20History/Landmarks/21-Fairmount-Water-Works.pdf)
- [Lisbon Water and Windsor Steam](https://www.bhsportugal.org/uploads/fotos_artigos/files/LisbonWaterandWindsorSteam(1).pdf)
- [1854 Broad Street cholera outbreak](https://en.wikipedia.org/wiki/1854_Broad_Street_cholera_outbreak)
- [John Snow: Cholera and the Broad Street pump (London Museum)](https://www.londonmuseum.org.uk/collections/london-stories/john-snow-cholera-broad-street-pump/)
- [Chelsea Waterworks Company](https://en.wikipedia.org/wiki/Chelsea_Waterworks_Company)
- [London's water supply and the introduction of sand filtration (ICE)](https://ice.org.uk/what-is-civil-engineering/infrastructure-projects/london-s-water-supply-and-the-introduction-of-sand-filtration)
- [The history of drinking water (Round Mountain WSD)](https://www.roundmountainwsdco.gov/the-history-of-drinking-water)
- [River Irwell](https://en.wikipedia.org/wiki/River_Irwell)
- [Bowler and Brimblecombe, Environment and History](https://environmentandsociety.org/sites/default/files/key_docs/bowler-brimblecombe-6-1.pdf)
- [River as Sink and Sewer (Lowell Land Trust)](https://lowelllandtrust.org/greenwayclassroom/history/sinksewer.htm)
- [USGS Water Supply Paper 559](https://pubs.usgs.gov/wsp/0559/report.pdf)
- [Ruhr (river)](https://en.wikipedia.org/wiki/Ruhr_(river))
- [A Nature Fit for Industry: Environmental History of the Ruhr Basin](https://www.journals.uchicago.edu/doi/10.2307/3984744)
- [Ganges Canal](https://en.wikipedia.org/wiki/Ganges_Canal)
- [Egyptian Public Works](https://en.wikipedia.org/wiki/Egyptian_Public_Works)
