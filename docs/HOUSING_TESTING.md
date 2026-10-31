# Housing: implementation and test guide

Housing is part of **Burden of Infrastructure**. It was developed as the separate BOI Housing Prototype and merged into the main mod on 2026-10-30. It implements the [agreed goods-based housing design](plans/04_HOUSING.md) and loads in every BOI campaign: there is no separate launcher entry and no switch to turn it off. Household demand lives in buy packages, which no game rule can change.

Start a new campaign to use it. Starting residential supply is not seeded; households get basic housing from subsistence buildings and whatever residential buildings are built later. Acquisition enforcement, ownership laws, private investment eligibility, a dedicated Housing category, and calibrated balance are still unfinished; see the [housing plan](plans/04_HOUSING.md).

## Implemented scripts

- Local Housing and Luxury Housing with separate wealth-based needs. Luxury demand is additional, never a substitute for basic Housing.
- Fixed slum districts, tenements, apartments, luxury apartments, suburbs, and public temporary shelters. Residential quality cannot be changed by switching PMs.
- Staffing-scaled slum mortality and migration penalties; one unscaled SoL penalty on the single slum building type. Luxury buildings provide staffed migration bonuses.
- Selectable horse, rail, and motor commuting for suburbs.
- Optional company housing on 27 rural building types, including Horse Ranches. No Company Housing is the default and is never law- or technology-gated.
- Small staffed basic output from all five subsistence building types.
- Separate Employer Housing and Residential Standards law groups. Reform supporters/opponents are attached additively to selected interest groups.
- Hostile housing employee penalties, law gates, and an enactment fallback to None with monthly maintenance. Safe methods are not reset by the fallback.
- A ban on new slum construction/expansion that leaves existing operations intact.
- Emergency Accommodation decree and a publicly funded Temporary Shelter Programme building.
- Substantial infrastructure costs for permanent housing and temporary shelters. Denser buildings provide more accommodation per infrastructure unit; native state infrastructure is the resource to watch.
- Dedicated goods icons for basic and luxury Housing, alongside BOI's Horses icon.
- Dedicated building icons for slums, tenements, apartments, luxury apartments, suburbs, and temporary shelters.

All figures are provisional. Native declarations establish candidate behavior; the checks below must demonstrate it in the engine.

## Files

Housing files are the ones named for housing (`*boi_housing*`, 18 script files across `common/`, `events/` and `gui/`) plus `common/buy_packages/00_buy_packages.txt`. The Horse Ranch in `common/buildings/50_boi_buildings.txt` lists `pmg_boi_company_housing` by hand. Localization is in `localization/english/boi_housing_l_english.yml`.

## Goods artwork

The generated full-resolution PNGs are in `art/housing/`, with building originals in `art/housing/buildings/`. The game does not load that folder. It uses 256-pixel PNG and mipmapped DDS versions in `gfx/interface/icons/goods_icons/` and `gfx/interface/icons/building_icons/`. Goods definitions, inline text icons, and the six housing building definitions reference the DDS files. Rebuild the game-sized assets from the sources with `tools/Convert-HousingIcons.ps1` from the BOI root.

## Test values

Outputs and inputs below are per fully staffed building level. Each residential/service level employs 1,000 maintenance/administrative workers, not 1,000 residents. Output units are services, not an exact population count.

| Building | Basic / luxury output | Construction tier | Infrastructure | State effects per staffed level |
| --- | --- | --- | --- | --- |
| Slum Districts | 60 / 0 | Low | 8 | +0.1% mortality, -0.2% migration; separately -1 flat SoL while any levels exist |
| Tenement Districts | 70 / 0 | Medium | 6 | None |
| Apartment Blocks | 100 / 10 | High; steel-frame technology | 4 | None |
| Luxury Apartments | 25 / 60 | High | 5 | +0.2% migration |
| Suburban Estates | 25 / 60 | Medium | 8 | +0.3% migration; additional commuting inputs |
| Temporary Shelter Programme | 40 / 0 | Low | 5 | Government-funded wages and inputs |

