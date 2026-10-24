# Plan 2: Road Financing politics

Updated: 2026-10-24. Back to the [overview](../OVERVIEW.md).

Condensed from the Road Financing proposal (2026-09-26) and the politics item in
the ideas list. Full design, history and per-modifier reasoning are in the
[archived proposal](../archive/planning-2026-10-24/PROPOSAL_ROAD_FINANCING.md).

## Goal

A law group decides **who pays** for Public Works, so the burden becomes
something interest groups argue about, not just a budget line. Statute Labour
puts it on peasants, Turnpike Trusts on road users, Public Highways on the
treasury. Everything lives in new or BOI-owned files: no vanilla shadows.

## What is done (phase 1, roads only, 2026-09-26)

Static validation passes. **Nothing here has been observed in-game.**

### The laws

`lawgroup_boi_road_financing`, economy category, ideological impact 0.5.
Balance is anchored on **Public Highways = the mod as it plays without the
law**; the other two are discounts with side effects.

| | Statute Labour | Turnpike Trusts | Public Highways |
|---|---|---|---|
| Public Works goods input | −40% | −50% (raised from −35% on 2026-09-26) | baseline |
| Staffing | unchanged | −60 labourers, +50 shopkeepers, +10 capitalists per level | baseline |
| Infrastructure | −4 per level (flat, so it matters most early) | +15% of all state infra, once per state | baseline |
| Side effect | Peasant SoL −0.25 per Public Works level | Market access −5% everywhere (on the law, so it cannot stack) | none |
| Benefits | Farm and ranch throughput +1% per level; manor-house aristocrat SoL +2; aristocrat pol. strength +10% | Shopkeeper SoL +2 in Public Works; investment-pool efficiency +10% for shopkeepers, aristocrats, capitalists; pol. strength +10/+5/+5% | none (support is political) |

Wages are not discounted under any law, so the real saving is smaller than the
goods figures. A haulage toll on extraction was tried (needed a hidden monthly
event) and removed.

### How it is wired

- `pmg_boi_road_financing` on Public Works: one fallback PM
  (`pm_boi_public_highways`, `disallowing_laws`) and two law-unlocked PMs,
  copying the admin group pattern. Exactly one valid PM at any time.
- **Five ideologies** added at runtime with `add_ideology`, so no vanilla
  ideology is shadowed: manorial roads (Landowners), free roads (Rural Folk,
  Trade Unions), turnpike interest (Petty Bourgeoisie), road investors
  (Industrialists), national roads (Intelligentsia, Armed Forces). Devout have
  no stance.
- Game-start setup runs from `common/history/global/zz_boi_road_financing.txt`
  (because `on_game_started` has no root scope), calling an idempotent
  scripted effect. It is re-run on yearly pulse, country formed and country
  released.
- **Starting laws:** Turnpike Trusts for GBR and USA, Public Highways for FRA
  and PRU, Statute Labour for everyone else. Only assigned when a country has
  none of the three.
- Law icons generated; prompts in `output/law-art/PROMPTS.md`.

Files: `common/law_groups/50_boi_law_groups.txt`,
`common/laws/50_boi_road_financing.txt`,
`common/ideologies/50_boi_road_ideologies.txt`, the financing PMs in
`common/production_methods/50_boi_infrastructure.txt`,
`common/scripted_effects/50_boi_road_financing_effects.txt`,
`events/boi_road_financing_events.txt`,
`common/on_actions/zz_boi_on_actions.txt`.

## What is left

### Step 1: Verify phase 1 in-game

- [ ] Road ideologies show cleanly on IG panels and move law approval.
- [ ] Every country starts with a Road Financing law. Check whether the engine
      auto-assigns a law in a new group before history runs.
- [ ] Released and formed countries get the law and ideologies within a year.
- [ ] Flavoured IG variants still match the `ig_` keys the setup loop uses.
- [ ] `building_goods_input_mult` works inside a PM `unscaled` block, and the
      building-group SoL modifier works in PM `state_modifiers`. Fallbacks:
      `goods_input_horses_mult` plus per-good mults, and
      `state_lower_strata_standard_of_living_add`.
- [ ] Turnpike wage swap: the estimate is about +£17 per level per week in wages
      against a £150 goods saving at Cart Roads. Check real wage figures.

### Step 2: Political balance

- [ ] Landowner lock-in: Statute Labour plus Hereditary Bureaucrats gives
      Landowners pol. strength from two laws, state-paid aristocrat jobs and farm
      profits. Intended as drama, but if it runs away, cut the throughput bonus
      first, then the pol.-strength bonus.
- [ ] Does the AI ever leave Statute Labour?

### Step 3: AI weights

- [ ] Add modest `ai_enact_weight_modifier` (100 to 150): Turnpike Trusts while
      in deficit (find the budget trigger name), Public Highways once solvent with
      Industrialists or Intelligentsia in government. Keep the standard petition
      hook (`ai_has_enact_weight_modifier_journal_entries`).

### Step 4: Phase 2 (not started)

- [ ] **Rebecca Riots** under Turnpike Trusts in a state with strong or angry
      Rural Folk: abolish tolls locally for a while, suppress, or appoint a
      commission.
- [ ] **Road-duty defaulters** under Statute Labour when peasant SoL is low.
- [ ] **"A Highway Act"** flavour event on leaving Statute Labour.
- [ ] **Harbour Works financing:** `pmg_boi_harbour_financing` using the same
      three laws (harbour dues as tolls, press-ganged dock labour as statute
      labour).
- [ ] **Dedicated Road Fund** law (UK 1909), unlocked by `combustion_engine`,
      discounting motor-road tiers.

## Open questions for the author

1. Are −40% and −50% the right discounts?
2. Should Statute Labour be disallowed under Peasant Proprietorship or
   Commercialized Agriculture? More historical, but forces a law change.
3. Is "strongly approve" too strong a pull for the small 1836 Petty Bourgeoisie?
4. Is +1% farm and ranch throughput per level right, or should it be capped by
   moving it onto the law?
5. Gate Public Highways on `centralization` and hand-assign it to France and
   Prussia, or leave it ungated (current)?
6. Include Harbour Works in phase 2, or keep roads only?
