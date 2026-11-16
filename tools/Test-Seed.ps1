[CmdletBinding()]
param(
    [string]$ModPath,
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game',
    [int]$ExpectedHorseRanches = 223,      # 1.15 balance passes 3 (Bihar, Shandong, Beijing, East Java) and 4 (Midlands, East Anglia, West Country)
    [int]$ExpectedHorseRanchLevels = 525   # 491 after the 1.15.0 patch (Semireche out, Kostroma in), +20 in pass 3, +14 in pass 4
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$seedPath = Join-Path $ModPath 'common/history/buildings/zz_boi_buildings.txt'
$bytes = [IO.File]::ReadAllBytes($seedPath)
if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
    throw "Seed is missing its UTF-8 BOM: $seedPath"
}
$seed = [IO.File]::ReadAllText($seedPath)

# Road, Rail and Harbour Works were retired on 2026-11-13 (plan 12); none may be seeded.
foreach ($retired in 'building_boi_infrastructure', 'building_boi_rail_works', 'building_boi_harbour_works') {
    if ($seed -match $retired) { throw "Retired building still seeded: $retired" }
}
$horseRanches = ([regex]::Matches($seed, 'building_boi_horse_ranch')).Count
if ($horseRanches -ne $ExpectedHorseRanches) {
    throw "Unexpected Horse Ranch count: $horseRanches (expected $ExpectedHorseRanches)"
}
$horseLevels = 0
foreach ($match in [regex]::Matches($seed, 'building\s*=\s*"building_boi_horse_ranch"[\s\S]*?levels\s*=\s*(\d+)')) {
    $horseLevels += [int]$match.Groups[1].Value
}
if ($horseLevels -ne $ExpectedHorseRanchLevels) {
    throw "Unexpected Horse Ranch levels: $horseLevels (expected $ExpectedHorseRanchLevels)."
}

# Public Works hub seed (plan 12, tools/Build-PublicWorksSeed.py): one staffed hub for
# every state at the 1836 start, coastal only where vanilla seeds a port.
$hubPath = Join-Path $ModPath 'common/history/buildings/zz_boi_public_works_seed_generated.txt'
$hub = [IO.File]::ReadAllText($hubPath)
$pairs = @{}
$state = $null
foreach ($line in ($hub -split "`n")) {
    if ($line -match '^\s*s:(STATE_[A-Z0-9_]+)\s*=') { $state = $Matches[1] }
    elseif ($line -match '^\s*region_state:([A-Z0-9_]+)\s*=') {
        $key = "$state/$($Matches[1])"
        if ($pairs.ContainsKey($key)) { throw "Public Works seeded twice: $key" }
        $pairs[$key] = $true
    }
}
$hubs = ([regex]::Matches($hub, 'building = "building_boi_(?:coastal_)?public_works"')).Count
$coastal = ([regex]::Matches($hub, 'building = "building_boi_coastal_public_works"')).Count
if ($hubs -ne $pairs.Count) { throw "Public Works seed: $hubs hubs for $($pairs.Count) state-owners." }
if ($GamePath -and (Test-Path -LiteralPath $GamePath)) {
    # Strip comments: vanilla comments out some create_state blocks (Kanto's second owner).
    $states = [IO.File]::ReadAllText((Join-Path $GamePath 'common/history/states/00_states.txt')) -replace '#[^\r\n]*', ''
    $vanillaPairs = @{}
    foreach ($block in [regex]::Matches($states, 's:(STATE_[A-Z0-9_]+)\s*=\s*\{(?<body>(?:[^{}]|(?<o>\{)|(?<-o>\}))*)\}')) {
        foreach ($cs in [regex]::Matches($block.Groups['body'].Value, 'country\s*=\s*c:([A-Z0-9_]+)')) {
            $vanillaPairs["$($block.Groups[1].Value)/$($cs.Groups[1].Value)"] = $true
        }
    }
    $missing = @($vanillaPairs.Keys | Where-Object { -not $pairs.ContainsKey($_) })
    if ($missing.Count) { throw "Public Works seed misses $($missing.Count) starting states, e.g. $($missing[0]). Re-run tools/Build-PublicWorksSeed.py." }
}
Write-Host "PASS: seed has $horseRanches Horse Ranches ($horseLevels levels), no retired works, and $hubs Public Works hubs ($coastal coastal), one per starting state."
