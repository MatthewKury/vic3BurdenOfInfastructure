# Building icon artwork

Generated on 2026-11-08 using the built-in image_gen tool, one generation per building. These eleven original illustrations replace the tinted, letter-stamped placeholders. The other nine existing building icons are retained.

Full-resolution sources are the `boi_*.png` files in this directory. Game assets are `gfx/interface/icons/building_icons/<name>.png` and `.dds`: 256x256 BGRA DDS with nine mip levels, using the existing mod texture format. Rebuild with `powershell -ExecutionPolicy Bypass -File tools/Convert-HousingIcons.ps1 -BuildingReplacementsOnly`. The placeholder generator skips these completed sources.

`before.png` records the previous full roster; `after.png` shows the updated roster. Labels in these review sheets are outside the icons and are not in the game textures.

## Exact prompt set

Each generation used the following shared prefix followed immediately by its building-specific subject below. `transparent_background` was false; no reference image was supplied.

Use case: historical-scene. Asset type: square building icon for a Victoria 3 mod, readable at 256x256. Create one original illustration. Style: richly detailed painterly historical strategy-game architectural art, realistic proportions, warm natural light, muted natural earth tones, tactile masonry, controlled detail and strong readable silhouette. Composition: square 1:1, building scene fills the frame, all key architecture fits with breathing room. Include a thin antique bronze rounded-square frame inset close to the image edge, dark outer corners, matching a cohesive nineteenth-century strategy-game icon set. Opaque scenic background. No text, letters, numbers, labels, banners, logos, watermarks, UI badges, neon colors, or modern objects. Subject: 

### Regulated Terraces (`boi_regulated_terraces`)

A planned straight street of modest two-storey Victorian red-brick through-terraces, repeated front doors, pitched slate roofs and chimney pots, small fenced rear yards visible from an elevated three-quarter viewpoint, orderly paving and a visible gutter drain. The low repetitive row-house silhouette is the defining feature.

### Tenement Blocks (`boi_tenement_blocks`)

A dense late nineteenth-century six-storey brick tenement complex around a very narrow deep air shaft courtyard, exterior iron fire escapes, laundry lines and crowded small windows. Elevated three-quarter view reveals the cramped U-shaped massing, soot-stained ochre brick and dark courtyard. Clearly taller and more crowded than workers' rows.

### Model Dwellings (`boi_model_dwellings`)

Victorian philanthropic model dwellings: three restrained four-storey red-brick residential wings enclosing a bright open communal courtyard, symmetrical gables, cream stone window lintels, shared washhouse and a small courtyard water pump, neat laundry drying area. Elevated three-quarter architectural view; airy, clean, humane, modest rather than palatial.

### Municipal Estates (`boi_municipal_estates`)

An early 1920s municipal housing estate: broad five-storey red-ochre rendered perimeter blocks with simple geometric facades and tiled roofs surrounding a large green communal courtyard, monumental central archway leading inside, saplings and benches. Elevated three-quarter view makes the generous shared courtyard and large unified estate clearly legible. Pre-war European social housing, no postwar towers.

### Elevator Apartments (`boi_elevator_apartments`)

A practical early 1900s twelve-storey steel-frame apartment building clad in brown brick with cream horizontal masonry bands, many regular windows, flat roof and a prominent rooftop elevator machinery penthouse, modest recessed entrance, adjacent shorter buildings to establish height. Dramatic three-quarter elevated view, distinctly tall rectangular mass with restrained ornament; residential not a factory.

### Boulevard Apartments (`boi_boulevard_apartments`)

A sweeping continuous row of grand six-storey Haussmann limestone apartment buildings along a wide tree-lined Parisian boulevard, slate mansard roofs, wrought-iron balconies, emphatic rounded corner pavilion, broad clean sidewalks and a tiny horse-drawn carriage. Three-quarter elevated view, boulevard receding diagonally, pale limestone and blue slate, grand horizontal urban ensemble.

### Elevator Residences (`boi_elevator_residences`)

An elegant 1920s luxury residential tower, fifteen storeys, cream limestone cladding, stepped upper floors, copper roof accents and a distinctive ornate crown, tall entrance canopy, rooftop terraces with restrained greenery. Three-quarter view from slightly above street level showing entire tall silhouette and small lower neighboring roofs. Art Deco and Beaux-Arts character, electric luxury, no glass curtain wall.

### Railway Suburbs (`boi_railway_suburbs`)

Leafy late Victorian commuter villas clustered behind a small picturesque suburban railway station, a clearly visible black steam locomotive with two passenger carriages on a curving railway in the foreground, railway platform and signal, gabled detached villas and gardens beyond. Elevated three-quarter view, railway and small station prominent, restrained steam plume.

### Streetcar Suburbs (`boi_streetcar_suburbs`)

An early 1900s neighborhood of modest closely spaced two-storey gabled homes with small front porches and gardens along a paved avenue. A distinctive burgundy electric streetcar in the foreground, on flush street rails with slender overhead trolley wires and poles. Elevated three-quarter view, houses receding along the tram route, friendly green and brick tones. No steam locomotive.

### Motor Suburbs (`boi_motor_suburbs`)

A 1920s suburb of detached Arts and Crafts bungalows, low pitched roofs, wide lawns, individual driveways and visibly separate small garages. A clearly recognizable 1920s black automobile with tall narrow wheels parked in the nearest driveway, gently curving broad road. Elevated three-quarter view, spacious low-density homes, mature garden trees. No contemporary cars or postwar houses.

### Rail Works (`boi_rail_works`)

A nineteenth-century railway engineering works: a red-brick locomotive repair shed with three large arched open bays, radiating steel tracks, a compact railway turntable in front, a partly serviced black steam locomotive and stacked rails and wooden sleepers. Elevated three-quarter view, strong industrial shed silhouette, iron roof trusses and modest chimney smoke. Clearly a railway maintenance facility.

