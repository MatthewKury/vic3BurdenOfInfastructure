"""Collect headless ensemble runs into one self-contained SQLite database.

Reads the BOIENS| snapshot lines that the ensemble telemetry module
(tools/headless-telemetry/ensemble) writes to each run's mirrored debug.log,
plus the run's run.json, and stores them as one ensemble: a set of runs of the
same setup that differ only by the game's own randomness. Nothing in the
database points back at the run folders, so they can be deleted afterwards.

Usage (normally called by tools/Invoke-HeadlessEnsemble.ps1):
    python Build-EnsembleDb.py --db ensembles.sqlite --name vanilla_1836_1846 \
        --description "..." <run folder> [<run folder> ...]

Rebuilding an ensemble that already exists in the database replaces it.
Schema and example queries: tools/ensembles/README.md.
"""

import argparse
import base64
import datetime as dt
import json
import math
import pathlib
import re
import sqlite3
import sys

SCHEMA_VERSION = 2
START_YEAR = 1836

# Metric catalogue: (unit, description). Columns not listed here still load;
# they are stored with an empty description and reported at the end.
COUNTRY_METRICS = {
    "market_id": ("country_id", "Owner of the market the country trades in (itself unless in a customs union)"),
    "gdp": ("money/year", "Gross domestic product"),
    "sol": ("SoL", "Average standard of living, population weighted"),
    "population": ("pops", "Total population"),
    "literacy": ("fraction", "Literacy rate (0-1)"),
    "urbanization": ("points", "Sum of state urbanization (country_total_urbanization)"),
    "states": ("count", "States owned"),
    "incorporated_states": ("count", "Incorporated states"),
    "turmoil": ("fraction", "Country turmoil (0-1)"),
    "radicals": ("pops", "Radical population"),
    "loyalists": ("pops", "Loyalist population"),
    "rank": ("rank_value", "Country rank: 7 great, 6 major, 5 unrecognized major, 4 minor, 3 unrecognized regional, 2 insignificant, 1 unrecognized"),
    "prestige": ("points", "Prestige"),
    "infamy": ("points", "Infamy"),
    "legitimacy": ("points", "Government legitimacy (0-100)"),
    "techs": ("count", "Technologies researched"),
    "army": ("battalions", "Army size"),
    "navy": ("flotillas", "Navy size"),
    "at_war": ("flag", "1 if at war"),
    "is_subject": ("flag", "1 if a subject of another country"),
    "subjects": ("count", "Number of subjects"),
    "gold": ("money", "Gold reserves"),
    "debt": ("ratio", "Scaled debt (debt / debt ceiling; 0 when in the black)"),
    "credit": ("money", "Credit limit"),
    "income": ("money/week", "Total weekly income"),
    "expenses": ("money/week", "Total weekly expenses"),
    "fixed_income": ("money/week", "Fixed weekly income (taxes, tariffs etc.)"),
    "fixed_expenses": ("money/week", "Fixed weekly expenses"),
    "investment_income": ("money/week", "Net weekly income of the investment pool"),
    "tax_level": ("level", "Tax level (0 very low .. 4 very high)"),
    "gov_wage_level": ("level", "Government wage level (0 very low .. 4 very high)"),
    "mil_wage_level": ("level", "Military wage level (0 very low .. 4 very high)"),
    "bureaucracy": ("points", "Bureaucracy produced"),
    "bureaucracy_usage": ("points", "Bureaucracy used"),
    "authority": ("points", "Authority produced"),
    "authority_usage": ("points", "Authority used"),
    "influence": ("points", "Influence produced"),
    "influence_usage": ("points", "Influence used"),
    "infrastructure": ("points", "Infrastructure supply, summed over states"),
    "infrastructure_usage": ("points", "Infrastructure usage, summed over states"),
    "deficit_states": ("count", "States whose infrastructure usage exceeds supply"),
    "railway_levels": ("levels", "Railway levels"),
    "port_levels": ("levels", "Port levels"),
    "construction_levels": ("levels", "Construction sector levels"),
    "urban_center_levels": ("levels", "Urban center levels"),
    "trade_center_levels": ("levels", "Trade center levels"),
    "building_levels": ("levels", "All building levels except subsistence"),
    "admin_levels": ("levels", "Government administration levels"),
    "university_levels": ("levels", "University levels"),
    "livestock_ranch_levels": ("levels", "Livestock ranch levels"),
    "logging_levels": ("levels", "Logging camp levels"),
    "shipyard_levels": ("levels", "Shipyard levels"),
    "tooling_levels": ("levels", "Tooling workshop levels"),
    "steel_levels": ("levels", "Steel mill levels"),
    "coal_levels": ("levels", "Coal mine levels"),
    "iron_levels": ("levels", "Iron mine levels"),
    "bg_agriculture_levels": ("levels", "Building group bg_agriculture (includes subsistence farms)"),
    "bg_subsistence_levels": ("levels", "Subsistence farms and pastures"),
    "bg_plantations_levels": ("levels", "Building group bg_plantations"),
    "bg_ranching_levels": ("levels", "Building group bg_ranching (includes subsistence pastures)"),
    "bg_extraction_levels": ("levels", "Building group bg_extraction (mines, logging, fishing, oil, rubber)"),
    "bg_light_industry_levels": ("levels", "Building group bg_light_industry"),
    "bg_heavy_industry_levels": ("levels", "Building group bg_heavy_industry"),
    "bg_military_industry_levels": ("levels", "Building group bg_military_industry"),
    "bg_government_levels": ("levels", "Building group bg_government"),
    "bg_military_levels": ("levels", "Building group bg_military (barracks, naval bases, conscription)"),
    "bg_infrastructure_levels": ("levels", "Building group bg_infrastructure (railways, ports, construction)"),
}

