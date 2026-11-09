"""Generate events/boi_housing_events.txt and its triggers.

Twelve housing events (agreed 2026-11-08; plan 6, "Proposed housing events"),
five for employer housing and seven for residential housing. The file is
generated because the Great Fire needs if/else chains over every housing type
(to burn one wood-heated building) and every urban industry type (to burn
one), which a script can keep in step with the roster. Re-run when the
housing roster or vanilla's industry buildings change:

    python tools/Build-HousingEvents.py
"""
import os

MOD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_EVENTS = os.path.join(MOD, 'events', 'boi_housing_events.txt')
OUT_TRIGGERS = os.path.join(MOD, 'common', 'scripted_triggers', '55_boi_housing_event_triggers.txt')

HOUSING = ['slums', 'tenements', 'regulated_terraces', 'tenement_blocks', 'model_dwellings',
           'apartments', 'municipal_estates', 'elevator_apartments', 'luxury_apartments',
           'boulevard_apartments', 'elevator_residences', 'suburbs', 'railway_suburbs',
           'streetcar_suburbs', 'motor_suburbs']
INDUSTRY = ['building_arms_industry', 'building_artillery_foundry', 'building_automotive_industry',
            'building_chemical_plant', 'building_electrics_industry', 'building_explosives_factory',
            'building_food_industry', 'building_furniture_manufactory', 'building_glassworks',
            'building_motor_industry', 'building_munition_plant', 'building_paper_mill',
            'building_steel_mill', 'building_synthetics_plant', 'building_textile_mill',
            'building_tooling_workshop']


def ind(text, n):
    pad = '\t' * n
    return '\n'.join(pad + l if l else l for l in text.split('\n'))


def chain(scope, types):
    """if/else_if: remove the building type that scope:<scope> is."""
    parts = []
    for i, t in enumerate(types):
        kw = 'if' if i == 0 else 'else_if'
        parts.append(f'{kw} = {{\n\tlimit = {{ scope:{scope} = {{ is_building_type = {t} }} }}\n\tremove_building = {t}\n}}')
    return '\n'.join(parts)


def ig(name, mod):
    return f'ig:{name} ?= {{\n\tadd_modifier = {{ name = boi_hev_ig_{mod} days = 730 is_decaying = yes }}\n}}'


def event(n, video, icon, trigger, immediate, options, cooldown=None, placement=True):
    lines = [f'boi_housing_events.{n} = {{', '\ttype = country_event']
    if placement:
        lines.append('\tplacement = scope:hev_state')
    lines += [f'\ttitle = boi_housing_events.{n}.t', f'\tdesc = boi_housing_events.{n}.d',
              f'\tflavor = boi_housing_events.{n}.f', f'\tevent_image = {{ video = "{video}" }}',
              '\ton_created_soundeffect = "event:/SFX/UI/Alerts/event_appear"',
              f'\ticon = "gfx/interface/icons/event_icons/{icon}"', '\tduration = 3', '']
    trig = trigger
    imm = immediate
    if cooldown:
        var, years = cooldown
        trig = f'NOT = {{ has_variable = {var} }}\n' + trig
        imm = (f'set_variable = {{ name = {var} value = yes years = {years} }}\n' if years
               else f'set_variable = {var}\n') + imm
    lines += ['\ttrigger = {', ind(trig.strip(), 2), '\t}', '', '\timmediate = {', ind(imm.strip(), 2), '\t}']
    for letter, body, ai, default in options:
        lines += ['', '\toption = {', f'\t\tname = boi_housing_events.{n}.{letter}']
        if default:
            lines.append('\t\tdefault_option = yes')
        if body.strip():
            lines.append(ind(body.strip(), 2))
        lines += [f'\t\tai_chance = {{ base = {ai} }}', '\t}']
    lines.append('}')
    return '\n'.join(lines)


def pick(limit, order):
    return (f'ordered_scope_state = {{\n\tlimit = {{ {limit} }}\n\torder_by = {order}\n'
            '\tposition = 0\n\tcheck_range_bounds = no\n\tsave_scope_as = hev_state\n}')


EVENTS = []

