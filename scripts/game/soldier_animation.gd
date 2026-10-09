extends Node
# Animazione di camminata per soldato scheletrico
# Muove gambe (anche, cosce, ginocchia, caviglie) e braccia (spalle, gomiti, polsi)
# Dark Corporation / Stev

var _skeleton: Skeleton3D
var _time: float = 0.0
var _walking: bool = false
var _move_speed: float = 1.5

var _bone_ids := {}

func setup(skeleton: Skeleton3D):
	_skeleton = skeleton
	for name in ["Bacino", "Addome", "Busto", "Testa",
			"SpallaSx", "BraccioSx", "AvambraccioSx", "ManoSx",
			"SpallaDx", "BraccioDx", "AvambraccioDx", "ManoDx",
			"AncaSx", "CosciaSx", "GambaSx", "PiedeSx",
			"AncaDx", "CosciaDx", "GambaDx", "PiedeDx"]:
		_bone_ids[name] = skeleton.find_bone(name)

func set_walking(walking: bool):
	_walking = walking

func set_speed(speed: float):
	_move_speed = speed

func _process(delta: float):
	if _skeleton == null:
		return
	# Frequenza dei passi proporzionale alla velocita' di movimento
	# Un passo copre circa 0.7m, quindi freq = velocita' / 0.7
	var step_freq: float = _move_speed / 0.7
	_time += delta * step_freq * (1.0 if _walking else 0.0)
	if _walking:
		_animate_walk()
	else:
		_animate_idle()

func _animate_walk():
	var t := _time
	# Gambe: oscillazione fluida e naturale (ampiezze ridotte)
	var leg_swing: float = sin(t) * 0.25
	var thigh_bend: float = sin(t) * 0.20
	# Ginocchio: piegamento graduale quando la gamba si solleva
	var knee_sx: float = max(0.0, -sin(t)) * 0.35
	var knee_dx: float = max(0.0, -sin(t + PI)) * 0.35
	# Caviglia: flessione leggera
	var ankle_sx: float = sin(t) * 0.10
	var ankle_dx: float = sin(t + PI) * 0.10

	# Gamba sinistra
	_set_rot("AncaSx", Vector3(leg_swing, 0, 0))
	_set_rot("CosciaSx", Vector3(thigh_bend, 0, 0))
	_set_rot("GambaSx", Vector3(-knee_sx, 0, 0))
	_set_rot("PiedeSx", Vector3(ankle_sx, 0, 0))
	# Gamba destra (opposta)
	_set_rot("AncaDx", Vector3(-leg_swing, 0, 0))
	_set_rot("CosciaDx", Vector3(-thigh_bend, 0, 0))
	_set_rot("GambaDx", Vector3(-knee_dx, 0, 0))
	_set_rot("PiedeDx", Vector3(ankle_dx, 0, 0))

	# Braccia: oscillazione opposta alle gambe (ampiezza ridotta)
	var arm_swing: float = sin(t + PI) * 0.20
	var elbow_bend: float = 0.15 + max(0.0, sin(t + PI)) * 0.20
	# Braccio sinistro
	_set_rot("SpallaSx", Vector3(-arm_swing, 0, 0))
	_set_rot("BraccioSx", Vector3(0, 0, 0))
	_set_rot("AvambraccioSx", Vector3(elbow_bend, 0, 0))
	_set_rot("ManoSx", Vector3(0.05, 0, 0))
	# Braccio destro
	_set_rot("SpallaDx", Vector3(arm_swing, 0, 0))
	_set_rot("BraccioDx", Vector3(0, 0, 0))
	_set_rot("AvambraccioDx", Vector3(elbow_bend, 0, 0))
	_set_rot("ManoDx", Vector3(0.05, 0, 0))

	# Busto: oscillazione molto leggera
	_set_rot("Busto", Vector3(0.02 * sin(t * 2.0), 0, 0))
	_set_rot("Addome", Vector3.ZERO)
	_set_rot("Testa", Vector3(-0.02, 0, 0))
	# Bacino: bobbing verticale leggero
	var rest := _skeleton.get_bone_rest(_bone_ids["Bacino"])
	var bob: float = 0.02 * sin(t * 2.0)
	_skeleton.set_bone_pose_position(_bone_ids["Bacino"], rest.origin + Vector3(0, bob, 0))

func _animate_idle():
	var t := _time * 0.5
	var breathe: float = 0.02 * sin(t)
	for name in _bone_ids.keys():
		_set_rot(name, Vector3.ZERO)
	_set_rot("Busto", Vector3(breathe, 0, 0))
	var rest := _skeleton.get_bone_rest(_bone_ids["Bacino"])
	_skeleton.set_bone_pose_position(_bone_ids["Bacino"], rest.origin + Vector3(0, breathe * 0.5, 0))

func _set_rot(bone_name: String, euler: Vector3):
	if not _bone_ids.has(bone_name):
		return
	var idx: int = _bone_ids[bone_name]
	var rest := _skeleton.get_bone_rest(idx)
	var pose := Transform3D(
		Basis().rotated(Vector3.RIGHT, euler.x).rotated(Vector3.UP, euler.y).rotated(Vector3.BACK, euler.z),
		rest.origin
	)
	_skeleton.set_bone_pose(idx, pose)
