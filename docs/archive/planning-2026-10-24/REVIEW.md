Burden of Infrastructure — review, 21 September 2026

**My assessment: a compelling alpha with a coherent economic identity, but it needs targeted correctness fixes and AI/balance testing before I would call it ready for a broad release.** The strongest idea is making infrastructure an ongoing public expense linked to real supply chains. The biggest danger is that the extra expense becomes compulsory maintenance the player understands but the AI cannot manage.

This review examines the mod's scripts, localization, generators, metadata, balance notes, and development plan against the locally installed Victoria 3 **1.13.11**. I did not launch the game or simulate a campaign. Confirmed file discrepancies are distinguished below from design judgments and playtest questions. No gameplay files were changed.

**What works well**

- **The central mechanic has a clear purpose.** Removing infrastructure from railway/port PMs and supplying it through government-funded Public Works and Harbour Works makes expansion carry a visible fiscal cost. Separate transport producers and infrastructure consumers create an understandable economic relationship.
- **Horses connect several systems.** Ranches, extraction haulage, public infrastructure, and cavalry all participate in the same market. This gives an agricultural good strategic importance beyond household consumption. The reduction in horse inputs through industrial haulage tiers also gives modernization a tangible benefit.
- **Technology and administration are separated cleanly.** Independent PM groups let the technical method and bureaucracy law influence different aspects of a building. Keeping administrative headcounts fixed while changing occupations is an elegant way to connect infrastructure to politics. Actual effects on interest-group strength still need measurement.
- **Staffing matters mechanically.** Infrastructure and goods inputs are workforce-scaled, while jobs are level-scaled. Building empty capacity cannot provide the full infrastructure benefit. The changing skill mix also gives modernization a labor requirement.
- **The implementation is reasonably easy to audit.** Custom identifiers are namespaced, vanilla shadows are separated, intended changes are tagged, and generated history has source scripts. The explanations of previous implementation failures are useful maintenance records.
- **Basic file hygiene is good.** All 30 checked script/localization files have UTF-8 BOMs and matching brace counts. All referenced graphics resolve locally. These checks are reassuring, although they do not establish engine validity or campaign stability.

**Highest-priority improvements**

1. **Restore the vanilla hussar bonuses — confirmed regression.**

   `common/combat_unit_types/00_boi_cavalry_overrides.txt` omits vanilla 1.13.11's `formation_modifier` containing `military_formation_mobilization_speed_mult = 0.25` and `military_formation_army_movement_speed_mult = 0.25`. The full-key override therefore changes cavalry performance beyond the intended horse upkeep. Restore that block while retaining the horse input. A normalized comparison of all 22 shadows found this as the only discrepancy beyond the intended changes. The existing development plan identifies it correctly; it remains unfixed.

2. **Prove the AI can maintain the new system — high-impact, unverified behavior.**

   Public Works and Harbour Works have constant `ai_value` values of 3000 and 1500 in `common/buildings/50_boi_buildings.txt`. Neither defines an explicit auto-expansion rule. Those values express priority but do not themselves express when a state needs capacity, whether existing buildings are staffed, or whether the government can afford more.

   Test both overbuilding and underbuilding before choosing a fix. The desired behavior is construction near an infrastructure deficit, with checks for occupancy and fiscal capacity. Also test whether PM upgrades occur without adequate local transportation or electricity. Selecting a more productive method is not enough if its inputs are unavailable.

3. **Balance opening horse supply by market, not just by world totals.**

   The checked seed contains 236 three-level Horse Ranches: **8,496 horses** at the base PM and full staffing. The 675 two-level Public Works consume **13,500 horses** under the same assumptions. Ranch supply covers only about **63%** of Public Works demand, before haulage and cavalry.

   This is a warning signal, not proof of a universal shortage: subsistence pasture adds supply, and staffing, market boundaries, trade, and other modifiers affect actual quantities. Measure each starting market. Pasture output does not help markets without that subsistence type, and it can decline as subsistence employment or available land declines; the comments describing it as an indestructible floor are too strong.

   Two Public Works levels also impose 1,000 jobs and £600 of base-price horse inputs wherever seeded. A coastal Harbour Works adds 500 jobs and £200 of goods. Uniform seeding may burden small populations disproportionately while providing unnecessary capacity in some states. Consider seeding against actual starting need once opening measurements are available.

