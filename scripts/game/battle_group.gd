extends Node2D

signal selected(group)
signal died(group)
signal commander_died(side)

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

@onready var sprite: Sprite2D = $Sprite2D
@onready var count_label: Label = $CountLabel

func init(type_name: String, side_name: String, unit_count: int, region: String, player_side: bool, terrain_attack: float = 1.0, terrain_defense: float = 1.0):
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

	sprite.texture = IconManager.get_battle_sprite(type_name, region)
	if sprite.texture == null:
		sprite.texture = IconManager.get_unit_icon(type_name, region)
	if sprite.texture == null:
		sprite.texture = _default_texture()

	_update_label()
	set_process(false)

func update(delta: float):
	if not is_instance_valid(self):
		return
	if count <= 0:
		_queue_die()
		return

	attack_cooldown -= delta

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

func take_damage(raw_damage: float):
	if count <= 0:
		return
	var actual_damage: float = raw_damage / maxf(0.1, _terrain_defense_mod * _tactic_defense_mod)
	var hp_per_unit: float = (_data.get("defense", 0.1) + _data.get("armor", 0.0)) * 10.0 + 10.0
	var kills: int = int(actual_damage / hp_per_unit)
	if kills < 1 and actual_damage > 0.0:
		kills = 1
	count = max(0, count - kills)
	morale -= actual_damage * 0.3
	if morale <= 0:
		is_routing = true
	if count <= 0:
		count = 0
		_queue_die()

func set_tactic(new_tactic: String):
	tactic = new_tactic
	_set_tactic_modifiers()

func set_commander(value: bool):
	has_commander = value
	queue_redraw()

func set_selected(value: bool):
	is_selected = value
	queue_redraw()

func get_attack_damage(target: Node2D) -> float:
	var base: float = _data.get("attack", 0.1)
	var n: float = float(count)
	var morale_factor: float = clampf(morale / max_morale, 0.2, 1.3)
	var tactic_mod: float = _tactic_attack_mod
	var commander_bonus: float = 1.25 if has_commander else 1.0
	var dmg: float = n * base * morale_factor * tactic_mod * commander_bonus * _terrain_attack_mod
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

var _tactic_speed_mod: float = 1.0
var _tactic_attack_mod: float = 1.0
var _tactic_defense_mod: float = 1.0

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

	if dir != Vector2.ZERO:
		var move_speed: float = speed * _tactic_speed_mod
		if is_routing:
			move_speed *= 1.3
		global_position += dir * move_speed * delta
		if dir.x < -0.1:
			sprite.flip_h = true
		elif dir.x > 0.1:
			sprite.flip_h = false

func _try_attack():
	if attack_cooldown > 0.0:
		return
	if not is_instance_valid(attack_target):
		return
	var dist := global_position.distance_to(attack_target.global_position)
	if dist > attack_range:
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

func _default_texture() -> Texture2D:
	var tex := GradientTexture2D.new()
	tex.width = 32
	tex.height = 32
	var grad := Gradient.new()
	grad.set_color(0, Color.GRAY)
	grad.set_color(1, Color.DARK_GRAY)
	tex.gradient = grad
	return tex

func _move_away(delta: float):
	var nearest: Node2D = _nearest_enemy()
	var dir := Vector2.RIGHT
	if nearest != null:
		dir = (global_position - nearest.global_position).normalized()
	var move_speed: float = speed * 1.3 * _tactic_speed_mod
	global_position += dir * move_speed * delta
	if dir.x < -0.1:
		sprite.flip_h = true
	elif dir.x > 0.1:
		sprite.flip_h = false

func _draw():
	if is_selected:
		draw_rect(Rect2(Vector2(-24, -24), Vector2(48, 48)), Color.YELLOW, false, 2.0)
	if has_commander:
		draw_circle(Vector2(0, -28), 6.0, Color.GOLD)
	var hp_ratio: float = float(count) / float(max_count) if max_count > 0 else 1.0
	draw_rect(Rect2(Vector2(-24, 28), Vector2(48 * hp_ratio, 6)), Color.DARK_RED)
	draw_rect(Rect2(Vector2(-24, 28), Vector2(48, 6)), Color.WHITE, false, 1.0)
