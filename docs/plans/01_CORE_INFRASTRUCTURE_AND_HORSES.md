# Plan 1: Core infrastructure and horses

Updated: 2026-10-24. Back to the [overview](../OVERVIEW.md).

Condensed from the development plan (2026-08-23, updated to 2026-09-23), the
review of 2026-09-21, the deferred-ideas list, and the tools audits. Full
numbers and reasoning stay in [BALANCE.md](../../BALANCE.md); the originals are
in [the archive](../archive/planning-2026-10-24/README.md).

## Goal

Infrastructure is supplied by government-funded Public Works and Harbour Works,
fed by horses early and by transportation, oil and electricity later. Railways
and ports keep their transport output but give no infrastructure. The system
must work from the 1836 start, and the AI must keep its states supplied.

## What is done

### Content

| Item | Detail | Key files |
|---|---|---|
| `horses` good | cost 30, custom provisional icon and texticon | `common/goods/`, `gui/boi_goods_texticons.gui` |
| Horse Ranch | 3 PMs: Open Pasture 12 → Selective Breeding 20 → Stud Farms 28 horses. No tech gate on the base PM. Uses `most_profitable` (changed 2026-09-23) | `common/production_methods/50_boi_horse_ranch.txt` |
| Public Works | 5 tiers: Cart Roads 15 → Macadam 22 → Rail Network 30 → Motor Roads 38 → Modern Highways 48 infra. 400 technical + 100 admin staff per level | `common/production_methods/50_boi_infrastructure.txt` |
| Harbour Works | Coastal only. 3 tiers: Coastal Lighters 10 → Steam Lighters 18 → Electrified Quays 25 infra. 375 technical + 125 admin | `common/production_methods/50_boi_harbour_works.txt` |
| Bureaucracy admin group | Manorial (hereditary / crownland diets) → Appointed (default) → Elected, on both works | same files |
| No maximum level | Deliberate, matching railways (2026-09-23). `stateregion_max_level` alone does not cap; do not add `has_max_level` without checking how its dynamic modifier initialises | `common/buildings/50_boi_buildings.txt` |
| Rail and port changes | `state_infrastructure_add` removed; transport output unchanged | vanilla PM shadows |
| Haulage horses | `pm_road_carts` +3 (one key reaches 18 PM groups); rail haulage tiers +1; electric and refrigeration tiers untouched. `pm_log_carts` is the most advanced tier, not a horse cart, and is left alone | PM shadows |
| Other horse consumers | Crop farm draft animals, urban centre transport (1 horse per level on the start PM) | PM shadows |
| Subsistence pasture trickle | +0.25 horses on both halves of the pasture PM group | PM shadows |
| Cavalry upkeep | Horses replace grain: hussars 1, dragoons 1, cuirassiers 1, lancers 2. Hussar 1.13.11 `formation_modifier` restored (verified 2026-10-24) | `common/combat_unit_types/00_boi_cavalry_overrides.txt` |
| Mobilization options | Horseback Reconnaissance (weaker than motorised), Horse-Drawn Transport (Forced March movement, smaller speed bonus, no morale penalty, exclusive with other transport), Extra Supplies needs horse supply and uses 0.5 horses | `common/mobilization_options/`, GUI shadow for the panel |
| Horse-Breeding Traditions | Regional state trait with `goods_output_horses_mult` | `tools/Add-HorseBreedingTrait.ps1` |
| Icons | Horse good, three buildings, the trait. All provisional AI-assisted art | `gfx/interface/icons/` |

### 1836 seed

Seeded through generated history so buildings start staffed (script-created
buildings start empty and caused a self-curing shortage every game).

- **Infrastructure replaces only what rail and ports lost**, per actual state
  owner, across 1,147 state-owner records. Removed: 357 levels / 1,107 infra.
  Planned: 40 Public Works levels (20 buildings) and 141 Harbour Works levels
  (139 buildings), 2,010 infra. Audit: `tools/STARTING_INFRASTRUCTURE_1836.md`.