# ── Employer housing ────────────────────────────────────────────
EVENTS.append(event(10, 'europenorthamerica_capitalists_meeting', 'event_scales.dds',
    'has_law_or_variant = law_type:law_no_workers_rights\nboi_hev_camp_levels >= 10\nany_scope_state = { boi_hev_state_camp_levels >= 3 }',
    pick('boi_hev_state_camp_levels >= 3', 'boi_hev_state_camp_levels'),
    [('a', ig('ig_industrialists', 'angered') + '\n' + ig('ig_trade_unions', 'pleased'), 1, False),
     ('b', 'scope:hev_state = {\n\tadd_radicals_in_state = {\n\t\tvalue = medium_radicals\n\t\tpop_type = laborers\n\t}\n}', 2, True)],
    cooldown=('boi_hev_company_store_cd', 5)))

EVENTS.append(event(11, 'europenorthamerica_russian_serfs', 'event_protest.dds',
    'ig:ig_rural_folk ?= { has_ideology = ideology:ideology_boi_housing_tied_cottages }\nany_scope_state = { boi_hev_state_farm_company_levels >= 5 }',
    pick('boi_hev_state_farm_company_levels >= 5', 'boi_hev_state_farm_company_levels'),
    [('a', ig('ig_landowners', 'angered') + '\n' + ig('ig_rural_folk', 'pleased'), 1, False),
     ('b', 'scope:hev_state = {\n\tadd_radicals_in_state = {\n\t\tvalue = medium_radicals\n\t\tpop_type = farmers\n\t}\n}\n' + ig('ig_rural_folk', 'angered'), 2, True)],
    cooldown=('boi_hev_tied_cottage_cd', 5)))

EVENTS.append(event(12, 'unspecific_devastation', 'event_skull.dds',
    'any_scope_state = { boi_hev_state_extraction_camp_levels >= 3 }',
    pick('boi_hev_state_extraction_camp_levels >= 3', 'boi_hev_state_extraction_camp_levels'),
    [('a', 'add_treasury = boi_hev_payment\n' + ig('ig_trade_unions', 'pleased') + '\n' + ig('ig_intelligentsia', 'pleased'), 1, True),
     ('b', 'scope:hev_state = {\n\tadd_modifier = { name = boi_hev_camp_disaster years = 1 }\n\tadd_radicals_in_state = {\n\t\tvalue = medium_radicals\n\t\tpop_type = laborers\n\t}\n}', 2, False)],
    cooldown=('boi_hev_camp_disaster_cd', 5)))

EVENTS.append(event(13, 'southamerica_factory_opening', 'event_industry.dds',
    'any_scope_state = { boi_hev_state_town_levels >= 5 }\nig:ig_industrialists ?= { OR = { is_in_government = yes is_powerful = yes } }',
    pick('boi_hev_state_town_levels >= 5', 'boi_hev_state_town_levels'),
    [('a', 'add_modifier = { name = boi_hev_model_village_prestige years = 5 }\nscope:hev_state = {\n\tadd_modifier = { name = boi_hev_model_village years = 5 }\n}\n' + ig('ig_industrialists', 'pleased'), 2, True),
     ('b', 'add_treasury = boi_hev_grant\n' + ig('ig_industrialists', 'angered'), 1, False)],
    cooldown=('boi_hev_model_village_cd', 10)))

EVENTS.append(event(14, 'europenorthamerica_political_extremism', 'event_protest.dds',
    'ig:ig_trade_unions ?= { is_powerful = yes }\nany_scope_state = { boi_hev_state_town_levels >= 10 }',
    pick('boi_hev_state_town_levels >= 10', 'boi_hev_state_town_levels'),
    [('a', 'scope:hev_state = {\n\tadd_radicals_in_state = {\n\t\tvalue = large_radicals\n\t\tstrata = poor\n\t}\n}\n' + ig('ig_armed_forces', 'pleased') + '\n' + ig('ig_trade_unions', 'angered'), 1, False),
     ('b', 'add_treasury = boi_hev_payment\n' + ig('ig_trade_unions', 'pleased'), 2, True)],
    cooldown=('boi_hev_pullman_cd', 5)))

# ── Residential housing ─────────────────────────────────────────
EVENTS.append(event(20, 'unspecific_devastation', 'event_skull.dds',
    'NOT = { has_law = law_type:law_boi_residential_standards }\nany_scope_state = {\n\tboi_cm_state_low_tier_levels >= 3\n\tsg:boi_housing = { state_goods_pricier >= 0.5 }\n}',
    pick('boi_cm_state_low_tier_levels >= 3 sg:boi_housing = { state_goods_pricier >= 0.5 }', 'boi_cm_state_low_tier_levels'),
    [('a', ig('ig_intelligentsia', 'pleased') + '\n' + ig('ig_trade_unions', 'pleased') + '\n' + ig('ig_landowners', 'angered') + '\n' + ig('ig_petty_bourgeoisie', 'angered'), 1, False),
     ('b', 'scope:hev_state = {\n\tadd_radicals_in_state = {\n\t\tvalue = medium_radicals\n\t\tstrata = poor\n\t}\n}', 2, True)],
    cooldown=('boi_hev_collapse_cd', 5)))

