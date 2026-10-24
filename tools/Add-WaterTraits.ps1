# Reapply the BOI water traits to map_data/state_regions after regenerating it.
# Safe to rerun: an existing assignment is left intact. Throws on an unknown
# state name, so a typo or a vanilla rename cannot pass silently.
#
# Two sources of assignments:
#   AUTOMATIC  states that already carry a vanilla river/lake trait get
#              state_trait_boi_water_abundant; states carrying a vanilla desert
#              trait get state_trait_boi_arid_interior.
#   CURATED    the lists below.
# A state with no traits line gets one inserted after its provinces line,
# which is where vanilla puts it.
$ErrorActionPreference = 'Stop'
$regions = Join-Path (Split-Path $PSScriptRoot -Parent) 'map_data/state_regions'

$riverTraits = @(
    'state_trait_st_lawrence_river','state_trait_mississippi_river','state_trait_ohio_river',
    'state_trait_columbia_river','state_trait_great_lakes','state_trait_rio_grande_river',
    'state_trait_lake_maracaibo','state_trait_orinoco_river','state_trait_uruguay_river',
    'state_trait_parana_river','state_trait_paraguay_river','state_trait_amazon_river',
    'state_trait_rhine_river','state_trait_elbe_river','state_trait_oder_river',
    'state_trait_rhone_river','state_trait_loire_river','state_trait_seine_river',
    'state_trait_po_river','state_trait_douro_river','state_trait_tagus_river',
    'state_trait_drava_river','state_trait_danube_river','state_trait_volga_river',
    'state_trait_dnieper_river','state_trait_don_river','state_trait_irtysh_river',
    'state_trait_nile_river','state_trait_congo_river','state_trait_niger_river',
    'state_trait_lake_victoria','state_trait_zambezi_river','state_trait_tigris_river',
    'state_trait_euphrates_river','state_trait_ob_river','state_trait_indus_river',
    'state_trait_ganges_river','state_trait_bengal_delta','state_trait_cauvery_delta',
    'state_trait_brahmaputra_river','state_trait_mekong_delta','state_trait_chao_phraya_delta',
    'state_trait_mekong_river','state_trait_kapuas_river','state_trait_sarawak_river',
    'state_trait_pearl_river','state_trait_yangtze_river','state_trait_yellow_river',
    'state_trait_angara_river','state_trait_yenisei_river','state_trait_mesopotamian_floodplain'
)
$desertTraits = @(
    'state_trait_sahara_desert','state_trait_arabian_desert','state_trait_gobi_desert',
    'state_trait_taklamakan_desert','state_trait_atacama_desert','state_trait_the_great_basin_desert',
    'state_trait_australian_desert'
)

$abundant = 'state_trait_boi_water_abundant'
$summerDry = 'state_trait_boi_summer_dry'
$arid = 'state_trait_boi_arid_interior'
$monsoon = 'state_trait_boi_monsoon_dependent'
$irrigation = 'state_trait_boi_irrigation_heritage'
$brackish = 'state_trait_boi_brackish_aquifer'

