# Runs one unattended observer game (-handsoff -run_until) with BOI (plus any
# -ExtraMods) or vanilla (-Control), mirrors the logs and autosaves into
# tools/headless-runs/<stamp>_<arm>/, then checks error.log for BOI-attributable
# errors. Exits non-zero on BOI or telemetry errors, a missing (or unexpected)
# mod mount, a crash, or a timeout.
#
# Unless -NoTelemetry, both arms also load a telemetry mod assembled into the
# run folder from tools/headless-telemetry/: the core module always, and the
# boi / housing modules when a loaded mod defines horses / boi_housing. Its
# BOITM| lines in debug.log are read by tools/Get-HeadlessReport.ps1.
#
# Player state it touches -- content_load.json, pdx_settings.json,
# continue_game.json and the autosave*.v3 slots -- is backed up into the run
# folder and restored afterwards. If the script is killed before restoring,
# rerun it with -RestoreFrom <run folder>.
[CmdletBinding()]
param(
    [string]$ModPath,
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3',
    [string]$UntilDate = '1837.1.1',
    [int]$TimeoutMinutes = 30,
    [ValidateSet('never', 'monthly', 'quarteryear', 'halfyear', 'yearly', 'five_year')]
    [string]$Autosave = 'yearly',
    [switch]$Control,
    [switch]$DebugMode,
    [switch]$NoSaves,
    [string[]]$ExtraMods,
    [switch]$NoTelemetry,
    [string[]]$ExtraGameArgs,
    [string]$RestoreFrom
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$ModPath = (Resolve-Path -LiteralPath $ModPath).Path
$userDir = Split-Path (Split-Path $ModPath -Parent) -Parent
$runsRoot = Join-Path $PSScriptRoot 'headless-runs'
$saveDir = Join-Path $userDir 'save games'
$logDir = Join-Path $userDir 'logs'
$stateFiles = 'content_load.json', 'pdx_settings.json', 'continue_game.json'
$utf8NoBom = New-Object Text.UTF8Encoding $false

function Restore-PlayerState([string]$RunDir) {
    $backup = Join-Path $RunDir 'backup'
    if (-not (Test-Path -LiteralPath (Join-Path $backup 'PENDING'))) { return }
    foreach ($name in $stateFiles) {
        $source = Join-Path $backup $name
        if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination (Join-Path $userDir $name) -Force }
    }
    Get-ChildItem -LiteralPath $saveDir -Filter 'autosave*.v3' -File | Remove-Item -Force
    Get-ChildItem -LiteralPath $backup -Filter 'autosave*.v3' -File |
        Copy-Item -Destination $saveDir -Force
    Remove-Item -LiteralPath (Join-Path $backup 'PENDING') -Force
    Write-Host "Restored player state from $backup"
}

if ($RestoreFrom) {
    Restore-PlayerState (Resolve-Path -LiteralPath $RestoreFrom).Path
    return
}

if ($UntilDate -notmatch '^\d{4}\.\d{1,2}\.\d{1,2}$') { throw "UntilDate must look like 1837.1.1, got '$UntilDate'" }
$exe = Join-Path $GamePath 'binaries\victoria3.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw "victoria3.exe not found at $exe" }
if (-not (Test-Path -LiteralPath (Join-Path $userDir 'content_load.json'))) { throw "content_load.json not found in $userDir" }
if (Get-Process -Name victoria3 -ErrorAction SilentlyContinue) { throw 'victoria3.exe is already running; close it first.' }
if (Test-Path -LiteralPath $runsRoot) {
    $pending = Get-ChildItem -LiteralPath $runsRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'backup\PENDING') }
    if ($pending) { throw "Run '$($pending[0].Name)' never restored player state. Run: Test-Headless.ps1 -RestoreFrom '$($pending[0].FullName)'" }
}

$arm = if ($Control) { 'control' } else { 'mod' }
$runDir = Join-Path $runsRoot ('{0}_{1}' -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $arm)
$backupDir = Join-Path $runDir 'backup'
$mirrorDir = Join-Path $runDir 'logs'
$runSaveDir = Join-Path $runDir 'saves'
New-Item -ItemType Directory -Force -Path $backupDir, $mirrorDir, $runSaveDir | Out-Null

