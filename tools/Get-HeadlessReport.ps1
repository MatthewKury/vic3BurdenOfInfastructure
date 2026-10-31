# Turns the BOITM| telemetry lines of a headless run (tools/Test-Headless.ps1)
# into <run>/telemetry.tsv and <run>/report.md. With -Compare <control run>,
# the report also sets each metric beside the control run's value at the last
# date both runs sampled, per country.
#
# Line format (tools/headless-telemetry/*/events/*.txt):
#   BOITM|<group>|<date>|<tag>|key=value;key=value
# Goods lines carry goods=<name>; their metrics are reported as <name>_<key>.
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$Run,
    [string]$Compare,
    [string[]]$Tags,
    [string[]]$Metrics = @('gdp', 'sol', 'population', 'infrastructure', 'usage', 'deficit_states',
        'horses_price', 'horses_sell', 'horse_ranch_levels', 'public_works_levels', 'horse_expensive_states',
        'transportation_price', 'grain_price', 'boi_housing_price', 'housing_expensive_states', 'slum_levels')
)

$ErrorActionPreference = 'Stop'
$months = @{ January = 1; February = 2; March = 3; April = 4; May = 5; June = 6; July = 7
    August = 8; September = 9; October = 10; November = 11; December = 12 }

function ConvertTo-IsoDate([string]$Text) {
    $Text = $Text.Trim()
    if ($Text -match '^(\d{4})\.(\d{1,2})\.(\d{1,2})$') { return '{0}-{1:D2}-{2:D2}' -f $Matches[1], [int]$Matches[2], [int]$Matches[3] }
    if ($Text -match '^([A-Za-z]+) (\d{1,2}), (\d{4})$' -and $months[$Matches[1]]) { return '{0}-{1:D2}-{2:D2}' -f $Matches[3], $months[$Matches[1]], [int]$Matches[2] }
    if ($Text -match '^(\d{1,2}) ([A-Za-z]+),? (\d{4})$' -and $months[$Matches[2]]) { return '{0}-{1:D2}-{2:D2}' -f $Matches[3], $months[$Matches[2]], [int]$Matches[1] }
    return $Text
}

# Display formats can add thousands separators, currency marks or K/M/B.
function ConvertTo-Number([string]$Text) {
    $clean = $Text -replace '[^0-9.\-KMB]', ''
    $scale = 1.0
    if ($clean -match '([KMB])$') {
        $scale = @{ K = 1e3; M = 1e6; B = 1e9 }[$Matches[1]]
        $clean = $clean.Substring(0, $clean.Length - 1)
    }
    $value = 0.0
    if ([double]::TryParse($clean, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$value)) {
        return $value * $scale
    }
    return $null
}

function Read-Telemetry([string]$RunDir) {
    $log = Join-Path $RunDir 'logs\debug.log'
    if (-not (Test-Path -LiteralPath $log)) { throw "No mirrored debug.log in $RunDir" }
    $rows = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    foreach ($match in [regex]::Matches([IO.File]::ReadAllText($log), 'BOITM\|([^\r\n]*)')) {
        $line = $match.Groups[1].Value
        # The mirror can repeat a line at a log rotation; count each once.
        if ($seen.ContainsKey($line)) { continue }
        $seen[$line] = $true
        $parts = $line -split '\|', 4
        if ($parts.Count -lt 4) { continue }
        $group, $date, $tag = $parts[0], (ConvertTo-IsoDate $parts[1]), $parts[2].Trim()
        $fields = [ordered]@{}
        foreach ($pair in $parts[3] -split ';') {
            $kv = $pair -split '=', 2
            if ($kv.Count -eq 2) { $fields[$kv[0].Trim()] = $kv[1].Trim() }
        }
        $prefix = if ($fields.Contains('goods')) { "$($fields['goods'])_" } else { '' }
        foreach ($key in $fields.Keys) {
            if ($key -eq 'goods') { continue }
            $rows.Add([pscustomobject]@{
                    date = $date; tag = $tag; group = $group; metric = "$prefix$key"
                    value = ConvertTo-Number $fields[$key]; raw = $fields[$key]
                })
        }
    }
    return $rows
}

