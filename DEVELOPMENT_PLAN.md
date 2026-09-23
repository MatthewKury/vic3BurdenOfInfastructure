# Burden of Infrastructure — Development Plan

> **Status:** Planning document. This file records review findings, proposed
> improvements, and playtest questions. It is not an implementation record or
> a statement that the proposed changes have already been made.

Last reviewed against Victoria 3 **1.13.11** on 2026-08-23.

## Current assessment

The mod is a strong, well-documented alpha. Its core design is coherent, the
custom content and vanilla overrides are clearly separated, and its generated
files have reproducible source instructions. The main remaining risks are
patch-sensitive overrides, AI behavior, opening horse-market balance, and the
large compatibility footprint created by overriding every state-region file.

At the time of this review:

- all referenced graphics were present;
- braces were balanced across the script files;
- all `.txt` and localization files had a UTF-8 BOM;
- generated counts were correct: 675 horse-ranch whitelist entries, 675 Public
  Works, 372 Harbour Works, and 236 Horse Ranches;
- all 16 state-region copies matched vanilla 1.13.11 after removing the intended
  Horse Ranch insertion;
- 21 of the 22 keyed vanilla shadows showed no assignment-level upstream drift
  after ignoring the intended BOI changes;
- the available game logs were from 1.13.10 and therefore do not constitute a
  current 1.13.11 smoke test.

## Immediate fixes

### 1. Refresh the hussar override for 1.13.11

The vanilla `combat_unit_type_hussars` block gained the following in 1.13.11:

```text
formation_modifier = {
	military_formation_mobilization_speed_mult = 0.25
	military_formation_army_movement_speed_mult = 0.25
}
```

`common/combat_unit_types/00_boi_cavalry_overrides.txt` is still based on the
1.13.10 block. Because the mod shadows the full key, the current override removes
these vanilla bonuses. Copy the new block into the BOI override, preserve the
horse-upkeep addition, and run a new 1.13.11 smoke test.

### 2. Horse Ranch PM selection

The previous `most_productive` selection was appropriate for government cost
centres whose output is a state modifier, but not for a privately operated Horse
Ranch with salable output and fluctuating input prices.

Implemented on 2026-09-23: the Horse Ranch group uses `most_profitable`.
Public Works and Harbour Works retain `most_productive`, since their output is
a state modifier rather than a salable good. Test horse-market behavior in play.

### 3. Public Works maximum-level assumption

Implemented on 2026-09-23: Public Works and Harbour Works intentionally have
no maximum level, matching vanilla Railways. `stateregion_max_level = yes` does
not create a cap by itself; it only changes the scope for buildings that also
set `has_max_level = yes`. This is an assumption to revisit after campaign
testing. Do not add `has_max_level = yes` without confirming how the associated
dynamic maximum-level modifier is initialized.

## AI behavior work

Implemented on 2026-09-23: Public Works and Harbour Works now multiply their
base `ai_value` by spare-infrastructure urgency and a smaller input-price factor.
See `common/script_values/50_boi_ai_values.txt` and `tools/AI_VALIDATION.md`.
Railroad base priority responds to transportation prices, and its auto-expansion
no longer responds to infrastructure deficits. Campaign behavior is unverified.

Implemented on 2026-09-23: Public Works and Harbour Works auto-expand when the
state has fewer than 5 spare infrastructure, provided the state owner is not in
default, its current building is at least 90% staffed, and no instance of that
same building is already under construction. The toggle remains opt-in. Wider
budget safeguards remain untested.

Investigate infrastructure-aware AI and auto-expansion rules using:

- the implemented spare-infrastructure priority bands;
- government budget health;
- a buffer above current infrastructure usage to avoid oscillation.

The desired result is for the AI to build capacity in states approaching an
infrastructure deficit without spamming expensive Public Works in states that
already have ample capacity.

## Horse-system architecture: separate Horse Ranch retained

The separate rural Horse Ranch requires overriding all 16 vanilla state-region
files so the building appears in every `arable_resources` list. This is the
mod's largest compatibility cost and is likely to conflict with map and resource
mods.

Decision recorded on 2026-09-23: retain the separate Horse Ranch building. Its
distinct identity and direct competition for arable land are part of the mod's
design. Keep the state-region overrides, document their compatibility impact
prominently, and consider patches for major map mods before release.

### Chosen approach: Keep the separate Horse Ranch

Advantages:

