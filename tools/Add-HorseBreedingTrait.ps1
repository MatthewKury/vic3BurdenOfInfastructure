# Reapply the horse-specific trait after regenerating map_data/state_regions.
# Safe to rerun: an existing assignment is left intact.
$ErrorActionPreference = 'Stop'
$regions = Join-Path (Split-Path $PSScriptRoot -Parent) 'map_data/state_regions'
$trait = 'state_trait_boi_horse_breeding_traditions'
$targetStates = @(
    'STATE_URGA', 'STATE_ULIASTAI',
    'STATE_AKMOLINSK', 'STATE_AKTOBE', 'STATE_SEMIRECHE',
    'STATE_ROSTOV', 'STATE_KUBAN', 'STATE_KALMYKIA',
    'STATE_BEKES',
    'STATE_NEJD', 'STATE_HAIL', 'STATE_SYRIA'
)
$seen = @{}
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

foreach ($file in (Get-ChildItem $regions -Filter '*.txt')) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $data = [IO.File]::ReadAllText($file.FullName)
    $stateMatches = [regex]::Matches($data, '(?m)^STATE_[A-Z0-9_]+\s*=\s*\{')
    $edits = @()
    for ($i = 0; $i -lt $stateMatches.Count; $i++) {
        $name = [regex]::Match($stateMatches[$i].Value, 'STATE_[A-Z0-9_]+').Value
        if ($name -notin $targetStates) { continue }
        if ($seen.ContainsKey($name)) { throw "Duplicate state: $name" }
        $seen[$name] = $true
        $start = $stateMatches[$i].Index
        $end = if ($i + 1 -lt $stateMatches.Count) { $stateMatches[$i + 1].Index } else { $data.Length }
        $body = $data.Substring($start, $end - $start)
        $match = [regex]::Match($body, '(?m)^\s*traits\s*=\s*\{[^}\r\n]*\}')
        if (-not $match.Success) { throw "Missing one-line traits assignment for $name" }
        if ($match.Value.Contains('"' + $trait + '"')) { continue }
        $replacement = $match.Value.Substring(0, $match.Value.LastIndexOf('}')).TrimEnd() + ' "' + $trait + '" }'
        $edits += [pscustomobject]@{ Start = $start + $match.Index; Length = $match.Length; Text = $replacement }
    }
    if ($edits.Count) {
        foreach ($edit in ($edits | Sort-Object Start -Descending)) {
            $data = $data.Substring(0, $edit.Start) + $edit.Text + $data.Substring($edit.Start + $edit.Length)
        }
        [IO.File]::WriteAllText($file.FullName, $data, $(if ($hasBom) { $utf8Bom } else { $utf8NoBom }))
    }
}

$missing = @($targetStates | Where-Object { -not $seen.ContainsKey($_) })
if ($missing.Count) { throw "Target states not found: $($missing -join ', ')" }
Write-Host "Horse-Breeding Traditions present in $($seen.Count) states."
