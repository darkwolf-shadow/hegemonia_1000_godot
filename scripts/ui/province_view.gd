extends Control

@onready var background: TextureRect = $Background
@onready var title_label: Label = $Title
@onready var settlements_list: ItemList = $SettlementsList
@onready var details_label: Label = $Details
@onready var enter_button: Button = $EnterButton
@onready var back_button: Button = $BackButton

var current_province: String = ""


func _ready():
	background.texture = UiHelper.create_parchment_texture(1920, 1080)
	UiHelper.apply_parchment_theme(self)
	enter_button.pressed.connect(_on_enter)
	back_button.pressed.connect(_on_back)
	settlements_list.item_selected.connect(_on_item_selected)
	visible = false


func _parchment_for_terrain(terrain: String) -> Texture2D:
	var base := Color(0.82, 0.72, 0.58)
	match terrain.to_lower():
		"forest", "foresta", "jungle", "giungla":
			base = Color(0.78, 0.74, 0.62)
		"mountain", "montagna", "mountains":
			base = Color(0.80, 0.76, 0.70)
		"desert", "deserto":
			base = Color(0.88, 0.80, 0.65)
		"coastal", "costiera", "coast":
			base = Color(0.84, 0.78, 0.62)
		"tundra", "snow":
			base = Color(0.85, 0.82, 0.78)
	return UiHelper.create_parchment_texture(1920, 1080, base, base.darkened(0.12))


func open(province_name: String):
	current_province = province_name
	visible = true
	title_label.text = province_name
	var data = WorldData.get_province(province_name)
	background.texture = _parchment_for_terrain(str(data.get("terrain", "generic")))
	_update_list()


func _load_icon(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	return null


func _load_background(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	return _load_icon("res://assets/backgrounds/1000/generic.svg")


func _update_list():
	settlements_list.clear()
	var prov = GameState.state.provinces.get(current_province, {})
	var settlements = prov.get("settlements", {})
	var owner = str(prov.get("owner", ""))
	var region = IconManager.region_for_faction(owner) if not owner.is_empty() else "european"
	for s_name in settlements.keys():
		var s = settlements[s_name]
		var icon = IconManager.get_settlement_icon_masked(str(s.get("type", "civil")), region)
		settlements_list.add_item("%s (%s)" % [s_name, s.get("type", "")], icon)

	var data = WorldData.get_province(current_province)
	details_label.text = "Regione: %s\nTerreno: %s\nPopolazione: %d\nProprietario: %s" % [
		data.get("region", ""),
		data.get("terrain", ""),
		data.get("population", 0),
		prov.get("owner", "")
	]


func _on_item_selected(index: int):
	pass


func _on_enter():
	var idx = settlements_list.get_selected_items()
	if idx.size() == 0:
		return
	var prov = GameState.state.provinces.get(current_province, {})
	var s_name = prov.get("settlements", {}).keys()[idx[0]]
	var settlement_view = get_tree().get_root().get_node_or_null("StrategicMap/CanvasLayer/UI/SettlementView")
	if settlement_view:
		settlement_view.open(current_province, s_name)


func _on_back():
	visible = false