$curated = @{
    $abundant = @(
        'STATE_HIGHLANDS','STATE_WALES','STATE_LANCASHIRE','STATE_WEST_COUNTRY','STATE_ULSTER',
        'STATE_MUNSTER','STATE_LEINSTER','STATE_CONNAUGHT','STATE_WESTERN_NORWAY','STATE_GOTALAND',
        'STATE_BRITTANY','STATE_ASTURIAS','STATE_GALICIA','STATE_WASHINGTON','STATE_OREGON',
        'STATE_BRITISH_COLUMBIA','STATE_NORTH_ISLAND','STATE_SOUTH_ISLAND','STATE_TASMANIA',
        'STATE_TOKAI','STATE_KANSAI','STATE_HOKKAIDO','STATE_NEW_HAMPSHIRE','STATE_VERMONT','STATE_MAINE'
    )
    $summerDry = @(
        'STATE_PROVENCE','STATE_LANGUEDOC','STATE_CATALONIA','STATE_VALENCIA','STATE_MURCIA',
        'STATE_LOWER_ANDALUSIA','STATE_UPPER_ANDALUSIA','STATE_EXTREMADURA','STATE_ALENTEJO',
        'STATE_NEW_CASTILE','STATE_ARAGON','STATE_BALEARIC_ISLANDS','STATE_SARDINIA','STATE_SICILY',
        'STATE_MALTA','STATE_CAMPANIA','STATE_CALABRIA','STATE_APULIA','STATE_CRETE','STATE_ATTICA',
        'STATE_PELOPONNESE','STATE_WEST_AEGEAN_ISLANDS','STATE_EAST_AEGEAN_ISLANDS','STATE_AYDIN',
        'STATE_CYPRUS','STATE_LEBANON','STATE_PALESTINE','STATE_ALGIERS','STATE_ORAN',
        'STATE_CONSTANTINE','STATE_TUNISIA','STATE_CALIFORNIA','STATE_CAPE_COLONY','STATE_SOUTH_AUSTRALIA',
        'STATE_SANTIAGO'
    )
    $arid = @(
        'STATE_HEDJAZ','STATE_HAIL','STATE_OMAN','STATE_ABU_DHABI','STATE_TRANSJORDAN','STATE_DEIR_EZ_ZOR',
        'STATE_SYRIA','STATE_KERMAN','STATE_SISTAN','STATE_SEMNAN','STATE_KHORASAN','STATE_FARS',
        'STATE_LARISTAN','STATE_TURKMENIA','STATE_UZBEKIA','STATE_KHIVA','STATE_BALUCHISTAN','STATE_QUETTA',
        'STATE_KANDAHAR','STATE_SINDH','STATE_RAJPUTANA','STATE_EGYPTIAN_DESERT','STATE_MATRUH','STATE_LIBYA',
        'STATE_LIBYAN_DESERT','STATE_TRIPOLI','STATE_MAURITANIA','STATE_NORTHERN_CAPE','STATE_NAMAQUALAND',
        'STATE_HEREROLAND','STATE_BOTSWANA','STATE_SONORA','STATE_CHIHUAHUA','STATE_NEW_MEXICO','STATE_ARIZONA',
        'STATE_NEVADA','STATE_UTAH','STATE_BAJA_CALIFORNIA','STATE_ANTOFAGASTA','STATE_TARAPACA',
        'STATE_PATAGONIA','STATE_WESTERN_AUSTRALIA','STATE_NORTHERN_TERRITORY','STATE_ALXA','STATE_TIANSHAN',
        'STATE_GANSU','STATE_NINGXIA','STATE_URGA','STATE_ULIASTAI'
    )
    $monsoon = @(
        'STATE_BOMBAY','STATE_MADRAS','STATE_KURNOOL','STATE_HYDERABAD','STATE_MYSORE','STATE_TRAVANCORE',
        'STATE_CIRCARS','STATE_ORISSA','STATE_CENTRAL_PROVINCES','STATE_BUNDELKHAND','STATE_MALWA','STATE_GUJARAT',
        'STATE_WEST_BENGAL','STATE_EAST_BENGAL','STATE_ASSAM','STATE_ARAKAN','STATE_PEGU','STATE_TENASSERIM',
        'STATE_MANDALAY','STATE_TONKIN','STATE_ANNAM','STATE_CAMBODIA','STATE_LAOS','STATE_BANGKOK',
        'STATE_CHIANG_MAI','STATE_NAKHON_RATCHASIMA','STATE_GUANGDONG','STATE_GUANGXI','STATE_FUJIAN',
        'STATE_YUNNAN','STATE_GUIZHOU','STATE_CEYLON'
    )
    $irrigation = @(
        'STATE_UPPER_EGYPT','STATE_MIDDLE_EGYPT','STATE_PUNJAB','STATE_SINDH','STATE_AGRA','STATE_DELHI','STATE_AWADH',
        'STATE_BAGHDAD','STATE_BASRA','STATE_MOSUL','STATE_KHUZESTAN','STATE_VALENCIA','STATE_PIEDMONT','STATE_FERGANA',
        'STATE_SYRDARYA','STATE_MADRAS'
    )
    $brackish = @(
        'STATE_HOLLAND','STATE_FRIESLAND','STATE_FLANDERS','STATE_LOUISIANA','STATE_FLORIDA','STATE_MIDDLE_EGYPT',
        'STATE_BASRA','STATE_ABU_DHABI','STATE_OMAN','STATE_EAST_BENGAL','STATE_NIGER_DELTA','STATE_MALTA',
        'STATE_BAHAMAS','STATE_WEST_INDIES','STATE_CAPE_VERDE','STATE_CANARY_ISLANDS','STATE_BALEARIC_ISLANDS'
    )
}

