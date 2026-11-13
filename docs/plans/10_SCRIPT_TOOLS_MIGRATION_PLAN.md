# Fewer vanilla shadows: migrate to the database override tools

Written 2026-11-13. **This is the first thing to do next session**, at the user's request,
before any more design work on plan 11.

## Why

BOI changes vanilla by copying whole vanilla blocks into `00_boi_*` files that load first. This
is "first-read-wins" shadowing; see `VIC3_MODDING_LESSONS.md` §1. Every shadow:
- logs a "Duplicated key" line;
- has to be re-diffed after each patch (`tools/Compare-ShadowBodies.py`,
  `tools/Test-ShadowSources.ps1`);
- clashes with any other mod that touches the same block.

Locomotion: Land, Water, & Air (plan 09, part 5) uses `REPLACE:` and `INJECT:` prefixes:
- `REPLACE:` swaps a single vanilla entry;
- `INJECT:` adds to a vanilla entry, for example a PM group on `building_railway`, without
  copying it.

If these work on 1.15, most of BOI's shadows can shrink to the lines BOI actually changes.

## Steps

1. **Read the wiki page first:** <https://vic3.paradoxwikis.com/Mod_compatibility>.
   - Note every prefix it documents (for example `INJECT:`, `REPLACE:`, `TRY_INJECT:`,
     `TRY_REPLACE:`, `REPLACE_OR_CREATE:`, `INJECT_OR_CREATE:`; take the real list from the
     page), which databases support them, how a list inside an injected block behaves (appended
     or replaced), and how load order works between two mods that both inject.
   - Record the findings in `VIC3_MODDING_LESSONS.md` §1, replacing the "Possible alternative"
     note added 2026-11-13.
2. **Test the behaviour on 1.15** with a throwaway probe mod or a harness switch, before
   converting anything. Confirm in `error.log` and in game:
   - `REPLACE:` on a production method (for example a copy of `pm_steam_trains` with one number
     changed): no "Duplicated key" line, and the new value in the building panel.
   - `INJECT:` on a building: add a PM group to `building_urban_center` or `building_railway`.
     Check that the vanilla groups survive and the panel shows the new one.
   - `INJECT:` that changes one field of a vanilla PM (for example `building_modifiers`): is the
     sub-block merged or replaced?
   - The databases BOI shadows today: production methods, buildings, combat unit types,
     mobilization options. Check each one, since support may differ by database.
   - Also `common/static_modifiers` (vanilla's `incorporated_state`), and a production method
     group (`INJECT:` a new PM into `pmg_public_transport`). Plan 11 needs both.
   - Interaction with a full-copy shadow of the same key from another mod.
   - The headless harness (`tools/Test-Headless.ps1`) for a short run, checking the errors it
     reports.
3. **Inventory the shadows** and mark each one REPLACE, INJECT or keep:

   | File | Blocks | Likely conversion |
   |---|---|---|
   | `common/production_methods/00_boi_rail_port_overrides.txt` | railway and port PMs | REPLACE, or INJECT if partial merges work |
   | `common/production_methods/00_boi_transport_overrides.txt` | transport-using PMs | same |
   | `common/production_methods/00_boi_farm_overrides.txt` | farm PMs | same |
   | `common/production_methods/00_boi_subsistence_overrides.txt` | subsistence PMs | same |
   | `common/production_methods/00_boi_urban_transport_overrides.txt` | `pm_no_public_transport` | same |
   | `common/buildings/00_boi_ownership_overrides.txt` | ownership buildings (`investment_scores`) | INJECT |
   | `common/buildings/00_boi_railway_ai_override.txt` | `building_railway` AI rule | INJECT or REPLACE |
   | `common/combat_unit_types/00_boi_cavalry_overrides.txt` | cavalry upkeep | INJECT or REPLACE |
   | `common/mobilization_options/00_boi_supply_overrides.txt`, `00_boi_transport_overrides.txt` | mobilisation options | depends on test |
   | `common/buy_packages/00_buy_packages.txt` | pop buy packages | check: may be a full-file override |

   Defines (`zz_boi_defines.txt`), history (`zz_*`) and on_actions already merge or use their
   own rules. Leave them alone.
4. **Convert one file at a time.** After each:
   - launch;
   - check `error.log` for parse errors and for the "Duplicated key" line going away;
   - spot-check the changed values in game or in a harness dump.

   Keep each file's banner comment, and update it to say which mechanism it uses.
5. **Retire or adapt the shadow tooling.** `Compare-ShadowBodies.py` and
   `Test-ShadowSources.ps1` compare full copies. With REPLACE, a re-diff is still needed (a
   replaced block hides vanilla changes); with INJECT, much less.
6. **Regression run:** a 10-year headless game against the last baseline. Then commit, and
   list the converted files in the commit message.

7. **Then write the Public Works implementation plan,**
   `docs/plans/12_PUBLIC_WORKS_HUB_IMPLEMENTATION.md`, from plan 11 parts 13–14, using what
   the tests showed. The user asked for it to wait until after these script tests (2026-11-13).
   Its phase 1 adds more prototype tests (plan 11, part 13):
   - does `state_infrastructure_mult` scale the population floor;
   - can a scripted employment modifier change a building's jobs;
   - does `most_profitable` pick the cheapest PM on a building that sells nothing;
   - can script read the population floor.

   Where they fit, run them alongside step 2's tests.

## Not in scope

- Any balance or design change. Plan 11 (the Public Works hub) comes after this, and will
  itself use `INJECT:` where it touches vanilla. Its penalty could go on vanilla's
  `incorporated_state` / `unincorporated_state` modifiers, so test `INJECT:` on
  `common/static_modifiers` too.
