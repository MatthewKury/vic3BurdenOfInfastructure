# Runs one unattended observer game (-handsoff -run_until) with BOI (plus any
# -ExtraMods) or vanilla (-Control), mirrors the logs and autosaves into
# tools/headless-runs/<stamp>_<arm>/, then checks error.log for BOI-attributable
# errors. Exits non-zero on BOI or telemetry errors, a missing (or unexpected)
# mod mount, a crash, or a timeout. Housing is part of BOI, so the mod arm
# needs no -ExtraMods; that switch is for testing other mods alongside BOI.
#
# Unless -NoTelemetry, both arms also load a telemetry mod assembled into the
# run folder from tools/headless-telemetry/: the core module always, and the
# boi / housing modules when a loaded mod defines horses / boi_housing (BOI
# defines both). Its BOITM| lines in debug.log are read by
# tools/Get-HeadlessReport.ps1. With housing, the fixtures module also runs the
# housing debug events as Portugal (skip with -NoFixtures); its BOIFIX| checks
# (and the rail_survey module's, with -RailSurvey)
# are summarised here, and any "fail" fails the run. -Ensemble adds the
# quarterly all-country snapshot module (BOIENS| lines) that
# tools/Invoke-HeadlessEnsemble.ps1 collects into an ensemble database.
# Every run also writes run.json, the machine-readable form of summary.md.
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
    [int]$StallMinutes = 5,
    [ValidateSet('never', 'monthly', 'quarteryear', 'halfyear', 'yearly', 'five_year')]
    [string]$Autosave = 'yearly',
    [switch]$Control,
    [switch]$DebugMode,
    [switch]$NoSaves,
    [string[]]$ExtraMods,
    [switch]$NoTelemetry,
    [switch]$NoFixtures,
    [switch]$Ensemble,
    [switch]$Probes,
    # One-off checks of the 2026-11-09 fixes (headless-telemetry/checks).
    [switch]$Checks,
    [switch]$LongRun,
    [switch]$RailSurvey,
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
    # The autosave copies (about 340 MB a run) are only needed until restored.
    Get-ChildItem -LiteralPath $backup -Filter 'autosave*.v3' -File | Remove-Item -Force
    Write-Host "Restored player state from $backup"
}

if ($RestoreFrom) {
    Restore-PlayerState (Resolve-Path -LiteralPath $RestoreFrom).Path
    return
}

if ($UntilDate -notmatch '^\d{4}\.\d{1,2}\.\d{1,2}$') { throw "UntilDate must look like 1837.1.1, got '$UntilDate'" }
if ($Ensemble -and $NoTelemetry) { throw '-Ensemble is a telemetry module; it cannot be combined with -NoTelemetry.' }
$exe = Join-Path $GamePath 'binaries\victoria3.exe'
if (-not (Test-Path -LiteralPath $exe)) { throw "victoria3.exe not found at $exe" }
if (-not (Test-Path -LiteralPath (Join-Path $userDir 'content_load.json'))) { throw "content_load.json not found in $userDir" }
if (Get-Process -Name victoria3 -ErrorAction SilentlyContinue) { throw 'victoria3.exe is already running; close it first.' }
if (Test-Path -LiteralPath $runsRoot) {
    $pending = Get-ChildItem -LiteralPath $runsRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'backup\PENDING') }
    if ($pending) { throw "Run '$($pending[0].Name)' never restored player state. Run: Test-Headless.ps1 -RestoreFrom '$($pending[0].FullName)'" }
}

