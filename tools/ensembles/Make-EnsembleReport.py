"""Write a Markdown report with SVG figures for one ensemble, or compare two.

Reads only tools/ensembles/ensembles.sqlite (see README.md), never the run
folders. Renders in VS Code's built-in Markdown preview (Ctrl+Shift+V).

    python Make-EnsembleReport.py --ensemble vanilla_1836_1846
    python Make-EnsembleReport.py --ensemble vanilla_1836_1846 --compare boi_1836_1846

With --compare, the first ensemble is the reference (A, blue) and the second
the treatment (B, orange): every world chart overlays both, and the tables add
B, the difference, a Welch t-test p-value, and whether the difference exceeds
the minimum detectable effect. Default output: docs/reports/<A>[_vs_<B>]/.

Needs numpy and matplotlib (pip install --user matplotlib).
"""

import argparse
import collections
import datetime as dt
import math
import pathlib
import sqlite3
import statistics

import matplotlib

matplotlib.use("svg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from matplotlib.ticker import FuncFormatter, MaxNLocator  # noqa: E402

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent.parent

# Reference palette of the dataviz method (light surface), unchanged.
SURFACE, INK, INK2, MUTED = "#fcfcfb", "#0b0b0b", "#52514e", "#898781"
GRID, AXIS, QUIET = "#e1e0d9", "#c3c2b7", "#c3c2b7"
SERIES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
UP, DOWN = "#e34948", "#2a78d6"  # diverging poles; neutral midpoint is the axis
RAMP = ["#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b"]

plt.rcParams.update({
    "svg.fonttype": "none", "svg.hashsalt": "boi-ensemble",
    "font.family": ["Segoe UI", "DejaVu Sans"], "font.size": 9,
    "figure.facecolor": SURFACE, "axes.facecolor": SURFACE, "savefig.facecolor": SURFACE,
    "axes.edgecolor": AXIS, "axes.linewidth": 0.8, "axes.labelcolor": INK2,
    "axes.titlesize": 9.5, "axes.titleweight": "semibold", "axes.titlecolor": INK, "axes.titlelocation": "left",
    "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "axes.grid.axis": "y", "grid.color": GRID, "grid.linewidth": 0.6,
    "xtick.color": MUTED, "ytick.color": MUTED, "xtick.labelcolor": INK2, "ytick.labelcolor": INK2,
    "xtick.major.size": 0, "ytick.major.size": 0, "legend.frameon": False, "legend.fontsize": 8.5,
    "lines.solid_capstyle": "round",
})


# --- statistics ---------------------------------------------------------------
def _betacf(a, b, x):
    qab, qap, qam = a + b, a + 1, a - 1
    c, d = 1.0, 1 - qab * x / qap
    d = 1 / (d if abs(d) > 1e-300 else 1e-300)
    h = d
    for m in range(1, 300):
        m2 = 2 * m
        aa = m * (b - m) * x / ((qam + m2) * (a + m2))
        d = 1 + aa * d
        d = 1 / (d if abs(d) > 1e-300 else 1e-300)
        c = 1 + aa / c if abs(1 + aa / c) > 1e-300 else 1e-300
        h *= d * c
        aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
        d = 1 + aa * d
        d = 1 / (d if abs(d) > 1e-300 else 1e-300)
        c = 1 + aa / c if abs(1 + aa / c) > 1e-300 else 1e-300
        delta = d * c
        h *= delta
        if abs(delta - 1) < 1e-12:
            break
    return h


def _betainc(a, b, x):
    if x <= 0:
        return 0.0
    if x >= 1:
        return 1.0
    front = math.exp(math.lgamma(a + b) - math.lgamma(a) - math.lgamma(b) + a * math.log(x) + b * math.log(1 - x))
    if x < (a + 1) / (a + b + 2):
        return front * _betacf(a, b, x) / a
    return 1 - front * _betacf(b, a, 1 - x) / b


def t_cdf(t, df):
    tail = 0.5 * _betainc(df / 2, 0.5, df / (df + t * t))
    return 1 - tail if t > 0 else tail


def t_ppf(p, df):
    lo, hi = -50.0, 50.0
    for _ in range(100):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if t_cdf(mid, df) < p else (lo, mid)
    return (lo + hi) / 2


def mde(sd, n_a, n_b, alpha=0.05, power=0.8):
    """Smallest true difference a two-sided Welch-style test detects with the given power."""
    df = n_a + n_b - 2
    return (t_ppf(1 - alpha / 2, df) + t_ppf(power, df)) * sd * math.sqrt(1 / n_a + 1 / n_b)


def runs_needed(cv, effect, limit=1000):
    """Members per arm to detect a relative change `effect` given the metric's cv."""
    if not cv or not math.isfinite(cv):
        return None
    for n in range(3, limit):
        if mde(cv, n, n) <= effect:
            return n
    return None


def welch(a, b):
    a, b = [x for x in a if x is not None and math.isfinite(x)], [x for x in b if x is not None and math.isfinite(x)]
    if len(a) < 2 or len(b) < 2:
        return None
    va, vb = statistics.variance(a) / len(a), statistics.variance(b) / len(b)
    if va + vb == 0:
        return 1.0 if statistics.mean(a) == statistics.mean(b) else 0.0
    t = (statistics.mean(b) - statistics.mean(a)) / math.sqrt(va + vb)
    df = (va + vb) ** 2 / (va ** 2 / (len(a) - 1) + vb ** 2 / (len(b) - 1))
    return 2 * (1 - t_cdf(abs(t), df))


# --- formatting ---------------------------------------------------------------
def fmt(v, digits=3):
    if v is None or (isinstance(v, float) and not math.isfinite(v)):
        return "–"
    a = abs(v)
    for size, suffix in ((1e9, " B"), (1e6, " M"), (1e3, " k")):
        if a >= size:
            return f"{v / size:.{digits}g}{suffix}" if a / size < 1000 else f"{v / size:,.0f}{suffix}"
    if a >= 100:
        return f"{v:,.0f}"
    if a >= 1:
        return f"{v:.{digits}g}"
    return f"{v:.{digits}f}".rstrip("0").rstrip(".") if v else "0"


def pct(v, digits=1, sign=False):
    if v is None or not math.isfinite(v):
        return "–"
    return f"{v * 100:+.{digits}f}%" if sign else f"{v * 100:.{digits}f}%"


def axis_fmt(kind="num"):
    if kind == "pct":
        return FuncFormatter(lambda v, _: f"{v * 100:.0f}%")
    return FuncFormatter(lambda v, _: fmt(v, 3))


def table(headers, rows, align=None):
    align = align or ["l"] + ["r"] * (len(headers) - 1)
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join(":--" if a == "l" else "--:" for a in align) + "|"]
    out += ["| " + " | ".join(str(c) for c in row) + " |" for row in rows]
    return "\n".join(out)


