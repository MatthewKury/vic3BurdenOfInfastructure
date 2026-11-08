# Patching notes

What Burden of Infrastructure overrides in the base game, and what to redo after
every Victoria 3 patch. Checked against 1.13.11 on 2026-10-31, and patched for
1.15.0 on 2026-11-06 (see "1.15.0 patch log" below).

## How the overrides work

Keyed databases are **first-read-wins**. A `00_boi_*` file loads before
vanilla's `01_`+ files, so its copy of a key wins and the vanilla copy is
discarded with one harmless `error.log` line: `Duplicated key X will not be
created`. Every shadow is a full copy of the vanilla block with BOI's changes
tagged `# BOI:`.

**Expected count: 65 `Duplicated key` lines per launch on 1.15.0** (measured, run `20261106-102840_mod`) (63 on
1.13.11, headless run `20261030-174303_mod`; 1.15 adds the copper mine and the
Cossack Host to the generated housing shadows). A different count after a patch
means a key was renamed, removed or added; investigate before playing.

Two file sets replace whole vanilla files instead, because the engine reads
them by file path: the 16 state-region files and `00_buy_packages.txt`. They
log nothing, so drift there is silent.

## Shadowed keys (65)

| BOI file | Keys | Vanilla source | Change |
|---|---:|---|---|
| `common/production_methods/00_boi_rail_port_overrides.txt` | 10 | `11_private_infrastructure.txt` | `state_infrastructure_add` removed from the 3 port and 7 train PMs |
| `common/production_methods/00_boi_transport_overrides.txt` | 6 | `03_mines`, `04_plantations`, `09_misc_resource` | horse input on haulage PMs |
| `common/production_methods/00_boi_farm_overrides.txt` | 3 | `02_agro.txt` | horse input on farm tool PMs |
| `common/production_methods/00_boi_subsistence_overrides.txt` | 2 | `12_subsistence.txt` | horse output on pasture PMs |
| `common/production_methods/00_boi_urban_transport_overrides.txt` | 1 | `06_urban_center.txt` | horse input on `pm_no_public_transport` |
| `common/combat_unit_types/00_boi_cavalry_overrides.txt` | 4 | `00_land_combat_unit_types.txt` | horse upkeep on the four cavalry types |
| `common/mobilization_options/00_boi_supply_overrides.txt` | 2 | `00_mobilization_option.txt` | Extra Supplies needs potential horse supply and costs 0.5 horses; Basic Supplies is an unchanged copy, kept so the options list keeps vanilla's order |
| `common/mobilization_options/00_boi_transport_overrides.txt` | 3 | `00_mobilization_option.txt` | Forced March, Truck and Rail Transport exclusive with Horse-Drawn Transport |
| `common/buildings/00_boi_railway_ai_override.txt` | 1 | `11_private_infrastructure.txt` | `building_railway`: price-scaled `ai_value`; no auto-expansion on infrastructure deficit |
| `common/buildings/00_boi_housing_rural_generated.txt` | 33 | `02_agro`, `03_mines`, `04_plantations`, `09_misc_resource`, `12_subsistence`, `15_special` | **generated**: housing PM group added to 27 rural workplaces and 6 subsistence-style buildings (1.15 adds the copper mine, and the Cossack Host as subsistence) |

GUI types are first-read-wins per type, without a log line:

| BOI file | Type | Change |
|---|---|---|
| `gui/01_boi_panel_military.gui` | `mobilization_widget` | wrapping grid so the extra horse options fit (loses to Community Mod Framework 1.65.0 when that is loaded, which has its own wrap) |
| `gui/01_boi_military_formation_panel.gui` | `military_formation_panel` | bulk-selection grid wrap 3 → 2 |

## Whole-file replacements (generated)

| Files | Why | Regenerate with |
|---|---|---|
| `map_data/state_regions/*.txt` (16) | `building_boi_horse_ranch` inserted into all `arable_resources` lists (675 on 1.13, 676 on 1.15) (a rural building missing from that list cannot be built), plus the Horse-Breeding Traditions trait | `tools/REGENERATE.md` §1, then `tools/Add-HorseBreedingTrait.ps1` |
| `common/buy_packages/00_buy_packages.txt` | all 99 `wealth_N` packages, vanilla needs plus housing demand | `tools/Build-Housing.ps1` |

`tools/Build-Housing.ps1` also writes the 31-building shadow above,
`common/modifier_type_definitions/zz_boi_housing_generated.txt`,
`common/scripted_effects/zz_boi_housing_fallback_generated.txt` and the 1836
residential seed `common/history/buildings/zz_boi_housing_seed_generated.txt`, whose
demand input may need measuring again (`tools/REGENERATE.md` §3).

Any future pop need (luxury horse demand, for instance) must go through
`Build-Housing.ps1`; a second copy of `00_buy_packages.txt` silently replaces
the first.

