# Housing implementation plan

Prepared: 2026-10-03

Status: Phase 1's isolated debug probe is implemented; live engine verification and the feasibility exit gate remain pending. See the [feasibility record](HOUSING_FEASIBILITY.md) and [probe instructions](tools/housing-probe/README.md). No production housing mechanics have been enabled. Design source: [PROPOSAL_HOUSING.md](PROPOSAL_HOUSING.md). Where this plan recommends a default for an unresolved choice, it is a prototype assumption rather than an agreed final rule.

## Intended result

Residential buildings provide maintained rural or urban person-capacity. Actual employment claims accommodation for workers and their allocated dependents without employers buying a Housing good. Poor Laws cover a configurable share of unemployed residents at government expense. When current employment and welfare eligibility falls below the actual housed count, half the remaining gap loses housing each month. Housing laws and local scarcity determine household costs through a payment mechanism that must first be demonstrated in the engine.

Both Emergency Accommodation and Temporary Shelter Programme remain required parts of the planned feature. Tenure transfers, commuting, industrial districts, and a dedicated housing dashboard follow the core feature and are not prerequisites for its first playable prototype.

## Phase 1: establish engine support in one state

Create an isolated debug prototype before changing production buildings or seeding the world. Record the installed game version, exact working scopes, script examples, observed values, and log results in a housing feasibility report.

| Probe | Required evidence | If it fails |
| --- | --- | --- |
| Population accounting | Read numeric residents, workforce, employed workers, and dependents; identify their state and, ideally, workplace. Check partial employment and zero workers. | Try a state/profession aggregate allocation and label it as estimated. Trigger names alone are not proof that arithmetic works. |
| Persistent state accounting | Store and update housing counts once per month, persist across save/load, and initialize only once. | Find a verified event schedule before building the monthly system. |
| Physical capacity | Read residential levels, maintenance staffing/support, and devastation numerically. | Simplify the maintenance prototype to verified inputs; retain separate stock and condition. |
| Household payments | A law/scarcity change alters the intended housed pops' expenditure and produces matching provider receipts without employer purchases or invented wealth. | Report the full rent model as blocked. A capacity-only demonstrator can continue, but cannot stand in for the requested payment system. |
| Public coverage | Support actual occupied places with a traceable treasury expense and corresponding accommodation provision. Verify private-provider receipts if using reimbursement. | Test government-operated accommodation with real wages/material costs. Do not describe this as private-rent reimbursement. |
| Presentation | Read the custom totals in state tooltips and open the correct state from an alert. | Use a simpler verified state presentation before attempting a dashboard. |

Inspect local scripts and generated script documentation where available, then verify with a live debug game. A localized trigger name, a modifier declaration, or a clean static check does not establish runtime behavior. Confirm a monthly hook rather than assuming its name. Follow the existing BOI additive `events = { }` on-action pattern; do not replace vanilla on-action effects.

Exit: a written feasibility result identifies which parts are supported and which require an approximation or a design decision. Investigate payments in this phase even though full law integration comes later.

## Phase 2: define and verify the monthly accounts

Use one unit: capacity for one person. Keep two accounts per owned state, rural and urban, rather than a single account per map region. Split states must not share capacity across country owners.

For each pool maintain or derive:

| Value | Meaning |
| --- | --- |
| Population | All residents assigned to this pool, including unemployed residents and dependents |
| Physical stock, condition, usable capacity | Homes constructed, their maintenance condition, and places available after condition and damage |
| Employment claim | Employed workers plus their allocated dependents |
| Unemployed group | Unemployed workers plus their allocated dependents |
| Public claim | Policy-covered share of the eligible unemployed group |
| Current target | Employment claim plus public claim, bounded by eligible population |
| Actual housed | Residents currently occupying adequate housing, including temporary retention after losing eligibility |
| Retained occupation | Actual housed above the current target while the monthly loss rule operates |
| Sheltered / unsheltered | Residents outside adequate housing, divided by actual emergency accommodation allocation |
| Actual public occupancy | Publicly funded occupied places; the payment base, which can be smaller than the public claim |
| Crisis state | Severity and consecutive entry/recovery months |

Prefer observed pop counts over legal workforce-ratio assumptions. If per-pop workforce `W`, dependents `D`, and employed workers `E` are available, a possible aggregate allocation is `E * (1 + D / W)` to employment and `(W - E) * (1 + D / W)` to unemployment. This partitions the same population once and does not assign every dependent to partially employed workers. Handle `W = 0` separately. Assign residents that do not fit these categories explicitly; do not silently lose them from the totals.

This is a population allocation, not observed families or addresses. Do not promise to identify a particular unemployed adult's employed spouse. If workplace links are unavailable, distribute the employment account using verified employment shares. Classify subsistence, farms/ranches, extraction, manufacturing, services, government, military, and residential staff explicitly. Mining settlements require a deliberate rural/urban rule.

