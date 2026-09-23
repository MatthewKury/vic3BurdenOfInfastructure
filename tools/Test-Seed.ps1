[CmdletBinding()]
param(
    [string]$ModPath,
    [int]$ExpectedStates = 675,
    [int]$ExpectedPublicWorks = 675,
    [int]$ExpectedHarbourWorks = 372,
    [int]$ExpectedHorseRanches = 236
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$seedPath = Join-Path $ModPath 'common/history/buildings/zz_boi_buildings.txt'
$bytes = [IO.File]::ReadAllBytes($seedPath)
if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
    throw "Seed is missing its UTF-8 BOM: $seedPath"
}
$seed = [IO.File]::ReadAllText($seedPath)
$checks = @{
    'state blocks' = @(([regex]::Matches($seed, '(?m)^\ts:STATE_')).Count, $ExpectedStates)
    'Public Works' = @(([regex]::Matches($seed, 'building_boi_infrastructure')).Count, $ExpectedPublicWorks)
    'Harbour Works' = @(([regex]::Matches($seed, 'building_boi_harbour_works')).Count, $ExpectedHarbourWorks)
    'Horse Ranches' = @(([regex]::Matches($seed, 'building_boi_horse_ranch')).Count, $ExpectedHorseRanches)
}
foreach ($name in $checks.Keys) {
    if ($checks[$name][0] -ne $checks[$name][1]) {
        throw "Unexpected $name count: $($checks[$name][0]) (expected $($checks[$name][1]))"
    }
}
Write-Host "PASS: seed counts are $ExpectedStates states, $ExpectedPublicWorks Public Works, $ExpectedHarbourWorks Harbour Works, and $ExpectedHorseRanches Horse Ranches."
