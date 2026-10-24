# Validation scripts

Run the core checks from PowerShell:

```powershell
.\tools\Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
```

If the local PowerShell execution policy blocks project scripts, invoke the same
command with a process-only bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game'
```

`Test-ModStructure.ps1` checks UTF-8 BOMs and brace balance. It warns, rather
than fails, for the current descriptor/metadata version mismatch.

`Test-Seed.ps1` checks the committed 1.13 seed's BOM and expected counts. Pass
different expected counts after a reviewed game update.

`Test-ShadowSources.ps1` confirms every BOI override key has exactly one source
definition in the installed game. It catches renamed, removed and duplicate
keys; it does not prove a full copied vanilla block has no upstream changes.

`Test-SeedReproducibility.ps1` runs the generator twice with saved regeneration
inputs and compares the byte output. The input directory must contain
`pairs.txt`, `ranch.txt`, and sorted `owned_regions.txt` from REGENERATE.md.

Include the optional input directory in the combined command:

```powershell
.\tools\Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game' -SeedInputsDirectory C:\temp\boi-seed-inputs
```

To check BOI alongside an installed Community Mod Framework, add its workshop
directory. CMF is an optional companion: BOI does not consume CMF services and
must not declare it as a dependency.

```powershell
.\tools\Validate-All.ps1 -GamePath 'C:\Program Files (x86)\Steam\steamapps\common\Victoria 3\game' -CmfPath 'C:\Program Files (x86)\Steam\steamapps\workshop\content\529340\3385002128'
```

`Test-CMFCompatibility.ps1` verifies CMF's identity, then fails if CMF and BOI
share a game-data path or define the same key in a shared `common` domain. It is
a static conflict check; keep CMF above BOI in the playset and complete a game
startup smoke test after every CMF update.

These scripts are static checks. Launch the game and inspect its logs to verify
engine acceptance and campaign behavior.

`Test-HousingPrototype.ps1` is included in the combined checks. It verifies
the goods-based housing module's demand and staffing rules, fixed structures,
law gates, source-preserving overrides, graphics/references, explicit modifier
declarations, and deterministic regeneration. See the [prototype instructions](housing-prototype/README.md)
and [housing plan](../docs/plans/04_HOUSING.md) for the required live tests.
The optional module is not loaded by the main BOI mod. The earlier capacity
probe was retired; its old arithmetic checks do not apply to this design.
