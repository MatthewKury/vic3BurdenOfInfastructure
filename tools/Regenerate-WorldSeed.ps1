[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game',
    [string]$ModPath
)

$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
$awk = Get-Command awk -ErrorAction SilentlyContinue
if ($awk) { $awkPath = $awk.Source }
elseif (Test-Path 'C:\Program Files\Git\usr\bin\awk.exe') { $awkPath = 'C:\Program Files\Git\usr\bin\awk.exe' }
else { throw 'awk is required to regenerate the 1836 world seed.' }

function Read-Data([string]$path) {
    [regex]::Replace(([IO.File]::ReadAllText($path).TrimStart([char]0xFEFF)), '(?m)#.*$', '')
}
function Get-Blocks([string]$data, [string]$keyPattern) {
    $pattern = '(?ms)(?<key>' + $keyPattern + ')\s*(?:\?=|=)\s*\{(?<body>(?:[^{}]|(?<open>\{)|(?<-open>\}))*)(?(open)(?!))\}'
    foreach ($m in [regex]::Matches($data, $pattern)) {
        [pscustomobject]@{ Key = $m.Groups['key'].Value; Body = $m.Groups['body'].Value }
    }
}
function Write-Utf8NoBom([string]$path, [string[]]$lines) {
    [IO.File]::WriteAllText($path, (($lines -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))
}

& (Join-Path $PSScriptRoot 'Get-StartingInfrastructure.ps1') -GamePath $GamePath -ModPath $ModPath
$temporary = Join-Path $env:TEMP ('boi-seed-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
    $pairsPath = Join-Path $temporary 'pairs.txt'
    $ranchPath = Join-Path $temporary 'ranch.txt'
    $regionsPath = Join-Path $temporary 'owned_regions.txt'
    $outPath = Join-Path $temporary 'generated_seed.txt'
    $errPath = Join-Path $temporary 'awk_errors.txt'

    $pairs = @()
    $owned = @{}
    $statesFile = Join-Path $GamePath 'common/history/states/00_states.txt'
    foreach ($state in (Get-Blocks (Read-Data $statesFile) 's:STATE_[A-Z0-9_]+')) {
        $name = $state.Key.Substring(2)
        foreach ($create in (Get-Blocks $state.Body 'create_state')) {
            $match = [regex]::Match($create.Body, '\bcountry\s*=\s*"?c:([A-Z0-9_]+)')
            if (-not $match.Success) { throw "Owner missing in $name." }
            $pairs += "$name`t$($match.Groups[1].Value)"
            $owned[$name] = $true
        }
    }
    Write-Utf8NoBom $pairsPath $pairs

    $regions = @()
    foreach ($file in (Get-ChildItem (Join-Path $ModPath 'map_data/state_regions') -Filter '*.txt')) {
        foreach ($state in (Get-Blocks (Read-Data $file.FullName) 'STATE_[A-Z0-9_]+')) {
            if (-not $owned.ContainsKey($state.Key)) { continue }
            $arable = [regex]::Match($state.Body, '\barable_land\s*=\s*(\d+)')
            if (-not $arable.Success) { throw "Arable land missing in $($state.Key)." }
            $port = if ($state.Body -match '\bport\s*=') { 1 } else { 0 }
            $regions += "$($state.Key)`t$port`t$($arable.Groups[1].Value)"
        }
    }
    $regions = @($regions | Sort-Object)
    if ($regions.Count -ne $owned.Count) { throw "Found $($regions.Count) owned map regions, expected $($owned.Count)." }
    Write-Utf8NoBom $regionsPath $regions
    Copy-Item -LiteralPath (Join-Path $ModPath 'tools/horse_seed_baseline.txt') -Destination $ranchPath

    $scriptPath = Join-Path $ModPath 'tools/gen_seed.awk'
    $additions = Join-Path $ModPath 'tools/horse_seed_additions.tsv'
    $holds = Join-Path $ModPath 'tools/horse_seed_holds.tsv'
    $reductions = Join-Path $ModPath 'tools/horse_seed_reductions.tsv'
    $plan = Join-Path $ModPath 'tools/infrastructure_seed_plan.tsv'
    $arguments = @('-f', $scriptPath, $pairsPath, $ranchPath, $regionsPath, $additions, $holds, $plan, $reductions) |
        ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $awkPath '-f' $scriptPath $pairsPath $ranchPath $regionsPath $additions $holds $plan $reductions 1> $outPath 2> $errPath
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $messages = [IO.File]::ReadAllText($errPath)
    if ($exitCode -ne 0) { throw "AWK seed generation failed: $messages" }
    [IO.File]::WriteAllText($outPath, [IO.File]::ReadAllText($outPath), [Text.UTF8Encoding]::new($true))
    $bytes = [IO.File]::ReadAllBytes($outPath)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        throw 'Generated seed is missing its UTF-8 BOM.'
    }
    Copy-Item -LiteralPath $outPath -Destination (Join-Path $ModPath 'common/history/buildings/zz_boi_buildings.txt') -Force
    Write-Host $messages.Trim()
}
finally {
    foreach ($name in @('pairs.txt','ranch.txt','owned_regions.txt','generated_seed.txt','awk_errors.txt')) {
        Remove-Item -LiteralPath (Join-Path $temporary $name) -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue
}
