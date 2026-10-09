class_name BattleGroup
extends Node2D

signal selected(group)
signal died(group)
signal commander_died(side)
signal formation_changed(group)

static var _visual_mode: String = "vector_3d"

var unit_type: String = ""
var side: String = ""
var count: int = 0
var max_count: int = 0
var morale: float = 100.0
var max_morale: float = 100.0
var is_player: bool = false
var has_commander: bool = false
var tactic: String = "standard"
var role: String = "infantry"

# Sistema formazioni - Dark Corporation / Stev
var formation: int = 0  # FormationSystem.FormationType.LINE
var _formation_reform_time: float = 0.0
var _formation_slots_visual: Array = []

var target_pos: Vector2 = Vector2.ZERO
var attack_target: Node2D = null

var speed: float = 60.0
var attack_range: float = 40.0
var attack_cooldown: float = 0.0
var attack_interval: float = 1.5

var is_routing: bool = false
var is_selected: bool = false
var routing_time: float = 0.0
var combat_active: bool = false

var _data: Dictionary = {}
var _terrain_attack_mod: float = 1.0
var _terrain_defense_mod: float = 1.0

# Modificatori formazione (aggiornati quando cambia)
var _formation_attack_mod: float = 1.0
var _formation_defense_mod: float = 1.0
var _formation_speed_mod: float = 1.0
var _formation_morale_mod: float = 1.0
var _formation_range_mod: float = 1.0

const FormationSystemGD = preload("res://scripts/game/formation_system.gd")
const BattleUnitVisualGD = preload("res://scripts/game/battle_unit_visual.gd")

var _visual = null
@onready var count_label: Label = $CountLabel


static func set_default_visual_mode(mode: String):
	_visual_mode = mode


func set_visual_mode(mode: String):
	if _visual != null and is_instance_valid(_visual):
		_visual.set_visual_mode(mode)


func init(type_name: String, side_name: String, unit_count: int, region: String, player_side: bool, terrain_attack: float = 1.0, terrain_defense: float = 1.0, side_color: Color = Color.WHITE):
	unit_type = type_name
	side = side_name
	count = unit_count
	max_count = unit_count
	is_player = player_side
	_terrain_attack_mod = terrain_attack
	_terrain_defense_mod = terrain_defense
	_data = WorldData.get_unit(type_name)
	max_morale = _data.get("base_morale", 100.0)
	morale = max_morale

	role = _unit_role(type_name)
	_set_role_stats()
	_set_tactic_modifiers()

	# Formazione iniziale in base al ruolo
	_set_default_formation()

	_create_visual(region, side_color)
	_update_label()
	set_process(false)


func _set_default_formation():
	match role:
		"ranged":
			formation = FormationSystemGD.FormationType.SPREAD
		"cavalry":
			formation = FormationSystemGD.FormationType.WEDGE
		"elephant":
			formation = FormationSystemGD.FormationType.WEDGE
		"infantry":
			formation = FormationSystemGD.FormationType.LINE
		"artillery":
			formation = FormationSystemGD.FormationType.LINE
		_:
			formation = FormationSystemGD.FormationType.LINE
	_apply_formation_modifiers()


func set_formation(new_formation: int):
	if formation == new_formation:
		return
	formation = new_formation
	_formation_reform_time = 2.0  # tempo per riformare
	_apply_formation_modifiers()
	formation_changed.emit(self)
	if _visual != null and is_instance_valid(_visual):
		_visual.set_formation(new_formation)


func _apply_formation_modifiers():
	var mods := FormationSystemGD.get_modifiers(formation)
	_formation_attack_mod = mods.get("attack", 1.0)
	_formation_defense_mod = mods.get("defense", 1.0)
	_formation_speed_mod = mods.get("speed", 1.0)
	_formation_morale_mod = mods.get("morale", 1.0)
	_formation_range_mod = mods.get("range", 1.0)


func get_formation_radius() -> float:
	return FormationSystemGD.get_formation_radius(formation)


func get_formation_width() -> float:
	return FormationSystemGD.get_formation_width(formation)


func overlaps_with(other: Node2D) -> bool:
	if other == null or not other.has_method("get_formation_radius"):
		return false
	var dist := global_position.distance_to(other.global_position)
	return dist < (get_formation_radius() + other.get_formation_radius()) * 0.7


func _create_visual(region: String, side_color: Color):
	if _visual != null and is_instance_valid(_visual):
		_visual.queue_free()
	_visual = BattleUnitVisualGD.new()
	_visual.setup(unit_type, region, role, side_color, count, max_count, _visual_mode)
	_visual.selected = is_selected
	_visual.commander = has_commander
	_visual.formation = formation
	add_child(_visual)
	_visual.set_tactic(tactic)

func _ready():
	var old_sprite = get_node_or_null("Sprite2D")
	if old_sprite != null:
		old_sprite.visible = false