Slum mortality and migration percentages are additive modifiers, not percentage points of residents dying. At ten levels and 50% staffing: +0.5% relative mortality, -1% migration attraction, and -1 flat SoL. At zero staffing, mortality/migration effects vanish but the constructed slum's flat SoL loss remains.

Luxury apartments consume 8 wood, 5 tools, 8 glass, and 8 furniture per staffed level. Suburbs consume 6 wood, 2 tools, 2 glass, and 3 furniture, plus 6 horses / 5 transportation / 2 automobiles depending on commuting. This makes suburban luxury output cheaper in materials at base prices, while their infrastructure and transport demands are higher; actual profitability depends on local prices and wages. No separate residential land limit is used.

Basic need at wealth W is 10 + 2W expenditure units. Luxury demand begins at W=15 at (W-14)^2. Existing vanilla needs are preserved, so this increases household expenditure. Peasant market consumption is only 5% of an ordinary package; the 0.25 basic housing output per staffed subsistence level is a calibration starting point.

Hostile company camps sell 8 basic Housing for 1 wood and 1 fabric, with -1 employee SoL and +5% employee mortality. Safe worker settlements sell 6 for 3 wood, 2 fabric, and 1 tool. Serviced towns require Modern Sewerage and sell 12 for 4 wood, 3 fabric, and 2 tools. Effects apply through profession-specific building modifiers, not state modifiers.

Emergency Accommodation costs 100 base Authority, adds 15% basic Housing output, and costs 1 state SoL. It affects all basic suppliers, including company/subsistence housing and operating shelters. It does not boost luxury output. The shelter programme consumes 10 wood, 10 fabric, 2 tools, and treasury wages per staffed level. Programme suspension UI and more detailed operation are still planned.

## Debug events

Enable **Burden of Infrastructure** only; housing comes with it. If an old playset still lists **BOI Housing Prototype**, remove that entry: the folder no longer exists. Housing buildings appear under the existing Development building category; the state's ordinary infrastructure display shows the resource pressure.

Start a new Portugal campaign in debug mode, pause, and run:

```text
event boi_housing.1
event boi_housing.2
```

Event 1 initializes missing laws/ideologies without resetting existing choices; it also runs monthly and on country formation. Event 2 creates one level of each initially available housing type in owned Alentejo, only if that type is absent. It creates no free buildings elsewhere and is never called automatically. It does not unlock steel-frame apartments, fully staff buildings, balance the market, or transfer private ownership.

Event 2's four permanent fixture levels should consume 27 infrastructure in Alentejo: one slum (8), one tenement (6), one luxury apartment (5), and one suburb (8). The temporary shelter adds another 5, for 32 total. Compare infrastructure before and after the event, allowing for any other concurrent state changes. Running it again must not duplicate buildings or infrastructure demand.

For explicit law testing:

```text
event boi_housing.3
```

This sets permissive employer and residential laws. Select hostile housing at one rural workplace and safe housing at another, then run:

```text
event boi_housing.4
```

This enacts protected employer housing and minimum residential standards. The first workplace must revert to None; the safe workplace must remain unchanged. Existing slums must continue operating while new construction is blocked. These debug events deliberately bypass the enactment process and are not automatic gameplay events.

Because nothing references events 2 to 4, the engine logs `Event boi_housing.N is orphaned` for each at every launch. That is expected. `tools/Test-Headless.ps1` counts those three lines separately and does not treat them as BOI errors.

## Required runtime checklist