STATE_METRICS = {
    "population": ("pops", "State population"),
    "urbanization": ("points", "State urbanization (total_urbanization)"),
    "infrastructure": ("points", "Infrastructure supply"),
    "infrastructure_usage": ("points", "Infrastructure usage"),
    "unemployment_rate": ("fraction", "Unemployment rate (0-1)"),
    "incorporated": ("flag", "1 if incorporated"),
    "railway_levels": ("levels", "Railway levels"),
    "port_levels": ("levels", "Port levels"),
    "urban_center_levels": ("levels", "Urban center levels"),
    "construction_levels": ("levels", "Construction sector levels"),
    "building_levels": ("levels", "All building levels except subsistence"),
    "market_access": ("fraction", "Market access (0-1)"),
    "gdp": ("money/year", "State GDP contribution"),
    "sol": ("SoL", "Average standard of living"),
    "wage": ("money/year", "Average annual wage"),
    "literacy": ("fraction", "Literacy (0-1)"),
    "unemployed": ("pops", "Unemployed working adults"),
    "radicals": ("pops", "Radical population"),
    "loyalists": ("pops", "Loyalist population"),
    "turmoil": ("fraction", "State turmoil (0-1)"),
    "migration": ("pops/week", "Net weekly migration"),
}

MARKET_METRICS = {
    "price": ("money/unit", "Market price"),
    "buy": ("units/week", "Market buy orders (demand)"),
    "sell": ("units/week", "Market sell orders (supply)"),
}

STATE_GROUPS = {"state", "state_ui"}
MARKET_GROUPS = {"price", "buy", "sell"}

# World aggregates per run and snapshot: name -> (unit, description, SQL over
# country_obs c or state_obs s).
WORLD_COUNTRY_AGGREGATES = {
    "countries": ("count", "Countries alive (not decentralized)", "COUNT(*)"),
    "gdp": ("money/year", "World GDP", "SUM(gdp)"),
    "population": ("pops", "World population", "SUM(population)"),
    "sol": ("SoL", "Population-weighted average SoL", "SUM(sol * population) / SUM(population)"),
    "literacy": ("fraction", "Population-weighted literacy", "SUM(literacy * population) / SUM(population)"),
    "urbanization": ("points", "World urbanization", "SUM(urbanization)"),
    "radicals": ("pops", "World radicals", "SUM(radicals)"),
    "loyalists": ("pops", "World loyalists", "SUM(loyalists)"),
    "countries_at_war": ("count", "Countries at war", "SUM(at_war)"),
    "subjects": ("count", "Countries that are subjects", "SUM(is_subject)"),
    "techs_mean": ("count", "Mean technologies researched", "AVG(techs)"),
    "army": ("battalions", "World army size", "SUM(army)"),
    "navy": ("flotillas", "World navy size", "SUM(navy)"),
    "gold": ("money", "World gold reserves", "SUM(gold)"),
    "countries_in_debt": ("count", "Countries with debt", "SUM(debt > 0)"),
    "income": ("money/week", "World government income", "SUM(income)"),
    "expenses": ("money/week", "World government expenses", "SUM(expenses)"),
    "infrastructure": ("points", "World infrastructure supply", "SUM(infrastructure)"),
    "infrastructure_usage": ("points", "World infrastructure usage", "SUM(infrastructure_usage)"),
    "deficit_states": ("count", "States short of infrastructure", "SUM(deficit_states)"),
    "railway_levels": ("levels", "World railway levels", "SUM(railway_levels)"),
    "port_levels": ("levels", "World port levels", "SUM(port_levels)"),
    "construction_levels": ("levels", "World construction sector levels", "SUM(construction_levels)"),
    "urban_center_levels": ("levels", "World urban center levels", "SUM(urban_center_levels)"),
    "building_levels": ("levels", "World non-subsistence building levels", "SUM(building_levels)"),
    "bg_light_industry_levels": ("levels", "World light industry levels", "SUM(bg_light_industry_levels)"),
    "bg_heavy_industry_levels": ("levels", "World heavy industry levels", "SUM(bg_heavy_industry_levels)"),
    "livestock_ranch_levels": ("levels", "World livestock ranch levels", "SUM(livestock_ranch_levels)"),
}
WORLD_STATE_AGGREGATES = {
    "unemployed": ("pops", "World unemployed working adults", "SUM(unemployed)"),
    "wage": ("money/year", "Population-weighted average wage", "SUM(wage * population) / SUM(population)"),
    "market_access": ("fraction", "Population-weighted market access", "SUM(market_access * population) / SUM(population)"),
    "turmoil": ("fraction", "Population-weighted state turmoil", "SUM(turmoil * population) / SUM(population)"),
}

