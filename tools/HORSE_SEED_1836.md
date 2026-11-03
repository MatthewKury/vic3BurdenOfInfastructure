# 1836 Horse Ranch seed

The seed places **216 Horse Ranches with 492 total levels**, so horses start
scarce. The original curation selects 236 states and the additions list selects
14 more. An earlier suitability review brought that to 225 ranches and 857 levels,
and left 25 states with no starting ranch. The scarcity pass below then cut those
857 levels by each state's horse history. The 15 unincorporated states in
[the hold list](horse_seed_holds.tsv) remain at or below their previously tested
three-level cap, and the 14 [additional states](horse_seed_additions.tsv) stay at
or below their reviewed levels.

## Scarcity by horse history (2026-11-01)

At 857 levels the world opened at 102% of demand and 41% of demand bought below
base price, so horses gave little to think about. Each state now has a tier in
[horse_seed_tiers.tsv](horse_seed_tiers.tsv), and
[Set-HorseSeedTiers.py](Set-HorseSeedTiers.py) keeps a share of its levels. Tiers
are a judgement from general history, not newly sourced research, and they're
easy to change.

| Tier | Retained | States | Levels | Examples |
| --- | ---: | ---: | --- | --- |
| 1. Great horse country | 85% | 56 | 274 → 227 | Don and Black Earth steppe, Hungarian plain, pampas, northern Mexico, Persian and Central Asian horse lands, Kentucky bluegrass, Normandy and Limousin, East Prussia (Trakehnen), Andalusia, Yorkshire, Morocco |
| 2. Established breeding and farm-horse regions | 60% | 82 | 309 → 175 | Central Russia and Siberia, the American Midwest, northern China, western France, Transylvania, Castile, Wales |
| 3. Ordinary farming country | 35% | 68 | 243 → 79 | The American Deep South, northeast Brazil, Korea, Italy, Switzerland, Sweden, Egypt above the delta |
| 4. Poor horse country | 25% | 19 | 31 → 11 | Southern China, the Caribbean, Southeast Asia |

Rounding removes the ranch in 9 of these states, all but one of them in tier 4.
Subsistence pasture output also fell from 0.25 to 0.15 horses per level.

### Measured results

From one 20-year headless run on 1.13.11, `20261101-132605_mod`, read with
`tools/Get-HorseMarkets.py`. The earlier seed's row comes from `20261101-131117_mod`.
All are single runs, so read them as directions. Demand and supply are state buy
and sell orders, and both appear to count traded horses: at least 1,170 of the 1836
supply is round-numbered sales in port states with no ranch, such as Canton, London
and Lancashire. Without those, 1836 is about 62%, not 65%.

| | Demand | Supply | Supply / demand | Ranch levels | Demand buying at £45+ | Demand buying below base |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1836, earlier seed | 13,309 | 13,544 | 102% | 857 | 21% | 41% |
| **1836** | 12,801 | 8,352 | 65% | 511 | 54% | 13% |
| 1840 | 12,930 | 9,686 | 75% | 620 | 42% | 15% |
| 1845 | 14,414 | 11,489 | 80% | 720 | 37% | 20% |
| 1850 | 15,960 | 13,268 | 83% | 784 | 22% | 23% |
| 1855 | 18,139 | 15,955 | 88% | 861 | 7% | 27% |

Mean state horse price, weighted by demand:

| Country | 1836, earlier seed | 1836 | 1845 | 1855 |
| --- | ---: | ---: | ---: | ---: |
| Mexico | 16 | 15 | 25 | 22 |
| Persia | 10 | 17 | 24 | 20 |
| USA | 21 | 27 | 29 | 24 |
| Hungary | 23 | 32 | 22 | 19 |
| Russia | 26 | 35 | 27 | 25 |
| France | 25 | 40 | 38 | 35 |
| Prussia | 26 | 42 | 32 | 27 |
| Brazil | 28 | 42 | 28 | 25 |
| Ottoman Empire | 30 | 38 | 33 | 32 |
| Britain | 40 | 48 | 44 | 40 |
| Spain | 39 | 51 | 41 | 36 |
| China | 42 | 51 | 48 | 41 |
| Japan | 49 | 50 | 50 | 38 |
| British India | 46 | 52 | 51 | 41 |

