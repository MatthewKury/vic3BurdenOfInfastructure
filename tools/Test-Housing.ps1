[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$GamePath,
    [string]$ModPath
)
$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
. (Join-Path $PSScriptRoot 'Housing-ScriptTools.ps1')
function Assert-Housing {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
function Read-HousingDomain {
    param([string]$Root, [string]$Domain)
    $result = @{}
    $directory = Join-Path $Root "common/$Domain"
    if (Test-Path -LiteralPath $directory) {
        foreach ($file in (Get-ChildItem -LiteralPath $directory -Filter '*.txt' | Sort-Object Name)) {
            foreach ($block in (Get-HousingScriptBlocks ([IO.File]::ReadAllText($file.FullName)))) {
                Assert-Housing (-not $result.ContainsKey($block.Key)) "Duplicate $Domain key: $($block.Key)"
                $result[$block.Key] = $block.Text
            }
        }
    }
    return $result
}
function Child-HousingBlock {
    param([string]$Source, [string]$Key)
    $inner = $Source.Substring($Source.IndexOf('{') + 1)
    $inner = $inner.Substring(0, $inner.LastIndexOf('}'))
    $blocks = @(Get-HousingScriptBlocks $inner | Where-Object Key -eq $Key)
    Assert-Housing ($blocks.Count -eq 1) "Expected one $Key block."
    return $blocks[0].Text
}
function Housing-Number {
    param([string]$Source, [string]$Key)
    $match = [regex]::Match($Source, ('\b' + [regex]::Escape($Key) + '\s*=\s*(-?[0-9.]+)'))
    Assert-Housing $match.Success "Missing numeric value: $Key"
    return [double]::Parse($match.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
}
function Normalize-HousingScript {
    param([string]$Source)
    return ([regex]::Replace(([regex]::Replace($Source, '(?m)#[^\r\n]*', '')), '\s+', ''))
}

# Exercise the source reader with nested blocks, quoted braces and comments.
$readerFixture = @'
alpha = { text = "a } # b" nested = { value = 1 } } # ignored }
beta = { value = 2 }
'@
$readerBlocks = @(Get-HousingScriptBlocks $readerFixture)
Assert-Housing ($readerBlocks.Count -eq 2 -and $readerBlocks[1].Key -eq 'beta') 'Source parser failed quoted/comment brace fixture.'

# Housing is part of the main mod. Its script files are the ones named for
# housing, plus the generated buy-package file it owns.
$housingFiles = @(Get-ChildItem -LiteralPath (Join-Path $ModPath 'common'), (Join-Path $ModPath 'events'), (Join-Path $ModPath 'gui') -Recurse -File |
    Where-Object { $_.Extension -in '.txt', '.gui' -and ($_.Name -like '*housing*' -or $_.Directory.Name -eq 'buy_packages') })
Assert-Housing ($housingFiles.Count -eq 20) "Expected 20 housing script files, found $($housingFiles.Count); review the merged file set."

$pm = Read-HousingDomain $ModPath 'production_methods'
$pmg = Read-HousingDomain $ModPath 'production_method_groups'
$buildings = Read-HousingDomain $ModPath 'buildings'
$goods = Read-HousingDomain $ModPath 'goods'
$packages = Read-HousingDomain $ModPath 'buy_packages'
$vanillaPackages = Read-HousingDomain $GamePath 'buy_packages'
Assert-Housing ($packages.Count -eq 99) 'Every wealth level needs a demand package.'
$previousBasic = 0
$previousLuxury = 0
$previousTotal = 0
foreach ($wealth in 1..99) {
    $key = "wealth_$wealth"
    $source = $packages[$key]
    $basic = if ($source -match 'popneed_boi_housing') { Housing-Number $source 'popneed_boi_housing' } else { 0 }
    $luxury = if ($source -match 'popneed_boi_luxury_housing') { Housing-Number $source 'popneed_boi_luxury_housing' } else { 0 }
    $total = $basic + $luxury
    Assert-Housing ($basic -ge $previousBasic -and $luxury -ge $previousLuxury -and $total -ge $previousTotal) "Housing demand must not fall at wealth $wealth."
    $previousBasic = $basic
    $previousLuxury = $luxury
    $previousTotal = $total
    $core = 0.0
    foreach ($need in [regex]::Matches($vanillaPackages[$key], '(?m)^\s*popneed_\w+\s*=\s*([0-9.]+)')) {
        $core += [double]::Parse($need.Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture)
    }
    $share = $total / $core
    if ($wealth -le 4) { Assert-Housing ($total -eq 0) "Destitute wealth $wealth must have no housing demand." }
    if ($wealth -ge 5 -and $wealth -le 9) { Assert-Housing (($share * 1.75) -le 0.05) "Struggling wealth $wealth must stay within 5% at the price ceiling." }
    if ($wealth -ge 50) { Assert-Housing ([Math]::Abs($share - 0.15) -lt 0.001) "Wealth $wealth must sit on the 15% plateau." }
    if ($luxury -gt 0) { Assert-Housing ($basic -eq (10 + (2 * $wealth))) "Luxury housing must be additional to full basic demand at wealth $wealth." }
    $withoutHousing = [regex]::Replace($source, '(?m)^\s*popneed_boi_(?:luxury_)?housing\s*=\s*\d+[^\S\r\n]*\r?\n', '')
    Assert-Housing ((Normalize-HousingScript $withoutHousing) -eq (Normalize-HousingScript $vanillaPackages[$key])) "Non-housing buy package changed: $key"
}
foreach ($key in @('boi_housing', 'boi_luxury_housing')) {
    Assert-Housing ($goods.ContainsKey($key) -and $goods[$key] -match 'local\s*=\s*yes') "Housing must remain local: $key"
}

# Evaluate the actual PM's nested modifier blocks, including staffing and the
# crucial discontinuity between zero constructed slums and any slums present.
$state = Child-HousingBlock $pm['pm_boi_slums'] 'state_modifiers'
$scaled = Child-HousingBlock $state 'workforce_scaled'
$unscaled = Child-HousingBlock $state 'unscaled'
$mortality = Housing-Number $scaled 'state_mortality_mult'
$migration = Housing-Number $scaled 'state_migration_pull_mult'
$sol = Housing-Number $unscaled 'state_standard_of_living_add'
Assert-Housing ($mortality -gt 0 -and $migration -lt 0 -and $sol -lt 0) 'Slum effect signs are incorrect.'
foreach ($case in @(
    @{ levels=0; staffing=1.0; mortality=0.0; migration=0.0; sol=0.0 },
    @{ levels=1; staffing=1.0; mortality=0.001; migration=-0.002; sol=-1.0 },
    @{ levels=10; staffing=0.5; mortality=0.005; migration=-0.01; sol=-1.0 },
    @{ levels=20; staffing=0.0; mortality=0.0; migration=0.0; sol=-1.0 }
)) {
    $effectiveLevels = $case.levels * $case.staffing
    $actualSol = if ($case.levels -gt 0) { $sol } else { 0 }
    Assert-Housing ([Math]::Abs($effectiveLevels * $mortality - $case.mortality) -lt 0.000001) 'Slum mortality fixture failed.'
    Assert-Housing ([Math]::Abs($effectiveLevels * $migration - $case.migration) -lt 0.000001) 'Slum migration fixture failed.'
    Assert-Housing ($actualSol -eq $case.sol) 'Slum SoL must be flat and independent of staffing.'
}
foreach ($key in @('suburbs','luxury_apartments')) {
    $source = $pm["pm_boi_$key"]
    $workforce = Child-HousingBlock (Child-HousingBlock $source 'state_modifiers') 'workforce_scaled'
    Assert-Housing ((Housing-Number $workforce 'state_migration_pull_mult') -gt 0) 'Luxury migration bonus must scale with employment.'
    $output = Child-HousingBlock (Child-HousingBlock $source 'building_modifiers') 'workforce_scaled'
    Assert-Housing ((Housing-Number $output 'goods_output_boi_housing_add') -gt 0) 'Luxury buildings must also provide basic housing.'
    Assert-Housing ((Housing-Number $output 'goods_output_boi_luxury_housing_add') -gt 0) 'Missing luxury housing output.'
}
foreach ($key in @('slums','tenements','apartments','luxury_apartments','suburbs','temporary_shelter')) {
    $structure = Child-HousingBlock $pmg["pmg_boi_$key"] 'production_methods'
    $methods = [regex]::Matches($structure, '\bpm_boi_\w+\b')
    Assert-Housing ($methods.Count -eq 1) "Structural upgrade PMs are forbidden: $key"
}
Assert-Housing ($pm['pm_boi_no_company_housing'] -match 'is_default\s*=\s*yes') 'No Housing must be the default.'
Assert-Housing ($pm['pm_boi_no_company_housing'] -notmatch 'unlocking_|goods_|state_modifiers') 'No Housing must be unconditional and supply no housing.'
Assert-Housing ($pm['pm_boi_work_camp'] -notmatch 'state_modifiers') 'Work Camp penalties must not affect an entire state.'
Assert-Housing ($pm['pm_boi_work_camp'] -match 'unlocking_laws\s*=\s*\{\s*law_boi_unregulated_company_housing') 'Work Camp needs its separate law gate.'
# Each employer housing law permits No Housing plus exactly one tier.
$tierLaws = @{ work_camp = 'law_boi_unregulated_company_housing'; work_town = 'law_boi_protected_company_housing'; serviced_town = 'law_boi_mandated_serviced_housing' }
$tierEffects = @{ work_camp = 'boi_housing_enforce_work_camps_effect'; work_town = 'boi_housing_enforce_work_towns_effect'; serviced_town = 'boi_housing_enforce_serviced_towns_effect' }
$laws = Read-HousingDomain $ModPath 'laws'
$setup = [IO.File]::ReadAllText((Join-Path $ModPath 'common/scripted_effects/50_boi_housing.txt'))
foreach ($tier in $tierLaws.Keys) {
    $gate = [regex]::Match($pm["pm_boi_$tier"], 'unlocking_laws\s*=\s*\{([^{}]*)\}')
    Assert-Housing ($gate.Success -and ($gate.Groups[1].Value.Trim() -eq $tierLaws[$tier])) "$tier must be unlocked by exactly $($tierLaws[$tier])."
    Assert-Housing ($pm["pm_boi_$tier"] -notmatch 'disallowing_laws') "$tier must rely on its one unlocking law."
    Assert-Housing ($laws[$tierLaws[$tier]] -match ('on_activate\s*=\s*\{\s*' + $tierEffects[$tier])) "$($tierLaws[$tier]) must move paying tiers to $tier."
    Assert-Housing ($setup -match ('has_law\s*=\s*law_type:' + $tierLaws[$tier] + '\s*\}\s*' + $tierEffects[$tier])) "Monthly setup must enforce $tier under its law."
    Assert-Housing ($setup -match ('NOR\s*=\s*\{[^{}]*' + $tierLaws[$tier])) "Monthly setup must recognise $($tierLaws[$tier]) or it resets the law every month."
}
Assert-Housing ($pm['pm_boi_serviced_town'] -match 'unlocking_technologies\s*=\s*\{\s*modern_sewerage') 'Serviced Town must keep its technology gate.'
$mandate = $laws['law_boi_mandated_serviced_housing']
Assert-Housing ($mandate -match 'unlocking_technologies\s*=\s*\{\s*socialism') 'Mandatory Serviced Housing must unlock with Socialism.'
Assert-Housing ($mandate -notmatch 'can_enact') 'Mandatory Serviced Housing must stay enactable without Modern Sewerage.'
$enforcement = [IO.File]::ReadAllText((Join-Path $ModPath 'common/scripted_effects/zz_boi_housing_fallback_generated.txt'))
Assert-Housing ($enforcement -match 'has_technology_researched\s*=\s*modern_sewerage') 'The mandate must check for Modern Sewerage.'
foreach ($destination in @('pm_boi_work_camp', 'pm_boi_work_town', 'pm_boi_serviced_town', 'pm_boi_no_company_housing')) {
    Assert-Housing ($enforcement -match ('production_method\s*=\s*' + $destination)) "Generated enforcement must cover $destination."
}
# Higher tiers must use at least as much of every input, so the profit order
# Work Camp > Work Town > Serviced Town holds at any prices.
$tierOrder = @('work_camp', 'work_town', 'serviced_town')
foreach ($step in 0..1) {
    $lower = Child-HousingBlock (Child-HousingBlock $pm["pm_boi_$($tierOrder[$step])"] 'building_modifiers') 'workforce_scaled'
    $upper = Child-HousingBlock (Child-HousingBlock $pm["pm_boi_$($tierOrder[$step + 1])"] 'building_modifiers') 'workforce_scaled'
    foreach ($good in @('wood', 'fabric', 'tools')) {
        $inputKey = "goods_input_${good}_add"
        $lowerAmount = if ($lower -match $inputKey) { Housing-Number $lower $inputKey } else { 0 }
        $upperAmount = if ($upper -match $inputKey) { Housing-Number $upper $inputKey } else { 0 }
        Assert-Housing ($upperAmount -ge $lowerAmount) "$($tierOrder[$step + 1]) must use at least as much $good as $($tierOrder[$step])."
    }
}
# A Work Town houses as many workers as a Work Camp at half its penalties, for
# every profession. Serviced Towns carry no penalty.
$campBuilding = Child-HousingBlock $pm['pm_boi_work_camp'] 'building_modifiers'
$townBuilding = Child-HousingBlock $pm['pm_boi_work_town'] 'building_modifiers'
Assert-Housing ((Housing-Number (Child-HousingBlock $townBuilding 'workforce_scaled') 'goods_output_boi_housing_add') -eq (Housing-Number (Child-HousingBlock $campBuilding 'workforce_scaled') 'goods_output_boi_housing_add')) 'Work Town must supply the same housing as a Work Camp.'
$campPenalties = Child-HousingBlock $campBuilding 'unscaled'
$townPenalties = Child-HousingBlock $townBuilding 'unscaled'
$campPenaltyKeys = @([regex]::Matches($campPenalties, 'building_\w+_(?:standard_of_living_add|mortality_mult)') | ForEach-Object Value)
$townPenaltyKeys = @([regex]::Matches($townPenalties, 'building_\w+_(?:standard_of_living_add|mortality_mult)') | ForEach-Object Value)
Assert-Housing ($campPenaltyKeys.Count -eq 20 -and $townPenaltyKeys.Count -eq 20) 'Work Camp and Work Town must penalise all ten professions.'
foreach ($key in $campPenaltyKeys) {
    Assert-Housing ([Math]::Abs((Housing-Number $townPenalties $key) * 2 - (Housing-Number $campPenalties $key)) -lt 0.000001) "Work Town penalty must be half of Work Camp: $key"
}
Assert-Housing ($pm['pm_boi_serviced_town'] -notmatch 'standard_of_living|mortality') 'Serviced Town must carry no penalty.'
$servicedOutput = Housing-Number (Child-HousingBlock (Child-HousingBlock $pm['pm_boi_serviced_town'] 'building_modifiers') 'workforce_scaled') 'goods_output_boi_housing_add'
Assert-Housing ($servicedOutput -eq (Housing-Number (Child-HousingBlock $campBuilding 'workforce_scaled') 'goods_output_boi_housing_add')) 'Every housing tier must supply the same housing.'
Assert-Housing ($pm['pm_boi_slums'] -notmatch 'unlocking_laws') 'Residential law must not disable existing slum operation.'
Assert-Housing ($buildings['building_boi_slums'] -match 'possible\s*=\s*\{\s*owner\s*=\s*\{\s*NOT\s*=\s*\{\s*has_law\s*=\s*law_type:law_boi_residential_standards') 'New slums must be blocked by residential standards.'

# Each generated shadow must be its vanilla block plus the housing PM group.
# BOI's own Horse Ranch lists company housing by hand instead: a generated
# copy would sort first and replace BOI's definition.
$originalBuildings = Read-HousingDomain $GamePath 'buildings'
$generatedSource = [IO.File]::ReadAllText((Join-Path $ModPath 'common/buildings/00_boi_housing_rural_generated.txt'))
$ruralCount = 0
$subsistenceCount = 0
foreach ($block in (Get-HousingScriptBlocks $generatedSource)) {
    $key = $block.Key
    Assert-Housing ($originalBuildings.ContainsKey($key)) "Generated shadow of a non-vanilla building: $key"
    $source = $block.Text
    $ruralCount += [int]($source -match '\bpmg_boi_company_housing\b')
    $subsistenceCount += [int]($source -match '\bpmg_boi_subsistence_housing\b')
    $restored = [regex]::Replace($source, '(?m)^\s*pmg_boi_(?:company|subsistence)_housing\s*\r?\n', '')
    Assert-Housing ((Normalize-HousingScript $restored) -eq (Normalize-HousingScript $originalBuildings[$key])) "Unexpected rural override change: $key"
}
$ranch = [regex]::Replace($buildings['building_boi_horse_ranch'], '(?m)#[^\r\n]*', '')
Assert-Housing ($ranch -match 'production_method_groups\s*=\s*\{[^}]*\bpmg_boi_company_housing\b') 'The Horse Ranch must list pmg_boi_company_housing.'
$ruralCount++
Assert-Housing ($ruralCount -eq 27 -and $subsistenceCount -eq 5) 'Rural coverage changed; review expected supported buildings.'

# The 1836 seed places only buildings available at the start, for real starting owners.
$seed = [IO.File]::ReadAllText((Join-Path $ModPath 'common/history/buildings/zz_boi_housing_seed_generated.txt'))
Assert-Housing ($seed -notmatch 'building_boi_apartments|building_boi_temporary_shelter') 'The 1836 seed must not place Apartment Blocks or shelters.'
Assert-Housing ($seed -notmatch 'STATE_ALENTEJO') 'Alentejo stays unseeded: the housing fixtures build there.'

# Verify housing references resolve against game + BOI, including borrowed art.
$domains = @('goods','buildings','building_groups','production_methods','production_method_groups','laws','law_groups','technology/technologies','modifier_type_definitions')
$known = @{}
foreach ($domain in $domains) {
    $known[$domain] = @{}
    foreach ($root in @($GamePath,$ModPath)) {
        $definitions = Read-HousingDomain $root $domain
        foreach ($key in $definitions.Keys) { $known[$domain][$key] = $true }
    }
}
foreach ($file in $housingFiles) {
    $source = [IO.File]::ReadAllText($file.FullName)
    foreach ($match in [regex]::Matches($source, '(?:texture|icon|background)\s*=\s*"(gfx/[^"\r\n]+)"')) {
        $relative = $match.Groups[1].Value
        Assert-Housing ((Test-Path (Join-Path $GamePath $relative)) -or (Test-Path (Join-Path $ModPath $relative))) "Missing art: $relative"
    }
    foreach ($match in [regex]::Matches($source, '\bgoods_(?:input|output)_(\w+)_(?:add|mult)\s*=')) {
        Assert-Housing ($known['goods'].ContainsKey($match.Groups[1].Value)) "Unknown housing good reference: $($match.Value)"
    }
    foreach ($match in [regex]::Matches($source, '(?m)^\s*((?:goods_|building_|state_)\w+)\s*=\s*-?[0-9]')) {
        Assert-Housing ($known['modifier_type_definitions'].ContainsKey($match.Groups[1].Value)) "Undeclared modifier: $($match.Groups[1].Value)"
    }
    foreach ($reference in @(
        @{ pattern='\bbuilding_group\s*=\s*(\w+)'; domain='building_groups' },
        @{ pattern='\bparent_group\s*=\s*(\w+)'; domain='building_groups' },
        @{ pattern='\bbuilding_type\s*=\s*(\w+)'; domain='buildings' },
        @{ pattern='\b(?:production_method|has_active_production_method)\s*=\s*(\w+)'; domain='production_methods' },
        @{ pattern='\blaw_type:(\w+)'; domain='laws' }
    )) {
        foreach ($match in [regex]::Matches($source, $reference.pattern)) {
            Assert-Housing ($known[$reference.domain].ContainsKey($match.Groups[1].Value)) "Unknown $($reference.domain) reference: $($match.Value)"
        }
    }
    foreach ($reference in @(
        @{ list='unlocking_technologies'; domain='technology/technologies' },
        @{ list='unlocking_laws'; domain='laws' },
        @{ list='production_method_groups'; domain='production_method_groups' },
        @{ list='production_methods'; domain='production_methods' }
    )) {
        foreach ($match in [regex]::Matches($source, ('\b' + $reference.list + '\s*=\s*\{([^{}]*)\}'))) {
            foreach ($key in ($match.Groups[1].Value.Trim() -split '\s+')) {
                Assert-Housing ($known[$reference.domain].ContainsKey($key)) "Unknown $($reference.domain) list entry: $key"
            }
        }
    }
}

# Regeneration must be deterministic and must match committed generated files.
# The generator reads the mod root, which already holds its own output, so a
# match here also proves it does not feed its output back in.
$temporaryRoot = [IO.Path]::GetFullPath((Join-Path ([IO.Path]::GetTempPath()) ('boi-housing-test-' + [guid]::NewGuid().ToString('N'))))
try {
    & (Join-Path $PSScriptRoot 'Build-Housing.ps1') -GamePath $GamePath -ModPath $ModPath -OutputPath $temporaryRoot
    foreach ($file in Get-ChildItem $temporaryRoot -Recurse -File) {
        $relative = $file.FullName.Substring($temporaryRoot.Length + 1)
        $expected = Join-Path $ModPath $relative
        Assert-Housing ((Get-FileHash $file.FullName).Hash -eq (Get-FileHash $expected).Hash) "Stale generated housing file: $relative"
    }
    $firstHashes = @{}
    foreach ($file in Get-ChildItem $temporaryRoot -Recurse -File) { $firstHashes[$file.FullName] = (Get-FileHash $file.FullName).Hash }
    & (Join-Path $PSScriptRoot 'Build-Housing.ps1') -GamePath $GamePath -ModPath $ModPath -OutputPath $temporaryRoot
    foreach ($file in Get-ChildItem $temporaryRoot -Recurse -File) {
        Assert-Housing ($firstHashes[$file.FullName] -eq (Get-FileHash $file.FullName).Hash) 'Housing generation is not deterministic.'
    }
}
finally {
    $allowedTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    if ($temporaryRoot.StartsWith($allowedTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path $temporaryRoot -Leaf) -match '^boi-housing-test-[a-f0-9]{32}$' -and
        (Test-Path -LiteralPath $temporaryRoot)) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}
Write-Host 'PASS: housing demand, fixed structures, staffing/flat effects, law gates, rural preservation, asset/reference resolution, and deterministic generation. Runtime behavior remains unverified.'