FOCUS_RANK = 5  # countries at or above this rank at the first snapshot get country_stats
LINE_RE = re.compile(r"BOIENS\|[^\r\n]*")
REGION_RE = re.compile(r",([A-Za-z0-9+/]{6}==|[A-Za-z0-9+/]{7}=|[A-Za-z0-9+/]{8}),DATA_STATE_REGION_NAME_TOOLTIP,StateRegionTooltip ([^\x15]*)")
UNRESOLVED_RE = re.compile(r"\[[A-Za-z]")


def parse_date(text):
    return dt.datetime.strptime(text.strip(), "%B %d, %Y").date()


def quarter_index(day):
    return (day.year - START_YEAR) * 4 + (day.month - 1) // 3


def number(text):
    value = float(text)
    if math.isfinite(value) and value.is_integer():
        return int(value)
    return value


def parse_region(text):
    """State region field -> (engine region id or None, plain name)."""
    m = REGION_RE.search(text)
    if not m:
        return None, text.strip()
    region_id = int.from_bytes(base64.b64decode(m.group(1)), "little")
    return region_id, m.group(2).strip()


def percentile(sorted_values, q):
    if not sorted_values:
        return None
    pos = (len(sorted_values) - 1) * q
    lo = math.floor(pos)
    hi = math.ceil(pos)
    return sorted_values[lo] + (sorted_values[hi] - sorted_values[lo]) * (pos - lo)


def describe(values):
    values = sorted(v for v in values if v is not None)
    n = len(values)
    if not n:
        return None
    mean = sum(values) / n
    sd = math.sqrt(sum((v - mean) ** 2 for v in values) / (n - 1)) if n > 1 else 0.0
    return (n, mean, sd, values[0], percentile(values, 0.1), percentile(values, 0.5), percentile(values, 0.9), values[-1])


