# Housing implementation plan

Updated: 2026-10-09.

Design source: [agreed housing model](PROPOSAL_HOUSING.md). This plan replaces the former capacity prototype; the [old plan](docs/archive/housing-capacity-2026-10-03/IMPLEMENTATION_PLAN_HOUSING.md) is archived.

## Current delivery

An optional module exists at [tools/housing-prototype](tools/housing-prototype/README.md), requiring BOI and loaded after it. It contains real game definitions for local Housing and Luxury Housing, demand, fixed residential buildings, commuting, company and peasant provision, housing standards, and emergency measures. It is an unseeded test economy, not a campaign-ready feature.

The main BOI campaign definitions have not been changed. Its validation entry point now includes the prototype checks.

## 1. Economic and effects prototype — scripts delivered; live tests pending

- Local basic and luxury goods and independent needs.
- Generated additive housing demand at all 99 wealth levels, preserving original needs and political strength.
- Six fixed residential/service building types, including slums, mixed-output luxury housing, suburbs, and public temporary shelters.
- Staffing-scaled state mortality/migration effects and one native unscaled slum SoL penalty.
- Three suburban transport options.
- Optional company housing on 27 rural building types, including BOI Horse Ranches; baseline peasant housing on five subsistence types.
- Employee-scoped hostile housing effects and separate employer regulation.
- Residential standards that gate new slum construction without disabling existing operations.
- Emergency crowding decree plus funded shelter building.
- Country law initialization, additive ideology attachment, and a generated hostile-PM fallback.
- Idempotent debug fixture event for owned Alentejo; no automatic world seed.
- Source-preserving generators and regression checks.

Run the [live checklist](tools/housing-prototype/README.md). Static checks do not establish engine acceptance, targeting, or AI behavior. Address any script errors before economic tuning.

## 2. Infrastructure, redevelopment, acquisition, and presentation — next

The user replaced the shared residential land design with substantial infrastructure demand. The optional prototype now charges 8 infrastructure per slum level, 6 per tenement, 4 per apartment, 5 per luxury apartment, 8 per suburb, and 5 per temporary shelter. These are provisional values. Native state infrastructure accounting provides the constraint, so the residential land script, construction gate, and custom land row were removed. No rezoning action is planned.

### 2a. Verify infrastructure and redevelopment economics

Load the optional module and confirm each housing type consumes its specified infrastructure even when vacant. Confirm that demolishing a level releases its demand and that construction adds demand at completion. Compare service output per infrastructure unit: the initial values are 7.5 basic housing per slum infrastructure, about 11.7 per tenement, 27.5 basic plus 2.5 luxury per apartment, and 5 basic plus 12 luxury per luxury-apartment infrastructure. Suburbs provide 3.125 basic plus 7.5 luxury per infrastructure and also require commuting inputs. Verify actual game behavior and adjust values after observing infrastructure shortages, prices, and build incentives. The values should make replacing old housing with dense buildings economical where infrastructure is costly, while allowing new construction where capacity exists.

Native infrastructure pressure does not itself require demolition before new construction. Do not describe the design as a hard housing cap. Check whether shortages meaningfully affect the housing economy and AI choices; if they do not, revise the coefficients or supporting incentives before main-mod integration.

### 2b. Acquisition and replacement

Investigate native downsizing rules and ownership fractions. Enforce acquisition before private housing demolition without bypassing payment or restrictions. Do not automatically nationalize as part of clearance. Preserve a viable government-owned redevelopment path. Test the full sequence: acquire eligible private levels, demolish, observe released infrastructure, then construct denser housing. Verify that the combined purchase and construction cost can be worthwhile under realistic infrastructure prices and housing demand.

### 2c. Player presentation

Keep housing in a visible building group under the existing Development category while testing. The state panel already displays native infrastructure; rely on that value for the resource constraint. Show each residential type's infrastructure demand through ordinary building tooltips and a short Housing explanation in the prototype documentation/localization. A dedicated Housing section remains desirable, but a custom top-level category requires a separate GUI test. Do not restore the copied state-panel GUI merely to show a housing-only counter.

**Exit criteria:** infrastructure values load and change with construction/demolition as expected; old-to-dense redevelopment saves meaningful infrastructure for comparable housing output; private acquisition rules prevent uncompensated clearance; the player can find housing buildings and understand their infrastructure cost; and the AI can build and operate needed housing. Record game version, logs, screenshots, and observed numbers in the feasibility record.
## 3. Emergency operation and transitions

Verify the decree's output modifier affects only the basic housing good and ends cleanly when removed. The prototype applies it to all basic suppliers, including subsistence/company housing and shelters; review this scope during playtesting.

Verify the shelter programme charges treasury wages and real wood/fabric/tools, sells basic housing services, and produces nothing when unstaffed. Add a clear suspension/closure path and decide its construction/deconstruction behavior without supplying permanent homes for free.

Test hostile-PM law transitions immediately on enactment and after conquest/save-load. The default PM plus law on_activate fallback and monthly maintenance are implemented; the engine's ordering still needs observation. Ensure safe PMs survive unchanged.

## 4. Starting supply and AI

Build a reproducible seed from population, wealth, and existing subsistence supply. Never seed a whole state-region's demand separately for each country owner. Do not assign housing claims by workplace or recreate employment eligibility.

Calibrate peasants first at low and high wealth, then a mixed urban population. Review basic and luxury prices, household budgets, residential profitability, treasury shelter costs, migration modifiers, and mortality. All company housing starts at None; it cannot be used to hide missing starting residential stock.

Confirm private investment eligibility for new groups, acquisition behavior, and AI responses to infrastructure pressure and housing laws. Test demand shocks, supplier layoffs, rapid growth, and deindustrialization. Confirm the AI can fund, build, and operate required housing before enabling it globally.

## 5. Ownership extensions

Detailed ownership laws, mandatory privatization, government-only construction, resident cooperatives, and frontier homesteading remain deferred design work. Keep employer housing exempt. Resolve precedence with vanilla economic laws before implementing restrictions.

## Release gate

The module is ready for main-mod integration only after live engine tests, infrastructure and redevelopment balance, private-acquisition rules, starting supply, and AI behavior have passed. Merge definitions and generator integration together; do not enable universal demand in an unseeded main campaign.

Existing saves require a separate migration plan. Initial testing is for new disposable campaigns only.