$armMods = @()
if (-not $Control) {
    $armMods = @($ModPath) + @($ExtraMods | Where-Object { $_ } | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
}

# --- Assemble the telemetry mod ----------------------------------------------
$telemetryPath = Join-Path $runDir 'telemetry_mod'
$telemetryName = 'BOI Headless Telemetry'
$telemetryModules = @()
if (-not $NoTelemetry) {
    function Test-DefinesGoods([string]$Path, [string]$Goods) {
        $goodsDir = Join-Path $Path 'common\goods'
        if (-not (Test-Path -LiteralPath $goodsDir)) { return $false }
        [bool](Get-ChildItem -LiteralPath $goodsDir -Filter '*.txt' -File |
            Select-String -Pattern ('^\W?\s*' + $Goods + '\s*=\s*\{') -List)
    }
    $telemetryModules = @('core')
    if ($armMods | Where-Object { Test-DefinesGoods $_ 'horses' }) { $telemetryModules += 'boi' }
    if ($armMods | Where-Object { Test-DefinesGoods $_ 'boi_housing' }) { $telemetryModules += 'housing' }
    foreach ($module in $telemetryModules) {
        $source = Join-Path $PSScriptRoot "headless-telemetry\$module"
        Get-ChildItem -LiteralPath $source -Recurse -File | ForEach-Object {
            $target = Join-Path $telemetryPath $_.FullName.Substring($source.Length + 1)
            New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $target
        }
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $telemetryPath '.metadata') | Out-Null
    $telemetryMeta = [ordered]@{
        name = $telemetryName; id = 'BOIHeadlessTelemetry'; version = '1'
        game_id = 'victoria3'; supported_game_version = '1.13'
        short_description = "Test-only telemetry ($($telemetryModules -join ', ')), generated by tools/Test-Headless.ps1."
        tags = @(); relationships = @(); game_custom_data = @{ multiplayer_synchronized = $true }
    }
    [IO.File]::WriteAllText((Join-Path $telemetryPath '.metadata\metadata.json'), ($telemetryMeta | ConvertTo-Json), $utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $telemetryPath 'descriptor.mod'), "name=`"$telemetryName`"`nversion=`"1`"`nsupported_version=`"1.13.*`"`n", $utf8NoBom)
}

# --- Back up player state, then point the game at this run ------------------
foreach ($name in $stateFiles) {
    $source = Join-Path $userDir $name
    if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $backupDir }
}
Get-ChildItem -LiteralPath $saveDir -Filter 'autosave*.v3' -File | Copy-Item -Destination $backupDir
New-Item -ItemType File -Path (Join-Path $backupDir 'PENDING') | Out-Null

$gameArgs = @('-handsoff', "-run_until=$UntilDate", '-gdpr-compliant', '-disable_renderframeifneeded')
if ($DebugMode) { $gameArgs += '-debug_mode' }
if ($ExtraGameArgs) { $gameArgs += $ExtraGameArgs }

