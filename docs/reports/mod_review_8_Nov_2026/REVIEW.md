# Burden of Infrastructure — Mod Review

**Date:** November 8, 2026  
**Target:** Victoria 3 1.15  
**Scope:** Mod structure, implementation consistency, and potential gameplay weaknesses.

This records the review findings discussed on November 8, 2026. It is a review of the current files and existing test reports, supplemented by a static validation run. No new campaign was launched and no gameplay files were changed. Confirmed script or tooling issues are distinguished below from balance risks that still need playtesting.

## Overall assessment

The mod has a coherent design and substantial testing infrastructure. Connecting housing, horses, and public works creates meaningful economic dependencies. The main risk is that those dependencies become traps the AI or player cannot resolve.

Prioritize reliability, AI recovery, and balance validation before adding more features. The separation between generators and generated content is useful, but the regeneration and validation workflows need to preserve the same assumptions as the live mod.

## Highest-priority fixes

1. **Regeneration can undo infrastructure balance work.**

   The world-seed generator calls the starting-infrastructure calculation, which rewrites the committed infrastructure plan from vanilla replacement requirements. This can overwrite the calibrated additions made to accommodate housing demand. Keep the calculated baseline separate from persistent balance adjustments, then combine them when generating the final seed. Validation should check that the calibrated additions survive regeneration rather than only comparing the seed with a plan that the same workflow has just overwritten.

   Evidence: [Regenerate-WorldSeed.ps1](../../../tools/Regenerate-WorldSeed.ps1), [Get-StartingInfrastructure.ps1](../../../tools/Get-StartingInfrastructure.ps1), and the housing-shortfall additions documented in [REGENERATE.md](../../../tools/REGENERATE.md).

2. **The housing validation suite currently fails before its deeper checks.**

   The combined validation run stopped at `Expected 22 housing script files, found 28`. Structure, seed, horse-safety, and shadow-source checks passed before that failure. Replace the brittle file-count assertion with an explicit manifest or checks of the required definitions and relationships, then rerun the complete suite. Merely accepting the new count would not establish that the newly added mechanics are covered.

   Evidence: [Test-Housing.ps1](../../../tools/Test-Housing.ps1) and [Validate-All.ps1](../../../tools/Validate-All.ps1).

3. **Municipal Estates' AI rules disagree with their building requirements.**

   The construction event checks Socialism research but omits the government/economic laws required by the building's `possible` block. The AI can therefore attempt an ineligible build and consume its cooldown. Use a shared eligibility rule for the building and the scripted construction path, including technology and law requirements. The mismatch is confirmed in the files; this review did not reproduce the resulting behavior in a campaign.

   Evidence: [AI construction events](../../../events/boi_ai_infrastructure_events.txt), [AI construction triggers](../../../common/scripted_triggers/51_boi_ai_construction_triggers.txt), and [residential building definitions](../../../common/buildings/50_boi_housing_tiers_generated.txt).

4. **The Great Fire can create an excessive recovery burden.**

   The event removes entire housing and industrial building stacks. Selecting the smallest industrial stack does not bound the damage when a state has only one large industry. Its rebuilding option can also permanently prohibit Slums and Workers' Rows before replacement housing technology is available. Bound the damage or use a recoverable disruption, and require a viable replacement before imposing the permanent restriction. The deletion and eligibility behavior is visible in the script; its economic severity needs playtesting.

   Evidence: `boi_housing_events.24` in [housing events](../../../events/boi_housing_events.txt) and the restrictions in [residential building definitions](../../../common/buildings/50_boi_housing_tiers_generated.txt). Implement changes through [Build-HousingEvents.py](../../../tools/Build-HousingEvents.py) where it generates the event.

5. **Rehousing pledges need stronger state tracking.**

   Pledge markers do not identify the responsible country, and cleanup misses states lost through conquest or revolution. This can leave markers behind and interfere with a later owner's pledge. Partial territorial loss also leaves the original baseline and target unchanged. Track the responsible country and define how a pledge adjusts or lapses when states change hands.

   Progress currently counts aggregate building levels across the affected states. Construction in one state can satisfy the pledge while other cleared states remain short of housing, and building levels alone do not establish that the replacement housing is staffed and supplied. Consider tracking replacement capacity per affected state.

   Evidence: [displacement and pledge effects](../../../common/scripted_effects/54_boi_displacement_effects.txt), [pledge values](../../../common/script_values/54_boi_displacement_values.txt), and the [rehousing pledge journal entry](../../../common/journal_entries/52_boi_rehousing_pledge.txt).

