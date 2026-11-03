# Housing: implementation and test guide

Housing is part of **Burden of Infrastructure**. It was developed as the separate BOI Housing Prototype and merged into the main mod on 2026-10-30. It implements the [agreed goods-based housing design](plans/04_HOUSING.md) and loads in every BOI campaign: there is no separate launcher entry and no switch to turn it off. Household demand lives in buy packages, which no game rule can change.

Start a new campaign to use it. Starting residential supply is seeded from measured 1836 demand (see "Starting supply" below). Acquisition enforcement, ownership laws, private investment eligibility, a dedicated Housing category, and calibrated balance are still unfinished; see the [housing plan](plans/04_HOUSING.md).

## Implemented scripts

- Local Housing and Luxury Housing with separate wealth-based needs. Luxury demand is additional, never a substitute for basic Housing.
- Fixed slum districts, tenements, apartments, luxury apartments, suburbs, and public temporary shelters. Residential quality cannot be changed by switching PMs.
- Staffing-scaled slum mortality and migration penalties, plus one unscaled mortality penalty on the single slum building type. Luxury buildings provide staffed migration bonuses.
- Selectable horse, rail, and motor commuting for suburbs.
- Optional company housing on 27 rural building types, including Horse Ranches. No Housing is the default and is never law- or technology-gated.
- Small staffed basic output from all five subsistence building types.
- Separate Employer Housing and Residential Standards law groups. Reform supporters/opponents are attached additively to selected interest groups.
- Work Camp and Work Town employee penalties, and three employer-housing laws that each permit No Housing plus one tier: Unregulated (Work Camp), Protected (Work Town), Mandatory Serviced Housing (Serviced Town, unlocked by Socialism). Enacting or repealing a law moves paying tiers to the permitted one, with monthly maintenance; without Modern Sewerage the mandate moves them to No Housing. No Housing is never changed.
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
| Slum Districts | 6 / 0 | Low | 2 | +2% mortality, -0.2% migration; separately +10% flat mortality while any levels exist |
| Tenement Districts | 7 / 0 | Medium | 1.5 | None |
| Apartment Blocks | 10 / 1 | High; steel-frame technology | 1 | None |
| Luxury Apartments | 2.5 / 6 | High | 1.5 | +0.2% migration |
| Suburban Estates | 2.5 / 6 | Medium | 2.5 | +0.3% migration; additional commuting inputs |
| Temporary Shelter Programme | 4 / 0 | Low | 1.5 | Government-funded wages and inputs |

Slum mortality and migration percentages are additive modifiers, not percentage points of residents dying. At ten levels and 50% staffing: +20% relative mortality (+10% from staffing, +10% flat) and -1% migration attraction. At zero staffing, the staffing part and migration effect vanish, but the constructed slum's flat +10% mortality remains.

Luxury apartments consume 0.8 wood, 0.5 tools, 0.8 glass, and 0.8 furniture per staffed level. Suburbs consume 0.6 wood, 0.2 tools, 0.2 glass, and 0.3 furniture, plus 0.6 horses / 0.5 transportation / 0.2 automobiles depending on commuting. Staff stay at 1,000 per level, so wages set a break-even near 25 for basic housing. This makes suburban luxury output cheaper in materials at base prices, while their infrastructure and transport demands are higher; actual profitability depends on local prices and wages. No separate residential land limit is used.

Housing demand at each wealth level is a share of that level's core game basket, with housing at base price: none when Destitute (1-4), up to 5% at the price ceiling by the top of Struggling (9), an S-curve to 15% at Lavish (50), and flat above that. Basic need is 10 + 2W expenditure units, capped at that total, and luxury demand takes the rest. Existing vanilla needs are preserved.

Work Camps sell 0.45 basic Housing for 0.075 wood and 0.075 fabric, with +15% employee mortality. Work Towns sell 0.45 for 0.15 wood and 0.075 fabric, with +7.5% employee mortality. Serviced Towns require Modern Sewerage and sell 0.45 for 0.15 wood, 0.15 fabric, and 0.075 tools, with no penalty. Subsistence buildings supply 0.02 per staffed level. Effects apply through profession-specific building modifiers, not state modifiers.

