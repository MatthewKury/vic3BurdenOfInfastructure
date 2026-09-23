[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$PairsPath,
    [Parameter(Mandatory)] [string]$RanchPath,
    [Parameter(Mandatory)] [string]$OwnedRegionsPath,
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$awk = Get-Command awk -ErrorAction Stop
$previous = Get-Content -LiteralPath $OwnedRegionsPath
if ($previous -ne ($previous | Sort-Object)) {
    throw 'owned_regions.txt is not sorted. Regenerate it through tools/REGENERATE.md before testing reproducibility.'
}

$first = Join-Path $env:TEMP 'boi-seed-first.txt'
$second = Join-Path $env:TEMP 'boi-seed-second.txt'
try {
    & $awk.Source '-f' (Join-Path $ModPath 'tools/gen_seed.awk') $PairsPath $RanchPath $OwnedRegionsPath 1> $first
    if ($LASTEXITCODE -ne 0) { throw 'First seed generation failed.' }
    & $awk.Source '-f' (Join-Path $ModPath 'tools/gen_seed.awk') $PairsPath $RanchPath $OwnedRegionsPath 1> $second
    if ($LASTEXITCODE -ne 0) { throw 'Second seed generation failed.' }
    if (-not ((Get-FileHash -LiteralPath $first -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $second -Algorithm SHA256).Hash)) {
        throw 'Identical seed inputs produced different outputs.'
    }
    Write-Host 'PASS: identical seed inputs produce byte-for-byte identical output.'
}
finally {
    Remove-Item -LiteralPath $first, $second -Force -ErrorAction SilentlyContinue
}
