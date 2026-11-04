# Plan 4: Housing

Updated: 2026-11-03 (15 buildings and Light and Heat; numbers live in `tools/Housing-Tiers.ps1`, and the building table below is out of date. See the [tiers proposal](04_HOUSING_TIERS_PROPOSAL.md)). Back to the [overview](../OVERVIEW.md).

## Current state and open decisions (2026-11-01)

Decided by the author on 2026-11-01. The details are in the rules, "What is done"
and the test log below.

- **Company housing:** No Housing, Work Camp, Work Town (half the penalties), Serviced
  Town (no penalty), all with equal output. The AI choosing No Housing or Work Camp
  on profit is desired behaviour.
- **Employer housing laws:** Unregulated, Protected, and Mandatory Serviced Housing
  (unlocked by Socialism). Each permits No Housing plus one tier.
- **Demand:** 0% when Destitute, at most 5% at the price ceiling when Struggling, an
  S-curve to 15% at base price at Lavish, flat above that.
- **Aim:** housing causes complications without dragging the game to a halt. Supply
  sits just under demand.

Chosen during tuning and open to change: residential buildings at a tenth of their old
size, a seed of 1,046 levels, and conversions on law repeal (paying tiers move to
whichever tier the new law permits).

Open:

- [ ] **SoL gap to vanilla, about -0.6.** It barely moved when housing costs and Work
      Camp penalties fell, so housing looks unlikely to be the main cause. Test a game
      with housing demand removed, then grain and tools (about +8% and +11% against
      vanilla).
- [ ] **Services prices are not logged in BOI runs.** Vanilla's are in the ensemble
      database. Add services to the telemetry before the next comparison.
- [ ] **Government debt.** Seeded housing is state-owned. France, the USA and Spain
      ended at 0.32–0.44 scaled debt in the kept run, against at most 0.10 in attempt 1.
      One run each; check it in the ensemble.
- [ ] **Work Camp's role.** About 8% of levels by 1845 at 0.45 housing per level. It
      earns little, with its penalties unchanged. Giving it more output would break
      the equal-output rule, so this is the author's decision.
- [ ] **BOI ensemble and later eras.** All housing results are single runs that stop at
      1846. Next: 10 BOI games against the vanilla baseline, then a longer run.

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
- Housing demand is a share of each level's core game basket (changed by the author
  2026-11-01): none when Destitute, at most 5% at the price ceiling when Struggling,
  then a curve to 15% at base price at Lavish, flat above that.
  Luxury Housing is an *additional* wealthy need, never a substitute.
- Residential quality and structure are fixed by building type. No PM switch
  turns a slum into a tenement. Light and Heat (author, 2026-11-03) is the only PM
  that can change on a housing building: None, Wood, Oil or Electricity for extra
  housing; slums get None or Wood only. Replacement means acquire, demolish, rebuild.
  No free redevelopment and no automatic confiscation.
- **Slums (changed by the author 2026-11-01):** no SoL penalty, because the mod's SoL
  penalties were feeding radicals. Part of the mortality penalty and all of the
  migration penalty scale with staffed levels (levels × staffing). A flat mortality
  penalty applies while *any* slum level exists, regardless of count or staffing, and
  goes when the last is demolished. The author chose +50 pollution per staffed level as
  a later step, which reverses the old no-pollution rule; it isn't in yet. Don't attach
  the harm only to slum employees. If more slum types are added, keep a single
  state-wide flat penalty. See [the proposal](04_SOL_TO_MORTALITY_PROPOSAL.md).
- Suburbs and luxury housing give staffed migration bonuses. They can offset
  slum migration loss but not slum mortality.
- Minimum residential standards stop new and expanded slums; existing slums keep
  running until acquired and demolished.
- **Company housing has four tiers (changed by the author 2026-11-01): No Housing,
  Work Camp, Work Town, Serviced Town.** A Work Camp is cheapest to run and hurts
  only that building's employees (mortality). A Work Town supplies the same
  housing at half those penalties. Penalties must not grow per level for each
  employee. Each employer housing law permits **No Housing plus one tier** (changed
  by the author 2026-11-01): Unregulated allows Work Camps, Protected allows Work
  Towns, and Mandatory Serviced Housing (unlocked by Socialism) allows Serviced
  Towns. Enacting or repealing a law moves paying tiers to the permitted one, or to
  No Housing under the mandate without Modern Sewerage; No Housing is never changed.
  Employer housing is exempt from residential ownership laws.
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
seeded from measured 1836 demand (2026-11-01; see step 5).

