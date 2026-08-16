extends Control

@onready var title_label := $Title
@onready var attacker_info := $AttackerPanel/AttackerInfo
@onready var defender_info := $DefenderPanel/DefenderInfo
@onready var morale_att := $AttackerPanel/MoraleBarAtt
@onready var morale_def := $DefenderPanel/MoraleBarDef
@onready var tactic_option := $CenterPanel/TacticOption
@onready var next_button := $CenterPanel/NextRoundButton
@onready var auto_button := $CenterPanel/AutoButton
@onready var return_button := $CenterPanel/ReturnButton
@onready var report_label := $ReportLabel
@onready var battlefield := $BattleField

var _unit_nodes: Array = []
var _pending_att_tactic: String = "standard"
var _pending_def_tactic: String = "standard"
var _round_count: int = 0

class BattleUnit:
	extends Node2D
	var unit_type: String
	var side: String
	var sprite: Sprite2D
	var target_pos: Vector2
	var base_pos: Vector2
	var unit_speed: float = 40.0

	func _init(type_name: String, side_name: String, region: String, color: Color):
		unit_type = type_name
		side = side_name
		sprite = Sprite2D.new()
		var tex = IconManager.get_battle_sprite(type_name, region)
		if tex == null:
			tex = IconManager.get_unit_icon(type_name, region)
		sprite.texture = tex
		sprite.modulate = color
		sprite.scale = Vector2(0.35, 0.35)
		add_child(sprite)
		var data = WorldData.get_unit(type_name)
		unit_speed = data.get("speed", 2.0) * 15.0
		base_pos = Vector2.ZERO
		target_pos = Vector2.ZERO


func _ready():
	next_button.pressed.connect(_on_next_round)
	auto_button.pressed.connect(_on_auto)
	return_button.pressed.connect(_on_return)
	BattleSystem.battle_started.connect(_on_battle_started)
	BattleSystem.round_ended.connect(_on_round_ended)
	BattleSystem.battle_ended.connect(_on_battle_ended)

	if GameState.state.pending_battle:
		var b = GameState.state.pending_battle
		BattleSystem.start_battle(b.attacker, b.defender, b.province, b.attacker_units, b.defender_units)
	else:
		# Battaglia di test per verificare la scena
		BattleSystem.start_battle("Impero Bizantino", "Califfato Fatimide", "Nicea", {"fanteria": 20, "cavalleria": 5}, {"fanteria": 15, "arcieri": 10})


func _on_battle_started(battle):
	title_label.text = "Battaglia per %s" % battle.province
	_round_count = 0
	_spawn_units()
	_update_info()


func _update_info():
	var b = BattleSystem.current_battle
	if b.is_empty():
		return
	attacker_info.text = "%s\nMorale: %d\nTruppe: %s" % [b.attacker, b.attacker_morale, JSON.stringify(b.attacker_units)]
	defender_info.text = "%s\nMorale: %d\nTruppe: %s" % [b.defender, b.defender_morale, JSON.stringify(b.defender_units)]
	morale_att.value = b.attacker_morale
	morale_def.value = b.defender_morale
	_cull_dead()
	_update_unit_positions(_pending_att_tactic, _pending_def_tactic)


func _spawn_units():
	for child in battlefield.get_children():
		child.queue_free()
	_unit_nodes.clear()

	var b = BattleSystem.current_battle
	if b.is_empty():
		return

	var region_att: String = IconManager.region_for_faction(b.attacker)
	var region_def: String = IconManager.region_for_faction(b.defender)
	_add_side_units(b.attacker_units, "attacker", Color(0.2, 0.4, 0.9), region_att)
	_add_side_units(b.defender_units, "defender", Color(0.9, 0.2, 0.2), region_def)


func _add_side_units(units: Dictionary, side: String, color: Color, region: String):
	var base_x: float = -250.0 if side == "attacker" else 150.0
	var idx: int = 0
	for unit_type in units.keys():
		var count: int = units[unit_type]
		var visual_count: int = min(count, 10)
		for i in range(visual_count):
			var u := BattleUnit.new(unit_type, side, region, color)
			var col: int = idx / 6
			var row: int = idx % 6
			var x: float = base_x + col * 35.0 + randf_range(-6.0, 6.0)
			var y: float = (row - 2.5) * 45.0 + randf_range(-12.0, 12.0)
			u.position = Vector2(x, y)
			u.base_pos = u.position
			u.target_pos = u.position
			battlefield.add_child(u)
			_unit_nodes.append(u)
			idx += 1