- **Horse Ranches are curated** after a hard crash from over-allocating arable
  land (a state's real arable land depends on incorporation and province
  ownership, not the region's declared figure). 225 ranches, 857 levels: the
  original 236 safe states plus 14 reviewed additions, then cut by regional
  suitability (25 states drop to zero; 15 unincorporated states held at three
  levels or fewer). Every ranch state keeps at least 12 arable levels of
  headroom. Audit: `tools/HORSE_SEED_1836.md`.
- **Opening balance:** 10,284 horses/week from ranches against 10,494 known
  demand (400 Public Works, 7,059 haulage, 2,257 farms, 778 cavalry), so 98%
  covered before pasture output and dynamically created Urban Centre demand.
  Biggest country gaps: BIC −711, CHI −657, GBR −389. Biggest surpluses: RUS
  +497, MEX +486, HUN +439. See `tools/HORSE_BALANCE_1836.md`.
- Colonised states are deliberately not seeded. Conquest needs no handling.

### AI (2026-09-23)

- Public Works (base 3000) and Harbour Works (base 1500) multiply `ai_value` by
  spare infrastructure: ×6 below −20, ×4 below 0, ×2 under 5, ×1.5 under 15,
  ×0.75 under 30, ×0.25 at 30+. A small input-price factor (0.8 to 1.2) uses
  horses or transportation for Public Works and merchant marine for Harbour
  Works. Details: `tools/AI_VALIDATION.md`,
  `common/script_values/50_boi_ai_values.txt`.
- Railway priority now follows transportation price; its auto-expansion no
  longer reacts to infrastructure deficits (full-key `building_railway` shadow).
- Public Works and Harbour Works auto-expand when spare infra is under 5, the
  owner is not in default, the building is at least 90% staffed, and none is
  already under construction. Opt-in toggle.

### Architecture decision (2026-09-23)

**Keep the separate Horse Ranch.** It costs 16 full state-region overrides and
conflicts with map mods, but gives the strongest identity and makes horses
compete for arable land. Folding horses into Livestock Ranches was considered
and rejected unless the separate building proves untenable. Consider patches
for major map mods before release.

### Validation done

Static only: `tools/Validate-All.ps1` passes (structure, BOM and braces, seed
counts, 675-state horse safety audit, shadow drift). A short Portugal
debug-mode game ran without obvious failure. That is a smoke test, not a
balance test.

**Headless 20-year pair, 2026-10-30** (`tools/Test-Headless.ps1`, 1836 to 1856,
BOI + housing prototype against vanilla, one run each, observer AI). These are
single runs and history diverged (revolts, wars), so read these as directions,
not effect sizes. Major powers in both runs, unless noted:
- Stable: no crash. The only BOI-attributed errors are the housing prototype's
  orphaned events `boi_housing.2` to `.4`.
- Infrastructure supply is 23% below vanilla by 1855 and usage 20% above it.
  States in deficit: 23 against vanilla's 0. Vanilla's deficits clear as rail
  spreads; BOI's don't. GBR, NET and PRU are 36 to 47% below vanilla.
- **Step 3 answer: underbuilding.** Public Works barely exist and shrink
  (FRA 4→0, GBR 3→1; RUS 1→5 is the only growth). Seeded Harbour Works
  disappear (FRA 7→0, SPA 7→0, USA 8→0). Horse Ranches are flat apart from
  RUS +8 and NET +4.
- Horses: GBR runs a structural deficit (buy 4216 against sell 2667 in 1855)
  at +44% of base, with 1–11 expensive states. Elsewhere supply roughly matches
  demand at or below base price.
- SoL averages about 0.8 below vanilla through the 1840s and converges by 1855
  (9.91 against 9.98).

**AI fix, 2026-10-30** (three 10-year headless runs with per-state
diagnostics; details in `tools/AI_VALIDATION.md`). The engine ignores
`ai_value` for these buildings. It never built them in states 31 short. Its
budget cuts demolished them even in deficit states, including 17 of GBR's 20
seeded levels in the first six months. Fix: `downsizeable = no` plus a hidden
monthly event that queues a level for AI countries in the worst-deficit state.
It has a one-year per-state cooldown and a concurrency cap. Deficit states
across 12 major powers at the end of 1845: 26 → 1, with no debt spiral.
Trade-off: players can no longer downsize either.

## What is left

### Step 1: Clean 1.13.11 start

- [ ] Launch, check `error.log` for invalid scopes, script values, price
      triggers and building definitions. Confirm the shadows (including the
      railway shadow) win loading. Expected duplicate-key lines are not proof.
- [ ] Confirm every starting market has access to some horse production.
- [ ] Confirm the hussar fix in the unit panel.

### Step 2: Opening market measurement

Record for Britain, Austria, Qing, Sokoto, a small isolated market and a
country with split states:

- [ ] Opening horse price and shortages, by market not world total.
- [ ] Government goods and wage spending; market access; infrastructure balance.
- [ ] Whether horse-starved coal, iron, logging and plantation buildings go
      unprofitable or fail to hire (coal loses 16% of goods margin at par, a
      third at double price).
- [ ] Effect of Public Works wages on countries with many low-population states.

### Step 3: AI over time

- [x] Underbuilding: fixed with the scripted fallback and `downsizeable = no`
      (2026-10-30, 10-year runs).
- [ ] Public Works, Harbour Works and Horse Ranch levels after 20 and 50 years
      with the fallback. Watch for overbuilding, now that levels can't be
      shed. GBR's seed already leaves +36 to +81 spare in its home states.
- [ ] States with ample spare capacity, near zero and in deficit: construction,
      occupancy, budgets.
- [ ] Early Public Works uses horses, later tiers transportation; first
      construction still happens.
- [ ] Railroad auto-expansion: a deficit alone must not trigger it.
- [ ] PM upgrades without local transportation or electricity (a more productive
      PM is useless if its inputs are missing). Newly colonised states.
- [ ] Horse Ranch PM choice under cheap horses and expensive grain and tools.
- [ ] Decide whether auto-expansion needs a wider budget-health guard than
      "not in default", and a buffer to stop oscillation.

### Step 4: Politics side effects

- [ ] Whether Hereditary Bureaucrats becomes a Landowner trap: 50 state-paid
      aristocrats per Public Works level in every state. Also see plan 2, which
      stacks Statute Labour on top.
- [ ] Late-game qualified-labour squeeze: top tiers want 275 (Public Works) and
      200 (Harbour Works) machinists and engineers per state. Flatten engineer
      counts first if it bites.

### Step 5: Tuning

Tuning dials, in the order to reach for them:

1. `pm_boi_cart_roads` horse input (most load-bearing number).
2. Public Works infrastructure per tier (15/22/30/38/48).
3. Horse Ranch output (12/20/28).
4. Public Works construction cost (400) and employment (500).
5. Subsistence pasture output (0.25; extend to subsistence farms if too thin).
6. Number and spread of seeded ranches.

If extraction is hit too hard: drop `pm_road_carts` from 3 horses to 2 or 1, or
lower the horse base price. Model shortage penalties separately from price,
since a £30 good tops out around £52.50.

### Open design questions

- **Harbour Works' role.** Same construction and staff as Public Works but 10
  infra instead of 15 at base, with equal goods cost per point. Its niche is
  input diversification (merchant marine instead of horses), not "more total
  capacity", since there is no cap. Confirm that is enough, comparing full costs
  including wages.
- **Road and rail.** Rail Network, Motor Roads and Modern Highways all consume
  transportation, so road modernisation stays tied to local transport output.
  Decide whether that is an integrated freight network or whether roads should
  be a distinct alternative, and align names and tooltips.
- **Seeding to need.** Seeding is now replacement-based. Once opening
  measurements exist, decide whether to seed against actual starting need.

## Deferred (from the original scope)

Agreed 2026-08-16 as later phases: military training PMs, wider draught animals
in agriculture (crop farms are now done), and pop-needs horse consumption. See
the overview's idea list.

## Exit criteria

Infrastructure expense creates choices the player can plan around; the AI
keeps viable market access across the test countries for 50 years;
modernisation helps without routinely breaking input supply. Then call it beta.