## The 1836 seed (generated)

`common/history/buildings/zz_boi_buildings.txt` places **20 Public Works (40
levels), 139 Harbour Works (141 levels) and 216 Horse Ranches (492 levels)**.
Works replace only the infrastructure taken off railways and ports, and ranches
are deliberately scarce by horse history. It is built by `tools/gen_seed.awk`,
`tools/curate.awk` and `tools/Set-HorseSeedTiers.py`; see `tools/REGENERATE.md` §2.
History seeding is used, not an `on_game_started` effect, because only
buildings created during world initialisation start staffed.

Horse Ranches are curated (core, sole owner, low industry, arable ≥ 25). A
state's real arable land depends on incorporation and province ownership, not
the state region's declared figure; seeding on the declared figure
over-allocated 10 states and crashed world initialisation.

## After every game patch

1. Re-diff every shadowed key above against the new vanilla source with
   `python tools/Compare-ShadowBodies.py --summary`, then without `--summary`
   for any block that shows vanilla lines BOI lacks. `tools/Test-ShadowSources.ps1`
   only catches renamed and removed keys, and only for 31 of them.
   Also check every `tools/*.tsv` seed input for state regions the patch
   renamed or split (match old and new regions by province ids).
2. Regenerate the state regions, re-run `Add-HorseBreedingTrait.ps1`, then
   regenerate the seed (`tools/REGENERATE.md`).
3. Re-run `tools/Build-Housing.ps1`.
4. Re-measure the housing seed demand (`tools/Get-HousingSeedDemand.py`; it
   needs a one-year run with the housing seed emptied), then re-run step 3.
5. Run `tools/Validate-All.ps1`, then a headless run
   (`tools/Test-Headless.ps1`) and compare the `Duplicated key` count with 65.

## Conflicts

Any mod that edits the 16 state-region files, buy packages, the 31 housing
buildings, or any key in the shadow table conflicts with BOI. Community Mod
Framework is compatible (`tools/Test-CMFCompatibility.ps1`, CMF 1.65.0).

## Defines

`common/defines/zz_boi_defines.txt` overrides `NPops.INDIVIDUALS_PER_POP_INFRASTRUCTURE` (125,000 against vanilla's 100,000, a trial since 2026-11-03). Check that the key still exists after each patch.

## 1.15.0 patch log (2026-11-06)

Balance after the patch, 10 games in four passes, is in
[docs/reports/balance_6_Nov_2026_1.15/BALANCE_LOG.md](docs/reports/balance_6_Nov_2026_1.15/BALANCE_LOG.md).
It changed only seed data: 47 more Public Works levels and 7 more Horse Ranches.

- **State regions.** 1.15 renamed or split six Russian regions. Matched by
  province ids: Galich became Vologda (259 of 282 provinces), Tartaria became
  Saratov (all 46), Kaunas became Lithuania (all 23), Chukotka merged into
  Kamchatka, Oryol split into Oryol and Tula, and Kostroma was carved from
  Yaroslavl, Nizhny Novgorod and Galich. The 16 files were regenerated from 1.15
  (676 ranch whitelist entries, 12 Horse-Breeding Traditions).
- **Seed inputs.** `horse_seed_tiers.tsv`: Galich to Vologda, Tartaria to
  Saratov, Kostroma added at tier 3, and Semireche commented out because 1.15
  splits it between owners, so curation drops it. `horse_seed_holds.tsv`:
  Tartaria to Saratov, and Ural removed because 1.15 history incorporates it.
  `horse_seed_additions.tsv`: Oryol removed, since the split lets it pass curation
  by itself. `infrastructure_seed_plan.tsv`: Kaunas to Lithuania (Russia still
  holds the port province). Result: 216 ranches at 491 levels (492 before), with
  the works seed unchanged at 20 Public Works and 139 Harbour Works.
- **Shadows.** `building_railway` was rebuilt from the 1.15 block. 1.15 had
  rewritten its Trans-Siberian, Tsar and five-year-plan AI bonuses, and the 1.13
  copy silently undid that. The 30 hand-written PM, cavalry and mobilization
  shadows matched 1.15 apart from BOI's tagged changes. The 31 generated rural
  shadows were regenerated, because five 1.15 farm blocks had changed.
- **New 1.15 buildings.** The copper mine gets company housing, and it uses
  the shared `pm_road_carts` / `pm_rail_transport_mine`, so horse haulage already
  applies. The Cossack Host (`bg_cossack_host`, under `bg_ranching`) gets
  subsistence housing, because its base PM is subsistence-style.
- **Housing seed.** Re-measured on 1.15, because the 1.13 table named
  Galich, Tartaria, Kaunas, Chukotka and two Russian-owned Polish states that 1.15
  gives to Poland.