The AI closes much of the gap with new ranches and better PMs, so this is a
start-of-game squeeze, not a permanent one. Growth is uneven, though: Britain stays
at 14 levels for 20 years. GDP and SoL showed no collapse.

## Seed construction

| New ranch state | Levels | Placement reason |
| --- | ---: | --- |
| Auvergne-Limousin | 6 | Limousin horse breeding and a substantial rural base |
| Yorkshire | 6 | Northern English breeding and opening British horse demand |
| Lowlands | 5 | Scottish breeding and opening British horse demand |
| Oryol | 5 | Central Russian breeding and domestic distribution |
| Kazan | 5 | Volga basin breeding and domestic distribution |
| Ohio | 5 | American farm and transport demand |
| Tohoku | 5 | Northern Japanese horse breeding |
| Hudavendigar | 4 | Ottoman Anatolian horse raising |
| Lower Egypt | 4 | Nile Valley breeding and Egyptian demand |
| Fez | 4 | Moroccan Barb horse region |
| Bavaria | 4 | Central European farm and transport demand |
| Moravia | 4 | Central European farm and transport demand |
| Zhili | 4 | North Chinese distribution and Qing horse demand |
| New Castile | 4 | Iberian breeding and Spanish demand |

Historical anchors include the [Pompadour national stud in Limousin](https://cheval-patrimoine.culture.gouv.fr/fr/le-haras-national-de-pompadour),
[nineteenth-century British breeding districts](https://darwin-online.org.uk/converted/pdf/1829_Lawrence_Horse_CUL-DAR.LIB.356.pdf),
[the horse culture of Hachinohe in Tohoku](https://visithachinohe.com/en/park/horse/),
[horse raising in the Ottoman Kirmasti/Mihaliç area](https://dergipark.org.tr/tr/pub/otam/article/1048870),
and [Barb horses in Morocco](https://darwin-online.org.uk/converted/pdf/1841_Smith_horses_CUL-DAR.LIB.595.pdf).
Other choices spread supply near major opening demand and use the game's safe,
incorporated, sole-owner rural states. The earlier suitability review favored
established breeding areas and open grazing country. The game's steppe, pampas, and Pannonian plain
traits retain their initial levels. Most malaria-affected, rainforest, humid
tropical, and high mountain states lose far more. Bornu is an exception to the
malaria rule because it was a documented horse-breeding center. Lima, Santiago,
and Los Rios retain smaller ranches despite an Andes trait because coastal and
central valley horse traditions are documented. This is a historical suitability heuristic,
not a claim that every removed state lacked horses: [FAO describes the tsetse
constraint on African horses](https://www.fao.org/4/x0413e/x0413e02.htm),
[a contemporary account describes Bornu breeding](https://www.gutenberg.org/files/77463/77463-h/77463-h.htm),
and [research on Southeast Asia describes breeding favoring its drier zones](https://brill.com/display/book/9789004288058/B9789004288058-s004.pdf).
[Chile's national library describes colonial horse use in its central zone](https://www.memoriachilena.gob.cl/602/w3-article-93612.html).

At full staffing, the seed yields **5,904 horses/week before modifiers**
(492 × 12), **4,590/week below** the 10,494/week of known seeded demand.
Subsistence pastures and state modifiers add supply; dynamically created Urban
Centers add demand. See the [opening balance](HORSE_BALANCE_1836.md) for source
totals and owner-state breakdowns.

The [state audit](horse_seed_audit.csv) records ownership, incorporation,
fixed rural levels, ranch levels, and declared land headroom for all 675 owned
regions. Every ranch state retains at least 12 declared arable levels of
headroom. The validation script checks the new states and protected old states
against the installed game history. This is a static check; the game's actual
province-level land allocation still needs an in-game smoke test.
