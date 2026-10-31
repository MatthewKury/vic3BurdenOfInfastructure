# Burden of Infrastructure: overview and big ideas

Updated: 2026-10-30. Target game version: Victoria 3 **1.13** (checked against
installed 1.13.11).

This is the top-level planning document. It says what the mod is for, what
state each part is in, and what might come next. The detailed work for each
part lives in its own execution plan:

| # | Plan | Status in one line |
|---|---|---|
| 1 | [Core infrastructure and horses](plans/01_CORE_INFRASTRUCTURE_AND_HORSES.md) | Built and smoke-tested; needs a campaign balance and AI pass |
| 2 | [Road Financing politics](plans/02_ROAD_FINANCING.md) | Phase 1 (roads) built; untested in-game; phase 2 (events, harbours) not started |
| 4 | [Housing](plans/04_HOUSING.md) | Merged into the main mod (2026-10-30); loads cleanly in headless runs; not calibrated |
| 5 | [Release, tooling and hygiene](plans/05_RELEASE_AND_TOOLING.md) | Validation suite built; release files still missing |

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

1. **Infrastructure is a standing public expense.** Public Works (land) and
   Harbour Works (coast) are cost centres shaped like Government
   Administration: wages and goods in, a state modifier out, no revenue.
2. **Horses connect the economy.** A new tradeable good, a new Horse Ranch,
   and horse inputs on haulage, farms, urban transport, cavalry and
   mobilization options.
3. **Modernisation is a ladder.** Each building's PM tiers trade horses for
   transportation, oil and electricity, and labourers for machinists and
   engineers. Cost per infrastructure point falls with era.
4. **Politics decides who pays.** Bureaucracy law already changes who staffs
   the works; the Road Financing law group decides whose pocket the roads come
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
- **Leave vanilla's population infrastructure floor alone.** It is the safety
  net that stops the world collapsing when railways stop giving
  infrastructure.
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

## 4. Status board (as of 2026-10-30)

| Area | Built | Static validation | In-game |
|---|---|---|---|
| Horses, Horse Ranch, Horse-Breeding Traditions trait | Yes | Passes | Short smoke test only |
| Public Works and Harbour Works (5 and 3 PM tiers, Bureaucracy admin group) | Yes | Passes | Smoke test only |
| Rail and port infrastructure removed; haulage, farm, urban, cavalry horse inputs | Yes | Passes | Smoke test only |
| Horse mobilization options (Recon, Horse-Drawn Transport, Extra Supplies) | Yes | Passes | Not recorded |
| 1836 seed (20 Public Works, 139 Harbour Works, 225 Horse Ranches) | Yes | Passes | Not recorded |
| Infrastructure-aware AI weights and opt-in auto-expansion | Yes | Passes | Not observed |
| Road Financing laws, ideologies, PMs, starting laws | Yes (roads) | Passes | Not observed |
| Housing (merged into the main mod 2026-10-30) | Yes | Regression suite passes | 10-year headless run, no housing errors; not calibrated |
| Release files (licence, changelog, patching notes, .gitignore) | No | — | — |

## 5. How the modules depend on each other

- **Infrastructure is the shared resource.** Public Works and Harbour Works
  produce it. Housing (4 to 8 per level) consumes it. Balancing housing means
  re-checking that the core buildings can keep up, and that the AI builds them
  when consumption rises. The AI construction fallback measures usage minus
  supply, so it already responds to housing demand.
- **Horses feed housing.** Suburbs can commute by horse, and the Horse Ranch
  carries the company-housing PM group like other rural workplaces.
- **`00_buy_packages.txt` is one shared file.** Housing replaces the whole
  vanilla file, generated by `tools/Build-Housing.ps1`. Any future pop need
  (luxury horse demand, for instance) must go through that generator; a second
  copy of the file would silently replace it.
- **Road Financing applies to the whole Public Works building.** If other
  services ever move onto Public Works, they inherit the financing law.
- **The Bureaucracy-law admin pattern** (hereditary / appointed / elected PMs)
  is reused on Public Works and Harbour Works. Keep it consistent.

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

## 7. Where the old documents disagreed, and what is true now

Found while condensing; each was checked against the current files on
2026-10-24.

- **Hussar override:** the 2026-08-23 plan and the 2026-09-21 review list the
  missing 1.13.11 `formation_modifier` as an open regression. It is **fixed**:
  `common/combat_unit_types/00_boi_cavalry_overrides.txt` has the 0.25 / 0.25
  block on hussars.
- **Seed counts:** the review and plan cite 675 Public Works, 372 Harbour Works
  and 236 Horse Ranches. The current seed is **20 Public Works (40 levels), 139
  Harbour Works (141 levels) and 225 Horse Ranches (857 levels)**, replacing
  only the infrastructure removed from rail and ports.
- **Public seeding by owner:** the review's point that split state regions gave
  secondary owners no public seed is **resolved**; the plan now covers 1,147
  state-owner records.
- **Horse icon:** the review says horses use the meat icon. A custom (provisional,
  AI-assisted) horse icon now exists.
- **Git and README:** both now exist; the plan listed them as missing.
- **Opening horse balance:** older figures of 8,496 supply against 13,500
  demand are superseded by 10,284 against 10,494 (98% covered, before pasture
  output and Urban Center demand).
- **BALANCE.md** still contains a stray fragment of an old cavalry upkeep table
  and calls the top Harbour Works tier `pm_container_wharves`; the implemented
  name is `pm_boi_electrified_quays`. Its £60 horse scenario is also above the
  engine's normal price ceiling (£52.50 for a £30 good). See plan 5.
- **Road Financing file list** says "four ideologies"; five were designed and
  built.
- **Housing apartment ratio:** the housing implementation plan gives 27.5 basic
  housing per apartment infrastructure point; 100 output over 4 infra is 25.
  Plan 4 uses 25.
