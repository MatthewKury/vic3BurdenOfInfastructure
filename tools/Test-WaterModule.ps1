[CmdletBinding()]
param(
    [string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game',
    [string]$ModPath
)

# Static checks for the Waterworks module. They prove the files agree with each
# other and with the installed game; they do NOT prove in-game behaviour. See
# tools/water-prototype/README.md for the runtime checklist.
$ErrorActionPreference = 'Stop'
if (-not $ModPath) { $ModPath = Split-Path $PSScriptRoot -Parent }
. (Join-Path $PSScriptRoot 'Housing-ScriptTools.ps1')

function Read-Mod([string]$relative) {
    $path = Join-Path $ModPath $relative
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing water module file: $relative" }
    [IO.File]::ReadAllText($path).TrimStart([char]0xFEFF)
}
function Strip-Comments([string]$text) { [regex]::Replace($text, '(?m)#.*$', '') }
function Fail([string]$message) { throw "Water module: $message" }

$goodsText = Strip-Comments (Read-Mod 'common/goods/51_boi_water_goods.txt')
$modText = Strip-Comments (Read-Mod 'common/modifier_type_definitions/51_boi_water_modifier_types.txt')
$groupText = Strip-Comments (Read-Mod 'common/building_groups/51_boi_water_building_groups.txt')
$buildingText = Strip-Comments (Read-Mod 'common/buildings/51_boi_waterworks.txt')
$pmgText = Strip-Comments (Read-Mod 'common/production_method_groups/51_boi_waterworks_pm_groups.txt')
$pmText = Strip-Comments (Read-Mod 'common/production_methods/51_boi_waterworks.txt')
$traitText = Strip-Comments (Read-Mod 'common/state_traits/51_boi_water.txt')
$popNeedText = Strip-Comments (Read-Mod 'common/pop_needs/50_boi_water.txt')
$locText = Read-Mod 'localization/english/boi_water_l_english.yml'

# --- Goods -------------------------------------------------------------------
$goods = @{}
foreach ($b in (Get-HousingScriptBlocks $goodsText)) { $goods[$b.Key] = $b.Text }
foreach ($g in 'water', 'bulk_water') { if (-not $goods.ContainsKey($g)) { Fail "good $g is not defined." } }
if ($goods['water'] -notmatch '(?m)^\s*local\s*=\s*yes') { Fail 'water must be local = yes.' }
if ($goods['bulk_water'] -match '(?m)^\s*local\s*=\s*yes') { Fail 'bulk_water must NOT be local.' }
$costWater = [regex]::Match($goods['water'], '(?m)^\s*cost\s*=\s*(\d+)').Groups[1].Value
$costBulk = [regex]::Match($goods['bulk_water'], '(?m)^\s*cost\s*=\s*(\d+)').Groups[1].Value
if (-not $costWater -or $costWater -ne $costBulk) { Fail "water ($costWater) and bulk_water ($costBulk) must have the same cost." }
if ($popNeedText -notmatch 'goods\s*=\s*water') { Fail 'popneed_boi_water must consume water.' }

# --- Every goods modifier used anywhere must be declared (vanilla or mod) ----
$declared = @{}
foreach ($root in @($GamePath, $ModPath)) {
    foreach ($file in (Get-ChildItem (Join-Path $root 'common/modifier_type_definitions') -Filter '*.txt')) {
        foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName), '(?m)^([a-z0-9_]+)\s*=\s*\{')) { $declared[$m.Groups[1].Value] = $true }
    }
}
$used = [Collections.Generic.HashSet[string]]::new()
foreach ($text in @($pmText, $traitText)) {
    foreach ($m in [regex]::Matches($text, '\b(goods_(?:input|output)_[a-z_]+_(?:add|mult))\b')) { [void]$used.Add($m.Groups[1].Value) }
}
$undeclared = @($used | Where-Object { -not $declared.ContainsKey($_) } | Sort-Object)
if ($undeclared.Count) { Fail "undeclared goods modifier types (hard load error): $($undeclared -join ', ')" }
foreach ($good in 'water', 'bulk_water') {
    foreach ($dir in 'input', 'output') { foreach ($op in 'add', 'mult') {
        if (-not $declared.ContainsKey("goods_${dir}_${good}_${op}")) { Fail "goods_${dir}_${good}_${op} is not declared." }
    } }
}

# --- Production methods and groups agree --------------------------------------
$pms = @{}
foreach ($b in (Get-HousingScriptBlocks $pmText)) { $pms[$b.Key] = $b.Text }
$pmgs = @{}
foreach ($b in (Get-HousingScriptBlocks $pmgText)) { $pmgs[$b.Key] = $b.Text }
$listed = @{}
foreach ($key in $pmgs.Keys) {
    $inner = [regex]::Match($pmgs[$key], 'production_methods\s*=\s*\{([^}]*)\}').Groups[1].Value
    foreach ($name in ($inner -split '\s+' | Where-Object { $_ })) {
        if (-not $pms.ContainsKey($name)) { Fail "$key lists $name, which is not defined." }
        if ($listed.ContainsKey($name)) { Fail "$name is listed in two groups." }
        $listed[$name] = $key
    }
}
foreach ($name in $pms.Keys) { if (-not $listed.ContainsKey($name)) { Fail "$name is defined but in no group." } }

