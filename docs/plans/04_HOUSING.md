# Plan 4: Housing

Updated: 2026-10-30 (merged into the main mod; housing design last changed
2026-10-09). Back to the [overview](../OVERVIEW.md).

Condensed from the agreed housing proposal, the housing implementation plan and
the housing feasibility record. Those originals are in
[the archive](../archive/planning-2026-10-24/README.md). Debug events, test
values and the full 14-item runtime checklist are in
[docs/HOUSING_TESTING.md](../HOUSING_TESTING.md).

## Goal

Housing is an ongoing accommodation service, sold as a normal **local good**.
Households buy Housing and Luxury Housing through ordinary wealth-based needs.
Supply comes from subsistence buildings, optional company housing, dedicated
residential buildings and emergency measures. Residential buildings use a lot of
infrastructure, which makes replacing old, sprawling housing with dense housing
worthwhile where infrastructure is scarce.

## Design history

1. **Capacity model (archived 2026-10-03).** Housing capacity,
   employment-based entitlement and delayed eviction. Superseded; the probe
   scripts were removed on 2026-10-04 at the user's request. Kept in
   [docs/archive/housing-capacity-2026-10-03/](../archive/housing-capacity-2026-10-03/).
2. **Goods model (agreed 2026-10-04).** Current design.
3. **Residential land counter removed (2026-10-09).** The user rejected a
   scripted land pool in favour of high native infrastructure demand per
   building. The land script values, construction gates, Alentejo allowance and
   copied state-panel GUI were deleted. No rezoning action is planned.

## Agreed rules (do not change without the author)

- No parallel entitlement, capacity or rent-transfer system. Employment affects
  housing only through income. No exact household-to-building assignment.
- Basic Housing is needed from the lowest wealth level and grows with wealth.
  Luxury Housing is an *additional* wealthy need, never a substitute.
- Residential quality and structure are fixed by building type. No PM switch
  turns a slum into a tenement. Replacement means acquire, demolish, rebuild.
  No free redevelopment and no automatic confiscation.
- **Slums:** mortality and migration penalties scale with staffed levels
  (levels × staffing). One flat SoL penalty applies while *any* slum level
  exists, regardless of count or staffing, and goes when the last is
  demolished. Do not use pollution, spill into neighbouring states, or attach
  the harm only to slum employees. If more slum types are added, keep a single
  state-wide SoL penalty.
- Suburbs and luxury housing give staffed migration bonuses. They can offset
  slum migration loss but not slum mortality or SoL.
- Minimum residential standards stop new and expanded slums; existing slums keep
  running until acquired and demolished.
- **Hostile company housing** is cheaper to run, hurts only that building's
  employees (SoL and mortality), and must not grow per level for each employee.
  When a law bans it, it switches to **No Company Housing**, never upgrades to
  safe housing. Safe PMs are never touched. Employer housing is exempt from
  residential ownership laws.
- Infrastructure demand belongs to building levels regardless of staffing. It is
  an incentive, not a hard cap. Subsistence and company housing stay under their
  workplace's infrastructure use.
- Both emergency responses stay: the Emergency Accommodation decree and the
  Temporary Shelter Programme. Neither supplies luxury housing or upgrades
  structures permanently.
- Do not implement a housing-only policy with country-wide privatisation rules.
  Do not equate worker ownership of a housing business with resident ownership.

## What is done (delivered 2026-10-04, revised 2026-10-09, merged 2026-10-30)

Housing was built as the separate BOI Housing Prototype and **merged into the
main mod on 2026-10-30** at the author's request, ahead of the original release
gate (see below). It loads in every BOI campaign. Starting residential supply is
still unseeded.

- Local Housing and Luxury Housing goods with dedicated icons. Demand generated
  into all 99 wealth packages, preserving vanilla needs: basic `10 + 2W`, luxury
  `(W − 14)²` from wealth 15.
- Six fixed building types (per staffed level; 1,000 maintenance staff, not
  residents):

  | Building | Basic / luxury | Infra | Effects |
  |---|---|---|---|
  | Slum Districts | 60 / 0 | 8 | +0.1% mortality, −0.2% migration; −1 flat SoL |
  | Tenement Districts | 70 / 0 | 6 | none |
  | Apartment Blocks (steel-frame tech) | 100 / 10 | 4 | none |
  | Luxury Apartments | 25 / 60 | 5 | +0.2% migration |
  | Suburban Estates | 25 / 60 | 8 | +0.3% migration; commuting inputs |
  | Temporary Shelter Programme (government-funded) | 40 / 0 | 5 | treasury wages, wood, fabric, tools |

- Suburb commuting: 6 horses, 5 transportation or 2 automobiles, tech-gated.
- Company housing PM group on 27 rural building types including Horse Ranches;
  No Company Housing is default and never gated. Hostile camps (8 housing, −1
  SoL, +5% mortality), safe settlements (6), serviced towns (12, Modern
  Sewerage).
- 0.25 basic housing per staffed level on all five subsistence building types.
- Employer Housing and Residential Standards law groups, with reform supporters
  and opponents attached additively to IGs. Enactment fallback to None plus
  monthly maintenance.
- Emergency Accommodation decree: 100 Authority, +15% basic output for all basic
  suppliers, −1 state SoL.
- Debug events `boi_housing.1` to `.4` (init laws, Alentejo fixture, permissive
  laws, protective laws).
