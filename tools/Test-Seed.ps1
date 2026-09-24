[CmdletBinding()]
param(
    [string]$ModPath,
    [int]$ExpectedHorseRanches = 225,
    [int]$ExpectedHorseRanchLevels = 857
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$seedPath = Join-Path $ModPath 'common/history/buildings/zz_boi_buildings.txt'
$planPath = Join-Path $ModPath 'tools/infrastructure_seed_plan.tsv'
$bytes = [IO.File]::ReadAllBytes($seedPath)
if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
    throw "Seed is missing its UTF-8 BOM: $seedPath"
}
$seed = [IO.File]::ReadAllText($seedPath)
$plan = foreach ($line in Get-Content -LiteralPath $planPath) {
    $parts = $line -split "`t"
    if ($parts.Count -ne 4 -or $parts[0] -notmatch '^STATE_' -or $parts[1] -notmatch '^[A-Z0-9_]+$' -or
        $parts[2] -notmatch '^\d+$' -or $parts[3] -notmatch '^\d+$' -or ([int]$parts[2] + [int]$parts[3]) -le 0) {
        throw "Malformed infrastructure seed plan line: $line"
    }
    [pscustomobject]@{ PublicWorks = [int]$parts[2]; HarbourWorks = [int]$parts[3] }
}
$expectedPublicWorks = @($plan | Where-Object PublicWorks -gt 0).Count
$expectedPublicWorksLevels = @($plan | Measure-Object PublicWorks -Sum).Sum
$expectedHarbourWorks = @($plan | Where-Object HarbourWorks -gt 0).Count
$expectedHarbourWorksLevels = @($plan | Measure-Object HarbourWorks -Sum).Sum
$checks = @{
    'Public Works' = @(([regex]::Matches($seed, 'building_boi_infrastructure')).Count, $expectedPublicWorks)
    'Harbour Works' = @(([regex]::Matches($seed, 'building_boi_harbour_works')).Count, $expectedHarbourWorks)
    'Horse Ranches' = @(([regex]::Matches($seed, 'building_boi_horse_ranch')).Count, $ExpectedHorseRanches)
}
$publicWorksLevels = 0
foreach ($match in [regex]::Matches($seed, 'building\s*=\s*"building_boi_infrastructure"[\s\S]*?levels\s*=\s*(\d+)')) {
    $publicWorksLevels += [int]$match.Groups[1].Value
}
if ($publicWorksLevels -ne $expectedPublicWorksLevels) {
    throw "Unexpected Public Works levels: $publicWorksLevels (expected $expectedPublicWorksLevels)."
}
$harbourWorksLevels = 0
foreach ($match in [regex]::Matches($seed, 'building\s*=\s*"building_boi_harbour_works"[\s\S]*?levels\s*=\s*(\d+)')) {
    $harbourWorksLevels += [int]$match.Groups[1].Value
}
if ($harbourWorksLevels -ne $expectedHarbourWorksLevels) {
    throw "Unexpected Harbour Works levels: $harbourWorksLevels (expected $expectedHarbourWorksLevels)."
}
foreach ($name in $checks.Keys) {
    if ($checks[$name][0] -ne $checks[$name][1]) {
        throw "Unexpected $name count: $($checks[$name][0]) (expected $($checks[$name][1]))"
    }
}
$horseLevels = 0
foreach ($match in [regex]::Matches($seed, 'building\s*=\s*"building_boi_horse_ranch"[\s\S]*?levels\s*=\s*(\d+)')) {
    $horseLevels += [int]$match.Groups[1].Value
}
if ($horseLevels -ne $ExpectedHorseRanchLevels) {
    throw "Unexpected Horse Ranch levels: $horseLevels (expected $ExpectedHorseRanchLevels)."
}
Write-Host "PASS: seed counts are $expectedPublicWorks Public Works ($publicWorksLevels levels), $expectedHarbourWorks Harbour Works ($harbourWorksLevels levels), and $ExpectedHorseRanches Horse Ranches ($horseLevels levels)."
