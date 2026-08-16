# Analisi economia e territori Hegemonia 1000

## Risorse di gioco configurate

Le risorse definite in `data/config/game_config.json` sono:
oro, legname, pietra, ferro, argento, armi, cibo, prestigio

## Problema 1: `denaro` vs `oro` e nomi fazione discordanti

In `data/world/factions_1000.json` la fazione e' chiamata **Impero Fatimide**, mentre in
`data/world/provinces_1000.json` le province associate sono intestate a **Califfato Fatimide**.
Questo fa si' che, senza alias, l'Impero Fatimide risulti con 0 province. E' un'anomalia
da correggere nella mappa o nel file fazioni.


`data/world/provinces_1000.json` assegna ai possedimenti una risorsa chiamata `denaro`,
ma il codice (`EconomyEngine`, `SettlementManager`, costi unità/edifici) usa esclusivamente `oro`.
Risultato:

- `denaro` accumulato nelle province **non entra mai nell'economia di gioco**.
- `oro` parte solo dalle scorte iniziali della fazione e dalla produzione base;
  le province contribuiscono pochissimo oro (solo dove c'e' un campo `oro` esplicito).
- Manutenzione unità/navi e reclutamento consumano `oro`, quindi il tesoro giocatore
  si esaurisce col tempo se non si converte `denaro`.

## Problema 2: `produce_resources` somma l'intero stock provinciale ad ogni turno

In `SettlementManager.production_for_faction` le risorse delle province vengono aggiunte
interamente a ogni turno. Esempio: se una fazione possiede 1.000 unita' di cibo nelle province,
ottiene +1.000 cibo a turno. Questo e' sostenibile per il cibo ma e' ovviamente esplosivo
per oro/denaro, che sono valori molto grandi. Inoltre fa scendere rapidamente il valore
strategico di edifici e produzione base.

## Problema 3: Stime attuali per fazione

| Fazione | Prov | Pop | Oro iniz | Cibo iniz | Manutenzione oro/turno | Consumo cibo/turno | Oro province | Denaro province | Cibo province | Netto oro/turno | Netto se denaro=oro |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Terra di Nessuno | 2498 | 2516486 | 0 | 0 | 0 | 0 | 260 | 72985598 | 9095 | 260 | 72985858 |
| Impero Bizantino | 230 | 177527 | 18000 | 25000 | 286 | 158 | 18 | 5592253 | 1605 | 432 | 5592685 |
| Vichinghi | 214 | 192013 | 9000 | 12000 | 209 | 118 | 0 | 5837742 | 1318 | 141 | 5837883 |
| Impero del Ghana | 202 | 71857 | 11000 | 12000 | 110 | 92 | 61 | 2325572 | 707 | 451 | 2326023 |
| Regno Khmer | 179 | 129043 | 8000 | 16000 | 89 | 71 | 0 | 3428806 | 754 | 211 | 3429017 |
| Impero Fatimide | 119 | 74081 | 15000 | 25000 | 246 | 144 | 0 | 2046472 | 466 | 354 | 2046826 |
| Regno di Francia | 112 | 77490 | 11000 | 18000 | 125 | 91 | 0 | 1622030 | 417 | 325 | 1622355 |
| Sacro Romano Impero | 98 | 211145 | 14000 | 22000 | 188 | 122 | 7 | 6838154 | 1604 | 369 | 6838523 |
| Regno d'Ungheria | 84 | 59964 | 7000 | 12000 | 104 | 87 | 29 | 1881855 | 539 | 225 | 1882080 |
| Dinastia Song | 75 | 743681 | 20000 | 35000 | 279 | 154 | 0 | 23612133 | 463 | 521 | 23612654 |
| Califfato di Cordova | 71 | 58404 | 12000 | 16000 | 185 | 125 | 13 | 1960161 | 386 | 328 | 1960489 |
| Regni Maya | 70 | 29353 | 5000 | 9000 | 59 | 55 | 38 | 1011548 | 293 | 199 | 1011747 |
| Principato di Kiev | 64 | 89199 | 8000 | 15000 | 156 | 106 | 0 | 3180110 | 653 | 194 | 3180304 |
| Regno di Srivijaya | 62 | 81323 | 9000 | 16000 | 124 | 66 | 0 | 2725113 | 286 | 276 | 2725389 |
| Regno Heian | 55 | 94808 | 9000 | 14000 | 118 | 84 | 22 | 3190208 | 411 | 254 | 3190462 |
| Califfato Abbaside | 48 | 39654 | 13000 | 20000 | 209 | 132 | 0 | 1261073 | 266 | 341 | 1261414 |
| Toltechi | 45 | 23082 | 6000 | 10000 | 74 | 68 | 71 | 715410 | 207 | 247 | 715657 |
| Sultanato Ghaznavide | 44 | 28109 | 10000 | 16000 | 161 | 119 | 0 | 867406 | 241 | 289 | 867695 |
| Regno di Polonia | 23 | 18001 | 6500 | 14000 | 101 | 80 | 0 | 623975 | 145 | 179 | 624154 |
| Impero Khitan Liao | 20 | 160513 | 11000 | 18000 | 214 | 158 | 2 | 5145609 | 150 | 188 | 5145797 |
| Impero Chola | 14 | 4188 | 12000 | 22000 | 190 | 108 | 0 | 64811 | 25 | 310 | 65121 |

