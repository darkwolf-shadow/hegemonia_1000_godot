extends Control

@onready var background: TextureRect = $Background
@onready var title_label: Label = $Title
@onready var buildings_list: ItemList = $BuildingsList
@onready var buildable_list: OptionButton = $BuildableList
@onready var build_button: Button = $BuildButton
@onready var units_list: ItemList = $UnitsList
@onready var amount_spin: SpinBox = $AmountSpin
@onready var recruit_button: Button = $RecruitButton
@onready var back_button: Button = $BackButton
@onready var info_label: Label = $InfoLabel

var current_province: String = ""
var current_settlement_name: String = ""
var current_settlement: Dictionary = {}
var available_units: Array = []
var available_buildings: Array = []


func _region() -> String:
	return IconManager.region_for_faction(GameState.state.player_faction)


func _load_background(settlement_type: String) -> Texture2D:
	var type_key := settlement_type.to_lower()
	var paths := [
		"res://assets/backgrounds/1000/png/" + type_key + ".png",
		"res://assets/backgrounds/1000/svg/" + type_key + ".svg",
		"res://assets/backgrounds/1000/png/generic.png",
		"res://assets/backgrounds/1000/svg/generic.svg",
		"res://assets/ui_textures/southern_european/sharedpage_00.png"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var res = load(p)
			if res is Texture2D:
				return res
	return null


func _ready():
	build_button.pressed.connect(_on_build)
	recruit_button.pressed.connect(_on_recruit)
	back_button.pressed.connect(_on_back)
	buildable_list.item_selected.connect(_on_building_selected)
	units_list.item_selected.connect(_on_unit_selected)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	visible = false


func open(province_name: String, settlement_name: String):
	current_province = province_name
	current_settlement_name = settlement_name
	current_settlement = SettlementManager.get_settlement(
		GameState.state.provinces.get(province_name, {}),
		settlement_name
	)
	visible = true
	background.texture = _load_background(current_settlement.get("type", "generic"))
	_update_ui()


func _update_ui():
	title_label.text = "%s (%s)" % [current_settlement_name, current_settlement.get("type", "")]
	var region := _region()

	buildings_list.clear()
	for b in current_settlement.get("buildings", []):
		var icon := IconManager.get_building_icon(b, region)
		buildings_list.add_item(WorldData.get_building(b).get("name", b), icon)

	buildable_list.clear()
	available_buildings = []
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	for b in WorldData.buildings.keys():
		if SettlementManager.can_build_settlement_building(faction, current_settlement, b):
			available_buildings.append(b)
			var bicon := IconManager.get_building_icon(b, region)
			if bicon:
				buildable_list.add_icon_item(bicon, WorldData.get_building(b).get("name", b))
			else:
				buildable_list.add_item(WorldData.get_building(b).get("name", b))

	units_list.clear()
	available_units = SettlementManager.get_recruitable_units(faction, current_settlement)
	for u in available_units:
		var data := WorldData.get_unit(u)
		var icon := IconManager.get_unit_icon(u, region)
		units_list.add_item("%s (oro %d)" % [data.get("name", u), data.get("cost", 0)], icon)

	info_label.text = "Risorse fazione: " + _resources_text(faction.get("resources", {}))


func _resources_text(resources: Dictionary) -> String:
	var out := ""
	for r in ["oro", "legname", "pietra", "ferro", "armi", "cibo", "prestigio"]:
		if out != "":
			out += "  "
		out += "%s: %d" % [r.capitalize(), resources.get(r, 0)]
	return out


func _on_building_selected(index: int):
	var b: String = available_buildings[index]
	var data: Dictionary = WorldData.get_building(b)
	var unlocks: Array = data.get("unlocks_units", [])
	var unlock_text := "Sblocca: " + ", ".join(unlocks) if unlocks.size() > 0 else "Nessuna unità aggiuntiva"
	info_label.text = "Costo: " + _resources_text(data.get("cost", {})) + "\n" + unlock_text


func _on_build():
	var idx = buildable_list.selected
	if idx < 0:
		return
	var b: String = available_buildings[idx]
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	if SettlementManager.build_settlement_building(faction, GameState.state.provinces[current_province], current_settlement_name, b):
		_update_ui()


func _on_unit_selected(index: int):
	var u: String = available_units[index]
	var data: Dictionary = WorldData.get_unit(u)
	info_label.text = "%s | Att %.2f | Dif %.2f | Arm %.2f | Vel %.2f\nCosto per unità: oro %d, legname %d, pietra %d, ferro %d, armi %d, pop %d" % [
		data.get("name", u),
		data.get("attack", 0.0),
		data.get("defense", 0.0),
		data.get("armor", 0.0),
		data.get("speed", 0.0),
		data.get("cost", 0),
		data.get("legname", 0),
		data.get("pietra", 0),
		data.get("ferro", 0),
		data.get("armi", 0),
		data.get("pop", 0)
	]


func _on_recruit():
	var idx = units_list.get_selected_items()
	if idx.size() == 0:
		return
	var u = available_units[idx[0]]
	var amount = int(amount_spin.value)
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	if SettlementManager.recruit_in_settlement(faction, current_settlement, u, amount):
		_update_ui()


func _on_back():
	visible = false
