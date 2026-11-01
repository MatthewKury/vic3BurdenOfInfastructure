# Patching notes

What Burden of Infrastructure overrides in the base game, and what to redo after
every Victoria 3 patch. Checked against 1.13.11 on 2026-10-31.

## How the overrides work

Keyed databases are **first-read-wins**. A `00_boi_*` file loads before
vanilla's `01_`+ files, so its copy of a key wins and the vanilla copy is
discarded with one harmless `error.log` line: `Duplicated key X will not be
created`. Every shadow is a full copy of the vanilla block with BOI's changes
tagged `# BOI:`.

**Expected count: 63 `Duplicated key` lines per launch** (headless run
`20261030-174303_mod`, 1.13.11). A different count after a patch means a key
was renamed, removed or added; investigate before playing.

Two file sets replace whole vanilla files instead, because the engine reads
them by file path: the 16 state-region files and `00_buy_packages.txt`. They
log nothing, so drift there is silent.

## Shadowed keys (63)

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
| `common/buildings/00_boi_housing_rural_generated.txt` | 31 | `02_agro`, `03_mines`, `04_plantations`, `09_misc_resource`, `12_subsistence` | **generated**: housing PM group added to 26 rural workplaces and 5 subsistence buildings |

GUI types are first-read-wins per type, without a log line:

| BOI file | Type | Change |
|---|---|---|
| `gui/01_boi_panel_military.gui` | `mobilization_widget` | wrapping grid so the extra horse options fit (loses to Community Mod Framework 1.65.0 when that is loaded, which has its own wrap) |
| `gui/01_boi_military_formation_panel.gui` | `military_formation_panel` | bulk-selection grid wrap 3 → 2 |

## Whole-file replacements (generated)

| Files | Why | Regenerate with |
|---|---|---|
| `map_data/state_regions/*.txt` (16) | `building_boi_horse_ranch` inserted into all 675 `arable_resources` lists (a rural building missing from that list cannot be built), plus the Horse-Breeding Traditions trait | `tools/REGENERATE.md` §1, then `tools/Add-HorseBreedingTrait.ps1` |
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
levels), 139 Harbour Works (141 levels) and 225 Horse Ranches (857 levels)**,
replacing only the infrastructure taken off railways and ports. It is built by
`tools/gen_seed.awk` and `tools/curate.awk`; see `tools/REGENERATE.md` §2.
History seeding is used, not an `on_game_started` effect, because only
buildings created during world initialisation start staffed.

Horse Ranches are curated (core, sole owner, low industry, arable ≥ 25). A
state's real arable land depends on incorporation and province ownership, not
the state region's declared figure; seeding on the declared figure
over-allocated 10 states and crashed world initialisation.

## After every game patch

1. Re-diff every shadowed key above against the new vanilla source;
   `tools/Test-ShadowSources.ps1` catches renamed and removed keys, not edits
   inside a block.
2. Regenerate the state regions, re-run `Add-HorseBreedingTrait.ps1`, then
   regenerate the seed (`tools/REGENERATE.md`).
3. Re-run `tools/Build-Housing.ps1`.
4. Run `tools/Validate-All.ps1`, then a headless run
   (`tools/Test-Headless.ps1`) and compare the `Duplicated key` count with 63.

## Conflicts

Any mod that edits the 16 state-region files, buy packages, the 31 housing
buildings, or any key in the shadow table conflicts with BOI. Community Mod
Framework is compatible (`tools/Test-CMFCompatibility.ps1`, CMF 1.65.0).
