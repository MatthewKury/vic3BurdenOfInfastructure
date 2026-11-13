# Steel and construction: larger-scale ideas (for discussion)

> **Status (end of 2026-11-13):** the chosen direction is
> [11_PUBLIC_WORKS_HUB_DESIGN.md](11_PUBLIC_WORKS_HUB_DESIGN.md).
> - Railways get their infrastructure back (idea D, without Rail Works).
> - No works in the construction queue (idea H).
> - Running costs follow use, and the population floor is discounted from the bill, which does
>   most of idea F's job.
> - Steel demand is expected to come back with vanilla railways. Measure it in plan 11's
>   40-year ensemble.

Written 2026-11-10, after the steel-demand iterations in
`docs/reports/steel_10_Nov_2026/BALANCE_LOG.md`. **Nothing here is decided or
implemented.** It is a menu to discuss in a later session. A plan goes in
`docs/plans/` before any code changes.

## The problem

The 2026-11-10 changes added demand:
- Rail Works buy iron, then steel, plus 1.5 railway levels' transportation.
- Harbour Works buy clippers, then steamers and steel.
- Road Works buy engines from Steam-Rolled Roads on.
- A horse-price factor in the railway AI.

World steel still isn't reliably higher. At 1876, games ran 10.5k–18.8k a week, against
vanilla's 21.6k, and one country's luck (Prussia) moved the total more than the changes did.
Railways are unchanged: about 450, against vanilla's 678. Steel follows how much gets built,
and BOI builds less.

Three linked causes:

1. **Railways lost their main job.** In vanilla, infrastructure is the main reason railways
   get built. In BOI they live on transportation sales alone.
2. **The burden lands on the treasury, not the market.** The works are government cost
   centres. The 1836 seed costs Britain about £20k a week from day one, and its starting
   treasury is gone by October 1836 (vanilla: about £100k left). Vanilla Britain spends that
   treasury on construction sectors.
3. **The construction sector is about 20% smaller** worldwide, and 25–40% smaller in Britain,
   through 1876. Everything heavy comes later: steel mills, railways, engine buyers.

## Ideas

Keys marked ✓ exist in the 1.15 `modifier_type_definitions` or vanilla events (checked
2026-11-10). None of these ideas has been tested.

### Giving railways a reason to exist again

**A. Railways give market access instead of infrastructure.**
- Roads and works carry the load (infrastructure). Railways tie a state to its market's
  prices (`state_market_access_price_impact` ✓). The split fits the theme.
- Risk: the vanilla AI may not count market access when it scores a railway, so
  `00_boi_railway_ai_override.txt` would need a factor for it.
- The cleanest idea on design grounds.

**B. Railway levels set how many Rail Works a state can have.**
- For example, one Rail Works slot per two railway levels, in place of the fixed 1/2/4 cap.
- Railways become what unlocks rail infrastructure, and rich states keep building both.
- Costs a scripted cap, and a railway AI factor for "this state has spare Rail Works slots".
  The AI won't see that link on its own.

**C. Rail Works output grows with railway levels in the state.**
- A scripted state modifier adds infrastructure per railway level, only where a staffed Rail
  Works exists.
- Like B, but continuous rather than in steps. More script, and a monthly pulse.
- Lessons-file note: PM modifiers can't be gated on state conditions, so this has to go
  through a static modifier.

**D. The most sweeping: put railways back on the private side.**
- Railways give infrastructure again, but burn much more steel, engines and coal. Rail Works
  goes away.
- The burden stays on roads and harbours. The rail half of it moves into transportation
  prices that private owners pay.
- Steel demand comes back almost by construction.
- Gives up the state-funded Rail Works part of the design.

### Taking the strain off the treasury

**E. Toll income.**
- A periodic `add_treasury` ✓, scaled by each state's infrastructure use, larger under Tolls
  and Dues.
- The works partly pay for themselves, and their goods demand (steel, engines) stays.
- Catch: the AI's spending check (`MONEY_SPENDING_MIN_RATIO_TO_ADD_*`) probably counts only
  weekly budget income it can see. A lump payment may not lead to more construction sectors.
  Test that first.

**F. Phase the burden in.**
- A country modifier for inherited turnpikes cuts works goods costs by about 50% in 1836, and
  fades to zero over 15–20 years.
- Britain can build construction sectors first and take on the full bill later.
- This is the open "ease Britain's opening" question, but phased in, so the long-run burden
  doesn't change.

### Rebuilding construction capacity

**G. Make up the construction gap directly.**
- Construction-sector throughput (`building_construction_sector_throughput_add` ✓) or
  cheaper construction goods (`country_construction_goods_cost_mult` ✓), sized to the
  measured −20%.
- Blunt, and it hides some of the burden, but it goes straight at the number that limits
  steel.
- Could come from technology or a law rather than a flat bonus.

