# Dark Corporation / Stev
# Popup provincia stile Medieval Total War
extends Control

signal enter_province(province_name: String)

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/Title
@onready var info_label: Label = $Panel/Info
@onready var enter_button: Button = $Panel/EnterButton
@onready var close_button: Button = $Panel/CloseButton
@onready var owner_label: Label = $Panel/OwnerRow/OwnerValue
@onready var region_label: Label = $Panel/RegionRow/RegionValue
@onready var terrain_label: Label = $Panel/TerrainRow/TerrainValue
@onready var pop_label: Label = $Panel/PopRow/PopValue
@onready var resources_label: Label = $Panel/ResourcesRow/ResourcesValue

var current_province: String = ""


func _ready():
	enter_button.pressed.connect(_on_enter)
	close_button.pressed.connect(_on_close)
	visible = false


func show_province(province_name: String):
	current_province = province_name
	var prov = GameState.state.provinces.get(province_name, {})
	var owner = prov.get("owner", "Terra di Nessuno")
	var data = WorldData.get_province(province_name)
	var fog: String = GameState.get_fog(province_name)

	title_label.text = province_name

	if fog == "nebbia":
		info_label.text = "Territorio sconosciuto"
		owner_label.text = "???"
		region_label.text = "???"
		terrain_label.text = "???"
		pop_label.text = "???"
		resources_label.text = "???"
		enter_button.disabled = true
	else:
		owner_label.text = owner
		region_label.text = data.get("region", "N/D")
		terrain_label.text = _translate_terrain(data.get("terrain", "N/D"))
		pop_label.text = str(int(data.get("population", 0)))
		var res = data.get("resources", {})
		if res is Dictionary and res.size() > 0:
			var parts: Array = []
			for k in res.keys():
				parts.append("%s: %s" % [k, str(res[k])])
			resources_label.text = ", ".join(parts)
		else:
			resources_label.text = "Nessuna"
		enter_button.disabled = false

	visible = true


func _on_enter():
	if current_province != "":
		enter_province.emit(current_province)
		visible = false


func _on_close():
	visible = false


func _translate_terrain(terrain: String) -> String:
	# Traduce il tipo di terreno in italiano - Dark Corporation / Stev
	match terrain.to_lower():
		"forest", "foresta":
			return "Foresta"
		"mountain", "montagna":
			return "Montagna"
		"mountains":
			return "Montagne"
		"desert", "deserto":
			return "Deserto"
		"plains", "pianura":
			return "Pianura"
		"coastal", "costiera":
			return "Costiera"
		"coast":
			return "Costa"
		"tundra":
			return "Tundra"
		"hills", "colline":
			return "Colline"
		"swamp", "palude":
			return "Palude"
		"jungle", "giungla":
			return "Giungla"
		"steppe", "steppa":
			return "Steppa"
		"savannah", "savana":
			return "Savana"
		"river", "fiume":
			return "Fiume"
		"industrial":
			return "Industriale"
		"military":
			return "Militare"
		"port":
			return "Porto"
		"generic":
			return "Generico"
		_:
			return terrain
