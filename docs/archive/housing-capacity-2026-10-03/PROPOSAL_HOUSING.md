# Housing capacity, crises, and tenure proposal

Saved: 2026-10-02. Employment-linked occupancy direction added 2026-10-03.

Status: Deferred design for later investigation. No housing mechanics have been implemented. Saving this proposal does not authorize implementation or settle the unresolved design choices.

Proposed delivery sequence and acceptance checks: [Housing implementation plan](IMPLEMENTATION_PLAN_HOUSING.md).

## Objective

Represent local housing supply and the support costs of population growth and industrialization. The current design direction is maintained rural and urban housing capacity, similar to Public Works. Occupied jobs claim capacity for their workers and associated dependents; Poor Laws can fund housing for a share of those who lose employment. Housing laws and local scarcity could determine what housed pops pay. Crisis alerts and both emergency accommodation options remain in scope. Capacity and eligibility can be prototyped before household payment and ownership accounting are solved.

The earlier tenure proposal is retained below as a separate, unresolved extension. Housing laws could govern residential ownership independently of industrial ownership, subject to explicit compatibility rules with national economic laws. A capacity-only version must not claim to simulate rents or household property ownership.

## Current direction: maintained housing capacity

Construction creates homes; maintenance keeps them usable; residents occupy them. Residential buildings consume goods and employ maintenance workers to support accommodation capacity, much as Public Works consumes inputs to support infrastructure.

- Separate physical stock from maintenance condition. Brief understaffing should not instantly erase homes; deterioration and recovery should be gradual if modeled.
- Production methods could change density, upkeep, and capacity. Higher density should carry an investment or operating tradeoff; changing a method should not grant unlimited free housing.
- Every resident counts in potential housing need, including dependents and unemployed residents. Employment and welfare determine eligibility for adequate housing; they do not create or destroy people or physical homes.
- Seed existing settlements in 1836, including rural accommodation. Moving workers out of subsistence employment must not automatically demolish their homes.
- A Public Works-style financing model puts wages and maintenance inputs on the treasury. Private financing remains a separate problem.
- Infrastructure is a native engine capacity; housing would require custom calculations and effects. A modifier named housing supply does not automatically provide native housing behavior.
- Adequate housing capacity and emergency shelter capacity must be tracked separately.

This direction supersedes the requirement to solve tenure accounting before any housing prototype. The local Housing good described later remains an alternative economic design, not an automatic additional charge on top of capacity-based housing. Workplaces claim capacity rather than buy a Housing good; housed pops would bear any verified household payment under housing law, while government-supported residents would be funded by the treasury.

## Rural and urban housing

Maintain two accommodation pools per state:

| Pool | Represents | Expansion and upkeep direction |
| --- | --- | --- |
| Rural housing | Farmsteads, cottages, and villages | Low density; relatively inexpensive expansion; mainly wood and modest tool inputs. |
| Urban housing | Town houses, tenements, and apartments | More construction-intensive; denser methods; wood, tools, glass, and later advanced materials. |

Estimate settlement demand from employment as a proxy: agricultural and extraction work generally contributes to rural demand, manufacturing and urban services to urban demand. Mining towns and other exceptions need explicit treatment. Assign dependents and unemployed residents to a pool, and ensure rural plus urban potential need accounts for the entire resident population without duplication.

The game does not supply a verified household-address system for this design. Residence estimates should shift gradually as employment changes, rather than instantly moving all workers between housing pools. Spare rural housing may coexist with urban overcrowding.

A later, limited commuting allowance could let transport connections make some rural accommodation accessible to urban workers. Technology and investment could improve it. Spare infrastructure alone is not a measure of commuting access, and rural capacity must not be usable everywhere in the state without limits. Any crossover must avoid counting the same accommodation in both pools.

Choose one consistent capacity unit during prototyping. The earlier tenure example uses household-equivalents; the crisis and emergency examples below use person-capacity. They cannot be mixed without an explicit conversion.

## Employment-linked occupancy and Poor Laws

The proposed policy ties access to adequate housing to an occupied job. A staffed production building claims housing capacity for its actual workers and their associated dependents; an unstaffed building claims none. This is an occupancy account, not an input good or a purchase by the employer. Housed pops would pay rent or upkeep according to housing law and local scarcity. The exact payment mechanism remains unverified.

