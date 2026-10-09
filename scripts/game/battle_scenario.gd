extends Node3D
# Generatore di scenari di battaglia basati sul tipo di terreno della provincia
# Ogni provincia ha un terrain_type che determina:
# - forma del terreno (pianura, colline, montagne, deserto, foresta, neve, costa)
# - colori del terreno
# - densita' di alberi e rocce
# - presenza di acqua
# Dark Corporation / Stev

# Tipi di terreno supportati
enum TerrainType {
	PLAINS,     # pianura erbosa
	HILLS,      # colline dolci
	MOUNTAINS,  # montagne ripide
	FOREST,     # foresta densa
	DESERT,     # deserto sabbioso
	COASTAL,    # costa con mare
	SNOW,       # neve e ghiaccio
	MARSH       # palude
}

# Configurazione per ogni tipo di terreno
const TERRAIN_CONFIG := {
	"plains": {
		"hill_height": 4.0,
		"noise_freq": 0.008,
		"tree_count": 40,
		"rock_count": 10,
		"grass_color": Color(0.35, 0.55, 0.25),
		"ground_color": Color(0.4, 0.3, 0.15),
		"tree_color": Color(0.2, 0.4, 0.15),
		"has_water": false,
		"fog_color": Color(0.7, 0.8, 0.9, 1),
		"fog_density": 0.005
	},
	"hills": {
		"hill_height": 15.0,
		"noise_freq": 0.012,
		"tree_count": 50,
		"rock_count": 20,
		"grass_color": Color(0.3, 0.5, 0.2),
		"ground_color": Color(0.35, 0.28, 0.12),
		"tree_color": Color(0.15, 0.35, 0.1),
		"has_water": false,
		"fog_color": Color(0.65, 0.75, 0.85, 1),
		"fog_density": 0.007
	},
	"mountains": {
		"hill_height": 35.0,
		"noise_freq": 0.015,
		"tree_count": 30,
		"rock_count": 40,
		"grass_color": Color(0.25, 0.35, 0.15),
		"ground_color": Color(0.4, 0.38, 0.35),
		"tree_color": Color(0.1, 0.25, 0.08),
		"has_water": false,
		"fog_color": Color(0.6, 0.7, 0.8, 1),
		"fog_density": 0.012
	},
	"forest": {
		"hill_height": 6.0,
		"noise_freq": 0.01,
		"tree_count": 120,
		"rock_count": 15,
		"grass_color": Color(0.2, 0.4, 0.15),
		"ground_color": Color(0.3, 0.22, 0.1),
		"tree_color": Color(0.1, 0.3, 0.08),
		"has_water": false,
		"fog_color": Color(0.5, 0.65, 0.55, 1),
		"fog_density": 0.008
	},
	"desert": {
		"hill_height": 8.0,
		"noise_freq": 0.006,
		"tree_count": 5,
		"rock_count": 25,
		"grass_color": Color(0.85, 0.75, 0.45),
		"ground_color": Color(0.8, 0.65, 0.35),
		"tree_color": Color(0.5, 0.45, 0.2),
		"has_water": false,
		"fog_color": Color(0.9, 0.85, 0.7, 1),
		"fog_density": 0.006
	},
	"coastal": {
		"hill_height": 5.0,
		"noise_freq": 0.009,
		"tree_count": 30,
		"rock_count": 15,
		"grass_color": Color(0.4, 0.55, 0.3),
		"ground_color": Color(0.7, 0.65, 0.45),
		"tree_color": Color(0.2, 0.4, 0.15),
		"has_water": true,
		"fog_color": Color(0.6, 0.75, 0.85, 1),
		"fog_density": 0.006
	},
	"snow": {
		"hill_height": 10.0,
		"noise_freq": 0.011,
		"tree_count": 20,
		"rock_count": 30,
		"grass_color": Color(0.85, 0.88, 0.92),
		"ground_color": Color(0.7, 0.72, 0.78),
		"tree_color": Color(0.15, 0.25, 0.12),
		"has_water": false,
		"fog_color": Color(0.8, 0.85, 0.9, 1),
		"fog_density": 0.01
	},
	"marsh": {
		"hill_height": 3.0,
		"noise_freq": 0.014,
		"tree_count": 60,
		"rock_count": 8,
		"grass_color": Color(0.25, 0.35, 0.2),
		"ground_color": Color(0.2, 0.25, 0.15),
		"tree_color": Color(0.15, 0.25, 0.1),
		"has_water": true,
		"fog_color": Color(0.5, 0.6, 0.55, 1),
		"fog_density": 0.015
	}
}

# Mappa regione geografica -> tipo di terreno probabile
# Basato sulla latitudine e longitudine della provincia
static func get_terrain_for_province(latitude: float, longitude: float) -> String:
	# Nord (lat > 55): neve
	if latitude > 55.0:
		return "snow"
	# Nord Europa (lat 45-55): foresta o colline
	if latitude > 45.0 and longitude > -10.0 and longitude < 40.0:
		return "forest" if randf() > 0.5 else "hills"
	# Mediterraneo (lat 30-45, long -10 to 40): colline o costa
	if latitude > 30.0 and latitude < 45.0 and longitude > -10.0 and longitude < 40.0:
		return "hills" if randf() > 0.4 else "coastal"
	# Nord Africa (lat 15-30, long -10 to 40): deserto
	if latitude > 15.0 and latitude < 35.0 and longitude > -10.0 and longitude < 50.0:
		return "desert"
	# Medio Oriente (lat 20-40, long 40-70): deserto o colline
	if latitude > 20.0 and latitude < 40.0 and longitude > 40.0 and longitude < 70.0:
		return "desert" if randf() > 0.4 else "hills"
	# Asia centrale (lat 30-55, long 70-120): montagne o steppe
	if latitude > 30.0 and latitude < 55.0 and longitude > 70.0 and longitude < 120.0:
		return "mountains" if randf() > 0.5 else "plains"
	# Asia sud-est (lat -10 to 30, long 90-140): foresta o palude
	if latitude > -10.0 and latitude < 30.0 and longitude > 90.0 and longitude < 140.0:
		return "forest" if randf() > 0.4 else "marsh"
	# Americhe (long < -30): varia
	if longitude < -30.0:
		if latitude > 45.0:
			return "snow"
		if latitude > 30.0:
			return "forest" if randf() > 0.5 else "hills"
		if latitude > -10.0:
			return "forest" if randf() > 0.4 else "mountains"
		return "plains"
	# Africa subsahariana (lat -35 to 15, long -20 to 50): savana/palude
	if latitude > -35.0 and latitude < 15.0:
		return "plains" if randf() > 0.4 else "marsh"
	# Default
	return "plains"

# Restituisce la configurazione per un tipo di terreno
static func get_config(terrain_type: String) -> Dictionary:
	if TERRAIN_CONFIG.has(terrain_type):
		return TERRAIN_CONFIG[terrain_type]
	return TERRAIN_CONFIG["plains"]
