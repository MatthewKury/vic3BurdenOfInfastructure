# Burden of Infrastructure: overview and big ideas

Updated: 2026-11-03. Target game version: Victoria 3 **1.13** (checked against
installed 1.13.11).

This is the top-level planning document. It says what the mod is for, what
state each part is in, and what might come next. The detailed work for each
part lives in its own execution plan:

| # | Plan | Status in one line |
|---|---|---|
| 1 | [Core infrastructure and horses](plans/01_CORE_INFRASTRUCTURE_AND_HORSES.md) | Road, Rail and Harbour Works built (2026-11-03); AI keeps up over 10-year headless runs; see the [century report](reports/century_3_Nov_2026/REPORT.md) |
| 2 | [Road Financing politics](plans/02_ROAD_FINANCING.md) | Laws cover all three works buildings (2026-11-03); phase 2 events not started |
| 4 | [Housing](plans/04_HOUSING.md) | Merged into the main mod (2026-10-30); fixture checks automated; 15 replace-not-upgrade buildings and Light and Heat built 2026-11-03; first balance passes done, open decisions in the plan |
| 5 | [Release, tooling and hygiene](plans/05_RELEASE_AND_TOOLING.md) | Validation suite, headless harness and PATCHING.md done; changelog and licence still missing |

The original documents these were condensed from are kept in
[docs/archive/planning-2026-10-24/](archive/planning-2026-10-24/README.md).
Numbers and engine detail behind the core design stay in
[BALANCE.md](../BALANCE.md). Engine lessons shared across all mods are in
`../VIC3_MODDING_LESSONS.md` (one folder up from this mod).

---

## 1. Thesis

In vanilla Victoria 3, infrastructure is free. A railway earns money and hands
out 20 to 40 infrastructure as a by-product. **This mod makes infrastructure
something the state must build, staff and feed with goods.** Railways and ports
keep producing transportation and merchant marine, but government-funded
buildings now supply the infrastructure, and they cost money every week.

Horses are the connecting good. They feed early roads, extraction haulage,
farms, urban transport and cavalry, so one market links agriculture, the
treasury, industry and the army. Industrialisation is how a country escapes
the horse burden.

The later modules push the same idea further: who pays for roads (politics)
and where people live (housing). Each one adds a cost a state must manage,
rather than a free bonus.

## 2. Pillars

1. **Infrastructure is a standing public expense.** Road Works (land), Rail
   Works (railway states) and Harbour Works (coast) are cost centres shaped like Government
   Administration: wages and goods in, a state modifier out, no revenue.
2. **Horses connect the economy.** A new tradeable good, a new Horse Ranch,
   and horse inputs on haulage, farms, urban transport, cavalry and
   mobilization options.
3. **Modernisation is a ladder.** Each building's PM tiers trade horses for
   transportation, oil and electricity, and labourers for machinists and
   engineers. Cost per infrastructure point falls with era.
4. **Politics decides who pays.** Bureaucracy law already changes who staffs
   the works; the Public Works Financing law group decides whose pocket the roads come
   out of, and interest groups take sides.
5. **Geography matters through state traits.** PMs cannot test terrain, so
   regional differences (horse breeding) come from state traits
   carrying modifiers.

## 3. Design rules that apply to every module

These come from the original agreed design (2026-08-16) and have held since.

- **Keep patch debt low.** New content goes in new files. Shadow individual
  keyed vanilla blocks only, never whole files, and tag every BOI change in a
  shadow. The one accepted exception is the 16 state-region files (needed for
  the Horse Ranch arable whitelist and the trait assignments).
- **The population floor is the safety net** that stops the world collapsing
  when railways stop giving infrastructure. Left alone until 2026-11-03, when the
  author confirmed a divisor of 125,000 (vanilla 100,000).
- **Government cost centres use `ai_selection = most_productive`;** buildings
  that sell a good use `most_profitable`.
- **The AI must be able to run it.** A system the player understands but the AI
  cannot maintain is the biggest single risk. Prefer buildings over PM groups on
  private vanilla buildings when the AI needs to use them (the reason Harbour
  Works is its own building).
- **Mark what is verified.** Separate "checked in vanilla files", "passes static
  validation" and "observed in-game". Almost nothing beyond a short Portugal
  smoke test has been observed in-game.
- **Every new piece of engine knowledge goes into the shared lessons file** in
  the same session.

## 4. Status board (as of 2026-11-03)