- Local Housing and Luxury Housing goods with dedicated icons. Demand generated
  into all 99 wealth packages, preserving vanilla needs. Basic is `10 + 2W` capped at
  the level's total, and luxury takes the rest.
- Six fixed building types (per staffed level; 1,000 maintenance staff, not
  residents):

  | Building | Basic / luxury | Infra | Effects |
  |---|---|---|---|
  | Slum Districts | 6 / 0 | 2 | +2% mortality, −0.2% migration; +10% flat mortality |
  | Tenement Districts | 7 / 0 | 1.5 | none |
  | Apartment Blocks (steel-frame tech) | 10 / 1 | 1 | none |
  | Luxury Apartments | 2.5 / 6 | 1.5 | +0.2% migration |
  | Suburban Estates | 2.5 / 6 | 2.5 | +0.3% migration; commuting inputs |
  | Temporary Shelter Programme (government-funded) | 4 / 0 | 1.5 | treasury wages, wood, fabric, tools |

- Suburb commuting: 0.6 horses, 0.5 transportation or 0.2 automobiles, tech-gated.
- Company housing PM group on 27 rural building types including Horse Ranches;
  No Housing is default and never gated. Work Camp (0.45 housing, 0.075 wood, 0.075
  fabric, +15% mortality; Unregulated), Work Town (0.45 housing, 0.15 wood,
  0.075 fabric, +7.5% mortality; Protected), Serviced Town (0.45 housing,
  0.15 wood, 0.15 fabric, 0.075 tools, no penalty; Mandatory Serviced Housing and
  Modern Sewerage).
- 0.02 basic housing per staffed level on all five subsistence building types.
- Employer Housing and Residential Standards law groups, with reform supporters
  and opponents attached additively to IGs. Enactment fallback to None plus
  monthly maintenance.
- Emergency Accommodation decree: 100 Authority, +15% basic output for all basic
  suppliers, +10% state mortality.
- Debug events `boi_housing.1` to `.5` (init laws, Alentejo fixture, permissive
  laws, protective laws, mandatory serviced housing). Since 2026-10-31 the headless harness runs `.2` to
  `.4` automatically as Portugal and checks the results (the `fixtures`
  telemetry module; see `docs/HOUSING_TESTING.md`, "Automated version").
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
The headless fixture checks cover the Alentejo fixture and the law-fallback
items automatically; the rest still need a hands-on game.
Highest-risk items:

- [ ] Loads without housing errors, unknown modifiers, bad scopes, missing icons
      or localisation.
- [ ] Unscaled slum mortality: gone at zero built levels, present at zero staffing, not
      applied for a queued building, does not stack per level.
- [ ] Work Camp and Work Town penalties hit only the employing building's pops (check
      dependants); law fallback runs on enactment and selects None before or
      after engine invalidation; conversions land on the permitted tier; No Housing survives.
- [ ] Alentejo fixture: +9 infrastructure demand (2 + 1.5 + 1.5 + 2.5 + 1.5), persists
      at zero staffing, released on demolition, no duplicates on re-run.
- [ ] Save/load, form/release a country, transfer a state: no reset laws or
      duplicate ideologies.

### Step 2: Infrastructure and redevelopment economics

- [ ] Confirm the redevelopment incentive is real. Output per infra point today:
      slum 3 basic; tenement about 4.7; apartment 10 basic + 1 luxury;
      luxury apartment 1.7 basic + 4 luxury; suburb 1 basic + 2.4 luxury plus
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

- [x] Build a reproducible seed (2026-11-01): generated by `tools/Build-Housing.ps1`
      from demand measured per state-owner (`tools/Get-HousingSeedDemand.py`). Company
      housing starts at None and must not hide missing stock.
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

## Interest group stances

Every interest group holds one housing stance. Each stance is its own ideology, attached by
`boi_housing_setup_effect`, so no vanilla ideology is changed.

