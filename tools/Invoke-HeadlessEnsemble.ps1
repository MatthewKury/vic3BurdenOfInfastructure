# Runs an ensemble: the same headless observer game several times, so the
# game's own randomness can be measured, then collects the runs into the
# SQLite database tools/ensembles/ensembles.sqlite with
# tools/ensembles/Build-EnsembleDb.py. The database is self-contained, so the
# run folders can be deleted once it is built (see tools/ensembles/README.md).
#
# Each run is tools/Test-Headless.ps1 -Ensemble -NoFixtures -LongRun (the housing
# fixtures rewrite Portugal, which would bias a mod ensemble, and -LongRun leaves
# out the crash-linked boi_states module). The manifest
# tools/headless-runs/ensembles/<Name>.json lists the runs so far, so rerunning
# the same command after an interruption tops the ensemble up to the passing
# members it asks for instead of starting again.
#
# -Plan runs members of different lengths as one ensemble, shortest first, and
# rebuilds the database after each length, so early data is usable while the long
# games play. Statistics then have fewer members in later years. -Autosave keeps
# the game's autosaves in each run folder (about 40 MB each by the 1930s).
#
#   .\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -Control -Runs 10
#   .\Invoke-HeadlessEnsemble.ps1 -Name boi_1836_1846 -Runs 10
#   .\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -BuildOnly -Control
#   .\Invoke-HeadlessEnsemble.ps1 -Name vanilla115_1836_1936 -Control -Autosave five_year `
#       -Plan '1846.1.15=3','1856.1.15=3','1886.1.15=2','1936.1.15=2'
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Name,
    [int]$Runs = 10,
    # Mid-January, so the January snapshot of the last year is taken.
    [string]$UntilDate = '1846.1.15',
    # Instead of -Runs and -UntilDate: '<until date>=<members>' entries, run in order.
    [string[]]$Plan,
    [switch]$Control,
    [switch]$RailSurvey,
    [string]$Description,
    [string]$ModPath,
    [string[]]$ExtraMods,
    # A floor: long games get 6 real minutes per game year if that is longer.
    [int]$TimeoutMinutes = 45,
    [int]$MaxConsecutiveFailures = 3,
    [ValidateSet('never', 'monthly', 'quarteryear', 'halfyear', 'yearly', 'five_year')]
    [string]$Autosave = 'never',
    [string]$Database = (Join-Path $PSScriptRoot 'ensembles\ensembles.sqlite'),
    [string]$Python,
    [switch]$BuildOnly
)

$ErrorActionPreference = 'Stop'
$runsRoot = Join-Path $PSScriptRoot 'headless-runs'
$manifestDir = Join-Path $runsRoot 'ensembles'
$manifestPath = Join-Path $manifestDir "$Name.json"
$utf8NoBom = New-Object Text.UTF8Encoding $false
$arm = if ($Control) { 'control' } else { 'mod' }

$tiers = @(
    if ($Plan) {
        foreach ($entry in $Plan) {
            if ($entry -notmatch '^(\d{4})(\.\d{1,2}\.\d{1,2})=(\d+)$') { throw "Plan entries look like 1846.1.15=3, got '$entry'" }
            [pscustomobject]@{ Until = $Matches[1] + $Matches[2]; Runs = [int]$Matches[3]; Year = [int]$Matches[1] }
        }
    } else {
        [pscustomobject]@{ Until = $UntilDate; Runs = $Runs; Year = [int]($UntilDate -split '\.')[0] }
    })
$lastUntil = $tiers[-1].Until

