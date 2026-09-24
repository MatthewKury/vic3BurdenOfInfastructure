param(
    [string]$Game = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
)

# Static 1836 balance at full staffing. Markets, subsistence pastures, and
# dynamically created Urban Centers require an in-game measurement.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
& (Join-Path $PSScriptRoot 'Get-HorseConsumption.ps1') -Game $Game | Out-Host

function Get-Blocks([string]$data, [string]$keyPattern) {
    $pattern = '(?ms)(?<key>' + $keyPattern + ')\s*(?:\?=|=)\s*\{(?<body>(?:[^{}]|(?<open>\{)|(?<-open>\}))*)(?(open)(?!))\}'
    foreach ($m in [regex]::Matches($data, $pattern)) {
        [pscustomobject]@{ Key = $m.Groups['key'].Value; Body = $m.Groups['body'].Value }
    }
}

$pmFile = Join-Path $root 'common/production_methods/50_boi_horse_ranch.txt'
$pmText = [regex]::Replace([IO.File]::ReadAllText($pmFile).TrimStart([char]0xFEFF), '(?m)#.*$', '')
$rate = @{}
foreach ($pm in (Get-Blocks $pmText 'pm_boi_[A-Za-z0-9_]+')) {
    $m = [regex]::Match($pm.Body, '\bgoods_output_horses_add\s*=\s*([0-9.]+)')
    if ($m.Success) { $rate[$pm.Key] = [double]::Parse($m.Groups[1].Value, [cultureinfo]::InvariantCulture) }
}

$seedFile = Join-Path $root 'common/history/buildings/zz_boi_buildings.txt'
$seedText = [regex]::Replace([IO.File]::ReadAllText($seedFile).TrimStart([char]0xFEFF), '(?m)#.*$', '')
$production = @{}
$ranches = 0
$levelsTotal = 0
foreach ($top in (Get-Blocks $seedText 'BUILDINGS')) {
    foreach ($state in (Get-Blocks $top.Body 's:STATE_[A-Z0-9_]+')) {
        foreach ($region in (Get-Blocks $state.Body 'region_state:[A-Z0-9_]+')) {
            $key = $state.Key.Substring(2) + '|' + $region.Key.Substring(13)
            foreach ($building in (Get-Blocks $region.Body 'create_building')) {
                if ($building.Body -notmatch '\bbuilding\s*=\s*"?building_boi_horse_ranch\b') { continue }
                $levels = 0
                foreach ($m in [regex]::Matches($building.Body, '\blevels\s*=\s*(\d+)')) { $levels += [int]$m.Groups[1].Value }
                $pm = [regex]::Match($building.Body, '\bpm_boi_(?:open_pasture|selective_breeding|stud_farms)\b').Value
                if ($levels -le 0 -or -not $rate.ContainsKey($pm)) { throw "Cannot price Horse Ranch in $key" }
                if (-not $production.ContainsKey($key)) { $production[$key] = [pscustomobject]@{ Levels = 0; Horses = 0.0 } }
                $production[$key].Levels += $levels
                $production[$key].Horses += $levels * $rate[$pm]
                $ranches++
                $levelsTotal += $levels
            }
        }
    }
}

$consumption = @(Import-Csv (Join-Path $PSScriptRoot 'horse_consumption_1836.csv'))
$seen = @{}
$rows = foreach ($d in $consumption) {
    $key = $d.state + '|' + $d.owner
    if ($seen.ContainsKey($key)) { throw "Duplicate owner-state in demand: $key" }
    $seen[$key] = $true
    $supply = 0.0
    $levels = 0
    if ($production.ContainsKey($key)) {
        $supply = $production[$key].Horses
        $levels = $production[$key].Levels
    }
    $demand = [double]::Parse($d.total, [cultureinfo]::InvariantCulture)
    [pscustomobject]@{
        state = $d.state; owner = $d.owner; ranch_levels = $levels
        ranch_output = $supply; public_works = [double]$d.public_works
        haulage = [double]$d.haulage; farm_draft = [double]$d.farm_draft
        cavalry = [double]$d.cavalry; other_demand = [double]$d.urban_transport + [double]$d.other_buildings
        known_demand = $demand; balance = $supply - $demand
    }
}
foreach ($key in $production.Keys) {
    if (-not $seen.ContainsKey($key)) { throw "Ranch owner-state absent from consumption history: $key" }
}
$rows = @($rows | Sort-Object state,owner)
$statePath = Join-Path $PSScriptRoot 'horse_balance_1836_by_owner_state.csv'
$rows | Export-Csv $statePath -NoTypeInformation -Encoding UTF8

