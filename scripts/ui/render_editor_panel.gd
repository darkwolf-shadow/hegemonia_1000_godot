extends Control
# Pannello di modifica per la scena di rendering
# Permette di cambiare texture, colore, scala e rotazione degli oggetti
# Dark Corporation / Stev

signal apply_texture(texture_path: String)
signal apply_color(color: Color)
signal apply_scale(scale: Vector3)
signal apply_rotation(rotation_y: float)
signal close_panel

@onready var _panel: Panel = $Panel
@onready var _title: Label = $Panel/VBox/Title
@onready var _type_label: Label = $Panel/VBox/TypeLabel
@onready var _texture_opt: OptionButton = $Panel/VBox/TextureOption
@onready var _color_picker: ColorPickerButton = $Panel/VBox/ColorPicker
@onready var _scale_slider: HSlider = $Panel/VBox/ScaleSlider
@onready var _rot_slider: HSlider = $Panel/VBox/RotationSlider
@onready var _scale_label: Label = $Panel/VBox/ScaleLabel
@onready var _rot_label: Label = $Panel/VBox/RotationLabel
@onready var _apply_btn: Button = $Panel/VBox/ApplyBtn
@onready var _reset_btn: Button = $Panel/VBox/ResetBtn
@onready var _close_btn: Button = $Panel/VBox/CloseBtn

var _building_icons: Array = []
var _current_scale: float = 1.0
var _current_rot: float = 0.0

func _ready():
	_panel.visible = false
	_apply_btn.pressed.connect(_on_apply)
	_reset_btn.pressed.connect(_on_reset)
	_close_btn.pressed.connect(_on_close)
	_scale_slider.value_changed.connect(_on_scale_changed)
	_rot_slider.value_changed.connect(_on_rot_changed)

func setup(building_icons: Array):
	_building_icons = building_icons

func open_for(node: Node3D):
	_panel.visible = true
	_type_label.text = "Oggetto: %s" % node.name
	_texture_opt.clear()
	_color_picker.visible = false
	_texture_opt.visible = false
	_scale_slider.value = 1.0
	_rot_slider.value = 0.0
	_current_scale = 1.0
	_current_rot = 0.0
	_update_labels()
	
	if node is Sprite3D:
		_title.text = "Modifica edificio"
		_texture_opt.visible = true
		for i in range(_building_icons.size()):
			_texture_opt.add_item(_building_icons[i].get_file().get_basename())
	elif node.name.begins_with("Unit_"):
		_title.text = "Modifica unita'"
		_color_picker.visible = true

func _on_scale_changed(value: float):
	_current_scale = value
	_update_labels()

func _on_rot_changed(value: float):
	_current_rot = value
	_update_labels()

func _update_labels():
	_scale_label.text = "Scala: %.2f" % _current_scale
	_rot_label.text = "Rotazione Y: %d" % int(_current_rot)

func _on_apply():
	if _texture_opt.visible and _texture_opt.selected >= 0:
		apply_texture.emit(_building_icons[_texture_opt.selected])
	if _color_picker.visible:
		apply_color.emit(_color_picker.color)
	apply_scale.emit(Vector3.ONE * _current_scale)
	apply_rotation.emit(deg_to_rad(_current_rot))

func _on_reset():
	_scale_slider.value = 1.0
	_rot_slider.value = 0.0
	_current_scale = 1.0
	_current_rot = 0.0
	_update_labels()

func _on_close():
	_panel.visible = false
	close_panel.emit()