| Interest group | Stance | Employer Housing: Unregulated / Protected / Mandated | Residential: Unregulated / Standards | Why |
| --- | --- | --- | --- | --- |
| Trade Unions, Intelligentsia | Housing Reform | Disapprove / Approve / Strongly approve | Disapprove / Approve | Tenants' interests and sanitary science |
| Landowners, Industrialists | Unregulated Housing | Approve / Disapprove / Strongly disapprove | Approve / Disapprove | They own the housing and pay for any rules |
| Devout | Moral Housing Reform | Disapprove / Approve / Neutral | Disapprove / Approve | Overcrowding as a moral danger; charity over a state mandate |
| Armed Forces | Fit Recruits | Neutral / Approve / Neutral | Disapprove / Approve | Bad housing makes sickly recruits |
| Rural Folk | Tied Cottages | Disapprove / Approve / Neutral | Neutral / Disapprove | Tied cottages are their grievance; by-laws outlaw the cheap cottage |
| Petty Bourgeoisie | Ratepayers' Interest | Disapprove / Approve / Disapprove | Approve / Disapprove | Small landlords and builders against by-laws and rates; shopkeepers against the company store |

**AI weights.** Each is +150. Protected: Trade Unions, Intelligentsia or Devout in government.
Mandated: Trade Unions or Intelligentsia in government. Standards: Trade Unions, Intelligentsia,
Devout or Armed Forces in government, and another +150 with Modern Sewerage.

**AI gates, which don't bind a person.** Standards waits for Urban Planning, so Regulated Terraces
exist before cheap housing is banned. Mandated waits for Modern Sewerage, so the law can't end a
country's company housing by accident.

## Provisional values

Every number, tech gate, building name and political stance in the housing
module is a test value. The point where luxury demand begins is a starting point, not
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
- **2026-10-31, headless, 1.13.11, 1836–1846, BOI with the fixtures module,
  observer AI** (`tools/headless-runs/20261031-104008_mod`). PASS, 0 BOI error
  lines. All 10 automated fixture checks passed: the Alentejo fixture built all
  five buildings and raised usage by exactly 32.0; a re-run added no levels;
  `boi_housing.3` and `.4` set their laws; hostile company housing on the
  livestock ranch reverted to None the day after `.4` (law `on_activate`) and
  stayed reverted after the next monthly pass; worker settlements on the
  logging camp survived; existing slums survived. Not covered: staffing,
  demolition, SoL and mortality effects, save/load.
- **2026-11-01, headless, 1.13.11, 1836 to 1837, BOI with the fixtures module,
  observer AI** (`tools/headless-runs/20261101-080233_mod`). PASS, 0 BOI error
  lines, 15 fixture checks passed. First run of the four tiers and Mandatory
  Serviced Housing. The protected law upgraded a Work Camp to a Work Town. The
  mandate gave No Housing without Modern Sewerage and a Serviced Town with it, and
  held through monthly maintenance. Laws were set with `activate_law`, so the normal
  enactment process, the Socialism unlock and the law's UI were not exercised. Not
  checked: whether AI owners keep the upgraded PMs. Alentejo's usage delta was 27
  in July against 32 in April; unexplained, and not investigated.
- **2026-11-01, headless, 1.13.11, 1836–1846, BOI with company housing output at 6
  on all three paying tiers, observer AI** (`tools/headless-runs/20261101-081325_mod`).
  PASS, 0 BOI error lines, 15 fixture checks passed. First count of tiers among
  major powers: Work Camp 65% of levels in 1836, 83% in 1845 (1,971 of 2,370); Work
  Town 10 levels; Serviced Town 0. Housing price fell from a national mean of 14.5 in
  1836 to the 7.5 floor by 1843. Sell orders stayed 2.9 times buy orders (3.7 times
  in the earlier run at 8). This corrects the 2026-10-30 entry above: company housing,
  not subsistence, appears to supply most of the surplus. SoL gap to the vanilla
  ensemble: -0.74 against -0.80 for the earlier BOI run, with all 11 shared powers
  still below vanilla. One run each, so read the small differences as noise.
  Austria lost 5 of 15 states in 1845, a revolution unrelated to this change.
