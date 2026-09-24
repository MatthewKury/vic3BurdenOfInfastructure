# Burden of Infrastructure — Costing & Balance

All figures derived from **vanilla Victoria 3 1.13**. Values in £ are
`quantity × base price`, the same convention as vanilla's inline `# 300`
comments in production method files.

---

## 1. Vanilla baselines

### Goods prices

| Good | Cost | | Good | Cost |
|---|---|---|---|---|
| grain, fabric, wood, fish | 20 | | oil, tools | 40 |
| meat, coal, fertilizer, **transportation**, electricity | 30 | | **merchant_marine** | 50 |
| engines, clippers | 60 | | steamers | 70 |
| automobiles | 100 | | | |

### Construction costs

`very_low 100 · low 200 · medium 400 · high 600 · very_high 800`

### What we are removing — railways

| PM | Inputs | £ in | Output | £ out | **Net** | Infra |
|---|---|---|---|---|---|---|
| early_trains | engines 5, coal 2 | 360 | transp 20 | 600 | **+240** | 20 |
| steam_trains | engines 5, coal 5 | 450 | transp 25 | 750 | **+300** | 25 |
| electric_trains | engines 5, elec 8 | 540 | transp 35 | 1050 | **+510** | 30 |
| diesel_trains | engines 5, oil 6 | 540 | transp 40 | 1200 | **+660** | 40 |

Employment ~1000/level. Construction `very_high` (800).

**The key insight for this mod:** in vanilla, infrastructure is *free*. A railway
earns £240–660 per level in goods margin **and** hands you 20–40 infrastructure
as a by-product. Our job is to make that infrastructure something you buy.

### Ports

| PM | Inputs | £ in | Output | £ out | Net | Infra |
|---|---|---|---|---|---|---|
| basic_port | clippers 6 | 360 | MM 9 | 450 | +90 | 3 |
| industrial_port | steamers 5, coal 5 | 500 | MM 20 | 1000 | +500 | 4 |
| modern_port | steamers 5, oil 10 | 750 | MM 30 | 1500 | +750 | 5 |

Ports were never a serious infrastructure source (3–5). Harbour Works can
comfortably exceed that without distorting anything.

### Livestock Ranch — the Horse Ranch template

| PM | Inputs | £ in | Output | £ out | Net |
|---|---|---|---|---|---|
| open_air_stockyards | — | 0 | meat 10 | 300 | +300 |
| butchering_tools | tools 2 | 60 | meat 15 | 450 | +390 |
| slaughterhouses | tools 5 | 200 | meat 25 | 750 | +550 |

Employment 5000/level (4000 laborers, 1000 farmers). Construction `low` (200).

### Infrastructure demand (`infrastructure_usage_per_level`)

| Group | Usage | | Group | Usage |
|---|---|---|---|---|
| heavy_industry | 2.5 | | agriculture, ranching, plantations | 1 |
| mining, oil, power, urban_facilities, construction, ship_construction, military_industry | 2 | | logging, rubber, whaling, fishing, government | 1 |
| light_industry | 1.5 | | arts, trade | 0.5 |
| military | 0.2 | | owner_buildings, logistics | 0.1 |

### The population floor (our safety net — left untouched)

`state_infrastructure_from_population_add` comes from **technology**, not by
default:

| Tech | Era | Value |
|---|---|---|
| urbanization | 1 | +2 |
| urban_planning | 1 | +1 |
| modern_sewerage | 2 | +1 |
| steel_frame_buildings | 3 | +1 |
| elevator | 4 | +1 |

Multiplied by population ÷ `INDIVIDUALS_PER_POP_INFRASTRUCTURE` (100,000). A
2-million-pop state in 1836 with the two era-1 techs gets **20 × 3 = 60
infrastructure free**. This is a substantial floor and is why stripping railways
does not instantly collapse the world.

State traits (rivers, natural harbours) add a further flat 15–20 in many states.

---

## 2. Proposed costing

### The `horses` good

**cost = 30.** Sits with meat, coal, and transportation. Above grain (20)
because a horse is worth more than fodder; below tools (40) because it is a
rural product, not a manufactured one. `category` is cosmetic (UI grouping only)
— proposing `staple`.

