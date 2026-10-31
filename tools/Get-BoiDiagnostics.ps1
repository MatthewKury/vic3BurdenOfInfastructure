# Turns the BOIDIAG| per-state lines of a headless run (tools/Test-Headless.ps1,
# boi telemetry module) into <run>/boi_diag.tsv, and prints per-country
# Public Works / Harbour Works changes between consecutive samples, so that
# lost or new levels can be tied to the state's spare infrastructure,
# staffing and AI score at the time.
#
#   BOIDIAG|<date>|<tag>|<state>|key=value;key=value
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$Run,
    [string[]]$Tags
)

$ErrorActionPreference = 'Stop'
$Run = (Resolve-Path -LiteralPath $Run).Path
$log = Join-Path $Run 'logs\debug.log'
if (-not (Test-Path -LiteralPath $log)) { throw "No logs\debug.log in $Run" }

# GetStateRegion.GetName prints tooltip markup ("\x15tooltippable_name ...
# StateRegionTooltip <name>\x15!"); keep only the name. Lines whose tag came
# out blank take it from the BOITM| line the same event printed just before.
$lastTag = ''
$rows = foreach ($match in [regex]::Matches([IO.File]::ReadAllText($log), '(BOITM|BOIDIAG)\|([^\r\n]*)')) {
    if ($match.Groups[1].Value -eq 'BOITM') {
        $lastTag = ($match.Groups[2].Value -split '\|')[2]
        continue
    }
    $parts = $match.Groups[2].Value -split '\|', 4
    if ($parts.Count -lt 4) { continue }
    $state = $parts[2] -replace '^.*StateRegionTooltip ', '' -replace '[\x00-\x1f].*$', ''
    $tag = if ($parts[1]) { $parts[1] } else { $lastTag }
    # The engine also echoes the unresolved template when a data function fails.
    $date = [datetime]::MinValue
    if (-not [datetime]::TryParse($parts[0], [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$date)) { continue }
    $row = [ordered]@{ date = $date.ToString('yyyy-MM-dd'); tag = $tag; state = $state }
    foreach ($pair in $parts[3] -split ';') {
        $kv = $pair -split '=', 2
        $row[$kv[0]] = $kv[1] -replace ',', ''
    }
    [pscustomobject]$row
}
if (-not $rows) { throw "No BOIDIAG lines in $log" }
$rows | Export-Csv -LiteralPath (Join-Path $Run 'boi_diag.tsv') -Delimiter "`t" -NoTypeInformation -Encoding UTF8

foreach ($group in ($rows | Group-Object tag | Sort-Object Name)) {
    if ($Tags -and $group.Name -notin $Tags) { continue }
    $dates = @($group.Group.date | Sort-Object -Unique)
    $changes = @()
    for ($i = 1; $i -lt $dates.Count; $i++) {
        $before = @{}; foreach ($r in $group.Group | Where-Object date -eq $dates[$i - 1]) { $before[$r.state] = $r }
        $after = @{}; foreach ($r in $group.Group | Where-Object date -eq $dates[$i]) { $after[$r.state] = $r }
        foreach ($state in ($before.Keys + $after.Keys | Sort-Object -Unique)) {
            $b = $before[$state]; $a = $after[$state]
            $pw0 = if ($b) { [int]$b.pw } else { 0 }; $pw1 = if ($a) { [int]$a.pw } else { 0 }
            $hw0 = if ($b) { [int]$b.hw } else { 0 }; $hw1 = if ($a) { [int]$a.hw } else { 0 }
            if ($pw0 -ne $pw1 -or $hw0 -ne $hw1) {
                $changes += '  {0} {1,-28} pw {2}->{3}  hw {4}->{5}  spare {6} -> {7}  pw_occ {8}  ai_pw {9}' -f $dates[$i], $state,
                    $pw0, $pw1, $hw0, $hw1, $b.spare, $a.spare, $b.pw_occ, $b.ai_pw
            }
        }
    }
    $last = @($group.Group | Where-Object date -eq $dates[-1])
    $deficit = @($last | Where-Object { [double]$_.spare -lt 0 }).Count
    Write-Host ('{0}: {1} samples; latest {2}: {3} states logged, {4} in deficit, {5} queued' -f $group.Name, $dates.Count, $dates[-1], $last.Count, $deficit, @($last | Where-Object queued -eq '1').Count)
    $changes | ForEach-Object { Write-Host $_ }
}
