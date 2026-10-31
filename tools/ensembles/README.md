# Headless ensembles

An **ensemble** is the same unattended observer game run several times. Vanilla
Victoria 3 has no fixed random seed (`VIC3_MODDING_LESSONS.md` §20), so each
member plays out differently. The spread across members shows how much a metric
moves on chance alone. A mod's effect only counts if it falls outside that spread.

`ensembles.sqlite` in this folder holds every ensemble built so far. It is
**self-contained**: run metadata, the metric catalogue and every observation
live inside it, so the raw run folders in `tools/headless-runs/` can be deleted
once it is built. It is gitignored because it is too large for git: 134 MB for
10 members of 10 years, built from 804 MB of run folders. Back it up separately
if you need to keep it.

How much vanilla varies (10 members, January 1846, sd as % of mean): world GDP
1.7%, population 0.4%, SoL 2.2%, unemployed 5.3%, infrastructure 1.3%,
railway levels 11%, countries at war 66%. Individual powers vary much more than
the world: GDP varies 3–7% for China, Russia, Britain and France, but 16–24% for
Prussia, the USA and Austria. Small mod effects are therefore detectable in
world totals long before they are in any single country.

## Ensembles in the database

| Name | Members | Span | Setup |
|---|---|---|---|
| `vanilla_1836_1846` | 10 | 1836-01 to 1846-01, quarterly (41 snapshots) | Vanilla 1.13.11 with all installed DLC, no mods, `-handsoff` observer from the 1836 bookmark |

Run `SELECT * FROM ensemble` for the live list.

## Making or extending one

```powershell
# 10 vanilla members, 1836 to 1846 (about 11 minutes each; the game window is busy)
.\tools\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -Control -Runs 10
# The same with BOI loaded, for comparison
.\tools\Invoke-HeadlessEnsemble.ps1 -Name boi_1836_1846 -Runs 10
# Rebuild an ensemble's rows from its manifest without running the game
.\tools\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -Control -BuildOnly
```

The driver runs `Test-Headless.ps1 -Ensemble -NoSaves -NoFixtures` repeatedly.
It records the run folders in `tools/headless-runs/ensembles/<name>.json`, then
calls `Build-EnsembleDb.py`. The builder drops any snapshot that is incomplete and
says so. A snapshot is incomplete when it has no header line, the same
country, state or market appears twice, or its line groups have different
counts, which would mean the log mirror lost or repeated lines. Rerunning the
same command tops the ensemble up to
`-Runs` passing members. Raising `-Runs` later adds members the same way. Runs
that fail the harness's checks stay in the manifest but are left out of the
database. Building again replaces that ensemble's rows; other ensembles are
untouched. Building needs Python 3 (standard library only).

The game sometimes hangs after reaching its end date. The harness kills it
after 5 minutes without log output, and keeps the run when the final snapshot
was already taken.

The snapshots come from the `ensemble` telemetry module
(`tools/headless-telemetry/ensemble/`). The first country whose monthly pulse
lands in January, April, July or October logs every country, state and market
on that day. So all values in one snapshot share a date: in practice the 1st or
2nd of the month. The module only reads vanilla data, so BOI and vanilla
ensembles are measured identically.

## Reports

```powershell
python tools\ensembles\Make-EnsembleReport.py --ensemble vanilla_1836_1846
python tools\ensembles\Make-EnsembleReport.py --ensemble vanilla_1836_1846 --compare boi_1836_1846
```

This writes `docs/reports/<name>/REPORT.md` with SVG figures, viewable in VS
Code's Markdown preview (Ctrl+Shift+V). The script reads only the database.
`--compare` overlays the second ensemble (B, orange) on every world chart and
adds B, the difference, a Welch p-value and a pooled-spread MDE check to the
tables. It needs matplotlib (`pip install --user matplotlib`). Don't run it with
`python -I`, which hides user-installed packages. `--png <dir>` also writes PNG
copies. The current baseline report is
[docs/reports/vanilla_1836_1846/REPORT.md](../../docs/reports/vanilla_1836_1846/REPORT.md).

## Schema

`t` is the quarter index: `t = (year - 1836) * 4 + (month - 1) / 3`. So `t = 0`
is January 1836 and `t = 40` is January 1846. `snapshot.date` gives the exact day.
Members are numbered `1..n` within an ensemble.

