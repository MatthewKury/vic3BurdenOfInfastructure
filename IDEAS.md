2026-09-26

# Burden of Infrastructure — Thematic Ideas

> **Status:** Ideas only. Nothing here is designed, agreed, or implemented. This
> is a review of what the mod is missing thematically, ranked by priority.

The economic loop (horses → roads → infrastructure, paid for by the state) is
solid. What is thin is everything around it: the "burden" only shows up as a
budget line and a goods shortage.

## 1. Politics: nobody has an opinion about the burden

> **Implemented 2026-09-26** as the Road Financing law group; see
> PROPOSAL_ROAD_FINANCING.md.

This is the biggest gap. Who pays for roads was a major political fight of the
century (turnpike trusts, statute labour, tolls against general taxation,
private railway charters), and it currently has no political effect. The three
existing ownership PMs (appointed surveyors, manorial roadwardens, elected road
boards) are a natural hook:

- **Toll roads / turnpike trusts** as a funding option: cheaper for the
  treasury, but they cut market access or charge pops. Landowners and
  Industrialists would favour it; Rural Folk would oppose it.
- **Statute labour / corvée** under Serfdom: unpaid peasant labour instead of
  wages. Ties directly into the serfdom and abolition debate.
- Interest groups with opinions on Public Works spending, for example Rural
  Folk or the Petite Bourgeoisie wanting roads.

## 2. Nothing happens: no events or journal entries

The horse economy is currently just numbers. Historical flavour candidates:

- **The Great Epizootic (1872):** equine flu hit North America and freight and
  urban transport largely stopped. A random horse-disease event (equine flu or
  glanders) that knocks down horse output.
- **Remount requisitioning** at mobilization: armies took civilian horses, so
  farms and roads suffered during wars.
- **Macadamisation** or national road programme journal entries.
- **The Horse Manure Crisis (1890s)**, since horses already feed urban
  transport through `pm_no_public_transport`.

## 3. Military horses beyond cavalry

Only the four cavalry units and the mobilization options use horses.
Historically, **artillery and supply trains** used far more horses than cavalry
did; every WWI army ran on horses. Horse upkeep on artillery is the cheapest
historically important addition, but it is another combat-unit override.

## 4. Geography plays no part

A Public Works level gives the same infrastructure in the Alps, the Amazon, or
Belgium. Terrain-based difficulty (mountain, jungle, and desert states get less
output or cost more) would make infrastructure a burden in *specific places*.
Colonial Africa, for example, should be expensive to connect.

## 5. Canals and rivers

The first half of the 19th century was the canal age, with horse-drawn barges
on towpaths. Inland states with navigable rivers currently get nothing between
Public Works and coastal Harbour Works. A canal or towpath PM, or
waterway-flavoured Public Works, would fill the gap between cart roads and
railways.

## 6. Regional draught animals

Horses are universal, but mules, oxen, and camels did this work in large parts
of the world (India, the Sahara, the Andes). The Horse-Breeding Traditions trait
is already regional. Even a flavour pass (local names or regional ranch PMs)
would help non-European games feel less generic.

## 7. The horse's decline has no consequences

Late in the game, horse demand should collapse and ranches become stranded
assets. Currently that just fades out quietly. A bust for the ranching class,
or a horse → glue/fertilizer/leather by-product, would give the decline some
shape.

## Already on the deferred list

Draught animals in agriculture, pop-needs horse consumption (carriages, racing,
aristocratic luxury), and military training PMs were already staged for a later
phase. Luxury horse demand from aristocrats would pair well with item 1.

## Suggested priority

Do #1 (politics, using the existing funding and ownership PMs) and #2 (the
Great Epizootic event) first. They add the most identity for the least patch
debt, since both can live in new files with no vanilla shadows. #3 (artillery)
is the cheapest historically important addition, but it adds a combat-unit
override.

## Additional unique ideas — 2026-09-26

### Physical infrastructure upkeep

Public Works currently emphasizes haulage inputs more than the materials needed
to maintain roads, bridges, and track. Small wood, tools, iron, or steel inputs
at appropriate technology tiers could represent replacement timbers, bridge
repairs, and structural maintenance. Rebalance existing inputs where appropriate
so this adds thematic depth without simply increasing the total expense.

### Maintenance versus expansion

A maintenance policy separate from technology could let governments temporarily
save money at the expense of infrastructure capacity, or spend more to sustain
reliable service. Keep the tradeoff visible and reversible initially; a hidden
deterioration meter risks becoming tedious. This would add an operating decision
alongside building more capacity and adopting newer methods.

### Public works events tied to existing problems

Complement the horse-focused events above with an unsafe bridge, a harbor
silting up, disputed tolls, or landowners resisting a planned road. Prefer
triggers tied to existing infrastructure or funding problems, with meaningful
responses, rather than arbitrary recurring penalties.

### Broader public works scope — optional later expansion

Waterworks, sewers, and telegraphs could extend the public-investment theme
beyond transport. These would substantially expand the mod's scope and are
longer-term possibilities rather than priorities for the current transport loop.
