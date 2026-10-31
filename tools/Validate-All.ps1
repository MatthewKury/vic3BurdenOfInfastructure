[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$GamePath,
    [string]$ModPath,
    [string]$SeedInputsDirectory,
    [string]$CmfPath,
    [switch]$Headless,
    [string]$HeadlessUntilDate = '1837.1.1'
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
& (Join-Path $PSScriptRoot 'Test-ModStructure.ps1') -ModPath $ModPath
& (Join-Path $PSScriptRoot 'Test-Seed.ps1') -ModPath $ModPath
& (Join-Path $PSScriptRoot 'Test-HorseSeedSafety.ps1') -GamePath $GamePath -ModPath $ModPath
& (Join-Path $PSScriptRoot 'Test-ShadowSources.ps1') -ModPath $ModPath -GamePath $GamePath
& (Join-Path $PSScriptRoot 'Test-Housing.ps1') -ModPath $ModPath -GamePath $GamePath
if ($CmfPath) {
    & (Join-Path $PSScriptRoot 'Test-CMFCompatibility.ps1') -ModPath $ModPath -CmfPath $CmfPath
}
if ($SeedInputsDirectory) {
    & (Join-Path $PSScriptRoot 'Test-SeedReproducibility.ps1') -ModPath $ModPath `
        -PairsPath (Join-Path $SeedInputsDirectory 'pairs.txt') `
        -RanchPath (Join-Path $SeedInputsDirectory 'ranch.txt') `
        -OwnedRegionsPath (Join-Path $SeedInputsDirectory 'owned_regions.txt')
}
if ($Headless) {
    & (Join-Path $PSScriptRoot 'Test-Headless.ps1') -ModPath $ModPath -GamePath $GamePath -UntilDate $HeadlessUntilDate
    if ($LASTEXITCODE) { throw "Headless run failed (exit $LASTEXITCODE); see tools/headless-runs/." }
}
Write-Host 'PASS: all requested validation checks completed.'
