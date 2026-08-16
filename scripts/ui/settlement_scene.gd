# Dark Corporation / Stev
# Scena agglomerato urbano - gestione edifici e truppe
extends Control

@onready var title_label: Label = $Panel/Title
@onready var buildings_list: ItemList = $Panel/BuildingsList
@onready var info_label: Label = $Panel/Info
@onready var panel: Panel = $Panel
@onready var back_button: Button = $Panel/BackButton
@onready var settlement_map: Control = $Panel/SettlementMap

var current_province: String = ""
var current_settlement: String = ""
var _recruitment_view: Control


func _ready():
	back_button.pressed.connect(_on_back)
	_add_recruitment_button()
	_instantiate_recruitment_view()
	var prov = GameState.state.get("last_province", "")
	var sett = GameState.state.get("last_settlement", "")
	if not prov.is_empty() and not sett.is_empty():
		_open_settlement(prov, sett)
	elif not prov.is_empty():
		# Fallback: se non c'e' un settlement specifico, mostra info provincia
		title_label.text = prov
		var data = WorldData.get_province(prov)
		info_label.text = "Proprietario: %s\nRegione: %s\nTerreno: %s\nPopolazione: %d" % [
			GameState.state.provinces.get(prov, {}).get("owner", "N/D"),
			data.get("region", "N/D"),
			data.get("terrain", "N/D"),
			int(data.get("population", 0))
		]


func _open_settlement(province_name: String, settlement_name: String):
	current_province = province_name
	current_settlement = settlement_name
	title_label.text = settlement_name

	var region := _get_region(province_name)
	var prov = GameState.state.provinces.get(province_name, {})
	var settlements = prov.get("settlements", {})

	# Se il settlement esiste nei dati, mostra i suoi edifici
	if settlements is Dictionary and settlements.has(settlement_name):
		var s = settlements[settlement_name]
		buildings_list.clear()
		for b in s.get("buildings", []):
			var bdata = WorldData.get_building(b)
			var icon = IconManager.get_building_icon(b, region)
			buildings_list.add_item(bdata.get("name", b), icon)

		info_label.text = "Tipo: %s\nPopolazione: %d\nEdifici: %d" % [
			_translate_type(s.get("type", "civil")),
			int(s.get("population", 0)),
			s.get("buildings", []).size()
		]

		# Mappa dell'agglomerato con strade ed edifici
		if settlement_map and settlement_map.has_method("build_map"):
			settlement_map.build_map(s, region, province_name, settlement_name)
	else:
		# Fallback: mostra info generiche con icone e mappa
		var data = WorldData.get_province(province_name)
		buildings_list.clear()
		buildings_list.add_item("Centro urbano", IconManager.get_building_icon("centro_cittadino", region))
		buildings_list.add_item("Mercato", IconManager.get_building_icon("mercato", region))
		buildings_list.add_item("Caserma", IconManager.get_building_icon("caserma_i", region))
		info_label.text = "Tipo: Civile\nPopolazione: %d\nEdifici: 3 (predefiniti)" % [
			int(data.get("population", 0))
		]
		var fallback := {
			"type": "civil",
			"population": data.get("population", 0),
			"buildings": ["centro_cittadino", "mercato", "caserma_i"]
		}
		if settlement_map and settlement_map.has_method("build_map"):
			settlement_map.build_map(fallback, region, province_name, settlement_name)


func _get_region(province_name: String) -> String:
	var owner: String = GameState.state.provinces.get(province_name, {}).get("owner", "")
	if owner.is_empty():
		return "european"
	if IconManager and IconManager.has_method("region_for_faction"):
		return IconManager.region_for_faction(owner)
	return "european"


func _translate_type(type_name: String) -> String:
	match type_name.to_lower():
		"capital":
			return "Capitale"
		"military":
			return "Militare"
		"port":
			return "Porto"
		"industrial":
			return "Industriale"
		"civil":
			return "Civile"
		_:
			return type_name



func _add_recruitment_button():
	var recruit_button := Button.new()
	recruit_button.text = "Reclutamento"
	recruit_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	recruit_button.offset_left = -170.0
	recruit_button.offset_top = -50.0
	recruit_button.offset_right = -20.0
	recruit_button.offset_bottom = -15.0
	recruit_button.pressed.connect(_on_recruit)
	panel.add_child(recruit_button)


func _instantiate_recruitment_view():
	var view_scene := preload("res://scenes/settlement_view.tscn")
	_recruitment_view = view_scene.instantiate()
	add_child(_recruitment_view)


func _on_recruit():
	if _recruitment_view == null or current_province.is_empty() or current_settlement.is_empty():
		return
	_recruitment_view.open(current_province, current_settlement)


func _on_back():
	get_tree().change_scene_to_file("res://scenes/province_scene.tscn")


func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/province_scene.tscn")
