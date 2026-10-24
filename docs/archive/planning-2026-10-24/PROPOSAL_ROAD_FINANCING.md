2026-09-26

# Proposal — Road Financing Politics

> **Status:** Implemented 2026-09-26 (roads only; Harbour Works and phase-2
> events not yet). Static validation passes; untested in-game. Engine claims
> are marked **[verified]** (checked in vanilla 1.13 files) or **[to verify]**
> (inferred; must be confirmed in-game before building on it).

## 1. The idea in one paragraph

Add a new law group, **Road Financing**, that decides *who pays* for Public
Works. Each law makes the roads cheaper or dearer for the treasury, and pushes
the cost onto someone else: peasants (Statute Labour), traders and travellers
(Turnpike Trusts), or the taxpayer (Public Highways). Interest groups take sides,
so the burden stops being only a budget line and becomes something you argue
about. The whole feature lives in new files, so it adds **no vanilla shadows**.

## 2. Historical basis

- **Statute labour:** most of Europe and North America required rural
  households to work several days a year on local roads, and often to bring
  their own horse and cart. Britain abolished it in the Highway Act 1835;
  elsewhere it lasted much longer and was tied to serfdom and corvée.
- **Turnpike trusts:** private or local trusts built and maintained roads and
  charged tolls. They peaked in Britain in the 1830s. US turnpikes and plank
  roads worked the same way. Tolls caused the **Rebecca Riots** in Wales
  (1839–43), where farmers smashed tollgates.
- **Public highways:** road-building funded from general taxation by a state
  engineering corps: France's *Ponts et Chaussées* and Prussia's
  *Chausseebau*. It spread across Europe as states centralised.

The three laws also line up with the existing Bureaucracy-driven administration
PMs (manorial roadwardens / appointed surveyors / elected road boards), so the
two systems read as one story.

## 3. The law group

```
lawgroup_boi_road_financing = {
	law_group_category = economy
	ideological_opinion_impact = 0.5   # same as taxation: matters, but not land reform
}
```

**[verified]** Law groups live in `common/law_groups/`; vanilla's are all in
`00_laws.txt`, so a new file `50_boi_law_groups.txt` with a new key does not
collide.

### The three laws

Balance is anchored on **Public Highways = the mod as it plays today**. All
existing BALANCE.md numbers stay valid under it; the other two laws are
discounts with side effects.

| | Statute Labour | Turnpike Trusts | Public Highways |
|---|---|---|---|
| Who pays | Peasants, in labour and draught animals | Road users, in tolls | The treasury |
| Public Works goods input | **−40%** | **−50%** | baseline |
| Public Works state-paid labourers | unchanged | **−60 per level** (replaced by 50 shopkeepers + 10 capitalists) | baseline |
| Public Works infrastructure | **−4 per level** | **+15% of all state infrastructure** (once per state) | baseline |
| Side effect | Peasant standard of living −0.25 per Public Works level in the state | Market access −5% in every state | none |
| Who gains | Landowners and aristocrats (see §4a) | Petty Bourgeoisie and shopkeepers, with Industrialists (capitalists) and Landowners (see §4a) | no one in particular |
| Progressiveness | regressive | neutral | progressive |
| Unlocked by | always available | always available | always available (see §9, Q5) |

Worked example, Cart Roads (1 level: 10 horses = £300/week, 15 infrastructure):

| Law | Horse cost | Infrastructure | Cost per infra point |
|---|---|---|---|
| Public Highways | £300 | 15 | £20.0 |
| Turnpike Trusts | £150 | 17 (15 + 15%) | £8.8 |
| Statute Labour | £180 | 11 | £16.4 |

Wages are not discounted under any law, since wage modifiers that are specific
to one building are not available. So the real saving is smaller than the
goods figures suggest.

Design notes:

- **Statute Labour's infrastructure penalty is flat (−4), not a percentage.**
  At Cart Roads it costs 27% of output; at Modern Highways (48) only 8%. This
  is intended: unpaid peasant labour matters most in the early game and fades
  as roads become engineering projects. It also gives modernisers a reason to
  abolish it early.
