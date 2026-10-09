extends Node
# Animazione camminata cavallo: muove le 4 zampe alternativamente
# Zampe anteriori: ginocchio piega in avanti (come umano)
# Zampe posteriori: ginocchio piega all'indietro (opposto)
# Dark Corporation / Stev

var _skeleton: Skeleton3D
var _time: float = 0.0
var _walking: bool = false
var _move_speed: float = 1.5

func setup(skeleton: Skeleton3D):
	_skeleton = skeleton

func set_walking(walking: bool):
	_walking = walking

func set_speed(speed: float):
	_move_speed = speed

func _process(delta: float):
	if _skeleton == null or not is_instance_valid(_skeleton):
		return
	if not _walking:
		return
	# Frequenza delle falcate proporzionale alla velocita'
	# Una falcata di cavallo copre circa 1.5m
	var stride_freq: float = _move_speed / 1.5
	_time += delta * stride_freq
	# Animazione camminata: le zampe si muovono alternativamente
	# Zampe anteriori: coscia ruota in avanti/indietro, gamba piega in avanti
	# Zampe posteriori: coscia ruota in avanti/indietro, gamba piega all'indietro
	_animate_leg("AntSx", _time, true)
	_animate_leg("AntDx", _time + PI, true)
	_animate_leg("PostSx", _time + PI, false)
	_animate_leg("PostDx", _time, false)
	# Coda: oscillazione laterale durante il movimento
	_animate_tail()

func _animate_leg(suffix: String, phase: float, is_front: bool):
	if _skeleton == null:
		return
	# Coscia: oscilla in avanti/indietro (rotazione asse X)
	var thigh_idx := _skeleton.find_bone("Coscia" + suffix)
	if thigh_idx >= 0:
		var rest := _skeleton.get_bone_rest(thigh_idx)
		var swing := sin(phase) * 0.3  # 17 gradi
		_skeleton.set_bone_pose(thigh_idx, Transform3D(
			Basis().rotated(Vector3.RIGHT, swing), rest.origin))
	# Gamba: piega durante il sollevamento
	# Anteriore: piega in avanti (rotazione positiva asse X)
	# Posteriore: piega all'indietro (rotazione negativa asse X)
	var leg_idx := _skeleton.find_bone("Gamba" + suffix)
	if leg_idx >= 0:
		var rest := _skeleton.get_bone_rest(leg_idx)
		# Piega quando la zampa e' sollevata (fase di oscillazione)
		var bend: float = max(0.0, sin(phase + PI/2)) * 0.5
		if is_front:
			# Anteriore: ginocchio piega in avanti (rotazione positiva)
			_skeleton.set_bone_pose(leg_idx, Transform3D(
				Basis().rotated(Vector3.RIGHT, bend), rest.origin))
		else:
			# Posteriore: ginocchio piega all'indietro (rotazione negativa)
			_skeleton.set_bone_pose(leg_idx, Transform3D(
				Basis().rotated(Vector3.RIGHT, -bend - 0.4), rest.origin))

# Anima la coda: oscillazione laterale (asse Y) durante il movimento
func _animate_tail():
	if _skeleton == null:
		return
	var tail_idx := _skeleton.find_bone("Coda")
	if tail_idx >= 0:
		var rest := _skeleton.get_bone_rest(tail_idx)
		var sway := sin(_time * 1.5) * 0.3
		_skeleton.set_bone_pose(tail_idx, Transform3D(
			Basis().rotated(Vector3.UP, sway), rest.origin))