function Find-Python {
    if ($Python) { return $Python }
    # Skip the Microsoft Store stub in WindowsApps, which only opens the Store.
    $onPath = Get-Command python, python3 -ErrorAction SilentlyContinue |
        Where-Object { $_.Source -notlike '*\WindowsApps\*' } | Select-Object -First 1
    if ($onPath) { return $onPath.Source }
    $installed = Get-ChildItem -Path (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python3*\python.exe') -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending | Select-Object -First 1
    if ($installed) { return $installed.FullName }
    throw 'Python 3 not found; install it (winget install Python.Python.3.12) or pass -Python.'
}

function Get-RunInfo([string]$RunName) {
    $info = Join-Path (Join-Path $runsRoot $RunName) 'run.json'
    if (-not (Test-Path -LiteralPath $info)) { return $null }
    Get-Content -LiteralPath $info -Raw | ConvertFrom-Json
}

function Get-RunResult([string]$RunName) {
    $info = Get-RunInfo $RunName
    if ($info) { $info.result } else { 'MISSING' }
}

function Get-PassingCount([string]$Until) {
    @($manifest.runs | Where-Object {
            $info = Get-RunInfo $_
            $info -and $info.result -eq 'PASS' -and $info.until -eq $Until
        }).Count
}

function Save-Manifest($Manifest) {
    New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null
    [IO.File]::WriteAllText($manifestPath, ($Manifest | ConvertTo-Json -Depth 5), $utf8NoBom)
}

function Build-Database {
    $passing = @($manifest.runs | Where-Object { (Get-RunResult $_) -eq 'PASS' } | ForEach-Object { Join-Path $runsRoot $_ })
    if (-not $passing) { throw "Ensemble '$Name' has no passing runs to build from." }
    $interpreter = Find-Python
    $builder = Join-Path $PSScriptRoot 'ensembles\Build-EnsembleDb.py'
    $text = if ($manifest.description) { $manifest.description } else { "$arm ensemble until $lastUntil" }
    Write-Host "Building '$Name' from $($passing.Count) run(s) into $Database ($(Get-Date -Format 'HH:mm'))"
    & $interpreter -I $builder --db $Database --name $Name --description $text @passing
    if ($LASTEXITCODE) { throw "Build-EnsembleDb.py failed with exit code $LASTEXITCODE" }
    Write-Host "Built '$Name' from $($passing.Count) run(s) ($(Get-Date -Format 'HH:mm'))"
}

if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.arm -ne $arm -or (-not $BuildOnly -and $manifest.until -ne $lastUntil)) {
        throw "Ensemble '$Name' already exists as arm '$($manifest.arm)' until $($manifest.until); use another -Name."
    }
    $manifest.runs = @($manifest.runs)
    if ($Description) { $manifest.description = $Description }
} else {
    if ($BuildOnly) { throw "No manifest at $manifestPath" }
    $manifest = [pscustomobject]@{
        name = $Name; arm = $arm; until = $lastUntil; description = $Description
        created = (Get-Date).ToString('s'); runs = @()
    }
    Save-Manifest $manifest
}

if ($BuildOnly) {
    Build-Database
    return
}

$failures = 0
$stopped = $null
foreach ($tier in $tiers) {
    $played = $false
    $tierTimeout = [math]::Max($TimeoutMinutes, ($tier.Year - 1836) * 6)
    while (-not $stopped -and (Get-PassingCount $tier.Until) -lt $tier.Runs) {
        $played = $true
        Write-Host ("=== Ensemble {0}: until {1}, member {2} of {3} ({4}) ===" -f $Name, $tier.Until, ((Get-PassingCount $tier.Until) + 1), $tier.Runs, (Get-Date -Format 'HH:mm'))
        $before = @(if (Test-Path -LiteralPath $runsRoot) { Get-ChildItem -LiteralPath $runsRoot -Directory | ForEach-Object Name })
        $params = @{
            Ensemble = $true; NoFixtures = $true; LongRun = $true; Autosave = $Autosave
            UntilDate = $tier.Until; TimeoutMinutes = $tierTimeout
        }
        if ($Autosave -eq 'never') { $params.NoSaves = $true }
        if ($Control) { $params.Control = $true }
        if ($RailSurvey) { $params.RailSurvey = $true }
        if ($ModPath) { $params.ModPath = $ModPath }
        if ($ExtraMods) { $params.ExtraMods = $ExtraMods }
        & (Join-Path $PSScriptRoot 'Test-Headless.ps1') @params | Out-Host
        $newRun = Get-ChildItem -LiteralPath $runsRoot -Directory |
            Where-Object { $_.Name -notin $before -and $_.Name -like "*_$arm" } |
            Sort-Object Name | Select-Object -Last 1
        if (-not $newRun) { throw 'Test-Headless.ps1 did not create a run folder; see its output above.' }
        $manifest.runs = @($manifest.runs) + $newRun.Name
        Save-Manifest $manifest
        if ((Get-RunResult $newRun.Name) -eq 'PASS') {
            $failures = 0
        } else {
            $failures++
            Write-Warning "Run $($newRun.Name) did not pass ($failures in a row); it stays in the manifest but is left out of the database."
            if ($failures -ge $MaxConsecutiveFailures) { $stopped = "$failures runs in a row failed; stopping. Fix the cause, then rerun to resume." }
        }
    }
    if ($stopped) { break }
    if ($played -or $tier -eq $tiers[-1]) { Build-Database }
}
if ($stopped) {
    # Keep whatever passed before the failures, so the data so far is usable.
    if (@($manifest.runs | Where-Object { (Get-RunResult $_) -eq 'PASS' })) { Build-Database }
    throw $stopped
}
