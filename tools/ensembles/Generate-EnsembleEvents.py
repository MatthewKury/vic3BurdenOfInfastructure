"""Generate the ensemble telemetry module's on_action file.

The on_action file (tools/headless-telemetry/ensemble/common/on_actions/zz_boitm_ens_on_actions.txt)
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
         "steamers silk dye sulfur coal iron lead copper hardwood rubber oil engines steel glass fertilizer tools "
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
         "admin", "university", "livestock_ranch", "logging", "shipyard", "tooling", "steel", "coal", "iron", "copper"]]),
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
    ("state_env", [("sol_poor", "[THIS.GetState.GetAverageStandardOfLivingPoor|2]"),
                   ("sol_middle", "[THIS.GetState.GetAverageStandardOfLivingMiddle|2]"),
                   ("sol_rich", "[THIS.GetState.GetAverageStandardOfLivingRich|2]"),
                   ("pollution_impact", "[THIS.GetState.GetStateRegion.GetPollutionImpact|4]"),
                   ("pollution_generation", "[THIS.GetState.GetPollutionGeneration|1]")]),
]

header = """# Headless telemetry (ensemble module), generated by
# tools/ensembles/Generate-EnsembleEvents.py; don't edit by hand.
#
# Quarterly snapshot of every country, state and market, read by
# tools/ensembles/Build-EnsembleDb.py. Line format:
#   BOIENS|snapshot|<date>|WORLD|0|version=4                           header
#   BOIENS|<group>|<date>|<tag>|<id>|key=value;...                     country groups
#   BOIENS|state|<date>|<owner tag>|<owner id>|<region>|key=value;...  (also state_ui, state_env)
#   BOIENS|price|<date>|<owner tag>|<owner id>|<goods>=value;...       (also buy, sell)
# <id> is the engine's country id. Tags are not unique: civil-war
# revolutionaries share the tag of the country they split from.
# One metric group per debug_log, because a data function that fails blanks its
# whole line (VIC3_MODDING_LESSONS.md, section 20). The goods lines are long,
# but every key on one line calls the same data function.
#
# Clock (version 4, 2026-11-05): the global on_monthly_pulse (no root scope)
# calls boitm_ens_monthly, which snapshots in January, April, July and October
# (month is 0-based). Versions up to 3 ran the snapshot from the first
# country's on_monthly_pulse_country instead. Three 1.15 games crashed at the
# same address inside that country-pulse snapshot (lessons file, "Unsolved").
# The metrics are unchanged. Vanilla's _on_actions.md documents this hook
# pattern: list a modded on_action in the vanilla one's on_actions, and keep the
# effect in the modded one, because two effect blocks on one on_action conflict.
"""

body = ["\t\t" + 'debug_log = "BOIENS|snapshot|' + D + '|WORLD|0|version=4"',
        "\t\tevery_country = {", "\t\t\tlimit = { NOT = { is_country_type = decentralized } }"]
body += ["\t\t\t" + line(g, C, p) for g, p in country]
body += ["\t\t\tevery_scope_state = {"] + ["\t\t\t\t" + line(g, S, p) for g, p in state] + ["\t\t\t}", "\t\t}"]
body += ["\t\tevery_market = {"] + ["\t\t\t" + goods_line(g, fn) for g, fn in
                                    [("price", "GetMarketPrice"), ("buy", "GetMarketBuyOrders"), ("sell", "GetMarketSellOrders")]]
body += ["\t\t}"]

out = [header,
       "# No root scope",
       "on_monthly_pulse = {", "\ton_actions = {", "\t\tboitm_ens_monthly", "\t}", "}", "",
       "boitm_ens_monthly = {",
       "\ttrigger = {", "\t\tOR = {", "\t\t\tmonth = 0", "\t\t\tmonth = 3", "\t\t\tmonth = 6", "\t\t\tmonth = 9", "\t\t}", "\t}",
       "\teffect = {"] + body + ["\t}", "}", ""]

on_actions = root / "common" / "on_actions" / "zz_boitm_ens_on_actions.txt"
on_actions.parent.mkdir(parents=True, exist_ok=True)
on_actions.write_text("\n".join(out), encoding="utf-8-sig", newline="\n")

# Up to version 3 the snapshot was an event; remove the stale file.
stale = root / "events" / "zz_boitm_ens_events.txt"
if stale.exists():
    stale.unlink()
    if not any(stale.parent.iterdir()):
        stale.parent.rmdir()
print(on_actions, on_actions.stat().st_size)