- **Turnpike's market-access penalty sits on the law, not the PM**, so it
  cannot stack per building level. −0.05 mirrors the vanilla road-maintenance
  decree's +0.05. **[verified]** `state_market_access_price_impact` exists and
  vanilla uses it with that magnitude in `00_decree.txt`.
- Public Highways has no bonus. Its appeal is political (see §5), and it has
  no penalty, which keeps the numbers simple.

## 4. How the laws reach the buildings

**[verified]** PMs cannot be gated on conditions, only on laws, techs, and
similar. **[verified]** A PM group can hold modifier-only PMs (the existing
administration group already works this way).

Add a **third PM group** to `building_boi_infrastructure`:

```
pmg_boi_road_financing = {
	ai_selection = most_productive
	production_methods = {
		pm_boi_public_highways     # is_default fallback, disallowing the other two laws
		pm_boi_turnpike_tolls      # unlocking_laws = { law_boi_turnpike_trusts }
		pm_boi_statute_labour      # unlocking_laws = { law_boi_statute_labour }
	}
}
```

This copies the existing administration group's pattern exactly: one fallback
PM using `disallowing_laws`, two law-unlocked PMs, and exactly one valid PM at
any time.

Sketch of one PM:

```
pm_boi_statute_labour = {
	unlocking_laws = { law_boi_statute_labour }
	building_modifiers = {
		unscaled = {
			building_goods_input_mult = -0.4
		}
	}
	state_modifiers = {
		workforce_scaled = {
			state_infrastructure_add = -4
			building_group_bg_subsistence_agriculture_peasants_standard_of_living_add = -0.25
		}
	}
}
```

- **[verified]** `building_goods_input_mult` exists (vanilla `trade_distance`
  static modifier). It cuts *all* inputs, so it also covers the transport/oil
  tiers. The mod's own `goods_input_horses_mult` would be horses-only.
- **[verified]** `building_group_bg_subsistence_agriculture_peasants_standard_of_living_add`
  exists in vanilla laws.
- **[to verify]** That `building_goods_input_mult` behaves correctly inside a PM
  `unscaled` block, and that a building-group SoL modifier works in a PM's
  `state_modifiers`. Fallbacks: `goods_input_horses_mult` plus per-good mults,
  and `state_lower_strata_standard_of_living_add`.

The mod owns this building, so this is an edit to a BOI file, not a vanilla
shadow.

## 4a. Who gains: benefits for Landowners and the Petty Bourgeoisie

Without this section, the cheap laws only move costs onto the poor, and the
IGs that support them get nothing concrete for it. These benefits give each
supporting IG a real, visible stake, so that repealing the law takes something
away from them.

Rule used throughout: **flat, country-wide bonuses sit on the law** (so they
cannot stack), and **bonuses that should grow with the road network sit on the
PM** (scaled per Public Works level).

**[verified]** Every modifier key below is declared in vanilla 1.13's
`common/modifier_type_definitions/`.

### Statute Labour: "the squire's roads"

Under statute labour the local landowner decided where the parish's road duty
was spent, and roads ran to the estates.

| Benefit | Where | Modifier | Value |
|---|---|---|---|
| Estate roads: farms and ranches run better | PM, `state_modifiers`, workforce_scaled | `building_group_bg_agriculture_throughput_add`, `building_group_bg_ranching_throughput_add` | +0.01 each, per Public Works level |
| Manor-house comfort | Law | `building_group_bg_manor_houses_aristocrats_standard_of_living_add` | +2 |
| Local authority of the squire | Law | `country_aristocrats_pol_str_mult` | +0.10 |

- The throughput bonus reaches aristocrats through the profits of farms and
  ranches they own. It also covers horse ranches, since they are in
  `bg_ranching`. A state with 5 Public Works levels gets +5%. This is the only
  benefit that grows over time, so it is the main balance dial.
