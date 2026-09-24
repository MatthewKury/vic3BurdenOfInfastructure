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
    if ($seeded.Count -ne 225) { throw "Expected 225 seeded Horse Ranch states; found $($seeded.Count)." }
    $levels = ($seeded | Measure-Object -Property Ranch -Sum).Sum
    if ($levels -ne 857) { throw "Expected 857 Horse Ranch levels; found $levels." }
    foreach ($row in $seeded) {
        if ([int]$row.DeclaredHeadroom -lt 10) {
            throw "$($row.State) has only $($row.DeclaredHeadroom) declared arable levels left."
        }
    }

    $additions = @(Get-Content (Join-Path $ModPath 'tools/horse_seed_additions.tsv') |
        Where-Object { $_ -match '^STATE_([A-Z0-9_]+)\s+(\d+)$' })
    if ($additions.Count -ne 14) { throw "Expected 14 new ranch states; found $($additions.Count)." }
    foreach ($line in $additions) {
        $parts = $line -split '\s+'
        $row = $byState[$parts[0]]
        if (-not $row -or [int]$row.Ranch -ne [int]$parts[1] -or
            [int]$row.Owners -ne 1 -or $row.Core -ne 'True' -or $row.Unincorporated -ne 'False') {
            throw "Unsafe or mismatched new Horse Ranch state: $($parts[0])."
        }
    }

    $holds = @(Get-Content (Join-Path $ModPath 'tools/horse_seed_holds.tsv') |
        Where-Object { $_ -match '^STATE_([A-Z0-9_]+)\s+(\d+)$' })
    if ($holds.Count -ne 15) { throw "Expected 15 held ranch states; found $($holds.Count)." }
    foreach ($line in $holds) {
        $parts = $line -split '\s+'
        $row = $byState[$parts[0]]
        if (-not $row -or [int]$row.Ranch -gt [int]$parts[1] -or $row.Unincorporated -ne 'True') {
            throw "Held Horse Ranch state changed: $($parts[0])."
        }
    }
    Write-Host 'PASS: ranch levels fit declared land; 14 additions are core, sole-owner, incorporated; 15 unincorporated holds do not exceed their safe levels.'
}
finally {
    Remove-Item -LiteralPath $auditPath -Force -ErrorAction SilentlyContinue
}
