# Plan 5: Release, tooling and hygiene

Updated: 2026-11-01. Back to the [overview](../OVERVIEW.md).

Condensed from the development plan's tooling and hygiene sections, the
2026-09-21 review's documentation notes, and the tools READMEs.

## What is done

- **Git repository** and **README** exist.
- **Validation entry point:** `tools/Validate-All.ps1` (2026-09-23) runs
  structure, BOM and brace checks, committed-seed counts, the 675-state horse
  safety audit, installed-vanilla shadow drift, the housing regression suite.
  See `tools/VALIDATION.md`.
- **Headless harness** (2026-10-30): `tools/Test-Headless.ps1` runs unattended
  observer games with telemetry and, since 2026-10-31, the automated housing
  fixture checks. See `tools/headless-telemetry/README.md`. Run folders land in
  `tools/headless-runs/` (gitignored); the harness deletes its 340 MB autosave
  backup once it has restored the player's files. Kept runs: the baseline
  `20261030-104714_mod`, the control `20261030-092210_control`, the latest
  pre-cleanup run `20261030-174303_mod`, and the first run with housing fixtures
  `20261031-104008_mod`. Housing tuning, 2026-11-01: `20261101-094623_mod` (one-year
  demand measurement behind the seed), `20261101-081325_mod`, `20261101-085820_mod`,
  `20261101-095246_mod` and `20261101-100407_mod` (the kept seed).
- **Headless ensembles** (2026-10-31): `tools/Invoke-HeadlessEnsemble.ps1` runs
  the same observer game repeatedly with the quarterly all-country `ensemble`
  telemetry module. `tools/ensembles/Build-EnsembleDb.py` collects the runs into
  the self-contained `tools/ensembles/ensembles.sqlite` (gitignored), so the run
  folders can be deleted afterwards. Baseline: `vanilla_1836_1846`, 10 vanilla
  members, 1836 to 1846. See `tools/ensembles/README.md`.
  `tools/ensembles/Make-EnsembleReport.py` turns an ensemble, or an A-vs-B pair,
  into a Markdown report with SVG figures. The baseline report is
  `docs/reports/vanilla_1836_1846/REPORT.md`.
- **Seed reproducibility:** `tools/gen_seed.awk` keeps the sorted input order, so
  identical inputs give byte-identical output. `tools/Test-SeedReproducibility.ps1`
  proves it on demand. Keep the `sort > /tmp/regions.txt` step.
- **Regeneration docs:** `tools/REGENERATE.md` covers state-region copies, seeds
  and trait assignment after a patch.
- **Patching notes:** `PATCHING.md` (2026-10-31) lists every shadowed key and
  whole-file replacement, with the expected duplicate-key count (63 on
  1.13.11). The long `patch_sensitivity_note` in `.metadata/metadata.json` is
  now a short pointer to it.
- **CMF compatibility:** Community Mod Framework is an optional companion, not a
  dependency. A static check found no shared paths or keys against CMF 1.65.0
  (`tools/Test-CMFCompatibility.ps1`). Rerun after CMF updates.
- **Descriptor and metadata versions** both read `0.1`.
- **`.gitignore`** covers `tools/headless-runs/`, `tools/ensembles/*.sqlite` and
  `.claude/settings.local.json`.
- **Folder spelling:** the local folder was renamed from
  `BurdenOfInfastructure` to `BurdenOfInfrastructure` on 2026-10-31, and local
  references updated. The GitHub repository is still named
  `vic3BurdenOfInfastructure`; renaming it is deferred.
- **Documentation clean-up (2026-10-31):** BALANCE.md fixes (stray cavalry
  table, Electrified Quays name and era 4, price-ceiling scenario, recipes vs
  profitability, goods margin vs profit); law-icon prompts moved to
  `art/laws/PROMPTS.md`, vanilla reference images removed from the repo.
- Audit generators for horses and infrastructure:
  `Get-HorseBalance.ps1`, `Get-HorseConsumption.ps1`,
  `Get-StartingInfrastructure.ps1`, `Audit-HorseSeed.ps1`.

## What is left

### Before any public release

- [ ] Add `CHANGELOG.md`.
- [ ] Add a licence before publishing source or Workshop assets.
- [ ] Replace provisional AI-assisted icons with original art (horse good, three
      buildings, Horse-Breeding Traditions, Road Financing laws, housing goods
      and residential buildings).
- [ ] Rename the GitHub repository to match the corrected folder spelling, and
      update the local `origin` remote.
- [ ] Consider compatibility patches for major map mods (the 16 state-region
      copies are the largest conflict surface).
- [ ] Keep descriptor and metadata versions aligned each release.

### Validation still missing

- [ ] Full assignment-level comparison of every shadowed vanilla block,
      ignoring tagged BOI changes.
- [ ] Reference checks for all techs, laws, goods, modifiers, PMs and graphics.
- [ ] After every regeneration, an actual startup check: the ranch curation
      rules are heuristics, not a calculation of usable arable land.

### Ongoing

- [ ] Keep this plan set current: when something ships or a test runs, update
      the relevant plan's status and test log, and the overview's status board.