- Generator `tools/Build-Housing.ps1` (owns four generated files in the mod
  root and never reads them back; shadows 31 vanilla building keys and all 99
  buy packages; no vanilla PM shadowed). BOI's own Horse Ranch lists company
  housing by hand in `50_boi_buildings.txt`. Regression checks in
  `tools/Test-Housing.ps1`, run by `Validate-All.ps1`.

**The merge (2026-10-30):** the prototype's files moved from
`tools/housing-prototype/` into the mod root, its launcher descriptor was
deleted, and the `mod/BOIHousingPrototype` link was removed. One real engine
conflict was fixed: the prototype's generated `00_` building file carried a
copy of BOI's Horse Ranch, which replaced BOI's own `50_` definition (logged as
`Duplicated key building_boi_horse_ranch will not be created from file:
common/buildings/50_boi_buildings.txt`). The generator now copies vanilla
buildings only.

**Validation:** `Validate-All.ps1` passes on the merged mod (2026-10-30). Headless
observer runs of BOI with housing, 1836–1846 on 1.13.11, loaded with no housing
errors. The only housing lines are the three expected "orphaned" debug events,
which the harness now counts separately.

## What is left

### Step 1: Live engine test (item 1 partly covered by headless runs; 2 to 14 not run)

Run the checklist in `docs/HOUSING_TESTING.md`. Fix script errors before any tuning.
Highest-risk items:

- [ ] Loads without housing errors, unknown modifiers, bad scopes, missing icons
      or localisation.
- [ ] Unscaled slum SoL: gone at zero built levels, present at zero staffing, not
      applied for a queued building, does not stack per level.
- [ ] Hostile penalties hit only the employing building's pops (check
      dependants); law fallback runs on enactment and selects None before or
      after engine invalidation; safe PMs survive.
- [ ] Alentejo fixture: +32 infrastructure demand (8 + 6 + 5 + 8 + 5), persists
      at zero staffing, released on demolition, no duplicates on re-run.
- [ ] Save/load, form/release a country, transfer a state: no reset laws or
      duplicate ideologies.

### Step 2: Infrastructure and redevelopment economics

- [ ] Confirm the redevelopment incentive is real. Output per infra point today:
      slum 7.5 basic; tenement about 11.7; apartment 25 basic + 2.5 luxury;
      luxury apartment 5 basic + 12 luxury; suburb 3.1 basic + 7.5 luxury plus
      commuting.
- [ ] Compare a slum and tenement state with the same state after acquiring,
      demolishing and building apartments: output, infra, purchase and
      construction cost, prices, shortages.
- [ ] Check that shortages actually move the housing economy and AI choices; if
      not, revise coefficients before main-mod integration.
- [ ] Uncapped per-level mortality and migration can get large in big states;
      keep the agreed rule while calibrating level size and coefficients.

### Step 3: Acquisition before demolition

- [ ] Investigate native downsizing rules and ownership fractions. Enforce
      acquisition before private housing is demolished without bypassing payment.
      No confiscation workaround. Keep a government-owned redevelopment path.
- [ ] Confirm private investment is allowed for the new building groups.

### Step 4: Emergency measures and transitions

- [ ] Decree changes only basic output and ends cleanly. Review whether it should
      boost subsistence and company housing too.
- [ ] Shelters charge the treasury, sell housing, produce nothing unstaffed. Add a
      suspension or closure path; decide construction and deconstruction rules.
- [ ] How the engine handles already-queued slums when standards pass.

### Step 5: Starting supply and AI

- [ ] Build a reproducible seed from population, wealth and existing subsistence
      supply. Never seed a whole region's demand once per owner. Company housing
      starts at None and must not hide missing stock.
- [ ] Calibrate peasants (low and high wealth) first, then a mixed urban state.
      Peasants market only 5% of normal consumption.
- [ ] Test demand shocks, layoffs, rapid growth, deindustrialisation; confirm the
      AI funds, builds and runs needed housing.

### Step 6: Presentation

- [ ] Keep housing under the Development category while testing. Explain infra
      cost through building tooltips and a short Housing explanation. A dedicated
      Housing tab needs its own GUI test. Do not restore the copied state-panel
      GUI just for a counter.

### Step 7: Ownership laws (deferred design)

- [ ] Landlord, cooperative, public and frontier-homesteading ownership;
      construction rights, forced privatisation, government-only construction.
      Resolve precedence against vanilla economic laws first.

## Release gate

The original gate was to merge only after live tests, infrastructure and
redevelopment balance, acquisition rules, starting supply and AI behaviour all
passed. The author chose to merge first (2026-10-30), so those items are now the
gate for a public BOI **release**, not for the merge. Definitions and generator
were merged together, and `tools/Build-Housing.ps1` is the only buy-package
generator. Existing saves need their own migration plan; start a new campaign.

## Provisional values

Every number, tech gate, building name and political stance in the housing
module is a test value. The wealth-15 luxury threshold is a starting point, not
a settled class boundary.

## Test log

For each run, note game version, state, staffing, prices, modifiers, errors and
screenshots before marking anything verified.

- **2026-10-30, headless, 1.13.11, 1836–1846, BOI + housing (then still the
  prototype), observer AI** (`tools/headless-runs/20261030-104714_mod`). No
  crash; no housing errors besides the three orphaned debug events. National
  basic Housing sat at its price floor (7.5 of 30) in all 14 tracked countries,
  with supply 3–5 times demand, mostly from subsistence output. Luxury Housing
  was short in some (Brazil and Spain sold none). The AI built a few suburbs and
  luxury apartments; no country built apartment blocks. National aggregates only.