- The manor-house figure is sized against vanilla's own amendment, which gives
  +3 (`00_amendments_enactment_04.txt`).

### Turnpike Trusts: "the trustees and the toll-house"

Turnpike trusts were run by local gentry and merchants who lent money to the
trust and collected interest from the tolls. The toll-houses were kept by
tradesmen and innkeepers.

| Benefit | Where | Modifier | Value |
|---|---|---|---|
| Toll-keepers and trust investors: jobs move from labourers to shopkeepers and capitalists | PM, `building_modifiers`, level_scaled | `building_employment_laborers_add` / `_shopkeepers_add` / `_capitalists_add` | −60 / +50 / +10 per level |
| Toll revenue kept by the toll-house | PM, `building_modifiers`, unscaled | `building_shopkeepers_standard_of_living_add` | +2 (applies only to shopkeepers in Public Works) |
| Trust investors: capital raised locally | Law | `state_{shopkeepers,aristocrats,capitalists}_investment_pool_efficiency_mult` | +0.10 each |
| Trustees' political weight | Law | `country_{shopkeepers,aristocrats,capitalists}_pol_str_mult` | +0.10 / +0.05 / +0.05 |

- The job shift is the most thematic piece: every turnpike-era Public Works
  level employs 50 shopkeepers. They are Petty Bourgeoisie pops earning
  middle-strata wages from the state, which mirrors how Hereditary Bureaucrats
  already puts aristocrats on the payroll through the administration group.
- Shopkeepers (wage weight 3) and capitalists (5) earn more than labourers (1),
  so the swap is a small net wage increase: −60 + 150 + 50 = +140
  labourer-equivalents, roughly £17 per level per week at 1836 wages, against
  a £150 goods saving at Cart Roads. (Revised 2026-09-26: the goods discount
  rose from −35% to −50%. A −100 labourer cut was tried alongside it but
  saved only about £5 more per level and left just 25 labourers per level
  under Modern Highways, so it went back to −60.)
  **[to verify]** against the in-game wage figures.
- Tolls cannot be paid into a pop's income directly: government buildings have
  no revenue, and no modifier routes money to a specific pop. The SoL bonus on
  the toll-keepers stands in for toll income.
- Investment-pool *efficiency* is chosen over *contribution*. Efficiency makes
  money invested by these pops go further. Contribution would take a larger
  share of their income, which is a cost to them rather than a benefit.

## 4b. Turnpike economics: better roads

Added 2026-09-26. Turnpike trusts built the best roads of the era (McAdam and
Telford both worked for them).

| Effect | Where | Modifier | Value |
|---|---|---|---|
| Well-kept roads | PM, `state_modifiers`, **unscaled** | `state_infrastructure_mult` | +15%, once per state |

- **Why unscaled:** PM modifiers are either scaled linearly by level, or
  unscaled and applied once per building. Only one Public Works building exists
  per state, so unscaled gives a flat percentage. It multiplies *all* of the
  state's infrastructure, including Harbour Works and the population floor.
- **Haulage tolls on extraction: tried and removed (2026-09-26).** A capped,
  sublinear penalty on mining and logging output needed a hidden monthly state
  event applying a scaled static modifier. That approach was rejected. If
  wanted later without an event, the only PM-native capped form is a flat
  unscaled penalty per state (e.g. −3% extraction throughput in any state with
  Public Works under Turnpike Trusts).

### Public Highways: no direct beneficiaries

This is deliberate. Its supporters (Industrialists, Rural Folk, Trade Unions,
Intelligentsia, Armed Forces) want it because it removes costs from them, not
because it pays them. So this law has broad support but no single group
actively lobbying for it. That makes the two cheap laws "sticky" because a
concentrated interest defends them, which is historically accurate: British
turnpike trusts took about 50 years to wind up.

### Balance risk: a Landowner lock-in