For a worker population with known dependents, use person-capacity and the dynamic relation `housing claim = employed workers * (1 + associated dependents / employed workers)`. This equals employed workers plus associated dependents. A fixed number of homes per worker would miscount when workforce participation changes. Avoid division by zero when a group has no employed workers. Installed game files name `workforce`, `dependents`, and `total_size` triggers and contain profession- and law-dependent working-adult ratios; they do not establish that those values can be read in the required scopes and applied to a building's housing claim. Prototype this before promising per-building precision.

No verified household-address system identifies which dependents share a worker's home. Allocate each dependent once, including when multiple adults work. A resident entering employment transfers between occupancy accounts rather than creating a second housing requirement. Subsistence, government, military, and housing-maintenance employment need explicit classification so their residents are not omitted. Residents without an employment-linked claim remain in potential need.

Under the proposed strict employment rule, unemployed residents and their assigned dependents have no *current* job-based entitlement, even if homes stand vacant. A Poor Laws housing benefit would cover a configurable share of that group with adequate accommodation paid for by the government. Existing `law_poor_laws` uses the Social Security institution, whose investment level is a possible policy scale; the coverage rate, eligibility across other welfare laws, and payment route remain design and engine-test questions. Government coverage is limited by available usable housing. Someone outside the covered share is unhoused by policy, distinct from someone covered by law but unable to find physical capacity.

Count each person in exactly one current entitlement target: employed and associated dependents, government-covered unemployed and associated dependents, or ineligible. If both an employed member and a welfare-eligible member are present in an estimated household, employment takes precedence; welfare must not claim a second home. How to approximate this without household links needs testing. Keep target entitlement, actual housed residents, emergency shelter, and physical capacity as separate state values in each rural or urban pool.

### Monthly loss of housing after eligibility falls

At each monthly update, recompute the entitlement target from current employment and welfare coverage. If the target falls below last month's *actual housed* count, only half the gap loses adequate housing that month:

`new housed = previous housed - 0.5 * (previous housed - target)` when `target < previous housed`.

If the target rises, accommodate newly eligible residents up to available usable capacity; do not use the half-gap delay for gains. For example, 100,000 housed residents and a new target of 80,000 yield 90,000 housed after one month, 85,000 after two, and 82,500 after three if the target stays fixed. The difference between current entitlement and actual housed represents temporary retention after job loss, not a newly funded Poor Laws benefit. Decide who bears its cost before implementing household payments. Keep enough precision or a defined rounding rule so small gaps eventually close.

Apply the adjustment separately by rural and urban pool. It may slow loss of eligibility, but it cannot preserve adequate housing above physically usable capacity after devastation or maintenance failure. Reconcile actual housed against physical capacity first; move any excess to emergency shelter or unhoused status. Transfers between jobs, unemployment, and Poor Laws must not duplicate housing claims. Test layoffs, rapid rehiring, welfare-law changes, migration, and cross-pool moves for accounting stability.

These mechanics are a new design direction, not implemented or validated gameplay. The social consequences of immediate ineligibility, residual tenure during the half-gap transition, and the exact government payment to housing providers remain unresolved.

## Housing crises and alerts

Calculate coverage separately for rural and urban housing:

`Adequate housing coverage = usable adequate capacity / corresponding population requirement`

This measures the physical shortage against all residents' potential need. Show employment eligibility and Poor Laws coverage separately: enough vacant homes can coexist with people unhoused because they lack an entitlement. Conversely, people may be entitled but unhoused because capacity is missing. Crisis and alert rules need to distinguish these causes; the physical coverage thresholds below must not be presented as a complete unemployment or eviction measure.

Initial testing thresholds only:

| Status | Sustained condition | Presentation |
| --- | --- | --- |
| Housing Pressure | Coverage below 95% for three months | State warning. |
| Overcrowding | Coverage below 85% for three months | Persistent alert and state modifier. |
| Housing Crisis | Coverage below 70% for three months | Prominent alert and onset notification. |

Apply the highest applicable severity rather than all three penalty tiers at once. A capacity deficit represents inadequate accommodation, not an exact count of people sleeping outdoors. Crowding and informal shelter are part of the abstraction.

Track duration and use separate recovery thresholds to prevent flicker. For example, a crisis entered below 70% could clear after coverage stays above 80% for three months; a lower severity may remain. Define the complete transition rules in the prototype.

