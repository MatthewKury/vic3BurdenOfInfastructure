# Housing backend feasibility probe

Phase 1 of [the housing plan](../../IMPLEMENTATION_PLAN_HOUSING.md). This is a separate, optional debug mod; the main BOI mod does not load scripts under `tools`. Use a disposable campaign. It does not implement playable housing.

## Load and run

Register the add-on from the BOI directory using PowerShell (this creates one launcher descriptor alongside BOI):

```powershell
$probePath = (Resolve-Path './tools/housing-probe').Path.Replace('\', '/')
$registration = (Get-Content './tools/housing-probe/descriptor.mod' -Raw) + "`npath=""$probePath""`n"
[IO.File]::WriteAllText((Join-Path (Split-Path (Get-Location).Path -Parent) 'boi-housing-probe.mod'), $registration)
```

Enable **BOI Housing Feasibility Probe** in a test playset and launch Victoria 3 with `-debug_mode`. BOI may also be enabled; the probe uses vanilla assets and has no BOI dependency. Start a new Portugal campaign, pause, open the debug console, and run:

```text
event boi_housing_probe.1
event boi_housing_probe.2
```

The first command selects the current country's capital **owned state**, once per campaign. A global pointer prevents subsequent calls from initializing another state or resetting counters, even after a capital move. The second refreshes and displays its numeric snapshot. Console syntax, scope resolution, localization links and engine acceptance must be checked in the first runtime session.

| Command | Purpose |
| --- | --- |
| `event boi_housing_probe.1` | Initialize one state's probe; repeated calls do nothing |
| `event boi_housing_probe.2` | Refresh/read snapshot; does not advance fixture or monthly counter |
| `event boi_housing_probe.3` | Create one test accommodation level, once; begins real government spending as it hires |
| `event boi_housing_probe.4` | Stop monthly sampling; preserves data and building |
| `event boi_housing_probe.5` | Resume sampling without resetting accounts |

Event `.10` is the monthly state hook; do not manually fire it. A 27-day flag guards closely duplicated deliveries. This is a probe of hook timing, not a verified calendar-based scheduling system. Stopping sampling does **not** stop building expenses: demolish the test building or discard the campaign. Removing the add-on is intended for a new campaign, not as a supported save migration.

## Runtime checklist

Record observed results in [HOUSING_FEASIBILITY.md](../../HOUSING_FEASIBILITY.md), including dates and new log messages. Nothing below has already passed in game.

1. Before enabling, confirm no probe building, variables or expenses exist in a normal BOI campaign. After enabling but before `.1`, confirm no monthly probe activity. Check `error.log` for `boi_hp`, `boi_housing_probe`, invalid scopes, unknown triggers and localization errors.
2. Run `.1` twice. `.2` should show the same state, zero passes and fixture **100000** both times. Read population, workforce and dependents against the population panel; require workforce + dependents = residents. Inspect full, partial and zero employment, and a zero-workforce pop if available. A failed numeric reader can silently produce zero: a clean log alone is insufficient.
3. Advance three monthly pulses. Expect counters **1, 2, 3** and synthetic values **90000, 85000, 82500**. These are fixture numbers, not housed residents. Check `debug.log` for `BOI_HP` dated samples; snapshots also log but do not increment counters.
4. Save immediately after the first pulse, reload, repeat `.1` and `.2`, and verify no reset or additional monthly pass. Repeat across February and a year boundary. Stop/resume sampling, transfer the selected state, and move the capital. Confirm the original owned state remains the sole target; state destruction or merging may invalidate the pointer and is not handled by this prototype.
5. Run `.3` twice. There should be exactly **one** accommodation level, initially with vacancies; its maintenance PM has 100 laborer slots, 5 wood and 1 tool at full staffing. Record staffing, actual goods purchases, wages and government budget before and after hiring. Confirm no extra level or free replacement after demolition.
6. Compare numeric levels and occupancy with the building panel. Shortage is a boolean diagnostic, not a measured supply fraction. Lay off staff or restrict inputs in the disposable campaign; physical levels should remain. Condition stays at the fixed test value 1; this phase does not implement condition decay. Capacity is an illustrative 1000 persons/level times condition times clamped (1 - devastation), not occupied provision.
7. Apply controlled devastation in the debug explorer and compare the numeric sample to the panel. Test 0%, 25%, 100%: if the reader is 0-1, one level gives 1000, 750, 0 capacity. Do not confuse percentage-point `add_devastation` effects with the numeric reader's scale. Confirm by observation before accepting this formula.
8. Hover/click the report's state name and verify its tooltip/navigation opens the selected state, including after a capital change. This event is the simpler presentation fallback; a custom state tooltip and alert remain unverified.
9. For payments, capture pop expenditure and provider income under two law/scarcity settings. There is no verified transfer implementation in this probe: record **blocked**, not a zero-valued pass. The public test building proves only a potential government-operated cost centre. Occupied public places and matched private reimbursement have not been implemented or demonstrated.

The employment estimate uses state unemployment applied to aggregate workforce and dependents. It does not observe individual employed workers, workplace links, or families, and can misallocate dependents when groups have different employment/dependent ratios. Zero workforce avoids division, but dependent-only residents are not resolved into an eligibility account. Rural/urban allocation, Poor Laws, maintenance dynamics, emergency shelter, seeding and AI belong to later phases.

## Static validation

From the BOI directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Test-HousingProbe.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
```

The expression test reads the actual probe script values and interprets their small arithmetic subset. It checks expected sequences, employment estimate extremes and damage/capacity bounds. It does not emulate the engine, prove trigger arithmetic, or establish save/load behavior.
