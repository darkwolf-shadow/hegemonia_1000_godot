class_name Building

var type: String
var display_name: String
var cost: Dictionary
var effects: Dictionary

func _init(type_name: String, data: Dictionary):
	type = type_name
	display_name = data.get("name", type_name)
	cost = data.get("cost", {}).duplicate()
	effects = data.get("effects", {}).duplicate()
