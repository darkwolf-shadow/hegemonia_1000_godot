extends Control

@onready var background: TextureRect = $Background
@onready var battlefield: Node2D = $BattleField

var _groups: Array = []
var _selected_group: Node2D = null
var _commander_group: Dictionary = {}
var _player_side: String = ""
var _phase: String = "deploy"
var _paused: bool = true
var _time_scale: float = 1.0
var _combat_active: bool = false
var _ai_timer: float = 0.0
var _battle: Dictionary = {}
var _visual_mode: String = "realistic"
const BattleGroupClass = preload("res://scripts/game/battle_group.gd")

var _top_bar: HBoxContainer
var _phase_label: Label
var _bottom_panel: Panel
var _group_icon: TextureRect
var _group_name: Label
var _group_info: Label
var _group_morale: ProgressBar
var _tactic_buttons: Dictionary = {}
var _commander_check: CheckBox
var _end_panel: Panel

const TACTIC_LABELS := {
	"standard": "Standard",
	"charge": "Carica",
	"shield_wall": "Muro di Scudi",
	"skirmish": "Schermaglia",
	"elephant_charge": "Carica Elefanti"
}

const ROLE_TACTICS := {
	"infantry": ["standard", "charge", "shield_wall"],
	"cavalry": ["standard", "charge"],
	"ranged": ["standard", "skirmish"],
	"artillery": ["standard", "skirmish"],
	"elephant": ["standard", "charge", "elephant_charge"]
}


func _ready():
	set_process(true)
	set_process_input(true)
	mouse_filter = MOUSE_FILTER_PASS
	_setup_ui()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	BattleSystem.battle_started.connect(_on_battle_started)
	BattleSystem.battle_ended.connect(_on_battle_ended)

	if GameState.state.pending_battle:
		var b = GameState.state.pending_battle
		BattleSystem.start_battle(b.attacker, b.defender, b.province, b.attacker_units, b.defender_units)
	else:
		BattleSystem.start_battle("Impero Bizantino", "Califfato Fatimide", "Nicea", {"fanteria": 20, "cavalleria": 5}, {"fanteria": 15, "arcieri": 10})


func _on_battle_started(battle):
	_battle = battle
	_phase = "deploy"
	_combat_active = false
	_paused = false
	_time_scale = 1.0
	_ai_timer = 0.0
	_setup_background(battle.province)
	_spawn_groups()
	_update_top_bar()
	_deselect_group()


func _setup_background(province_name: String):
	var data := WorldData.get_province(province_name)
	var terrain: String = (data.get("terrain", "generic") as String).to_lower()
	var bg_path := _get_background_path(terrain)
	if ResourceLoader.exists(bg_path):
		var tex := load(bg_path) as Texture2D
		background.texture = tex
	else:
		background.texture = null


func _get_background_path(terrain_lower: String) -> String:
	var png_name := ""
	if terrain_lower in ["forest", "foresta", "jungle", "giungla", "swamp", "palude"]:
		png_name = "forest"
	elif terrain_lower in ["mountain", "montagna", "mountains", "hills", "colline", "tundra"]:
		png_name = "mountain"
	elif terrain_lower in ["desert", "deserto", "savannah", "savana", "steppe", "steppa"]:
		png_name = "desert"
	elif terrain_lower in ["coastal", "costiera", "river", "fiume", "lake", "lago"]:
		png_name = "coastal"
	elif terrain_lower in ["plains", "pianura", "grassland", "prateria"]:
		png_name = "plains"
	else:
		png_name = "plains"
	var png_path := "res://assets/backgrounds/1000/png/" + png_name + ".png"
	if FileAccess.file_exists(png_path):
		return png_path
	var svg_path := "res://assets/backgrounds/1000/" + png_name + ".svg"
	if FileAccess.file_exists(svg_path):
		return svg_path
	return ""


