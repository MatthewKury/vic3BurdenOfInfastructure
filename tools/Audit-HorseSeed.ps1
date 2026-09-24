param(
    [string]$Game = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game',
    [string]$ModPath,
    [string]$OutputPath = (Join-Path $PSScriptRoot 'horse_seed_audit.csv')
)

# Read-only audit of 1836 rural land available for Horse Ranch seeding.
$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$root = $ModPath
function Read-Data([string]$path) {
    return [regex]::Replace([IO.File]::ReadAllText($path), '(?m)#.*$', '')
}
function Get-Blocks([string]$data, [string]$keyPattern) {
    $pattern = '(?ms)(?<key>' + $keyPattern + ')\s*(?:\?=|=)\s*\{(?<body>(?:[^{}]|(?<open>\{)|(?<-open>\}))*)(?(open)(?!))\}'
    foreach ($m in [regex]::Matches($data, $pattern)) {
        [pscustomobject]@{ Key = $m.Groups['key'].Value; Body = $m.Groups['body'].Value }
    }
}
function Scalar([string]$body, [string]$key) {
    $m = [regex]::Match($body, '\b' + [regex]::Escape($key) + '\s*=\s*"?([^\s"{}]+)')
    if ($m.Success) { return $m.Groups[1].Value }
    return $null
}

$regions = @{}
foreach ($file in (Get-ChildItem (Join-Path $root 'map_data/state_regions') -Filter '*.txt')) {
    foreach ($block in (Get-Blocks (Read-Data $file.FullName) 'STATE_[A-Z0-9_]+')) {
        $regions[$block.Key] = [pscustomobject]@{
            Arable = [int](Scalar $block.Body 'arable_land')
            Traits = @([regex]::Matches(([regex]::Match($block.Body, 'traits\s*=\s*\{([^}]*)\}')).Groups[1].Value, 'state_trait_[a-z0-9_]+') | ForEach-Object Value)
        }
    }
}
$cultures = @{}
foreach ($file in (Get-ChildItem (Join-Path $Game 'common/country_definitions') -Filter '*.txt')) {
    foreach ($block in (Get-Blocks (Read-Data $file.FullName) '[A-Z0-9_]{3}')) {
        $m = [regex]::Match($block.Body, '\bcultures\s*=\s*\{([^}]*)\}')
        if ($m.Success) { $cultures[$block.Key] = @([regex]::Matches($m.Groups[1].Value, '[a-z][a-z_]+') | ForEach-Object Value) }
    }
}
$states = @{}
foreach ($block in (Get-Blocks (Read-Data (Join-Path $Game 'common/history/states/00_states.txt')) 's:STATE_[A-Z0-9_]+')) {
    $name = $block.Key.Substring(2)
    $owners = @()
    foreach ($create in (Get-Blocks $block.Body 'create_state')) {
        $owners += [pscustomobject]@{ Tag = (Scalar $create.Body 'country') -replace '^c:', ''; Unincorporated = $create.Body -match '\bstate_type\s*=\s*unincorporated' }
    }
    $homelands = @([regex]::Matches($block.Body, 'add_homeland\s*=\s*cu:([a-z_]+)') | ForEach-Object { $_.Groups[1].Value })
    if ($owners.Count) {
        $tag = $owners[0].Tag
        $core = @($cultures[$tag] | Where-Object { $_ -in $homelands }).Count -gt 0
        $states[$name] = [pscustomobject]@{ Owner = $tag; Owners = $owners.Count; Core = $core; Unincorporated = $owners[0].Unincorporated }
    }
}
$fixedRural = @{}
foreach ($file in (Get-ChildItem (Join-Path $Game 'common/history/buildings') -Filter '*.txt')) {
    foreach ($top in (Get-Blocks (Read-Data $file.FullName) 'BUILDINGS')) {
        foreach ($state in (Get-Blocks $top.Body 's:STATE_[A-Z0-9_]+')) {
            $name = $state.Key.Substring(2)
            foreach ($region in (Get-Blocks $state.Body 'region_state:[A-Z0-9_]+')) {
                foreach ($building in (Get-Blocks $region.Body 'create_building')) {
                    $type = Scalar $building.Body 'building'
                    if ($type -notmatch '^building_.*(_farm|_ranch|_plantation)$|^building_vineyard$') { continue }
                    $levels = 0
                    foreach ($m in [regex]::Matches($building.Body, '\blevels\s*=\s*(\d+)')) { $levels += [int]$m.Groups[1].Value }
                    if (-not $fixedRural.ContainsKey($name)) { $fixedRural[$name] = 0 }
                    $fixedRural[$name] += $levels
                }
            }
        }
    }
}
$existing = @{}
$seed = Read-Data (Join-Path $root 'common/history/buildings/zz_boi_buildings.txt')
foreach ($top in (Get-Blocks $seed 'BUILDINGS')) {
    foreach ($state in (Get-Blocks $top.Body 's:STATE_[A-Z0-9_]+')) {
        $name = $state.Key.Substring(2)
        foreach ($region in (Get-Blocks $state.Body 'region_state:[A-Z0-9_]+')) {
            foreach ($building in (Get-Blocks $region.Body 'create_building')) {
                if ((Scalar $building.Body 'building') -ne 'building_boi_horse_ranch') { continue }
                $levels = 0
                foreach ($m in [regex]::Matches($building.Body, '\blevels\s*=\s*(\d+)')) { $levels += [int]$m.Groups[1].Value }
                $existing[$name] = $levels
            }
        }
    }
}
$rows = foreach ($name in ($states.Keys | Sort-Object)) {
    $history = $states[$name]
    $region = $regions[$name]
    if (-not $region) { continue }
    $rural = [int]$fixedRural[$name]
    $ranch = [int]$existing[$name]
    [pscustomobject]@{
        State = $name; Owner = $history.Owner; Owners = $history.Owners
        Core = $history.Core; Unincorporated = $history.Unincorporated
        Arable = $region.Arable; FixedRural = $rural; Ranch = $ranch
        DeclaredHeadroom = $region.Arable - $rural - $ranch
        Traits = ($region.Traits -join ' ')
    }
}
$rows | Export-Csv $OutputPath -NoTypeInformation -Encoding UTF8
Write-Host "$($rows.Count) owned state regions audited -> $OutputPath"
