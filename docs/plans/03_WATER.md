# Plan 3: Water and Waterworks

Updated: 2026-10-24. Back to the [overview](../OVERVIEW.md).

Condensed from the water proposal (sections 1 to 9 drafted, section 10 built on
2026-10-09) and the water prototype README. The period research and sources
are in the [archived proposal](../archive/planning-2026-10-24/PROPOSAL_WATER.md);
the test module's run instructions are in
[tools/water-prototype/README.md](../../tools/water-prototype/README.md).

## Goal

Water is the thing a growing 19th-century city ran out of first. Make it a
**local good** that cannot leave its state, so a state's own geography and
investment decide its supply. Tie it back to the core loop: horses cart water
early, industry pollutes it, and piped systems use up infrastructure.

## Design history

The first draft put water PM groups on Public Works and Harbour Works. On
2026-10-09 that was replaced by a separate **private Waterworks** building, for
these reasons: water has a price, so a private owner has a profit signal and the
AI handles PMs and construction without workarounds; Public Works' PM panel was
already crowded; a separate building has its own level and its own
auto-expansion. The Harbour Works water group from the draft is not built.

## What is done (2026-10-09)

Static checks pass (`tools/Test-WaterModule.ps1`, wired into
`Validate-All.ps1`). **Nothing has been run in-game.**

### Goods

| Good | Local | Cost | Role |
|---|---|---|---|
| `water` (Local Water) | yes | 20 | What households and industry consume |
| `bulk_water` | no, `tradeable = no` (deliberate test) | 20 | Water in transit; pools across the market |

Water only crosses a state border by converting to Bulk Water and back, and both
conversions lose water, so a round trip always loses.

### Building: `building_boi_waterworks`

- Private (`ownership_type = self`), in its own root group `bg_boi_waterworks`,
  `category = rural`. Not under `bg_extraction`, which is resource-capped and
  would make it unbuildable everywhere.
- `infrastructure_usage_per_level = 2`, plus negative infrastructure on piped
  tiers: the "stress of infrastructure".
- `ai_value` +3000 while a state of over 10,000 people has no Waterworks.
- Three PM groups:

**Source** (`most_profitable`, staffed):

| PM | Gate | Water out |
|---|---|---|
| Wells and Carriers (default) | none | 24 |
| Gravity Aqueducts | `urban_planning` | 36 |
| Steam Pumping Stations | `atmospheric_engine` | 50 |
| Filtered Mains | `modern_sewerage` | 60 |
| Treatment and Reservoirs | `pharmaceuticals` | 70 |
| Electric Pumping Grid | `electrical_generation` | 75 |
| Import: Water Wagons | none | 15 (from Bulk Water, plus horses) |
| Import: Aqueduct Intake | `urban_planning` | 22 |
| Import: Pressure Main | `modern_sewerage` | 34 |

Outputs are about 4× the draft so supply can meet the housing prototype's scale.
Wells carry a small mortality cost; steam pumping adds pollution; import is
about 25% lossy and needs fewer staff.

**Export** (`most_profitable`, **no employment keys**, all `workforce_scaled`):
None (default), Surplus Sales (8 water in), Bulk Sales (`urban_planning`, 16),
Aqueduct Contract (`modern_sewerage`, 32), each converting at 75%. Export
amounts are fixed per level, not a fraction of source output; the engine cannot
make one PM read another. Export draws from the state pool, so a short state's
price rises and export stops paying.

**Administration** (`most_productive`): Appointed Water Commissioners /
Manorial Water Rights / Elected Water Boards, following Bureaucracy law. The
Road Financing group is not attached.

### Traits

Six traits in `common/state_traits/51_boi_water.txt`: Abundant Water (+25%),
Dry Summers (−25%), Arid Interior (−50% water, −10% horses), Monsoon-Dependent,
Irrigation Heritage (+15%), Brackish Aquifer (−15%). Rivers and deserts tagged
automatically; about 164 states curated by `tools/Add-WaterTraits.ps1`.

### Demand

`popneed_boi_water` is defined in the main mod, but **nothing buys water** unless
the optional [water demand module](../../tools/water-prototype/README.md) is
loaded. It replaces `00_buy_packages.txt` with vanilla's 99 packages plus
`popneed_boi_water = 8 + wealth`. It cannot be loaded alongside the housing
prototype; use `tools/Build-WaterPrototype.ps1 -MergeIntoHousing` instead.

## What is left

### Step 1: Runtime checklist (all not run)

Record results in this plan's test log below.

- [ ] `tradeable = no` on Bulk Water: does it move between two states in the same
      market, and stay out of cross-market trade? If it cannot move at all, delete
      the flag.
- [ ] Waterworks appears in the build menu (which tab), and private capital
      builds it.
- [ ] Owner earns revenue and pays wages and inputs.
- [ ] Export buys water from the state pool at the state price.
- [ ] How far Bulk Water's price swings with few producers.
- [ ] `state_mortality_mult` and `state_pollution_reduction_health_mult` inside a
      PM's `state_modifiers` (not seen in a vanilla PM): error log and state panel.
- [ ] `goods_output_water_mult` from a trait scales output (check a Dry Summers
      and an Arid Interior state).
- [ ] State infrastructure and market access fall as levels and piped tiers grow.
- [ ] Changing the Export PM does not change employee count.
- [ ] Admin PM follows the Bureaucracy law.

### Step 2: Seed and demand calibration

- [ ] No Waterworks exist in 1836, so every household starts short and SoL dips
      until the AI builds. Decide on a 1836 seed (follow the core seed pattern:
      generated history, so buildings start staffed).
- [ ] Calibrate demand (placeholder `8 + wealth`) against supply.
- [ ] Re-check that Public Works can keep up with the extra infrastructure use.

### Step 3: Merge demand into the main mod

- [ ] Fold water demand into a single buy-package generator shared with housing,
      so the main mod owns one copy of `00_buy_packages.txt`. Only after Step 2.

### Step 4: Stress consequences (from the draft, not built)

Hidden monthly state event that swaps one scaled static modifier (no vanilla
shadows, up to a month of lag):

- [ ] Shortage tiers (`boi_water_stress_low/_high`): throughput, SoL and migration
      down. First verify whether `building_has_goods_shortage` or
      `market_goods_shortage_ratio_*` can read a local good's per-state balance;
      fallback is a script value from building levels and population.
- [ ] Pollution reduces usable supply (the Irwell effect); treatment tiers damp it.
- [ ] Stress rises when `infrastructure_delta < 0`.

### Step 5: Optional extensions

- [ ] **Harbour Works water group** (coastal only): Water Lighters, Brackish
      Intake Wells, Distilling Condensers (condensers are flavour, not
      researched). Gives dry coastal states a second source.
- [ ] **Cholera outbreak events**: shortage plus density plus no filtration.
      Blamed on foul air before the filtration tech, on water after. Gate on
      `is_player`.
- [ ] **Layer 2 industrial demand**: shadow a short list of vanilla PMs (textiles,
      steel, paper, chemicals, food, steam power) so heavy users consume water.
      Count the exact set first; this is the real patch debt. Alternative without
      shadows: a monthly event applies a modifier based on industrial levels.

## Open questions for the author

1. Should every state feel water through household demand, or only industrial
   areas?
2. Keep infrastructure cost visible on the PM (as built), or hide it in the
   stress event?
3. How harsh should mortality be, given vanilla's war and famine effects?
4. Are Layer 2 vanilla shadows acceptable?

## Test log

No runs recorded yet. For each run, note game version, mods loaded, state,
staffing, prices, modifiers, errors and screenshots.