- strongest flavor and visual identity;
- horse production competes explicitly for construction and arable land;
- straightforward output balancing.

Costs:

- 16 full-file state-region overrides;
- generated rural-building history and the associated arable-land crash risk;
- substantial patch and compatibility debt.

### Rejected for this mod: Integrate horses into Livestock Ranches

Possible implementations are a horse-breeding PM group attached to
`building_livestock_ranch`, or horse output added to selected livestock PMs.

Advantages:

- eliminates the 16 state-region overrides;
- removes Horse Ranch history seeding and its arable-land risk;
- uses already-whitelisted and widely seeded rural buildings.

Costs:

- less distinct flavor;
- requires a vanilla Livestock Ranch building or PM shadow;
- PM profitability and AI choice would need careful testing.

This approach is not planned unless the separate-building architecture proves
untenable in playtesting or compatibility work.

## Balance and playtest plan

The committed balance analysis shows seeded horse supply of 8,496 per week
against 13,500 demand from seeded Public Works alone, before extraction-building
haulage and cavalry. An opening shortage is therefore expected.

Test at least the following:

1. Confirm that every starting market has access to some horse production.
2. Record opening horse price, government expenses, infrastructure balance, and
   market access for Britain, Austria, Qing, Sokoto, and a small isolated market.
3. Record AI Public Works, Harbour Works, and Horse Ranch levels after 5, 20,
   and 50 years.
4. Check whether horse-starved coal, iron, logging, and plantation buildings
   become unprofitable or fail to hire.
5. Measure the effect of Public Works wages on countries with many low-population
   states.
6. Test whether Hereditary Bureaucrats creates a self-reinforcing Landowner
   political trap through state-funded aristocrat employment.
7. Test colonization: newly colonized states intentionally receive no seeded
   buildings and must remain recoverable through normal AI and player building.

Primary tuning controls, in order:

1. `pm_boi_cart_roads` horse input;
2. Public Works infrastructure output by tier;
3. Horse Ranch output by tier;
4. Public Works construction cost and employment;
5. subsistence-pasture horse output;
6. the number and distribution of seeded ranches.

## Tooling and validation

Implemented on 2026-09-23: `tools/Validate-All.ps1` provides one PowerShell
entry point for structure, committed-seed and installed-vanilla shadow-key
checks. `tools/Test-SeedReproducibility.ps1` optionally proves that saved seed
inputs reproduce byte-identical output. See `tools/VALIDATION.md`.

Remaining validation scope:

- full assignment-level comparison of every shadowed vanilla block while
  ignoring tagged BOI changes;
- generated state and building counts;
- state-region equality with vanilla after removing the Horse Ranch insertion;
- referenced technologies, laws, goods, modifiers, PMs, and graphics;
- expected duplicate-key count from an actual game launch;
- keeping metadata and descriptor versions aligned for each release.

Implemented on 2026-09-23: `tools/gen_seed.awk` preserves the sorted input order
of `owned_regions.txt`, yielding byte-for-byte identical output for identical
inputs. Keep the existing `sort > /tmp/regions.txt` regeneration step.

## Project and release hygiene

- Initialize a Git repository before further patch-sensitive work.
- Add `README.md`, `PATCHING.md`, `.gitignore`, and `CHANGELOG.md`.
- Move the long `patch_sensitivity_note` out of `.metadata/metadata.json` and
  into `PATCHING.md`; the game currently logs the custom metadata member as
  skipped.
- Keep the version in `descriptor.mod` aligned with `.metadata/metadata.json`
  (both are currently `0.1`).
- Keep `.claude/settings.local.json` out of version control. It is machine-local
  and currently contains a permission referring to `BoomAndBust` rather than
  this project.
- Consider correcting the directory spelling `BurdenOfInfastructure` before
  public distribution, while accounting for any launcher paths that depend on
  it.
- Add a license before publishing source or Workshop assets.

## Suggested order of work

1. Refresh the hussar shadow and perform a clean 1.13.11 startup test.
2. Change Horse Ranch AI PM selection and test horse-market behavior.
3. Playtest the implemented infrastructure-aware AI weights; investigate public
   auto-expansion, staffing and budget safeguards based on the results.
4. Maintain and document compatibility for the retained separate Horse Ranch.
5. Add automated drift and generated-file validation.
6. Establish version control and release documentation.
7. Run the multi-country balance matrix before declaring a beta.
