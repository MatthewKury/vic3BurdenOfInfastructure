# Transport progression, works budget and upkeep tiers (for discussion)

> **Status (end of 2026-11-13):** largely superseded by
> [11_PUBLIC_WORKS_HUB_DESIGN.md](11_PUBLIC_WORKS_HUB_DESIGN.md), parts 13–14.
> - The horses → rail → motor ladder becomes the shared Mode group on Public Works, and the AI
>   picks on local cost (close to Option 1 here).
> - The upkeep tiers (part 3) were dropped: consumption follows real use.
> - The wage-slider link is parked in `docs/OVERVIEW.md` §6a.
> - Britain's opening is handled by discounting the population floor from the bill.
> - Parts 2 and 4 (budget findings, what infrastructure does) remain useful reference.

Written 2026-11-11 from a design discussion. **Nothing here is decided or implemented.**
It follows [07_STEEL_AND_CONSTRUCTION_IDEAS.md](07_STEEL_AND_CONSTRUCTION_IDEAS.md), whose
idea letters (A–N) are used below. A plan goes in `docs/plans/` before any code changes.

**The user's goals from this discussion:**
- Keep the mod's horses → rail → automobile progression.
- Let nations lean on horses instead of rail where it makes sense for them.
- Open to larger changes to the whole works family (Road, Rail and Harbour Works).
- Interested in a budget-window upkeep setting for the works (part 3).

**Where to resume:** the open decisions are listed at the end of each part and gathered in
part 5.

**Follow-up (2026-11-13):** [09_INFRASTRUCTURE_FUNDING_AND_RAIL_ECONOMICS_IDEAS.md](09_INFRASTRUCTURE_FUNDING_AND_RAIL_ECONOMICS_IDEAS.md)
covers:
- why railways lose money;
- the user's construction-sector idea;
- urban centres;
- a three-layer "paid network" alternative;
- infrastructure-law directions;
- an online survey of mods that tackle the same problem.

Its Transport Policy question overlaps with Option 3 here.

---

## 1. Transport progression: horses → rail → automobiles

### Where the story breaks today

- Road Works already climb horses → steam rollers → motors:
  `pm_boi_cart_roads` → `pm_boi_macadam_roads` → `pm_boi_steam_rolled_roads` →
  `pm_boi_motor_roads` → `pm_boi_modern_highways`.
- Rail sits off to the side, in Rail Works. They need a railway in the state, and their slots
  are capped at 1/2/4, raised by the rail survey.
- Railways themselves give no infrastructure, so the rail chapter of the story is missing.

### Engine limits that shape every option

All from `VIC3_MODDING_LESSONS.md`:
- **A production method can't depend on a state's conditions.** It can only be gated by a law,
  a technology, a principle or goods access. A state condition has to go through a separate
  building's `potential`, or through a modifier.
- **Laws can gate production methods** (`unlocking_laws` / `disallowing_laws`).
- **The works choose `most_productive`**, the method that gives the most infrastructure. They
  have been seen dropping back when an input hits its price ceiling: Motor Roads went back to
  Steam-Rolled Roads 11 times in two games, with automobiles at 170–175.
- **Script can switch methods** with `activate_production_method` in state scope. Verified on
  1.15 in BOI's harness, 2026-11-10.
- **`required_input_goods` works only for local goods.** Transportation is local, but whether
  the gate works for it is untested.

### Option 1: one road network that runs on horses, rail or motors (structural)

The Road Works ladder becomes **parallel options**, opened era by era, instead of one method
replacing the last:

| Era | Horse option | Rail option | Motor option |
|---|---|---|---|
| 1836 | Cart Roads | — | — |
| Railways tech | Macadam Roads (horses, tools) | Railhead Haulage (transportation, iron, few horses) | — |
| Steel railway cars | Steam-Rolled Roads (horses, engines) | Rail-Fed Network (transportation, steel) | — |
| Combustion | Heavy Draught Roads (horses, law-gated, see Option 3) | Electric Signalling | Motor Roads |
| Late | — | National Rail Grid | Highways |

- **The rail options buy transportation, which only railways produce.** Transportation is
  local, so a state needs railways nearby to feed them. The road network becomes the railways'
  biggest customer.
