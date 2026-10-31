"""Generate the ensemble telemetry module's event and on_action files.

The event file (tools/headless-telemetry/ensemble/events/zz_boitm_ens_events.txt)
is one long debug_log line per metric group, so it is generated rather than
edited by hand. To add a metric: add its script value to
tools/headless-telemetry/ensemble/common/script_values/zz_boitm_ens_values.txt,
add a (key, expression) pair to the matching group below, add the key to the
catalogue in Build-EnsembleDb.py, then run:

    python Generate-EnsembleEvents.py

Keys must be unique across a line family (all country groups, or both state
groups), because the builder merges each family into one table row.
"""
import pathlib
import sys

root = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else     pathlib.Path(__file__).resolve().parent.parent / "headless-telemetry" / "ensemble"
goods = ("ammunition small_arms artillery tanks aeroplanes manowars ironclads grain fish fabric wood "
         "groceries clothes furniture paper services transportation electricity merchant_marine clippers "
         "steamers silk dye sulfur coal iron lead hardwood rubber oil engines steel glass fertilizer tools "
         "explosives porcelain meat fruit liquor wine tea coffee sugar tobacco opium automobiles telephones "
         "radios luxury_clothes luxury_furniture gold fine_art").split()

D = "[TimeKeeper.GetCurrentDate.GetString]"
C = "[THIS.GetCountry.GetTagName]|[THIS.GetCountry.GetIDString]"
S = "[THIS.GetState.GetOwner.GetTagName]|[THIS.GetState.GetOwner.GetIDString]|[THIS.GetState.GetStateRegion.GetName]"
M = "[THIS.GetMarket.GetOwner.GetTagName]|[THIS.GetMarket.GetOwner.GetIDString]"


def sv(name, fmt):
    return f"[THIS.ScriptValue('{name}')|{fmt}]"


def line(group, who, pairs):
    body = ";".join(f"{k}={v}" for k, v in pairs)
    return f'debug_log = "BOIENS|{group}|{D}|{who}|{body}"'


def goods_line(group, fn):
    return line(group, M, [(g, f"[GetGoods('{g}').WithMarketContext(THIS.GetMarket.Self).{fn}|2]") for g in goods])


country = [
    ("society", [("gdp", sv("boitm_gdp", 0)), ("sol", sv("boitm_sol", 2)), ("population", sv("boitm_population", 0)),
                 ("literacy", sv("boitm_ens_literacy", 4)), ("urbanization", sv("boitm_ens_urbanization", 0)),
                 ("states", sv("boitm_states", 0)), ("incorporated_states", sv("boitm_ens_incorporated_states", 0)),
                 ("turmoil", sv("boitm_ens_turmoil", 4))]),
    ("politics", [("radicals", "[THIS.GetCountry.GetNumRadicals|0]"), ("loyalists", "[THIS.GetCountry.GetNumLoyalists|0]"),
                  ("market", "[THIS.GetCountry.GetMarket.GetOwner.GetIDString]")]),
    ("standing", [(k, sv(f"boitm_ens_{v}", f)) for k, v, f in [
        ("rank", "rank", 0), ("prestige", "prestige", 1), ("infamy", "infamy", 1), ("legitimacy", "legitimacy", 0),
        ("techs", "techs", 0), ("army", "army", 0), ("navy", "navy", 0), ("at_war", "at_war", 0),
        ("is_subject", "is_subject", 0), ("subjects", "subjects", 0)]]),
    ("budget", [(k, sv(f"boitm_ens_{k}", f)) for k, f in [
        ("gold", 0), ("debt", 4), ("credit", 0), ("income", 0), ("expenses", 0), ("fixed_income", 0),
        ("fixed_expenses", 0), ("investment_income", 0), ("tax_level", 0), ("gov_wage_level", 0), ("mil_wage_level", 0)]]),
    ("admin", [(k, sv(f"boitm_ens_{k}", 0)) for k in [
        "bureaucracy", "bureaucracy_usage", "authority", "authority_usage", "influence", "influence_usage"]]),
    ("infrastructure", [("infrastructure", sv("boitm_infrastructure", 1)), ("infrastructure_usage", sv("boitm_infrastructure_usage", 1)),
                        ("deficit_states", sv("boitm_infrastructure_deficit_states", 0))] +
     [(f"{k}_levels", sv(f"boitm_ens_{k}_levels", 0)) for k in ["railway", "port", "construction", "urban_center", "trade_center"]]),
    ("buildings", [("building_levels", sv("boitm_ens_building_levels", 0))] +
     [(f"{k}_levels", sv(f"boitm_ens_{k}_levels", 0)) for k in [
         "admin", "university", "livestock_ranch", "logging", "shipyard", "tooling", "steel", "coal", "iron"]]),
    ("sectors", [(f"{k}_levels", sv(f"boitm_ens_{k}", 0)) for k in [
        "bg_agriculture", "bg_subsistence", "bg_plantations", "bg_ranching", "bg_extraction", "bg_light_industry",
        "bg_heavy_industry", "bg_military_industry", "bg_government", "bg_military", "bg_infrastructure"]]),
]