EVENTS.append(event(21, 'unspecific_vandalized_storefront', 'event_protest.dds',
    'any_scope_state = {\n\tboi_hev_state_industry_levels >= 10\n\tsg:boi_housing = { state_goods_pricier >= 0.6 }\n}',
    pick('boi_hev_state_industry_levels >= 10 sg:boi_housing = { state_goods_pricier >= 0.6 }', 'boi_hev_state_industry_levels'),
    [('a', 'scope:hev_state = {\n\tadd_modifier = { name = boi_disp_rent_control years = 2 }\n}\n' + ig('ig_landowners', 'angered') + '\n' + ig('ig_trade_unions', 'pleased'), 1, False),
     ('b', 'scope:hev_state = {\n\tadd_radicals_in_state = {\n\t\tvalue = large_radicals\n\t\tstrata = poor\n\t}\n}', 2, True)],
    cooldown=('boi_hev_rent_strike_cd', 5)))

EVENTS.append(event(22, 'unspecific_signed_contract', 'event_scales.dds',
    'has_technology_researched = urban_planning\nhas_technology_researched = modern_sewerage\nNOT = { has_journal_entry = je_boi_rehousing_pledge }\nany_scope_state = { boi_cm_state_low_tier_levels >= 4 }',
    pick('boi_cm_state_low_tier_levels >= 4', 'boi_cm_state_low_tier_levels'),
    [('a', 'add_treasury = boi_hev_grant\nboi_pledge_start_state = yes\n' + ig('ig_devout', 'pleased'), 1, False),
     ('b', '', 1, True)],
    cooldown=('boi_hev_philanthropist_cd', 10)))

EVENTS.append(event(23, 'unspecific_politicians_arguing', 'event_scales.dds',
    'NOT = { has_law = law_type:law_boi_residential_standards }\nboi_hev_low_tier_levels >= 15\nOR = {\n\tig:ig_intelligentsia ?= { is_powerful = yes }\n\tig:ig_trade_unions ?= { is_powerful = yes }\n}',
    'capital = { save_scope_as = hev_state }',
    [('a', 'add_radicals = {\n\tvalue = small_radicals\n\tstrata = poor\n}\n' + ig('ig_intelligentsia', 'pleased') + '\n' + ig('ig_trade_unions', 'pleased') + '\n' + ig('ig_landowners', 'angered'), 1, True),
     ('b', ig('ig_intelligentsia', 'angered'), 1, False)],
    cooldown=('boi_hev_commission_cd', 15)))

# The Great Fire: 20-year cooldown; needs a housing building heated by wood.
fire_burn = '''scope:hev_state = {
	if = {
		limit = { has_building = building_boi_slums }
		remove_building = building_boi_slums
	}
	if = {
		limit = { has_building = building_boi_tenements }
		remove_building = building_boi_tenements
	}
	# The largest other wood-heated housing goes with them.
	ordered_scope_building = {
		limit = { boi_hev_building_wood_fire = yes }
		order_by = level
		position = 0
		check_range_bounds = no
		save_scope_as = burned_housing
	}
	if = {
		limit = { exists = scope:burned_housing }
''' + ind(chain('burned_housing', [f'building_boi_{k}' for k in HOUSING]), 2) + '''
	}
	# And the smallest urban industry nearby.
	ordered_scope_building = {
		limit = { boi_hev_building_urban_industry = yes }
		order_by = boi_hev_building_smallness
		position = 0
		check_range_bounds = no
		save_scope_as = burned_industry
	}
	if = {
		limit = { exists = scope:burned_industry }
''' + ind(chain('burned_industry', INDUSTRY), 2) + '''
	}
	add_modifier = { name = boi_hev_great_fire years = 1 }
}'''
EVENTS.append(event(24, 'unspecific_devastation', 'event_skull.dds',
    'any_scope_state = { boi_hev_state_wood_fire = yes }',
    pick('boi_hev_state_wood_fire = yes', 'boi_cm_state_low_tier_levels') + '\n' + fire_burn,
    [('a', 'add_treasury = boi_hev_payment_large\nscope:hev_state = {\n\tset_variable = boi_modernised_city\n\tadd_modifier = { name = boi_cm_modernised_city years = 5 }\n}', 1, False),
     ('b', '', 2, True)],
    cooldown=('boi_hev_great_fire_cd', 20)))