- **It sorts itself out by price.** No railways means expensive transportation, so the works
  stay on horses. Expensive transportation also triggers the railway rule the mod already has
  (`00_boi_railway_ai_override.txt` auto-expands at +25%), so railways get built. Then
  transportation gets cheaper and the works move to rail.
- **Rail Works:** either merge into this ladder (the cap goes), or stay as a heavy trunk-line
  building with its cap set by railway levels (idea B).
- **The rail survey can survive** as a regional bonus to the rail options.
- **Risks:** whether the AI really drops from rail to horses when transportation is short, and
  a large rebalance.

### Option 2: rail amplifies and replaces horses (lighter)

- The Road Works ladder stays horses → motors.
- **Railways boost state infrastructure by a percentage** (idea I, `state_infrastructure_mult`)
  **and cut horse use across their state** (`goods_input_horses_mult` on the railway's state
  modifier).
  - The mod defines that key itself. That it applies to every building in the state when it
    comes from a state modifier is inferred, not verified.
- **The story:** horses are the base everywhere, rail amplifies the network and displaces
  horses, and motors finish the job.
- **Horse nations** skip rail and pay the full horse bill, which is cheap where horses are cheap.
- **Trade-off:** less restructuring, but rail feels like an add-on rather than a stage.

### Option 3: a Transport Policy law (horse leeway; works with either option)

A new law group, linked to the existing road ideologies:

| Law | Supported by | Effect |
|---|---|---|
| **Horse Haulage** | Landowners, Rural Folk | Unlocks the best horse methods (post roads, remount stations, heavy draught). Horse Ranches and cavalry get stronger; rail options are weaker. Could also speed mobilisation (part 4). |
| **Railway Promotion** (railways tech) | Industrialists | Rail options and railway building are cheaper; Rail Works gets more slots. |
| **Motorisation** (combustion tech) | Industrialists, Petite Bourgeoisie | Motor options are boosted, and horse use drops faster. |

- **The AI chooses through politics.** Agrarian, aristocratic states (Russia, the Ottomans,
  Argentina) would lean on horses, and industrial ones on rail.

### Other ways to keep horses viable

- **Horse-Breeding Traditions state trait** (exists): cheaper horse inputs in that state.
- **Large, thinly populated states:** a yearly check gives a modifier that favours horses over
  rail. It has to be a modifier, not a production method.
- **A late horse method,** so horses are never strictly beaten. Motor Roads already keeps
  3 horses.
- **The military payoff** exists already (cavalry, horse mobilisation options) and could grow
  through mobilisation speed.
- **Horse exports:** surplus horse nations sell to rail-poor neighbours.

### Recommendation at the time

- **First choice: Option 1 with the Option 3 law.** It tells the whole story in one building,
  gives railways a role, and plugs into the existing railway rule. The law makes staying on
  horses a political choice.
- **Fallback:** Option 2.
- The construction gap and Britain's opening (ideas F and G) remain separate problems either way.

### Decisions open

1. Option 1 or Option 2?
2. Under Option 1, does Rail Works merge into the road ladder, or stay as a capped trunk line?
3. Does horse leeway come from the law, from state conditions (trait, sparse states), or both?

---

## 2. Works budget: was the budget hit before 10 November?

The user believed the budget wasn't much affected before the 10 November tests. **Mostly not
so:**
- For the world as a whole, the budget really wasn't much affected.
- Britain has been hit in every test since at least 3 November.

**Britain**, from `tools/ensembles/ensembles.sqlite` (13 vanilla games, 34 BOI games, 6–10 Nov).
"Sectors" means construction sector levels:

| Britain | Vanilla | BOI 6–8 Nov | BOI 9 Nov | BOI 10 Nov |
|---|---:|---:|---:|---:|
| Treasury, Oct 1836 | £104k | £3k | £0 | £0 |
| Treasury, 1838 | £96k | £0 | £0 | £0 |
| Sectors, Oct 1836 | 47 | 35 | 38 | 36 |
| Sectors, 1841 | 50 | 40 | 40 | 38 |

### Why it looked fine

- **World totals hide it.** Earlier reports compared world gold and "countries in debt", which
  were within noise.