func _spawn_groups():
	for g in _groups:
		if is_instance_valid(g):
			g.queue_free()
	_groups.clear()
	for child in battlefield.get_children():
		child.queue_free()

	var region_att := IconManager.region_for_faction(_battle.attacker)
	var region_def := IconManager.region_for_faction(_battle.defender)

	if _battle.attacker == GameState.state.player_faction:
		_player_side = "attacker"
	elif _battle.defender == GameState.state.player_faction:
		_player_side = "defender"
	else:
		_player_side = "attacker"

	var terrain_mods: Dictionary = WorldData.terrain_modifiers.get(_battle.terrain, {})
	var att_mod: float = terrain_mods.get("attack", 1.0)
	var def_mod: float = terrain_mods.get("defense", 1.0)

	_spawn_side(_battle.attacker_units, "attacker", region_att, true, att_mod, 1.0)
	_spawn_side(_battle.defender_units, "defender", region_def, false, 1.0, def_mod)


func _spawn_side(units: Dictionary, side: String, region: String, left_side: bool, attack_mod: float, defense_mod: float):
	var is_player := (side == _player_side)
	var faction_name: String = _battle.attacker if side == "attacker" else _battle.defender
	var faction := WorldData.get_faction(faction_name)
	var side_color := Color(faction.get("color", "#ffffff"))
	var start_x: float = -600.0 if left_side else 600.0
	var idx: int = 0
	var total := units.size()
	for unit_type in units.keys():
		var count: int = units[unit_type]
		if count <= 0:
			continue
		var group: Node2D = preload("res://scenes/battle_group.tscn").instantiate()
		battlefield.add_child(group)
		var y: float = (idx - total / 2.0) * 90.0 + randf_range(-20.0, 20.0)
		var x: float = start_x + randf_range(-60.0, 60.0)
		group.position = Vector2(x, y)
		group.init(unit_type, side, count, region, is_player, attack_mod, defense_mod, side_color)
		group.selected.connect(_on_group_selected)
		group.died.connect(_on_group_died)
		group.commander_died.connect(_on_commander_died)
		_groups.append(group)
		idx += 1


func _process(delta: float):
	if _paused:
		return
	var dt := delta * _time_scale

	for child in battlefield.get_children():
		if child.has_method("update"):
			child.update(dt)

	if _combat_active:
		_ai_timer += dt
		if _ai_timer >= 1.2:
			_ai_timer = 0.0
			_run_ai()
		_check_end()

	_update_top_bar()
	if _selected_group != null and is_instance_valid(_selected_group):
		_update_bottom_panel()


func _input(event: InputEvent):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if get_viewport().is_input_handled():
		return

	var mouse_pos := get_viewport().get_mouse_position()
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered != null and hovered != self:
		return

	var clicked_group := _group_at(mouse_pos)

	if clicked_group != null:
		if clicked_group.side == _player_side:
			_select_group(clicked_group)
			accept_event()
			return
		elif _selected_group != null and is_instance_valid(_selected_group) and _selected_group.side == _player_side:
			if _phase == "combat":
				_selected_group.attack_target = clicked_group
			_selected_group.target_pos = clicked_group.global_position
			accept_event()
			return

	if _selected_group != null and is_instance_valid(_selected_group) and _selected_group.side == _player_side:
		_selected_group.attack_target = null
		_selected_group.target_pos = mouse_pos
		accept_event()


func _group_at(pos: Vector2) -> Node2D:
	var best: Node2D = null
	var best_dist: float = 120.0
	for g in _groups:
		if not is_instance_valid(g):
			continue
		var d: float = g.global_position.distance_to(pos)
		if d < best_dist:
			best_dist = d
			best = g
	return best


func _select_group(group: Node2D):
	_deselect_group()
	_selected_group = group
	_selected_group.set_selected(true)
	_update_bottom_panel()
	_bottom_panel.visible = true


func _deselect_group():
	if _selected_group != null and is_instance_valid(_selected_group):
		_selected_group.set_selected(false)
	_selected_group = null
	_bottom_panel.visible = false


func _on_group_selected(group: Node2D):
	_select_group(group)


