# The residential roster. tools/Build-Housing.ps1 dot-sources this and generates
# buildings, building groups, PMs, PM groups and localization from it, so a balance
# pass only changes numbers here. All numbers are test values. See
# docs/plans/04_HOUSING_TIERS_PROPOSAL.md.
#
# Rules the table has to keep:
# - Structure is fixed: each building has one structure PM. The only PM a player
#   or AI can change on a housing building is Light and Heat. Company housing
#   on workplaces is a separate system.
# - Each step of a ladder needs less infrastructure per unit of housing.
# - Keys of the five original buildings stay, so the seed and fixtures keep working.

# Light and Heat: extra output as a share of the building's own, and the share of
# that output's value at base price spent on fuel. Slums can only burn wood.
$HousingFuels = [ordered]@{
    wood        = @{ Bonus = 0.10; Good = 'wood'; Price = 20; Name = 'Wood Stoves and Candles'; Texture = 'hardwood_selection.dds' }
    oil         = @{ Bonus = 0.30; Good = 'oil'; Price = 40; Name = 'Paraffin Lamps and Stoves'; Texture = 'oil_fired_plant.dds'; Tech = 'pumpjacks' }
    electricity = @{ Bonus = 0.60; Good = 'electricity'; Price = 30; Name = 'Electric Light and Heat'; Texture = 'electric_streetlights.dds'; Tech = 'electrical_generation'; RequiredInput = 'electricity' }
}
$HousingFuelCostShare = 0.5
$HousingBasicPrice = 30
$HousingLuxuryPrice = 60

$HousingPowerPlantGate = 'has_building = building_power_plant'
$HousingStandardsGate = 'owner = { NOT = { has_law = law_type:law_boi_residential_standards } }'
# A state cleared by City Modernisation never gets Slums or Workers' Rows back, even if
# Residential Standards is later repealed (the journal entry sets boi_modernised_city).
$HousingClearedGate = "$HousingStandardsGate`n  NOT = { has_variable = boi_modernised_city }"
# Municipal Estates need a socialist-type government: a council republic, or an
# economy without private capital (2026-11-08).
$HousingSocialistGate = 'owner = { OR = { has_law_or_variant = law_type:law_council_republic has_law_or_variant = law_type:law_command_economy has_law_or_variant = law_type:law_cooperative_ownership } }'
# Country = country_modifiers, workforce_scaled (per staffed level). The low tiers cost a
# share of prestige: -0.5% / -0.25% / -0.125% per staffed level (2026-11-08).

