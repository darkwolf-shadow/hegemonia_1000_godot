class_name Unit

var type: String
var display_name: String
var strength: float
var cost: int
var population: int
var maintenance: int
var food: int

func _init(type_name: String, data: Dictionary):
	type = type_name
	display_name = data.get("name", type_name)
	strength = data.get("strength", 1.0)
	cost = data.get("cost", 0)
	population = data.get("pop", 0)
	maintenance = data.get("maintenance", 0)
	food = data.get("food", 0)
