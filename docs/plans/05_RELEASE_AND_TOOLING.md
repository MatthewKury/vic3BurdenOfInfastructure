# Plan 5: Release, tooling and hygiene

Updated: 2026-10-24. Back to the [overview](../OVERVIEW.md).

Condensed from the development plan's tooling and hygiene sections, the
2026-09-21 review's documentation notes, and the tools READMEs.

## What is done

- **Git repository** and **README** exist.
- **Validation entry point:** `tools/Validate-All.ps1` (2026-09-23) runs
  structure, BOM and brace checks, committed-seed counts, the 675-state horse
  safety audit, installed-vanilla shadow drift, the housing regression suite and
  the water module checks. See `tools/VALIDATION.md`.
- **Seed reproducibility:** `tools/gen_seed.awk` keeps the sorted input order, so
  identical inputs give byte-identical output. `tools/Test-SeedReproducibility.ps1`
  proves it on demand. Keep the `sort > /tmp/regions.txt` step.
- **Regeneration docs:** `tools/REGENERATE.md` covers state-region copies, seeds
  and trait assignment after a patch.
- **CMF compatibility:** Community Mod Framework is an optional companion, not a
  dependency. A static check found no shared paths or keys against CMF 1.65.0
  (`tools/Test-CMFCompatibility.ps1`). Rerun after CMF updates.
- **Descriptor and metadata versions** both read `0.1`.
- Audit generators for horses and infrastructure:
  `Get-HorseBalance.ps1`, `Get-HorseConsumption.ps1`,
  `Get-StartingInfrastructure.ps1`, `Audit-HorseSeed.ps1`.

## What is left

### Before any public release

- [ ] Add `.gitignore` (at least `.claude/settings.local.json`, which is
      machine-local; it is currently untracked but not ignored).
- [ ] Add `CHANGELOG.md`.
- [ ] Add `PATCHING.md` and move the long `patch_sensitivity_note` out of
      `.metadata/metadata.json` into it (the game logs the custom member as
      skipped).
- [ ] Add a licence before publishing source or Workshop assets.
- [ ] Replace provisional AI-assisted icons with original art (horse good, three
      buildings, Horse-Breeding Traditions, water and housing icons).
- [ ] Decide whether to fix the folder spelling `BurdenOfInfastructure`,
      allowing for launcher paths that depend on it.
- [ ] Consider compatibility patches for major map mods (the 16 state-region
      copies are the largest conflict surface).
- [ ] Keep descriptor and metadata versions aligned each release.

### Validation still missing

- [ ] Full assignment-level comparison of every shadowed vanilla block,
      ignoring tagged BOI changes.
- [ ] Reference checks for all techs, laws, goods, modifiers, PMs and graphics.
- [ ] Expected duplicate-key count from a real game launch, to compare against.
- [ ] A fresh 1.13.11 startup log (the last logs on file were from 1.13.10).
- [ ] After every regeneration, an actual startup check: the ranch curation
      rules are heuristics, not a calculation of usable arable land.

### Documentation fixes

- [ ] `BALANCE.md`: remove the stray fragment of the old cavalry upkeep table;
      rename `pm_container_wharves` to Electrified Quays and reconcile its tech
      tier; drop or relabel the £60 horse scenario (the price ceiling for a £30
      good is £52.50; model shortage penalties separately); say railway and port
      *recipes* are unchanged rather than their profitability; keep "goods
      margin" distinct from profit after wages.
- [ ] Keep this plan set current: when something ships or a test runs, update
      the relevant plan's status and test log, and the overview's status board.
