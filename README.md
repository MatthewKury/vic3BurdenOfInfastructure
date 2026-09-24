# Burden of Infrastructure

**Burden of Infrastructure** is a Victoria 3 mod that makes infrastructure an ongoing public expense. Railways and ports remain useful for transport and trade, while separate Public Works and Harbour Works buildings provide infrastructure at a cost to the state. Horses support early roads, rural haulage, and cavalry.

This is an experimental release for **Victoria 3 1.13.x**. The mod descriptor declares version `0.1` and support for `1.13.*`. It has been checked against the locally installed game version 1.13.11, but longer campaigns and AI behavior still need testing.

## What the mod adds

| Addition | Role |
| --- | --- |
| **Horses** | A tradeable good used by early infrastructure methods, some rural production methods, and cavalry. |
| **Horse Ranches** | Produce horses through a three-step breeding method progression. |
| **Public Works** | Government-funded land infrastructure, from cart roads to modern highways. |
| **Harbour Works** | Government-funded coastal infrastructure, from lighters to electrified quays. |
| **Horse-Breeding Traditions** | A regional state trait that improves horse output. |

Existing railway and port production methods no longer provide infrastructure directly. Several existing farm, mine, plantation, subsistence, urban transport, and cavalry definitions are adjusted to account for horses. The 1836 setup includes starting Public Works, Harbour Works, and Horse Ranches so the new supply chain can function from the beginning of a campaign.

The mod includes distinct icons for horses, the three new buildings, and Horse-Breeding Traditions. A separate texticon definition displays the horse good in compact UI text, such as budget details.

## Installation and use

1. Place this mod in your Victoria 3 local mod directory and enable **Burden of Infrastructure** in a launcher playset.
2. Start a **new 1836 campaign**. The starting buildings are created during world initialization; an existing save will not receive that initial setup.
3. Check Horse Ranches for horse supply and Public Works or Harbour Works for infrastructure capacity. These public buildings consume goods and wages, so their cost appears in the government budget.

Only English localization is included at present.

## Compatibility and development status

The mod copies all 16 base-game state-region files to make Horse Ranches buildable, and it overrides selected game definitions. Other mods that change those same files or definitions may conflict. These copies and overrides should be reviewed after each Victoria 3 patch. See [regeneration instructions](tools/REGENERATE.md) and [validation instructions](tools/VALIDATION.md).

A short Portugal debug-mode game ran without an obvious gameplay failure, but that is only a smoke test. AI construction, market balance, long campaigns, and compatibility with other mods still need evaluation. See [balance notes](BALANCE.md) and the [development plan](DEVELOPMENT_PLAN.md) for the design and remaining work.

## AI assistance and artwork disclaimer

**AI assistance was used to write and revise parts of the mod's scripting and to generate the custom icons.** The horse good, Horse Ranch, Public Works, Harbour Works, and Horse-Breeding Traditions icons are provisional AI-assisted artwork. They were made using base-game icons as visual references. **The hope is to replace these icons with original artwork in a later update.** Other production method icons and some interface art still reference base-game assets.

AI-assisted work can contain mistakes. The scripts and artwork should be judged by how they behave and appear in game, and issues are welcome.

## Project files

- [Balance and design notes](BALANCE.md)
- [Development plan](DEVELOPMENT_PLAN.md)
- [Regenerating game-version-dependent files](tools/REGENERATE.md)
- [Static validation](tools/VALIDATION.md)
