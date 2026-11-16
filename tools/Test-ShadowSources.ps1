[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$GamePath,
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$gameMethods = Join-Path $GamePath 'common/production_methods'
$gameCombat = Join-Path $GamePath 'common/combat_unit_types'
$gameMobilization = Join-Path $GamePath 'common/mobilization_options'
if (-not (Test-Path -LiteralPath $gameMethods)) { throw "Victoria 3 production methods not found under $GamePath" }
if (-not (Test-Path -LiteralPath $gameMobilization)) { throw "Victoria 3 mobilization options not found under $GamePath" }

# First-read-wins shadows (00_boi_*overrides), REPLACE: copies (*_replace) and
# INJECT: additions (*_inject*) all need their vanilla key to exist (2026-11-13, plan 10).
$shadowFiles = @(
    foreach ($folder in 'common/production_methods', 'common/combat_unit_types', 'common/mobilization_options') {
        foreach ($filter in '00_boi_*overrides.txt', '50_boi_*replace.txt', '50_boi_*inject*.txt') {
            Get-ChildItem -LiteralPath (Join-Path $ModPath $folder) -Filter $filter
        }
    }
)
$vanillaFiles = @(Get-ChildItem -LiteralPath $gameMethods, $gameCombat, $gameMobilization -Filter '*.txt' -File)
$count = 0
foreach ($file in $shadowFiles) {
    $source = Get-Content -LiteralPath $file.FullName -Raw
    $keys = [regex]::Matches($source, '(?m)^﻿?(?:REPLACE:|INJECT:)?([a-z][a-z0-9_]*)\s*=\s*\{') | ForEach-Object { $_.Groups[1].Value }
    foreach ($key in $keys) {
        # Files with a line starting with the key; \W? skips the BOM vanilla files open with.
        $hits = @($vanillaFiles | Select-String -Pattern "^\W?$key\s*=\s*\{" -List | Select-Object -ExpandProperty Path -Unique)
        if ($hits.Count -ne 1) { throw "Shadow key $key from $($file.Name) matched $($hits.Count) vanilla definitions." }
        $count++
    }
}
Write-Host "PASS: $count BOI shadow keys each match one installed vanilla definition. Review changed vanilla blocks after every patch."