func update(delta: float):
	if not is_instance_valid(self):
		return
	if count <= 0:
		_queue_die()
		return

	attack_cooldown -= delta

	# Tempo di riformazione: durante il riformamento velocita' ridotta
	if _formation_reform_time > 0:
		_formation_reform_time -= delta

	if is_routing:
		routing_time += delta
		_move_away(delta)
		if routing_time > 3.0:
			_queue_die()
		return

	if morale <= 0:
		is_routing = true
		return

	_regen_morale(delta)
	_resolve_target()
	_move(delta)

	if combat_active:
		_try_attack()

	_update_label()
	if _visual != null:
		_visual.count = count
		_visual.max_count = max_count
		_visual.queue_redraw()


func take_damage(raw_damage: float):
	if count <= 0:
		return
	var actual_damage: float = raw_damage / maxf(0.1, _terrain_defense_mod * _tactic_defense_mod * _formation_defense_mod)
	var hp_per_unit: float = (_data.get("defense", 0.1) + _data.get("armor", 0.0)) * 10.0 + 10.0
	var kills: int = int(actual_damage / hp_per_unit)
	if kills < 1 and actual_damage > 0.0:
		kills = 1
	count = max(0, count - kills)
	morale -= actual_damage * 0.3 * _formation_morale_mod
	if morale <= 0:
		is_routing = true
	if count <= 0:
		count = 0
		_queue_die()


func set_tactic(new_tactic: String):
	tactic = new_tactic
	_set_tactic_modifiers()
	if _visual != null and is_instance_valid(_visual):
		_visual.set_tactic(tactic)


func set_commander(value: bool):
	has_commander = value
	if _visual != null:
		_visual.commander = value
		_visual.queue_redraw()
	queue_redraw()


func set_selected(value: bool):
	is_selected = value
	if _visual != null:
		_visual.selected = value
		_visual.queue_redraw()
	queue_redraw()


func get_attack_damage(target: Node2D) -> float:
	var base: float = _data.get("attack", 0.1)
	var n: float = float(count)
	var morale_factor: float = clampf(morale / max_morale, 0.2, 1.3)
	var tactic_mod: float = _tactic_attack_mod
	var commander_bonus: float = 1.25 if has_commander else 1.0
	var dmg: float = n * base * morale_factor * tactic_mod * commander_bonus * _terrain_attack_mod * _formation_attack_mod
	return maxf(1.0, dmg)


func _queue_die():
	if has_commander:
		commander_died.emit(side)
	died.emit(self)
	queue_free()


func _set_role_stats():
	var sp: float = _data.get("speed", 2.0)
	match role:
		"ranged":
			speed = sp * 28.0
			attack_range = 220.0
			attack_interval = 1.8
		"artillery":
			speed = sp * 20.0
			attack_range = 320.0
			attack_interval = 3.0
		"cavalry":
			speed = sp * 40.0
			attack_range = 45.0
			attack_interval = 1.4
		"elephant":
			speed = sp * 22.0
			attack_range = 50.0
			attack_interval = 2.0
		_:
			speed = sp * 25.0
			attack_range = 40.0
			attack_interval = 1.5


var _tactic_speed_mod: float = 1.0
var _tactic_attack_mod: float = 1.0
var _tactic_defense_mod: float = 1.0


func _set_tactic_modifiers():
	_tactic_speed_mod = 1.0
	_tactic_attack_mod = 1.0
	_tactic_defense_mod = 1.0
	match tactic:
		"charge", "elephant_charge":
			if role in ["cavalry", "elephant"]:
				_tactic_speed_mod = 1.6
				_tactic_attack_mod = 1.35
			elif role == "infantry":
				_tactic_speed_mod = 1.3
				_tactic_attack_mod = 1.2
			else:
				_tactic_speed_mod = 1.1
				_tactic_attack_mod = 0.8
		"shield_wall":
			_tactic_speed_mod = 0.6
			_tactic_attack_mod = 0.8
			_tactic_defense_mod = 1.4
		"skirmish":
			_tactic_speed_mod = 0.9
			if role in ["ranged", "artillery"]:
				_tactic_attack_mod = 1.1
			else:
				_tactic_attack_mod = 0.85


func _resolve_target():
	if is_instance_valid(attack_target):
		target_pos = attack_target.global_position
	elif attack_target != null:
		attack_target = null