Statute Labour + Hereditary Bureaucrats (manorial roadwardens) together give
Landowners political strength from both laws, plus state-paid aristocrat jobs,
plus farm profits. That may create the self-reinforcing trap the development
plan already lists as playtest item 6. It is intended as drama, but it needs
testing. If it runs away, the first thing to cut is the throughput bonus, then
the pol-strength bonus.

## 5. Interest-group stances

| Interest group | Statute Labour | Turnpike Trusts | Public Highways | Why |
|---|---|---|---|---|
| Landowners | strongly approve | approve | disapprove | Free labour and roads to their estates (§4a); they sat on turnpike trusts; highways mean land tax |
| Rural Folk | strongly disapprove | disapprove | approve | They do the road duty *and* pay the tolls |
| Trade Unions | strongly disapprove | disapprove | approve | Unpaid labour; tolls on workers' travel |
| Petty Bourgeoisie | disapprove | strongly approve | neutral | Toll-keeper jobs and trust investments (§4a); innkeepers and the coaching trade |
| Industrialists | disapprove | approve | neutral | Capitalists invest in the trusts (10 per level, §4a) and want roads run as a business |
| Intelligentsia | disapprove | disapprove | approve | Rational state administration |
| Armed Forces | disapprove | disapprove | approve | Military roads (the Napoleonic model) |
| Devout | — | — | — | No stance |

That gives five distinct stance rows, so **five new ideologies**:

| Ideology | Given to |
|---|---|
| `ideology_boi_manorial_roads` | Landowners |
| `ideology_boi_free_roads` | Rural Folk, Trade Unions |
| `ideology_boi_turnpike_interest` | Petty Bourgeoisie |
| `ideology_boi_road_investors` | Industrialists |
| `ideology_boi_national_roads` | Intelligentsia, Armed Forces |

Each holds only a `lawgroup_boi_road_financing = { ... }` block. Icons reuse
vanilla ideology icons for now.

### Delivering the ideologies without shadowing vanilla

The normal method is to add the stance block to the vanilla ideologies (29 in
the core file, plus flavoured variants). That means shadowing dozens of keyed
blocks, which is exactly the patch debt this mod tries to avoid.

Instead, attach new ideologies at runtime:

- **[verified]** `add_ideology = ideology_x` is a vanilla effect on
  interest-group scope (`common/decisions/00_decisions.txt`, the Ibadi decision).
- **[verified]** `has_ideology = ideology:ideology_x` is a vanilla trigger.
- **As implemented:** `on_game_started` has no root scope, so game-start setup
  runs from `common/history/global/zz_boi_road_financing.txt`. That is the
  same place vanilla attaches `ideology_pro_slavery` to Landowners
  (`history/global/00_global.txt`), so the pattern has a direct vanilla
  precedent. It calls `boi_road_financing_setup_effect` for every country; the
  effect only fills in what is missing.
- Re-run the same check from `on_yearly_pulse_country`, `on_country_formed`
  and the `on_country_released_*` hooks. That covers released or formed
  countries and any event that rebuilds an IG's ideologies.

**[to verify]** in-game:

1. That ideologies added this way affect law approval. They should, since
   they are real ideologies.
2. That the IG panel displays an extra ideology cleanly.
3. That flavoured IGs, for example renamed Devout or Landowners variants,
   still have the same `ig_` key the loop matches on.

## 6. Starting laws (1836)

Set by the same game-start event, before ideologies matter:

| Law | Countries | Basis |
|---|---|---|
| Turnpike Trusts | GBR, USA | Turnpike era at its peak |
| Public Highways | FRA, PRU | Ponts et Chaussées, Chausseebau |
| Statute Labour | everyone else | The historical norm |

**As implemented:** the same setup effect assigns the law, but only when the
country has none of the three, so it never overrides a law the engine or a
player already chose. Statute Labour is listed first in the law file in case
the engine auto-assigns before history runs. **[to verify]** Whether the engine
auto-assigns a law in a new group at all.

