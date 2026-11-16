# Public Works hub: implementation plan

> **Status (end of 2026-11-13):** phases 1–7 built on branch `script-update` (uncommitted).
> - Three 10-year games were run, as the user allowed. Results and open questions are in
>   [the balance log](../reports/public_works_13_Nov_2026/BALANCE_LOG.md).
> - Settings left in the mod: CAP 10, inputs ×1.5 over the table below, shortage factor 0.8.
> - Not yet updated: the optional `checks` and `rail_survey` telemetry modules, which still
>   reference the retired works.

Written 2026-11-13, after plan 10's script tests, from the settled design in
[11_PUBLIC_WORKS_HUB_DESIGN.md](11_PUBLIC_WORKS_HUB_DESIGN.md) parts 13–14. Engine facts
cited here were verified on 1.15.1 that day and are recorded in `VIC3_MODDING_LESSONS.md`
(probe runs `20261113-111013_mod` and `20261113-111539_mod`).

## What the tests changed in the design

| Design point | Test result | Consequence |
|---|---|---|
| Jobs scale slowly by script modifier | A script-added `building_employment_*_add` **does nothing** | Use the user's fallback: each level maintains up to a fixed amount of use, and script raises the level (`create_building` raises to a level; verified) |
| Goods follow use by script modifier | `building_goods_input_mult` via `add_modifier` works within 2 days | Keep it, as a trim inside the current level |
| Penalty on all infrastructure | `state_infrastructure_mult` **misses the population floor**; adding `state_infrastructure_from_population_mult` gives exactly −30% | The penalty carries both keys |
| Penalty from day one | `INJECT:` into `incorporated_state` / `unincorporated_state` works | No script needed for the penalty |
| Cancellation fails when inputs fail | Shortages cut workforce-scaled modifiers (about half) but not `unscaled` ones | With levels changing, a PM modifier would scale with the level count, so a monthly script applies the cancellation instead, from occupancy and `building_has_goods_shortage` |
| AI picks Mode on cost | `most_profitable` on a building that sells nothing moves to the cheaper PM (6–16 months) | As agreed |
| Base discount | The floor computes exactly from `modifier:` reads | Chargeable use = usage − floor, by script |
| Urban horse option | Injected PM spread through French, Russian and Prussian urban centres within 2 years | Ship it as designed; watch its size |

No question in this plan needs the user's decision before a first build. The numbers are
first guesses, to be tuned in at most three 10-year games.

## Mechanics

**Penalty (static, day one).** `INJECT:incorporated_state` adds
`state_infrastructure_mult = -0.3` and `state_infrastructure_from_population_mult = -0.3`;
`INJECT:unincorporated_state` adds −0.1 / −0.1.

**Upkeep (script, monthly, per state).** Three static modifiers on the state:
- `boi_network_upkeep` (+0.3 / +0.3), or `boi_network_upkeep_uninc` (+0.1 / +0.1), applied
  with `multiplier = m`, where:
  - m = Public Works occupancy (in 0.05 bands);
  - × 0.8 if `building_has_goods_shortage` (0.6 until a sanity run before game 1; see the balance log).
- `boi_network_mode_bonus` (`state_infrastructure_mult` +0.01) with
  `multiplier = bonus% × m`, from the active Mode and Harbour PMs.

So a fully staffed, supplied Public Works cancels the penalty. A growing state whose new
level hasn't hired yet, or one short of goods, carries part of it: the intended growing
pains.

**Chargeable use** = max(0, `infrastructure_usage` − floor), where floor =
min(pop / 125,000 × `modifier:…from_population_add` × (1 + `…_population_mult`),
`modifier:…_max_add`).
- The floor is computed without the penalty's own −0.3. The base is meant to be free, so
  the penalty's effect on the floor isn't charged for.

**Levels.** level target = max(1, ceil(chargeable / CAP)), CAP = 20 use per level. Script
raises the level when the target exceeds it. It never lowers it (no effect exists). New
levels open new jobs and hire over weeks.

**Goods trim.** Inputs are per level in the PMs. Each month, script sets one building
modifier, `boi_pw_goods_trim` (`building_goods_input_mult = -0.01`), with
`multiplier = 100 × (1 − fraction)`.
- fraction = chargeable ÷ (levels × CAP) × (1 − survey discount), floored at 0.05.
- So a building sized for 60 but carrying 45 buys 75%.
- The Financing PMs' own `building_goods_input_mult` (Road Fund −0.25, Tolls −0.5) adds to
  this rather than compounding. The script multiplies the trim by (1 + law discount) to keep
  them proportional.

**Survey.** Each completed rail survey adds 5–10% (by quality) to a state variable
`boi_pw_survey_discount`, capped at 30%. It needs the railways technology, as now. The
1/2/4 Rail Works cap and its modifiers are retired.

## Buildings and PM groups

Both buildings:
- group `bg_boi_public_works` (government-funded), now with the logistics-centre settings:
  `ignores_productivity_when_hiring = yes`, `fired_pops_become_radical = no`,
  `should_auto_expand = { always = no }`;
- `buildable = no`, `expandable = no`, `downsizeable = no`, `ownership_type = no_ownership`.

`building_boi_public_works` (`potential = { is_coastal = no }`, city model of Road Works) and
`building_boi_coastal_public_works` (`is_coastal = yes`, port model of Harbour Works).