func _cull_dead():
	var b = BattleSystem.current_battle
	if b.is_empty():
		return
	var kept: Dictionary = {}
	for u in _unit_nodes.duplicate():
		var unit := u as BattleUnit
		var counts: Dictionary = b.attacker_units if unit.side == "attacker" else b.defender_units
		var count: int = min(counts.get(unit.unit_type, 0), 10)
		var key: String = unit.side + "_" + unit.unit_type
		var current: int = kept.get(key, 0)
		if current < count:
			kept[key] = current + 1
		else:
			unit.queue_free()
			_unit_nodes.erase(u)


func _update_unit_positions(tactic_att: String, tactic_def: String):
	var b = BattleSystem.current_battle
	if b.is_empty():
		return
	for u in _unit_nodes:
		var unit := u as BattleUnit
		var tactic: String = tactic_att if unit.side == "attacker" else tactic_def
		unit.target_pos = _target_for_unit(unit, tactic)


func _target_for_unit(unit: BattleUnit, tactic: String) -> Vector2:
	var role: String = _unit_role(unit.unit_type)
	var base: Vector2 = unit.base_pos
	var advance: float = 0.0
	match tactic:
		"charge":
			advance = 35.0 if role in ["cavalry", "elephant"] else 25.0
			if role == "ranged":
				advance = 8.0
			if role == "artillery":
				advance = 4.0
		"skirmish":
			if role == "ranged":
				advance = -10.0
			elif role == "cavalry":
				advance = 15.0
			else:
				advance = 8.0
		"shield_wall":
			advance = 5.0 if role in ["infantry", "elephant"] else 0.0
		_:
			advance = 12.0 if role in ["infantry", "cavalry", "elephant"] else 4.0

	# I difensori partono da x positivo e avanzano verso sinistra (valori negativi)
	var sign: float = 1.0 if unit.side == "attacker" else -1.0
	var max_x: float = 80.0 if unit.side == "attacker" else -80.0
	var new_x: float = clampf(base.x + advance * sign, min(base.x, max_x), max(base.x, max_x))
	return Vector2(new_x, base.y)


func _unit_role(unit_type: String) -> String:
	var key: String = unit_type.to_lower()
	if key.contains("elephant"):
		return "elephant"
	if key.contains("caval") or key.contains("cataphract") or key.contains("mamluk") or key.contains("ghilman") or key.contains("ghulam") or key.contains("lancer") or key.contains("drak") or key.contains("druzhina") or key.contains("jinete") or key.contains("magyar") or key.contains("horse") or key.contains("soninke"):
		return "cavalry"
	if key.contains("arcier") or key.contains("archer") or key.contains("crossbow") or key.contains("balestri") or key.contains("toxot") or key.contains("shenbi") or key.contains("atlatl") or key.contains("javelin") or key.contains("arcieri"):
		return "ranged"
	if key.contains("artiglier") or key.contains("catapult") or key.contains("onager") or key.contains("scorpion"):
		return "artillery"
	return "infantry"


func _process(delta: float):
	for u in _unit_nodes:
		var unit := u as BattleUnit
		unit.position = unit.position.lerp(unit.target_pos, delta * 3.0)
		if unit.side == "attacker":
			unit.sprite.flip_h = false
		else:
			unit.sprite.flip_h = true


func _on_next_round():
	var tactic: String = tactic_option.get_item_text(tactic_option.selected)
	var ai_tactic: String = AIController.choose_battle_tactic(BattleSystem.current_battle, "defender")
	_pending_att_tactic = tactic
	_pending_def_tactic = ai_tactic
	BattleSystem.play_round(tactic, ai_tactic)
	_round_count += 1


func _on_round_ended(report):
	_update_info()
	report_label.text = "Round %d: %s\nForza attaccante: %.1f\nForza difensore: %.1f" % [report.round, report.result, report.attacker_strength, report.defender_strength]


func _on_battle_ended(result):
	_update_info()
	report_label.text = "Fine battaglia. Vince %s" % result.winner
	next_button.disabled = true


func _on_auto():
	while not BattleSystem.current_battle.is_empty():
		var tactic: String = tactic_option.get_item_text(tactic_option.selected)
		var ai_tactic: String = AIController.choose_battle_tactic(BattleSystem.current_battle, "defender")
		_pending_att_tactic = tactic
		_pending_def_tactic = ai_tactic
		BattleSystem.play_round(tactic, ai_tactic)
		_round_count += 1


func _on_return():
	GameState.clear_pending_battle()
	next_button.disabled = false
	get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")