Emergency Accommodation costs 100 base Authority, adds 15% basic Housing output, and adds 10% state mortality. It affects all basic suppliers, including company/subsistence housing and operating shelters. It does not boost luxury output. The shelter programme consumes 10 wood, 10 fabric, 2 tools, and treasury wages per staffed level. Programme suspension UI and more detailed operation are still planned.

## Debug events

Enable **Burden of Infrastructure** only; housing comes with it. If an old playset still lists **BOI Housing Prototype**, remove that entry: the folder no longer exists. Housing buildings appear under the existing Development building category; the state's ordinary infrastructure display shows the resource pressure.

Start a new Portugal campaign in debug mode, pause, and run:

```text
event boi_housing.1
event boi_housing.2
```

Event 1 initializes missing laws/ideologies without resetting existing choices; it also runs monthly and on country formation. Event 2 creates one level of each initially available housing type in owned Alentejo, only if that type is absent. It creates no free buildings elsewhere and is never called automatically. It does not unlock steel-frame apartments, fully staff buildings, balance the market, or transfer private ownership.

Event 2's four permanent fixture levels should consume 7.5 infrastructure in Alentejo: one slum (2), one tenement (1.5), one luxury apartment (1.5), and one suburb (2.5). The temporary shelter adds another 1.5, for 9 total. Compare infrastructure before and after the event, allowing for any other concurrent state changes. Running it again must not duplicate buildings or infrastructure demand.

For explicit law testing:

```text
event boi_housing.3
```

This sets permissive employer and residential laws. Select Work Camp at one rural workplace and leave another on No Housing, then run:

```text
event boi_housing.4
```

`event boi_housing.5` enacts Mandatory Serviced Housing the same way.

This enacts protected employer housing and minimum residential standards. The Work Camp must become a Work Town; the No Housing workplace must remain unchanged. Existing slums must continue operating while new construction is blocked. These debug events deliberately bypass the enactment process and are not automatic gameplay events.

### Automated version

`tools/Test-Headless.ps1` runs this whole sequence by itself in every BOI run
(skip it with `-NoFixtures`), through the `fixtures` telemetry module. Starting
at the first monthly pulse on or after 1836-02-01, as Portugal, it:

1. records Alentejo's infrastructure usage, fires `boi_housing.2`, and 30 days
   later checks that all five buildings exist and that usage rose by 32;
2. fires `boi_housing.2` again and 30 days later checks that no levels were
   added;
3. fires `boi_housing.3`, checks the permissive laws took, puts a Work Camp
   on Alentejo's livestock ranch, leaves its logging camp on No Housing, and checks
   the Work Camp took;
4. fires `boi_housing.4` and, a day later, checks the protective laws took, the
   Work Camp became a Work Town, the No Housing workplace stayed and the slums survived;
5. 35 days later, after a full monthly maintenance pass, checks again that the
   Work Camp is gone, then fires `boi_housing.5` without Modern Sewerage and checks
   for No Housing;
6. goes back to the protected law, researches Modern Sewerage, sets a Work Town,
   fires `boi_housing.5` again and checks it became a Serviced Town;
7. 35 days later checks the law held through maintenance and no banned tier runs;
8. steps back through the protected and unregulated laws, checking Serviced Town
   becomes Work Town, then Work Town becomes Work Camp.

Results go in the run's `summary.md` under "Housing fixture checks". A `fail`
fails the run. A `warn` marks checks that other activity can disturb: other
construction in Alentejo moves the 32-point infrastructure figure; the AI owner
can switch a PM; and the revert on enactment may wait for the monthly
pass.

First run, 2026-10-31 (`tools/headless-runs/20261031-104008_mod`, 1.13.11): all
10 checks passed, with Alentejo usage rising by exactly 32.0. The Work Camp
(then called hostile housing) reverted on the day after `boi_housing.4`, so the law's `on_activate`
does the work and the monthly pass is a backstop.