func _on_group_died(group: Node2D):
	if _selected_group == group:
		_deselect_group()
	_groups.erase(group)
	if _commander_group.get(group.side) == group:
		_commander_group.erase(group.side)


func _on_commander_died(side: String):
	GameState.push_event("Il comandante è morto! Morale crollato per %s" % side)
	for g in _groups:
		if is_instance_valid(g) and g.side == side:
			g.morale -= 20.0


func _run_ai():
	for g in _groups:
		if not is_instance_valid(g):
			continue
		if g.side == _player_side:
			continue
		var battle := _make_ai_snapshot(g.side)
		var tactic := AIController.choose_battle_tactic(battle, g.side)
		g.set_tactic(tactic)
		var target := _nearest_enemy(g)
		if target != null:
			g.attack_target = target
			g.target_pos = target.global_position


func _make_ai_snapshot(side: String) -> Dictionary:
	var att := _count_units("attacker")
	var def := _count_units("defender")
	var att_morale := _avg_morale("attacker")
	var def_morale := _avg_morale("defender")
	return {
		"attacker": _battle.attacker,
		"defender": _battle.defender,
		"attacker_units": att,
		"defender_units": def,
		"attacker_morale": att_morale,
		"defender_morale": def_morale,
		"terrain": _battle.terrain,
	}


func _count_units(side: String) -> Dictionary:
	var out := {}
	for g in _groups:
		if is_instance_valid(g) and g.side == side and g.count > 0:
			out[g.unit_type] = out.get(g.unit_type, 0) + g.count
	return out


func _avg_morale(side: String) -> float:
	var total := 0.0
	var n := 0
	for g in _groups:
		if is_instance_valid(g) and g.side == side and g.count > 0:
			total += g.morale
			n += 1
	if n == 0:
		return 0.0
	return total / n


func _nearest_enemy(group: Node2D) -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for g in _groups:
		if not is_instance_valid(g) or g == group or g.side == group.side or g.count <= 0:
			continue
		var d: float = group.global_position.distance_to(g.global_position)
		if d < best_dist:
			best_dist = d
			best = g
	return best


func _check_end():
	var att_alive := _side_alive("attacker")
	var def_alive := _side_alive("defender")
	if att_alive and def_alive:
		return
	if not att_alive and not def_alive:
		_end_battle("stalemate")
	elif att_alive:
		_end_battle("attacker")
	else:
		_end_battle("defender")


func _side_alive(side: String) -> bool:
	for g in _groups:
		if is_instance_valid(g) and g.side == side and g.count > 0 and not g.is_routing:
			return true
	return false


func _end_battle(winner: String):
	_paused = true
	_combat_active = false
	if winner == "attacker":
		BattleSystem.current_battle.attacker_morale = max(1, _avg_morale("attacker"))
		BattleSystem.current_battle.defender_morale = 0
	elif winner == "defender":
		BattleSystem.current_battle.attacker_morale = 0
		BattleSystem.current_battle.defender_morale = max(1, _avg_morale("defender"))
	else:
		BattleSystem.current_battle.attacker_morale = _avg_morale("attacker")
		BattleSystem.current_battle.defender_morale = _avg_morale("defender")
	BattleSystem.end_battle()
	_show_end_panel(winner)


func _on_battle_ended(result):
	GameState.clear_pending_battle()


func _show_end_panel(winner: String):
	var text := "Pareggio"
	if winner == "attacker":
		text = "Vince l'Attaccante"
	elif winner == "defender":
		text = "Vince il Difensore"
	var label := _end_panel.get_node("VBox/Label") as Label
	if label:
		label.text = text
	_end_panel.visible = true