### Horse Ranch — `construction_cost_low` (200), employment 5000/level

Deliberately mirrors the Livestock Ranch so it competes on even terms for
arable land.

| PM | Era | Inputs | £ in | Output | £ out | Net |
|---|---|---|---|---|---|---|
| pm_open_pasture | start | — | 0 | horses 12 | 360 | +360 |
| pm_selective_breeding | 2 | grain 5 | 100 | horses 20 | 600 | +500 |
| pm_stud_farms | 3 | grain 8, tools 2 | 240 | horses 28 | 840 | +600 |

Tracks livestock's +300 → +390 → +550 progression closely. **No unlocking
technology on the base PM** — it must work in 1836.

### How these buildings work economically — pure cost centres

**The Infrastructure and Harbour Works buildings run at a permanent net loss by
design.** They are structurally identical to Government Administration, not to a
railway.

Vanilla Government Administration (`pm_horizontal_drawer_cabinets`):

```
country_modifiers  = { workforce_scaled = { country_bureaucracy_add = 50 } }
state_modifiers    = { workforce_scaled = { state_tax_capacity_add = 10 } }
building_modifiers = { workforce_scaled = { goods_input_paper_add = 10 }
                       level_scaled     = { building_employment_clerks_add = 500 } }
```

Note what is **absent**: any `goods_output_*`. It sells nothing. The state pays
the wages and buys the paper, and receives bureaucracy capacity in return.

Our buildings take exactly that shape — `state_modifiers` emitting
`state_infrastructure_add` in place of `country_bureaucracy_add`, goods inputs,
employment, and no output.

So there are **two costs and no revenue**:

| | Paid by | Counted in tables below? |
|---|---|---|
| Goods inputs (horses, transportation…) | state treasury | **yes** |
| Employee wages | state treasury | **no — additional** |

The £ figures in the tables that follow are **goods only**. Wages sit on top and
may well be the larger number for a big country: ~1000 employees per state,
across every state, is a substantial standing expense. That is deliberate — it
is the same shape of burden that Government Administration already imposes, and
it is the mechanism by which infrastructure stops being free.

One contrast worth noting: Government Administration's *base* PMs
(`pm_professional_bureaucrats`) consume **no goods at all** — pure wages, with
paper arriving only at later PMs. Our design front-loads horses from the first
PM instead, because paying for infrastructure in goods is the mod's whole point.

### Infrastructure Building — `construction_cost_medium` (400), employment 500/level

Government-funded, so employment is a permanent budget line. **500 per level**,
matching Government Administration's own scale (500 clerks/level).

The workforce composition shifts as the building modernises — unskilled roadwork
gives way to a technical operation. This follows vanilla's own arc exactly:
ports move laborers 700 → 500 → 400 while introducing machinists (200 → 250) and
engineers (50), holding clerks and bureaucrats flat.

The 500 splits into **400 technical** (set by the method PM group) and
**100 administrative** (set by a second, law-gated group — see below).

**Group 1 — `pmg_boi_infrastructure_method`, 400 technical:**

| PM | Laborers | Machinists | Engineers |
|---|---|---|---|
| pm_cart_roads | **400** | — | — |
| pm_macadam_roads | 350 | 50 | — |
| pm_rail_network | 275 | 100 | 25 |
| pm_motor_roads | 200 | 150 | 50 |
| pm_modern_highways | **125** | **175** | **100** |

Laborers fall 400 → 125 while machinists rise 0 → 175 and engineers 0 → 100.
Total technical staffing stays flat at 400 throughout.

**Group 2 — `pmg_boi_road_administration`, 100 admin, gated on Bureaucracy law:**

| PM | Law gate | Aristocrats | Bureaucrats | Clerks |
|---|---|---|---|---|
| pm_manorial_roadwardens | `unlocking_laws = { law_hereditary_bureaucrats law_crownland_diets }` | **50** | 25 | 25 |
| pm_appointed_surveyors | `disallowing_laws = { law_hereditary_bureaucrats law_crownland_diets law_elected_bureaucrats }`, `is_default = yes` | — | 50 | 50 |
| pm_elected_road_boards | `unlocking_laws = { law_elected_bureaucrats }` | — | 25 | **75** |