Nothing in the shipped mod references events 2 to 4, so in a normal game the
engine logs `Event boi_housing.N is orphaned` for each at every launch. That is
expected and harmless. In harness runs with the fixtures module the lines
disappear, because a reference from another loaded mod counts.
`tools/Test-Headless.ps1` still counts them separately, for `-NoFixtures` runs,
and does not treat them as BOI errors.

## Required runtime checklist

Record observed results in the test log of [the housing plan](plans/04_HOUSING.md#test-log). Item 1 is partly covered by headless runs; every other item is **not run**.

1. Load without new housing-related errors, unknown modifiers, invalid event scopes, unresolved icons, or missing localization. Check the game's error log after initialization and law switches. *Headless, 1.13.11, 1836–1846: no housing errors besides the three expected orphaned-event lines. Icons, tooltips and law switches have not been checked by eye.*
2. Confirm all company housing starts at None before unpausing; rural building outputs, employment, other PMs, and BOI horse inputs remain unchanged.
3. Observe basic and luxury buy/sell orders in Alentejo. Confirm local trade isolation, additional wealthy luxury demand, positive low-wealth basic demand, and actual residential revenue.
4. Compare low- and higher-wealth peasants against subsistence housing output. Establish the intended transition to insufficient provision from actual household budgets.
5. Compare slum modifiers at one/multiple levels, zero/partial/full staffing, and after the last level is demolished. A queued-only slum must not impose its flat mortality. Native unscaled effects must not stack per level.
6. Compare suburbs and luxury apartments at zero/partial/full staffing. Migration bonuses must disappear without staffing. Check all commuting inputs and shortages, and both output goods.
7. Confirm Work Camp and Work Town penalties affect only the employing building's relevant pops. Check dependent treatment explicitly. Hiring more employees must not amplify the percentage penalty for each existing employee.
8. Run the law fixtures; confirm each law offers only No Housing and its one tier, conversion on enactment and repeal, No Housing retention, existing slum operation, and blocked new/expanded slums. Check already queued slums and record engine behavior.
9. Enable and remove Emergency Accommodation; check only basic output changes, flat mortality applies once, and removal restores the previous values. Run it alongside shelters to verify the single additive boost.
10. Confirm shelter goods and wages are charged to the treasury, basic housing is sold, and unstaffed shelters supply nothing. The current building has no dedicated programme shutdown control.
11. Save/load, form/release a country, and transfer a state. Initialization must not reset existing housing laws, duplicate ideologies, or create new debug-fixture levels. Protected employer rules must remain enforceable.
12. Test native ownership, acquisition, and downsizing without assuming the agreed acquisition rule is enforced. No free confiscation workaround is permitted. This is an open implementation gate.
13. In Alentejo after event 2, check the state infrastructure change and each building tooltip. Confirm 9 total infrastructure demand from the five fixture buildings at one level each, including 1.5 from the temporary shelter. Check that demand persists at zero staffing and is released when a level is demolished.
14. Compare a state with slums/tenements to the same state after acquiring, demolishing, and replacing old housing with apartments. Record basic and luxury output, infrastructure demand, construction/purchase costs, prices, and shortages. Confirm that dense replacement saves meaningful infrastructure for comparable accommodation. Check AI choices under infrastructure pressure before finalizing values.

## Starting supply

`common/history/buildings/zz_boi_housing_seed_generated.txt` seeds Slums, Tenements, Luxury Apartments and Suburban Estates from `tools/housing_seed_demand_1836.tsv`, which holds demand measured per state in a one-year unseeded run. Seed levels are owned by the country, like the seeded Horse Ranches. Slums go only to crowded industrial cities and great ports, because each state with one takes the flat SoL penalty. Luxury goes to apartments in dense cities and to estates elsewhere. States whose demand rounds below one level get nothing and start short. Apartment Blocks and shelters are not seeded.

Do not read current housing prices or AI expansion as finished balance. In the 1836–1846 headless run, supply held at about 0.86 of demand with a population-weighted price of £33–35, but it is one run, and acquisition enforcement and later-era behaviour are still untested.

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