- **2026-11-01, headless, 1.13.11, 1836–1846, BOI with the demand curve (0% Destitute,
  5% at the ceiling by the top of Struggling, 15% plateau from Lavish), stricter
  employer laws, and supply scaled to 0.45 per company level and 0.02 per subsistence
  level, observer AI** (`tools/headless-runs/20261101-085820_mod`). PASS, 0 BOI error
  lines, all 17 fixture checks passed, including law repeals. Across 11 powers demand
  rose from 3,376 to 3,901, against an estimate of 2,650. Supply went from 916 in 1836
  (27% of demand, prices near the ceiling) to 9,876 in 1845 (253%), passing demand
  around 1838–39. The growth came from residential buildings, whose output was not
  scaled. Across 12 majors: slums 5 to 23, tenements 2 to 16, suburbs 5 to 39, luxury
  apartments 1 to 15. Work Camp fell to 2% of levels in 1836 and 10% in 1845. In 1845,
  173 of 259 states were still at least 50% above base price despite the market-level
  surplus. SoL gap to vanilla -0.75, against -0.74 in the previous run, so basket cost
  and the Work Camp penalty look unlikely to be the main cause. Grain +8%, tools +11%
  and merchant marine +32% against vanilla remain to be tested. A European revolution
  wave hit in 1844–45: Britain lost 9 of 26 states and Austria 5 of 15. Excluding those
  two, GDP was £130.8M against vanilla's £128.5M. One run.
- **2026-11-01, headless, 1.13.11, SoL penalties replaced with mortality, no pollution**
  (`20261101-185641_mod`, `20261101-191216_mod`). Both crashed before 1856 at a
  telemetry-linked address. No British civil war by 1847 and 1849, against 4 of 5 games
  by 1846 before. Results are in [the proposal](04_SOL_TO_MORTALITY_PROPOSAL.md).
- **2026-11-01, headless, 1.13.11, 1836–1846, seed tuning, observer AI.** Residential
  buildings at a tenth of their old output, infrastructure scaled to match, and an
  1836 seed from measured per-state demand. Both runs PASS, 0 BOI error lines, all
  fixtures passed.
  - Attempt 1 (`20261101-095246_mod`), 882 levels: basic supply 0.78–0.80 of demand,
    luxury 0.65–0.71, population-weighted housing price about £36. SoL gap -0.64.
  - **Attempt 2, kept** (`20261101-100407_mod`), 1,046 levels: basic supply 0.84–0.89,
    luxury 0.91 falling to 0.80. Price held at £33–35. 15–17% of people live in states
    at £45 or more, and about 450 small states with 9% of people have no residential
    buildings and start short. Residential levels grew from 1,051 to 1,215. SoL gap
    -0.60, with 10 of 11 powers below vanilla. GDP -1.2% against vanilla, excluding
    Austria and the USA, which lost states to the mid-1840s revolution wave. Vanilla
    has such losses in 4 of 10 runs, with the same USA 39→27 and Austria 15→8 pattern;
    BOI has them in 3 of 6 ten-year runs. Infrastructure-short states among majors: 4
    against vanilla's 8.9, so housing's complication is price, not infrastructure.
- **2026-11-03, headless, 1.13.11, 1836-1936, housing tiers and road/rail split, observer AI**
  (`20261103-081447_mod`, `20261103-101832_mod`). Both PASS with 0 BOI error lines, fixtures off.
  All 15 types were built. Basic supply stayed at 0.93-1.03 of demand from 1866 to 1916, then fell
  to 0.79 / 0.89 by 1935, and luxury to 0.69 / 0.60. Municipal Estates were repeatedly wiped out.
  Residential Standards reached only 5 / 2 countries. Details are in the
  [century report](../reports/century_3_Nov_2026/REPORT.md).
- **2026-11-03, headless, 1.13.11, 1836-1866, housing law stances and AI weights, Municipal Estates
  `downsizeable = no`, observer AI** (`20261103-200327_mod`, `20261103-204330_mod`). Protected reached
  50 / 77 countries and Standards 18 / 12 by 1865, and all interest groups held a stance. Municipal
  Estates weren't tested, because none exist that early. Details are in the
  [balance log](../reports/balance_3_Nov_2026/BALANCE_LOG.md).
