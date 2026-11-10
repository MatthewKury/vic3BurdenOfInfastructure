# Proposal: an event for a state with spare infrastructure

Written 2026-11-09 and revised the same day with your answers. **Built 2026-11-09** (`events/boi_infrastructure_surplus_events.txt`); the differences from this proposal are listed under "As built" at the end. It is item D1 of [the feature-complete plan](06_FEATURE_COMPLETE_PLAN.md), and it gets built after the review fixes (phase 6). Numbers marked *test value* are first guesses, for headless runs to tune.

## The idea

Most of BOI is about states that run short. This event rewards the opposite case: a state whose infrastructure is well ahead of what it uses, and which has at least one works building.

- The works have been built ahead of the traffic, and someone wants the spare capacity.
- The event comes in **two versions**, a *town* one and a *country* one, with **three options each**:
  - each version has exactly one option that pleases the Industrialists;
  - the country version has an option for the Rural Folk.
- Each option gives a 5-year bonus, and most please an interest group. Choosing one group passes over the others but costs nothing else.

## When it fires

### A qualifying state

A new scripted trigger, `boi_surplus_state_eligible` (state scope). All of these must hold:

1. The state is incorporated.
2. It has at least one level of Road Works, Rail Works or Harbour Works (`building_boi_infrastructure`, `building_boi_rail_works`, `building_boi_harbour_works`). The check uses `any_scope_building` with `level >= 1`.
3. **Spare infrastructure is at least 30.** Spare means `infrastructure` minus `infrastructure_usage`, which the existing `boi_ai_spare_infrastructure` computes. *(Agreed 2026-11-09.)*
4. **Infrastructure is at least 1.5 times usage.** This needs a new value, `boi_surplus_infrastructure_ratio`: `infrastructure` divided by `infrastructure_usage`, with usage floored at 1. *(Agreed 2026-11-09.)*
5. **At least one version fits the state** (see below): it has manufacturing, or it has both farms and extraction.
6. It has no `boi_surplus_state_cooldown` (10 years, *test value*) and none of the event's state modifiers.

**Why both tests 3 and 4:**

| Test alone | Fires wrongly on |
| --- | --- |
| Spare ≥ 30 only | A big industrial state with 300 supply and 265 usage. That's only 13% headroom, which one new factory uses up. |
| Ratio ≥ 1.5 only | A tiny state with 6 supply and 2 usage. The ratio is large, but there's nothing there to reward. |

### The country

- **Dispatcher:** a hidden yearly event, `boi_surplus.1`, in `on_yearly_pulse_country`. It rolls 10% (*test value*) for a country that:
  - isn't decentralised;
  - has no `boi_surplus_cooldown`, which is **15 years** *(your answer, 2026-11-09)*;
  - owns a qualifying state.
- **Which state:** the qualifying state with the most spare infrastructure. The pick uses `ordered_scope_state` with `order_by = boi_ai_spare_infrastructure` and **`max = 1`** (see C12 in the plan).
- **Which version:** if only one fits the state, that one. If both fit, a 50/50 `random_list` with a `trigger` on each entry.
- **Cooldowns:** firing sets the country cooldown and the state cooldown.

### How often (estimated from fc_game2, run `20261108-142017_mod`)

These figures come from the housing telemetry's per-state lines each December. Those lines cover about 280 states, in the countries that module logs. Works buildings were matched from the history seed only, so works built during the game are missing and the counts are a **lower bound**.

| Year | Qualifying states (spare ≥ 30, ratio ≥ 1.5) | Of those, with industry | Without industry |
| --- | ---: | ---: | --- |
| 1839 | 14 | 10 | Entre Douro and Minho, Kyushu, Pomerania, Ulster |
| 1845 | 15 | 11 | the same four |
| 1851 | 12 | 9 | Kyushu, Pomerania, Ulster |
| 1855 | 10 | 8 | Pomerania, Ulster |

So the town version fits most qualifying states. The country version's fit depends on extraction buildings, which this telemetry doesn't log. In 1855 the states with the largest surplus were:
- France: Rhône, Brittany, Poitou-Saintonge, Normandy, Lorraine and Aquitaine;
- Ulster, Pomerania, Tennessee and Western Norway.

