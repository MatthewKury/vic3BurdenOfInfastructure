# Patch 1.15: what it gives Burden of Infrastructure

Source: the patch notes at https://vic3.paradoxwikis.com/Patch_1.15 (read 6 Nov 2026), checked
against the installed 1.15.0 game files. Signatures come from how vanilla uses each key, and none
of the new keys has been tested in BOI yet unless marked.

## Short answer

1.15 adds mostly war, strait, regional-objective and Russia content for modders. **Nothing in it
removes a workaround BOI depends on.** It has no way to remove one building level by script, no
PM triggers, no hook that lets the government-building AI see the works buildings, and no state-level
local-goods values. BOI also uses none of the keys 1.15 removed or renamed (war exhaustion,
`enemy_contested_wargoals`, `strait_trade_importance_by`, `pop_type_percent_country`,
`primary_cultures_percent_*`, `ship_interest_gain_mult`; checked by grep).

What it does give BOI is a few new readings and hooks, listed below in order of usefulness.

## Applied now

| Change | Where | Why |
| --- | --- | --- |
| `weeks_until_bankruptcy` and `taking_loans` logged yearly | `tools/headless-telemetry/boi` (`BOITM\|solvency\|` line) | The century runs found works orders stalled for decades in indebted countries, with the cause unknown. `scaled_debt` alone can't tell a country that borrows comfortably from one about to default. Vanilla uses this key as a value in `war_support_values.txt`. |
| Railway AI shadow rebuilt from the 1.15 block | `common/buildings/00_boi_railway_ai_override.txt` | 1.15 rewrote vanilla's railway `ai_value`, and the 1.13 copy silently undid that. Not a new capability, but the largest drift the patch caused. |
| Shadow-body diff tool | `tools/Compare-ShadowBodies.py` | `Test-ShadowSources.ps1` only proves keys exist. The railway drift passed that check. |

## Worth using in future work

**1. `weeks_until_bankruptcy` as a gate in the AI works event (concern 2 in the century report).**
`boi_ai_infrastructure.1` uses `scaled_debt < 0.75` today. Once the new telemetry shows how
the value behaves, the event could do one of two things. It could stop queueing when bankruptcy
is near, so orders don't pile up that will never be built. Or it could switch an indebted country
to the cheapest works option. Decide this after a run has logged it.
*First reading (balance pass 3, 2026-11-06):* Britain at the end of 1836 logged
`weeks_until_bankruptcy=654` with `taking_loans=1`. So the value is finite and meaningful while a
country borrows. A threshold still needs the full distribution from the ensemble runs.

**2. Preferred laws for characters and political movements (concern 3: the AI ignores the reform
laws).** 1.15 lets characters and movements list the laws they prefer, and vanilla queries them
with `any_preferred_law` / `ordered_preferred_law`. A road-reform or housing-reform movement that
prefers Turnpike Trusts or Public Highways, or Residential Standards, would push those laws
through politics rather than through AI weights. It is the most promising route to getting AI
countries off Statute Labour. The syntax still needs reading from vanilla's movement and character
files before designing it.

**3. Strata birth-rate modifiers.** `state_lower_strata_birth_rate_mult` (and middle and upper)
are new state modifiers. Housing quality could act on lower-strata birth rate instead of, or as
well as, mortality. Slums and Work Camps would then shape population growth without touching SoL
or radicals, which fits the 2026-11-01 decision to move penalties away from SoL.

**4. Journal entries with a scripted map mode, and progress bars with script-valued bounds.** A
player-facing "Infrastructure" journal entry could colour states by shortfall or by works financing.
Its bars could scale to the country, because their min and max can now be script values.
This is the cheapest route to a BOI UI without editing `.gui` files.

**5. `add_decree` / `remove_decree` / `replace_decree`.** BOI's Emergency Accommodation decree has
`ai_weight = 0`, so only players use it. The AI works event could now issue it to an AI country
during a housing crisis, and take it away afterwards.

**6. `enact_law` (enacts a law "as if its enactment had succeeded").** BOI's fixtures use
`activate_law`. `enact_law` may come closer to a real passage, including whatever the engine runs
on success, so it is the better effect for testing law side effects. Test it before switching.

**7. Alternative names for goods and building types.** Culture- or country-specific names for the
works and housing tiers (Chaussée, Turnpike, Statute Labour by country, and so on). Flavour only.

**8. `has_building_levels_in_state_region`** (region, building, levels, incorporation in one
trigger). This could replace some hand-built checks if BOI ever needs region-wide counts. BOI's
current counts are per state, so nothing uses it today.

**9. `fire_only_once` on events.** Vanilla now uses it widely. BOI's telemetry fixtures guard their
start with a global variable, and this could replace that guard. It isn't worth changing working
test code for.

## 1.15 gameplay changes that touch BOI

- **Railways.** "The AI and private sector no longer build railways to offset temporary
  infrastructure penalties." BOI already removed all of vanilla's infrastructure-deficit railway
  expansion, so this changes nothing for BOI.
- **New buildings use the dominant production methods of their type.** This may make the
  regressive financing PMs (Statute Labour, Conscripted Navvies) more persistent, because new works
  inherit them. Watch the financing PM shares.
- **Hiring and wages are more conservative**, and the 1846 vanilla wage is 17% lower than on 1.13.
  BOI's housing basket was sized against 1.13 incomes.
- **The AI builds more construction when it is short of investment for it.** Vanilla 1.15 has
  15% more construction and 25% fewer countries in debt by 1846, which may ease BOI's stalled
  works orders.
- **Copper is a new good** whose demand rises with electricity. BOI's Electric Light and Heat adds
  electricity demand, so it adds copper demand indirectly.
- **Fully occupied states keep half their market access**, and devastation now comes only from
  battles. Both soften war-time isolation, which used to cut off BOI states.
- **Crop failures are more lethal, and the Hungry Forties hit harder and later.** BOI's horse and
  grain demand on farms falls in the same window. Read 1840s mortality against the 1.15 baseline,
  not the 1.13 one.