| Table | One row per | Holds |
|---|---|---|
| `ensemble` | ensemble | name, description, arm (`control` = vanilla, `mod` = BOI), game version, member count, date span |
| `run` | member | run folder name, launch time, minutes, result; `run_json` is the harness's full `run.json`: installed and disabled DLC, mods with git commit, telemetry modules |
| `snapshot` | member × quarter | date of the snapshot |
| `country` | country label | `country_id` ↔ `tag`. Tags are not unique in-game: civil-war revolutionaries share their parent's tag. Within each run, the first country seen under a tag keeps the plain tag (`GBR`), and later ones are labelled `GBR#2`, `GBR#3` |
| `run_country` | member × country | the engine's numeric country id behind each label in that member, and the first quarter it appeared |
| `state_region` | state region | engine region id ↔ English name |
| `goods` | goods | `goods_id` ↔ goods key, and `base_price` read from the game install at build time. `meta.price_range` holds the engine's `PRICE_RANGE`: market prices are clamped to base × (1 ± 0.75) |
| `metric` | column | unit and description of every metric column, by table |
| `country_obs` | member × quarter × country | ~70 country metrics, see below; `market_id` is the market the country trades in |
| `state_obs` | member × quarter × state | 21 state metrics; a state region split between owners has one row per owner |
| `market_obs` | member × quarter × market × goods | `price`, `buy` (demand), `sell` (supply) per market (`market_id` = owner's `country_id`). Goods with no buy and no sell orders in a market are left out |
| `world_obs` | member × quarter × metric | world aggregates: sums, and population-weighted means for SoL, literacy, wage, market access and turmoil |
| `world_goods` | member × quarter × goods | world supply and demand, demand-weighted average price |
| `world_stats` | ensemble × quarter × metric | across members: `n, mean, sd, min, p10, p50, p90, max` of every `world_obs` metric, plus `goods:<goods>:price/buy/sell` |
| `country_stats` | ensemble × quarter × country × metric | the same statistics for every country metric, for the powers: countries at rank ≥ 5 (great, major, unrecognized major) at the first snapshot of any member |

The convenience views, `v_country`, `v_state`, `v_market`, `v_world`,
`v_world_stats`, `v_country_stats` and `v_snapshot`, add the ensemble name,
tags, state names, goods names and dates.

### Country metrics (`country_obs`)

- **Society:** `gdp`, `sol`, `population`, `literacy`, `urbanization`, `states`, `incorporated_states`, `turmoil`, `radicals`, `loyalists`
- **Standing:** `rank`, `prestige`, `infamy`, `legitimacy`, `techs`, `army`, `navy`, `at_war`, `is_subject`, `subjects`
- **Budget** (weekly): `gold`, `debt` (scaled), `credit`, `income`, `expenses`, `fixed_income`, `fixed_expenses`, `investment_income`, `tax_level`, `gov_wage_level`, `mil_wage_level`
- **Administration:** `bureaucracy`, `bureaucracy_usage`, `authority`, `authority_usage`, `influence`, `influence_usage`
- **Infrastructure** (BOI's core concern): `infrastructure`, `infrastructure_usage`, `deficit_states`, `railway_levels`, `port_levels`, `construction_levels`, `urban_center_levels`, `trade_center_levels`
- **Buildings:** `building_levels` (non-subsistence), `admin_levels`, `university_levels`, `livestock_ranch_levels`, `logging_levels`, `shipyard_levels`, `tooling_levels`, `steel_levels`, `coal_levels`, `iron_levels`, and building-group totals `bg_*_levels` (agriculture, subsistence, plantations, ranching, extraction, light, heavy and military industry, government, military, infrastructure)

### State metrics (`state_obs`)

`population`, `urbanization`, `infrastructure`, `infrastructure_usage`,
`unemployment_rate`, `incorporated`, `railway_levels`, `port_levels`,
`urban_center_levels`, `construction_levels`, `building_levels`,
`market_access`, `gdp`, `sol`, `wage`, `literacy`, `unemployed`, `radicals`,
`loyalists`, `turmoil`, `migration`.

### Metrics with BOI in mind

The mod changes infrastructure, transport, housing and horses, so the baseline
records what each of those touches in vanilla:

- **Infrastructure:** supply, usage, shortfall states, railway and port levels, state `market_access`.
- **Transport and its cost:** `transportation`, `merchant_marine`, `clippers` and `steamers` prices and orders, per market and world-wide.
- **Housing:** `urbanization`, urban center levels, construction capacity, `sol` and `wage`. Price and orders of `services`, `furniture` and `wood`.
- **Horses:** livestock ranch levels and the ranching group. Price and orders of `meat`, `grain` and `groceries`.
- **Road financing:** budget, debt and gold, and the government building groups.

BOI's own goods (horses, housing) and buildings aren't logged yet. A BOI
ensemble would need a small extra module for them. New `key=value` pairs load
automatically, as extra columns.

To add a metric, follow the steps at the top of `Generate-EnsembleEvents.py`.
It writes the module's event file, which is too repetitive to edit by hand.

## Example queries

```sql
-- Ensemble spread of world GDP over time
SELECT t, n, mean, sd, p10, p50, p90 FROM v_world_stats
WHERE ensemble = 'vanilla_1836_1846' AND metric = 'gdp' ORDER BY t;

-- Great Britain's railway levels in every member at the last snapshot
SELECT member, railway_levels, infrastructure, infrastructure_usage FROM v_country
WHERE ensemble = 'vanilla_1836_1846' AND tag = 'GBR' AND t = 40;

-- Transportation price in the Prussian market, mean and range across members
SELECT t, AVG(price), MIN(price), MAX(price) FROM v_market
WHERE ensemble = 'vanilla_1836_1846' AND market = 'PRU' AND goods = 'transportation'
GROUP BY t ORDER BY t;

-- States short of infrastructure at the end, by how often across members
SELECT state, tag, COUNT(*) AS members_short FROM v_state
WHERE ensemble = 'vanilla_1836_1846' AND t = 40 AND infrastructure_usage > infrastructure
GROUP BY state, tag ORDER BY members_short DESC;

-- Comparing a mod ensemble against the baseline at the last snapshot,
-- in standard deviations of the vanilla spread
SELECT v.metric, m.mean AS mod_mean, v.mean AS vanilla_mean, (m.mean - v.mean) / NULLIF(v.sd, 0) AS z
FROM v_world_stats v JOIN v_world_stats m ON m.metric = v.metric AND m.t = v.t
WHERE v.ensemble = 'vanilla_1836_1846' AND m.ensemble = 'boi_1836_1846' AND v.t = 40;
```

From Python: `sqlite3.connect('tools/ensembles/ensembles.sqlite')`. The views
work with `pandas.read_sql` if pandas is installed.