$wanted = @{}   # state -> set of traits to ensure
function Add-Want([string]$state, [string]$trait) {
    if (-not $wanted.ContainsKey($state)) { $wanted[$state] = [Collections.Generic.List[string]]::new() }
    if (-not $wanted[$state].Contains($trait)) { $wanted[$state].Add($trait) }
}
foreach ($trait in $curated.Keys) { foreach ($state in $curated[$trait]) { Add-Want $state $trait } }

$seen = @{}
$added = 0
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)

foreach ($file in (Get-ChildItem $regions -Filter '*.txt')) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $data = [IO.File]::ReadAllText($file.FullName)
    $stateMatches = [regex]::Matches($data, '(?m)^STATE_[A-Z0-9_]+\s*=\s*\{')
    $edits = @()
    for ($i = 0; $i -lt $stateMatches.Count; $i++) {
        $name = [regex]::Match($stateMatches[$i].Value, 'STATE_[A-Z0-9_]+').Value
        $seen[$name] = $true
        $start = $stateMatches[$i].Index
        $end = if ($i + 1 -lt $stateMatches.Count) { $stateMatches[$i + 1].Index } else { $data.Length }
        $body = $data.Substring($start, $end - $start)
        $match = [regex]::Match($body, '(?m)^[ \t]*traits\s*=\s*\{[^}\r\n]*\}')

        # Work out which traits this state should carry.
        $want = [Collections.Generic.List[string]]::new()
        if ($wanted.ContainsKey($name)) { foreach ($t in $wanted[$name]) { $want.Add($t) } }
        if ($match.Success) {
            foreach ($t in $riverTraits) {
                if ($match.Value.Contains('"' + $t + '"') -and -not $want.Contains($abundant)) { $want.Add($abundant) }
            }
            foreach ($t in $desertTraits) {
                if ($match.Value.Contains('"' + $t + '"') -and -not $want.Contains($arid)) { $want.Add($arid) }
            }
        }
        $missing = @($want | Where-Object { -not ($match.Success -and $match.Value.Contains('"' + $_ + '"')) })
        if (-not $missing.Count) { continue }
        $addText = ($missing | ForEach-Object { '"' + $_ + '"' }) -join ' '
        $added += $missing.Count

        if ($match.Success) {
            $replacement = $match.Value.Substring(0, $match.Value.LastIndexOf('}')).TrimEnd() + ' ' + $addText + ' }'
            $edits += [pscustomobject]@{ Start = $start + $match.Index; Length = $match.Length; Text = $replacement }
        }
        else {
            # No traits line: insert one after the provinces line.
            $prov = [regex]::Match($body, '(?m)^([ \t]*)provinces\s*=\s*\{[^}]*\}[^\r\n]*(\r?\n)')
            if (-not $prov.Success) { throw "Cannot find provinces line in $name to insert traits after." }
            $indent = $prov.Groups[1].Value
            $newline = $prov.Groups[2].Value
            $insert = $indent + 'traits = { ' + $addText + ' }' + $newline
            $edits += [pscustomobject]@{ Start = $start + $prov.Index + $prov.Length; Length = 0; Text = $insert }
        }
    }
    if ($edits.Count) {
        foreach ($edit in ($edits | Sort-Object Start -Descending)) {
            $data = $data.Substring(0, $edit.Start) + $edit.Text + $data.Substring($edit.Start + $edit.Length)
        }
        [IO.File]::WriteAllText($file.FullName, $data, $(if ($hasBom) { $utf8Bom } else { $utf8NoBom }))
    }
}

$unknown = @($wanted.Keys | Where-Object { -not $seen.ContainsKey($_) } | Sort-Object)
if ($unknown.Count) { throw "Target states not found: $($unknown -join ', ')" }
Write-Host "Water traits: $added assignments added across $($wanted.Count) curated states plus automatic river/desert states."