$countries = @(foreach ($group in ($rows | Group-Object owner | Sort-Object Name)) {
    $g = $group.Group
    [pscustomobject]@{
        owner = $group.Name
        ranch_levels = ($g | Measure-Object ranch_levels -Sum).Sum
        ranch_output = ($g | Measure-Object ranch_output -Sum).Sum
        public_works = ($g | Measure-Object public_works -Sum).Sum
        haulage = ($g | Measure-Object haulage -Sum).Sum
        farm_draft = ($g | Measure-Object farm_draft -Sum).Sum
        cavalry = ($g | Measure-Object cavalry -Sum).Sum
        other_demand = ($g | Measure-Object other_demand -Sum).Sum
        known_demand = ($g | Measure-Object known_demand -Sum).Sum
        balance = ($g | Measure-Object balance -Sum).Sum
    }
})
$countryPath = Join-Path $PSScriptRoot 'horse_balance_1836_by_country.csv'
$countries | Export-Csv $countryPath -NoTypeInformation -Encoding UTF8

$supplyTotal = ($rows | Measure-Object ranch_output -Sum).Sum
$demandTotal = ($rows | Measure-Object known_demand -Sum).Sum
$balanceTotal = $supplyTotal - $demandTotal
$balanceLabel = if ($balanceTotal -gt 0) { "+$balanceTotal" } else { "$balanceTotal" }
$deficits = @($countries | Where-Object balance -lt 0 | Sort-Object balance | Select-Object -First 12)
$surpluses = @($countries | Where-Object balance -gt 0 | Sort-Object balance -Descending | Select-Object -First 12)
$md = [collections.generic.list[string]]::new()
$md.Add('# 1836 horse production and consumption')
$md.Add('')
$md.Add('Static weekly estimate at full staffing and full cavalry strength, using the installed game history and current mod seed. These are goods units, not individual animals.')
$md.Add('')
$md.Add('| Source | Horses per week |')
$md.Add('| --- | ---: |')
$md.Add("| Horse Ranch production ($ranches ranches, $levelsTotal levels) | $supplyTotal |")
$md.Add("| Public Works consumption | $(($rows | Measure-Object public_works -Sum).Sum) |")
$md.Add("| Extraction haulage consumption | $(($rows | Measure-Object haulage -Sum).Sum) |")
$md.Add("| Crop farm draft consumption | $(($rows | Measure-Object farm_draft -Sum).Sum) |")
$md.Add("| Cavalry consumption | $(($rows | Measure-Object cavalry -Sum).Sum) |")
$md.Add("| Other known consumption | $(($rows | Measure-Object other_demand -Sum).Sum) |")
$md.Add("| **Known consumption** | **$demandTotal** |")
$md.Add("| **Ranch output minus known consumption** | **$balanceLabel** |")
$md.Add('')
$md.Add('Ranch output covers ' + [math]::Round(100 * $supplyTotal / $demandTotal, 1) + '% of known demand. The world total is not a playable market balance: goods move within markets, and subjects may share markets with other countries.')
$md.Add('')
$md.Add('## Largest country-level gaps')
$md.Add('')
$md.Add('Country tags aggregate owner states; they do not represent market boundaries.')
$md.Add('')
$md.Add('| Owner | Ranch output | Known demand | Difference |')
$md.Add('| --- | ---: | ---: | ---: |')
foreach ($c in $deficits) { $md.Add("| $($c.owner) | $($c.ranch_output) | $($c.known_demand) | $($c.balance) |") }
$md.Add('')
$md.Add('## Largest country-level surpluses')
$md.Add('')
$md.Add('| Owner | Ranch output | Known demand | Difference |')
$md.Add('| --- | ---: | ---: | ---: |')
foreach ($c in $surpluses) { $md.Add("| $($c.owner) | $($c.ranch_output) | $($c.known_demand) | +$($c.balance) |") }
$md.Add('')
$md.Add('## Scope')
$md.Add('')
$md.Add('The calculation multiplies seeded ranch levels by their activated PM output, and seeded building levels and cavalry counts by their horse inputs. It excludes output modifiers, subsistence pasture output, dynamically created Urban Center demand, staffing changes, and in-game market access. Therefore the signed difference is a baseline estimate, not an observed shortage or surplus. For the demand method and defaulted PMs, see [HORSE_CONSUMPTION_1836.md](HORSE_CONSUMPTION_1836.md).')
$md.Add('')
$md.Add('Detailed results: [owner-state CSV](horse_balance_1836_by_owner_state.csv) and [country CSV](horse_balance_1836_by_country.csv).')
$md.Add('')
$md.Add('Regenerate with `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Get-HorseBalance.ps1`.')
[IO.File]::WriteAllLines((Join-Path $PSScriptRoot 'HORSE_BALANCE_1836.md'), $md, [Text.UTF8Encoding]::new($false))
Write-Host "Horse Ranch output $supplyTotal - known demand $demandTotal = $balanceTotal horses/week"
Write-Host "Detailed balance: $statePath, $countryPath"
