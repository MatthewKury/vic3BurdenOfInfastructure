# 1836 Horse Ranch seed

The seed places **225 Horse Ranches with 857 total levels**. The original
curation selects 236 states and the additions list selects 14 more. The
[reduction list](horse_seed_reductions.tsv) lowers levels in 218 of those 250
states; 25 reach zero and have no starting ranch. The 15 unincorporated states
in [the hold list](horse_seed_holds.tsv) remain at or below their previously
tested three-level cap. All 14 [additional states](horse_seed_additions.tsv)
retain their reviewed levels.

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
incorporated, sole-owner rural states. The reductions favor established breeding
areas and open grazing country. The game's steppe, pampas, and Pannonian plain
traits retain their initial levels. Most malaria-affected, rainforest, humid
tropical, and high mountain states lose far more. Bornu is an exception to the
malaria rule because it was a documented horse-breeding center. Lima, Santiago,
and Los Rios retain smaller ranches despite an Andes trait because coastal and
central valley horse traditions are documented. The 14 reviewed additions also
retain their levels. This is a historical suitability heuristic,
not a claim that every removed state lacked horses: [FAO describes the tsetse
constraint on African horses](https://www.fao.org/4/x0413e/x0413e02.htm),
[a contemporary account describes Bornu breeding](https://www.gutenberg.org/files/77463/77463-h/77463-h.htm),
and [research on Southeast Asia describes breeding favoring its drier zones](https://brill.com/display/book/9789004288058/B9789004288058-s004.pdf).
[Chile's national library describes colonial horse use in its central zone](https://www.memoriachilena.gob.cl/602/w3-article-93612.html).

At full staffing, the seed yields **10,284 horses/week before modifiers**
(857 × 12), **210/week below** the 10,494/week of known seeded demand.
Subsistence pastures and state modifiers add supply; dynamically created Urban
Centers add demand. See the [opening balance](HORSE_BALANCE_1836.md) for source
totals and owner-state breakdowns. Actual staffing, prices, and market balances
require a game launch.

The [state audit](horse_seed_audit.csv) records ownership, incorporation,
fixed rural levels, ranch levels, and declared land headroom for all 675 owned
regions. Every ranch state retains at least 12 declared arable levels of
headroom. The validation script checks the new states and protected old states
against the installed game history. This is a static check; the game's actual
province-level land allocation still needs an in-game smoke test.
