# Burden of Infrastructure

**Burden of Infrastructure** is a Victoria 3 mod that makes infrastructure an ongoing public expense. Railways and ports remain useful for transport and trade, while separate Road Works, Rail Works and Harbour Works buildings provide infrastructure at a cost to the state. Horses support early roads, rural haulage, and cavalry.

This is an experimental release for **Victoria 3 1.13.x**. The mod descriptor declares version `0.1` and support for `1.13.*`. It has been checked against the locally installed game version 1.13.11, but longer campaigns and AI behavior still need testing.

## What the mod adds

| Addition | Role |
| --- | --- |
| **Horses** | A tradeable good used by early infrastructure methods, some rural production methods, and cavalry. |
| **Horse Ranches** | Produce horses through a three-step breeding method progression. |
| **Road Works** | Government-funded land infrastructure, from cart roads to modern highways, running on horses and later automobiles. |
| **Rail Works** | Government-funded infrastructure in states with a railway, running on transportation. |
| **Harbour Works** | Government-funded coastal infrastructure, from lighters to electrified quays. |
| **Horse-Breeding Traditions** | A regional state trait that improves horse output. |
| **Horse mobilization options** | Horseback Reconnaissance and Horse-Drawn Transport consume horses while mobilized. |
| **Public Works Financing laws** | Statute Labour, Tolls and Dues, or State Funding decide who pays for all three works buildings: peasants, users, or the treasury. |
| **Housing and Luxury Housing** | Local goods every household buys, supplied by subsistence buildings, company housing, and new residential buildings. |
| **Residential buildings** | 15 building types in working-class, luxury and suburban ladders, unlocked by technology, plus a government-funded Temporary Shelter Programme. Each uses infrastructure, and each step uses less per unit of housing. |
| **Light and Heat** | The one choice on a housing building: burn wood, oil or electricity for extra housing. Slums can only use wood. |
| **Housing laws and decree** | Employer Housing and Residential Standards law groups, and an Emergency Accommodation decree. |

Existing railway and port production methods no longer provide infrastructure directly. Several existing farm, mine, plantation, subsistence, urban transport, and cavalry definitions are adjusted to account for horses. Horseback Reconnaissance is a weaker early alternative to Motorized Reconnaissance. Horse-Drawn Transport gives the movement bonus of Forced March with a smaller mobilization speed bonus, no morale penalty, and a horse cost; it is mutually exclusive with the other transport choices. The 1836 setup includes starting Road Works, Harbour Works, and Horse Ranches so the new supply chain can function from the beginning of a campaign.

Extra Supplies also requires potential horse supply and consumes 0.5 horses while mobilized, alongside its existing grocery cost.

A new economy law group, **Public Works Financing**, decides who pays for Road, Rail and Harbour Works. State Funding keeps the full cost on the treasury. Statute Labour and Tolls and Dues make the works cheaper but have side effects: Statute Labour lowers infrastructure output and raises peasant mortality, and Tolls and Dues improve infrastructure by 15% (through Road Works) but reduce market access. Each benefits a particular group: Landowners under Statute Labour, and the Petty Bourgeoisie and Industrialists (with Landowners) under Tolls and Dues. Interest groups take sides through new ideologies added at game start. Britain and the United States start with Tolls and Dues, France and Prussia with State Funding, and all other countries with Statute Labour.

Households also need **Housing**, a local good that cannot be traded between states. Basic Housing demand grows with wealth, and wealthier households also buy Luxury Housing. Subsistence buildings supply a little; rural workplaces can run company housing; and residential buildings supply the rest. Residential buildings use a lot of infrastructure. A building's structure can't be upgraded, so the way to recover infrastructure is to clear old housing and build a newer type. Slums raise mortality and lower migration; town houses and suburbs attract migrants. Suburbs consume horses, transportation or automobiles according to their type.