**H. Works stop competing for construction.**
- New works levels get a cheaper or near-zero construction cost, so building a road doesn't
  take a railway's or steel mill's place in the queue.
- The running cost stays the burden.

## Recommendation (from the 2026-11-10 session)

**B (or C) with F.**
- B gives railways back a structural role without undoing the Rail Works design.
- F fixes the opening, which is where the 40-year gap starts.
- Keep G in reserve: if construction is still 10% or more short after B and F, use G to
  close the rest.
- D is the fallback if the government-funded rail model keeps fighting the AI.

## Testing, whichever is chosen

- **More games per test.** 4–6 games per arm, not 2: Prussia's and Britain's fortunes
  dominate two-game tests.
- **No `-RailSurvey`** until the rail-survey decisions and JEs are revisited. It drove
  Britain into early revolt.
- **The quarterly 1836 check.** Compare `gold` and `construction_levels` against vanilla
  each quarter through 1836 before blaming later mechanics (see the lessons file, section 13).
- **The telemetry crash.** It hit 3 of 6 forty-year games. A `-NoHousing` harness switch
  might lower the crash rate, but it would also drop the works counts.

## More ideas (added 2026-11-11)

Asked for on 2026-11-11, open to larger changes. Same status: nothing decided or tested.
Keys marked ✓ exist in the 1.15 `modifier_type_definitions` (checked 2026-11-11).

**I. Railways multiply infrastructure instead of adding it.**
- Railway PMs carry `state_infrastructure_mult` ✓ (vanilla's decree uses +0.1, some
  companies +0.05), scaled by workforce like the old `state_infrastructure_add`.
- Works make the base; railways make it go further. Infrastructure still isn't free: a state
  with no works gets almost nothing from a railway, so the bonus gates itself without script.
- Does C's job with a native key, with no monthly pulse and no scripted cap.
- Unknown: whether the multiplier also scales the population floor. Test that first.

**J. Railways make the works cheaper.**
- Railway PMs carry `building_group_bg_infrastructure_throughput_add` ✓ as a state modifier.
  Group throughput keys do work on state modifiers (vanilla `unincorporated_state`).
- `bg_boi_public_works` sits under `bg_public_infrastructure`, so the works get more
  infrastructure from the same goods. Railways relieve the burden rather than replace it.
- Side effect: the bonus also hits the railway itself and ports.

**K. Railways raise the output of the industries they serve.**
- Railway PMs carry `building_group_bg_mining_throughput_add` ✓ and
  `building_group_bg_manufacturing_throughput_add` ✓.
- Railways become an economic engine again, and that goes at the GDP gap directly.
- It is a buff, not a burden, so it needs sizing against vanilla GDP. The AI won't count it
  unless the railway `ai_value` gets a factor for mining and manufacturing levels in the state.

**L. Give railways part of their infrastructure back.**
- For example 25% of vanilla's figure on the first railway PM, rising to 60% by the last.
- A single dial between today's design and D. The cheapest thing here to test.

**M. State railways (Rail Works merged into the railway).**
- The railway becomes government-funded and gives infrastructure again; Rail Works goes away.
  The engine requires `ownership_type = no_ownership` on government-funded buildings.
- The AI builds railways through its own logic, and the burden stays with the state.
- If sales of the railway's transportation reach the treasury, this is E (toll income) for
  free. Unverified: check where a government building's sales revenue goes before planning.
- The largest change: loses private railway investment and railway companies, and needs
  `downsizeable = no` like the works.

**N. Heavy industry needs a railway.**
- After some technology, states with mines or factories but no railway take a throughput
  penalty (static modifier), and the railway `ai_value` gets a factor for those states.
- The stick version of K. Less fun, and it hurts the AI before it hurts the player.

**Supporting change for I, J and L: give the AI back its infrastructure trigger.**
- `00_boi_railway_ai_override.txt` swapped vanilla's infrastructure-deficit auto-expansion
  for a transportation-price threshold.
- The lessons file (§13) says transportation sits at its price ceiling across most of the
  world, so price can't signal where railways are needed. Once railways help infrastructure
  again, vanilla's deficit trigger can come back.

**Not pursued: more transportation demand.** Railways live on transportation sales, but
the price is already at its ceiling almost everywhere, so more demand wouldn't make them more
attractive to build.

**Follow-up (2026-11-13):** [09_INFRASTRUCTURE_FUNDING_AND_RAIL_ECONOMICS_IDEAS.md](09_INFRASTRUCTURE_FUNDING_AND_RAIL_ECONOMICS_IDEAS.md)
revisits ideas A, D, E and L from the angle of railway profitability:
- a traffic throughput bonus;
- market access per locomotive tier, as a workshop mod does;
- ownership as the public/private split.

**Updated recommendation (2026-11-11):** I with F, plus the AI trigger restored. I replaces
B or C as the favourite because it uses a native key and needs no script. L is the simplest
fallback. M is the option if a big redesign is on the table. G stays in reserve.