EVENTS.append(event(25, 'europenorthamerica_capitalists_meeting', 'event_scales.dds',
    'boi_hev_cheap_luxury_states >= 3',
    'capital = { save_scope_as = hev_state }',
    [('a', 'add_treasury = boi_hev_payment_large\n' + ig('ig_industrialists', 'pleased'), 1, False),
     ('b', 'add_radicals = {\n\tvalue = small_radicals\n\tstrata = middle\n}\nadd_modifier = { name = boi_hev_building_crash years = 1 }', 2, True)],
    cooldown=('boi_hev_bubble_cd', 10)))

EVENTS.append(event(26, 'unspecific_world_fair', 'event_industry.dds',
    'boi_hev_socialist_government = yes\nboi_hev_municipal_levels >= 10',
    'capital = { save_scope_as = hev_state }',
    [('a', 'add_modifier = { name = boi_hev_red_vienna years = 10 }\n' + ig('ig_trade_unions', 'pleased'), 1, True)],
    cooldown=('boi_hev_red_vienna_done', None)))

ids = [10, 11, 12, 13, 14, 20, 21, 22, 23, 24, 25, 26]
dispatcher = ('boi_housing_events.1 = {\n\ttype = country_event\n\thidden = yes\n\n'
              '\ttrigger = { NOT = { is_country_type = decentralized } }\n\n\timmediate = {\n\t\trandom_list = {\n'
              + ''.join(f'\t\t\t3 = {{ trigger_event = {{ id = boi_housing_events.{i} popup = yes }} }}\n' for i in ids)
              + '\t\t\t64 = {}\n\t\t}\n\t}\n}')

header = '''namespace = boi_housing_events

# ================================================================
#  Burden of Infrastructure — housing events (2026-11-08)
#  Generated by tools/Build-HousingEvents.py; do not edit by hand.
#  Plan 6, "Proposed housing events". All numbers are test values.
#
#   .1    hidden yearly dispatcher: one 3% roll for each event
#   Employer housing:
#   .10   The Company Store         .11   Tied Cottage Evictions
#   .12   Disaster at the Camp      .13   A Model Village
#   .14   The Pullman Strike
#   Residential housing:
#   .20   A Tenement Collapses      .21   The Rent Strike
#   .22   A Philanthropist's Offer (rehousing pledge)
#   .23   A Royal Commission on Housing
#   .24   The Great Fire (20-year cooldown; any wood-heated housing)
#   .25   A Suburban Building Bubble
#   .26   Red Vienna (once)
#  Each event cools down 5-15 years per country from when it fires.
# ================================================================

'''
with open(OUT_EVENTS, 'w', encoding='utf-8-sig', newline='\n') as f:
    f.write(header + dispatcher + '\n\n' + '\n\n'.join(EVENTS) + '\n')

wood = '\n'.join(f'\t\thas_active_production_method = pm_boi_{k}_wood' for k in HOUSING)
industry = '\n'.join(f'\t\tis_building_type = {t}' for t in INDUSTRY)
triggers = f'''# Generated by tools/Build-HousingEvents.py; do not edit by hand.

# Building scope. A housing building heated by wood stoves and candles.
boi_hev_building_wood_fire = {{
	OR = {{
{wood}
	}}
}}

# State scope. The Great Fire can start here.
boi_hev_state_wood_fire = {{
	any_scope_building = {{ boi_hev_building_wood_fire = yes }}
}}

# Building scope. An urban industry the Great Fire can burn.
boi_hev_building_urban_industry = {{
	OR = {{
{industry}
	}}
}}

# Country scope. Municipal Estates' gate: a council republic, or an economy
# without private capital.
boi_hev_socialist_government = {{
	OR = {{
		has_law_or_variant = law_type:law_council_republic
		has_law_or_variant = law_type:law_command_economy
		has_law_or_variant = law_type:law_cooperative_ownership
	}}
}}
'''
with open(OUT_TRIGGERS, 'w', encoding='utf-8-sig', newline='\n') as f:
    f.write(triggers)
print(f'Wrote {OUT_EVENTS} and {OUT_TRIGGERS}')
