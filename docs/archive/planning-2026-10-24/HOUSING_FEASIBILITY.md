# Housing feasibility record

Updated: 2026-10-09. Installed reference: Victoria 3 1.13.11.

This concerns the new goods model. Earlier capacity-probe results are [archived](docs/archive/housing-capacity-2026-10-03/HOUSING_FEASIBILITY.md). The old probe scripts were removed at the user's request and have not been restored.

## Evidence and limits

| Feature | Evidence in installed files | Current result |
| --- | --- | --- |
| Local goods | services/transportation use local = yes in common/goods/00_goods.txt | Two goods defined; live prices untested |
| Wealth-dependent demand | common/pop_needs and 99 common/buy_packages definitions | Generated demand; preservation and monotonicity checked |
| Peasant consumption | common/pop_types/peasants.txt: consumption_mult = 0.05 | Small staffed subsistence output; balance unverified |
| Fixed building structure | Buildings list PM groups; a group can contain one PM | Six fixed types; no structural upgrade selector |
| Staffing-scaled effects | production_methods.md documents workforce_scaled from zero to building level | Slum mortality/migration and luxury migration in workforce_scaled |
| Flat effect | Same documentation defines unscaled | Slum SoL uses unscaled on the single slum building type; runtime non-stacking must be checked |
| Employee-specific harm | Vanilla mining PMs use building_laborers_mortality_mult in unscaled; building modifier definitions include profession SoL keys | Hostile PM applies profession SoL and mortality in building scope; employee/dependent targeting not yet observed |
| Law gating | unlocking_laws in PM documentation; state-scoped possible in building documentation | Hostile PM gated; construction gated separately from slum operation |
| Law fallback | Vanilla country/state-region activate_production_method patterns, law on_activate country effects, has_active_production_method triggers | Generated affected-state/type fallback; exact runtime scope/order pending |
| Monthly maintenance | on_monthly_pulse_country in 00_code_on_actions.txt | Additive events list, no vanilla effect replacement |
| Housing grouping | Existing building_groups use category/lens and parent groups | Dedicated group under Development; custom tab not attempted |
| Residential infrastructure | Native building-group `infrastructure_usage_per_level` is used for each permanent housing type and shelters | Provisional costs are 8/6/4/5/8/5 respectively; game behavior and economic incentive remain unverified |
| Private acquisition before demolition | Native ownership_type exists, but no verified conditional downsizing gate inspected | Requirement retained; enforcement not implemented |
| Residential ownership law isolation | country_force_privatization_bool is country-wide | Detailed ownership law system deferred |
| Emergency crowding | Decrees provide state modifiers | Prototype adds basic Housing output and flat SoL cost; live behavior pending |
| Temporary shelter | BOI public works establishes government-funded + no_ownership pattern | Funded building with actual inputs/output; treasury behavior pending |

Source paths are relative to the installed game's game directory. Comments and existing usage justify implementation candidates, not claims of live validation.

## Prototype assumptions

- Basic need at wealth W: 10 + 2W expenditure units.
- Additional luxury need from wealth 15: (W - 14)^2.
- Peasant housing output: 0.25 units per fully staffed subsistence level.
- Hostile company housing: -1 employee SoL, +5% employee mortality (relative multiplier), higher output and lower inputs than safe baseline.
- Slums: +0.1% relative state mortality and -0.2% migration attraction per fully staffed level; -1 flat state SoL while any level exists.
- Luxury apartments: +0.2% migration attraction per staffed level; suburbs +0.3%.
- Suburban commuting: 6 horses, 5 transportation, or 2 automobiles per staffed level; technology gates on rail/motor methods.
- Infrastructure per level: slums 8, tenements 6, apartments 4, luxury apartments 5, suburbs 8, temporary shelters 5. These are provisional balance values.
- Emergency crowding: 100 Authority, +15% basic housing output, -1 state SoL.
- Shelter: public wages plus wood, fabric, and tools; 40 basic housing output per fully staffed level.

All are provisional, not final balance decisions.

## Validation

The automated suite checks source-preserving rural overrides, 99 demand packages, local-good and fixed-structure invariants, signed/scaled effects at zero/partial/full staffing, law gates, available game assets/references, and deterministic regeneration. The main BOI structure, seeds, horse safety, and vanilla shadow checks also remain required.

Actual observation: no live game run for this module has been performed. Use the [runtime checklist](tools/housing-prototype/README.md) and record game version, state, staffing, prices, modifiers, errors, and screenshots/results before marking any runtime row verified.

2026-10-09 design change: the user rejected the residential land counter in favor of high native infrastructure demand. The prototype's land script values, construction gates, Alentejo allowance variable, localization, and copied state-panel GUI were removed. Each housing type now has its own building group infrastructure cost. This removes the unverified queue-counting and GUI-override risks. Native infrastructure behavior and redevelopment economics still need a live run with the optional module enabled.

Static run on 2026-10-04: `tools/Validate-All.ps1` passed against the installed
game. It checked 65 BOM/brace-valid script/localization files, current seed
counts, the 675-state horse safety audit, 31 existing BOI vanilla shadow keys,
and the housing regression/reference/regeneration suite. No main-mod seed
or production definition changed. Optional CMF compatibility and saved-input
seed reproducibility checks were not requested or run.

Static run on 2026-10-09 after the infrastructure redesign: `tools/Validate-All.ps1` passed against installed game 1.13.11, including housing reference resolution and 65 BOM/brace-valid script/localization files. The launcher's scan detected the prototype folder but warned that it lacked `.metadata`; a valid metadata file was added afterward and verified to parse. Launcher display and in-game infrastructure figures still require a fresh run.

## Highest-priority risks

1. Infrastructure costs must be high enough to favor dense replacement where capacity is scarce without making starting housing supply or AI construction impossible.
2. Engine law invalidation may run before scripted fallback; verify it selects None and preserves safe PMs.
3. The unscaled slum effect must disappear at zero constructed levels, remain at zero staffing, and not apply merely for a queued building.
4. Household budgets change because housing expenditure is added to existing needs. Opening supply is not seeded.
5. Private investment and acquisition are not established for the new building groups.
6. Uncapped per-level mortality/migration can become large in heavily developed states. Preserve the agreed rule while calibrating level size and coefficients.
