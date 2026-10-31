# Runs an ensemble: the same headless observer game several times, so the
# game's own randomness can be measured, then collects the runs into the
# SQLite database tools/ensembles/ensembles.sqlite with
# tools/ensembles/Build-EnsembleDb.py. The database is self-contained, so the
# run folders can be deleted once it is built (see tools/ensembles/README.md).
#
# Each run is tools/Test-Headless.ps1 -Ensemble -NoSaves -NoFixtures (the
# housing fixtures rewrite Portugal, which would bias a mod ensemble). The
# manifest tools/headless-runs/ensembles/<Name>.json lists the runs so far, so
# rerunning the same command after an interruption tops the ensemble up to
# -Runs passing members instead of starting again.
#
#   .\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -Control -Runs 10
#   .\Invoke-HeadlessEnsemble.ps1 -Name boi_1836_1846 -Runs 10
#   .\Invoke-HeadlessEnsemble.ps1 -Name vanilla_1836_1846 -BuildOnly
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Name,
    [int]$Runs = 10,
    # Mid-January, so the January snapshot of the last year is taken.
    [string]$UntilDate = '1846.1.15',
    [switch]$Control,
    [string]$Description,
    [string]$ModPath,
    [string[]]$ExtraMods,
    [int]$TimeoutMinutes = 45,
    [int]$MaxConsecutiveFailures = 3,
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

function Get-RunResult([string]$RunName) {
    $info = Join-Path (Join-Path $runsRoot $RunName) 'run.json'
    if (-not (Test-Path -LiteralPath $info)) { return 'MISSING' }
    (Get-Content -LiteralPath $info -Raw | ConvertFrom-Json).result
}

function Save-Manifest($Manifest) {
    New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null
    [IO.File]::WriteAllText($manifestPath, ($Manifest | ConvertTo-Json -Depth 5), $utf8NoBom)
}

if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.arm -ne $arm -or $manifest.until -ne $UntilDate) {
        throw "Ensemble '$Name' already exists as arm '$($manifest.arm)' until $($manifest.until); use another -Name."
    }
    $manifest.runs = @($manifest.runs)
    if ($Description) { $manifest.description = $Description }
} else {
    if ($BuildOnly) { throw "No manifest at $manifestPath" }
    $manifest = [pscustomobject]@{
        name = $Name; arm = $arm; until = $UntilDate; description = $Description
        created = (Get-Date).ToString('s'); runs = @()
    }
    Save-Manifest $manifest
}

if (-not $BuildOnly) {
    $failures = 0
    while (@($manifest.runs | Where-Object { (Get-RunResult $_) -eq 'PASS' }).Count -lt $Runs) {
        $passed = @($manifest.runs | Where-Object { (Get-RunResult $_) -eq 'PASS' }).Count
        Write-Host ("=== Ensemble {0}: member {1} of {2} ({3}) ===" -f $Name, ($passed + 1), $Runs, (Get-Date -Format 'HH:mm'))
        $before = @(if (Test-Path -LiteralPath $runsRoot) { Get-ChildItem -LiteralPath $runsRoot -Directory | ForEach-Object Name })
        $params = @{
            Ensemble = $true; NoSaves = $true; NoFixtures = $true; Autosave = 'never'
            UntilDate = $UntilDate; TimeoutMinutes = $TimeoutMinutes
        }
        if ($Control) { $params.Control = $true }
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
            if ($failures -ge $MaxConsecutiveFailures) { throw "$failures runs in a row failed; stopping. Fix the cause, then rerun to resume." }
        }
    }
}

$passing = @($manifest.runs | Where-Object { (Get-RunResult $_) -eq 'PASS' } | ForEach-Object { Join-Path $runsRoot $_ })
if (-not $passing) { throw "Ensemble '$Name' has no passing runs to build from." }
$python = Find-Python
$builder = Join-Path $PSScriptRoot 'ensembles\Build-EnsembleDb.py'
$text = if ($manifest.description) { $manifest.description } else { "$arm ensemble until $UntilDate" }
Write-Host "Building '$Name' from $($passing.Count) run(s) into $Database"
& $python -I $builder --db $Database --name $Name --description $text @passing
if ($LASTEXITCODE) { throw "Build-EnsembleDb.py failed with exit code $LASTEXITCODE" }
