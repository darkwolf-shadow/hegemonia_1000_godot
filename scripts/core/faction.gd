class_name Faction

var name: String
var leader: String
var attitude: String
var color: String
var capital: String
var resources: Dictionary
var units: Dictionary
var ships: Dictionary
var buildings: Array

func _init(data: Dictionary):
	name = data.get("name", "")
	leader = data.get("leader", "")
	attitude = data.get("attitude", "balanced")
	color = data.get("color", "#AAAAAA")
	capital = data.get("capital", "")
	resources = data.get("resources", {}).duplicate()
	units = data.get("units", {}).duplicate()
	ships = data.get("ships", {}).duplicate()
	buildings = data.get("buildings", []).duplicate()