## Gameplay weaknesses to investigate

- **Colonial infrastructure can be neglected.** The scripted AI recovery excludes unincorporated states, despite being the reliable construction mechanism for these custom government buildings. Economically important colonies need a recovery route. Consider prioritizing resource production, population, and shortage severity rather than incorporation alone. See [AI construction triggers](../../../common/scripted_triggers/51_boi_ai_construction_triggers.txt).

- **Public works are permanently costly commitments.** Disabling downsizing protects against the known AI behavior of demolishing needed infrastructure, but it also prevents players retiring obsolete or excessive capacity. **Keeping the lack of downsizing is important: retain `downsizeable = no`.** Adding a **mothball production method** might help by allowing a reversible reduction in staffing, input consumption, and infrastructure output while preserving the buildings. This should complement the downsizing restriction, not replace it. Its AI selection and reactivation behavior would need testing. See [works building definitions](../../../common/buildings/50_boi_buildings.txt).

- **Statute Labour scales awkwardly.** Twenty fully staffed Road Works levels grant statewide +20% agriculture/ranching throughput and +60% peasant mortality. With few peasants remaining, much of the social cost disappears while the production benefit remains. This is a scaling risk, not a demonstrated profitable exploit: wages, input costs, and market conditions still matter. Consider capping or tapering the benefit, or relating it to available peasant labour. Test commercial-farming states alongside peasant-heavy states. See [Road Works financing methods](../../../common/production_methods/50_boi_infrastructure.txt) and [Rail Works financing methods](../../../common/production_methods/50_boi_rail_works.txt).

- **Electrified Quays lacks a local electricity availability requirement.** The method consumes electricity but does not declare `required_input_goods = electricity`. Add the availability gate and check a coastal state with power against one without it, so modernization does not become an input-shortage trap. The omission is confirmed; automatic AI selection was not reproduced in this review. See [Harbour Works production methods](../../../common/production_methods/50_boi_harbour_works.txt).

## Mod structure and documentation

- **Use one override manifest to support patching and validation.** The broad vanilla override footprint makes updates expensive: state-region files, city-type files, household buy packages, and individual definitions all require review. A maintained manifest should identify each source, generator or manual owner, intended change, and validation coverage. Generate the documentation and validation inventory from it where practical. See [PATCHING.md](../../../PATCHING.md) and [REGENERATE.md](../../../tools/REGENERATE.md).

- **Reconcile documentation with the current release.** The README still introduces the mod as a Victoria 3 1.13 release, while the descriptor targets 1.15. Some descriptions and test claims also refer to earlier feature sets. Keep current behavior and current validation status prominent, with older evidence clearly dated. See [README.md](../../../README.md), [descriptor.mod](../../../descriptor.mod), and [metadata](../../../.metadata/metadata.json).

## Validation and balance evidence

The review's static validation run produced these results:

| Check | Result |
| --- | --- |
| File structure | Passed: 1,412 checked files had UTF-8 BOMs; checked script braces balanced |
| Starting buildings | Passed: 36 Road Works records / 87 levels; 139 Harbour Works records / 141 levels; 223 Horse Ranch records / 525 levels |
| Horse-seed safety | Passed |
| Shadow-source lookup | Passed for the 31 keys covered by that check; this is not a complete upstream-content comparison |
| Housing validation | Failed at the 22-versus-28 file-count assertion; subsequent housing checks did not run |

The largest evidence gap is the current build's long-term behavior. Older versions completed century runs, but the latest longer tests end in 1856, and several subsequent features received only short checks. Older campaign results do not establish the balance of the current feature set.

Prioritize current-version campaigns covering poor countries, colonies, agrarian economies, and industrial powers. Measure unresolved infrastructure shortages, housing affordability, government spending, mortality, railway and transport supply, and reform adoption. Include manual playtesting to assess whether the mechanics create understandable decisions and achievable recovery paths.

Evidence: [feature-complete balance log, November 8](../feature_complete_8_Nov_2026/BALANCE_LOG.md) and the older [century-run report, November 3](../century_3_Nov_2026/REPORT.md).