Monthly order:

1. Read current population and reconcile previous occupants for deaths, migration, state ownership changes, and rural/urban transfers. Departed residents do not remain as retained occupants. Avoid duplicate monthly processing after a transfer.
2. Update condition and damage, then calculate usable physical capacity. Cap the reconciled previous housed count by current population and usable capacity; physical displacement is recorded immediately.
3. Calculate employment and public claims from current counts and law/institution settings. Clamp the public coverage fraction to 0-100%; count each resident once.
4. Apply the housing-loss rule against the reconciled previous *actual housed* count, not the previous month's eligibility target:

   ```text
   if target < previous_housed:
       desired_housed = previous_housed - 0.5 * (previous_housed - target)
   else:
       desired_housed = target

   housed = min(desired_housed, usable_capacity, population)
   ```

5. Allocate actual housed between employment, public coverage, and retained occupants. Suggested prototype rule: current eligible claims take priority over retention; if current claims exceed capacity, allocate proportionally between employment and public claims. Final allocation priority remains a policy choice.
6. Allocate emergency shelter only among residents outside adequate housing; calculate remaining unsheltered residents. Apply verified payments to actual occupants, then update alerts and effects.

Reconcile population changes conservatively; if exact occupant migration is unavailable, document the allocation approximation. Use persistent fractional counts or an explicit rounding rule, with a final snap when a remaining gap is below one person. Never process the half-gap loss twice in a month.

Exit: population equals adequately housed plus sheltered plus unsheltered, with no duplicate dependent or welfare allocation. At fixed capacity and population, a target drop from 100,000 to 80,000 produces 90,000, 85,000, and 82,500 housed after successive months. A recovery to a higher target raises occupancy at the next monthly calculation, subject to physical capacity.

## Phase 3: add residential stock and maintenance

Add Rural Housing and Urban Housing in a separate residential building group. Reuse the Public Works pattern for the government-funded prototype: real wages, maintenance inputs, and an explicit cost centre. This prototype establishes capacity behavior; private financing requires Phase 1's payment proof and Phase 4's economic implementation.

Start with one construction form per pool. Building levels create stock; a monthly condition value controls its usability. Understaffing or input shortages reduce condition gradually, and restored support allows recovery. Do not make stock disappear with workforce-scaled output or grant free new stock on a production-method switch. Add denser forms only with a verified construction or conversion cost.

Prototype the proposal's devastation factor, after verifying its numeric scale, and audit overlap with devastation's effects on staffing/supplies. Preserve levels during damage. Set residential urbanization and infrastructure demand explicitly after inspecting inheritance; avoid inheriting unintended Public Works behavior or using homes to create a self-amplifying urbanization loop. Prefer custom definitions over new full-file vanilla overrides.

Exit: construction increases capacity, layoffs of maintenance workers do not instantly demolish homes, input recovery restores condition, and damage limits occupancy. Material consumption and government expenses are visible.

## Phase 4: integrate Poor Laws and household costs

Read existing welfare laws and Social Security investment through the verified hooks. Keep housing coverage coefficients in one tuning location. Define coverage for every welfare law, including special variants, rather than allowing an unhandled law to reset coverage unexpectedly. Use test fixtures such as 0%, 50%, and 100% to prove the accounting; choose balance values afterward.

Government support must be charged for actual provided accommodation, not simply the number entitled. A change from employment coverage to public coverage transfers responsibility without creating another housing claim. Funding loss lowers the current target and triggers the half-gap rule; it does not demolish homes.

Implement household payments only through the mechanism established in Phase 1. Separate physical occupation from payment policy. Test at least a rental arrangement and publicly supported occupation, with scarcity-sensitive charges and matching receipts. Define which ratio drives rent, its lower/upper bounds, and its adjustment speed. Display physical need separately from paying demand: vacant homes and unemployed people without eligibility may coexist.

Before this phase is complete, settle how temporarily retained occupants pay after job loss and how to avoid counting the same upkeep expense through rent, household consumption, and a government maintenance subsidy. Do not infer that a housing good automatically supports law-dependent exemptions, or substitute SoL changes for actual money flows.

Resident ownership and cooperatives remain later extensions, subject to the proposal's tenure accounting tests. If verified payment support cannot deliver the requested core behavior, report the specific limitation and present concrete alternatives before treating any reduced model as the completed feature.

Exit: a fixed-stock example proves employment, public coverage, and temporary retention each have one housing claim and the intended payer; changing scarcity or law changes the correct expenditure and receipts.

## Phase 5: add both emergency responses and clear feedback

