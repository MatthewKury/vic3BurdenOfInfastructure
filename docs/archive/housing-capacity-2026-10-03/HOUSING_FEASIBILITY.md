# Housing Phase 1 feasibility record

Prepared 2026-10-03. **Prototype implemented; runtime feasibility gate still open.** The isolated [probe add-on](tools/housing-probe/README.md) contains the executable tests and run instructions. No production housing, world seed or vanilla override was added.

## Environment and evidence standard

Installed game directory inspected: `C:/Program Files (x86)/Steam/steamapps/common/Victoria 3/game`. The most recent existing `Victoria 3/logs/system.log` (2026-09-26) identifies **release/1.13.11**, revision `15aa89ae429b6bcff8d195f2a650f98ba95cd64c`, build timestamp 2026-08-18. That log predates this probe and cannot validate it. No generated script documentation was found in the inspected logs/dumps. No Victoria 3 process was running and no interactive game-control tool was available in this session; no live results or clean runtime logs are claimed.

All paths below are relative to the installed `game` directory. Local source examples establish candidates, not verified runtime scopes. The plan's exit requires observed results, especially payment reconciliation.

| Probe | Local evidence / implementation | Result so far |
| --- | --- | --- |
| Residents | `common/buildings/08_monuments.txt` uses `value = state_population`; probe copies this state-scoped numeric reader | Source-backed; actual count pending |
| Workforce/dependents | `common/trigger_localization/00_trigger_localization.txt` declares `workforce`, `dependents`, `total_size`; vanilla events use `every_scope_pop` | Probe iterates state pops and tries numeric reads into persistent state sums. Localization is not proof of arithmetic. Pending |
| Employed workers | `events/brazil/brazilian_slavery.txt` uses `is_employed`; `events/spanish_flu_events.txt` uses `state_unemployment_rate` | No exact per-pop employed-count arithmetic demonstrated. Probe explicitly estimates workforce times (1 - unemployment rate); partial/zero employment and workforce+dependents reconciliation pending |
| Workplace | Localized `pop_employment_building` and `pop_employment_building_group` triggers exist | No numeric workplace allocation implemented or proven; blocked for exact employment allocation |
| Monthly state storage | `common/on_actions/00_code_on_actions.txt:2038` declares `on_monthly_pulse_state`, with Root = State; BOI's existing additive events-list pattern retained | Probe has one-time global state selection, state variables, monthly counter, duplicate-delivery guard and half-gap synthetic fixture. Save/load and actual pulse timing pending |
| Building levels/staffing | `common/scripted_effects/00_victoria_scripted_effects.txt:2189` adds `prev.level` numerically; government administration uses `occupancy` in expansion triggers | One console-created residential test building; numeric level and occupancy samples pending |
| Maintenance support | Vanilla monuments and journal entries use `building_has_goods_shortage = yes` | Boolean shortage sample only. No verified numeric input-support fraction; condition remains independent fixed input |
| Devastation | State-scoped vanilla predicates compare devastation with fractional thresholds in `common/script_values/cultural_community_values.txt` | Numeric read and 0-1 scale still pending. Formula clamps damage; physical levels remain separate |
| Household payments | Inspected `common/effect_localization/00_pop_effects_loc.txt`, `common/modifier_type_definitions/00_modifier_types.txt`, and existing BOI road-financing implementation | **Blocked/unproven.** Wealth effects, strata SoL effects, general consumption changes or treasury expenses do not establish a selected household-to-provider transfer. No fabricated receipts or wealth grants implemented |
| Public coverage | Government-funded parent group in `common/building_groups/00_building_groups.txt`; BOI Public Works cost-centre pattern | Test accommodation has real wage/material definitions. Budget expense pending observation; actual occupied provision and private reimbursement remain unproven |
| Presentation | Vanilla state event scope/localization and `MakeScope.Var(...).GetValue` patterns | Snapshot event and dated diagnostic logging implemented. State link/tooltip and navigation pending; no claim of a completed alert or state-panel UI |

## Economic feasibility decision

The requested full rent model is not yet demonstrated. Adding a local housing good would establish ordinary supply and demand only after a separate goods/needs prototype; it would not by itself establish eligibility-specific charges or law-dependent exemptions. Altering wealth or applying SoL modifiers is not an acceptable payment substitute. The debug building tests the concrete government-operation alternative: wages and materials purchased by the treasury. It has no private revenue and is not rent reimbursement.

The probe deliberately does not label capacity as occupied accommodation. Connecting public expenses to actual occupied places requires verified population allocation plus an operating rule; both remain open. Do not advance to full economic integration on the basis of these definitions alone.

## Runtime results to complete

| Observation | Expected comparison | Actual / new log evidence |
| --- | --- | --- |
| Initial / repeated start | Same owned state, counter 0, fixture 100000 | Not run |
| Monthly pulses 1 / 2 / 3 | 90000 / 85000 / 82500; counter increments once | Not run |
| Save/load, capital move, ownership transfer | No reinitialization, duplicate pass or retargeting | Not run |
| Residents / workforce / dependents | Match population panel; sums reconcile | Not run |
| Full / partial / zero workforce and employment | Estimate checked against observed counts; limitations recorded | Not run |
| Building levels / staffing / shortage | Match building panel | Not run |
| 0 / 25 / 100% damage | 1000 / 750 / 0 illustrative capacity at condition 1 | Not run |
| Government wages/materials | Actual purchases and treasury expense visible | Not run |
| Occupied public places | Traceable provision for actual recipients | Unimplemented/unproven |
| Law/scarcity rent change | Correct household debit equals provider credit | Blocked/unproven |
| Report link / state tooltip / logs | Correct state and readable values, no new script errors | Not run |

Static arithmetic tests and existing mod checks can validate the delivered files; they cannot fill the actual-observation column. Phase 1 remains open until the runtime checklist is performed and the supported/approximate/blocked decisions are backed by those observations.

Static validation on 2026-10-03 passed: probe arithmetic expectations, BOM/brace checks for 55 script/localization files, seed counts, horse land/ownership safety audit, and all 31 existing BOI shadow-key source checks. No seed data or production definitions changed. The optional saved-input reproducibility check was not run.
