param(
    [string]$Game = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
)

# Static 1836 full-staffing estimate from vanilla history and the mod's PMs.
# Run: powershell -File tools/Get-HorseConsumption.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$output = Join-Path $PSScriptRoot 'horse_consumption_1836.csv'
$stateOutput = Join-Path $PSScriptRoot 'horse_consumption_1836_by_state.csv'

function Read-Data([string]$path) {
    $data = [IO.File]::ReadAllText($path)
    $data = $data.TrimStart([char]0xFEFF)
    return [regex]::Replace($data, '(?m)#.*$', '')
}

function Get-Blocks([string]$data, [string]$keyPattern) {
    # .NET balancing groups allow nested Paradox script blocks.
    $pattern = '(?ms)(?<key>' + $keyPattern + ')\s*(?:\?=|=)\s*\{(?<body>(?:[^{}]|(?<open>\{)|(?<-open>\}))*)(?(open)(?!))\}'
    foreach ($m in [regex]::Matches($data, $pattern)) {
        [pscustomobject]@{ Key = $m.Groups['key'].Value; Body = $m.Groups['body'].Value }
    }
}

function Get-Scalar([string]$data, [string]$key) {
    $m = [regex]::Match($data, '\b' + [regex]::Escape($key) + '\s*=\s*"?([^\s"{}]+)')
    if ($m.Success) { return $m.Groups[1].Value }
    return $null
}

$rates = @{}
Get-ChildItem (Join-Path $root 'common/production_methods') -Filter '*.txt' | ForEach-Object {
    foreach ($block in (Get-Blocks (Read-Data $_.FullName) 'pm_[A-Za-z0-9_]+')) {
        $m = [regex]::Match($block.Body, '\bgoods_input_horses_add\s*=\s*([0-9.]+)')
        if ($m.Success) { $rates[$block.Key] = [double]::Parse($m.Groups[1].Value, [cultureinfo]::InvariantCulture) }
    }
}

$values = @{}
$owners = @{}
$defaulted = @{}
$categories = @('public_works','haulage','farm_draft','urban_transport','other_buildings','cavalry')
function Add-Value([string]$state, [string]$owner, [string]$category, [double]$amount) {
    $key = "$state|$owner"
    if (-not $values.ContainsKey($key)) {
        $values[$key] = @{}
        foreach ($c in $categories) { $values[$key][$c] = 0.0 }
    }
    $values[$key][$category] += $amount
}

$files = @(Get-ChildItem (Join-Path $Game 'common/history/buildings') -Filter '*.txt') + @(Get-Item (Join-Path $root 'common/history/buildings/zz_boi_buildings.txt'))
foreach ($file in $files) {
    foreach ($top in (Get-Blocks (Read-Data $file.FullName) 'BUILDINGS')) {
        foreach ($stateBlock in (Get-Blocks $top.Body 's:STATE_[A-Z0-9_]+')) {
            $state = $stateBlock.Key.Substring(2)
            if (-not $owners.ContainsKey($state)) { $owners[$state] = @{} }
            foreach ($region in (Get-Blocks $stateBlock.Body 'region_state:[A-Z0-9_]+')) {
                $owner = $region.Key.Substring(13)
                $owners[$state][$owner] = $true
                foreach ($building in (Get-Blocks $region.Body 'create_building')) {
                    $type = Get-Scalar $building.Body 'building'
                    if (-not $type) { continue }
                    $levels = 0
                    foreach ($m in [regex]::Matches($building.Body, '\blevels\s*=\s*(\d+)')) { $levels += [int]$m.Groups[1].Value }
                    if ($levels -eq 0) { continue }
                    $horsePmFound = $false
                    foreach ($pms in (Get-Blocks $building.Body 'activate_production_methods')) {
                        foreach ($pm in [regex]::Matches($pms.Body, '\bpm_[A-Za-z0-9_]+\b')) {
                            $name = $pm.Value
                            if (-not $rates.ContainsKey($name)) { continue }
                            $horsePmFound = $true
                            $category = 'other_buildings'
                            if ($type -eq 'building_boi_infrastructure') { $category = 'public_works' }
                            elseif ($name -eq 'pm_road_carts' -or $name -match 'rail_transport|tanker_cars') { $category = 'haulage' }
                            elseif ($name -in @('pm_tools_disabled','pm_tools','pm_tools_building_rice_farm')) { $category = 'farm_draft' }
                            elseif ($name -eq 'pm_no_public_transport') { $category = 'urban_transport' }
                            Add-Value $state $owner $category ($levels * $rates[$name])
                        }
                    }
                    # When a history record omits a PM group, its first method is active.
                    if (-not $horsePmFound -and $type -match '^building_(rye|wheat|rice|maize|millet)_farm$|^building_.*(_mine|_plantation)$|^building_(logging_camp|oil_rig|vineyard)$') {
                        $pmText = (@(Get-Blocks $building.Body 'activate_production_methods') | ForEach-Object Body) -join ' '
                        $isFarm = $type -match '^building_(rye|wheat|rice|maize|millet)_farm$'
                        $groupPmPresent = if ($isFarm) { $pmText -match '\bpm_(tools|steam_threshers|tractors)' } else { $pmText -match '\bpm_(road_carts|.*rail_transport|tanker_cars|log_carts)' }
                        if (-not $groupPmPresent) {
                            $category = if ($isFarm) { 'farm_draft' } else { 'haulage' }
                            $rate = if ($isFarm) { 2 } else { 3 }
                            Add-Value $state $owner $category ($levels * $rate)
                            if (-not $defaulted.ContainsKey($type)) { $defaulted[$type] = 0 }
                            $defaulted[$type] += $levels
                        }
                    }
                }
            }
        }
    }
}

