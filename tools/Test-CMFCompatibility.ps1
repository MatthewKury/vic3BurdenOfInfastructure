[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$CmfPath,
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$cmfMetadataPath = Join-Path $CmfPath '.metadata/metadata.json'
if (-not (Test-Path -LiteralPath $cmfMetadataPath)) {
    throw "CMF metadata was not found: $cmfMetadataPath"
}
$cmfMetadata = Get-Content -LiteralPath $cmfMetadataPath -Raw | ConvertFrom-Json
if ($cmfMetadata.id -ne 'com.github.Victoria-3-Modding-Co-op.Community-Mod-Framework') {
    throw "The supplied path is not Community Mod Framework: $CmfPath"
}

function Get-RelativeFiles([string]$Root) {
    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        $_.FullName.Substring($Root.Length + 1).Replace('\', '/')
    }
}
function Get-DefinitionKeys([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return @() }
    Get-ChildItem -LiteralPath $Path -Recurse -File -Filter '*.txt' | ForEach-Object {
        [regex]::Matches((Get-Content -LiteralPath $_.FullName -Raw), '(?m)^([a-z][a-z0-9_]*)\s*=\s*\{') |
            ForEach-Object { $_.Groups[1].Value }
    }
}

$modFiles = Get-RelativeFiles $ModPath | Where-Object { $_ -notmatch '^\.metadata/' }
$cmfFiles = Get-RelativeFiles $CmfPath | Where-Object { $_ -notmatch '^\.metadata/' }
$fileConflicts = Compare-Object $modFiles $cmfFiles -IncludeEqual -ExcludeDifferent |
    ForEach-Object InputObject
if ($fileConflicts) {
    throw "CMF and BOI share game-data paths: $($fileConflicts -join ', ')"
}

$keyConflicts = @()
$modCommon = Join-Path $ModPath 'common'
Get-ChildItem -LiteralPath $modCommon -Directory | ForEach-Object {
    $domain = $_.Name
    $modKeys = @(Get-DefinitionKeys $_.FullName | Sort-Object -Unique)
    $cmfKeys = @(Get-DefinitionKeys (Join-Path $CmfPath "common/$domain") | Sort-Object -Unique)
    $shared = Compare-Object $modKeys $cmfKeys -IncludeEqual -ExcludeDifferent |
        ForEach-Object InputObject
    foreach ($key in $shared) { $keyConflicts += "common/$domain/$key" }
}
if ($keyConflicts) {
    throw "CMF and BOI define the same game keys: $($keyConflicts -join ', ')"
}

Write-Host "PASS: BOI has no game-data path or common-definition key conflicts with CMF $($cmfMetadata.version)."
