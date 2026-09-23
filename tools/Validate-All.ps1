[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$GamePath,
    [string]$ModPath,
    [string]$SeedInputsDirectory
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
& (Join-Path $PSScriptRoot 'Test-ModStructure.ps1') -ModPath $ModPath
& (Join-Path $PSScriptRoot 'Test-Seed.ps1') -ModPath $ModPath
& (Join-Path $PSScriptRoot 'Test-ShadowSources.ps1') -ModPath $ModPath -GamePath $GamePath
if ($SeedInputsDirectory) {
    & (Join-Path $PSScriptRoot 'Test-SeedReproducibility.ps1') -ModPath $ModPath `
        -PairsPath (Join-Path $SeedInputsDirectory 'pairs.txt') `
        -RanchPath (Join-Path $SeedInputsDirectory 'ranch.txt') `
        -OwnedRegionsPath (Join-Path $SeedInputsDirectory 'owned_regions.txt')
}
Write-Host 'PASS: all requested validation checks completed.'