class Builder:
    def store_game_data(self, game_path):
        """Base prices and the price range from the installed game, so price
        ratios (price / base, and the 1 +/- PRICE_RANGE caps) work from the
        database alone. Skipped with a note when the game isn't found."""
        goods_dir = game_path / "game" / "common" / "goods"
        defines = game_path / "game" / "common" / "defines" / "00_defines.txt"
        if not goods_dir.is_dir():
            print(f"Note: no game install at {game_path}; goods.base_price left empty")
            return
        if "base_price" not in {r[1] for r in self.db.execute("PRAGMA table_info(goods)")}:
            self.db.execute("ALTER TABLE goods ADD COLUMN base_price REAL")
        for path in sorted(goods_dir.glob("*.txt")):
            goods = None
            for line in path.read_text(encoding="utf-8-sig").splitlines():
                m = re.match(r"^([a-z_]+)\s*=\s*\{", line)
                if m:
                    goods = m.group(1)
                m = re.match(r"^\tcost\s*=\s*([0-9.]+)", line)
                if m and goods:
                    self.db.execute("UPDATE goods SET base_price = ? WHERE name = ?", (float(m.group(1)), goods))
        if defines.exists():
            m = re.search(r"^\s*PRICE_RANGE\s*=\s*([0-9.]+)", defines.read_text(encoding="utf-8-sig"), re.M)
            if m:
                self.db.execute("INSERT OR REPLACE INTO meta VALUES ('price_range', ?)", (m.group(1),))

    def __init__(self, db_path):
        self.db = sqlite3.connect(db_path)
        self.db.execute("PRAGMA foreign_keys = ON")
        self.create_schema()
        self.unknown = {"country_obs": set(), "state_obs": set()}

    def create_schema(self):
        self.db.executescript("""
        CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT);
        CREATE TABLE IF NOT EXISTS ensemble (
            ensemble_id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL, description TEXT,
            arm TEXT, built_utc TEXT, n_runs INTEGER, first_date TEXT, last_date TEXT, game_version TEXT);
        CREATE TABLE IF NOT EXISTS run (
            run_id INTEGER PRIMARY KEY, ensemble_id INTEGER NOT NULL REFERENCES ensemble ON DELETE CASCADE,
            member INTEGER NOT NULL, run_name TEXT NOT NULL, arm TEXT, result TEXT, launched_utc TEXT,
            minutes REAL, until TEXT, game_version TEXT, n_snapshots INTEGER, run_json TEXT,
            UNIQUE (ensemble_id, member));
        CREATE TABLE IF NOT EXISTS snapshot (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL, date TEXT NOT NULL,
            PRIMARY KEY (run_id, t)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS country (country_id INTEGER PRIMARY KEY, tag TEXT UNIQUE NOT NULL);
        CREATE TABLE IF NOT EXISTS run_country (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, country_id INTEGER NOT NULL,
            engine_id TEXT NOT NULL, first_t INTEGER, PRIMARY KEY (run_id, country_id)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS state_region (region_id INTEGER PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS goods (goods_id INTEGER PRIMARY KEY, name TEXT UNIQUE NOT NULL);
        CREATE TABLE IF NOT EXISTS metric (
            table_name TEXT NOT NULL, column_name TEXT NOT NULL, unit TEXT, description TEXT,
            PRIMARY KEY (table_name, column_name)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS country_obs (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL,
            country_id INTEGER NOT NULL, market_id INTEGER,
            PRIMARY KEY (country_id, run_id, t)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS state_obs (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL,
            region_id INTEGER NOT NULL, owner_id INTEGER NOT NULL,
            PRIMARY KEY (owner_id, region_id, run_id, t)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS market_obs (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL,
            market_id INTEGER NOT NULL, goods_id INTEGER NOT NULL, price REAL, buy REAL, sell REAL,
            PRIMARY KEY (market_id, goods_id, run_id, t)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS world_obs (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL,
            metric TEXT NOT NULL, value REAL, PRIMARY KEY (run_id, t, metric)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS world_goods (
            run_id INTEGER NOT NULL REFERENCES run ON DELETE CASCADE, t INTEGER NOT NULL,
            goods_id INTEGER NOT NULL, price REAL, buy REAL, sell REAL,
            PRIMARY KEY (run_id, t, goods_id)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS world_stats (
            ensemble_id INTEGER NOT NULL REFERENCES ensemble ON DELETE CASCADE, t INTEGER NOT NULL,
            metric TEXT NOT NULL, n INTEGER, mean REAL, sd REAL, min REAL, p10 REAL, p50 REAL, p90 REAL, max REAL,
            PRIMARY KEY (ensemble_id, t, metric)) WITHOUT ROWID;
        CREATE TABLE IF NOT EXISTS country_stats (
            ensemble_id INTEGER NOT NULL REFERENCES ensemble ON DELETE CASCADE, t INTEGER NOT NULL,
            country_id INTEGER NOT NULL, metric TEXT NOT NULL,
            n INTEGER, mean REAL, sd REAL, min REAL, p10 REAL, p50 REAL, p90 REAL, max REAL,
            PRIMARY KEY (ensemble_id, t, country_id, metric)) WITHOUT ROWID;
        -- The observation tables are keyed entity-first (country, owner and
        -- region, market and goods), which suits time-series queries and needs
        -- no secondary index; world_* tables cover whole-world questions.
        CREATE INDEX IF NOT EXISTS run_ensemble ON run (ensemble_id);
        """)
        self.db.execute("INSERT OR REPLACE INTO meta VALUES ('schema_version', ?)", (str(SCHEMA_VERSION),))
        self.db.execute("INSERT OR IGNORE INTO meta VALUES ('start_year', ?)", (str(START_YEAR),))
        self.db.execute("INSERT OR IGNORE INTO meta VALUES ('t_definition', ?)",
                        ("t = (year - start_year) * 4 + (month - 1) / 3: quarters since January of start_year",))
        for table, catalogue in (("country_obs", COUNTRY_METRICS), ("state_obs", STATE_METRICS),
                                 ("market_obs", MARKET_METRICS), ("world_goods", MARKET_METRICS)):
            for column, (unit, text) in catalogue.items():
                self.db.execute("INSERT OR REPLACE INTO metric VALUES (?, ?, ?, ?)", (table, column, unit, text))
        for column, (unit, text, _) in {**WORLD_COUNTRY_AGGREGATES, **WORLD_STATE_AGGREGATES}.items():
            self.db.execute("INSERT OR REPLACE INTO metric VALUES ('world_obs', ?, ?, ?)", (column, unit, text))
        self.create_views()

    def create_views(self):
        self.db.executescript("""
        DROP VIEW IF EXISTS v_snapshot;
        CREATE VIEW v_snapshot AS
            SELECT e.name AS ensemble, r.member, s.run_id, s.t, s.date
            FROM snapshot s JOIN run r USING (run_id) JOIN ensemble e USING (ensemble_id);
        DROP VIEW IF EXISTS v_market;
        CREATE VIEW v_market AS
            SELECT e.name AS ensemble, r.member, m.run_id, m.t, s.date, c.tag AS market, g.name AS goods,
                   m.price, m.buy, m.sell
            FROM market_obs m JOIN run r USING (run_id) JOIN ensemble e USING (ensemble_id)
            JOIN snapshot s ON s.run_id = m.run_id AND s.t = m.t
            JOIN country c ON c.country_id = m.market_id JOIN goods g USING (goods_id);
        DROP VIEW IF EXISTS v_world;
        CREATE VIEW v_world AS
            SELECT e.name AS ensemble, r.member, w.run_id, w.t, w.metric, w.value
            FROM world_obs w JOIN run r USING (run_id) JOIN ensemble e USING (ensemble_id);
        DROP VIEW IF EXISTS v_world_stats;
        CREATE VIEW v_world_stats AS
            SELECT e.name AS ensemble, w.* FROM world_stats w JOIN ensemble e USING (ensemble_id);
        DROP VIEW IF EXISTS v_country_stats;
        CREATE VIEW v_country_stats AS
            SELECT e.name AS ensemble, c.tag, s.* FROM country_stats s
            JOIN ensemble e USING (ensemble_id) JOIN country c USING (country_id);
        """)

    def rebuild_wide_views(self):
        # v_country / v_state list every metric column, so recreate them after
        # columns are added.
        for view, table, keys in (("v_country", "country_obs", "o.country_id = c.country_id"),
                                  ("v_state", "state_obs", "o.owner_id = c.country_id")):
            cols = [r[1] for r in self.db.execute(f"PRAGMA table_info({table})")
                    if r[1] not in ("run_id", "t", "country_id", "owner_id", "region_id", "market_id")]
            extra = "sr.name AS state, " if table == "state_obs" else "m.tag AS market, "
            join = ("JOIN state_region sr ON sr.region_id = o.region_id" if table == "state_obs"
                    else "LEFT JOIN country m ON m.country_id = o.market_id")
            select = ", ".join(f"o.{c}" for c in cols)
            self.db.executescript(f"""
            DROP VIEW IF EXISTS {view};
            CREATE VIEW {view} AS
                SELECT e.name AS ensemble, r.member, o.run_id, o.t, s.date, c.tag, {extra}{select}
                FROM {table} o JOIN run r USING (run_id) JOIN ensemble e USING (ensemble_id)
                JOIN snapshot s ON s.run_id = o.run_id AND s.t = o.t
                JOIN country c ON {keys} {join};
            """)

    # --- dictionaries -------------------------------------------------------
    def country_id(self, tag, cache={}):
        if tag not in cache:
            self.db.execute("INSERT OR IGNORE INTO country (tag) VALUES (?)", (tag,))
            cache[tag] = self.db.execute("SELECT country_id FROM country WHERE tag = ?", (tag,)).fetchone()[0]
        return cache[tag]

    def goods_id(self, name, cache={}):
        if name not in cache:
            self.db.execute("INSERT OR IGNORE INTO goods (name) VALUES (?)", (name,))
            cache[name] = self.db.execute("SELECT goods_id FROM goods WHERE name = ?", (name,)).fetchone()[0]
        return cache[name]

    def region_id(self, field, cache={}):
        if field not in cache:
            region_id, name = parse_region(field)
            if region_id is None:
                # No engine id in the markup: fall back to a stable negative id per name.
                row = self.db.execute("SELECT region_id FROM state_region WHERE name = ? AND region_id < 0", (name,)).fetchone()
                region_id = row[0] if row else (self.db.execute("SELECT MIN(MIN(region_id), 0) - 1 FROM state_region").fetchone()[0] or -1)
            self.db.execute("INSERT OR IGNORE INTO state_region VALUES (?, ?)", (region_id, name))
            cache[field] = region_id
        return cache[field]

    def ensure_columns(self, table, keys):
        existing = {r[1] for r in self.db.execute(f"PRAGMA table_info({table})")}
        catalogue = COUNTRY_METRICS if table == "country_obs" else STATE_METRICS
        for key in keys:
            if key not in existing:
                if not re.fullmatch(r"[a-z][a-z0-9_]*", key):
                    raise ValueError(f"unsafe column name {key!r}")
                self.db.execute(f"ALTER TABLE {table} ADD COLUMN {key} REAL")
                existing.add(key)
                if key not in catalogue:
                    self.unknown[table].add(key)
                    self.db.execute("INSERT OR IGNORE INTO metric VALUES (?, ?, '', '')", (table, key))

    # --- loading ------------------------------------------------------------
    def parse_run(self, run_dir):
        """Parse one run's BOIENS lines. Returns the observations plus the
        snapshots dropped as incomplete, as {t: reason}."""
        debug = run_dir / "logs" / "debug.log"
        countries, states, markets, snapshots = {}, {}, {}, {}
        lines_per_group = {}   # (t, group) -> line count
        bad = {}               # t -> reason
        seen = set()           # (t, group, entity) already read
        skipped = 0
        # Tags are not unique: civil-war revolutionaries share their parent's
        # tag. The first engine id seen under a tag in this run keeps the plain
        # tag; later ones become TAG#2, TAG#3, ...
        labels, per_tag, first_t = {}, {}, {}

        def ident(tag, engine_id, t):
            if engine_id not in labels:
                per_tag.setdefault(tag, []).append(engine_id)
                n = len(per_tag[tag])
                labels[engine_id] = tag if n == 1 else f"{tag}#{n}"
                first_t[engine_id] = t
            return self.country_id(labels[engine_id])

        with open(debug, encoding="utf-8", errors="replace") as handle:
            for raw in handle:
                m = LINE_RE.search(raw)
                if not m:
                    continue
                line = m.group(0)
                if UNRESOLVED_RE.search(line):
                    skipped += 1  # the engine's unresolved copy of a line whose data function failed
                    continue
                parts = line.split("|")
                try:
                    day = parse_date(parts[2])
                except (ValueError, IndexError):
                    skipped += 1
                    continue
                t = quarter_index(day)
                group = parts[1]
                if group == "snapshot":
                    snapshots[t] = day.isoformat()
                    continue
                expected = 7 if group in STATE_GROUPS else 6
                if len(parts) != expected:
                    bad.setdefault(t, f"malformed {group} line")
                    continue
                entity = (parts[4], parts[5]) if group in STATE_GROUPS else parts[4]
                if (t, group, entity) in seen:
                    bad.setdefault(t, f"duplicate {group} line for {entity}")
                    continue
                seen.add((t, group, entity))
                lines_per_group[(t, group)] = lines_per_group.get((t, group), 0) + 1
                try:
                    pairs = [(k, v) for k, _, v in (pair.partition("=") for pair in parts[-1].split(";"))]
                    who = ident(parts[3], parts[4], t)
                    if group in MARKET_GROUPS:
                        target = markets.setdefault((t, who), {})
                        for goods, value in pairs:
                            target.setdefault(goods, {})[group] = number(value)
                        continue
                    if group in STATE_GROUPS:
                        target = states.setdefault((t, self.region_id(parts[5]), who), {})
                    else:
                        target = countries.setdefault((t, who), {})
                    for key, value in pairs:
                        if key == "market":
                            target["market_id"] = value  # engine id; resolved below
                        else:
                            target[key] = number(value)
                except ValueError:
                    bad.setdefault(t, f"unparsable {group} line (truncated?)")

        # A complete snapshot has its header, and every line family has the
        # same count in each of its groups (one line per country, state or
        # market per group). A gap or overlap in the log mirror breaks that.
        for t in {t for t, _ in lines_per_group} | set(snapshots):
            if t not in snapshots:
                bad.setdefault(t, "no snapshot header")
            counts = {g: n for (tt, g), n in lines_per_group.items() if tt == t}
            families = (STATE_GROUPS, MARKET_GROUPS, set(counts) - STATE_GROUPS - MARKET_GROUPS)
            for family in families:
                values = {counts.get(g, 0) for g in family if family is not families[2] or g in counts}
                if len(values) > 1:
                    bad.setdefault(t, "line counts differ between groups: "
                                   + ", ".join(f"{g}={counts.get(g, 0)}" for g in sorted(family)))
        for row in countries.values():
            if "market_id" in row:
                engine_id = row["market_id"]
                row["market_id"] = self.country_id(labels[engine_id]) if engine_id in labels else None
        identities = [(self.country_id(labels[e]), e, first_t[e]) for e in labels]
        for t in bad:
            snapshots.pop(t, None)
        countries = {k: v for k, v in countries.items() if k[0] not in bad}
        states = {k: v for k, v in states.items() if k[0] not in bad}
        markets = {k: v for k, v in markets.items() if k[0] not in bad}
        return countries, states, markets, snapshots, skipped, bad, identities

    def add_ensemble(self, name, description, run_dirs, include_failed):
        old = self.db.execute("SELECT ensemble_id FROM ensemble WHERE name = ?", (name,)).fetchone()
        if old:
            print(f"Replacing existing ensemble '{name}'")
            self.db.execute("DELETE FROM ensemble WHERE ensemble_id = ?", old)
        cur = self.db.execute("INSERT INTO ensemble (name, description, built_utc) VALUES (?, ?, ?)",
                              (name, description, dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds")))
        ensemble_id = cur.lastrowid
        member = 0
        arms, versions = set(), set()
        for run_dir in run_dirs:
            info_path = run_dir / "run.json"
            info = json.loads(info_path.read_text(encoding="utf-8-sig")) if info_path.exists() else {"run": run_dir.name}
            if info.get("result") != "PASS" and not include_failed:
                print(f"  skip {run_dir.name}: result {info.get('result')} ({'; '.join(info.get('failures') or [])})")
                continue
            countries, states, markets, snapshots, skipped, bad, identities = self.parse_run(run_dir)
            for t, reason in sorted(bad.items()):
                print(f"  {run_dir.name}: dropped snapshot t={t}: {reason}")
            if not snapshots:
                print(f"  skip {run_dir.name}: no ensemble snapshots")
                continue
            member += 1
            arms.add(info.get("arm"))
            versions.add(info.get("game_version"))
            cur = self.db.execute(
                "INSERT INTO run (ensemble_id, member, run_name, arm, result, launched_utc, minutes, until, game_version,"
                " n_snapshots, run_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (ensemble_id, member, info.get("run"), info.get("arm"), info.get("result"), info.get("launched"),
                 info.get("minutes"), info.get("until"), info.get("game_version"), len(snapshots), json.dumps(info)))
            run_id = cur.lastrowid
            self.db.executemany("INSERT INTO snapshot VALUES (?, ?, ?)", [(run_id, t, d) for t, d in snapshots.items()])
            self.db.executemany("INSERT INTO run_country VALUES (?, ?, ?, ?)",
                                [(run_id, c, e, t) for c, e, t in identities])
            self.insert_wide("country_obs", ("run_id", "t", "country_id"),
                             [((run_id, t, c), row) for (t, c), row in countries.items()])
            self.insert_wide("state_obs", ("run_id", "t", "region_id", "owner_id"),
                             [((run_id, t, r, o), row) for (t, r, o), row in states.items()])
            rows = []
            for (t, market), goods in markets.items():
                for goods_name, values in goods.items():
                    if not values.get("buy") and not values.get("sell"):
                        continue  # goods with no trade in this market: price would just be base price
                    rows.append((run_id, t, market, self.goods_id(goods_name),
                                 values.get("price"), values.get("buy"), values.get("sell")))
            self.db.executemany("INSERT INTO market_obs VALUES (?, ?, ?, ?, ?, ?, ?)", rows)
            print(f"  member {member}: {run_dir.name}: {len(snapshots)} snapshots, {len(countries)} country rows,"
                  f" {len(states)} state rows, {len(rows)} market rows"
                  + (f", {skipped} lines skipped" if skipped else "")
                  + (f", {len(bad)} snapshot(s) dropped" if bad else ""))
        if not member:
            raise SystemExit("No usable runs; nothing stored.")
        dates = self.db.execute("SELECT MIN(date), MAX(date) FROM snapshot JOIN run USING (run_id) WHERE ensemble_id = ?",
                                (ensemble_id,)).fetchone()
        self.db.execute("UPDATE ensemble SET arm = ?, n_runs = ?, first_date = ?, last_date = ?, game_version = ?"
                        " WHERE ensemble_id = ?",
                        (",".join(sorted(a for a in arms if a)), member, dates[0], dates[1],
                         ",".join(sorted(v for v in versions if v)), ensemble_id))
        self.derive(ensemble_id)
        self.rebuild_wide_views()
        return ensemble_id

    def insert_wide(self, table, key_cols, rows):
        keys = sorted({k for _, row in rows for k in row})
        self.ensure_columns(table, keys)
        cols = list(key_cols) + keys
        sql = f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join('?' * len(cols))})"
        self.db.executemany(sql, [tuple(key) + tuple(row.get(k) for k in keys) for key, row in rows])

    # --- derived tables -----------------------------------------------------
    def derive(self, ensemble_id):
        runs = [r[0] for r in self.db.execute("SELECT run_id FROM run WHERE ensemble_id = ?", (ensemble_id,))]
        country_cols = {r[1] for r in self.db.execute("PRAGMA table_info(country_obs)")}
        state_cols = {r[1] for r in self.db.execute("PRAGMA table_info(state_obs)")}
        for run_id in runs:
            for table, aggregates, cols in (("country_obs", WORLD_COUNTRY_AGGREGATES, country_cols),
                                            ("state_obs", WORLD_STATE_AGGREGATES, state_cols)):
                for metric, (_, _, expr) in aggregates.items():
                    needed = set(re.findall(r"[a-z_]+(?=\W|$)", expr)) - {"count", "sum", "avg"}
                    if not needed <= cols | {""}:
                        continue  # metric columns missing (older telemetry)
                    self.db.execute(f"INSERT INTO world_obs SELECT run_id, t, ?, {expr} FROM {table}"
                                    f" WHERE run_id = ? GROUP BY run_id, t", (metric, run_id))
            # World goods: summed orders, demand-weighted average price.
            self.db.execute("""INSERT INTO world_goods
                SELECT run_id, t, goods_id, SUM(price * buy) / NULLIF(SUM(buy), 0), SUM(buy), SUM(sell)
                FROM market_obs WHERE run_id = ? GROUP BY run_id, t, goods_id""", (run_id,))
        placeholders = ",".join("?" * len(runs))

        # world_stats: world_obs metrics plus world goods price/buy/sell, across runs.
        series = {}
        for t, metric, value in self.db.execute(
                f"SELECT t, metric, value FROM world_obs WHERE run_id IN ({placeholders})", runs):
            series.setdefault((t, metric), []).append(value)
        for t, goods, price, buy, sell in self.db.execute(
                f"SELECT t, g.name, price, buy, sell FROM world_goods JOIN goods g USING (goods_id)"
                f" WHERE run_id IN ({placeholders})", runs):
            for kind, value in (("price", price), ("buy", buy), ("sell", sell)):
                series.setdefault((t, f"goods:{goods}:{kind}"), []).append(value)
        self.db.executemany("INSERT INTO world_stats VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            [(ensemble_id, t, metric) + stats for (t, metric), values in series.items()
                             if (stats := describe(values))])

        # country_stats for the powers: rank >= FOCUS_RANK at the first snapshot of any run.
        focus = [r[0] for r in self.db.execute(
            f"""SELECT DISTINCT country_id FROM country_obs o
                WHERE run_id IN ({placeholders}) AND rank >= ?
                AND t = (SELECT MIN(t) FROM snapshot s WHERE s.run_id = o.run_id)""", runs + [FOCUS_RANK])]
        metrics = [c for c in sorted(country_cols) if c not in ("run_id", "t", "country_id", "market_id")]
        rows = []
        for country in focus:
            series = {}
            for record in self.db.execute(
                    f"SELECT t, {', '.join(metrics)} FROM country_obs WHERE country_id = ? AND run_id IN ({placeholders})",
                    [country] + runs):
                for metric, value in zip(metrics, record[1:]):
                    series.setdefault((record[0], metric), []).append(value)
            for (t, metric), values in series.items():
                stats = describe(values)
                if stats:
                    rows.append((ensemble_id, t, country, metric) + stats)
        self.db.executemany("INSERT INTO country_stats VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rows)
        print(f"Derived: world_obs, world_goods, world_stats, country_stats for {len(focus)} powers")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--db", required=True, type=pathlib.Path)
    parser.add_argument("--name", required=True, help="ensemble name, e.g. vanilla_1836_1846")
    parser.add_argument("--description", default="")
    parser.add_argument("--include-failed", action="store_true", help="also load runs whose result is not PASS")
    parser.add_argument("--game-path", type=pathlib.Path,
                        default=pathlib.Path(r"C:\Program Files (x86)\Steam\steamapps\common\Victoria 3"),
                        help="Victoria 3 install, read for goods base prices")
    parser.add_argument("runs", nargs="+", type=pathlib.Path, help="run folders under tools/headless-runs")
    args = parser.parse_args()

    args.db.parent.mkdir(parents=True, exist_ok=True)
    builder = Builder(args.db)
    with builder.db:
        builder.add_ensemble(args.name, args.description, args.runs, args.include_failed)
        builder.store_game_data(args.game_path)
    for table, keys in builder.unknown.items():
        if keys:
            print(f"Note: {table} columns without a catalogue entry: {', '.join(sorted(keys))}")
    builder.db.execute("VACUUM")
    builder.db.close()
    print(f"Wrote {args.db} ({args.db.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    sys.exit(main())