Record observed results in the test log of [the housing plan](plans/04_HOUSING.md#test-log). Item 1 is partly covered by headless runs; every other item is **not run**.

1. Load without new housing-related errors, unknown modifiers, invalid event scopes, unresolved icons, or missing localization. Check the game's error log after initialization and law switches. *Headless, 1.13.11, 1836–1846: no housing errors besides the three expected orphaned-event lines. Icons, tooltips and law switches have not been checked by eye.*
2. Confirm all company housing starts at None before unpausing; rural building outputs, employment, other PMs, and BOI horse inputs remain unchanged.
3. Observe basic and luxury buy/sell orders in Alentejo. Confirm local trade isolation, additional wealthy luxury demand, positive low-wealth basic demand, and actual residential revenue.
4. Compare low- and higher-wealth peasants against subsistence housing output. Establish the intended transition to insufficient provision from actual household budgets.
5. Compare slum modifiers at one/multiple levels, zero/partial/full staffing, and after the last level is demolished. A queued-only slum must not impose SoL loss. Native unscaled effects must not stack per level.
6. Compare suburbs and luxury apartments at zero/partial/full staffing. Migration bonuses must disappear without staffing. Check all commuting inputs and shortages, and both output goods.
7. Confirm hostile penalties affect only the employing building's relevant pops. Check dependent treatment explicitly. Hiring more employees must not amplify the percentage penalty for each existing employee.
8. Run both law fixtures; confirm immediate fallback, safe-PM retention, existing slum operation, and blocked new/expanded slums. Check already queued slums and record engine behavior.
9. Enable and remove Emergency Accommodation; check only basic output changes, flat SoL applies once, and removal restores the previous values. Run it alongside shelters to verify the single additive boost.
10. Confirm shelter goods and wages are charged to the treasury, basic housing is sold, and unstaffed shelters supply nothing. The current building has no dedicated programme shutdown control.
11. Save/load, form/release a country, and transfer a state. Initialization must not reset existing housing laws, duplicate ideologies, or create new debug-fixture levels. Protected employer rules must remain enforceable.
12. Test native ownership, acquisition, and downsizing without assuming the agreed acquisition rule is enforced. No free confiscation workaround is permitted. This is an open implementation gate.
13. In Alentejo after event 2, check the state infrastructure change and each building tooltip. Confirm 32 total infrastructure demand from the five fixture buildings at one level each, including 5 from the temporary shelter. Check that demand persists at zero staffing and is released when a level is demolished.
14. Compare a state with slums/tenements to the same state after acquiring, demolishing, and replacing old housing with apartments. Record basic and luxury output, infrastructure demand, construction/purchase costs, prices, and shortages. Confirm that dense replacement saves meaningful infrastructure for comparable accommodation. Check AI choices under infrastructure pressure before finalizing values.

Do not read the current housing prices or AI expansion as balanced. In the 1836–1846 headless run, basic Housing sat at its price floor nationally, with supply 3–5 times demand. Acquisition enforcement, infrastructure calibration, and initial world supply must follow before release.

## Regeneration and automated checks

Run from the BOI root:

```powershell
.\tools\Build-Housing.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
.\tools\Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
```

The builder writes four files into the mod root: `common/buildings/00_boi_housing_rural_generated.txt`, `common/buy_packages/00_buy_packages.txt`, `common/scripted_effects/zz_boi_housing_fallback_generated.txt`, and `common/modifier_type_definitions/zz_boi_housing_generated.txt`. It never reads those four back as input, so running it repeatedly gives identical output. It copies vanilla rural and subsistence buildings and adds only the housing PM group. It never copies a building BOI itself defines or shadows: such a building (today, only the Horse Ranch) must list the housing PM group by hand, and the builder stops with an error if it does not. Building shadows follow BOI's early `00_boi_*` convention. Demand replaces the complete vanilla buy-package file, avoiding duplicate-key ordering. No vanilla PM definition is shadowed by housing. Handwritten definitions are not regenerated.

`tools/Test-Housing.ps1` (run by `Validate-All.ps1`) compares every generated building and demand package to vanilla with only the intended addition removed, and checks that the Horse Ranch lists company housing. It verifies staffing fixtures, fixed structural groups, law gates, assets, good/PM/technology references, explicit modifier declarations, and that regeneration matches the committed files. It does not replace engine tests.

For an unattended run, `tools/Test-Headless.ps1` needs no extra mods: it loads the housing telemetry module automatically because BOI defines `boi_housing`. `tools/Get-HeadlessReport.ps1` reports the housing price, buy/sell volumes and building levels.

## Compatibility

Housing shadows 31 vanilla building keys and replaces all 99 wealth packages, so other mods that change those buildings or buy packages conflict with BOI. Any future pop need must be added through `tools/Build-Housing.ps1`; a second copy of the buy-package file would silently replace this one. Re-run regeneration and review after game or BOI definition updates.