func _move(delta: float):
	var dir := Vector2.ZERO
	if not is_instance_valid(attack_target):
		attack_target = null

	if is_routing:
		dir = _flee_direction()
	elif is_instance_valid(attack_target):
		var dist := global_position.distance_to(attack_target.global_position)
		if role in ["ranged", "artillery"]:
			if dist < attack_range * 0.6:
				dir = (global_position - attack_target.global_position).normalized()
			elif dist > attack_range:
				dir = (attack_target.global_position - global_position).normalized()
			else:
				dir = Vector2.ZERO
		elif tactic == "shield_wall":
			if dist > attack_range:
				dir = (attack_target.global_position - global_position).normalized()
			else:
				dir = Vector2.ZERO
		else:
			if dist > attack_range:
				dir = (attack_target.global_position - global_position).normalized()
			else:
				dir = Vector2.ZERO
	elif target_pos != Vector2.ZERO and global_position.distance_to(target_pos) > 5.0:
		dir = (target_pos - global_position).normalized()

	if _visual != null:
		_visual.set_moving(dir != Vector2.ZERO)

	if dir != Vector2.ZERO:
		var move_speed: float = speed * _tactic_speed_mod * _formation_speed_mod
		if is_routing:
			move_speed *= 1.3
		# Durante il riformamento velocita' ridotta
		if _formation_reform_time > 0:
			move_speed *= 0.5
		# Controllo collisioni con altri gruppi
		var new_pos := global_position + dir * move_speed * delta
		if not _check_collision(new_pos):
			global_position = new_pos
		else:
			# Se collisione, prova a scivolare lateralmente
			var perp := Vector2(-dir.y, dir.x).normalized()
			var slide_pos := global_position + perp * move_speed * delta * 0.5
			if not _check_collision(slide_pos):
				global_position = slide_pos
		if _visual != null:
			_visual.set_facing_right(dir.x >= -0.1)


func _try_attack():
	if attack_cooldown > 0.0:
		return
	if not is_instance_valid(attack_target):
		return
	var effective_range: float = attack_range * _formation_range_mod
	var dist := global_position.distance_to(attack_target.global_position)
	if dist > effective_range:
		return
	attack_cooldown = attack_interval
	var dmg := get_attack_damage(attack_target)
	if role in ["ranged", "artillery"]:
		_spawn_projectile(attack_target, dmg)
	else:
		attack_target.take_damage(dmg)


func _spawn_projectile(target: Node2D, damage: float):
	var proj_scene := preload("res://scenes/projectile.tscn")
	var proj: Node2D = proj_scene.instantiate()
	proj.init(target, damage, role == "artillery")
	proj.global_position = global_position
	get_parent().add_child(proj)


func _flee_direction() -> Vector2:
	var nearest: Node2D = _nearest_enemy()
	if nearest == null:
		return Vector2.RIGHT
	return (global_position - nearest.global_position).normalized()


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for child in get_parent().get_children():
		if child == self:
			continue
		if not child.has_method("take_damage"):
			continue
		if child.side == side:
			continue
		if child.count <= 0:
			continue
		var d := global_position.distance_to(child.global_position)
		if d < best_dist:
			best_dist = d
			best = child
	return best


func _regen_morale(delta: float):
	if morale < max_morale:
		var regen: float = 2.0 * delta
		if has_commander:
			regen *= 1.5
		morale = minf(max_morale, morale + regen)


func _update_label():
	count_label.text = "%d" % count


func _unit_role(unit_type_name: String) -> String:
	var key: String = unit_type_name.to_lower()
	if key.contains("elephant"):
		return "elephant"
	if key.contains("caval") or key.contains("cataphract") or key.contains("mamluk") or key.contains("ghilman") or key.contains("ghulam") or key.contains("lancer") or key.contains("drak") or key.contains("druzhina") or key.contains("jinete") or key.contains("magyar") or key.contains("horse") or key.contains("soninke"):
		return "cavalry"
	if key.contains("arcier") or key.contains("archer") or key.contains("crossbow") or key.contains("balestri") or key.contains("toxot") or key.contains("shenbi") or key.contains("atlatl") or key.contains("javelin"):
		return "ranged"
	if key.contains("artiglier") or key.contains("catapult") or key.contains("onager") or key.contains("scorpion"):
		return "artillery"
	return "infantry"


func _move_away(delta: float):
	var nearest: Node2D = _nearest_enemy()
	var dir := Vector2.RIGHT
	if nearest != null:
		dir = (global_position - nearest.global_position).normalized()
	var move_speed: float = speed * 1.3 * _tactic_speed_mod
	global_position += dir * move_speed * delta
	if _visual != null:
		_visual.set_facing_right(dir.x >= -0.1)
		_visual.set_moving(true)


# Controllo collisioni tra formazioni - Dark Corporation / Stev
func _check_collision(new_pos: Vector2) -> bool:
	var parent := get_parent()
	if parent == null:
		return false
	for child in parent.get_children():
		if child == self:
			continue
		if not child.has_method("get_formation_radius"):
			continue
		if not is_instance_valid(child):
			continue
		if child.count <= 0:
			continue
		var dist := new_pos.distance_to(child.global_position)
		var min_dist: float = (get_formation_radius() + child.get_formation_radius()) * 0.6
		if dist < min_dist:
			return true
	return false