The mod includes distinct icons for horses, the infrastructure buildings, Horse-Breeding Traditions, the three financing laws, both housing goods, and the residential buildings. Rail Works and ten residential buildings use tinted placeholders for now. Separate texticon definitions display the horse and housing goods in compact UI text, such as budget details.

## Installation and use

1. Place this mod in your Victoria 3 local mod directory and enable **Burden of Infrastructure** in a launcher playset.
2. Start a **new 1836 campaign**. The starting buildings are created during world initialization; an existing save will not receive that initial setup.
3. Check Horse Ranches for horse supply and Road Works, Rail Works or Harbour Works for infrastructure capacity. These public buildings consume goods and wages, so their cost appears in the government budget. They cannot be downsized once built, by the player or the AI: the AI's budget cuts otherwise demolished them even in states short of infrastructure. AI countries also queue new levels automatically in their worst-short states, through a hidden monthly event.

Only English localization is included at present.

## Compatibility and development status

Housing was developed as a separate prototype and merged into this mod on 2026-10-30; if an older playset lists **BOI Housing Prototype**, remove that entry. Housing has had first balance passes only, and buying out private housing before demolition is not enforced. See [housing tests](docs/HOUSING_TESTING.md) and the [housing plan](docs/plans/04_HOUSING.md).

It overrides one define, `INDIVIDUALS_PER_POP_INFRASTRUCTURE` (125,000 against 100,000). The mod copies all 16 base-game state-region files to make Horse Ranches buildable, and it overrides selected game definitions. Housing replaces the base game's household buy-package file and adds a housing production method group to 31 rural and subsistence buildings. Other mods that change those same files or definitions may conflict. These copies and overrides should be reviewed after each Victoria 3 patch. See the [patching notes](PATCHING.md) for the full list, plus the [regeneration instructions](tools/REGENERATE.md) and [validation instructions](tools/VALIDATION.md).

Testing so far: a short Portugal debug-mode game, and automated 10-year observer runs (1836–1846) that load without mod errors and in which AI countries keep up with infrastructure demand. Nobody has played a full campaign yet. Long-term AI behaviour, market balance, and compatibility with other mods still need evaluation. See [balance notes](BALANCE.md) and the [planning overview](docs/OVERVIEW.md) for the design and remaining work.

## Vanilla overrides and mod conflicts

Every place where BOI replaces base-game content. Any other mod that changes the same thing conflicts with BOI: whichever loads first or last wins, depending on the file type, and the other mod's change, or BOI's, is lost. All of these must be re-checked after a Victoria 3 patch; [PATCHING.md](PATCHING.md) has the procedure. "Generated" means a script rebuilds it from the game files.

| What BOI replaces | Files | Conflicts with mods that… | Rebuild with |
| --- | --- | --- | --- |
| All 16 state-region files (Horse Ranch arable lists, Horse-Breeding Traditions trait) | `map_data/state_regions/*.txt` | edit state regions: map mods, resource mods, new-state mods | `tools/REGENERATE.md` §1 |
| Household buy packages (housing demand) | `common/buy_packages/00_buy_packages.txt` | change pop needs or buy packages | `tools/Build-Housing.ps1` |
| 33 rural and subsistence buildings (housing PM group) | `common/buildings/00_boi_housing_rural_generated.txt` | edit farms, mines, plantations, logging, fishing, subsistence buildings | `tools/Build-Housing.ps1` |
| `building_railway` (AI value) | `common/buildings/00_boi_railway_ai_override.txt` | edit railways | by hand |
| `building_manor_house`, `building_financial_district` (housing investment scores, 2026-11-08) | `common/buildings/00_boi_ownership_overrides.txt` | edit ownership buildings or investment: economy overhauls | `tools/Build-OwnershipOverrides.py` |
| 34 map city-type files: Horse Ranch, Road, Rail and Harbour Works models (2026-11-08), 15 of them from DLCs | `gfx/map/city_data/city_types/*.txt` | change city graphics, or add buildings with models: graphics mods, building mods | `tools/Build-CityTypes.py` |
| 22 production methods (rail and port infrastructure removed; horse inputs on haulage, farms, pasture, urban transport) | `common/production_methods/00_boi_*_overrides.txt` | edit railway, port, mine, plantation, farm, subsistence or urban-centre PMs | by hand |
| 4 cavalry combat units (horse upkeep) | `common/combat_unit_types/00_boi_cavalry_overrides.txt` | edit land units: military overhauls | by hand |
| 5 mobilization options | `common/mobilization_options/00_boi_*_overrides.txt` | edit mobilization options | by hand |
| 3 GUI types (mobilization grid, formation panel, building details header) | `gui/01_boi_*.gui` | change those panels (Community Mod Framework is compatible) | by hand |
| One define, `INDIVIDUALS_PER_POP_INFRASTRUCTURE` | `common/defines/zz_boi_defines.txt` | change the same define | by hand |