- Distinguish Rural Housing Crisis and Urban Housing Crisis.
- Show capacity, estimated need, employment claims, Poor Laws coverage, temporary retention after job loss, and each cause of being unhoused in tooltips.
- Notify on onset, escalation, and resolution; retain the alert between transitions rather than sending monthly popups.
- Clicking an alert should open the relevant state; verify the panel routing in-game.
- Start with advance warnings and gradual living-standard and migration-attraction effects. Prolonged severe crises could later add health consequences or events.
- Avoid stacking large effects for the same shortage, and allow time for construction to provide relief.

Installed game files confirm configurable alerts, a `player_state` alert context, scripted validity conditions, and feed/toast message definitions. Famine itself uses a dedicated `has_famine` trigger and opens the Food Security panel. Housing needs its own conditions and status; it will not automatically appear in the famine panel. A dedicated housing dashboard or map presentation would be additional UI work.

## Devastation and reconstruction

Devastation should reduce usable accommodation, representing damaged or uninhabitable homes. The installed scripts expose devastation conditions; the exact arithmetic integration still needs validation.

Illustrative formula, with devastation normalized from 0 to 1:

`Usable capacity = maintained capacity * (1 - 0.5 * devastation)`

| Devastation | Capacity remaining |
| --- | --- |
| 0% | 100% |
| 20% | 90% |
| 50% | 75% |
| 100% | 50% |

The coefficient is a testing value. Apply the same rule to rural and urban pools initially because state devastation does not identify which neighborhoods were damaged. Show the loss explicitly in the housing tooltip.

Preserve residential building levels initially and restore usable capacity as devastation declines. This avoids requiring manual replacement of every damaged level. A later Housing Reconstruction programme could spend materials and money to accelerate recovery. Housing-only recovery would need a separate repair mechanism if it should not also reduce all other effects of devastation.

Audit indirect devastation effects on staffing and supplies so the same damage is not unintentionally counted twice. Any persistent housing-damage system would be an extension beyond the simple devastation-linked version.

## Emergency responses: retain both options

The user explicitly requested keeping both Emergency Accommodation and Temporary Shelter Programme in the plan. They are different responses, not mutually exclusive alternatives selected during this discussion. Whether they may operate simultaneously, and any combined cap, remain balancing decisions.

### Emergency Accommodation decree

Represent subdivided apartments, compulsory billeting, and public buildings converted into temporary lodgings. Increase shelter capacity by accepting poorer living conditions, without constructing permanent homes.

Illustrative starting values:

| Effect | Testing value |
| --- | --- |
| Temporary accommodation | Up to 20% of usable existing housing capacity. |
| Living standards | -1 SoL while active. |
| Authority | Base decree cost of 100; engine scaling may apply. |
| Permanent housing stock | No increase. |

Compute capacity from housing usable after maintenance and devastation adjustments, separately for rural and urban pools. Do not recursively boost emergency shelter or treat ruined homes as available lodgings.

Example: 100,000 people require accommodation, while adequate housing accommodates 80,000. A 20% emergency allowance provides 16,000 temporary places. The unsheltered-capacity gap falls to 4,000, but the adequate-housing gap remains 20,000.

Emergency accommodation could downgrade the severe emergency to an Emergency Accommodation in Use status while retaining a smaller quality penalty. It must not declare adequate housing restored merely by permitting crowding. Define shelter-driven and quality-driven consequences separately, and ensure the combined decree and residual crisis penalties make relief beneficial rather than worse than inaction.

Warn how much shelter will disappear when the decree ends. The basic state or stratum SoL modifier is an aggregate approximation: it does not precisely target occupants of temporary lodgings, nor distinguish rural from urban residents by itself.

Installed decree definitions support Authority costs, state modifiers, eligibility conditions, AI weights, and `has_decree` checks. The custom housing calculation would read decree status; it is not a native housing-output modifier.

### Temporary Shelter Programme

Offer a less coercive response that supplies temporary accommodation using wood, fabric, government money, and any necessary staff. Authority alone must not stand in for these resource purchases.

- Implement as a decree-backed programme with a supporting building or verified upkeep scripting; the exact route remains open.
- Tie funded temporary capacity to actual support, with a defined setup time and withdrawal behavior.
- Keep shelter distinct from adequate permanent housing; quality, capacity, and funding tradeoffs need balancing against Emergency Accommodation.
- Do not assign final costs or promise a precise budget mechanism before testing.
- Define how input shortages, funding withdrawal, and damaged supporting facilities affect the programme without abrupt repeated alert spam.

Both options buy time for permanent housing construction or reconstruction. They must not create permanent stock when toggled or apply their capacity bonuses to one another.