function Format-Value($Value) {
    if ($null -eq $Value) { return 'n/a' }
    if ([math]::Abs($Value) -ge 1e6) { return '{0:N2}M' -f ($Value / 1e6) }
    if ([math]::Abs($Value) -ge 1e4) { return '{0:N0}' -f $Value }
    return '{0:0.##}' -f $Value
}

$Run = (Resolve-Path -LiteralPath $Run).Path
$rows = Read-Telemetry $Run
if ($rows.Count -eq 0) { throw "No BOITM lines in $Run (was it run with -NoTelemetry, or ended before the first yearly pulse?)" }
$rows | Export-Csv -LiteralPath (Join-Path $Run 'telemetry.tsv') -Delimiter "`t" -NoTypeInformation -Encoding UTF8

$allTags = @($rows | ForEach-Object tag | Sort-Object -Unique)
if (-not $Tags) { $Tags = $allTags }
$present = @($rows | ForEach-Object metric | Sort-Object -Unique)
$shown = @($Metrics | Where-Object { $_ -in $present })
$blank = @($rows | Where-Object { $null -eq $_.value } | ForEach-Object { "$($_.group).$($_.metric)='$($_.raw)'" } | Sort-Object -Unique)

$report = @(
    "# Headless telemetry: $(Split-Path $Run -Leaf)",
    '',
    "- Rows: $($rows.Count); countries: $($allTags -join ', ')",
    "- Dates: $(@($rows | ForEach-Object date | Sort-Object -Unique) -join ', ')",
    "- Metrics present: $($present -join ', ')"
)
if ($blank) { $report += "- **Unparsed values:** $($blank -join '; ')" }

# Per-country timeline, one column per sampled year.
foreach ($tag in $Tags) {
    $tagRows = @($rows | Where-Object tag -eq $tag)
    if (-not $tagRows) { continue }
    $dates = @($tagRows | ForEach-Object date | Sort-Object -Unique)
    $report += @('', "## $tag", '', "| metric | $($dates -join ' | ') |", "|---|$('---|' * $dates.Count)")
    foreach ($metric in $shown) {
        $cells = foreach ($date in $dates) {
            $hit = $tagRows | Where-Object { $_.metric -eq $metric -and $_.date -eq $date } | Select-Object -First 1
            if ($hit) { Format-Value $hit.value } else { '' }
        }
        if (($cells | Where-Object { $_ }).Count) { $report += "| $metric | $($cells -join ' | ') |" }
    }
}

if ($Compare) {
    $Compare = (Resolve-Path -LiteralPath $Compare).Path
    $controlRows = Read-Telemetry $Compare
    $report += @('', "## Compared with $(Split-Path $Compare -Leaf)", '',
        'Each country at the last date both runs sampled. Change is (run - control) / control.', '',
        '| country | date | metric | run | control | change |', '|---|---|---|---|---|---|')
    foreach ($tag in $Tags) {
        $runDates = @($rows | Where-Object tag -eq $tag | ForEach-Object date | Sort-Object -Unique)
        $common = @($controlRows | Where-Object { $_.tag -eq $tag -and $_.date -in $runDates } | ForEach-Object date | Sort-Object -Unique)
        if (-not $common) { continue }
        $date = $common[-1]
        foreach ($metric in $shown) {
            $a = $rows | Where-Object { $_.tag -eq $tag -and $_.date -eq $date -and $_.metric -eq $metric } | Select-Object -First 1
            $b = $controlRows | Where-Object { $_.tag -eq $tag -and $_.date -eq $date -and $_.metric -eq $metric } | Select-Object -First 1
            if (-not $a -and -not $b) { continue }
            $change = ''
            if ($a -and $b -and $null -ne $a.value -and $b.value) { $change = '{0:+0.0;-0.0;0.0}%' -f (100 * ($a.value - $b.value) / $b.value) }
            $report += "| $tag | $date | $metric | $(if ($a) { Format-Value $a.value } else { '-' }) | $(if ($b) { Format-Value $b.value } else { '-' }) | $change |"
        }
    }
}

$report | Set-Content -LiteralPath (Join-Path $Run 'report.md') -Encoding UTF8
$report | Write-Host
Write-Host "Wrote $(Join-Path $Run 'telemetry.tsv') and report.md"