The arc is aristocratic → bureaucratic → clerical:

- **Hereditary / Crownland Diets** — the local landowner *is* the road warden.
  Corvée labour administered by the squire; few professionals involved.
- **Appointed** — county surveyors and a professional civil service.
- **Elected** — road boards and turnpike trusts, staffed by literate townsmen.
  Commercial administration rather than state administration.

`pm_appointed_surveyors` uses `disallowing_laws` rather than an `unlocking_laws`
gate specifically so it acts as the guaranteed fallback — exactly how vanilla's
`pm_professional_bureaucrats` works. One PM in a group must always be valid.

Two consequences worth knowing:

- **Modernising raises your qualified-labour demand.** Machinists and engineers
  need literacy, so a backward country can adopt the late PMs on paper and then
  fail to staff them.
- **Employment is `level_scaled` but goods and infrastructure output are
  `workforce_scaled`.** An understaffed building produces proportionally less
  infrastructure *and* consumes proportionally fewer goods — it self-balances
  rather than bankrupting you.

| PM | Era | Inputs | £ in | Infra | £/infra |
|---|---|---|---|---|---|
| pm_cart_roads | start | horses 10 | 300 | 15 | 20 |
| pm_macadam_roads | 2 | horses 12, tools 3 | 480 | 22 | 22 |
| pm_rail_network | 3 | horses 8, transportation 10 | 540 | 30 | 18 |
| pm_motor_roads | 4 | transportation 12, oil 5 | 560 | 38 | 15 |
| pm_modern_highways | 5 | transportation 15, automobiles 3 | 750 | 48 | 16 |

Zero salable output — this building only produces a state modifier.

**The swing:** in 1836 a railway level *earned* £240 and gave 20 infrastructure.
An Infrastructure level *costs* £300 and gives 15. That is a ~£540 per-level
turnaround, plus wages. Efficiency improves with era (£20 → £15 per infra), so
modernisation is rewarded.

### Harbour Works — coastal only, `construction_cost_medium` (400), employment 500/level

Dock labour is heavier on clerks than roadwork — manifests, customs, and
harbour dues are paperwork a road never generates — so clerks sit at 75 rather
than 50, funded out of the same 500.

Split **375 technical / 125 administrative**.

**Group 1 — `pmg_boi_harbour_method`, 375 technical:**

| PM | Laborers | Machinists | Engineers |
|---|---|---|---|
| pm_coastal_lighters | **375** | — | — |
| pm_steam_lighters | 275 | 100 | — |
| pm_container_wharves | **175** | **150** | **50** |

Lightermen and stevedores give way to crane and winch operators — the same
transition vanilla's own port ladder makes, compressed into three tiers.

**Group 2 — `pmg_boi_harbour_administration`, 125 admin, gated on Bureaucracy law:**

| PM | Law gate | Aristocrats | Bureaucrats | Clerks |
|---|---|---|---|---|
| pm_manorial_harbour_dues | hereditary / crownland diets | **50** | 25 | 50 |
| pm_appointed_harbourmasters | default (disallowing the other two) | — | 50 | 75 |
| pm_elected_harbour_trusts | elected | — | 25 | **100** |

Docks skew clerical at every tier — manifests, customs entries and harbour dues
are paperwork a road never generates — so clerks stay higher than the
Infrastructure building throughout.

| PM | Era | Inputs | £ in | Infra | £/infra |
|---|---|---|---|---|---|
| pm_coastal_lighters | start | merchant_marine 4 | 200 | 10 | 20 |
| pm_steam_lighters | 3 | merchant_marine 5, coal 3 | 340 | 18 | 19 |
| pm_container_wharves | 5 | merchant_marine 6, electricity 4 | 420 | 25 | 17 |

Priced at the **same £/infra as the main building on purpose**. Coastal states
do not get *cheaper* infrastructure, they get *more total capacity* — and they
pay for it in merchant marine, which has its own opportunity cost in prestige
and trade. That keeps the coastal advantage real without making inland
development feel punitive.