func _setup_ui():
	_top_bar = HBoxContainer.new()
	_top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_bar.offset_left = 20.0
	_top_bar.offset_top = 20.0
	_top_bar.offset_right = -20.0
	_top_bar.offset_bottom = 60.0
	_top_bar.add_theme_constant_override("separation", 12)
	add_child(_top_bar)

	_phase_label = Label.new()
	_phase_label.text = "Fase di Posizionamento"
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.custom_minimum_size = Vector2(220, 0)
	_top_bar.add_child(_phase_label)

	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.pressed.connect(_on_play)
	_top_bar.add_child(play_btn)

	var pause_btn := Button.new()
	pause_btn.text = "Pausa"
	pause_btn.pressed.connect(_on_pause)
	_top_bar.add_child(pause_btn)

	var fast_btn := Button.new()
	fast_btn.text = "Veloce"
	fast_btn.pressed.connect(_on_fast)
	_top_bar.add_child(fast_btn)

	var start_btn := Button.new()
	start_btn.text = "Inizia Battaglia"
	start_btn.pressed.connect(_on_start_combat)
	_top_bar.add_child(start_btn)

	var toggle_btn := Button.new()
	toggle_btn.text = "Vista: 3D"
	toggle_btn.pressed.connect(_on_toggle_visual)
	_top_bar.add_child(toggle_btn)

	var return_btn := Button.new()
	return_btn.text = "Torna alla Mappa"
	return_btn.pressed.connect(_on_return)
	_top_bar.add_child(return_btn)

	_bottom_panel = Panel.new()
	_bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_panel.offset_left = 20.0
	_bottom_panel.offset_top = -180.0
	_bottom_panel.offset_right = -20.0
	_bottom_panel.offset_bottom = -20.0
	_bottom_panel.visible = false
	add_child(_bottom_panel)

	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	bottom_hbox.offset_left = 12.0
	bottom_hbox.offset_top = 12.0
	bottom_hbox.offset_right = -12.0
	bottom_hbox.offset_bottom = -12.0
	bottom_hbox.add_theme_constant_override("separation", 16)
	_bottom_panel.add_child(bottom_hbox)

	_group_icon = TextureRect.new()
	_group_icon.custom_minimum_size = Vector2(96, 96)
	_group_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bottom_hbox.add_child(_group_icon)

	var stats_vbox := VBoxContainer.new()
	stats_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_vbox.add_theme_constant_override("separation", 6)
	bottom_hbox.add_child(stats_vbox)

	_group_name = Label.new()
	_group_name.add_theme_font_size_override("font_size", 22)
	stats_vbox.add_child(_group_name)

	_group_info = Label.new()
	stats_vbox.add_child(_group_info)

	_group_morale = ProgressBar.new()
	_group_morale.max_value = 100.0
	_group_morale.value = 100.0
	stats_vbox.add_child(_group_morale)

	_commander_check = CheckBox.new()
	_commander_check.text = "Comandante"
	_commander_check.toggled.connect(_on_commander_toggled)
	stats_vbox.add_child(_commander_check)

	var tactics_vbox := VBoxContainer.new()
	tactics_vbox.add_theme_constant_override("separation", 6)
	bottom_hbox.add_child(tactics_vbox)

	var tactics_label := Label.new()
	tactics_label.text = "Tattica"
	tactics_vbox.add_child(tactics_label)

	for key in ["standard", "charge", "shield_wall", "skirmish", "elephant_charge"]:
		var btn := Button.new()
		btn.text = TACTIC_LABELS[key]
		btn.pressed.connect(_on_tactic_pressed.bind(key))
		_tactic_buttons[key] = btn
		tactics_vbox.add_child(btn)

	_end_panel = Panel.new()
	_end_panel.set_anchors_preset(Control.PRESET_CENTER)
	_end_panel.custom_minimum_size = Vector2(400, 200)
	_end_panel.visible = false
	add_child(_end_panel)

	var end_vbox := VBoxContainer.new()
	end_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_vbox.offset_left = 12.0
	end_vbox.offset_top = 12.0
	end_vbox.offset_right = -12.0
	end_vbox.offset_bottom = -12.0
	end_vbox.name = "VBox"
	end_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_end_panel.add_child(end_vbox)

	var end_label := Label.new()
	end_label.name = "Label"
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.add_theme_font_size_override("font_size", 28)
	end_vbox.add_child(end_label)

	var end_return := Button.new()
	end_return.text = "Torna alla Mappa"
	end_return.pressed.connect(_on_return)
	end_vbox.add_child(end_return)