| Area | Built | Static validation | In-game |
|---|---|---|---|
| Horses, Horse Ranch, Horse-Breeding Traditions trait | Yes | Passes | Short smoke test only |
| Road, Rail and Harbour Works (5, 4 and 3 PM tiers, Bureaucracy admin groups) | Yes | Passes | 10-year headless runs; see the century report for later tiers |
| Rail and port infrastructure removed; haulage, farm, urban, cavalry horse inputs | Yes | Passes | Smoke test only |
| Rail Network Survey: Rail Works 2.5× (3× until 2026-11-08), capped 1/2/4 per state (2/4/6 until then), cap raised by a region survey (decision and journal entry) or the AI pass (2026-11-07) | Yes | Passes | Three 15-year balance passes, 2 games each, with 4 stand-in players; [balance log](reports/rail_survey_7_Nov_2026/BALANCE_LOG.md) |
| Horse mobilization options (Recon, Horse-Drawn Transport, Extra Supplies) | Yes | Passes | Not recorded |
| 1836 seed (20 Public Works, 139 Harbour Works, 216 Horse Ranches, scarce by horse history) | Yes | Passes | 20-year headless run, 2026-11-01: supply 65% of demand in 1836, 88% in 1855 |
| AI construction fallback event and `downsizeable = no` | Yes | Passes | 10-year headless runs: deficit states 26 → 1 across 12 major powers |
| Infrastructure-aware `ai_value` weights (Public Works, Harbour Works) | Yes | Passes | No visible effect; kept pending reinvestigation (plan 1, step 3) |
| Price-scaled `ai_value` for railways and Horse Ranches; opt-in auto-expansion | Yes | Passes | Not observed |
| Public Works Financing laws, ideologies, PMs, starting laws | Yes (all works) | Passes | Runs in headless games; political balance not assessed |
| Housing (merged into the main mod 2026-10-30); housing law groups in the Social tab since 2026-11-08; seed privately owned since 2026-11-08 | Yes | Regression suite passes | 10-year headless runs, no housing errors; automated fixture checks; 1836 supply seeded from measured demand (2026-11-01); one-run calibration only |
| Release files | `PATCHING.md` and `.gitignore` yes; licence and changelog no | — | — |
| Vanilla baseline ensemble and report tooling (2026-10-31) | Yes: `Invoke-HeadlessEnsemble.ps1`, `ensembles.sqlite`, `Make-EnsembleReport.py` | Comparison mode tested on a 5-vs-5 split | 10 vanilla runs, 1836–1846, all passed; [report](reports/vanilla_1836_1846/REPORT.md). No BOI ensemble yet |

## 5. How the modules depend on each other

- **Infrastructure is the shared resource.** Road, Rail and Harbour Works
  produce it. Housing (1.25 to 4 per level) consumes it. Balancing housing means
  re-checking that the core buildings can keep up, and that the AI builds them
  when consumption rises. The AI construction fallback measures usage minus
  supply, so it already responds to housing demand.
- **Horses feed housing.** Carriage Villas consume horses, and the Horse Ranch
  carries the company-housing PM group like other rural workplaces.
- **`00_buy_packages.txt` is one shared file.** Housing replaces the whole
  vanilla file, generated by `tools/Build-Housing.ps1`. Any future pop need
  (luxury horse demand, for instance) must go through that generator; a second
  copy of the file would silently replace it.
- **Financing applies to all three works buildings,** each through its own PM
  group, so a law's per-level effects stay tuned to that building.
- **The Bureaucracy-law admin pattern** (hereditary / appointed / elected PMs)
  is reused on all three works buildings. Keep it consistent.

## 6. Big ideas not yet started

Ranked roughly by value for patch cost. None of these is designed or agreed.
Items 1 to 3 have the clearest path. Ideas that belong to an existing module
are listed in that module's plan instead (Road Financing events, harbour
financing, housing ownership laws).

1. **Horse events and journal entries.** The horse economy is only numbers.
   Candidates: the Great Epizootic of 1872 (equine flu stops freight and urban
   transport), glanders outbreaks, remount requisitioning at mobilization,
   a macadamisation or national road programme journal entry, and the 1890s
   horse manure crisis (horses already feed urban transport through
   `pm_no_public_transport`). All of these can live in new files.
2. **Public works events tied to real problems.** An unsafe bridge, a harbour
   silting up, disputed tolls, landowners resisting a planned road. Trigger
   them from existing infrastructure or funding problems, with real choices,
   not arbitrary recurring penalties.
3. **Military horses beyond cavalry.** Artillery and supply trains used far more
   horses than cavalry did. Horse upkeep on artillery is the cheapest
   historically important addition, but it is another combat-unit shadow.
   (Military training PMs were also on the original deferred list.)
4. **Geography for infrastructure.** A Public Works level gives the same output
   in the Alps, the Amazon and Belgium. Terrain-based difficulty through state
   traits (mountain, jungle, desert states produce less or cost more) would make
   colonial Africa expensive to connect. Horse-Breeding Traditions shows the
   trait pattern.
5. **Physical upkeep materials.** Small wood, tools, iron or steel inputs on
   Public Works tiers for bridges, timbers and track. Rebalance existing inputs
   so this adds theme without simply raising the total cost.
6. **Maintenance versus expansion policy.** A visible, reversible choice to save
   money at the cost of capacity, or spend more for reliable service. Avoid a
   hidden deterioration meter.
