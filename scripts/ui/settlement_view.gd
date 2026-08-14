extends Control

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


func _ready():
	build_button.pressed.connect(_on_build)
	recruit_button.pressed.connect(_on_recruit)
	back_button.pressed.connect(_on_back)
	buildable_list.item_selected.connect(_on_building_selected)
	units_list.item_selected.connect(_on_unit_selected)
	visible = false


func open(province_name: String, settlement_name: String):
	current_province = province_name
	current_settlement_name = settlement_name
	current_settlement = SettlementManager.get_settlement(
		GameState.state.provinces.get(province_name, {}),
		settlement_name
	)
	visible = true
	_update_ui()


func _update_ui():
	title_label.text = "%s (%s)" % [current_settlement_name, current_settlement.get("type", "")]

	buildings_list.clear()
	for b in current_settlement.get("buildings", []):
		buildings_list.add_item(WorldData.get_building(b).get("name", b))

	buildable_list.clear()
	available_buildings = []
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	for b in WorldData.buildings.keys():
		if SettlementManager.can_build_settlement_building(faction, current_settlement, b):
			available_buildings.append(b)
			buildable_list.add_item(WorldData.get_building(b).get("name", b))

	units_list.clear()
	available_units = SettlementManager.get_recruitable_units(faction, current_settlement)
	for u in available_units:
		var data = WorldData.get_unit(u)
		units_list.add_item("%s (oro %d)" % [data.get("name", u), data.get("cost", 0)])

	info_label.text = "Risorse: " + JSON.stringify(faction.get("resources", {}))


func _on_building_selected(index: int):
	var b = available_buildings[index]
	info_label.text = "Costo: " + JSON.stringify(WorldData.get_building(b).get("cost", {}))


func _on_build():
	var idx = buildable_list.selected
	if idx < 0:
		return
	var b = available_buildings[idx]
	var faction = GameState.state.factions.get(GameState.state.player_faction, {})
	if SettlementManager.build_settlement_building(faction, GameState.state.provinces[current_province], current_settlement_name, b):
		_update_ui()


func _on_unit_selected(index: int):
	pass


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