$cavalryRates = @{}
foreach ($unit in (Get-Blocks (Read-Data (Join-Path $root 'common/combat_unit_types/00_boi_cavalry_overrides.txt')) 'combat_unit_type_[A-Za-z0-9_]+')) {
    $m = [regex]::Match($unit.Body, '\bgoods_input_horses_add\s*=\s*([0-9.]+)')
    if ($m.Success) { $cavalryRates[$unit.Key] = [double]::Parse($m.Groups[1].Value, [cultureinfo]::InvariantCulture) }
}
foreach ($file in (Get-ChildItem (Join-Path $Game 'common/history/military_formations') -Filter '*.txt')) {
    foreach ($top in (Get-Blocks (Read-Data $file.FullName) 'MILITARY_FORMATIONS')) {
        foreach ($country in (Get-Blocks $top.Body 'c:[A-Z0-9_]+')) {
            $owner = $country.Key.Substring(2)
            foreach ($formation in (Get-Blocks $country.Body 'create_military_formation')) {
                foreach ($unit in (Get-Blocks $formation.Body 'combat_unit')) {
                    $type = (Get-Scalar $unit.Body 'type') -replace '^unit_type:', ''
                    $state = (Get-Scalar $unit.Body 'state_region') -replace '^s:', ''
                    $count = Get-Scalar $unit.Body 'count'
                    if ($state -and $count -and $cavalryRates.ContainsKey($type)) {
                        if (-not $owners.ContainsKey($state)) { $owners[$state] = @{} }
                        $owners[$state][$owner] = $true
                        Add-Value $state $owner 'cavalry' ([int]$count * $cavalryRates[$type])
                    }
                }
            }
        }
    }
}

foreach ($key in $values.Keys) {
    $parts = $key.Split('|')
    if (-not $owners.ContainsKey($parts[0]) -or -not $owners[$parts[0]].ContainsKey($parts[1])) {
        throw "Horse demand has no matching owner-state history row: $key"
    }
}

$rows = foreach ($state in ($owners.Keys | Sort-Object)) {
    foreach ($owner in ($owners[$state].Keys | Sort-Object)) {
        $key = "$state|$owner"
        $v = $values[$key]
        if (-not $v) {
            $v = @{}
            foreach ($c in $categories) { $v[$c] = 0.0 }
        }
        [pscustomobject]@{
            state = $state; owner = $owner
            public_works = $v.public_works; haulage = $v.haulage
            farm_draft = $v.farm_draft; urban_transport = $v.urban_transport
            other_buildings = $v.other_buildings; cavalry = $v.cavalry
            total = ($categories | ForEach-Object { $v[$_] } | Measure-Object -Sum).Sum
        }
    }
}
$rows | Export-Csv -Path $output -NoTypeInformation -Encoding UTF8
$stateRows = foreach ($group in ($rows | Group-Object state | Sort-Object Name)) {
    $record = [ordered]@{ state = $group.Name }
    foreach ($category in $categories) {
        $record[$category] = ($group.Group | Measure-Object -Property $category -Sum).Sum
    }
    $record['total'] = ($group.Group | Measure-Object -Property total -Sum).Sum
    [pscustomobject]$record
}
$stateRows | Export-Csv -Path $stateOutput -NoTypeInformation -Encoding UTF8
Write-Host "$($rows.Count) owner-state rows across $($owners.Count) states -> $output"
Write-Host "$($stateRows.Count) state rows -> $stateOutput"
if ($defaulted.Count) { Write-Host "Defaulted horse PM levels: $($defaulted | ConvertTo-Json -Compress)" }
$rows | Measure-Object public_works,haulage,farm_draft,urban_transport,other_buildings,cavalry,total -Sum | Select-Object Property,Sum | Format-Table