4. **Separate rural-land protection from public-building coverage.**

   `tools/gen_seed.awk` picks the first listed owner and seeds all buildings only into that owner's portion of a state region. Protecting against rural over-allocation is sensible, but Public Works and Harbour Works do not use arable land. Secondary owners of split regions consequently receive no equivalent public seed.

   The first owner in an input file is also not an explicit test of population, province share, or coastal ownership. Generate public buildings per eligible owned state portion, while retaining separate ranch safeguards. For Harbour Works, verify that the receiving state portion actually has a coast; the current generator checks the region's port flag. This is a coverage/design issue confirmed in the generator, not a demonstrated startup failure.

5. **Use profitability to guide Horse Ranch PM selection.**

   `pmg_boi_horse_ranch_method` uses `most_productive`, alongside the public-service groups. Ranches sell a good and buy inputs, so their commercial tradeoffs differ. Prefer `most_profitable` for ranches and test the result under cheap horses and expensive grain/tools. Retain separate reasoning for the public buildings. Higher horse output is not automatically the best business decision.

**Design choices worth revisiting**

- **Give Harbour Works a precise role.** Both public buildings cost 400 construction and employ 500 people per level. At their base PMs, Public Works gives 15 infrastructure and Harbour Works 10, with equal base-price goods cost per infrastructure point. Harbour Works therefore requires more construction and workers for equal capacity. Its real attraction may be input diversification and avoiding expensive horses. That is a valid niche, but the documentation's “more total capacity” argument depends on a meaningful cap that is not established by the building definitions. Verify the intended cap and compare total costs, including wages and supporting port capacity.
- **Make the road/rail relationship clear.** Rail Network, Motor Roads, and Modern Highways all consume local transportation. Road modernization therefore remains tied to local transport production. Decide whether that represents an integrated freight network or whether roads should offer a distinct alternative; align names and player explanations with the decision.
- **Keep the separate ranch only if its identity earns its compatibility cost.** All 16 map files currently match installed vanilla after removing the ranch whitelist insertion, which is good. Nevertheless, copying whole state-region files creates a large conflict surface. A horse-breeding PM on existing livestock ranches could reduce that footprint, at the cost of a less distinctive building and different balancing requirements. Either approach is defensible; document the chosen tradeoff.
- **Prioritize distinctive goods art.** Horses currently use the meat icon. Reusing assets is practical during development, but this icon obscures the mod's central commodity. A recognizable horse icon and a short player-facing explanation would improve usability more than additional mechanics at this stage.

**Documentation and maintenance**

The balance documentation is unusually useful, but some conclusions need tightening:

- The installed game's `PRICE_RANGE = 0.75` gives a normal maximum of **£52.50** for a £30 good. The £60 horse scenario in `BALANCE.md` is outside that range. Model shortage penalties separately from higher prices.
- Unchanged railway and port input/output coefficients do not guarantee unchanged profitability: the mod changes demand, prices, staffing competition, and utilization. Describe their production recipes as unchanged.
- Replace the obsolete “Container Wharves” terminology with the implemented Electrified Quays, and reconcile the documented technology tier.
- Goods margin is not profit after wages. The document often makes this distinction correctly; carry it through claims that infrastructure is “free” and comparisons of alternative infrastructure sources.
- Align `descriptor.mod` version `0.1` with metadata version `0.1-a`. Add a concise README covering supported version, starting procedure, mechanics, and known conflicts. Establish version control; this directory is not currently a Git repository.
- Automate the checks performed here. Make generation deterministic: `for (s in states)` in AWK does not guarantee stable ordering. The curation rules are useful heuristics, but they are not a calculation of remaining usable arable land, so retain an actual startup check after regeneration.

**Suggested next milestone**

Fix the hussar shadow, correct ranch PM selection, and resolve public seeding coverage. Then run a clean-start and 5–20-year comparison for an industrial power, an agrarian empire, a small isolated market, and a country with split states. Record horse prices and shortages, government goods/wage spending, market access, staffing, AI construction, and PM choices. Include a bureaucracy-law change and a newly colonized state.

Success means the infrastructure expense creates choices the player can plan around, the AI maintains viable market access, and modernization offers benefits without routinely breaking input supply. I would prioritize that evidence over adding more buildings or PM tiers.

Validation performed: 30 files checked for BOM and brace-count consistency; referenced graphics checked against mod and installed assets; 22 vanilla shadows compared after normalizing intended changes and empty containers; 16 state-region copies compared; 675 whitelist insertions and seeds of 675 Public Works, 372 Harbour Works, and 236 Horse Ranches confirmed. These are static checks, not an in-game certification.