**Not overrides, but shared hooks:** BOI reads the vanilla Labour Rights laws (`law_no_workers_rights`, `law_regulatory_bodies`, `law_worker_protections`) to decide company housing, without changing them (2026-11-08). A mod that renames or replaces those laws leaves company housing on Work Camps. BOI's on-action hooks only add to `events = { }` lists, which merge with other mods'.

**DLC city types:** the 15 DLC city-type copies keep their `has_dlc_feature` triggers, so a player without a DLC never gets that city type. Their mesh names still load, though, and may log missing-asset errors for players without the DLC. Not yet tested.

## AI assistance and artwork disclaimer

**AI assistance was used to write and revise parts of the mod's scripting and to generate the custom icons.** The horse good, Horse Ranch, Road Works, Rail Works, Harbour Works, Horse-Breeding Traditions, financing law, housing good, and residential building icons are provisional AI-assisted artwork. Earlier icons were made using base-game icons as visual references. **The hope is to replace these icons with human-created artwork in a later update.** Other production method icons and some interface art still reference base-game assets.

On 2026-11-08, the following 11 building images were generated with OpenAI's built-in image generation tool to replace tinted, text-labeled placeholders. Each was generated separately from a text prompt, without supplying a reference image to the tool:

| Building | AI-generated image filename |
| --- | --- |
| Regulated Terraces | `boi_regulated_terraces.png` |
| Tenement Blocks | `boi_tenement_blocks.png` |
| Model Dwellings | `boi_model_dwellings.png` |
| Municipal Estates | `boi_municipal_estates.png` |
| Elevator Apartments | `boi_elevator_apartments.png` |
| Boulevard Apartments | `boi_boulevard_apartments.png` |
| Elevator Residences | `boi_elevator_residences.png` |
| Railway Suburbs | `boi_railway_suburbs.png` |
| Streetcar Suburbs | `boi_streetcar_suburbs.png` |
| Motor Suburbs | `boi_motor_suburbs.png` |
| Rail Works | `boi_rail_works.png` |

The full-resolution images are in [art/buildings](art/buildings/). This disclosure also covers their resized PNG and DDS versions in `gfx/interface/icons/building_icons/`. The [generation prompts and export details](art/buildings/PROMPTS.md) are recorded alongside the source images.

AI-assisted work can contain mistakes. The scripts and artwork should be judged by how they behave and appear in game, and issues are welcome.

## Project files

- [Balance and design notes](BALANCE.md)
- [Patching notes: what the mod overrides](PATCHING.md)
- [Planning overview and execution plans](docs/OVERVIEW.md)
- [Regenerating game-version-dependent files](tools/REGENERATE.md)
- [Static validation](tools/VALIDATION.md)
- [Headless ensembles: baseline database and reports](tools/ensembles/README.md)
- [Vanilla baseline report, 1836–1846](docs/reports/vanilla_1836_1846/REPORT.md)
- [Balance log, 3 Nov 2026](docs/reports/balance_3_Nov_2026/BALANCE_LOG.md)
- [Century runs report](docs/reports/century_3_Nov_2026/REPORT.md)