With the 10% roll and the 15-year country cooldown, a country that keeps a qualifying state would see the event about once every 20–25 years, or four or five times in a full game.

## The event: "Ahead of the Traffic"

*Placement:* the chosen state. The description changes with the works building the state has: Road Works ("the new roads stand half-empty"), Rail Works ("the goods sheds stand half-empty") or Harbour Works ("the new quays stand half-idle"). It uses `first_valid` with `triggered_desc`.

All three options in a version are always shown, because the version is chosen to fit the state. Every option lasts **5 years**. Every interest group reference is guarded with `ig:… ?=`.

### Version 1, the town (`boi_surplus.10`)

Fits a state with manufacturing: `any_scope_building = { is_building_group = bg_manufacturing }`. Vanilla's decrees use that test, and it matches the industry subgroups too.

| Option | State or country modifier, 5 years (*test values*) | Interest group |
| --- | --- | --- |
| **A. Open the roads to the mills** | State: `building_group_bg_manufacturing_throughput_add = 0.10` | **Industrialists** pleased |
| **B. A market-town charter** | State: `state_migration_pull_mult = 0.15` and `state_construction_mult = 0.10` | Petty Bourgeoisie pleased |
| **C. Proclaim the government's works** | Country: legitimacy, scaled by press control (below) | none |

### Version 2, the country (`boi_surplus.11`)

Fits a state with farms, ranches or plantations (`bg_agriculture`, `bg_ranching`, `bg_plantations`) **and** at least one extraction building (`bg_extraction`, the parent of mining, logging and the other extraction groups).

| Option | State modifier, 5 years (*test values*) | Interest group |
| --- | --- | --- |
| **D. Open up the hinterland** | `building_group_bg_extraction_throughput_add = 0.10` | **Industrialists** pleased |
| **E. Carry the harvest to market** | `building_group_bg_agriculture_throughput_add`, `_ranching_` and `_plantations_` each `0.10` | Landowners pleased |
| **F. Market roads for the villages** | `state_mortality_mult = -0.05`: grain and doctors reach the villages in a bad year | **Rural Folk** pleased |

E and F set the Landowners against the Rural Folk: the same roads serve the estate's harvest or the village's.

### Option C: legitimacy scaled by press control *(your answer, 2026-11-09)*

The government claims the works as its own. The more it controls the press, the more the papers carry the message. The option adds a country modifier, `boi_surplus_government_works`, with `country_legitimacy_base_add = 3`, for 5 years. It's added with `multiplier = boi_surplus_press_control`, a country-scope script value read from the Free Speech law group (`common/laws/02_free_speech.txt`):

| Law | Multiplier | Legitimacy, 5 years |
| --- | ---: | ---: |
| Protected Speech | 1 | +3 |
| Right of Assembly | 2 | +6 |
| Censorship | 3 | +9 |
| Outlawed Dissent | 4 | +12 |

Vanilla's event modifiers mostly give ±5 or ±10 legitimacy, so +3 to +12 sits in that range (*test values*). Vanilla uses `multiplier` on `add_modifier` in events (`paris_commune_pulse_events.txt`), and the tooltip shows the scaled number. Every country always has one Free Speech law, so the value is never empty.

### Interest group modifiers

New `boi_surplus_ig_pleased` (+3 approval), decaying over 1,825 days (*test value*). It works like the existing `boi_rf_ig_pleased`. No option angers a group.

### AI choice (`ai_chance`)

- Base 1 for each option, +1 when its interest group is in government.
- Option C: base 1, +1 under Censorship or Outlawed Dissent, where the reward is largest.

### Notes

- **Sizes.** Vanilla gives +0.04 to +0.1 throughput in comparable event modifiers (`00_ep2_02_modifiers.txt`). Plus 0.10 for 5 years sits at the top of that range. Statute Labour's road bonus reaches +0.20 at 20 levels, for scale.
- **Option F uses mortality, not standard of living,** following BOI's switch from SoL penalties to mortality (2026-11-01). An alternative is `state_market_access_price_impact`, which BOI already uses in the Rebecca Riots modifier.
- **The bonus doesn't end if the surplus goes.** Throughput doesn't add usage, so the bonus can't use up the surplus itself.
- **Flat values, not scaled with the surplus.** They're easier to read in the tooltip. Only C scales, with press control.
- **Works aren't touched.** No option removes or downsizes a works building, so `downsizeable = no` is unaffected.