| Group | PMs (per level; first pass) | Bonus |
|---|---|---|
| Mode `pmg_boi_pw_mode` (default AI = cheapest) | Cart Roads: 4 horses, 200 labourers (£120) · Macadam Roads (mechanical_tools): 4 horses, 2 tools (£200) · Rail-Fed Network (railways): 4 transportation, 1 iron (£160) · Steel Rail Network (steel_railway_cars): 5 transportation, 1 steel (£200) · Motor Roads (combustion_engine): 1 automobile, 1 oil, 1 horse · Highways (existing late tech): 1 automobile, 2 oil, 1 steel | 0 / 3 / 5 / 8 / 10 / 15% |
| Administration `pmg_boi_road_administration` | carried over (follows the bureaucracy law) | — |
| Financing `pmg_boi_road_financing` | carried over (follows the road-financing law) | — |
| Harbour `pmg_boi_pw_harbour` (coastal only; cheapest) | Coastal Lighters: 0.5 clippers · Steam Lighters (steamers tech): 0.5 steamers, 1 coal · Electrified Quays (electricity tech): 2 electricity, 0.5 steel | 2 / 4 / 6% |

Jobs per level shrink as modes modernise, as the Road Works' ladder does now.

## Phases

1. **Revert railways and ports to vanilla.** Delete `00_boi_rail_port_overrides.txt` and
   `00_boi_railway_ai_override.txt`. "Duplicated key" lines go to 0.
2. **The hub.**
   - New buildings, PMs, groups, static modifiers, localisation.
   - `INJECT:` penalty.
   - Monthly script in `events/boi_public_works_events.txt` (country pulse, every state).
   - Script values.
   - Placement for states without a hub: release, conquest, new states.
3. **Seed.** Every state gets a staffed level-1 hub through history. Levels for big
   cities: a short measurement run logs each state's 1836 target level, and a generator
   writes `common/history/buildings/zz_boi_public_works_seed_generated.txt`. Unmeasured
   states start at 1.
4. **Retire the three works:**
   - Road, Rail and Harbour Works buildings and PMs, their seed, map models and AI events;
   - the rail survey cap, which becomes the discount;
   - the surplus event and phase-2 road-financing references move to the hub.
5. **Urban option.** `INJECT:pmg_public_transport` adds Cab Ranks and Carting (3 horses →
   5 transportation, +3 infrastructure per level, workforce-scaled).
6. **Tools and telemetry:**
   - `Build-CityTypes.py`;
   - seed checks in `Test-Seed.ps1`;
   - the telemetry `boi` module (hub levels, occupancy, upkeep m, chargeable use, bill);
   - Validate-All passing.
7. **Test, at most three 10-year games** (1836–1846), iterating between them.
   - Compare with the vanilla 1846 baseline (`tools/ensembles`) and the last BOI runs.
   - Measures: world and British GDP; states short of infrastructure and market access;
     railway levels; steel; the hub bill against government spending; the AI's Mode choices
     and cab adoption.
   - Log in `docs/reports/public_works_13_Nov_2026/BALANCE_LOG.md`.

## Risks to watch

- **Script cost.** One monthly pass over every state of every country. LLWA does the same.
  If needed, stagger by country pulse.
- **Hub bill too high or too low.** CAP and the per-level inputs are the dials.
- **The cab option is too strong.** It's +3 per urban-centre level everywhere it spreads,
  and its own dial.
- **Railways at vanilla strength** may make the penalty trivial in rail states. The dial is
  the penalty size; the user set 30% and 10%.
- **The telemetry crash** linked to the yearly all-state module (lessons file). Run with
  `-LongRun` if 10-year games crash.

## Where to pick up (recorded 2026-11-13)

**State of the branch.** Everything is on `script-update` and uncommitted: plan 10's
INJECT/REPLACE conversion, and the hub. `tools/Validate-All.ps1` passes, and all test games
ran with no BOI error lines and 0 "Duplicated key" lines.

**Results:** three 10-year games, `boi_pw_g1`–`g3` in `tools/ensembles/ensembles.sqlite`,
compared with `vanilla115_1836_1936_all` and the old design (`steel_iter3`). Full tables in
[the balance log](../reports/public_works_13_Nov_2026/BALANCE_LOG.md).
- World GDP 9–11% below vanilla, inside the 5–15% target band.
- Railways +10–14% against vanilla (old design −10%); construction −10 to −14% (old −27%);
  transportation +9%.
- About 130 states short of infrastructure (vanilla 31), by small margins; world market
  access −0.5%.
- The hub bill is about 2% of Britain's spending. Raising its cost (CAP 20 → 10, then
  inputs ×1.5) barely moved the totals. The friction comes from the penalty and from
  staffing and supply.
- Countries in debt 24–28% below vanilla in every game.
- **Steel fell in every game: −8, −17, −22%,** with engines and iron down. This is the main
  regression.

**Decisions waiting for the user:**
1. **Steel:** give the cheap early Modes a small steel or engines input (as Steam-Rolled
   Roads had), or make the rail Modes win sooner, or accept it?
2. **Free base:** chargeable use shrinks over 1836–46 as the population floor grows. Keep
   the whole floor free, or make only part of it free so the bill grows with the economy?
3. **Debt:** fewer indebted countries than vanilla. Acceptable, or should the hub cost
   more?
4. **Cab option:** add telemetry for its adoption in long games (the 1836–38 probe showed
   wide AI uptake).

**Housekeeping still to do:**
- Update the optional `checks` and `rail_survey` telemetry modules, which still reference the
  retired works.
- Refresh `README.md`'s description and `BALANCE.md`, which still describe Road, Rail and
  Harbour Works.
- Decide whether to commit plan 10 and plan 12 as separate commits.
- The ensemble database is 2.1 GB.