Note the interaction: Britain in 1836 has just passed the 1835 Highway Act
abolishing statute labour, so Turnpike Trusts is correct for it.

## 7. AI

- IG stances drive most AI law desire. **[verified in the lessons file]**
  Vanilla uses the same mechanism.
- Add a modest `ai_enact_weight_modifier` (100–150, "quiet-stretch politics"
  per the lessons file):
  - **Turnpike Trusts:** favoured while the country runs a deficit.
    **[to verify]** the budget trigger's name.
  - **Public Highways:** favoured once the country is solvent and
    Industrialists or Intelligentsia are in government.
  - Keep the standard petition hook
    (`ai_has_enact_weight_modifier_journal_entries`).
- The new PM group has exactly one valid PM at a time, so AI PM selection is
  not an issue.

## 8. Phase 2: events and harbours

Not part of the first build, but the laws are what give these events a trigger:

- **Rebecca Riots:** under Turnpike Trusts, in a state with a strong or angry
  Rural Folk presence. Choices: abolish tolls here (lose the discount in that
  state for a period), suppress (radicals, authority cost), or appoint a
  commission (bureaucracy cost, temporary calm).
- **Road-duty defaulters:** under Statute Labour, when peasant SoL is low.
  Temporary infrastructure penalty, or an order to enforce the duty with a
  radicalism cost.
- **"A Highway Act":** a flavour event when a country leaves Statute Labour.
- **Harbour Works:** add `pmg_boi_harbour_financing` using the same three laws
  (harbour dues = tolls, press-ganged dock labour = statute labour). Deferred
  to keep phase 1 small.
- **Later law:** a *Dedicated Road Fund* (UK 1909, fuel and vehicle duties),
  unlocked by `combustion_engine`, which would discount the motor-road tiers.

## 9. Open questions for you

1. **Numbers:** are −40% / −50% the right size of discount? They are sized to
   make the cheap laws tempting in the opening horse shortage without making
   Public Highways pointless.
2. **Statute Labour and serfdom:** should Statute Labour be *disallowed* once
   `law_peasant_proprietorship` or `law_commercialized_agriculture` is in
   force? It is more historical, but it forces a law change on the player.
3. **Petty Bourgeoisie:** with the §4a benefits they now *strongly* approve
   Turnpike Trusts. Is that too strong a pull for a group that is small in 1836?
4. **Benefit sizes (§4a):** the per-level farm and ranch throughput bonus under
   Statute Labour is the one that grows with the network. Is +1% per level the
   right size, or should it be capped by attaching it to the law instead?
5. **Tech gate on Public Highways:** leave it ungated (so France and Prussia can
   start with it), or gate it on `centralization` and hand-assign it to those
   two? **[verified]** `centralization` exists as a tech key.
6. **Scope:** roads only in phase 1 (recommended), or Harbour Works too?

## 10. Files touched

All new, or BOI-owned. No vanilla shadows.

| File | Change |
|---|---|
| `common/law_groups/50_boi_law_groups.txt` | new: law group |
| `common/laws/50_boi_road_financing.txt` | new: three laws |
| `common/ideologies/50_boi_road_ideologies.txt` | new: four ideologies |
| `common/production_methods/50_boi_infrastructure.txt` | add part 3: three financing PMs |
| `common/production_method_groups/50_boi_pm_groups.txt` | add `pmg_boi_road_financing` |
| `common/buildings/50_boi_buildings.txt` | add the group to Public Works |
| `events/boi_road_financing_events.txt` | new: hidden setup/maintenance event |
| `common/on_actions/zz_boi_on_actions.txt` | new: `events = { }` hooks only |
| `localization/english/boi_l_english.yml` | laws, ideologies, PMs, group |
| `common/scripted_effects/50_boi_road_financing_effects.txt` | new: idempotent setup effect (starting law + ideologies) |
| `common/history/global/zz_boi_road_financing.txt` | new: runs the setup effect at game start |

Rough size: about 300 lines of script plus localization.