### Haulage PMs — horses on the base tier, tapering into rail

**Corrected during implementation.** The original plan here was wrong in two
ways, both worth recording:

- There are **11** transportation-consuming PMs, not the 16 first quoted.
- **`pm_log_carts` is not a horse cart.** Despite the name it is the *most
  advanced* logging transport tier, gated on `electric_railway`. It is now left
  untouched.

The real haulage ladder on mines, plantations, vineyards, logging camps and oil
rigs is:

```
pm_road_carts  (no tech, EMPTY in vanilla)  ->  pm_rail_transport_*  (railways)  ->  pm_log_carts etc.  (electric_railway)
```

`pm_road_carts` is the genuine horse-drawn tier — and it is a **single shared
key used by 18 PM groups**, so one override reaches every extraction building in
the game.

| PM | Current transp | + horses | Added £ |
|---|---|---|---|
| **pm_road_carts** (18 groups) | — | **3** | 90 |
| pm_rail_transport_mine | 5 | 1 | 30 |
| pm_steam_rail_transport | 5 | 1 | 30 |
| pm_rail_transport_building_logging_camp | 5 | 1 | 30 |
| pm_rail_transport_building_oil_rig | 5 | 1 | 30 |
| pm_tanker_cars | 10 | 1 | 30 |

Horses on the rail tiers are last-mile cartage to and from the railhead. The
electric and refrigerated tiers get nothing. The refrigeration ladders
(`pm_unrefrigerated` → `pm_refrigerated_storage_*` → `pm_refrigerated_rail_cars_*`)
and `pm_flash_freezing_*` are cold-chain rather than haulage and are untouched.

This is the mod's main pre-rail pressure: haulage bleeds horses until you build
a railway to escape it.

### Subsistence horse trickle

`pm_road_carts` demands horses from *every* extraction building in 1836, against
a world horse supply of zero. Two subsistence pasture PMs therefore gain a
permanent baseline output:

| PM | + horses | Note |
|---|---|---|
| pm_home_workshops_no_building_subsistence_pasture | 0.25 | law_collectivized_agriculture |
| pm_home_workshops_building_subsistence_pasture | 0.25 | everything else |

These two are the halves of one PM group split on a law, so exactly one is
always active — covering the trickle under every set of laws. The `pm_serfdom_*`
variants sit in a separate additive group and are untouched.

