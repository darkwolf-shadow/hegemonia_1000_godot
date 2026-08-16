import json
import csv
from collections import defaultdict

DATA = "data"

def load_json(path):
	return json.load(open(path, encoding="utf-8"))

provinces = load_json("%s/world/provinces_1000.json" % DATA)
factions = load_json("%s/world/factions_1000.json" % DATA)
config = load_json("%s/config/game_config.json" % DATA)

maintenance = config.get("maintenance", {})
resources_cfg = config.get("resources", [])

def calc_maintenance(faction):
	oro = 0
	for unit, count in faction.get("units", {}).items():
		oro += count * maintenance.get(unit, 0)
	for ship, count in faction.get("ships", {}).items():
		oro += count * maintenance.get(ship, 0)
	return oro

def calc_food_consumption(faction):
	total = 0
	for unit, count in faction.get("units", {}).items():
		data = config["units"].get(unit, {})
		total += count * data.get("food", 0)
	for ship, count in faction.get("ships", {}).items():
		data = config["ships"].get(ship, {})
		total += count * data.get("food", 0)
	return total

rows = []
for fname, f in factions.items():
	provs = [p for p in provinces.values() if p.get("owner") == fname]
	bbox = {
		"min_lat": min(p["latitude"] for p in provs) if provs else None,
		"max_lat": max(p["latitude"] for p in provs) if provs else None,
		"min_lon": min(p["longitude"] for p in provs) if provs else None,
		"max_lon": max(p["longitude"] for p in provs) if provs else None,
	}
	pop = sum(int(p.get("population", 0)) for p in provs)
	totals = defaultdict(int)
	for p in provs:
		for r, v in p.get("resources", {}).items():
			totals[r] += int(v)

	start_res = f.get("resources", {})
	start_oro = start_res.get("oro", 0)
	start_cibo = start_res.get("cibo", 0)
	base_prod = f.get("production", {})

	maint_oro = calc_maintenance(f)
	food_cons = calc_food_consumption(f)

	# Netto per turno con il modello attuale (produce_resources somma TUTTE le risorse delle province)
	# Attenzione: denaro non e' in resources_cfg, quindi e' inutilizzato dal codice attuale.
	# Se denaro fosse convertito in oro, il netto cambierebbe drasticamente.
	prov_oro = totals.get("oro", 0)
	prov_denaro = totals.get("denaro", 0)
	net_oro_current = base_prod.get("oro", 0) + prov_oro - maint_oro
	net_oro_if_denaro_converted = base_prod.get("oro", 0) + prov_oro + prov_denaro - maint_oro

	rows.append({
		"Fazione": fname,
		"Province": len(provs),
		"Popolazione": pop,
		"Oro_iniziale": start_oro,
		"Cibo_iniziale": start_cibo,
		"Oro_province": prov_oro,
		"Denaro_province": prov_denaro,
		"Produzione_base_oro": base_prod.get("oro", 0),
		"Produzione_base_cibo": base_prod.get("cibo", 0),
		"Manutenzione_oro": maint_oro,
		"Consumo_cibo": food_cons,
		"Netto_oro_attuale": net_oro_current,
		"Netto_oro_se_denaro_converted": net_oro_if_denaro_converted,
		"Cibo_province": totals.get("cibo", 0),
		"Legname_province": totals.get("legname", 0),
		"Pietra_province": totals.get("pietra", 0),
		"Ferro_province": totals.get("ferro", 0),
		"Armi_province": totals.get("armi", 0),
		"Prestigio_province": totals.get("prestigio", 0),
		"Min_Lat": bbox["min_lat"],
		"Max_Lat": bbox["max_lat"],
		"Min_Lon": bbox["min_lon"],
		"Max_Lon": bbox["max_lon"],
	})

with open("docs/economy_factions.csv", "w", newline="", encoding="utf-8") as f:
	w = csv.DictWriter(f, fieldnames=rows[0].keys())
	w.writeheader()
	w.writerows(rows)

md = """# Analisi economia e territori Hegemonia 1000

## Risorse di gioco configurate

Le risorse definite in `data/config/game_config.json` sono:
"""
md += ", ".join(resources_cfg) + "\n\n"

md += """## Problema 1: `denaro` vs `oro`

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

"""
md += "| Fazione | Prov | Pop | Oro iniz | Cibo iniz | Manutenzione oro/turno | Consumo cibo/turno | Oro province | Denaro province | Cibo province | Netto oro/turno | Netto se denaro=oro |\n"
md += "|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|\n"
for r in sorted(rows, key=lambda x: -x["Province"]):
	md += f"| {r['Fazione']} | {r['Province']} | {r['Popolazione']} | {r['Oro_iniziale']} | {r['Cibo_iniziale']} | {r['Manutenzione_oro']} | {r['Consumo_cibo']} | {r['Oro_province']} | {r['Denaro_province']} | {r['Cibo_province']} | {r['Netto_oro_attuale']} | {r['Netto_oro_se_denaro_converted']} |\n"

md += """
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

"""

with open("docs/Analisi_Economia_e_Territori.md", "w", encoding="utf-8") as f:
	f.write(md)

print("Report scritto in docs/Analisi_Economia_e_Territori.md e docs/economy_factions.csv")