7. **Canals and rivers.** The canal age (horse-drawn barges on towpaths) fills the
   gap between cart roads and railways for inland states with navigable rivers.
   A canal PM or waterway-flavoured Public Works.
8. **Regional draught animals.** Mules, oxen and camels did this work in India,
   the Sahara and the Andes. Even a flavour pass (local names, regional ranch
   PMs) would help non-European games.
9. **The horse's decline.** Late-game horse demand should collapse and ranches
   become stranded assets. A bust for the ranching class, or a glue, fertiliser
   or leather by-product, would give the decline some shape.
10. **Luxury horse demand.** Carriages, racing and aristocratic consumption as a
    pop need. On the original deferred list; pairs well with Road Financing.
    Must go through the shared buy-package generator.
11. **Broader public works.** Sewers and telegraphs could extend the theme
    beyond transport. Long-term only.

## 6a. To revisit (noted 2026-11-07)

Raised by you on 2026-11-07, after the Rail Network Survey passes. None is designed yet. What I found when noting them is under each.

1. **Done 2026-11-08 (PMs only):** the Horse Ranch now has a by-product group (meat, then fertilizer, valued like Livestock's wool group) and vanilla's `pmg_fencing`; refrigeration is left out. The map look (`city_type = farm`) still needs mesh mappings in 34 city-type files, so it is still open. *Noted 2026-11-07:* **Give Horse Ranches more of the Livestock Ranch's features.** Vanilla's `building_livestock_ranch` has `city_type = farm`, `levels_per_mesh = 50`, `terrain_manipulator = pasture` and four PM groups: base, sheep ranch, fencing and refrigeration. BOI's Horse Ranch is `bg_ranching` with two groups, `pmg_boi_company_housing` and `pmg_boi_horse_ranch_method`, and no map look; plan 1 notes it was left without `city_type` or `levels_per_mesh` on purpose. Candidates: a fencing-style secondary group, a by-product such as meat or fertiliser (see idea 9), and the pasture terrain look.
2. **Partly done 2026-11-08.** Cause found: the 1836 seed gave every housing level to the country (`add_ownership = { country = … }`). It now goes to manor houses (aristocrats) and, in states with industry, financial districts (capitalists), which is how vanilla seeds private buildings. Housing the player builds is still government-owned, as with any building under vanilla rules. Still open: the private investment pool may never build housing at all. Vanilla's manor houses and financial districts list `investment_scores` per building group, and the root group `bg_boi_residential` is under none of them; the category is not the gate, since railways are `development` too. The housing telemetry now logs `BOIOWN|` ownership counts to show it. *Noted 2026-11-07:* **Housing looks government-owned in game.** The residential groups are `is_government_funded = no`, the buildings `ownership_type = self` (Municipal Estates, `no_ownership`, are the one exception). But `bg_boi_residential` sits in `category = development`, the same category as urban centres. That may keep the private investment pool from building it, so only the state ever does. The seeded levels may also start state-owned. Check both: what owns a seeded slum in 1836, and whether private investors queue housing anywhere in a headless run. If the category is the cause, move housing to a category the investment pool uses. That's a generator change in `tools/Housing-Tiers.ps1` / `tools/Build-Housing.ps1`, not a hand edit.
3. **Cut the construction cost of Road Works and Harbour Works.** Both are `construction_cost_medium` (400 points) against Rail Works' `construction_cost_high` (600) and the Horse Ranch's `construction_cost_low` (200). `construction_cost_low` (200) is the obvious first test. Re-run the AI works event's numbers afterwards: cheaper works build faster, which changes how quickly short states recover.

Also open, from the same day: the Rail Network Survey's next steps in its [balance log](reports/rail_survey_7_Nov_2026/BALANCE_LOG.md), starting with the AI pass's money check.

## 7. Where the archived documents are out of date

The current plans, `BALANCE.md`, `PATCHING.md` and the metadata were
reconciled on 2026-10-31. The archived originals in
`docs/archive/planning-2026-10-24/` were left as written and are stale on these
points:

- **Seed counts:** they cite 675 Public Works, 372 Harbour Works and 236 Horse
  Ranches. The seed is **20 Public Works (40 levels), 139 Harbour Works (141
  levels) and 216 Horse Ranches (492 levels)**. Works replace only the
  infrastructure removed from rail and ports.
- **Hussar override:** listed as an open regression; fixed (0.25 / 0.25
  `formation_modifier` block in `00_boi_cavalry_overrides.txt`).
- **Public seeding by owner:** resolved; the plan covers 1,147 state-owner
  records.
- **Opening horse balance:** 8,496 supply against 13,500 demand is superseded by
  a measured 8,352 against 12,801 (65% covered, on purpose), including pasture
  output and Urban Center demand.
- **Road Financing** has five ideologies, not four.
- **Housing apartment ratio:** 100 output over 4 infrastructure is 25 per point,
  not 27.5.
- **AI:** the archive treats `ai_value` weighting as the AI mechanism; the
  scripted fallback event replaced it in practice (plan 1).