- **The symptom changed shape.** On 1.13 (3 Nov), Britain borrowed: debt 0.46 against
  vanilla's 0.01, and expenses about £30k a week above vanilla. The 6 Nov change added works to
  the 1836 starting setup and brought its debt to 0.04, so it looked solved. Instead, the AI
  built fewer construction sectors, which doesn't show as debt.
- **Only Britain pays in construction.** France loses about £250k of its 1836 treasury
  (vanilla £369k, BOI £111–147k), but vanilla France doesn't spend that money on construction
  early, so nothing is lost. Vanilla Britain spends its £960k on construction sectors in the
  first nine months, and BOI takes that money first.
- **Other powers** (USA, Russia, Austria, Spain, Japan, Ottomans) are near vanilla. Prussia
  builds fewer sectors (10–13 against 15–18) but has plenty of gold, so its gap isn't the budget.

### Yesterday's changes didn't cause it

- `steel_iter1` had a slightly worse British year, but within the spread.
- The new inputs mostly start after 1836, and clippers cost slightly less than the merchant
  marine they replaced.
- The Tolls and Dues fix (`steel_iter2`) helped: Britain's fixed expenses fell below vanilla's
  by July 1836, and it kept 4 more sectors. That bug had been there all along.

### What it means for any redesign

- What matters is Britain's first-year bill, not the long-run burden.
- Keeping the 1836 bill flat, or phasing it in (idea F), would close most of the gap without
  softening the burden later.
- Option 1's horse-first opening helps naturally: the expensive rail options arrive with
  railways, after the opening construction spending.

---

## 3. Works upkeep tiers (Very Low → Very High)

**The user's idea:** a budget-window setting like government wages, with 5 tiers. Lower tiers
cost less but give less infrastructure.

### Feasibility

- **A true fourth budget slider isn't possible.** Tax, government wages and military wages are
  hard-wired in `gui/budget_panel.gui` (`SetGovernmentWageLevelVeryLow` … `VeryHigh`).
- **A lookalike is possible.** The Great Revision (workshop `3215078236`, installed locally)
  does it for its taxes:
  - it replaces `budget_panel.gui` wholesale;
  - its − / + buttons call scripted GUIs (`common/scripted_guis/TGR_TAX_PANEL_*_sguis.txt`);
  - each button steps a country variable and reapplies a static modifier with
    `multiplier = var:…`;
  - the AI never presses them: TGR reapplies a law-based default for AI countries every 60 days.
- **BOI needs more than TGR.** TGR's modifiers are country-wide. Mod building groups can't take
  group modifiers, so the tier has to live on the works buildings.

### Sketch

1. **A new "Maintenance" production method group** on Road, Rail and Harbour Works, with five
   methods. Each works building has 3 groups now, so a 4th still fits the building panel.
   Example numbers:

   | Tier | Goods | Workers | Infrastructure |
   |---|---:|---:|---:|
   | Very Low | −50% | −40% | −50% |
   | Low | −25% | −20% | −25% |
   | Medium | — | — | — |
   | High | +25% | +10% | +15% |
   | Very High | +50% | +20% | +25% |

   The upper tiers give back less than they cost, so High isn't a free win. Goods would use
   `building_goods_input_mult`, and infrastructure a negative or positive workforce-scaled
   `state_infrastructure_add`, as `pm_boi_conscripted_navvies` already does.
2. **Five buttons set the national tier.** Each switches every works building with
   `activate_production_method`, and new works pick up the national tier monthly.
3. **An AI rule in `events/boi_ai_infrastructure_events.txt`, per state:**
   - states with spare infrastructure drop to Low;
   - short states go to Medium or High;
   - when the treasury is empty, the AI steps down wherever there's spare infrastructure.

   This is better than TGR, whose AI doesn't use the setting.
4. **Optional, deferred maintenance against gaming.** Running below Medium builds a backlog
   that takes years at High to clear. Without it, a player can drop to Very Low in a crisis and
   restore it for free.

### Effect on Britain

- It helps, but modestly. Britain's home states use 80–100% of their infrastructure, so there
  is little spare to cut. Most savings would come from colonies and slack states.
- The phased opening (idea F) is still the bigger relief.

### Recommendation at the time

- Per-state tiers with the AI rule, plus a national setting for the player.
- Buttons in BOI's own panel first: the Urban tab where housing shows, or a journal entry.
- Move them to the budget panel later, if the clash with TGR is acceptable.

