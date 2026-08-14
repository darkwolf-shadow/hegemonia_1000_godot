class_name Province

var name: String
var owner: String
var region: String
var terrain: String
var population: int
var neighbors: Array
var resources: Dictionary

func _init(data: Dictionary):
	name = data.get("name", "")
	owner = data.get("owner", "Terra di Nessuno")
	region = data.get("region", "")
	terrain = data.get("terrain", "plains")
	population = data.get("population", 0)
	neighbors = data.get("neighbors", []).duplicate()
	resources = data.get("resources", {}).duplicate()
