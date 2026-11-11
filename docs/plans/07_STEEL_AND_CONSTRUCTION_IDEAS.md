# Steel and construction: larger-scale ideas (for discussion)

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