$exitReason = $null
$crashDumps = @()
$started = Get-Date
try {
    $content = Get-Content -LiteralPath (Join-Path $userDir 'content_load.json') -Raw | ConvertFrom-Json
    # Assign inside the branches: `$x = if ...` would unroll the array, and a
    # bare object here logs "dlc.cpp: Missing path for dlc/mod".
    $enabled = @()
    foreach ($path in $armMods) { $enabled += @{ path = $path } }
    if ($telemetryModules) { $enabled += @{ path = $telemetryPath } }
    $disabledDlc = @($content.disabledDLC | Where-Object { $_ })
    $newContent = [ordered]@{ enabledMods = $enabled; disabledDLC = $disabledDlc; enabledUGC = @() }
    [IO.File]::WriteAllText((Join-Path $userDir 'content_load.json'), ($newContent | ConvertTo-Json -Depth 5 -Compress), $utf8NoBom)

    # pdx_settings.json is tab-indented and the game drops default keys, so
    # patch the text rather than round-tripping it through ConvertTo-Json.
    $settingsPath = Join-Path $userDir 'pdx_settings.json'
    # pause_on_event=true halts an observer game at the first event popup until
    # someone clicks it, so it must be off for an unattended run.
    function Set-GameSetting([string]$Text, [string]$Key, [string]$JsonValue) {
        $pattern = "`"$Key`"\s*:\s*(`"[^`"]*`"|true|false)"
        $entry = "`"$Key`":`t$JsonValue"
        if ($Text -match $pattern) { return ([regex]$pattern).Replace($Text, $entry, 1) }
        if ($Text -match '"game"\s*:\s*\{') { return ([regex]'"game"\s*:\s*\{').Replace($Text, "`"game`":`t{`n`t`t$entry,", 1) }
        return ([regex]'^\s*\{').Replace($Text, "{`n`t`"game`":`t{`n`t`t$entry`n`t},", 1)
    }
    $settings = [IO.File]::ReadAllText($settingsPath)
    $settings = Set-GameSetting $settings 'autosave' "`"$Autosave`""
    $settings = Set-GameSetting $settings 'pause_on_event' 'false'
    [IO.File]::WriteAllText($settingsPath, $settings, $utf8NoBom)
    Get-ChildItem -LiteralPath $saveDir -Filter 'autosave*.v3' -File | Remove-Item -Force

    # --- Launch and watch -----------------------------------------------------
    $crashDir = Join-Path $userDir 'crashes'
    $crashesBefore = @(if (Test-Path -LiteralPath $crashDir) { Get-ChildItem -LiteralPath $crashDir | ForEach-Object Name })
    Write-Host "Launching ($arm): victoria3.exe $($gameArgs -join ' ')"
    $launchTime = Get-Date
    $process = Start-Process -FilePath $exe -ArgumentList $gameArgs -WorkingDirectory (Split-Path $exe) -PassThru

    # The game keeps <name>.log plus five rotated copies capped at 512 KB, and
    # rotates again at launch, so copy new bytes as they appear. Offset tracks
    # how far into the live file the mirror has read.
    $mirrors = @{}
    foreach ($name in 'error', 'debug', 'game') { $mirrors[$name] = @{ Offset = 0L; Live = $false } }
    $copiedSaves = @{}
    $saveIndex = 0

    function Read-Tail([string]$Path, [long]$From) {
        $stream = [IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite, Delete')
        try {
            if ($From -ge $stream.Length) { return ,([byte[]]@()) }
            $stream.Seek($From, 'Begin') | Out-Null
            $buffer = New-Object byte[] ($stream.Length - $From)
            $read = $stream.Read($buffer, 0, $buffer.Length)
            if ($read -lt $buffer.Length) { [Array]::Resize([ref]$buffer, $read) }
            return ,$buffer
        } finally { $stream.Dispose() }
    }

    function Add-Bytes([string]$Path, [byte[]]$Bytes) {
        $stream = [IO.File]::Open($Path, 'Append', 'Write', 'Read')
        try { $stream.Write($Bytes, 0, $Bytes.Length) } finally { $stream.Dispose() }
    }

    function Update-Mirrors {
        foreach ($name in @($mirrors.Keys)) {
            $state = $mirrors[$name]
            $live = Join-Path $logDir "$name.log"
            if (-not (Test-Path -LiteralPath $live)) { continue }
            $item = Get-Item -LiteralPath $live
            if (-not $state.Live) {
                if ($item.LastWriteTime -lt $launchTime.AddSeconds(-2)) { continue }
                $state.Live = $true
            }
            $out = Join-Path $mirrorDir "$name.log"
            try {
                if ($item.Length -lt $state.Offset) {
                    # Rotated since the last poll: finish the old file from .1.log.
                    $rotated = Join-Path $logDir "$name.1.log"
                    if (Test-Path -LiteralPath $rotated) {
                        $bytes = Read-Tail $rotated $state.Offset
                        if ($bytes.Length) { Add-Bytes $out $bytes }
                    }
                    $state.Offset = 0L
                }
                $bytes = Read-Tail $live $state.Offset
                if ($bytes.Length) {
                    Add-Bytes $out $bytes
                    $state.Offset += $bytes.Length
                }
            } catch [IO.IOException] { }
        }
        if ($NoSaves) { return }
        foreach ($save in Get-ChildItem -LiteralPath $saveDir -Filter 'autosave*.v3' -File) {
            # Only copy once the file has stopped growing between two polls.
            $key = "$($save.Name)|$($save.LastWriteTimeUtc.Ticks)|$($save.Length)"
            $previous = $copiedSaves[$save.Name]
            if ($previous -eq $key) { continue }
            if ($previous -eq "pending|$key") {
                $script:saveIndex++
                try {
                    Copy-Item -LiteralPath $save.FullName -Destination (Join-Path $runSaveDir ('autosave_{0:D3}.v3' -f $script:saveIndex))
                    $copiedSaves[$save.Name] = $key
                } catch [IO.IOException] { $script:saveIndex-- }
            } else {
                $copiedSaves[$save.Name] = "pending|$key"
            }
        }
    }

    $deadline = $launchTime.AddMinutes($TimeoutMinutes)
    $lastReport = Get-Date
    while (-not $process.HasExited) {
        Start-Sleep -Seconds 5
        Update-Mirrors
        if ((Get-Date) -gt $deadline) {
            Stop-Process -Id $process.Id -Force
            $process.WaitForExit()
            $exitReason = "timeout after $TimeoutMinutes min"
            break
        }
        if (((Get-Date) - $lastReport).TotalMinutes -ge 2) {
            $lastReport = Get-Date
            Write-Host ('  {0:N0} min elapsed, {1} autosave(s) copied' -f ((Get-Date) - $launchTime).TotalMinutes, $saveIndex)
        }
    }
    Start-Sleep -Seconds 3
    Update-Mirrors
    Update-Mirrors

    if (Test-Path -LiteralPath $crashDir) {
        $crashDumps = @(Get-ChildItem -LiteralPath $crashDir | Where-Object { $_.Name -notin $crashesBefore } | ForEach-Object Name)
    }
    if (-not $exitReason) {
        $exitReason = if ($crashDumps) { 'crash' } else { 'exited on its own' }
    }
    $continuePath = Join-Path $userDir 'continue_game.json'
    if (Test-Path -LiteralPath $continuePath) { Copy-Item -LiteralPath $continuePath -Destination (Join-Path $runDir 'continue_game.json') }
} finally {
    Restore-PlayerState $runDir
}
$elapsed = (Get-Date) - $started

# --- Analyse ----------------------------------------------------------------
$errorLines = @()
$errorMirror = Join-Path $mirrorDir 'error.log'
if (Test-Path -LiteralPath $errorMirror) { $errorLines = @(Get-Content -LiteralPath $errorMirror) }
$debugMirror = Join-Path $mirrorDir 'debug.log'
$debugText = if (Test-Path -LiteralPath $debugMirror) { [IO.File]::ReadAllText($debugMirror) } else { '' }

$mountLines = @([regex]::Matches($debugText, 'dlc\.cpp:\d+\]: Mod [^\r\n]+') | ForEach-Object Value)
$expectedNames = @($armMods | ForEach-Object {
        [regex]::Match((Get-Content -LiteralPath (Join-Path $_ 'descriptor.mod') -Raw), '(?m)^name="([^"]+)"').Groups[1].Value
    })
if ($telemetryModules) { $expectedNames += $telemetryName }
$missingMods = @($expectedNames | Where-Object { $name = $_; -not ($mountLines | Where-Object { $_ -like "*Mod $name (*" }) })
$unexpectedMounts = @($mountLines | Where-Object { $line = $_; -not ($expectedNames | Where-Object { $line -like "*Mod $_ (*" }) })

$modFiles = @($armMods | ForEach-Object {
        $root = $_
        Get-ChildItem -LiteralPath $root -Recurse -File -Include '*.txt', '*.yml', '*.gui' |
            Where-Object { $_.FullName -notlike (Join-Path $root 'tools\*') } |
            ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace('\', '/') }
    } | Sort-Object -Unique)
$messages = $errorLines | ForEach-Object { $_ -replace '^\[\d\d:\d\d:\d\d\]', '' }
$shadowLines = @($messages | Where-Object { $_ -match 'Duplicated key .* will not be created' })
$boiLines = @($messages | Where-Object {
        $line = $_
        if ($line -match 'Duplicated key .* will not be created') { return $false }
        if ($line -match '(?i)boitm') { return $false }
        if ($line -match '(?i)boi_|BurdenOfInfastructure') { return $true }
        foreach ($file in $modFiles) { if ($line.Contains($file)) { return $true } }
        $false
    } | Sort-Object -Unique)
$telemetryErrors = @($messages | Where-Object { $_ -match '(?i)boitm' } | Sort-Object -Unique)
# A data function that fails to resolve leaves its key with no value.
$telemetryLines = @([regex]::Matches($debugText, 'BOITM\|[^\r\n]*') | ForEach-Object Value)
$blankTelemetry = @($telemetryLines | Where-Object { $_ -match '=(;|$)' } |
    ForEach-Object { ($_ -split '\|')[1] } | Sort-Object -Unique)
$topSources =$messages | ForEach-Object { if ($_ -match '^\[([^\]]+)\]') { $Matches[1] } } |
    Group-Object | Sort-Object Count -Descending | Select-Object -First 15

$failures = @()
if ($exitReason -ne 'exited on its own') { $failures += $exitReason }
if ($crashDumps) { $failures += "crash dump(s): $($crashDumps -join ', ')" }
if ($missingMods) { $failures += "not mounted: $($missingMods -join ', ')" }
if ($unexpectedMounts) { $failures += "unexpected mount(s): $($unexpectedMounts -join ' | ')" }
if ($boiLines) { $failures += "$($boiLines.Count) unique BOI error line(s)" }
if ($telemetryErrors) { $failures += "$($telemetryErrors.Count) unique telemetry error line(s)" }
if ($blankTelemetry) { $failures += "telemetry group(s) with blank values: $($blankTelemetry -join ', ')" }

Set-Content -LiteralPath (Join-Path $runDir 'boi_errors.log') -Value (@($boiLines) + @($telemetryErrors)) -Encoding UTF8
$summary = @(
    "# Headless run $(Split-Path $runDir -Leaf)",
    '',
    "- Result: $(if ($failures) { 'FAIL - ' + ($failures -join '; ') } else { 'PASS' })",
    "- Arm: $arm; until $UntilDate; autosave $Autosave; args: $($gameArgs -join ' ')",
    "- Exit: $exitReason after $([int]$elapsed.TotalMinutes) min; autosaves copied: $saveIndex",
    "- Mounted: $(if ($mountLines) { $mountLines -join ' | ' } else { 'none' })",
    "- error.log: $($errorLines.Count) lines, $(@($messages | Sort-Object -Unique).Count) unique; shadow 'Duplicated key' lines: $($shadowLines.Count)",
    "- BOI-attributed unique lines: $($boiLines.Count) (see boi_errors.log)",
    "- Telemetry: $(if ($telemetryModules) { "modules $($telemetryModules -join ', '); $($telemetryLines.Count) BOITM lines; $($telemetryErrors.Count) error lines" } else { 'off' })",
    '',
    '## Top error sources',
    ''
) + @($topSources | ForEach-Object { "- $($_.Count) x $($_.Name)" })
if ($boiLines -or $telemetryErrors) {
    $summary += @('', '## BOI and telemetry lines (first 40)', '') +
        @(@($boiLines) + @($telemetryErrors) | Select-Object -First 40 | ForEach-Object { "    $_" })
}
$summary | Set-Content -LiteralPath (Join-Path $runDir 'summary.md') -Encoding UTF8
$summary | Write-Host

if ($failures) { exit 1 }
Write-Host "PASS: headless $arm run reached $UntilDate cleanly. Output: $runDir"
exit 0
