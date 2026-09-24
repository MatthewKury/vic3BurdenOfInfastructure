[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game',
    [string]$ModPath,
    [string]$OutputPath,
    [string]$PlanPath
)

# Full-staffing comparison of vanilla port/rail infrastructure with BOI's
# starting Public Works and Harbour Works, by state owner. Population, traits,
# technologies and other unchanged sources cancel out in this comparison.
$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
if (-not $OutputPath) { $OutputPath = Join-Path $PSScriptRoot 'starting_infrastructure_by_state.csv' }
if (-not $PlanPath) { $PlanPath = Join-Path $PSScriptRoot 'infrastructure_seed_plan.tsv' }

function Read-Data([string]$path) {
    $data = [IO.File]::ReadAllText($path).TrimStart([char]0xFEFF)
    return [regex]::Replace($data, '(?m)#.*$', '')
}
function Get-Blocks([string]$data, [string]$keyPattern) {
    $pattern = '(?ms)(?<key>' + $keyPattern + ')\s*(?:\?=|=)\s*\{(?<body>(?:[^{}]|(?<open>\{)|(?<-open>\}))*)(?(open)(?!))\}'
    foreach ($match in [regex]::Matches($data, $pattern)) {
        [pscustomobject]@{ Key = $match.Groups['key'].Value; Body = $match.Groups['body'].Value }
    }
}
function Scalar([string]$body, [string]$key) {
    $match = [regex]::Match($body, '\b' + [regex]::Escape($key) + '\s*=\s*"?([^\s"{}]+)')
    if ($match.Success) { return $match.Groups[1].Value }
    return $null
}
function New-Row([string]$state, [string]$owner) {
    [pscustomobject]@{
        State = $state; Owner = $owner; VanillaPortLevels = 0; VanillaRailLevels = 0
        VanillaPortInfrastructure = 0; VanillaRailInfrastructure = 0
        CurrentPublicWorksLevels = 0; CurrentHarbourWorksLevels = 0
    }
}

$rows = @{}
$harbourEligible = @{}
$statesPath = Join-Path $GamePath 'common/history/states/00_states.txt'
foreach ($stateBlock in (Get-Blocks (Read-Data $statesPath) 's:STATE_[A-Z0-9_]+')) {
    $state = $stateBlock.Key.Substring(2)
    foreach ($create in (Get-Blocks $stateBlock.Body 'create_state')) {
        $owner = (Scalar $create.Body 'country') -replace '^c:', ''
        if (-not $owner) { continue }
        $key = "$state|$owner"
        if (-not $rows.ContainsKey($key)) { $rows[$key] = New-Row $state $owner }
    }
}

foreach ($file in (Get-ChildItem (Join-Path $ModPath 'map_data/state_regions') -Filter '*.txt')) {
    foreach ($stateBlock in (Get-Blocks (Read-Data $file.FullName) 'STATE_[A-Z0-9_]+')) {
        if ($stateBlock.Body -match '\bport\s*=') { $harbourEligible[$stateBlock.Key] = $true }
    }
}

$rates = @{}
$vanillaMethods = Read-Data (Join-Path $GamePath 'common/production_methods/11_private_infrastructure.txt')
foreach ($pm in (Get-Blocks $vanillaMethods 'pm_[a-z0-9_]+')) {
    $match = [regex]::Match($pm.Body, '\bstate_infrastructure_add\s*=\s*([0-9.]+)')
    $rates[$pm.Key] = if ($match.Success) { [double]::Parse($match.Groups[1].Value, [cultureinfo]::InvariantCulture) } else { 0.0 }
}

