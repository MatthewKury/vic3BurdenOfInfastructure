[CmdletBinding()]
param([string]$ModPath)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$scriptFiles = Get-ChildItem -LiteralPath $ModPath -Recurse -File |
    Where-Object { $_.Extension -in '.txt', '.yml' }

if ($scriptFiles.Count -eq 0) { throw "No game script or localization files found in $ModPath" }

foreach ($file in $scriptFiles) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        throw "Missing UTF-8 BOM: $($file.FullName)"
    }

    if ($file.Extension -eq '.txt') {
        $source = [IO.File]::ReadAllText($file.FullName)
        $source = [regex]::Replace($source, '(?m)#.*$', '')
        $depth = 0
        foreach ($character in $source.ToCharArray()) {
            if ($character -eq '{') { $depth++ }
            elseif ($character -eq '}') { $depth-- }
            if ($depth -lt 0) { throw "Extra closing brace: $($file.FullName)" }
        }
        if ($depth -ne 0) { throw "Unbalanced braces ($depth): $($file.FullName)" }
    }
}

$descriptor = Get-Content -LiteralPath (Join-Path $ModPath 'descriptor.mod') -Raw
$metadata = Get-Content -LiteralPath (Join-Path $ModPath '.metadata/metadata.json') -Raw
$descriptorVersion = [regex]::Match($descriptor, '(?m)^version="([^"]+)"').Groups[1].Value
$metadataVersion = [regex]::Match($metadata, '"version"\s*:\s*"([^"]+)"').Groups[1].Value
if ($descriptorVersion -ne $metadataVersion) {
    Write-Warning "Version mismatch: descriptor.mod=$descriptorVersion; metadata=$metadataVersion"
}

Write-Host "PASS: $($scriptFiles.Count) files have UTF-8 BOMs; all .txt files have balanced braces."