state = [
    ("state", [("population", sv("boitm_ens_state_population", 0)), ("urbanization", sv("boitm_ens_state_urbanization", 0)),
               ("infrastructure", sv("boitm_ens_state_infrastructure", 1)),
               ("infrastructure_usage", sv("boitm_ens_state_infrastructure_usage", 1)),
               ("unemployment_rate", sv("boitm_ens_state_unemployment_rate", 4)),
               ("incorporated", sv("boitm_ens_state_incorporated", 0))] +
     [(f"{k}_levels", sv(f"boitm_ens_state_{k}_levels", 0)) for k in ["railway", "port", "urban_center", "construction"]] +
     [("building_levels", sv("boitm_ens_state_building_levels", 0))]),
    ("state_ui", [("market_access", "[THIS.GetState.GetMarketAccess|4]"), ("gdp", "[THIS.GetState.GetGDPContribution|0]"),
                  ("sol", "[THIS.GetState.GetAverageStandardOfLivingAll|2]"), ("wage", "[THIS.GetState.GetAverageAnnualWage|1]"),
                  ("literacy", "[THIS.GetState.GetLiteracy|4]"), ("unemployed", "[THIS.GetState.GetNumUnemployedWorkingAdults|0]"),
                  ("radicals", "[THIS.GetState.GetNumRadicals|0]"), ("loyalists", "[THIS.GetState.GetNumLoyalists|0]"),
                  ("turmoil", "[THIS.GetState.CalcTurmoil|4]"), ("migration", "[THIS.GetState.GetWeeklyPopNetMigration|0]")]),
]

header = """namespace = boitm_ens

# Headless telemetry (ensemble module). Quarterly snapshot of every country,
# state and market, read by tools/ensembles/Build-EnsembleDb.py. Line format:
#   BOIENS|<group>|<date>|<tag>|<id>|key=value;...                     country groups
#   BOIENS|state|<date>|<owner tag>|<owner id>|<region>|key=value;...  (also state_ui)
#   BOIENS|price|<date>|<owner tag>|<owner id>|<goods>=value;...       (also buy, sell)
# <id> is the engine's country id. Tags are not unique: civil-war
# revolutionaries share the tag of the country they split from.
# One metric group per debug_log, because a data function that fails blanks its
# whole line (VIC3_MODDING_LESSONS.md, section 20). The goods lines are long,
# but every key on one line calls the same data function.
#
# Clock: the first country whose monthly pulse lands in January, April, July or
# October takes the snapshot for everyone, so all countries share one date.
# month is 0-based (January = 0). The lock outlives the month, so the other
# countries' pulses that month do nothing.
"""

out = [header, "boitm_ens.1 = {", "\ttype = country_event", "\thidden = yes", "",
       "\ttrigger = {", "\t\tOR = {", "\t\t\tmonth = 0", "\t\t\tmonth = 3", "\t\t\tmonth = 6", "\t\t\tmonth = 9", "\t\t}",
       "\t\tNOT = { has_global_variable = boitm_ens_lock }", "\t}", "",
       "\timmediate = {", "\t\tset_global_variable = {", "\t\t\tname = boitm_ens_lock", "\t\t\tdays = 45", "\t\t}",
       "\t\t" + line("snapshot", C, [("version", "2")]),
       "\t\tevery_country = {", "\t\t\tlimit = { NOT = { is_country_type = decentralized } }"]
out += ["\t\t\t" + line(g, C, p) for g, p in country]
out += ["\t\t\tevery_scope_state = {"] + ["\t\t\t\t" + line(g, S, p) for g, p in state] + ["\t\t\t}", "\t\t}"]
out += ["\t\tevery_market = {"] + ["\t\t\t" + goods_line(g, fn) for g, fn in
                                   [("price", "GetMarketPrice"), ("buy", "GetMarketBuyOrders"), ("sell", "GetMarketSellOrders")]]
out += ["\t\t}", "\t}", "}", ""]

events = root / "events" / "zz_boitm_ens_events.txt"
events.parent.mkdir(parents=True, exist_ok=True)
events.write_text("\n".join(out), encoding="utf-8-sig", newline="\n")

on_actions = root / "common" / "on_actions" / "zz_boitm_ens_on_actions.txt"
on_actions.parent.mkdir(parents=True, exist_ok=True)
on_actions.write_text("""# Headless telemetry (ensemble module). events = { } only; see the core module.

# Root = country
on_monthly_pulse_country = {
\tevents = {
\t\tboitm_ens.1
\t}
}
""", encoding="utf-8-sig", newline="\n")
print(events, events.stat().st_size)