## Osservazioni sul territorio

- **Vichinghi**: oggi 214 province. Nel 1000 erano un insieme di regni scandinavi
  (Danimarca, Norvegia, Svezia meridionale), insediamenti in Islanda, spedizioni in
  Inghilterra/Danelaw e Normandia. Un blocco cosciuto dovrebbe contare **30-60 province**, non 200+.
- **Impero Bizantino**: 230 province. Plausibile in un grande impero (Anatolia, Balcani, Sud Italia,
  Cipro, Siria meridionale), ma molto dipende dalla granularita' della mappa. Con 4327 province
  totali, 230 equivale a circa il 5% della mappa; potrebbe essere troppo per un impero
  gia' in fase di consolidamento.
- **Sacro Romano Impero**: 98 province. Con Ottone III controllava Germania, Austria, Boemia,
  Ungheria occidentale e Nord Italia: forse 80-120 province plausibili.
- **Regno di Francia**: 112 province. Plausibile per la Francia metropolitana.
- **Dinastia Song**: 75 province ma 743k popolazione (piu' di tutti). Densita' corretta,
  ma il numero di province e' basso rispetto al peso demografico/economico.
- **Impero Khitan Liao**: solo 20 province per un'entita' che dominava Cina del Nord,
  Mongolia e Manciuria. Troppo piccolo.
- **Califfato Abbaside**: 48 province; nel 1000 era sotto tutela Buyide, con Iraq e Iran
  occidentale; plausibile ma forse leggermente sottodimensionato.
- **Califfato Fatimide**: 119 province: Egitto, Nordafrica, Sicilia, Palestina, Hedjaz.
  Plausibile in estensione, ma i valori di `denaro` sono molto piu' bassi del Bizantino/Song.
- **Impero del Ghana**: 202 province. Il Ghana controllava Sahel occidentale
  (Mauritania/Mali/Senegal): con la granularita' attuale potrebbe essere 30-60 province, non 200.
- **Regno Khmer**: 179 province. L'impero Khmer controllava Indocina centrale
  (Cambogia, Thailandia centrale, Laos meridionale, Vietnam meridionale): plausibile
  ma forse eccessivo.
- **Regno Heian**: 55 province. Per tutto il Giappone e' plausibile.
- **Impero Chola**: 14 province. Troppo piccolo per un impero che dominava il Sud India
  e lo Sri Lanka; dovrebbe essere 30-50.

## Proposte prioritarie

1. **Unificare la valuta**: rinominare `denaro` in `oro` in `provinces_1000.json`
   (e nel geojson) oppure far puntare tutto il codice a `denaro`. Rinominare e'
   piu' semplice e coerente con i costi gia' scritti in oro.
2. **Separare stock da reddito**: non sommare le risorse provinciali intere a ogni turno.
   Usare `population` + edifici per calcolare un reddito per turno, e mantenere
   le risorse provinciali come scorte iniziali/tesori.
3. **Ridurre/espandere fazioni chiave**: ridurre Vichinghi e Ghana, espandere
   Khitan Liao e Chola, verificare Impero Bizantino e Khmer.
4. **Aggiungere controllo reddituale**: se il netto oro/turno e' negativo dopo pochi turni,
   le fazioni piu' piccole collasseranno economicamente.

