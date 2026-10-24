# BOI Water Demand Prototype

Optional test module for **Burden of Infrastructure**; load it after the main mod. The main mod already
contains the Waterworks, the two water goods, the pop need `popneed_boi_water` and the six water state traits.
What it cannot contain is the *household demand*, because a pop need is consumed only when a wealth
package lists it, and `common/buy_packages/00_buy_packages.txt` is a single file with one block per wealth level.
This module is that file: vanilla's 99 packages plus one line, `popneed_boi_water = 8 + wealth`.

Plan: [docs/plans/03_WATER.md](../../docs/plans/03_WATER.md). Original design and sources: [archived proposal](../../docs/archive/planning-2026-10-24/PROPOSAL_WATER.md), section 10.

## Without this module

Water has no buyers. Waterworks can be built and run, but nothing consumes the Local Water, its price
falls to the floor, and a private owner makes no profit. Use the module for any real test.

## Not ready for a normal campaign

- **No 1836 seed.** No Waterworks exist at game start, so every household starts with an unmet water need and
  standard of living dips until the AI (or you) builds. The AI is pushed hard to put one in every populated
  state (`ai_value` +3000 while a state with over 10,000 people has none), but construction takes time.
- Demand is a placeholder (8 + wealth) and is not calibrated against supply.
- It replaces the whole `00_buy_packages.txt`. **It cannot be loaded with the housing prototype**, which replaces
  the same file; whichever loads first wins and the other module's needs silently vanish. To run both, execute
  `tools/Build-WaterPrototype.ps1 -MergeIntoHousing` and enable **only** the housing prototype.
- Regenerate after every game patch: `tools/Build-WaterPrototype.ps1`.

## Test checklist (record results in the test log of [the water plan](../../docs/plans/03_WATER.md#test-log) before trusting any of it)

1. **`tradeable = no` on Bulk Water.** Set an exporter and an importer in two states of the *same* market. Does
   Bulk Water appear in the market goods panel and move between them? If it cannot be sold even between
   neighbours, delete `tradeable = no` from `common/goods/51_boi_water_goods.txt`. Does it also stay out of
   cross-market trade? (Unverified; vanilla uses the flag only for gold.)
2. **Private building and the construction menu.** Does Waterworks appear, in which tab, and can private
   capital build it? (The group is a standalone `category = rural`, deliberately not under `bg_extraction`.)
3. **Outputs sold.** Does the owner earn the revenue? Do wages and inputs come out of the owner's pocket?
4. **Export draws from the state pool.** With Surplus Sales on, does `water` input come from the state at the
   state price? Does a short state see the price rise and the export stop paying?
5. **Price of a thinly traded good.** How far does Bulk Water swing with only a few producers and buyers?
6. **Mortality and pollution keys in a PM.** `state_mortality_mult` and `state_pollution_reduction_health_mult`
   inside `state_modifiers` have not been seen in a vanilla PM. Check the error log for an unknown-modifier
   complaint, then check the state panel for the effect.
7. **Traits.** Does `goods_output_water_mult` on a state trait scale the Waterworks output? Inspect a
   Dry Summers state (-25%) and an Arid Interior state (-50%).
8. **Stress of infrastructure.** Do state infrastructure and market access fall as Waterworks levels and the
   piped tiers are added?
9. **Staffing.** Does choosing a different Export PM change the number of employees? It must not.
10. **Admin laws.** Does the administration PM follow the Bureaucracy law as on Public Works?

## Regenerating

```powershell
tools/Build-WaterPrototype.ps1            # standalone module
tools/Build-WaterPrototype.ps1 -MergeIntoHousing   # fold water into the housing prototype instead
```