$vanillaFiles = @(Get-ChildItem (Join-Path $GamePath 'common/history/buildings') -Filter '*.txt')
$modFiles = @(Get-Item (Join-Path $ModPath 'common/history/buildings/zz_boi_buildings.txt'))
$missingMethods = @()
foreach ($file in ($vanillaFiles + $modFiles)) {
    $isVanilla = $file.FullName -ne $modFiles[0].FullName
    foreach ($top in (Get-Blocks (Read-Data $file.FullName) 'BUILDINGS')) {
        foreach ($stateBlock in (Get-Blocks $top.Body 's:STATE_[A-Z0-9_]+')) {
            $state = $stateBlock.Key.Substring(2)
            foreach ($region in (Get-Blocks $stateBlock.Body 'region_state:[A-Z0-9_]+')) {
                $owner = $region.Key.Substring(13)
                $key = "$state|$owner"
                if (-not $rows.ContainsKey($key)) { throw "Building without starting state owner: $key" }
                foreach ($building in (Get-Blocks $region.Body 'create_building')) {
                    $type = Scalar $building.Body 'building'
                    if ($isVanilla -and $type -notin @('building_port', 'building_railway')) { continue }
                    if (-not $isVanilla -and $type -notin @('building_boi_infrastructure', 'building_boi_harbour_works')) { continue }
                    $levels = 0
                    foreach ($match in [regex]::Matches($building.Body, '\blevels\s*=\s*(\d+)')) {
                        $levels += [int]$match.Groups[1].Value
                    }
                    if ($isVanilla) {
                        $active = [regex]::Match($building.Body, '\bactivate_production_methods\s*=\s*\{([^}]*)\}')
                        $pm = $null
                        if ($active.Success) {
                            foreach ($name in [regex]::Matches($active.Groups[1].Value, '\bpm_[a-z0-9_]+\b')) {
                                if ($rates.ContainsKey($name.Value)) { $pm = $name.Value; break }
                            }
                        }
                        if (-not $pm) {
                            $missingMethods += "$key $type"
                            continue
                        }
                        if ($type -eq 'building_port') {
                            $rows[$key].VanillaPortLevels += $levels
                            $rows[$key].VanillaPortInfrastructure += $levels * $rates[$pm]
                        } else {
                            $rows[$key].VanillaRailLevels += $levels
                            $rows[$key].VanillaRailInfrastructure += $levels * $rates[$pm]
                        }
                    } elseif ($type -eq 'building_boi_infrastructure') {
                        $rows[$key].CurrentPublicWorksLevels += $levels
                    } else {
                        $rows[$key].CurrentHarbourWorksLevels += $levels
                    }
                }
            }
        }
    }
}
if ($missingMethods.Count) {
    throw "Starting ports/railways without a recognized transport method: $($missingMethods -join ', ')"
}

$out = foreach ($row in ($rows.Values | Sort-Object State, Owner)) {
    $vanilla = $row.VanillaPortInfrastructure + $row.VanillaRailInfrastructure
    $harbour = 10 * $row.CurrentHarbourWorksLevels
    $works = 15 * $row.CurrentPublicWorksLevels
    $best = $null
    $maxHarbour = if ($row.VanillaPortLevels -gt 0 -and $harbourEligible.ContainsKey($row.State)) { [int][math]::Ceiling($vanilla / 10) } else { 0 }
    for ($h = 0; $h -le $maxHarbour; $h++) {
        $p = [int][math]::Ceiling([math]::Max(0, $vanilla - 10 * $h) / 15)
        $output = 15 * $p + 10 * $h
        $candidate = [pscustomobject]@{ Public = $p; Harbour = $h; Output = $output; Excess = $output - $vanilla; Levels = $p + $h }
        if (-not $best -or $candidate.Excess -lt $best.Excess -or
            ($candidate.Excess -eq $best.Excess -and $candidate.Levels -lt $best.Levels) -or
            ($candidate.Excess -eq $best.Excess -and $candidate.Levels -eq $best.Levels -and $candidate.Harbour -lt $best.Harbour)) {
            $best = $candidate
        }
    }
    [pscustomobject]@{
        State = $row.State; Owner = $row.Owner
        VanillaPortLevels = $row.VanillaPortLevels
        VanillaRailLevels = $row.VanillaRailLevels
        VanillaPortInfrastructure = $row.VanillaPortInfrastructure
        VanillaRailInfrastructure = $row.VanillaRailInfrastructure
        VanillaTransportInfrastructure = $vanilla
        CurrentPublicWorksLevels = $row.CurrentPublicWorksLevels
        CurrentHarbourWorksLevels = $row.CurrentHarbourWorksLevels
        CurrentModInfrastructure = $works + $harbour
        PublicWorksLevelsToMatchVanillaWithCurrentHarbour = [int][math]::Ceiling([math]::Max(0, $vanilla - $harbour) / 15)
        PublicWorksLevelsToMatchVanillaWithoutHarbour = [int][math]::Ceiling($vanilla / 15)
        CurrentInfrastructureSurplus = $works + $harbour - $vanilla
        PlannedPublicWorksLevels = $best.Public
        PlannedHarbourWorksLevels = $best.Harbour
        PlannedModInfrastructure = $best.Output
        PlannedInfrastructureExcess = $best.Excess
    }
}
$out | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
$planLines = foreach ($row in $out) {
    if ($row.PlannedPublicWorksLevels -gt 0 -or $row.PlannedHarbourWorksLevels -gt 0) {
        "$($row.State)`t$($row.Owner)`t$($row.PlannedPublicWorksLevels)`t$($row.PlannedHarbourWorksLevels)"
    }
}
[IO.File]::WriteAllText($PlanPath, (($planLines -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))
Write-Host "$($out.Count) starting state-owner records -> $OutputPath"
Write-Host "$($planLines.Count) planned replacement state-owners -> $PlanPath"