## What it needs

| File | Change |
| --- | --- |
| `events/boi_infrastructure_surplus_events.txt` (new) | `namespace = boi_surplus`: `.1` the hidden dispatcher, `.10` the town version, `.11` the country version |
| `common/scripted_triggers/56_boi_surplus_triggers.txt` (new) | `boi_surplus_state_eligible`, `boi_surplus_state_has_works`, `boi_surplus_town_fits`, `boi_surplus_country_fits` |
| `common/script_values/56_boi_surplus_values.txt` (new) | `boi_surplus_infrastructure_ratio` (state), `boi_surplus_press_control` (country) |
| `common/static_modifiers/55_boi_surplus_modifiers.txt` (new) | five state modifiers, the legitimacy modifier and `boi_surplus_ig_pleased` |
| `common/on_actions/zz_boi_on_actions.txt` | add `boi_surplus.1` to `on_yearly_pulse_country` |
| `localization/english/boi_surplus_l_english.yml` (new) | two titles, three descriptions per version, flavour, six options, modifier names |
| `tools/headless-telemetry/boi` | a count of fires by version and option, so the runs show whether it fires |
| `CHANGELOG.md`, `README.md` | entries |

Every new file needs a UTF-8 BOM, which the 8 Nov smoke run caught when it was missing.

## Not yet verified in the engine

- That the `building_group_bg_*_throughput_add` keys work on a **state** modifier added by script. Vanilla uses them in event modifiers, but which scope those modifiers are applied to hasn't been checked.
- That `building_group_bg_extraction_throughput_add` reaches the child groups (mining, logging and so on). The parent and child keys are declared separately, so it may apply only to buildings whose own group is `bg_extraction`. If so, option D uses the mining and logging keys instead.
- That `is_building_group` matches child groups in a `limit`. This is inferred from vanilla's decrees.
- How often the country version fits, because the telemetry doesn't log extraction buildings.

## Decisions (2026-11-09)

1. **Thresholds:** spare ≥ 30 and ratio ≥ 1.5. Agreed.
2. **Options:** two versions with three options each, one Industrialist option per version, and an option for the Rural Folk.
3. **"Retrench the works"** is replaced by **"Proclaim the government's works"**: legitimacy for 5 years, more under more press control.
4. **Country cooldown:** 15 years.
5. **Timing:** build after the review fixes, so it goes into the long ensemble.

## As built (2026-11-09)

- **Option D uses `building_group_bg_mining_throughput_add` and `building_group_bg_logging_throughput_add`** (+0.10 each), not the parent `bg_extraction` key, whose reach to its child groups was unverified. The country version therefore needs a mine or logging camp (`is_building_group = bg_mining` or `bg_logging`), not just any extraction building.
- **Farms means commercial farms.** `bg_agriculture` and `bg_ranching` include their subsistence children (lessons file, §20), so the country version leaves out `bg_subsistence_agriculture` and `bg_subsistence_ranching`.
- **Settled in check runs** `20261109-072458_mod` and `20261109-072912_mod`:
  - **Eligible states:** 8–10 in January 1837 (6–8 fit the town version, 5 the country version). 14–17 states had a works building and 30 spare before the ratio and fit tests.
  - **Forced events:** forced for three countries in each run, the event applied a modifier and set the cooldown every time. The AI picked different options: mills, charter, hinterland, and the government's works.
  - **The yearly roll fires:** one country by the end of 1836.
  - **The legitimacy multiplier works:** Moldavia, under Right of Assembly (×2), went from 28 to 34 legitimacy.
  - **Throughput keys on a state modifier** are vanilla practice: `unincorporated_state` carries one.
- **Telemetry:** the rail-survey module's yearly `sp_counts` line counts the countries in cooldown, the eligible states and each modifier in use.