# --- data -----------------------------------------------------------------------
class Ensemble:
    def __init__(self, db, name, color, label):
        self.db, self.name, self.color, self.label = db, name, color, label
        row = db.execute("SELECT ensemble_id, description, n_runs, first_date, last_date, game_version, arm"
                         " FROM ensemble WHERE name = ?", (name,)).fetchone()
        if not row:
            raise SystemExit(f"No ensemble '{name}' in the database")
        self.id, self.description, self.n, self.first_date, self.last_date, self.version, self.arm = row
        self.runs = db.execute("SELECT member, run_id, run_name, minutes, n_snapshots, run_json FROM run"
                               " WHERE ensemble_id = ? ORDER BY member", (self.id,)).fetchall()
        self.members = [r[0] for r in self.runs]
        self.run_ids = [r[1] for r in self.runs]
        self.T = db.execute("SELECT MAX(t) FROM snapshot WHERE run_id IN (%s)" % ",".join("?" * len(self.run_ids)),
                            self.run_ids).fetchone()[0] + 1
        self.cache = {}

    def q(self, sql, *args):
        return self.db.execute(sql, args).fetchall()

    def _matrix(self, rows):
        """rows of (member, t, value) -> members x T array (NaN where missing)."""
        m = np.full((len(self.members), self.T), np.nan)
        index = {mem: i for i, mem in enumerate(self.members)}
        for mem, t, v in rows:
            if v is not None and mem in index:
                m[index[mem], t] = v
        return m

    def world(self, key):
        if key in self.cache:
            return self.cache[key]
        if key == "utilization":
            out = self.world("infrastructure_usage") / self.world("infrastructure")
        elif key == "net_income":
            out = self.world("income") - self.world("expenses")
        elif key.startswith(("price:", "buy:", "sell:", "index:")):
            kind, goods = key.split(":")
            col = {"index": "w.price / g.base_price"}.get(kind, f"w.{kind}")
            out = self._matrix(self.q(f"SELECT r.member, w.t, {col} FROM world_goods w JOIN run r USING (run_id)"
                                      f" JOIN goods g USING (goods_id) WHERE r.ensemble_id = ? AND g.name = ?", self.id, goods))
        elif key.startswith("cap:"):
            goods = key.split(":")[1]
            rng = float(self.q("SELECT value FROM meta WHERE key = 'price_range'")[0][0])
            out = self._matrix(self.q(
                "SELECT r.member, m.t, SUM(CASE WHEN m.price >= g.base_price * ? * 0.999 THEN m.buy ELSE 0 END) / SUM(m.buy)"
                " FROM market_obs m JOIN run r USING (run_id) JOIN goods g USING (goods_id)"
                " WHERE r.ensemble_id = ? AND g.name = ? AND m.buy > 0 GROUP BY r.member, m.t", 1 + rng, self.id, goods))
        else:
            out = self._matrix(self.q("SELECT r.member, w.t, w.value FROM world_obs w JOIN run r USING (run_id)"
                                      " WHERE r.ensemble_id = ? AND w.metric = ?", self.id, key))
        self.cache[key] = out
        return out

    def country(self, tag, column):
        key = ("country", tag, column)
        if key not in self.cache:
            self.cache[key] = self._matrix(self.q(
                f"SELECT r.member, o.t, o.{column} FROM country_obs o JOIN run r USING (run_id)"
                f" JOIN country c USING (country_id) WHERE r.ensemble_id = ? AND c.tag = ?", self.id, tag))
        return self.cache[key]


def at(m, t):
    col = m[:, t]
    return [float(v) for v in col if np.isfinite(v)]


def summary(values):
    if not values:
        return dict(mean=None, sd=None, cv=None, median=None, lo=None, hi=None, n=0)
    mean = statistics.mean(values)
    sd = statistics.stdev(values) if len(values) > 1 else 0.0
    # cv is meaningless for a quantity that takes both signs (a net balance).
    cv = (sd / abs(mean)) if mean and not (min(values) < 0 < max(values)) else None
    return dict(mean=mean, sd=sd, cv=cv, median=statistics.median(values),
                lo=min(values), hi=max(values), n=len(values))


# --- plotting -------------------------------------------------------------------
def years(T):
    return 1836 + np.arange(T) / 4


def style_time_axis(ax, T):
    ax.set_xlim(1836, 1836 + (T - 1) / 4)
    ax.xaxis.set_major_locator(MaxNLocator(6, integer=True))


def fan(ax, ensembles, getter, title, kind="num", members=None):
    """p10-p90 band, faint member lines (single ensemble only), bold median."""
    members = len(ensembles) == 1 if members is None else members
    for ens in ensembles:
        m = getter(ens)
        x = years(m.shape[1])
        with np.errstate(all="ignore"):
            lo, med, hi = (np.nanpercentile(m, p, axis=0) for p in (10, 50, 90))
        ax.fill_between(x, lo, hi, color=ens.color, alpha=0.16, linewidth=0)
        if members:
            for row in m:
                ax.plot(x, row, color=ens.color, alpha=0.28, linewidth=0.6)
        ax.plot(x, med, color=ens.color, linewidth=1.8, label=ens.label)
        style_time_axis(ax, m.shape[1])
    ax.set_title(title)
    ax.yaxis.set_major_locator(MaxNLocator(5))
    if kind == "pct":
        span = abs(ax.get_ylim()[1] - ax.get_ylim()[0])
        digits = 0 if span >= 0.05 else 1 if span >= 0.005 else 2
        ax.yaxis.set_major_formatter(FuncFormatter(lambda v, _: f"{v * 100:.{digits}f}%"))
    else:
        ax.yaxis.set_major_formatter(axis_fmt(kind))


def grid_figure(n, ncols, w=10.0, h=2.3):
    nrows = math.ceil(n / ncols)
    fig, axes = plt.subplots(nrows, ncols, figsize=(w, h * nrows), squeeze=False)
    for ax in axes.flat[n:]:
        ax.set_visible(False)
    return fig, list(axes.flat[:n])


def legend_for(fig, ensembles, members_shown):
    handles = [plt.Line2D([], [], color=e.color, linewidth=1.8) for e in ensembles]
    labels = [f"{e.label}: median" for e in ensembles]
    band = ensembles[0].color if len(ensembles) == 1 else MUTED
    handles += [plt.Rectangle((0, 0), 1, 1, color=band, alpha=0.16 if len(ensembles) == 1 else 0.3, linewidth=0)]
    labels += ["10th–90th percentile of members" + (" (each arm)" if len(ensembles) > 1 else "")]
    if members_shown:
        handles += [plt.Line2D([], [], color=ensembles[0].color, alpha=0.4, linewidth=0.6)]
        labels += ["one member (run)"]
    fig.legend(handles, labels, loc="upper left", ncol=len(labels), bbox_to_anchor=(0.01, 1.0))


PNG_DIR = None  # set by --png: also write PNG copies there


def save(fig, out, name, top=0.9):
    fig.tight_layout(rect=(0, 0, 1, top))
    path = out / "figures" / f"{name}.svg"
    fig.savefig(path, format="svg", metadata={"Date": None})
    if PNG_DIR:
        fig.savefig(PNG_DIR / f"{name}.png", format="png", dpi=110)
    plt.close(fig)
    return f"figures/{name}.svg"


def fan_grid(out, name, ensembles, specs, ncols=3, h=2.3):
    fig, axes = grid_figure(len(specs), ncols, h=h)
    for ax, (title, getter, kind) in zip(axes, specs):
        fan(ax, ensembles, getter, title, kind)
    legend_for(fig, ensembles, len(ensembles) == 1)
    return save(fig, out, name, top=1 - 0.32 / (h * math.ceil(len(specs) / ncols)))