func _update_top_bar():
	if _phase_label == null:
		return
	if _phase == "deploy":
		_phase_label.text = "Fase di Posizionamento"
	elif _paused:
		_phase_label.text = "Battaglia in pausa"
	else:
		_phase_label.text = "Battaglia in corso (x%.1f)" % _time_scale


func _update_bottom_panel():
	if _selected_group == null or not is_instance_valid(_selected_group):
		return
	var data := WorldData.get_unit(_selected_group.unit_type)
	var region := IconManager.region_for_faction(_player_side if _selected_group.side == _player_side else _battle.defender if _selected_group.side == "defender" else _battle.attacker)
	_group_icon.texture = IconManager.get_unit_icon(_selected_group.unit_type, region)
	_group_name.text = data.get("name", _selected_group.unit_type)
	_group_info.text = "Lato: %s\nTruppe: %d / %d\nAttacco: %.2f\nDifesa: %.2f\nVelocità: %.1f" % [
		_selected_group.side,
		_selected_group.count,
		_selected_group.max_count,
		data.get("attack", 0.0),
		data.get("defense", 0.0) + data.get("armor", 0.0),
		data.get("speed", 0.0)
	]
	_group_morale.max_value = _selected_group.max_morale
	_group_morale.value = _selected_group.morale
	_commander_check.set_block_signals(true)
	_commander_check.button_pressed = _selected_group.has_commander
	_commander_check.set_block_signals(false)

	var allowed := ROLE_TACTICS.get(_selected_group.role, ["standard"]) as Array
	for key in _tactic_buttons.keys():
		var btn: Button = _tactic_buttons[key]
		btn.visible = key in allowed
		btn.disabled = not (key in allowed)
		if _selected_group.tactic == key:
			btn.add_theme_color_override("font_color", Color.GOLD)
		else:
			btn.remove_theme_color_override("font_color")


func _on_play():
	if _phase == "deploy":
		_on_start_combat()
		return
	_paused = false
	_time_scale = 1.0


func _on_pause():
	_paused = true
	_time_scale = 1.0


func _on_fast():
	if _phase == "deploy":
		_on_start_combat()
	_paused = false
	_time_scale = 3.0


func _on_toggle_visual():
	_visual_mode = "3d" if _visual_mode == "realistic" else "realistic"
	BattleGroupClass.set_default_visual_mode(_visual_mode)
	for g in _groups:
		if is_instance_valid(g):
			g.set_visual_mode(_visual_mode)
	for child in _top_bar.get_children():
		if child is Button and child.text.begins_with("Vista:"):
			child.text = "Vista: 3D" if _visual_mode == "3d" else "Vista: Realistico"
			break


func _on_start_combat():
	_phase = "combat"
	_combat_active = true
	_paused = false
	_time_scale = 1.0
	for g in _groups:
		if is_instance_valid(g):
			g.combat_active = true
			g.target_pos = g.global_position


func _on_tactic_pressed(key: String):
	if _selected_group != null and is_instance_valid(_selected_group):
		_selected_group.set_tactic(key)
		_update_bottom_panel()


func _on_commander_toggled(value: bool):
	if _selected_group == null or not is_instance_valid(_selected_group):
		return
	if _selected_group.side != _player_side:
		_commander_check.button_pressed = false
		return
	if value:
		for g in _groups:
			if is_instance_valid(g) and g.side == _selected_group.side:
				g.set_commander(false)
		_selected_group.set_commander(true)
		_commander_group[_selected_group.side] = _selected_group
	else:
		_selected_group.set_commander(false)
		_commander_group.erase(_selected_group.side)
	_update_bottom_panel()


func _on_return():
	GameState.clear_pending_battle()
	get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")