Implement Emergency Accommodation as the proposed Authority-backed decree that permits temporary crowding, and Temporary Shelter Programme through verified government material/staff expenditure. Neither creates permanent stock. Define setup time, simultaneous operation, combined limits, and removal behavior. Shelter capacity derives from its own valid source; bonuses must not amplify each other.

Show rural and urban stock, usable places, current target, actual housed, Poor Laws claims/actual provision, retained occupants, sheltered, and unsheltered residents. Distinguish physical shortage from lost eligibility. Keep adequate housing and emergency shelter separate in alerts and penalties.

Use the proposal's sustained severity bands and recovery hysteresis as starting assumptions. Notify on transitions rather than each monthly update. Test that relief improves outcomes after all decree and residual crisis penalties are combined. Add gradual SoL/migration effects only after counters and explanations are correct.

Exit: both responses visibly shelter residents, have their stated costs, end without duplicating or erasing stock, and navigate to the relevant state from alerts.

## Phase 6: seed 1836 and support AI

Extend the reproducible seed workflow with a separate population-based housing audit and output. Seed rural and urban stock by owned state, including subsistence settlements. Do not derive homes solely from subsistence levels or seed full regional capacity once for every owner. Review population and employment availability at initialization before choosing history-generated buildings versus one-time setup effects.

Recommended opening assumption: seed sufficient physical stock and initialize existing residents as housed; current employment and laws then determine the target, with the half-gap transition governing later loss. Document that this can still produce policy-driven homelessness in 1836. Review affected states before enabling world-wide consequences. Initialization must never regenerate free stock on load or conquest.

Adapt BOI's urgency-based AI pattern for physical shortages, with budget, construction-queue, and maintenance-staffing checks. Do not build more empty homes merely because residents lack eligibility. Add AI use/removal of emergency measures and test affordability of public coverage. Avoid blindly copying a 90% staffing gate if housing shortages themselves prevent recovery; test the feedback first.

Release the initial prototype for new campaigns. Existing-save conversion requires a separately verified initialization path. Handle conquest, releases, split states, and population transfers without duplicate stock or subsidies.

Exit: deterministic seed output, reviewed opening housing/budget balances, and AI intervention for the appropriate cause without runaway building or emergency spending.

## Planned files and integration points

Names below are proposed locations, not existing implementations.

| Area | Planned work |
| --- | --- |
| Definitions | New `common/buildings/50_boi_housing.txt`, housing building group, production methods and PM groups |
| Calculations | New housing `script_values`, `scripted_effects`, and verified triggers; persistent state variables for history-dependent counts |
| Scheduling | Housing events and an additive monthly on-action hook; one-time initialization patterned after BOI setup |
| Policy | Housing coverage reads existing welfare law/institution status; add payment-law definitions only after feasibility is established |
| Feedback | Housing modifiers, alerts/messages, decree definitions, and English localization |
| Seeding | Housing audit/generator and separate generated building history integrated with `Regenerate-WorldSeed.ps1` |
| Validation | Housing scenario checks and manual debug-game checklist alongside `tools/Validate-All.ps1` |

Avoid adding a housing input to every vanilla production method if employment can be enumerated directly. Reuse the mod's existing validation and seed conventions. Review any unavoidable vanilla shadows against the installed game version and document their compatibility cost.

## Verification and delivery milestones

Run existing static structure, seed, and shadow checks after relevant script changes. Add meaningful housing arithmetic/scenario tests, then compare their expected results to actual debug-game values. Static tests do not prove engine support.

Required scenarios: full/partial/zero employment; different dependent ratios; no workforce; workforce participation changes at fixed population; layoffs and rapid rehiring; 0/50/100% public coverage; sudden benefit cuts; physical damage below retained occupancy; rural/urban shifts; empty states; migration and conquest; both shelters together; save/load without duplicate processing; and household/provider/treasury payment reconciliation.

Before release, run a small-state campaign plus a large-population and multi-state AI campaign. Measure monthly calculation time, staffing recovery, construction, rent/support costs, alert transitions, and world initialization. Cache state totals after a monthly pass; avoid population iteration on every tooltip draw. Broaden long-campaign balance testing only after core results pass.

1. **Feasibility report:** evidence for counts, scheduling, physical data, payments, and UI; explicit blockers and tested alternatives.
2. **First playable prototype:** one state with rural/urban stock, employment/dependent accounting, Poor Laws targets, visible costs where verified, and monthly half-gap loss. Debug presentation is sufficient; any unsupported payment behavior remains visibly incomplete.
3. **Integrated feature:** verified household and public financing, both emergency responses, alerts, reproducible 1836 seed, and AI support.
4. **Later extensions:** tenure transfers, commuter access, denser conversion programmes, industrial districts, and a richer housing dashboard after separate validation.

Phase 1 determines feasibility, not permission to silently replace the requested model. The first playable prototype is a milestone; the integrated feature is the completion target for the current housing design.
