extends Node

# Autoloaded singleton. Holds the shopping timer, the grocery list and the score.

var W: float = 1280.0
var H: float = 720.0
var SHOP_TIME: float = 150.0

var shop_time_left: float = 150.0
var timer_running: bool = false

var groceries: Dictionary = {
	"chilli": false,
	"lemon": false,
	"mixers": false,
}

var grocery_names: Dictionary = {
	"chilli": "Salt",
	"lemon": "Lemons",
	"mixers": "Drinks and ice",
}

var scores: Dictionary = {}
var bingo_won: bool = false
var reached_hall: bool = false
var map_x: float = -1.0   # where Nan was left standing on the map, -1 means the start

func _ready() -> void:
	randomize()

func reset_run() -> void:
	shop_time_left = SHOP_TIME
	timer_running = false
	bingo_won = false
	reached_hall = false
	map_x = -1.0
	for k in groceries.keys():
		groceries[k] = false
	scores.clear()

func _process(delta: float) -> void:
	if timer_running:
		shop_time_left -= delta
		if shop_time_left <= 0.0:
			shop_time_left = 0.0
			timer_running = false
			goto("res://scenes/ShopsClosed.tscn")

func lose_time(seconds: float) -> void:
	shop_time_left = max(0.0, shop_time_left - seconds)

func collect(item: String, score: int) -> void:
	groceries[item] = true
	scores[item] = score

func all_collected() -> bool:
	for k in groceries.keys():
		if not groceries[k]:
			return false
	return true

func list_text() -> String:
	var parts: PackedStringArray = []
	for k in groceries.keys():
		var tick: String = "x" if groceries[k] else " "
		parts.append("[%s] %s" % [tick, grocery_names[k]])
	return "Grocery list:   " + "    ".join(parts)

func total_score() -> int:
	var t: int = 0
	for k in scores.keys():
		t += int(scores[k])
	return t

func goto(path: String) -> void:
	get_tree().change_scene_to_file(path)
