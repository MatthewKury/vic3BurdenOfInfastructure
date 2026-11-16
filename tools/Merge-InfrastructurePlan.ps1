[CmdletBinding()]
param(
    [string]$ModPath,
    # Compare the merge with the committed plan instead of writing it; throws on a mismatch.
    [switch]$Check
)

# Builds tools/infrastructure_seed_plan.tsv, which gen_seed.awk reads, from two files:
#   infrastructure_seed_baseline.tsv     vanilla rail and port replacement only; rewritten by
#                                        Get-StartingInfrastructure.ps1 on every regeneration
#   infrastructure_seed_adjustments.tsv  balance changes made by hand (level deltas, may be
#                                        negative); never rewritten by a script
# Split on 2026-11-09 (plan 6, review finding C1): the regeneration used to rewrite the plan
# from the baseline alone and drop the hand-made additions.
$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$tools = Join-Path $ModPath 'tools'
$baselinePath = Join-Path $tools 'infrastructure_seed_baseline.tsv'
$adjustmentsPath = Join-Path $tools 'infrastructure_seed_adjustments.tsv'
$planPath = Join-Path $tools 'infrastructure_seed_plan.tsv'

function Read-Plan([string]$path, [switch]$AllowNegative, [switch]$AllowComments) {
    $rows = [ordered]@{}
    foreach ($line in Get-Content -LiteralPath $path) {
        $line = $line.TrimStart([char]0xFEFF)
        if ($AllowComments -and ($line -match '^\s*#' -or $line -match '^\s*$')) { continue }
        $parts = $line -split "`t"
        $number = if ($AllowNegative) { '^-?\d+$' } else { '^\d+$' }
        if ($parts.Count -ne 4 -or $parts[0] -notmatch '^STATE_' -or $parts[1] -notmatch '^[A-Z0-9_]+$' -or
            $parts[2] -notmatch $number -or $parts[3] -notmatch $number) {
            throw "Malformed line in ${path}: $line"
        }
        $key = "$($parts[0])`t$($parts[1])"
        if ($rows.Contains($key)) { throw "Duplicate state-owner in ${path}: $key" }
        $rows[$key] = @([int]$parts[2], [int]$parts[3])
    }
    $rows
}

$baseline = Read-Plan $baselinePath
$adjustments = Read-Plan $adjustmentsPath -AllowNegative -AllowComments
$merged = @{}
foreach ($key in $baseline.Keys) { $merged[$key] = @($baseline[$key][0], $baseline[$key][1]) }
foreach ($key in $adjustments.Keys) {
    $current = if ($merged.ContainsKey($key)) { $merged[$key] } else { @(0, 0) }
    $merged[$key] = @(($current[0] + $adjustments[$key][0]), ($current[1] + $adjustments[$key][1]))
    if ($merged[$key][0] -lt 0 -or $merged[$key][1] -lt 0) {
        throw "Adjustment takes $key below zero levels: $($merged[$key] -join ', ')"
    }
}
$lines = foreach ($key in ($merged.Keys | Sort-Object)) {
    if (($merged[$key][0] + $merged[$key][1]) -gt 0) { "$key`t$($merged[$key][0])`t$($merged[$key][1])" }
}

if ($Check) {
    $committed = Read-Plan $planPath
    $problems = @()
    foreach ($line in $lines) {
        $parts = $line -split "`t"
        $key = "$($parts[0])`t$($parts[1])"
        if (-not $committed.Contains($key)) { $problems += "missing from plan: $line"; continue }
        if ($committed[$key][0] -ne [int]$parts[2] -or $committed[$key][1] -ne [int]$parts[3]) {
            $problems += "plan has $key $($committed[$key] -join '/'), baseline + adjustments give $($parts[2])/$($parts[3])"
        }
    }
    $expectedKeys = @($lines | ForEach-Object { ($_ -split "`t")[0..1] -join "`t" })
    foreach ($key in $committed.Keys) { if ($key -notin $expectedKeys) { $problems += "in plan but not in baseline + adjustments: $key" } }
    if ($problems.Count) { throw "infrastructure_seed_plan.tsv is not baseline + adjustments:`n  $($problems -join "`n  ")" }
    Write-Host "PASS: infrastructure_seed_plan.tsv = baseline ($($baseline.Count) rows) + adjustments ($($adjustments.Count) rows)."
    return
}

[IO.File]::WriteAllText($planPath, (($lines -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))
Write-Host "$($lines.Count) state-owners -> $planPath (baseline $($baseline.Count), adjustments $($adjustments.Count))"