# NotDownsizeable: AI budget cuts appear to have demolished whole countries' Municipal
# Estates in the century runs (Austria 41 to 0). Temporary Shelter stays cuttable, being temporary.
# Key, display name, description, building group, unlock, construction cost, basic
# and luxury output, infrastructure per level, inputs per level, employment
# (laborers, clerks), icon, and optional possible, state modifiers and fuels.
$HousingBuildings = @(
    # ---- Working-class ladder ----
    @{ Key = 'slums'; Name = 'Slum Districts'; Group = 'bg_boi_slum_housing'; GroupName = 'Slum Housing'; Parent = 'dense'
        Desc = 'Cheap accommodation with heavy infrastructure demand. Any constructed slum district raises state mortality, and staffing raises mortality further and lowers migration attraction. The only way out is to clear it and build something better.'
        Cost = 'construction_cost_low'; Basic = 6; Luxury = 0; Infra = 3.5; Labor = 900; Clerks = 100; Icon = 'boi_slums.dds'
        Inputs = [ordered]@{ wood = 0.3; tools = 0.1; fabric = 0.2 }; Possible = $HousingClearedGate; Fuels = @('wood')
        Scaled = [ordered]@{ state_mortality_mult = 0.02; state_migration_pull_mult = -0.002; state_pollution_generation_add = 50 }
        Country = [ordered]@{ country_prestige_mult = -0.005 }
        Unscaled = [ordered]@{ state_mortality_mult = 0.1 } }
    @{ Key = 'tenements'; Name = "Workers' Rows"; Group = 'bg_boi_tenement_housing'; GroupName = 'Rows and Terraces'; Parent = 'dense'
        Desc = 'Back-to-backs, chawls and cramped rows put up by speculative builders. Heavy infrastructure demand. Better housing has to be built new.'
        Cost = 'construction_cost_low'; Basic = 7; Luxury = 0; Infra = 3; Labor = 800; Clerks = 200; Icon = 'boi_tenements.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.3; fabric = 0.2 }; Possible = $HousingClearedGate
        Country = [ordered]@{ country_prestige_mult = -0.0025 } }
    @{ Key = 'regulated_terraces'; Name = 'Regulated Terraces'; Group = 'bg_boi_regulated_terrace_housing'; GroupName = 'Regulated Terraces'; Parent = 'dense'
        Desc = 'Through-terraces built to a street plan, with windows, drains and a little more light than the rows they replace.'
        Tech = 'urban_planning'; Cost = 'construction_cost_low'; Basic = 8; Luxury = 0; Infra = 2.5; Labor = 800; Clerks = 200; Icon = 'boi_regulated_terraces.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.3; glass = 0.2 } }
    @{ Key = 'tenement_blocks'; Name = 'Tenement Blocks'; Group = 'bg_boi_tenement_block_housing'; GroupName = 'Tenement Blocks'; Parent = 'dense'
        Desc = 'Mietskasernen and dumbbell tenements: cheap, dense and airless. Staffing raises state mortality a little and lowers migration attraction.'
        Tech = 'mechanized_workshops'; Cost = 'construction_cost_low'; Basic = 10; Luxury = 0; Infra = 2; Labor = 800; Clerks = 200; Icon = 'boi_tenement_blocks.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.3; iron = 0.2 }; Possible = $HousingStandardsGate
        Scaled = [ordered]@{ state_mortality_mult = 0.001; state_migration_pull_mult = -0.001 }
        Country = [ordered]@{ country_prestige_mult = -0.00125 } }
    @{ Key = 'model_dwellings'; Name = 'Model Dwellings'; Group = 'bg_boi_model_dwelling_housing'; GroupName = 'Model Dwellings'; Parent = 'dense'
        Desc = 'Philanthropic blocks with shared baths and laundries. As dense as a tenement block with none of its harm, at twice the construction cost.'
        Tech = 'modern_sewerage'; Cost = 'construction_cost_medium'; Basic = 9; Luxury = 0; Infra = 2; Labor = 800; Clerks = 200; Icon = 'boi_model_dwellings.dds'
        Inputs = [ordered]@{ wood = 0.5; tools = 0.4; glass = 0.3; iron = 0.2 } }
    @{ Key = 'apartments'; Name = 'Apartment Blocks'; Group = 'bg_boi_apartment_housing'; GroupName = 'Apartment Housing'; Parent = 'dense'
        Desc = 'Steel-framed blocks that use far less infrastructure per household than anything older.'
        Tech = 'steel_frame_buildings'; Cost = 'construction_cost_low'; Basic = 10; Luxury = 1; Infra = 1.5; Labor = 750; Clerks = 250; Icon = 'boi_apartments.dds'
        Inputs = [ordered]@{ steel = 0.4; glass = 0.4; tools = 0.5; wood = 0.3 } }
    @{ Key = 'municipal_estates'; Name = 'Municipal Estates'; Group = 'bg_boi_municipal_housing'; GroupName = 'Municipal Housing'; Government = $true; NotDownsizeable = $true
        Desc = 'Council estates built and run by the state, paid from the treasury rather than waiting on investors. Only a council republic, or an economy without private capital, builds them. The best working-class housing there is. Staffing raises migration attraction.'
        Tech = 'socialism'; Cost = 'construction_cost_low'; Basic = 14; Luxury = 2; Infra = 1.25; Labor = 750; Clerks = 250; Icon = 'boi_municipal_estates.dds'
        Inputs = [ordered]@{ steel = 0.3; glass = 0.4; tools = 0.5; wood = 0.5 }; Possible = $HousingSocialistGate
        Scaled = [ordered]@{ state_migration_pull_mult = 0.004 } }
    @{ Key = 'elevator_apartments'; Name = 'Elevator Apartments'; Group = 'bg_boi_elevator_apartment_housing'; GroupName = 'Elevator Apartments'; Parent = 'dense'
        Desc = 'Tall electric-lift blocks, the densest housing there is. Needs a power plant in the state. Staffing raises migration attraction.'
        Tech = 'elevator'; Cost = 'construction_cost_medium'; Basic = 14; Luxury = 2; Infra = 1.5; Labor = 700; Clerks = 300; Icon = 'boi_elevator_apartments.dds'
        Inputs = [ordered]@{ steel = 0.6; glass = 0.5; tools = 0.5; electricity = 1 }; Possible = $HousingPowerPlantGate
        Scaled = [ordered]@{ state_migration_pull_mult = 0.003 } }
    # ---- Luxury ladder ----
    @{ Key = 'luxury_apartments'; Name = 'Town Houses'; Group = 'bg_boi_luxury_apartment_housing'; GroupName = 'Town Houses'; Parent = 'dense'
        Desc = 'Terraces and squares for the comfortable classes, with servants below stairs. Staffing raises migration attraction.'
        Cost = 'construction_cost_low'; Basic = 2.5; Luxury = 6; Infra = 2.5; Labor = 700; Clerks = 300; Icon = 'boi_luxury_apartments.dds'
        Inputs = [ordered]@{ wood = 0.8; tools = 0.5; glass = 0.8; furniture = 0.8 }
        Scaled = [ordered]@{ state_migration_pull_mult = 0.002 } }
    @{ Key = 'boulevard_apartments'; Name = 'Boulevard Apartments'; Group = 'bg_boi_boulevard_apartment_housing'; GroupName = 'Boulevard Apartments'; Parent = 'dense'
        Desc = 'Grand apartments on broad sewered avenues, in the manner of Haussmann. Staffing raises migration attraction.'
        Tech = 'modern_sewerage'; Cost = 'construction_cost_medium'; Basic = 3; Luxury = 6; Infra = 1.75; Labor = 700; Clerks = 300; Icon = 'boi_boulevard_apartments.dds'
        Inputs = [ordered]@{ wood = 0.5; tools = 0.5; glass = 0.8; furniture = 1; iron = 0.2 }
        Scaled = [ordered]@{ state_migration_pull_mult = 0.002 } }
    @{ Key = 'elevator_residences'; Name = 'Elevator Residences'; Group = 'bg_boi_elevator_residence_housing'; GroupName = 'Elevator Residences'; Parent = 'dense'
        Desc = 'Luxury towers with lifts and electric service. Needs a power plant in the state. Staffing raises migration attraction.'
        Tech = 'elevator'; Cost = 'construction_cost_high'; Basic = 3; Luxury = 8; Infra = 1.25; Labor = 700; Clerks = 300; Icon = 'boi_elevator_residences.dds'
        Inputs = [ordered]@{ steel = 0.4; tools = 0.5; glass = 0.8; luxury_furniture = 0.5; electricity = 1 }; Possible = $HousingPowerPlantGate
        Scaled = [ordered]@{ state_migration_pull_mult = 0.004 } }
    # ---- Suburban ladder: each commute is its own building ----
    @{ Key = 'suburbs'; Name = 'Carriage Villas'; Group = 'bg_boi_suburban_housing'; GroupName = 'Carriage Villas'; Parent = 'residential'
        Desc = 'Villas for those who keep a carriage. Spacious, and heavy on infrastructure. Staffing raises migration attraction.'
        Cost = 'construction_cost_low'; Basic = 2.5; Luxury = 6; Infra = 4; Labor = 800; Clerks = 200; Icon = 'boi_suburbs.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.2; glass = 0.2; furniture = 0.3; horses = 0.6 }
        Scaled = [ordered]@{ state_migration_pull_mult = 0.003 } }
    @{ Key = 'railway_suburbs'; Name = 'Railway Suburbs'; Group = 'bg_boi_railway_suburb_housing'; GroupName = 'Railway Suburbs'; Parent = 'residential'
        Desc = 'Commuter villas strung along a branch line. Staffing raises migration attraction.'
        Tech = 'railways'; Cost = 'construction_cost_low'; Basic = 3; Luxury = 6; Infra = 3; Labor = 800; Clerks = 200; Icon = 'boi_railway_suburbs.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.2; glass = 0.2; furniture = 0.3; transportation = 0.5 }
        Scaled = [ordered]@{ state_migration_pull_mult = 0.003 } }
    @{ Key = 'streetcar_suburbs'; Name = 'Streetcar Suburbs'; Group = 'bg_boi_streetcar_suburb_housing'; GroupName = 'Streetcar Suburbs'; Parent = 'residential'
        Desc = 'Affordable small-lot corridors along the electric streetcar, for working and middle-class families. Needs a power plant in the state. Staffing raises migration attraction.'
        Tech = 'electric_railway'; Cost = 'construction_cost_low'; Basic = 6; Luxury = 4; Infra = 2.5; Labor = 800; Clerks = 200; Icon = 'boi_streetcar_suburbs.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.3; glass = 0.3; furniture = 0.3; transportation = 0.5; electricity = 0.5 }; Possible = $HousingPowerPlantGate
        Scaled = [ordered]@{ state_migration_pull_mult = 0.003 } }
    @{ Key = 'motor_suburbs'; Name = 'Motor Suburbs'; Group = 'bg_boi_motor_suburb_housing'; GroupName = 'Motor Suburbs'; Parent = 'residential'
        Desc = 'Detached houses with a garage. A step back in density and a step up in comfort. Staffing raises migration attraction.'
        Tech = 'combustion_engine'; Cost = 'construction_cost_low'; Basic = 3; Luxury = 7; Infra = 3; Labor = 800; Clerks = 200; Icon = 'boi_motor_suburbs.dds'
        Inputs = [ordered]@{ wood = 0.6; tools = 0.3; glass = 0.3; furniture = 0.4; automobiles = 0.2 }
        Scaled = [ordered]@{ state_migration_pull_mult = 0.005 } }
    # ---- Emergency measure, outside the ladders ----
    @{ Key = 'temporary_shelter'; Name = 'Temporary Shelter Programme'; Group = 'bg_boi_temporary_housing'; GroupName = 'Emergency Housing'; Government = $true
        Desc = 'Publicly funded temporary accommodation consuming wood, fabric, tools, and treasury wages. It supplies basic housing but no luxury housing, and it does not permanently improve the housing stock.'
        Cost = 'construction_cost_low'; Basic = 4; Luxury = 0; Infra = 1.5; Labor = 900; Clerks = 100; Icon = 'boi_temporary_shelter.dds'
        Inputs = [ordered]@{ wood = 1; tools = 0.2; fabric = 1 }; Fuels = @() }
)
