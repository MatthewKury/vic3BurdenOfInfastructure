[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$GamePath,
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$auditPath = Join-Path $env:TEMP ('boi-horse-audit-' + [guid]::NewGuid().ToString('N') + '.csv')
try {
    & (Join-Path $PSScriptRoot 'Audit-HorseSeed.ps1') -Game $GamePath -ModPath $ModPath -OutputPath $auditPath | Out-Null
    $rows = @(Import-Csv -LiteralPath $auditPath)
    $byState = @{}
    foreach ($row in $rows) { $byState[$row.State] = $row }

    $seeded = @($rows | Where-Object { [int]$_.Ranch -gt 0 })
    if ($seeded.Count -ne 223) { throw "Expected 223 seeded Horse Ranch states; found $($seeded.Count)." }
    $levels = ($seeded | Measure-Object -Property Ranch -Sum).Sum
    if ($levels -ne 525) { throw "Expected 525 Horse Ranch levels (1.15.0, balance pass 4); found $levels." }
    foreach ($row in $seeded) {
        if ([int]$row.DeclaredHeadroom -lt 10) {
            throw "$($row.State) has only $($row.DeclaredHeadroom) declared arable levels left."
        }
    }

    $additions = @(Get-Content (Join-Path $ModPath 'tools/horse_seed_additions.tsv') |
        Where-Object { $_ -match '^STATE_([A-Z0-9_]+)\s+(\d+)$' })
    # 1.15.0: 13; Oryol now passes curation itself after the Tula split. Balance passes 3 and 4 add 4 and 3.
    if ($additions.Count -ne 20) { throw "Expected 20 new ranch states; found $($additions.Count)." }
    # Company and colonial states are never core to their owner, so the core rule would
    # leave British India and the Dutch East Indies with no ranch at all. These are
    # still sole-owner and incorporated.
    $nonCoreAllowed = @('STATE_BIHAR', 'STATE_EAST_JAVA')
    foreach ($line in $additions) {
        $parts = $line -split '\s+'
        $row = $byState[$parts[0]]
        $coreOk = $row -and ($row.Core -eq 'True' -or $parts[0] -in $nonCoreAllowed)
        if (-not $row -or [int]$row.Ranch -gt [int]$parts[1] -or
            [int]$row.Owners -ne 1 -or -not $coreOk -or $row.Unincorporated -ne 'False') {
            throw "Unsafe or mismatched new Horse Ranch state: $($parts[0])."
        }
    }

    $holds = @(Get-Content (Join-Path $ModPath 'tools/horse_seed_holds.tsv') |
        Where-Object { $_ -match '^STATE_([A-Z0-9_]+)\s+(\d+)$' })
    if ($holds.Count -ne 14) { throw "Expected 14 held ranch states (1.15.0); found $($holds.Count)." }
    foreach ($line in $holds) {
        $parts = $line -split '\s+'
        $row = $byState[$parts[0]]
        if (-not $row -or [int]$row.Ranch -gt [int]$parts[1] -or $row.Unincorporated -ne 'True') {
            throw "Held Horse Ranch state changed: $($parts[0])."
        }
    }
    Write-Host 'PASS: ranch levels fit declared land; 20 additions are sole-owner, incorporated, core (or allowed by name) and within their reviewed levels; 14 unincorporated holds do not exceed their safe levels.'
}
finally {
    Remove-Item -LiteralPath $auditPath -Force -ErrorAction SilentlyContinue
}