This is a small net buff to subsistence output (+£7.5 against the block's ~£20).
Deliberate: the alternative was cutting an existing output, which is far more
invasive. If the floor proves too thin, extending to
`pm_*_building_subsistence_farm` is the first thing to try.

### Cavalry upkeep

Vanilla already feeds cavalry grain (fodder). Horses represent remounts, added
**on top of** existing inputs.

| Unit | Current | + horses | Upkeep £ before → after |
|---|---|---|---|
| hussars | grain 1 | **1** | 20 → 50 |
| dragoons | grain 1, small_arms 2 | **1** | 20 + arms → +30 |
| cuirassiers | grain 1, small_arms 2 | **1** | +30 |
| lancers | grain 2, small_arms 2, iron 2 | **2** | +60 |

Mirrors vanilla's own grain pattern (1/1/1/2). Meaningful but not crippling —
cavalry is a minority of most armies.

---

### Game-start seeding

Seeded through **history** (`common/history/buildings/zz_boi_buildings.txt`, a
generated file), not a scripted effect. Buildings created during world
initialization start **staffed**; anything created by script starts with zero
employees and hires over several weeks, which left every game opening with a
self-curing horse shortage.

| Building | Levels | Count | Gate |
|---|---|---|---|
| Public Works | 1–6 | 20 | replaces starting Port and Railway infrastructure |
| Harbour Works | 1–2 | 139 | replaces starting Port infrastructure where a port hub exists |
| Horse Ranch | **1–8** | 225 | curated; 857 total levels — see below |

**Infrastructure follows the actual state owner.** The generated plan covers
each starting owner separately, including split state regions. It seeds 40
Public Works levels and 141 Harbour Works levels across 155 owner-state records.
The audit is in [`tools/STARTING_INFRASTRUCTURE_1836.md`](tools/STARTING_INFRASTRUCTURE_1836.md).

**Horse Ranches are curated, and this cost a crash to learn.** Ranches are rural
and consume arable land, but a state's *real* arable land depends on
incorporation status and province ownership — not on the `arable_land` its state
region declares. `STATE_BALUCHISTAN` declares 63; the Omani state holding part of
it has **1**. Seeding on the declared figure over-allocated 10 states and logged
`State X is using an excess of N arable land` immediately before a hard crash in
world init.

The original 236 ranch states were restricted to states that are **core** (owner's primary culture
is a homeland culture of the state — a proxy for incorporated), **sole owner** of
their region, **low industry** (vanilla seeds ≤1 industrial building), and
declare **arable_land ≥ 25**. That excludes all 10 known failures and lands on
236 agrarian core states — Aquitaine, Abruzzo, Alabama, Banat and the like.
Fourteen additional core, sole-owner, incorporated states with adequate declared
arable headroom now receive ranches, including Limousin, Yorkshire, Tohoku and
Fez. Fifteen of the original 236 states are explicitly unincorporated despite
passing the core-culture proxy; their previously safe three levels are an upper
bound. Baseline levels of 4/6/8 by declared arable land are reduced according
to regional horse-breeding suitability; 25 candidate states lose their ranches.

The trade-off is fewer seeded ranch states than the original 636-state plan.
The subsistence pasture trickle is small relative to the opening horse demand;
players and the AI still need to expand ranches. Public Works and Harbour Works are not rural,
cost no arable land, and are seeded everywhere they apply.

**Colonised states are deliberately not seeded.** History only covers states
owned in 1836, so unclaimed land gets nothing — building your own infrastructure
is part of the cost of colonising. Conquest needs no handling at all: buildings
transfer with the state.

### How much is actually being removed in 1836

Less than it sounds, which is why the population floor is enough to carry the
opening years:

- Only **6** countries start with the `railways` technology.
- Only **11** railway buildings are seeded worldwide, all in West Europe.
- **241** port entries exist globally, but ports only ever gave 3–5 each.

The real bite arrives in the 1850s–60s as railways spread and no longer hand out
infrastructure — by which point Public Works can be built.

## 3. Risks and tuning dials

**Early horse price spike is the main risk.** Global demand at game start =
infrastructure buildings + transport PMs + cavalry, against a horse supply that
only exists where the seeding script places ranches. If horses spike, every
state's infrastructure gets expensive simultaneously. Mitigations, in order of
preference:

1. Seed generously — more horse ranch levels than look necessary.
2. Drop `pm_cart_roads` to horses 8 (£240).
3. Halve the transport-PM horse additions.

**Primary tuning dials**, in the order I would reach for them:

1. `pm_cart_roads` horse input (the single most load-bearing number).
2. Infrastructure per level across the ladder (15/22/30/38/48).
3. Horse Ranch output (12/20/28).
4. Infrastructure building construction cost (400) and employment (500).

**Deliberately conservative choices:** construction cost `medium` rather than
`high`, because this building is needed in *every* state and `very_high` (the
railway's cost) would be crushing at scale. Employment matched to the railway
rather than the construction sector.

**Not yet modelled:** the government budget impact of employing 500 people per
state in every state. For a large country that is still a significant new
expense on top of the goods, though halving it from the original 1000 shifts the
burden meaningfully toward materials. Worth watching in the first playtest.

**The Bureaucracy law now has a large new political side-effect — this is a
feature, but a big one.** Under Hereditary Bureaucrats every state in the
country employs 50 aristocrats per infrastructure level, on top of vanilla's
Government Administration aristocrats. Across a large empire that is a
substantial boost to Landowner political strength, funded by the state. Elected
Bureaucrats pushes the same weight toward clerks instead, strengthening the
petty bourgeoisie and intelligentsia.

That makes the Bureaucracy law a genuinely economic *and* political choice in a
way it is not in vanilla, and it means switching bureaucracy law mid-game
triggers a real reshuffle of who holds power. Worth watching that it does not
make Hereditary Bureaucrats a landowner-autocracy trap that is impossible to
legislate out of.

**PM group AI selection:** all our PM groups must set
`ai_selection = most_productive`. The default is `most_profitable`, which is
meaningless on a building with no salable output — vanilla sets
`most_productive` on every Government Administration group for exactly this
reason.

**Late-game qualified-labour squeeze:** the top PMs on both buildings want 275
machinists + engineers (Infrastructure) and 200 (Harbour Works) per state, in
*every* state, on top of existing industrial demand. In a large country that is
real competition for a scarce pop type. If it bites, flatten the engineer counts
before touching anything else.

---

## 4. Profitability impact of horses

Computed from vanilla 1.13 goods prices against each affected building's actual
production methods. **Goods margin only — wages are excluded**, so the effect on
true profit is larger than the percentages below.

### What is and is not affected

**Unaffected: railways and ports.** They lost `state_infrastructure_add`, which
is a state modifier and not a salable good. Their goods inputs and outputs are
byte-identical to vanilla, so their profitability does not move at all.

**Affected: 18 buildings** that use the haulage PMs — 5 mines (coal, iron, lead,
sulfur, gold), 11 plantations plus the vineyard, the logging camp, and the oil
rig.

**Improved: subsistence pasture**, +0.25 horses ≈ +£7.5 per level.

### 1836 — `pm_road_carts`, +3 horses = £90/level

| Building | Revenue | Inputs | Margin | After horses | Change |
|---|---|---|---|---|---|
| Sugar plantation | 1950 | 0 | 1950 | 1860 | −4.6% |
| Oil rig | 2400 | 600 | 1800 | 1710 | −5.0% |
| Tobacco plantation | 1400 | 0 | 1400 | 1310 | −6.4% |
| Coffee plantation | 1250 | 0 | 1250 | 1160 | −7.2% |
| Dye plantation | 1200 | 0 | 1200 | 1110 | −7.5% |
| Vineyard / tea / opium | 1000 | 0 | 1000 | 910 | −9.0% |
| Cotton / banana | 900 | 0 | 900 | 810 | −10.0% |
| Sulfur mine | 1000 | 200 | 800 | 710 | −11.2% |
| Rubber plantation | 800 | 0 | 800 | 710 | −11.2% |
| Silk plantation, logging camp | 600 | 0 | 600 | 510 | −15.0% |
| Iron / lead / gold mine | 800 | 200 | 600 | 510 | −15.0% |
| **Coal mine** | 750 | 200 | 550 | 460 | **−16.4%** |

### Late game — rail haulage, +1 horse = £30/level

Using each building's most advanced methods, the impact all but vanishes:
**−0.9% to −2.9%**, worst case the banana plantation at −2.9%. This is the
intended shape — horses are an early-game burden that industrialisation escapes.

### The caveat that matters: horses will not trade at par

Seeded Horse Ranch supply is **10,284 horses/week before state modifiers**
(857 levels × 12). Static known demand is **10,494/week**:
400 Public Works, 7,059 haulage, 2,257 farm draft animals, and 778 cavalry.
The new ranch locations, level choices, and land audit are documented in
[`tools/HORSE_SEED_1836.md`](tools/HORSE_SEED_1836.md).
Subsistence pastures add some supply, while dynamically created Urban Centers
add demand. Ranch supply is **210/week below** this known demand before pasture
output and state modifiers. Actual opening prices and shortages must be measured by market;
the cost examples below scale with horse price:

| Building | Margin | @30 (par) | @45 (1.5×) | @60 (2×) |
|---|---|---|---|---|
| Coal mine | 550 | −16.4% | −24.5% | −32.7% |
| Iron mine / logging | 600 | −15.0% | −22.5% | −30.0% |
| Cotton plantation | 900 | −10.0% | −15.0% | −20.0% |
| Oil rig | 1800 | −5.0% | −7.5% | −10.0% |

A coal mine losing a third of its goods margin in 1836 is a real risk of
unprofitable extraction and a stalled early economy.

**Levers, cheapest first:** drop `pm_road_carts` from 3 horses to 2 or 1; raise
the subsistence pasture output above 0.25; loosen `curate.awk` to seed more
ranches; or lower the `horses` base cost below 30.