## Infrastructure and natural industrial specialization

Design objective: make the location and support costs of industry matter without penalizing a state simply for having several building types.

These mechanics normally operate at state level, not individual map province level. Ten levels each of steel, glass, and tools may represent several industrial towns across a large state; that combination should remain viable where resources, population, and infrastructure support it.

- Housing occupancy follows actual workers and associated dependents through their workplaces, while infrastructure serves economic activity. A building level with no workers claims no housing. Industrial growth creates housing pressure through employment and population movement, not a duplicate per-level charge.
- Freight-intensive industries should place appropriate demands on infrastructure. Vanilla already distinguishes infrastructure usage by building group.
- Dense growth could require higher-density housing, improved transport, and eventually sanitation investment. Increasing support costs should be tied to visible constraints and useful upgrades, not arbitrary diversity penalties.
- Housing and infrastructure pressure encourage dispersal; they do not inherently favor 30 steel levels over 10 steel, 10 glass, and 10 tools with comparable requirements.
- First test existing manufacturing economies of scale alongside housing and infrastructure upkeep before adding new specialization rules.
- Preserve incentives for related industries to coexist, such as steel and tools. Resource access, local inputs, established workforce, and freight connections should help shape regional strengths.

If additional incentives are needed, consider later industrial districts representing shared training, workshops, and specialized transport. Benefits should apply to related industry families, grow gradually with actual activity, be modest and capped, and require support investment or upkeep. A developed state could support multiple districts. This is an unverified scripted extension, not a confirmed native district system.

Desired outcome: a small industrial state may find further glassworks cheaper to support elsewhere, while a large, well-connected state can profitably retain steel, glass, and tools. Avoid hard industry-count caps or penalties triggered by adding a third industry type.

## Capacity prototype and validation sequence

1. Seed a small test state's rural and urban physical capacity and consistent population need. Verify employment claims, dynamic dependent scaling, unemployed residents, and one claim per person.
2. Test Poor Laws coverage, government funding, monthly half-gap housing loss, rehiring, law changes, and rounding. Verify that physical capacity caps actual housed residents.
3. Verify maintenance and devastation adjustments, recovery, and explicit tooltip accounting.
4. Verify crisis timing, separate physical and eligibility causes, highest-severity selection, recovery thresholds, notifications, and state-panel navigation.
5. Prototype Emergency Accommodation: temporary capacity, SoL/Authority tradeoff, removal warning, and no duplicated adequate-housing benefit.
6. Prototype Temporary Shelter Programme with real material and treasury costs. Check coexistence rules and prevent recursive bonuses or free permanent stock.
7. Test employment shifts, migration, conquest, population changes, and optional commuting without duplicating capacity or demand.
8. Evaluate AI construction, decree use and removal, budget pressure, and campaign behavior. Publicly financed capacity needs its own AI support logic; ordinary private goods profitability will not automatically solve it.
9. Prototype law-dependent pop payments and matching receipts before claiming rent or tenure effects; compare industrial location choices using existing scale incentives before introducing industrial districts.

No implementation or gameplay testing has occurred. All numeric thresholds, costs, coefficients, and scope choices above remain prototype assumptions.

## Earlier tenure extension: engine evidence and limits

Inspection of the installed Victoria 3 game files found building-group-specific ownership modifiers. Cooperative Ownership targets several building groups; Homesteading and Collectivized Agriculture target agricultural groups. A separate residential building group therefore offers a plausible basis for housing-specific laws, pending in-game validation.

However, vanilla collectivization transfers ownership to a building's workforce, not its customers. Applying it directly to residential buildings would benefit maintenance workers and clerks, not the residents working elsewhere.

Consumption baskets are defined by wealth level. No verified scripting hook has yet been found to exempt a selected share of residents from rent while charging them homeowner upkeep. Tracking a homeownership share does not itself solve this household accounting problem.

## Physical housing and tenure

- Residential building levels represent housing stock; construction adds capacity.
- A local Housing good could represent accommodation supplied each week, rather than houses consumed each week.
- Operating inputs represent repairs and maintenance, with low staffing requirements to avoid making accommodation vanish when maintenance employment falls.
- Track landlord-owned, resident-owned, and optionally publicly owned capacity in each state.
- Store capacity amounts and derive percentages. A percentage alone could imply that population growth creates owned homes without construction.
- Transfers between tenure categories preserve total capacity. Converting rental homes to resident ownership does not create additional homes.

