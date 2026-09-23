[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$GamePath,
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$gameMethods = Join-Path $GamePath 'common/production_methods'
$gameCombat = Join-Path $GamePath 'common/combat_unit_types'
if (-not (Test-Path -LiteralPath $gameMethods)) { throw "Victoria 3 production methods not found under $GamePath" }

$shadowFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $ModPath 'common/production_methods') -Filter '00_boi_*overrides.txt'
    Get-ChildItem -LiteralPath (Join-Path $ModPath 'common/combat_unit_types') -Filter '00_boi_*overrides.txt'
)
$count = 0
foreach ($file in $shadowFiles) {
    $source = Get-Content -LiteralPath $file.FullName -Raw
    $keys = [regex]::Matches($source, '(?m)^([a-z][a-z0-9_]*)\s*=\s*\{') | ForEach-Object { $_.Groups[1].Value }
    foreach ($key in $keys) {
        $matches = @(rg -l --glob '*.txt' "(?m)^$key\s*=\s*\{" $gameMethods $gameCombat)
        if ($matches.Count -ne 1) { throw "Shadow key $key from $($file.Name) matched $($matches.Count) vanilla definitions." }
        $count++
    }
}
Write-Host "PASS: $count BOI shadow keys each match one installed vanilla definition. Review changed vanilla blocks after every patch."