$buildingPmgs = [regex]::Match($buildingText, 'production_method_groups\s*=\s*\{([^}]*)\}').Groups[1].Value -split '\s+' | Where-Object { $_ }
foreach ($g in $buildingPmgs) { if (-not $pmgs.ContainsKey($g)) { Fail "building lists unknown group $g." } }
foreach ($g in $pmgs.Keys) { if ($buildingPmgs -notcontains $g) { Fail "group $g is not attached to the building." } }
if ($buildingText -notmatch 'building_group\s*=\s*bg_boi_waterworks') { Fail 'building is not in bg_boi_waterworks.' }
if ($groupText -match 'parent_group\s*=\s*bg_extraction') { Fail 'bg_boi_waterworks must not inherit bg_extraction (capped_by_resources makes it unbuildable).' }
if ($buildingText -notmatch 'ownership_type\s*=\s*self') { Fail 'Waterworks must be privately owned.' }

# --- Export: no employment, lossy. Import: lossy. -----------------------------
foreach ($name in $pms.Keys) {
    $body = $pms[$name]
    if ($listed[$name] -eq 'pmg_boi_waterworks_export') {
        if ($body -match 'building_employment_') { Fail "$name is an export PM and must not set employment." }
        $in = [regex]::Match($body, 'goods_input_water_add\s*=\s*([\d.]+)').Groups[1].Value
        $out = [regex]::Match($body, 'goods_output_bulk_water_add\s*=\s*([\d.]+)').Groups[1].Value
        if ($in -or $out) {
            if (-not $in -or -not $out -or [double]$out -ge [double]$in) { Fail "$name must convert water to LESS bulk_water (in=$in out=$out)." }
        }
    }
    if ($body -match 'goods_input_bulk_water_add') {
        $in = [regex]::Match($body, 'goods_input_bulk_water_add\s*=\s*([\d.]+)').Groups[1].Value
        $out = [regex]::Match($body, 'goods_output_water_add\s*=\s*([\d.]+)').Groups[1].Value
        if (-not $out -or [double]$out -ge [double]$in) { Fail "$name must import to LESS water than bulk_water in (in=$in out=$out)." }
    }
    if ($listed[$name] -eq 'pmg_boi_waterworks_source' -and $body -notmatch 'goods_output_water_add') { Fail "$name is a source PM with no water output." }
}

# --- Admin group mirrors the Bureaucracy-law gates ----------------------------
$adminPms = @($pms.Keys | Where-Object { $listed[$_] -eq 'pmg_boi_waterworks_admin' })
$defaults = @($adminPms | Where-Object { $pms[$_] -match 'is_default\s*=\s*yes' })
if ($defaults.Count -ne 1) { Fail "admin group needs exactly one default PM, found $($defaults.Count)." }
$fallbackLaws = [regex]::Match($pms[$defaults[0]], 'disallowing_laws\s*=\s*\{([^}]*)\}').Groups[1].Value -split '\s+' | Where-Object { $_ }
foreach ($law in 'law_hereditary_bureaucrats', 'law_crownland_diets', 'law_elected_bureaucrats') {
    if ($fallbackLaws -notcontains $law) { Fail "admin fallback PM does not disallow $law." }
}

# --- Technologies and laws exist in the installed game ------------------------
$techKeys = @{}
foreach ($file in (Get-ChildItem (Join-Path $GamePath 'common/technology/technologies') -Filter '*.txt')) {
    foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName), '(?m)^([a-z0-9_]+)\s*=\s*\{')) { $techKeys[$m.Groups[1].Value] = $true }
}
$lawKeys = @{}
foreach ($file in (Get-ChildItem (Join-Path $GamePath 'common/laws') -Filter '*.txt')) {
    foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName), '(?m)^([a-z0-9_]+)\s*=\s*\{')) { $lawKeys[$m.Groups[1].Value] = $true }
}
foreach ($m in [regex]::Matches($pmText, 'unlocking_technologies\s*=\s*\{([^}]*)\}')) {
    foreach ($t in ($m.Groups[1].Value -split '\s+' | Where-Object { $_ })) { if (-not $techKeys.ContainsKey($t)) { Fail "unknown technology $t." } }
}
foreach ($m in [regex]::Matches($pmText, '(?:unlocking|disallowing)_laws\s*=\s*\{([^}]*)\}')) {
    foreach ($l in ($m.Groups[1].Value -split '\s+' | Where-Object { $_ })) { if (-not $lawKeys.ContainsKey($l)) { Fail "unknown law $l." } }
}