Example: 100,000 household-equivalents of capacity, comprising 60,000 rented and 40,000 resident-owned. These are aggregate accounting units, not individually tracked households or deeds. The relationship between capacity, occupancy, population, and differing household sizes still needs definition.

## Proposed housing laws

These are design candidates, not implemented or finalized laws:

| Law | Intended role |
| --- | --- |
| Private Landlordism | Private owners collect rental revenue and profits. |
| Homeownership Promotion | Encourage gradual resident purchases and resident-owned construction. |
| Housing Cooperatives | Represent collective resident ownership, distinct from employee ownership. |
| Public Housing | Government ownership and financing of residential capacity. |

Laws should govern transitions and construction incentives rather than instantly imposing a homeownership percentage. Interactions with national economic laws and building-group inheritance need explicit testing.

## Initial transition proposal

Prototype a state-level Tenant Purchase Programme under Homeownership Promotion:

1. Require existing rental capacity eligible for conversion.
2. Convert a limited amount per month.
3. Use an explicit funding arrangement.
4. Preserve total housing capacity; additional accommodation requires construction.

Government buyouts, resident purchases, and uncompensated redistribution are different policies. Do not hide those differences behind a free monthly ownership increase. A government-funded prototype is one possible starting point, but ownership transfer and compensation effects must first be verified. Subtracting treasury funds alone does not establish that former owners received payment. Private household financing remains unresolved.

## Intended household accounting

For a simple occupied-housing model without public housing:

`Average housing cost = renter share * rent + homeowner share * owner upkeep`

Illustrative values only:

- Renting, including maintenance: 10 currency units per household-equivalent per month.
- Owning outright, paying upkeep: 4 units.
- At 40% homeownership: `0.60 * 10 + 0.40 * 4 = 7.60`.
- At 60% homeownership: `0.40 * 10 + 0.60 * 4 = 6.40`.

These numbers describe ownership without mortgage debt. Mortgages, lender income, household equity, and property transactions are outside the initial scope.

Owners must still create maintenance demand, while only renters generate rent payments. Avoid double-counting maintenance or distributing landlord profits from resident-owned homes. Vacancies require a separate occupancy calculation; stock shares cannot automatically be treated as household tenure shares when occupancy differs.

## Unresolved delivery mechanism and fallback

The preferred route is an actual change in household expenditure, matched by the correct change in landlord receipts and maintenance demand. This needs an engine prototype before a full design can be committed to.

Making rent and upkeep interchangeable goods within a housing need does not establish which consumers own property. Likewise, adding an ownership variable does not automatically alter pop consumption.

A fallback could use scripted living-standard effects to approximate housing security. The installed game supports state-level lower-, middle-, and upper-strata living-standard modifiers. Separate tenure shares by stratum could improve targeting, but benefits would still be averaged across that stratum, including renters.

Such a fallback must be labeled a social-policy approximation, not a rent rebate or an accurate ownership economy. It does not by itself reduce household rent payments or landlord receipts. Avoid repeatedly increasing pop wealth to imitate funded income transfers.

Background on vanilla income, consumption, and wealth: [Paradox Dev Diary #13 - Standard of Living](https://steamcommunity.com/games/529340/announcements/detail/2965045886379003737).

## Tenure prototype gate

Use one state, fixed housing capacity, and two tenure settings. Before claiming an economic tenure simulation, demonstrate that increased resident ownership:

1. Reduces household rental expenditure.
2. Reduces landlord receipts correspondingly.
3. Preserves upkeep demand.
4. Preserves physical housing capacity.
5. Does not divert the savings to housing employees.

If these checks fail, keep tenure deferred or use a clearly labeled social-policy approximation. The maintained-capacity model above can proceed independently; an explicit rental-good model remains another option. Do not present the state-level ownership variable as a solved economic mechanism.

## Later balancing and integration

- Seed existing urban and rural housing in 1836 to prevent an artificial worldwide shortage.
- Rebalance existing household consumption rather than simply adding a large expense.
- Verify AI investment responds to local housing demand.
- Check migration, population growth, vacancies, conquest, and changes of law without creating or duplicating housing capacity.
- Define how repairs, employment, shortages, and any deterioration affect usable capacity.
- Connect housing growth to infrastructure demand after the core accounting works.
- An existing project, [Housing Realism](https://github.com/Teakowa/v3-housing-realism), describes local rental and owner-occupied housing goods as recurring residential costs. Its implementation has not been tested here and does not establish household property ownership.