# --- report -----------------------------------------------------------------------
class Report:
    def __init__(self, db, ensembles, out):
        self.db, self.E, self.out = db, ensembles, out
        self.A = ensembles[0]
        self.B = ensembles[1] if len(ensembles) > 1 else None
        self.md = []
        self.wave = []
        self.findings = []
        (out / "figures").mkdir(parents=True, exist_ok=True)

    def w(self, *lines):
        self.md.extend(lines)

    def fig(self, path, alt, caption=None):
        self.w(f"![{alt}]({path})", "")
        if caption:
            self.w(f"*{caption}*", "")

    # metric rows used by several tables: (label, getter, kind)
    def world_metric(self, key):
        return lambda e: e.world(key)

    def stat_rows(self, specs, t_end):
        """Rows for a world-metric table at t=0 and t_end, with comparison columns."""
        rows = []
        for label, getter, kind in specs:
            a0, a1 = summary(at(getter(self.A), 0)), summary(at(getter(self.A), t_end))
            growth = (a1["mean"] / a0["mean"] - 1) if a0["mean"] and a1["mean"] is not None else None
            show = (lambda v: pct(v)) if kind == "pct" else fmt
            row = [label, show(a0["mean"]), show(a1["mean"]), pct(growth, sign=True) if kind != "pct" else "–",
                   show(a1["sd"]), pct(a1["cv"])]
            if not self.B:
                row.append(pct(mde(a1["cv"], self.A.n, self.A.n)) if a1["cv"] is not None else "–")
            else:
                b = at(getter(self.B), t_end)
                b1 = summary(b)
                diff = (b1["mean"] / a1["mean"] - 1) if a1["mean"] else None
                p = welch(at(getter(self.A), t_end), b)
                # MDE from the pooled spread of both arms, each at its own size.
                limit = None
                if a1["sd"] is not None and b1["sd"] is not None and len(b) > 1:
                    limit = mde(math.sqrt((a1["sd"] ** 2 + b1["sd"] ** 2) / 2), a1["n"], b1["n"])
                beyond = limit is not None and abs(b1["mean"] - a1["mean"]) >= limit
                row += [pct(limit / abs(a1["mean"])) if limit is not None and a1["mean"] else "–",
                        show(b1["mean"]), pct(diff, sign=True), f"{p:.3f}" if p is not None else "–", "yes" if beyond else "no"]
            rows.append(row)
        headers = ["metric", f"{self.year(0)}", f"{self.year(t_end)} mean", "growth", "sd", "cv",
                   f"MDE (n={self.A.n} vs {self.A.n})"]
        if self.B:
            headers = ["metric", f"{self.year(0)}", f"A {self.year(t_end)}", "A growth", "A sd", "A cv",
                       f"MDE ({self.A.n} vs {self.B.n})", f"B {self.year(t_end)}", "B vs A", "p (Welch)", "beyond MDE"]
        return table(headers, rows)

    def year(self, t):
        return f"{1836 + t // 4}-{(t % 4) * 3 + 1:02d}"

    # --- sections ------------------------------------------------------------
    def build(self):
        A, T = self.A, self.A.T
        self.t_end = T - 1
        self.section_setup()
        self.section_world()
        self.section_noise()
        self.section_powers()
        self.section_geopolitics()
        self.section_infrastructure()
        self.section_markets()
        self.section_construction()
        self.section_fiscal()
        self.section_cheatsheet()
        self.section_appendix()
        title = f"Ensemble report: {A.name}" + (f" vs {self.B.name}" if self.B else "")
        head = [f"# {title}", "",
                f"Generated {dt.date.today().isoformat()} by `tools/ensembles/Make-EnsembleReport.py` from "
                f"`tools/ensembles/ensembles.sqlite`. {A.n} members"
                + (f" (A) vs {self.B.n} (B)" if self.B else "")
                + f", {A.first_date} to {A.last_date}, quarterly; game {A.version}.", "",
                "Charts: line = median of members, band = 10th–90th percentile, faint lines = individual members. "
                "cv = sd / mean across members. MDE = minimum detectable effect: the smallest true difference "
                "a two-sided test (α = 0.05) catches with 80% power when comparing two ensembles of this size; "
                "shown as % of the mean.", "",
                "## Key findings", ""] + [f"- {f}" for f in self.findings] + [""]
        toc = ["Contents: " + " · ".join(f"[{s}](#{s.lower().replace(' ', '-').replace('&', '').replace('--', '-')})" for s in (
            "Setup", "World", "Noise and power", "Great powers", "Geopolitics", "Infrastructure", "Markets",
            "Construction and urbanization", "Fiscal", "BOI cheat-sheet", "Appendix")), ""]
        (self.out / "REPORT.md").write_text("\n".join(head + toc + self.md) + "\n", encoding="utf-8")

    def section_setup(self):
        self.w("## Setup", "")
        for e in self.E:
            info = [json_load(r[5]) for r in e.runs]
            dlc = info[0].get("installed_dlc") or []
            disabled = info[0].get("disabled_dlc") or []
            mods = info[0].get("mods") or []
            minutes = [r[3] for r in e.runs if r[3]]
            dropped = sum(e.T - r[4] for r in e.runs)
            self.w(f"**{e.label}: `{e.name}`** ({e.arm}). {e.description}", "",
                   table(["item", "value"], [
                       ["members", e.n],
                       ["snapshots per member", f"{min(r[4] for r in e.runs)}–{max(r[4] for r in e.runs)} of {e.T}"
                        + (f" ({dropped} dropped as incomplete)" if dropped else " (none dropped)")],
                       ["minutes per member", f"{min(minutes):.1f}–{max(minutes):.1f} (total {sum(minutes) / 60:.1f} h)"],
                       ["game version", e.version],
                       ["DLC installed / disabled", f"{len(dlc)} / {len(disabled)}"],
                       ["mods", ", ".join(f"{pathlib.Path(m['path']).name} @ {str(m.get('commit'))[:8]}"
                                          + (" (dirty)" if m.get("dirty") else "") for m in mods) or "none (telemetry only)"],
                       ["telemetry modules", ", ".join(info[0].get("telemetry_modules") or [])],
                   ]), "")
        self.w("Countries are keyed by engine id; civil-war revolutionaries share their parent's tag, so the "
               "second country under a tag in a member is labelled `TAG#2` (see `run_country`).", "")

    def section_world(self):
        A, t = self.A, self.t_end
        specs = [("GDP (world)", self.world_metric("gdp"), "num"),
                 ("Population", self.world_metric("population"), "num"),
                 ("Standard of living (pop-weighted)", self.world_metric("sol"), "num"),
                 ("Literacy (pop-weighted)", self.world_metric("literacy"), "pct"),
                 ("Unemployed working adults", self.world_metric("unemployed"), "num"),
                 ("Urbanization (points)", self.world_metric("urbanization"), "num")]
        self.w("## World", "")
        self.fig(fan_grid(self.out, "world", self.E, specs), "World trajectories")
        self.w(self.stat_rows(specs + [
            ("Countries alive", self.world_metric("countries"), "num"),
            ("Wage (pop-weighted, /yr)", self.world_metric("wage"), "num"),
            ("Radicals", self.world_metric("radicals"), "num"),
            ("Loyalists", self.world_metric("loyalists"), "num"),
            ("State turmoil (pop-weighted)", self.world_metric("turmoil"), "pct"),
        ], t), "")
        g0, g1 = summary(at(A.world("gdp"), 0)), summary(at(A.world("gdp"), t))
        s0, s1 = summary(at(A.world("sol"), 0)), summary(at(A.world("sol"), t))
        u0, u1 = summary(at(A.world("unemployed"), 0)), summary(at(A.world("unemployed"), t))
        self.findings.append(
            f"World GDP grows {pct(g1['mean'] / g0['mean'] - 1, sign=True)} over {t / 4:.0f} years "
            f"(member spread {pct(g1['cv'])} cv), but pop-weighted SoL falls {fmt(s0['mean'])} → {fmt(s1['mean'])} "
            f"and unemployment goes ×{u1['mean'] / u0['mean']:.1f} ({fmt(u0['mean'])} → {fmt(u1['mean'])})"
            + (": the decade gets richer in total and poorer per head." if s1["mean"] < s0["mean"] else "."))
        self.w(self.sol_weight_note(), "")
        mid = summary(at(A.world("gdp"), t // 2))["mean"]
        first, second = mid / g0["mean"] - 1, g1["mean"] / mid - 1
        self.w(f"GDP rises {pct(first, sign=True)} in the first half and {pct(second, sign=True)} in the second"
               + (" (front-loaded). " if first > 1.5 * second else ". ") +
               f"Population is nearly deterministic (cv {pct(summary(at(A.world('population'), t))['cv'])}); welfare measures "
               f"(SoL, unemployment, wage) carry 2–5% noise.", "")

    def sol_weight_note(self):
        """World SoL is pop-weighted, so the most populous country dominates it; find the largest one-quarter
        jump of any member and attribute it."""
        A = self.A
        big = A.q("""SELECT c.tag, AVG(o.population * 1.0 / w.value) FROM country_obs o JOIN run r USING (run_id)
                     JOIN country c USING (country_id) JOIN world_obs w ON w.run_id = o.run_id AND w.t = o.t AND w.metric = 'population'
                     WHERE r.ensemble_id = ? GROUP BY c.tag ORDER BY 2 DESC LIMIT 1""", A.id)[0]
        sol = A.world("sol")
        jumps = np.abs(np.diff(sol, axis=1))
        i, t = np.unravel_index(np.nanargmax(jumps), jumps.shape)
        mem = A.members[i]
        rows = A.q("""SELECT c.tag, o.t, o.sol, o.population FROM country_obs o JOIN run r USING (run_id) JOIN country c USING (country_id)
                      WHERE r.ensemble_id = ? AND r.member = ? AND o.t IN (?, ?)""", A.id, mem, int(t), int(t) + 1)
        before = {tag: (s, p) for tag, tt, s, p in rows if tt == t}
        after = {tag: (s, p) for tag, tt, s, p in rows if tt == t + 1}
        culprit = max((tag for tag in before if tag in after),
                      key=lambda tag: abs((after[tag][0] or 0) * (after[tag][1] or 0) - (before[tag][0] or 0) * (before[tag][1] or 0)))
        return (f"{big[0]} averages {pct(big[1], 0)} of world population, so pop-weighted world SoL largely tracks it. "
                f"The biggest one-quarter jump in any member (member {mem}, {self.year(int(t))} → {self.year(int(t) + 1)}: "
                f"{sol[i, t]:.2f} → {sol[i, t + 1]:.2f}) is {culprit}'s SoL going {before[culprit][0]:.2f} → {after[culprit][0]:.2f}. "
                f"Compare SoL per country, or the powers' SoL panels, when testing welfare effects.")

    def section_noise(self):
        A, t = self.A, self.t_end
        self.w("## Noise and power", "")
        cv_specs = [("GDP", "gdp"), ("SoL", "sol"), ("Unemployed", "unemployed"), ("Railway levels", "railway_levels"),
                    ("Construction levels", "construction_levels"), ("Gold reserves", "gold")]
        fig, ax = plt.subplots(figsize=(10, 3.2))
        x = years(A.T)
        for i, (label, key) in enumerate(cv_specs):
            m = A.world(key)
            with np.errstate(all="ignore"):
                cv = np.nanstd(m, axis=0, ddof=1) / np.abs(np.nanmean(m, axis=0))
            ax.plot(x[1:], cv[1:], color=SERIES[i], linewidth=1.8, label=label)
        style_time_axis(ax, A.T)
        ax.yaxis.set_major_formatter(axis_fmt("pct"))
        ax.set_title(f"{A.label}: run-to-run spread (cv) of world metrics over time")
        ax.legend(loc="upper left", ncol=6)
        self.fig(save(fig, self.out, "noise_cv", top=1), "cv over time",
                 "Spread starts at zero (identical start) and grows; most world metrics settle at 1–6% within a few years, "
                 "railways near 10%.")

        mde_specs = [("World GDP", "gdp"), ("Population", "population"), ("SoL", "sol"), ("Literacy", "literacy"),
                     ("Unemployed", "unemployed"), ("Wage", "wage"), ("Infrastructure supply", "infrastructure"),
                     ("Infrastructure usage", "infrastructure_usage"), ("Infra utilization", "utilization"),
                     ("Deficit states", "deficit_states"), ("Railway levels", "railway_levels"), ("Port levels", "port_levels"),
                     ("Construction levels", "construction_levels"), ("Urban center levels", "urban_center_levels"),
                     ("Livestock ranch levels", "livestock_ranch_levels"), ("Gold reserves", "gold"),
                     ("Govt income", "income"), ("Govt expenses", "expenses"), ("Countries in debt", "countries_in_debt"),
                     ("Transportation price (clamped)", "price:transportation"), ("Grain price", "price:grain"),
                     ("Tools price", "price:tools"), ("Radicals", "radicals"), ("Countries at war", "countries_at_war")]
        rows = []
        for label, key in mde_specs:
            s = summary(at(A.world(key), t))
            if s["cv"] is None:
                continue
            rows.append((label, s["cv"], mde(s["cv"], A.n, A.n)))
        rows.sort(key=lambda r: r[2])
        fig, ax = plt.subplots(figsize=(10, 0.24 * len(rows) + 0.9))
        y = np.arange(len(rows))
        # Cap the axis above the second-largest value so one wild metric doesn't flatten the rest.
        cap = sorted(r[2] for r in rows)[-2] * 1.35 if len(rows) > 1 else rows[0][2] * 1.1
        vals = [min(r[2], cap) for r in rows]
        ax.barh(y, vals, height=0.7, color=SERIES[0], edgecolor=SURFACE, linewidth=1)
        ax.set_xlim(0, cap * 1.12)
        ax.xaxis.set_major_locator(MaxNLocator(8, steps=[1, 2, 5, 10]))
        for yi, r in zip(y, rows):
            ax.text(min(r[2], cap) + cap * 0.008, yi, pct(r[2]) + (" (axis cut)" if r[2] > cap else ""), va="center",
                    fontsize=8, color=INK2)
        ax.set_yticks(y, [r[0] for r in rows])
        ax.invert_yaxis()
        ax.grid(axis="x")
        ax.grid(axis="y", visible=False)
        ax.xaxis.set_major_formatter(axis_fmt("pct"))
        ax.set_title(f"Minimum detectable effect at {self.year(t)}, {A.n} vs {A.n} members (α 0.05, power 0.8)")
        self.fig(save(fig, self.out, "noise_mde", top=1), "MDE by metric")
        self.w(table(["metric", "cv", f"MDE n={A.n}", "n for 1%", "n for 2%", "n for 5%", "n for 10%"],
                     [[r[0], pct(r[1]), pct(r[2])] + [str(runs_needed(r[1], e) or ">1000") for e in (0.01, 0.02, 0.05, 0.10)]
                      for r in rows]), "")
        self.w("n = members per arm needed to detect a true change of that size (two-sample, α 0.05, power 0.8), "
               "assuming the mod leaves the spread unchanged.", "")
        by = {r[0]: r[2] for r in rows}
        def span(names):
            vals = [by[n] for n in names if n in by]
            return f"{pct(min(vals), 0)}–{pct(max(vals), 0)}" if vals else "–"
        self.findings.append(
            f"With {A.n} vs {A.n} members the minimum detectable effect is {span(['World GDP', 'SoL', 'Infrastructure usage', 'Urban center levels', 'Livestock ranch levels'])} "
            f"for world GDP, SoL, infrastructure usage, urban centers and ranches; {span(['Unemployed', 'Construction levels', 'Gold reserves'])} "
            f"for unemployment, construction and gold; {span(['Deficit states', 'Railway levels'])} for deficit states and railways. "
            f"Wars are untestable (MDE {pct(by.get('Countries at war', float('nan')), 0)}). Clamped prices (transport) look precise only because they "
            f"can't move.")

        # Regimes: civil-war waves.
        self.w("### Regimes: revolution waves", "")
        splits, gone = self.splits_and_gone(A)
        med = statistics.median(splits.values())
        wave = sorted(m for m, s in splits.items() if s >= max(10, 2.5 * med))
        self.wave = wave
        fig, axes = plt.subplots(1, 2, figsize=(10, 2.6))
        for ax, data, title in ((axes[0], splits, "Civil-war splits (TAG#n countries)"),
                                (axes[1], gone, "Countries gone by the end")):
            ms = sorted(data)
            ax.bar([str(m) for m in ms], [data[m] for m in ms], width=0.72,
                   color=[SERIES[0] if m in wave else QUIET for m in ms], edgecolor=SURFACE, linewidth=1)
            ax.set_title(title)
            ax.set_xlabel("member")
            ax.yaxis.set_major_locator(MaxNLocator(5, integer=True))
        fig.legend([plt.Rectangle((0, 0), 1, 1, color=SERIES[0]), plt.Rectangle((0, 0), 1, 1, color=QUIET)],
                   ["revolution-wave member", "other members"], loc="upper left", ncol=2)
        self.fig(save(fig, self.out, "regimes", top=0.88), "Revolution-wave members")
        if wave:
            firsts = sorted(r[0] for r in A.q(
                "SELECT rc.first_t FROM run_country rc JOIN run r USING (run_id) JOIN country c USING (country_id)"
                " WHERE r.ensemble_id = ? AND c.tag LIKE '%%#%%' AND r.member IN (%s)" % ",".join(map(str, wave)), A.id))
            lo, hi = firsts[len(firsts) // 10], firsts[(9 * len(firsts)) // 10]
            self.w(f"Members {', '.join(map(str, wave))} each produced {min(splits[m] for m in wave)}+ civil-war countries "
                   f"(median member: {med:.0f}). 80% of their splits start between {self.year(lo)} and {self.year(hi)} "
                   f"(see Geopolitics for which tags). How the wave shifts world metrics at {self.year(t)}:", "")
            rows = []
            for label, key in (("World GDP", "gdp"), ("SoL", "sol"), ("Unemployed", "unemployed"), ("Countries alive", "countries"),
                               ("Railway levels", "railway_levels"), ("Construction levels", "construction_levels"),
                               ("Infrastructure usage", "infrastructure_usage"), ("Gold", "gold"), ("Radicals", "radicals")):
                m = A.world(key)[:, t]
                w_vals = [m[i] for i, mem in enumerate(A.members) if mem in wave and np.isfinite(m[i])]
                o_vals = [m[i] for i, mem in enumerate(A.members) if mem not in wave and np.isfinite(m[i])]
                if w_vals and o_vals:
                    rows.append([label, fmt(statistics.mean(o_vals)), fmt(statistics.mean(w_vals)),
                                 pct(statistics.mean(w_vals) / statistics.mean(o_vals) - 1, sign=True)])
            self.w(table(["metric", "other members", "wave members", "wave vs other"], rows), "")
            shifts = {r[0]: abs(float(r[3].rstrip("%")) / 100) for r in rows if r[3] != "–"}
            econ = max(v for k, v in shifts.items() if k in ("World GDP", "SoL", "Unemployed", "Infrastructure usage", "Construction levels"))
            other = [v for k, v in shifts.items() if k in ("Countries alive", "Radicals", "Gold")]
            gone_w = statistics.mean(gone[m] for m in wave)
            gone_o = statistics.mean(gone[m] for m in A.members if m not in wave)
            self.findings.append(
                f"{len(wave)}/{A.n} members (#{', #'.join(map(str, wave))}) hit a European revolution wave "
                f"({', '.join(str(splits[m]) for m in wave)} civil-war splits vs a median of {med:.0f}; "
                f"{gone_w:.0f} vs {gone_o:.0f} countries gone). It shifts economic world totals by at most {pct(econ)}, but "
                f"country counts, radicals and gold by {pct(min(other), 0)}–{pct(max(other), 0)}: a mod that changes the odds of a wave moves those through "
                f"that alone.")

    def splits_and_gone(self, e):
        splits = dict(e.q("SELECT r.member, COUNT(*) FROM run_country rc JOIN run r USING (run_id) JOIN country c USING (country_id)"
                          " WHERE r.ensemble_id = ? AND c.tag LIKE '%#%' GROUP BY r.member", e.id))
        gone = dict(e.q("""SELECT r.member, COUNT(*) FROM run r JOIN country_obs o0 ON o0.run_id = r.run_id AND o0.t = 0
                           WHERE r.ensemble_id = ? AND NOT EXISTS (SELECT 1 FROM country_obs o WHERE o.run_id = r.run_id
                           AND o.t = ? AND o.country_id = o0.country_id) GROUP BY r.member""", e.id, e.T - 1))
        return {m: splits.get(m, 0) for m in e.members}, {m: gone.get(m, 0) for m in e.members}

    def powers(self):
        rows = self.A.q("SELECT DISTINCT c.tag FROM country_stats s JOIN country c USING (country_id) WHERE s.ensemble_id = ?", self.A.id)
        tags = [r[0] for r in rows]
        t = self.t_end
        return sorted(tags, key=lambda tag: -(summary(at(self.A.country(tag, "gdp"), t))["median"] or 0))

    def section_powers(self):
        A, t = self.A, self.t_end
        tags = self.powers()
        self.w("## Great powers", "",
               f"The {len(tags)} countries at rank ≥ 5 (great, major, unrecognized major) at the start, ordered by median GDP "
               f"at {self.year(t)}. Independent y-axes.", "")
        fig, axes = grid_figure(len(tags), 4, h=1.9)
        for ax, tag in zip(axes, tags):
            fan(ax, self.E, lambda e, tag=tag: e.country(tag, "gdp"), f"{tag} GDP")
        legend_for(fig, self.E, len(self.E) == 1)
        self.fig(save(fig, self.out, "powers_gdp", top=1 - 0.32 / (1.9 * math.ceil(len(tags) / 4))), "GDP by power")

        fig, axes = grid_figure(len(tags), 4, h=1.9)
        for ax, tag in zip(axes, tags):
            fan(ax, self.E, lambda e, tag=tag: e.country(tag, "sol"), f"{tag} SoL")
        legend_for(fig, self.E, len(self.E) == 1)
        self.fig(save(fig, self.out, "powers_sol", top=1 - 0.32 / (1.9 * math.ceil(len(tags) / 4))), "SoL by power")

        # GDP rank among these powers at the end.
        counts = np.zeros((len(tags), len(tags)))
        for mem in A.members:
            vals = []
            for i, tag in enumerate(tags):
                v = A.country(tag, "gdp")[A.members.index(mem), t]
                vals.append((v if np.isfinite(v) else -1, i))
            for rank, (_, i) in enumerate(sorted(vals, reverse=True)):
                counts[i, rank] += 1
        fig, ax = plt.subplots(figsize=(10, 0.28 * len(tags) + 1.0))
        cmap = matplotlib.colors.ListedColormap([SURFACE] + RAMP)
        norm = matplotlib.colors.BoundaryNorm(np.arange(-0.5, len(RAMP) + 1.5) * (A.n / len(RAMP)), cmap.N)
        ax.imshow(counts, cmap=cmap, norm=norm, aspect="auto")
        for i in range(len(tags)):
            for j in range(len(tags)):
                if counts[i, j]:
                    ax.text(j, i, int(counts[i, j]), ha="center", va="center", fontsize=7.5,
                            color="#ffffff" if counts[i, j] > A.n * 0.45 else INK)
        ax.set_xticks(range(len(tags)), [str(i + 1) for i in range(len(tags))])
        ax.set_yticks(range(len(tags)), tags)
        ax.grid(False)
        ax.spines[["left", "bottom"]].set_visible(False)
        ax.set_xlabel(f"GDP rank among these {len(tags)} at {self.year(t)}")
        ax.set_title(f"{A.label}: members (of {A.n}) placing each power at each GDP rank")
        self.fig(save(fig, self.out, "powers_rank", top=1), "GDP rank distribution")

        rows = []
        for tag in tags:
            g0, g1 = summary(at(A.country(tag, "gdp"), 0)), summary(at(A.country(tag, "gdp"), t))
            sol = summary(at(A.country(tag, "sol"), t))
            rail = summary(at(A.country(tag, "railway_levels"), t))
            techs = summary(at(A.country(tag, "techs"), t))
            war = np.nanmean(A.country(tag, "at_war"))
            rank = A.country(tag, "rank")[:, t]
            gp = sum(1 for v in rank if np.isfinite(v) and v >= 7)
            row = [tag, fmt(g1["median"]), pct(g1["median"] / g0["median"] - 1, sign=True) if g0["median"] else "–",
                   pct(g1["cv"]), fmt(sol["median"]), fmt(rail["median"]), fmt(techs["median"]),
                   pct(war, 0) if np.isfinite(war) else "–", f"{gp}/{A.n}"]
            if self.B:
                b = at(self.B.country(tag, "gdp"), t)
                row += [fmt(summary(b)["median"]), pct(summary(b)["mean"] / g1["mean"] - 1, sign=True) if b and g1["mean"] else "–",
                        f"{welch(at(A.country(tag, 'gdp'), t), b):.3f}" if b else "–"]
            rows.append(row)
        headers = ["power", "GDP (median)", "growth", "GDP cv", "SoL", "railways", "techs", "time at war", "great power at end"]
        if self.B:
            headers += ["B GDP", "B vs A", "p"]
        self.w(table(headers, rows), "")
        volatile = sorted(tags, key=lambda tag: -(summary(at(A.country(tag, "gdp"), t))["cv"] or 0))[:4]
        stable = sorted(tags, key=lambda tag: summary(at(A.country(tag, "gdp"), t))["cv"] or 9)[:4]
        self.findings.append(
            f"Power trajectories differ a lot in predictability: GDP cv at the end is lowest for {', '.join(stable)} "
            f"and highest for {', '.join(volatile)}. {self.top_stability(tags)}")

    def top_stability(self, tags):
        A, t = self.A, self.t_end
        orders = collections.Counter()
        for i, mem in enumerate(A.members):
            vals = sorted(((A.country(tag, "gdp")[i, t], tag) for tag in tags
                           if np.isfinite(A.country(tag, "gdp")[i, t])), reverse=True)
            orders[tuple(tag for _, tag in vals[:5])] += 1
        top, n = orders.most_common(1)[0]
        sets = collections.Counter(frozenset(o) for o in orders.elements())
        same_set = sets.most_common(1)[0][1]
        return (f"The GDP top five is the same set of countries in {same_set}/{A.n} members, and in exactly the order "
                f"{' > '.join(top)} in {n}/{A.n}.")

    def section_geopolitics(self):
        A, t = self.A, self.t_end
        self.w("## Geopolitics", "")
        self.fig(fan_grid(self.out, "conflict", self.E, [
            ("Countries at war", self.world_metric("countries_at_war"), "num"),
            ("Countries alive", self.world_metric("countries"), "num"),
            ("Subjects", self.world_metric("subjects"), "num"),
            ("Radicals", self.world_metric("radicals"), "num"),
            ("Loyalists", self.world_metric("loyalists"), "num"),
            ("State turmoil (pop-weighted)", self.world_metric("turmoil"), "pct")]), "Conflict and politics")
        war = A.world("countries_at_war")
        self.w(f"Countries at war swings between {int(np.nanmin(war[:, 1:]))} and {int(np.nanmax(war))} at any snapshot; "
               f"the quarter-to-quarter series is dominated by individual wars, so treat it as a regime indicator, not a metric.", "")

        gone = A.q("""SELECT c.tag, COUNT(*) FROM run r JOIN country_obs o0 ON o0.run_id = r.run_id AND o0.t = 0
                      JOIN country c ON c.country_id = o0.country_id
                      WHERE r.ensemble_id = ? AND NOT EXISTS (SELECT 1 FROM country_obs o WHERE o.run_id = r.run_id
                      AND o.t = ? AND o.country_id = o0.country_id) GROUP BY c.tag ORDER BY 2 DESC, 1""", A.id, t)
        always = [tag for tag, n in gone if n == A.n]
        often = [f"{tag} ({n})" for tag, n in gone if A.n / 2 <= n < A.n]
        formed = A.q("""SELECT c.tag, COUNT(DISTINCT r.run_id) FROM run_country rc JOIN run r USING (run_id) JOIN country c USING (country_id)
                        WHERE r.ensemble_id = ? AND rc.first_t > 0 AND c.tag NOT LIKE '%#%'
                        AND EXISTS (SELECT 1 FROM country_obs o WHERE o.run_id = rc.run_id AND o.country_id = rc.country_id)
                        GROUP BY c.tag ORDER BY 2 DESC, 1""", A.id)
        split_tags = A.q("""SELECT substr(c.tag, 1, instr(c.tag, '#') - 1) AS base, COUNT(DISTINCT r.run_id), MIN(rc.first_t)
                            FROM run_country rc JOIN run r USING (run_id) JOIN country c USING (country_id)
                            WHERE r.ensemble_id = ? AND c.tag LIKE '%#%' GROUP BY base ORDER BY 2 DESC, 1""", A.id)
        self.w(table(["event", "countries (members out of " + str(A.n) + ")"], [
            ["annexed/gone in every member", ", ".join(always) or "–"],
            ["gone in at least half", ", ".join(often) or "–"],
            ["formed (new tag) during the run", ", ".join(f"{tag} ({n})" for tag, n in formed) or "–"],
            ["civil-war split (TAG#n)", ", ".join(f"{tag} ({n})" for tag, n, _ in split_tags) or "–"],
        ]), "")
        background = [tag for tag, n, _ in split_tags if n >= 0.8 * A.n]
        wave_only = [tag for tag, n, _ in split_tags if n < 0.8 * A.n and self.wave and
                     not A.q("""SELECT 1 FROM run_country rc JOIN run r USING (run_id) JOIN country c USING (country_id)
                                WHERE r.ensemble_id = ? AND c.tag LIKE ? AND r.member NOT IN (%s) LIMIT 1"""
                             % ",".join(map(str, self.wave)), A.id, tag + "#%")]
        self.w(f"Civil wars that happen in at least 80% of members are background: {', '.join(background) or 'none'}. "
               + (f"Splits seen only in revolution-wave members: {', '.join(wave_only)}." if wave_only else ""), "")

    def section_infrastructure(self):
        A, t = self.A, self.t_end
        self.w("## Infrastructure", "")
        self.fig(fan_grid(self.out, "infrastructure", self.E, [
            ("Infrastructure supply (world)", self.world_metric("infrastructure"), "num"),
            ("Infrastructure usage (world)", self.world_metric("infrastructure_usage"), "num"),
            ("Utilization (usage / supply)", self.world_metric("utilization"), "pct"),
            ("States with usage > supply", self.world_metric("deficit_states"), "num"),
            ("Railway levels (world)", self.world_metric("railway_levels"), "num"),
            ("Port levels (world)", self.world_metric("port_levels"), "num")]), "Infrastructure")
        u0, u1 = summary(at(A.world("utilization"), 0)), summary(at(A.world("utilization"), t))
        d0, d1 = summary(at(A.world("deficit_states"), 0)), summary(at(A.world("deficit_states"), t))
        r0, r1 = summary(at(A.world("railway_levels"), 0)), summary(at(A.world("railway_levels"), t))
        self.findings.append(
            f"Infrastructure is slack in aggregate (world utilization {pct(u0['mean'], 0)} → {pct(u1['mean'], 0)}) "
            f"but shortages spread: states with usage > supply go {fmt(d0['mean'])} → {fmt(d1['mean'])} "
            f"(cv {pct(d1['cv'])}). Railways grow {fmt(r0['mean'])} → {fmt(r1['mean'])} levels with ~{pct(r1['cv'], 0)} spread, "
            f"the noisiest infrastructure metric.")

        # State level at the end, matched by region + owner label.
        states = A.q("""SELECT sr.name, c.tag, r.member, o.infrastructure, o.infrastructure_usage, o.population, o.market_access
                        FROM state_obs o JOIN run r USING (run_id) JOIN country c ON c.country_id = o.owner_id
                        JOIN state_region sr ON sr.region_id = o.region_id WHERE r.ensemble_id = ? AND o.t = ?""", A.id, t)
        by = collections.defaultdict(list)
        for name, tag, mem, infra, usage, pop, access in states:
            by[(name, tag)].append((infra or 0, usage or 0, pop or 0, access))
        rows = []
        for (name, tag), obs in by.items():
            short = sum(1 for i, u, _, _ in obs if u > i)
            rows.append(dict(name=name, tag=tag, n=len(obs), short=short,
                             infra=statistics.median(o[0] for o in obs), usage=statistics.median(o[1] for o in obs),
                             pop=statistics.median(o[2] for o in obs)))
        chronic = sorted((r for r in rows if r["short"] >= A.n / 2), key=lambda r: (-r["short"], -(r["usage"] - r["infra"])))
        fig, ax = plt.subplots(figsize=(10, 4.2))
        xs = np.array([max(r["infra"], 0.5) for r in rows])
        ys = np.array([max(r["usage"], 0.5) for r in rows])
        hot = np.array([r["short"] >= A.n / 2 for r in rows])
        ax.scatter(xs[~hot], ys[~hot], s=10, color=QUIET, alpha=0.7, linewidths=0, label="other states")
        ax.scatter(xs[hot], ys[hot], s=18, color=SERIES[1], edgecolors=SURFACE, linewidths=0.8,
                   label=f"short of infrastructure in ≥ {A.n // 2} members")
        lim = (0.5, max(xs.max(), ys.max()) * 1.3)
        ax.plot(lim, lim, color=AXIS, linewidth=0.8)
        ax.text(lim[1] / 1.4, lim[1] / 1.25, "usage = supply", color=MUTED, fontsize=8, ha="right")
        ax.set_xscale("log")
        ax.set_yscale("log")
        ax.set_xlim(lim)
        ax.set_ylim(lim)
        ax.grid(axis="both")
        ax.set_xlabel("infrastructure supply (median across members, log)")
        ax.set_ylabel("usage (log)")
        ax.xaxis.set_major_formatter(axis_fmt())
        ax.yaxis.set_major_formatter(axis_fmt())
        ax.legend(loc="upper left")
        ax.set_title(f"{A.label}: every state at {self.year(t)}, supply vs usage")
        self.fig(save(fig, self.out, "states_scatter", top=1), "State infrastructure scatter",
                 "States with zero usage sit on the bottom edge (log scale).")

        # Utilization distribution, start vs end.
        def utils(tt):
            return [u / i for _, _, _, i, u, _, _ in A.q(
                """SELECT sr.name, c.tag, r.member, o.infrastructure, o.infrastructure_usage, o.population, 0
                   FROM state_obs o JOIN run r USING (run_id) JOIN country c ON c.country_id = o.owner_id
                   JOIN state_region sr ON sr.region_id = o.region_id WHERE r.ensemble_id = ? AND o.t = ?""", A.id, tt)
                    if i and i > 0 and u is not None]
        fig, ax = plt.subplots(figsize=(10, 2.8))
        bins = np.linspace(0, 1.6, 33)
        for tt, color, label in ((0, SERIES[0], self.year(0)), (t, SERIES[1], self.year(t))):
            vals = np.clip(utils(tt), 0, 1.6)
            ax.hist(vals, bins=bins, histtype="step", linewidth=1.8, color=color, label=label,
                    weights=np.full(len(vals), 1 / len(vals)))
        ax.axvline(1, color=AXIS, linewidth=0.8)
        ax.text(1.01, ax.get_ylim()[1] * 0.9, "usage = supply", color=MUTED, fontsize=8)
        ax.xaxis.set_major_formatter(axis_fmt("pct"))
        ax.yaxis.set_major_formatter(axis_fmt("pct"))
        ax.set_xlabel("state utilization (usage / supply), all members pooled; > 160% clipped")
        ax.set_title(f"{A.label}: distribution of state utilization, start vs end (share of states)")
        ax.legend(loc="upper right")
        self.fig(save(fig, self.out, "states_utilization", top=1), "State utilization distribution")

        self.w(f"States short of infrastructure in at least half the members at {self.year(t)} "
               f"({len(chronic)} states; median values across members):", "")
        self.w(table(["state", "owner", "short in", "supply", "usage", "shortfall", "population"],
                     [[r["name"], r["tag"], f"{r['short']}/{r['n']}", fmt(r["infra"]), fmt(r["usage"]),
                       fmt(r["usage"] - r["infra"]), fmt(r["pop"])] for r in chronic[:25]]), "")
        access = summary(at(A.world("market_access"), t))
        self.w(f"Market access is uninformative in vanilla: pop-weighted world market access stays at "
               f"{pct(access['mean'], 1)} (cv {pct(access['cv'], 2)}). Deficits in vanilla don't yet cut states off; "
               f"BOI changing that would show up here immediately.", "")

        tags = self.powers()
        fig, ax = plt.subplots(figsize=(10, 3.0))
        for i, tag in enumerate(tags):
            vals = at(A.country(tag, "railway_levels"), t)
            jitter = (np.arange(len(vals)) - len(vals) / 2) * 0.03
            ax.scatter(np.full(len(vals), i) + jitter, vals, s=14, color=SERIES[0], alpha=0.75, linewidths=0)
            if vals:
                ax.plot([i - 0.3, i + 0.3], [statistics.median(vals)] * 2, color=INK, linewidth=1.4)
        ax.set_xticks(range(len(tags)), tags)
        ax.grid(axis="x", visible=False)
        ax.set_title(f"{A.label}: railway levels per power at {self.year(t)} (dot = member, bar = median)")
        self.fig(save(fig, self.out, "railways_powers", top=1), "Railways per power")

    def section_markets(self):
        A, t = self.A, self.t_end
        self.w("## Markets", "",
               "World prices are demand-weighted averages over markets (`world_goods`). Index = price / base price; "
               f"the engine clamps market prices to base × (1 ± {self.price_range()}), i.e. index 0.25–1.75.", "")
        goods = [g for g, base in A.q("SELECT name, base_price FROM goods WHERE base_price IS NOT NULL ORDER BY name")]
        changes = []
        for g in goods:
            p0, p1 = summary(at(A.world(f"price:{g}"), 0)), summary(at(A.world(f"price:{g}"), t))
            b1 = summary(at(A.world(f"buy:{g}"), t))
            if p0["mean"] and p1["mean"] and b1["mean"] and b1["mean"] > 50:
                changes.append((g, p1["mean"] / p0["mean"] - 1, p0, p1, b1))
        changes.sort(key=lambda r: r[1])
        fig, ax = plt.subplots(figsize=(10, 0.2 * len(changes) + 0.9))
        y = np.arange(len(changes))
        ax.barh(y, [c[1] for c in changes], height=0.72, color=[UP if c[1] > 0 else DOWN for c in changes],
                edgecolor=SURFACE, linewidth=1)
        ax.axvline(0, color=AXIS, linewidth=0.8)
        ax.set_yticks(y, [c[0] for c in changes])
        ax.grid(axis="x")
        ax.grid(axis="y", visible=False)
        ax.xaxis.set_major_formatter(axis_fmt("pct"))
        ax.set_title(f"{A.label}: change in world price {self.year(0)} → {self.year(t)} (mean of members)")
        self.fig(save(fig, self.out, "price_change", top=1), "Price change by goods",
                 "Red = dearer, blue = cheaper. Goods with negligible world demand are omitted.")
        ups = [c[0] for c in changes[::-1][:5]]
        downs = [c[0] for c in changes[:4]]
        self.findings.append(
            f"Industrialisation squeezes inputs: the biggest world price rises are {', '.join(f'{g} {pct(dict((c[0], c[1]) for c in changes)[g], 0, True)}' for g in ups)}; "
            f"plantation goods glut ({', '.join(f'{g} {pct(dict((c[0], c[1]) for c in changes)[g], 0, True)}' for g in downs)}).")

        key_goods = ["transportation", "merchant_marine", "services", "grain", "groceries", "wood",
                     "tools", "iron", "coal", "steel", "engines", "clothes"]
        self.fig(fan_grid(self.out, "price_index", self.E,
                          [(f"{g} (price / base)", (lambda e, g=g: e.world(f"index:{g}")), "num") for g in key_goods],
                          ncols=4, h=2.0), "Price index by goods")

        cap_goods = ["transportation", "merchant_marine", "services", "groceries", "tools", "engines", "wood", "grain"]
        self.fig(fan_grid(self.out, "price_cap", self.E,
                          [(g, (lambda e, g=g: e.world(f"cap:{g}")), "pct") for g in cap_goods],
                          ncols=4, h=2.0), "Share of demand at price ceiling",
                 "Share of each good's world demand in markets whose price is at the ceiling (1.75 × base). "
                 "Independent y-axes.")
        cap1 = summary(at(A.world("cap:transportation"), t))
        cap0 = summary(at(A.world("cap:transportation"), 0))
        cover = [summary(at(A.world("sell:transportation"), tt))["mean"] / summary(at(A.world("buy:transportation"), tt))["mean"]
                 for tt in (0, t)]
        self.findings.append(
            f"Transportation is the standout shortage good for BOI: world supply covers only {pct(cover[0], 0)} of demand "
            f"at the start and {pct(cover[1], 0)} at the end, and {pct(cap0['mean'], 0)} → {pct(cap1['mean'], 0)} of transport "
            f"demand sits in markets pinned at the price ceiling (1.75 × base). The world price can't register the shortage; "
            f"watch orders and the at-ceiling share instead.")
        self.w("A market at the ceiling can't signal a worse shortage through price, so for transport-heavy changes "
               "watch this share and the buy/sell orders, not the world price.", "")

        # Dispersion across markets at the end, pooled over members.
        rng = 1 + self.price_range()
        fig, ax = plt.subplots(figsize=(10, 3.2))
        for i, g in enumerate(key_goods):
            vals = [p / b for p, b in A.q("""SELECT m.price, g.base_price FROM market_obs m JOIN run r USING (run_id)
                                             JOIN goods g USING (goods_id) WHERE r.ensemble_id = ? AND m.t = ? AND g.name = ?
                                             AND m.buy > 1""", A.id, t, g)]
            if not vals:
                continue
            jitter = np.random.default_rng(i).uniform(-0.28, 0.28, len(vals))
            ax.scatter(np.full(len(vals), i) + jitter, vals, s=5, color=SERIES[0], alpha=0.25, linewidths=0)
            ax.plot([i - 0.32, i + 0.32], [statistics.median(vals)] * 2, color=INK, linewidth=1.4)
        for level, label in ((rng, "ceiling"), (1, "base"), (2 - rng, "floor")):
            ax.axhline(level, color=AXIS, linewidth=0.8)
            ax.text(len(key_goods) - 0.45, level, label, color=MUTED, fontsize=8, va="center")
        ax.set_xticks(range(len(key_goods)), key_goods, rotation=20, ha="right")
        ax.grid(axis="x", visible=False)
        ax.set_title(f"{A.label}: price / base in every market at {self.year(t)}, all members pooled (bar = median)")
        self.fig(save(fig, self.out, "price_dispersion", top=1), "Price dispersion across markets")

        rows = []
        for g, change, p0, p1, b1 in sorted(changes, key=lambda c: -c[4]["mean"])[:30]:
            s1 = summary(at(A.world(f"sell:{g}"), t))
            cap = summary(at(A.world(f"cap:{g}"), t))
            rows.append([g, fmt(p0["mean"]), fmt(p1["mean"]), pct(change, sign=True), pct(p1["cv"]), fmt(b1["mean"]),
                         f"{s1['mean'] / b1['mean']:.2f}" if b1["mean"] else "–", pct(cap["mean"], 0)])
        self.w("Top 30 goods by world demand at the end:", "")
        self.w(table(["goods", f"price {self.year(0)}", f"price {self.year(t)}", "change", "price cv", "demand/wk",
                      "supply/demand", "demand at ceiling"], rows), "")

    def price_range(self):
        r = self.A.q("SELECT value FROM meta WHERE key = 'price_range'")
        return float(r[0][0]) if r else 0.75

    def section_construction(self):
        self.w("## Construction and urbanization", "",
               "Vanilla stand-ins for BOI's housing: urban centers, construction capacity, the industry that competes "
               "for it, and ranching (horses come from livestock).", "")
        self.fig(fan_grid(self.out, "construction", self.E, [
            ("Construction sector levels", self.world_metric("construction_levels"), "num"),
            ("Urban center levels", self.world_metric("urban_center_levels"), "num"),
            ("Non-subsistence building levels", self.world_metric("building_levels"), "num"),
            ("Light industry levels", self.world_metric("bg_light_industry_levels"), "num"),
            ("Heavy industry levels", self.world_metric("bg_heavy_industry_levels"), "num"),
            ("Livestock ranch levels", self.world_metric("livestock_ranch_levels"), "num")]), "Construction and urbanization")
        self.w(self.stat_rows([
            ("Construction sector levels", self.world_metric("construction_levels"), "num"),
            ("Urban center levels", self.world_metric("urban_center_levels"), "num"),
            ("Non-subsistence building levels", self.world_metric("building_levels"), "num"),
            ("Light industry levels", self.world_metric("bg_light_industry_levels"), "num"),
            ("Heavy industry levels", self.world_metric("bg_heavy_industry_levels"), "num"),
            ("Livestock ranch levels", self.world_metric("livestock_ranch_levels"), "num"),
            ("Urbanization (points)", self.world_metric("urbanization"), "num"),
        ], self.t_end), "")

    def section_fiscal(self):
        self.w("## Fiscal", "")
        self.fig(fan_grid(self.out, "fiscal", self.E, [
            ("Gold reserves (world)", self.world_metric("gold"), "num"),
            ("Countries in debt", self.world_metric("countries_in_debt"), "num"),
            ("Government income /wk (world)", self.world_metric("income"), "num"),
            ("Government expenses /wk (world)", self.world_metric("expenses"), "num"),
            ("Net income /wk (world)", self.world_metric("net_income"), "num")]), "Fiscal")
        self.w(self.stat_rows([
            ("Gold reserves", self.world_metric("gold"), "num"),
            ("Countries in debt", self.world_metric("countries_in_debt"), "num"),
            ("Income /wk", self.world_metric("income"), "num"),
            ("Expenses /wk", self.world_metric("expenses"), "num"),
            ("Net income /wk", self.world_metric("net_income"), "num"),
        ], self.t_end), "")
        n0 = summary(at(self.A.world("net_income"), 0))
        n1 = summary(at(self.A.world("net_income"), self.t_end))
        self.w(f"World net government income goes {fmt(n0['mean'])} → {fmt(n1['mean'])} per week"
               + (": spending outgrows revenue, which is the headroom BOI's road financing competes for."
                  if n1["mean"] < n0["mean"] else "."), "")

    def section_cheatsheet(self):
        A, t = self.A, self.t_end
        self.w("## BOI cheat-sheet", "",
               f"Values at {self.year(t)}. Compare a BOI ensemble's mean against these; a difference smaller than the "
               f"MDE is indistinguishable from vanilla noise with {A.n} members per arm.", "")
        specs = [("World GDP", "gdp"), ("SoL", "sol"), ("Unemployed", "unemployed"), ("Wage", "wage"),
                 ("Infrastructure supply", "infrastructure"), ("Infrastructure usage", "infrastructure_usage"),
                 ("Utilization", "utilization"), ("Deficit states", "deficit_states"), ("Railway levels", "railway_levels"),
                 ("Port levels", "port_levels"), ("Construction levels", "construction_levels"),
                 ("Urban center levels", "urban_center_levels"), ("Livestock ranch levels", "livestock_ranch_levels"),
                 ("Gold reserves", "gold"), ("Countries in debt", "countries_in_debt"), ("Govt expenses", "expenses"),
                 ("Transportation price", "price:transportation"), ("Transport demand at ceiling", "cap:transportation"),
                 ("Transportation demand", "buy:transportation"), ("Merchant marine price", "price:merchant_marine"),
                 ("Services price", "price:services"), ("Wood price", "price:wood"), ("Grain price", "price:grain"),
                 ("Groceries price", "price:groceries"), ("Tools price", "price:tools")]
        rows = []
        for label, key in specs:
            s = summary(at(A.world(key), t))
            kind = "pct" if key in ("utilization", "cap:transportation") else "num"
            show = (lambda v: pct(v)) if kind == "pct" else fmt
            row = [label, show(s["mean"]), show(s["sd"]), pct(s["cv"]),
                   pct(mde(s["cv"], A.n, A.n)) if s["cv"] else "–",
                   str(runs_needed(s["cv"], 0.02) or ">1000"), str(runs_needed(s["cv"], 0.05) or ">1000")]
            if self.B:
                b = at(self.B.world(key), t)
                bs = summary(b)
                p = welch(at(A.world(key), t), b)
                row += [show(bs["mean"]), pct(bs["mean"] / s["mean"] - 1, sign=True) if s["mean"] else "–",
                        f"{p:.3f}" if p is not None else "–"]
            rows.append(row)
        headers = ["metric", "mean", "sd", "cv", f"MDE (n={A.n})", "n for 2%", "n for 5%"]
        if self.B:
            headers += ["B mean", "B vs A", "p"]
        self.w(table(headers, rows), "")

    def section_appendix(self):
        self.w("## Appendix", "",
               "- **Regenerate:** `python tools/ensembles/Make-EnsembleReport.py --ensemble <A> [--compare <B>]`. "
               "It reads only the database.",
               "- **Snapshots:** the first country whose monthly pulse lands in Jan/Apr/Jul/Oct logs everyone the same "
               "day; `t` counts quarters from 1836-01.",
               "- **World aggregates:** sums over countries (not decentralized), pop-weighted means for SoL, literacy, "
               "wage, market access and turmoil. World goods: summed orders, demand-weighted price.",
               "- **Stats:** sd uses n − 1. MDE and n-needed assume equal spread in both arms; Welch's t-test for "
               "comparisons. With ~25 metrics tested at once, expect about one p < 0.05 by chance.",
               "- **Bimodality:** revolution-wave members shift several world metrics; a mod that changes the chance "
               "of a wave changes means through that alone.",
               "- **Palette:** the dataviz skill's reference palette, unchanged (documented as CVD-validated); Node "
               "wasn't available to rerun its validator. Figures are static SVG; the tables carry the values.", "")


def json_load(text):
    import json
    try:
        return json.loads(text) if text else {}
    except ValueError:
        return {}


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--db", type=pathlib.Path, default=HERE / "ensembles.sqlite")
    parser.add_argument("--ensemble", required=True, help="reference ensemble (A)")
    parser.add_argument("--compare", help="treatment ensemble (B) to compare against A")
    parser.add_argument("--out", type=pathlib.Path)
    parser.add_argument("--png", type=pathlib.Path, help="also write PNG copies of the figures to this folder")
    args = parser.parse_args()
    global PNG_DIR
    if args.png:
        args.png.mkdir(parents=True, exist_ok=True)
        PNG_DIR = args.png

    db = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
    ensembles = [Ensemble(db, args.ensemble, SERIES[0], "A" if args.compare else "vanilla" if "vanilla" in args.ensemble else "A")]
    if args.compare:
        ensembles.append(Ensemble(db, args.compare, SERIES[1], "B"))
    name = args.ensemble + (f"_vs_{args.compare}" if args.compare else "")
    out = args.out or REPO / "docs" / "reports" / name
    report = Report(db, ensembles, out)
    report.build()
    print(f"Wrote {out / 'REPORT.md'} and {len(list((out / 'figures').glob('*.svg')))} figures")


if __name__ == "__main__":
    main()