### Decisions open

1. **Where the buttons go:**
   - the budget panel clashes with TGR's wholesale copy; shadowing only one GUI type is lower
     risk, but untested by us, and would still beat TGR's version of that part;
   - BOI's own panel, or a journal entry, avoids the clash.
2. **A new setting, or the government wage slider?**
   - Works wages very likely already follow the government wage slider. That's inferred from
     how government-funded buildings work, not checked in-game.
   - Linking the tier to that slider means no new interface, and the AI already moves it
     (BOI Britain sits at minimum wages when broke).
   - The downside is that roads and the civil service move together.
3. Include deferred maintenance or not?

---

## 4. What infrastructure actually does (engine)

*Read from vanilla 1.15 `00_defines.txt`, `00_ai.txt` and the concept localization,
2026-11-11; not measured. Also recorded in `VIC3_MODDING_LESSONS.md` §13.*

**Rules are engine code; numbers are defines.** No script can change the market-access
formula. A mod can change:
- infrastructure supply and use;
- the define values;
- the price dial, `state_market_access_price_impact`;
- new consequences of its own. Script can read `infrastructure`, `infrastructure_usage`,
  `relative_infrastructure` and `market_access` in triggers and attach its own modifiers, as
  vanilla's decrees do.

| Effect | How | Setting |
|---|---|---|
| **Market access** (main) | Falls in proportion once use exceeds supply. Scales the state's buy and sell orders, and how closely local prices follow the market | `state_market_access_price_impact` |
| **Mobilisation speed** | 0.01 per infrastructure point; a battalion needs 1 point | `MOBILIZATION_INFRASTRUCTURE_FACTOR` |
| **Migration** | Caps weekly migration in or out of a state, scaled by infrastructure. Mass migration needs at least 70% market access | `MIGRATION_MAX_PER_STATE_INFRASTRUCTURE`, `MASS_MIGRATION_STATE_MIN_MARKET_ACCESS` |
| **Overseas states** | Infrastructure use costs merchant marine on the port connection | `OVERSEAS_INFRASTRUCTURE_MERCHANT_MARINE_COST_MULTIPLIER` |
| **Market share** | Half of a state's "market points" scale with market access (not traced further) | `MARKET_SHARE_MARKET_ACCESS_*` |
| **Where the AI builds** | Location score ×0.1 with no spare infrastructure; under 0.8 of use is critical | `OWNER_BUILDING_LOCATION_NO_AVAILABLE_INFRASTRUCTURE_MULT`, `MONEY_SPENDING_INFRASTRUCTURE_*` |
| **The map** | Paved roads at 500 infrastructure | `PAVED_ROAD_MIN_INFRASTRUCTURE` |

### What it means for BOI

- **The AI-building effect may be part of the construction gap.** BOI keeps states nearer
  their limit, which may steer private building away. This is unmeasured: a possible check is
  spare infrastructure in Britain's states against where its private buildings go.
- **Mobilisation suits the horse theme,** for example a faster mobilisation bonus under the
  Horse Haulage law.
- **It gives the upkeep tiers more weight.** Very Low would also slow mobilisation and
  migration, and BOI can add its own effects for short states.
- Vanilla almost never runs short (pop-weighted market access 99.8%), so BOI is the first time
  many states will feel these effects.

---

## 5. All open decisions, in one place

**Transport progression:**
1. Option 1 (parallel horse/rail/motor options) or Option 2 (rail amplifies infrastructure and
   displaces horses)?
2. Rail Works: merge into the road ladder, or keep it as a capped trunk line (idea B)?
3. Horse leeway: Transport Policy law, state conditions, or both?

**Budget:**

4. Ease Britain's opening with a phased bill (idea F)? This was already open from 10 November.

**Upkeep tiers:**

5. Buttons in the budget panel (clashes with TGR) or in BOI's own panel?
6. A separate setting, or linked to the government wage slider?
7. Deferred maintenance or not?

**From plan 07, still open:** the menu A–N; recommendation there: I with F, plus vanilla's
infrastructure-shortage railway rule restored.

**Before building any of it:** write a plan; run 4–6 games per test arm; no `-RailSurvey`
until the rail-survey decisions are revisited.