# --- New keys must not collide with vanilla (first-read-wins would hide ours) --
$vanillaKeys = [Collections.Generic.HashSet[string]]::new()
foreach ($folder in 'goods', 'buildings', 'building_groups', 'production_methods', 'production_method_groups', 'state_traits', 'pop_needs') {
    foreach ($file in (Get-ChildItem (Join-Path $GamePath "common/$folder") -Filter '*.txt')) {
        foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file.FullName), '(?m)^([a-z0-9_]+)\s*=\s*\{')) { [void]$vanillaKeys.Add($m.Groups[1].Value) }
    }
}
$ours = @($goods.Keys) + @($pms.Keys) + @($pmgs.Keys) + 'building_boi_waterworks', 'bg_boi_waterworks', 'popneed_boi_water'
foreach ($k in $ours) { if ($vanillaKeys.Contains($k)) { Fail "key $k collides with a vanilla key." } }

# --- Traits: defined, used in map_data, localised ------------------------------
$traits = @{}
foreach ($b in (Get-HousingScriptBlocks $traitText)) { $traits[$b.Key] = $b.Text }
$expectedTraits = 'state_trait_boi_water_abundant', 'state_trait_boi_summer_dry', 'state_trait_boi_arid_interior',
    'state_trait_boi_monsoon_dependent', 'state_trait_boi_irrigation_heritage', 'state_trait_boi_brackish_aquifer'
foreach ($t in $expectedTraits) { if (-not $traits.ContainsKey($t)) { Fail "trait $t is not defined." } }
$regionData = ''
foreach ($file in (Get-ChildItem (Join-Path $ModPath 'map_data/state_regions') -Filter '*.txt')) { $regionData += [IO.File]::ReadAllText($file.FullName) }
$assigned = @{}
foreach ($t in $expectedTraits) {
    $n = ([regex]::Matches($regionData, '"' + $t + '"')).Count
    if ($n -eq 0) { Fail "trait $t is assigned to no state. Run tools/Add-WaterTraits.ps1." }
    $assigned[$t] = $n
}
foreach ($m in [regex]::Matches($regionData, '"(state_trait_boi_[a-z_]+)"')) {
    if (-not $traits.ContainsKey($m.Groups[1].Value) -and $m.Groups[1].Value -ne 'state_trait_boi_horse_breeding_traditions') { Fail "map_data uses undefined trait $($m.Groups[1].Value)." }
}
$traitDeclared = [regex]::Matches($regionData, 'traits\s*=\s*\{[^}]*\}') | ForEach-Object { $_.Value }
foreach ($line in $traitDeclared) {
    $names = [regex]::Matches($line, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    if (@($names | Select-Object -Unique).Count -ne @($names).Count) { Fail "duplicate trait in a state's traits line: $line" }
}

# --- Localisation -------------------------------------------------------------
$needLoc = @('water', 'bulk_water', 'popneed_boi_water', 'building_boi_waterworks', 'building_boi_waterworks_lens_option', 'bg_boi_waterworks') +
    @($pms.Keys) + @($pmgs.Keys) + $expectedTraits
foreach ($key in $needLoc) {
    if ($locText -notmatch ('(?m)^ ' + [regex]::Escape($key) + ':\d+ "')) { Fail "missing localisation key $key." }
}
foreach ($good in 'water', 'bulk_water') { foreach ($dir in 'input', 'output') { foreach ($op in 'add', 'mult') {
    if ($locText -notmatch ('(?m)^ goods_' + $dir + '_' + $good + '_' + $op + ':\d+ "')) { Fail "missing localisation for goods_${dir}_${good}_${op}." }
} } }

# --- Art ----------------------------------------------------------------------
foreach ($art in 'gfx/interface/icons/goods_icons/boi_water.dds', 'gfx/interface/icons/goods_icons/boi_bulk_water.dds', 'gfx/interface/icons/building_icons/boi_waterworks.dds') {
    if (-not (Test-Path -LiteralPath (Join-Path $ModPath $art))) { Fail "missing icon $art." }
}
$texticons = [IO.File]::ReadAllText((Join-Path $ModPath 'gui/boi_goods_texticons.gui'))
foreach ($icon in 'water', 'bulk_water') { if ($texticons -notmatch ('icon\s*=\s*' + $icon + '\b')) { Fail "no texticon for $icon." } }

Write-Host ("PASS: water module is internally consistent - {0} PMs in {1} groups; traits assigned {2}." -f
    $pms.Count, $pmgs.Count, (($expectedTraits | ForEach-Object { ($_ -replace 'state_trait_boi_', '') + '=' + $assigned[$_] }) -join ', '))
