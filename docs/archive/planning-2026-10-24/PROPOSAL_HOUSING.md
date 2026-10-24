# Housing goods and residential development

Updated: 2026-10-09.

Status: agreed design; implementation has begun in an optional [housing prototype](tools/housing-prototype/README.md). The main BOI campaign does not yet load housing. See the [implementation plan](IMPLEMENTATION_PLAN_HOUSING.md) and [feasibility record](HOUSING_FEASIBILITY.md).

This replaces the capacity, employment-entitlement, and delayed-eviction model. The [previous proposal](docs/archive/housing-capacity-2026-10-03/PROPOSAL_HOUSING.md) is retained as historical discussion, not an implementation requirement.

## Agreed economic model

Housing is an ongoing accommodation service sold as a normal local good. Housing and Luxury Housing are separate goods, each traded within its state. Households buy them through ordinary wealth-based needs. Basic Housing is required from the lowest wealth level and demand grows with wealth. Luxury Housing is an additional wealthy-household need; it does not replace the basic requirement.

Do not maintain a parallel entitlement, capacity, or rent-transfer system. Employment affects income and affordability through the ordinary economy. There is no exact assignment of households to buildings. State-wide residential effects are deliberate abstractions.

## Sources of supply

- Subsistence buildings produce a small amount of basic Housing, sufficient for modest peasant wealth but insufficient as peasant wealth rises. They supply the shared local market; output is not reserved for their own peasants.
- Rural industries offer an optional Company Housing PM group. All start with No Company Housing, always available. Employer accommodation represents camps and settlements, with technology and law gates.
- Dedicated residential buildings supply basic Housing, Luxury Housing, or both. Suburbs and luxury apartments supply both.
- Temporary emergency provision supplies basic Housing.

Subsistence and employer housing use their existing workplace infrastructure accounting; they do not create separate residential buildings.

## Residential buildings and replacement

Residential structure and quality are fixed by building type. A slum, tenement, apartment block, or suburban estate cannot become another structure through a PM switch. A single fixed internal PM is an engine implementation detail, not an upgrade choice.

Replacing a structure requires acquiring any privately owned housing, demolishing it, and constructing the replacement. There is no free redevelopment button or automatic confiscation. Exact acquisition enforcement and interaction with ownership laws require engine investigation.

Suburbs have selectable commuting PMs using horses, transportation, or automobiles as technology permits. They offer cheaper luxury accommodation materials, balanced by transport inputs and higher infrastructure demand than dense luxury housing.

A distinct Housing building group is required. A dedicated visible housing section is desired; a new top-level GUI tab remains subject to feasibility. The prototype temporarily uses the existing Development lens.

## Slum effects and desirable housing

For slum levels L with staffing fraction S:

- Effective staffed levels = L * S.
- Mortality increase = effective staffed levels * per-level mortality coefficient.
- Migration attraction loss = effective staffed levels * per-level migration coefficient.
- SoL receives one flat negative modifier if any constructed slum levels exist, regardless of level count or staffing. It disappears after the last slum is demolished.

These are state-wide effects. Do not use ordinary pollution, generate neighboring-state pollution, or attach residential harm only to maintenance employees.

Suburbs and other luxury housing can provide positive migration attraction scaled by staffed levels. Their bonuses can offset slum migration losses, but do not cancel slum mortality or the flat SoL penalty. If additional slum building types are introduced, retain a single state-wide SoL penalty rather than one penalty per type.

Minimum residential standards prevent new slum construction and expansion. Existing slums keep operating until acquired and demolished. Legislation must not delete stock or disable its fixed production method. Handling already queued construction must be verified.

## Employer housing

Hostile company accommodation is cheaper to operate than safer alternatives, giving employers a financial reason to retain it. It imposes a SoL penalty and increased mortality on that building's employees. Effects must not leak to the rest of the state or grow per building level for each employee.

A separate Employer Housing law group determines which PMs are permitted. Stronger laws prohibit hostile housing only. No Company Housing and all otherwise eligible safe methods remain available.

When legislation bans an active hostile PM, switch it to No Company Housing. Do not automatically upgrade it to safe housing. Existing safe methods must remain untouched. Technology independently unlocks more developed settlements.

Employer housing remains part of the underlying rural enterprise and is exempt from residential ownership laws.

## Infrastructure and redevelopment

Dedicated residential buildings impose substantial infrastructure demand. Older, less dense buildings use more infrastructure per unit of accommodation than apartments. Suburbs use more infrastructure than dense luxury apartments and also buy commuting inputs. This makes replacement attractive where infrastructure is scarce or expensive: acquiring and demolishing old housing frees its infrastructure demand, while denser new housing can supply comparable or greater accommodation with less demand. Building new housing remains possible when infrastructure is available; this is an economic incentive rather than a construction cap.

Infrastructure demand belongs to building levels, regardless of staffing. Subsistence and company housing continue under their workplace's infrastructure use, and temporary shelters have their own infrastructure demand. Prototype values and the strength of the redevelopment incentive require live economic calibration. Do not add a scripted residential land pool, capacity counter, or rezoning action.

## Laws and ownership

Residential ownership laws and possible amendments should eventually model landlord ownership, cooperative ownership, public provision, and frontier homesteading. Detailed construction rights, forced privatization, government-only construction, and precedence against national economic laws are deferred.

Do not use country-wide privatization rules to implement a housing-only policy. Do not equate worker ownership of a housing-maintenance business with ownership by its residents without explicit qualification.

The prototype's residential-standards laws regulate building types, not ownership. They are not a substitute for the deferred ownership system.

## Both emergency responses are retained

- Emergency Accommodation: an Authority-funded decree enabling temporary crowding and extra basic housing service at a comfort cost.
- Temporary Shelter Programme: government-funded accommodation consuming actual goods and wages.

They may coexist. Neither supplies Luxury Housing or permanently upgrades residential structures. Prototype coefficients and the precise programme start/stop behavior remain implementation assumptions; neither has final balancing approval.

## Provisional implementation choices

All numerical values, exact technology gates, building names, and political stances in the prototype are test values. The current wealthy-demand threshold is 15, borrowed as a starting tier rather than a settled class boundary. Subsistence supply needs live calibration because vanilla peasants market only 5% of ordinary consumption.

World seeding, player feedback, infrastructure balance, private acquisition, and AI operation must be validated before enabling housing in the main campaign.