# Read from the install, so a patch doesn't need this script edited: the telemetry
# mod declares the installed version, and run.json records version and Steam build.
$launcherSettings = [IO.File]::ReadAllText((Join-Path $GamePath 'launcher\launcher-settings.json'))
$installedVersion = [regex]::Match($launcherSettings, '"rawVersion"\s*:\s*"([^"]+)"').Groups[1].Value
if (-not $installedVersion) { throw 'No rawVersion in launcher-settings.json' }
$installedMinor = ($installedVersion -split '\.')[0..1] -join '.'
$appManifest = Join-Path $GamePath '..\..\appmanifest_529340.acf'
$gameBuild = if (Test-Path -LiteralPath $appManifest) { [regex]::Match([IO.File]::ReadAllText($appManifest), '"buildid"\s+"(\d+)"').Groups[1].Value } else { $null }

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
    # The vanilla-readable lines of the boi and housing modules, under the same keys.
    if ($Control) { $telemetryModules += 'parity' }
    if ($armMods | Where-Object { Test-DefinesGoods $_ 'horses' }) {
        $telemetryModules += 'boi'
        # Long runs with this module's yearly event crash; see the lessons file.
        if (-not $LongRun) { $telemetryModules += 'boi_states' }
        # Stand-in players: Rail Network Surveys for a few AI countries.
        if ($RailSurvey) { $telemetryModules += 'rail_survey' }
    }
    if ($armMods | Where-Object { Test-DefinesGoods $_ 'boi_housing' }) {
        $telemetryModules += 'housing'
        if (-not $NoFixtures) { $telemetryModules += 'fixtures' }
    }
    if ($Ensemble) { $telemetryModules += 'ensemble' }
    if ($Probes) { $telemetryModules += 'probes' }
    if ($Checks) { $telemetryModules += 'checks' }
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
        game_id = 'victoria3'; supported_game_version = $installedMinor
        short_description = "Test-only telemetry ($($telemetryModules -join ', ')), generated by tools/Test-Headless.ps1."
        tags = @(); relationships = @(); game_custom_data = @{ multiplayer_synchronized = $true }
    }
    [IO.File]::WriteAllText((Join-Path $telemetryPath '.metadata\metadata.json'), ($telemetryMeta | ConvertTo-Json), $utf8NoBom)
    [IO.File]::WriteAllText((Join-Path $telemetryPath 'descriptor.mod'), "name=`"$telemetryName`"`nversion=`"1`"`nsupported_version=`"$installedMinor.*`"`n", $utf8NoBom)
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
    # rotates again at launch, so copy new bytes as they appear. An ensemble
    # snapshot writes about 2 MB within a second, so several rotations can land
    # between two polls. Each file is identified by its first $headSize bytes:
    # Head is the file being read (adopted only once it has a full head, since
    # a short prefix like "[11:38:3" also matches the next file), Offset how far
    # into it, and Done the newest file read to the end, so files that rotated
    # past before being adopted are still found among .1 ... .5.
    $mirrors = @{}
    foreach ($name in 'error', 'debug', 'game') {
        $mirrors[$name] = @{ Offset = 0L; Live = $false; Initial = $true; Head = [byte[]]@(); Done = [byte[]]@() }
    }
    $copiedSaves = @{}
    $saveIndex = 0
    $rotationOverruns = 0
    $headSize = 256

    function Read-StreamTail([IO.Stream]$Stream, [long]$From) {
        $length = $Stream.Length
        if ($From -ge $length) { return ,([byte[]]@()) }
        $Stream.Seek($From, 'Begin') | Out-Null
        $buffer = New-Object byte[] ($length - $From)
        $read = $Stream.Read($buffer, 0, $buffer.Length)
        if ($read -lt $buffer.Length) { [Array]::Resize([ref]$buffer, $read) }
        return ,$buffer
    }

    function Read-StreamHead([IO.Stream]$Stream) {
        $Stream.Seek(0, 'Begin') | Out-Null
        $buffer = New-Object byte[] ([Math]::Min([long]$headSize, $Stream.Length))
        $read = $Stream.Read($buffer, 0, $buffer.Length)
        if ($read -lt $buffer.Length) { [Array]::Resize([ref]$buffer, $read) }
        return ,$buffer
    }

    # True when Candidate starts with Known, i.e. it is the same file grown.
    function Test-SameHead([byte[]]$Known, [byte[]]$Candidate) {
        if ($Candidate.Length -lt $Known.Length) { return $false }
        for ($i = 0; $i -lt $Known.Length; $i++) { if ($Known[$i] -ne $Candidate[$i]) { return $false } }
        $true
    }

    function Add-Bytes([string]$Path, [byte[]]$Bytes) {
        if (-not $Bytes.Length) { return }
        $stream = [IO.File]::Open($Path, 'Append', 'Write', 'Read')
        try { $stream.Write($Bytes, 0, $Bytes.Length) } finally { $stream.Dispose() }
    }

    # One poll of one log. Handles[0] is <name>.log, Handles[k] is <name>.k.log;
    # all were opened together, and an open handle follows its file through
    # renames, so indices can't shift while this runs.
    function Sync-Log($State, [hashtable]$Handles, [hashtable]$Heads, [hashtable]$Fresh, [string]$Out, [bool]$Final) {
        function Find-Rotated([byte[]]$Known) {
            foreach ($k in 1..5) { if ($Heads.ContainsKey($k) -and (Test-SameHead $Known $Heads[$k])) { return $k } }
            0
        }
        if ($State.Initial) {
            # First sight of this run's log: files that already rotated away
            # since launch (written after it) come first, oldest first.
            for ($k = 5; $k -ge 1; $k--) {
                if ($Handles.ContainsKey($k) -and $Fresh[$k]) {
                    Add-Bytes $Out (Read-StreamTail $Handles[$k] 0)
                    $State.Done = $Heads[$k]
                }
            }
            $State.Initial = $false
        }
        if ($State.Head.Length) {
            if ($Handles.ContainsKey(0) -and (Test-SameHead $State.Head $Heads[0])) {
                $bytes = Read-StreamTail $Handles[0] $State.Offset
                Add-Bytes $Out $bytes
                $State.Offset += $bytes.Length
                return
            }
            # Rotated away: finish it wherever it now sits.
            $k = Find-Rotated $State.Head
            if ($k) {
                Add-Bytes $Out (Read-StreamTail $Handles[$k] $State.Offset)
                $State.Done = $State.Head
            } else {
                $script:rotationOverruns++
                $State.Done = [byte[]]@()
            }
            $State.Head = [byte[]]@()
            $State.Offset = 0L
        }
        if ($State.Done.Length) {
            # Whole files newer than the last finished one.
            $j = Find-Rotated $State.Done
            if ($j) {
                for ($k = $j - 1; $k -ge 1; $k--) {
                    Add-Bytes $Out (Read-StreamTail $Handles[$k] 0)
                    $State.Done = $Heads[$k]
                }
            } else {
                $script:rotationOverruns++
                $State.Done = [byte[]]@()
            }
        }
        if ($Handles.ContainsKey(0) -and ($Heads[0].Length -ge $headSize -or $Final)) {
            $State.Head = $Heads[0]
            $bytes = Read-StreamTail $Handles[0] 0
            Add-Bytes $Out $bytes
            $State.Offset = $bytes.Length
            $State.Done = [byte[]]@()
        }
    }

    function Update-Mirrors([switch]$Final) {
        foreach ($name in @($mirrors.Keys)) {
            $state = $mirrors[$name]
            $live = Join-Path $logDir "$name.log"
            if (-not (Test-Path -LiteralPath $live)) { continue }
            if (-not $state.Live) {
                if ((Get-Item -LiteralPath $live).LastWriteTime -lt $launchTime.AddSeconds(-2)) { continue }
                $state.Live = $true
            }
            $out = Join-Path $mirrorDir "$name.log"
            for ($attempt = 0; $attempt -lt 3; $attempt++) {
                $handles = @{}
                $heads = @{}
                try {
                    foreach ($k in 0..5) {
                        $path = if ($k) { Join-Path $logDir "$name.$k.log" } else { $live }
                        try { $handles[$k] = [IO.File]::Open($path, 'Open', 'Read', 'ReadWrite, Delete') } catch [IO.IOException] { }
                    }
                    foreach ($k in @($handles.Keys)) { $heads[$k] = Read-StreamHead $handles[$k] }
                    # A rotation while the handles were opening shows up as one
                    # file under two names; try again.
                    $distinct = @($heads.Values | Where-Object { $_.Length } |
                        ForEach-Object { [Convert]::ToBase64String($_) } | Sort-Object -Unique).Count
                    if ($distinct -lt @($heads.Values | Where-Object { $_.Length }).Count) { continue }
                    $fresh = @{}
                    foreach ($k in 1..5) {
                        $fresh[$k] = [IO.File]::GetLastWriteTime((Join-Path $logDir "$name.$k.log")) -ge $launchTime.AddSeconds(-2)
                    }
                    Sync-Log $state $handles $heads $fresh $out $Final.IsPresent
                    break
                } catch [IO.IOException] {
                } finally {
                    foreach ($stream in $handles.Values) { $stream.Dispose() }
                }
            }
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
    # The game sometimes hangs after reaching -run_until instead of quitting
    # (seen once for 18 min, 1.13.11), so silence in debug.log ends the run.
    $lastGrowth = Get-Date
    $lastSize = -1L
    $debugMirrorPath = Join-Path $mirrorDir 'debug.log'
    while (-not $process.HasExited) {
        # An ensemble snapshot rotates debug.log four times in about a second,
        # and the ring holds five, so poll often.
        Start-Sleep -Milliseconds 500
        Update-Mirrors
        if ((Get-Date) -gt $deadline) {
            Stop-Process -Id $process.Id -Force
            $process.WaitForExit()
            $exitReason = "timeout after $TimeoutMinutes min"
            break
        }
        $size = if (Test-Path -LiteralPath $debugMirrorPath) { (Get-Item -LiteralPath $debugMirrorPath).Length } else { 0L }
        if ($size -ne $lastSize) {
            $lastSize = $size
            $lastGrowth = Get-Date
        } elseif (((Get-Date) - $lastGrowth).TotalMinutes -ge $StallMinutes) {
            Stop-Process -Id $process.Id -Force
            $process.WaitForExit()
            $exitReason = "stalled: no log output for $StallMinutes min"
            break
        }
        if (((Get-Date) - $lastReport).TotalMinutes -ge 2) {
            $lastReport = Get-Date
            Write-Host ('  {0:N0} min elapsed, {1} autosave(s) copied' -f ((Get-Date) - $launchTime).TotalMinutes, $saveIndex)
        }
    }
    Start-Sleep -Seconds 3
    Update-Mirrors
    Update-Mirrors -Final

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

# Read debug.log a line at a time. An ensemble logs about 8 MB per game year, so a
# century's log is about 1 GB, past the longest string .NET Framework can hold.
$mountLines = New-Object Collections.Generic.List[string]
$fixtureLines = New-Object Collections.Generic.List[string]
$ensembleSnapshots = New-Object Collections.Generic.List[string]
$telemetryCount = 0
$ensembleCount = 0
# A data function that fails to resolve leaves its key with no value.
$blankPattern = [regex]'=(;|$)'
$mountPattern = [regex]'dlc\.cpp:\d+\]: Mod .+'
$blankTelemetrySet = @{}
$blankEnsembleSet = @{}
$ordinal = [StringComparison]::Ordinal
if (Test-Path -LiteralPath $debugMirror) {
    $reader = [IO.File]::OpenText($debugMirror)
    try {
        while ($null -ne ($line = $reader.ReadLine())) {
            $i = $line.IndexOf('BOIENS|', $ordinal)
            if ($i -ge 0) {
                $body = $line.Substring($i)
                $ensembleCount++
                if ($blankPattern.IsMatch($body)) { $blankEnsembleSet[($body -split '\|')[1]] = $true }
                if ($body.StartsWith('BOIENS|snapshot|', $ordinal)) { $ensembleSnapshots.Add(($body -split '\|')[2]) }
                continue
            }
            $i = $line.IndexOf('BOITM|', $ordinal)
            if ($i -ge 0) {
                $body = $line.Substring($i)
                $telemetryCount++
                if ($blankPattern.IsMatch($body)) { $blankTelemetrySet[($body -split '\|')[1]] = $true }
                continue
            }
            $i = $line.IndexOf('BOIFIX|', $ordinal)
            if ($i -ge 0) {
                $fixtureLines.Add($line.Substring($i))
                continue
            }
            if ($line.IndexOf('dlc.cpp:', $ordinal) -ge 0) {
                $match = $mountPattern.Match($line)
                if ($match.Success) { $mountLines.Add($match.Value) }
            }
        }
    } finally {
        $reader.Dispose()
    }
}
$mountLines = @($mountLines)
$fixtureLines = @($fixtureLines)
$ensembleSnapshots = @($ensembleSnapshots)
$blankTelemetry = @($blankTelemetrySet.Keys | Sort-Object)
$blankEnsemble = @($blankEnsembleSet.Keys | Sort-Object)

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
# Console-only debug events (housing fixtures boi_housing.2-.5, see
# docs/HOUSING_TESTING.md) are referenced by nothing in the shipped mod, so the
# engine logs them as orphaned at launch. The fixtures module references them,
# so the lines only appear in -NoFixtures runs. Expected; counted separately,
# not as errors.
$expectedPatterns = @('Event boi_housing\.[2345] is orphaned$')
$expectedLines = @($messages | Where-Object { $line = $_; $expectedPatterns | Where-Object { $line -match $_ } } | Sort-Object -Unique)
$boiLines = @($messages | Where-Object {
        $line = $_
        if ($line -match 'Duplicated key .* will not be created') { return $false }
        if ($expectedPatterns | Where-Object { $line -match $_ }) { return $false }
        if ($line -match '(?i)boitm|BOIENS') { return $false }
        if ($line -match '(?i)boi_|BurdenOfInfrastructure') { return $true }
        foreach ($file in $modFiles) { if ($line.Contains($file)) { return $true } }
        $false
    } | Sort-Object -Unique)
$telemetryErrors = @($messages | Where-Object { $_ -match '(?i)boitm|BOIENS' } | Sort-Object -Unique)
# Housing fixture checks: BOIFIX|<date>|<check>|<pass/fail/warn/info>|<detail>
$fixtures = @($fixtureLines | ForEach-Object {
        $parts = $_ -split '\|', 5
        [pscustomobject]@{ Date = $parts[1]; Check = $parts[2]; Result = $parts[3]; Detail = $parts[4] }
    })
$fixtureFailures = @($fixtures | Where-Object Result -eq 'fail' | ForEach-Object Check)
$blankFixtures = @($fixtures | Where-Object { $_.Detail -match '=(;|$)' } | ForEach-Object Check)
$fixtureStatus = if (-not ($telemetryModules -contains 'fixtures')) { 'off' }
    elseif (-not $fixtures) { 'did not run (Portugal missing, or the run ended before 1836.2.1)' }
    elseif (-not ($fixtures | Where-Object Check -eq 'complete')) { "incomplete ($($fixtures.Count) lines; the chain takes about 100 days)" }
    else { "$(@($fixtures | Where-Object Result -eq 'pass').Count) pass, $(@($fixtures | Where-Object Result -eq 'warn').Count) warn, $($fixtureFailures.Count) fail" }
$topSources =$messages | ForEach-Object { if ($_ -match '^\[([^\]]+)\]') { $Matches[1] } } |
    Group-Object | Sort-Object Count -Descending | Select-Object -First 15

$failures = @()
# A stall after the ensemble's last snapshot (the quarter of -UntilDate) is the
# exit hang: the data is complete, so it does not fail the run.
$stallAfterEnd = $false
if ($exitReason -like 'stalled*' -and $ensembleSnapshots) {
    $culture = [Globalization.CultureInfo]::InvariantCulture
    $last = [datetime]::ParseExact($ensembleSnapshots[-1], 'MMMM d, yyyy', $culture)
    $until = [datetime]::ParseExact($UntilDate, 'yyyy.M.d', $culture)
    $stallAfterEnd = $last.Year -eq $until.Year -and [math]::Floor(($last.Month - 1) / 3) -eq [math]::Floor(($until.Month - 1) / 3)
    if ($stallAfterEnd) { $exitReason += ' after the last snapshot; killed' }
}
if ($exitReason -ne 'exited on its own' -and -not $stallAfterEnd) { $failures += $exitReason }
if ($crashDumps) { $failures += "crash dump(s): $($crashDumps -join ', ')" }
if ($missingMods) { $failures += "not mounted: $($missingMods -join ', ')" }
if ($unexpectedMounts) { $failures += "unexpected mount(s): $($unexpectedMounts -join ' | ')" }
if ($boiLines) { $failures += "$($boiLines.Count) unique BOI error line(s)" }
if ($telemetryErrors) { $failures += "$($telemetryErrors.Count) unique telemetry error line(s)" }
if ($blankTelemetry) { $failures += "telemetry group(s) with blank values: $($blankTelemetry -join ', ')" }
if ($blankEnsemble) { $failures += "ensemble group(s) with blank values: $($blankEnsemble -join ', ')" }
if ($rotationOverruns) { $failures += "log mirror lost $rotationOverruns rotation(s): over 5 rotations between polls" }
if ($fixtureFailures) { $failures += "housing fixture check(s) failed: $($fixtureFailures -join ', ')" }
if ($blankFixtures) { $failures += "housing fixture check(s) with blank values: $($blankFixtures -join ', ')" }

Set-Content -LiteralPath (Join-Path $runDir 'boi_errors.log') -Value (@($boiLines) + @($telemetryErrors)) -Encoding UTF8
$summary = @(
    "# Headless run $(Split-Path $runDir -Leaf)",
    '',
    "- Result: $(if ($failures) { 'FAIL - ' + ($failures -join '; ') } else { 'PASS' })",
    "- Arm: $arm; until $UntilDate; autosave $Autosave; args: $($gameArgs -join ' ')",
    "- Exit: $exitReason after $([int]$elapsed.TotalMinutes) min; autosaves copied: $saveIndex",
    "- Mounted: $(if ($mountLines) { $mountLines -join ' | ' } else { 'none' })",
    "- error.log: $($errorLines.Count) lines, $(@($messages | Sort-Object -Unique).Count) unique; shadow 'Duplicated key' lines: $($shadowLines.Count)",
    "- BOI-attributed unique lines: $($boiLines.Count) (see boi_errors.log); expected debug-event lines: $($expectedLines.Count)",
    "- Telemetry: $(if ($telemetryModules) { "modules $($telemetryModules -join ', '); $telemetryCount BOITM lines; $($telemetryErrors.Count) error lines" } else { 'off' })",
    "- Housing fixtures: $fixtureStatus",
    "- Ensemble: $(if ($telemetryModules -contains 'ensemble') { "$($ensembleSnapshots.Count) snapshot(s), $ensembleCount BOIENS lines; first $($ensembleSnapshots | Select-Object -First 1), last $($ensembleSnapshots | Select-Object -Last 1)" } else { 'off' })",
    '',
    '## Top error sources',
    ''
) + @($topSources | ForEach-Object { "- $($_.Count) x $($_.Name)" })
if ($fixtures) {
    $summary += @('', '## Housing fixture checks', '', '| date | check | result | detail |', '|---|---|---|---|') +
        @($fixtures | ForEach-Object { "| $($_.Date) | $($_.Check) | $($_.Result) | $($_.Detail) |" })
}
if ($boiLines -or $telemetryErrors) {
    $summary += @('', '## BOI and telemetry lines (first 40)', '') +
        @(@($boiLines) + @($telemetryErrors) | Select-Object -First 40 | ForEach-Object { "    $_" })
}
$summary | Set-Content -LiteralPath (Join-Path $runDir 'summary.md') -Encoding UTF8
$summary | Write-Host

# run.json: what summary.md says, for tools (Build-EnsembleDb.py stores it so
# an ensemble database outlives the run folders).
$gameVersion = ($mountLines | ForEach-Object { if ($_ -match 'matched game version (\S+?)\.?$') { $Matches[1] } } | Select-Object -First 1)
$dlcRoot = Join-Path $GamePath 'game\dlc'
$installedDlc = @(if (Test-Path -LiteralPath $dlcRoot) { Get-ChildItem -LiteralPath $dlcRoot -Directory | ForEach-Object Name })
$modInfo = @($armMods | ForEach-Object {
        $commit = $null; $dirty = $null
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $commit = (& git -C $_ rev-parse HEAD 2>$null)
            if ($commit) { $dirty = [bool](& git -C $_ status --porcelain 2>$null) }
        }
        [ordered]@{ path = $_; commit = $commit; dirty = $dirty }
    })
$runInfo = [ordered]@{
    run = Split-Path $runDir -Leaf
    arm = $arm
    result = if ($failures) { 'FAIL' } else { 'PASS' }
    failures = @($failures)
    until = $UntilDate
    autosave = $Autosave
    args = $gameArgs
    exit_reason = $exitReason
    minutes = [math]::Round($elapsed.TotalMinutes, 1)
    launched = $launchTime.ToUniversalTime().ToString('o')
    game_version = if ($gameVersion) { $gameVersion } else { $installedVersion }
    game_build = $gameBuild
    mods = $modInfo
    telemetry_modules = @($telemetryModules)
    installed_dlc = $installedDlc
    disabled_dlc = @($disabledDlc | ForEach-Object { $_.paradoxAppId })
    ensemble_snapshots = $ensembleSnapshots.Count
    ensemble_lines = $ensembleCount
    rotation_overruns = $rotationOverruns
}
[IO.File]::WriteAllText((Join-Path $runDir 'run.json'), ($runInfo | ConvertTo-Json -Depth 5), $utf8NoBom)

if ($failures) { exit 1 }
Write-Host "PASS: headless $arm run reached $UntilDate cleanly. Output: $runDir"
exit 0
