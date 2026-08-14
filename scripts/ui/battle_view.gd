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
	_update_info()


func _update_info():
	var b = BattleSystem.current_battle
	if b.is_empty():
		return
	attacker_info.text = "%s\nMorale: %d\nTruppe: %s" % [b.attacker, b.attacker_morale, JSON.stringify(b.attacker_units)]
	defender_info.text = "%s\nMorale: %d\nTruppe: %s" % [b.defender, b.defender_morale, JSON.stringify(b.defender_units)]
	morale_att.value = b.attacker_morale
	morale_def.value = b.defender_morale
	_draw_units()


func _draw_units():
	for child in battlefield.get_children():
		child.queue_free()
	var b = BattleSystem.current_battle
	if b.is_empty():
		return

	var x := -250
	for unit_type in b.attacker_units.keys():
		var count = b.attacker_units[unit_type]
		for i in range(min(count, 10)):
			var icon = _make_unit_icon(unit_type, Color(0.2, 0.4, 0.9))
			icon.position = Vector2(x + i * 35, randf_range(-40, 40))
			battlefield.add_child(icon)

	x = 150
	for unit_type in b.defender_units.keys():
		var count = b.defender_units[unit_type]
		for i in range(min(count, 10)):
			var icon = _make_unit_icon(unit_type, Color(0.9, 0.2, 0.2))
			icon.position = Vector2(x + i * 35, randf_range(-40, 40))
			battlefield.add_child(icon)


func _make_unit_icon(unit_type: String, color: Color) -> Polygon2D:
	var p = Polygon2D.new()
	p.polygon = PackedVector2Array([Vector2(0, -12), Vector2(10, 8), Vector2(-10, 8)])
	p.color = color
	return p


func _on_next_round():
	var tactic = tactic_option.get_item_text(tactic_option.selected)
	var ai_tactic = AIController.choose_battle_tactic()
	BattleSystem.play_round(tactic, ai_tactic)


func _on_round_ended(report):
	_update_info()
	report_label.text = "Round %d: %s\nForza attaccante: %.1f\nForza difensore: %.1f" % [report.round, report.result, report.attacker_strength, report.defender_strength]


func _on_battle_ended(result):
	_update_info()
	report_label.text = "Fine battaglia. Vince %s" % result.winner
	next_button.disabled = true


func _on_auto():
	while not BattleSystem.current_battle.is_empty():
		var tactic = tactic_option.get_item_text(tactic_option.selected)
		var ai_tactic = AIController.choose_battle_tactic()
		BattleSystem.play_round(tactic, ai_tactic)


func _on_return():
	GameState.clear_pending_battle()
	next_button.disabled = false
	get_tree().change_scene_to_file("res://scenes/strategic_map.tscn")
