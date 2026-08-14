extends Node

const SAVE_DIR := "user://saves"


func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func get_slots() -> Array:
	var list := []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while not file.is_empty():
			if file.ends_with(".json"):
				list.append(file.get_basename())
			file = dir.get_next()
	return list


func save_game(slot: String):
	var path = SAVE_DIR + "/" + slot + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(GameState.state, "  "))


func load_game(slot: String) -> bool:
	var path = SAVE_DIR + "/" + slot + ".json"
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		return false
	GameState.state = json.data
	return true
