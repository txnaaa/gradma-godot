extends Node2D

# Nan mixes drinks out of the shopping she just did. Each lady calls out how many
# chillies, lemons and shots she wants. Click the crates to add them, get it exactly
# right and the drink goes out.

var hud: Hud

const ORDERS: int = 5
const ROUND_TIME: float = 80.0
const GLASS_CENTRE := Vector2(690.0, 300.0)
const GLASS_SIZE: float = 300.0
const STATION_Y: float = 500.0
const STATION_W: float = 196.0
const STATION_H: float = 168.0

var ingredients: Array = [
	{"key": "ice", "tex": "ice", "label": "ICE", "pastel": Color(0.76, 0.90, 1.0), "x": 236.0},
	{"key": "lemon", "tex": "lemon", "label": "LEMON", "pastel": Color(1.0, 0.95, 0.72), "x": 504.0},
	{"key": "salt", "tex": "salt", "label": "SALT", "pastel": Color(0.96, 0.94, 0.88), "x": 772.0},
	{"key": "booze", "tex": "bottle_icon", "label": "TEQUILA", "pastel": Color(0.80, 0.92, 0.76), "x": 1040.0},
]

var need: Dictionary = {}
var have: Dictionary = {}
var orders_done: int = 0
var mistakes: int = 0
var time_left: float = ROUND_TIME
var finished: bool = false
var anger_t: float = 0.0
var anger_pos := Vector2(640.0, 240.0)

func _ready() -> void:
	Game.timer_running = false
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.title_label.text = "NAN'S COCKTAILS"
	_new_order()

func _new_order() -> void:
	need = {"ice": randi_range(0, 2), "lemon": randi_range(0, 2),
		"salt": randi_range(0, 1), "booze": randi_range(1, 3)}
	# later orders get fiddlier, and never let one be almost empty
	if orders_done >= 2 and int(need["ice"]) + int(need["lemon"]) < 2:
		need["lemon"] = 2
	have = {"ice": 0, "lemon": 0, "salt": 0, "booze": 0}

func _station_rect(i: int) -> Rect2:
	return Rect2(float(ingredients[i]["x"]) - STATION_W * 0.5, STATION_Y, STATION_W, STATION_H)

func _order_complete() -> bool:
	for k in need.keys():
		if int(have[k]) != int(need[k]):
			return false
	return true

func _input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var m: Vector2 = get_global_mouse_position()
		for i in range(ingredients.size()):
			if _station_rect(i).has_point(m):
				_add(i)
				return

func _add(i: int) -> void:
	var key: String = ingredients[i]["key"]
	if int(have[key]) + 1 > int(need[key]):
		mistakes += 1
		Sfx.play("error")
		anger_t = 1.0
		time_left = max(0.0, time_left - 5.0)
		have = {"ice": 0, "lemon": 0, "salt": 0, "booze": 0}
		hud.flash("She did not ask for that, start again", 1.0)
		return
	have[key] = int(have[key]) + 1
	Sfx.play("catch", -10.0, randf_range(0.95, 1.15))
	if _order_complete():
		_serve()

func _serve() -> void:
	Sfx.play("good", -4.0)
	orders_done += 1
	if orders_done >= ORDERS:
		_win()
	else:
		hud.flash("Served!", 0.7)
		_new_order()

func _process(delta: float) -> void:
	if finished:
		return
	anger_t = max(0.0, anger_t - delta * 1.1)
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_finish()
		return
	hud.info_label.text = "ORDER %d OF %d      TIME %d      MISTAKES %d" % [orders_done + 1, ORDERS, int(ceil(time_left)), mistakes]
	queue_redraw()

func _win() -> void:
	finished = true
	Game.scores["cocktails"] = max(0, 600 - mistakes * 40 + int(time_left) * 3)
	hud.flash("Everyone has a drink!", 1.3)
	await get_tree().create_timer(1.3).timeout
	Game.goto("res://scenes/Bingo.tscn")

func _finish() -> void:
	finished = true
	Game.scores["cocktails"] = orders_done * 60
	hud.flash("Time, ladies", 1.2)
	await get_tree().create_timer(1.2).timeout
	Game.goto("res://scenes/Bingo.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_bar")

	_draw_ticket()
	_draw_glass()
	_draw_stations()
	Art.anger(self, anger_pos, anger_t)

func _draw_ticket() -> void:
	var r := Rect2(56.0, 118.0, 320.0, 330.0)
	Art.panel(self, r, Color(0.96, 0.93, 0.84, 0.97))
	Art.text(self, Vector2(r.position.x, r.position.y + 44.0), "SHE WANTS", 24, Color(0.22, 0.18, 0.22), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	for i in range(ingredients.size()):
		var ing: Dictionary = ingredients[i]
		var y: float = r.position.y + 92.0 + float(i) * 60.0
		Art.sprite(self, ing["tex"], Vector2(r.position.x + 60.0, y), 54.0)
		var done: bool = int(have[ing["key"]]) == int(need[ing["key"]])
		Art.text(self, Vector2(r.position.x + 104.0, y + 10.0), "%d / %d" % [int(have[ing["key"]]), int(need[ing["key"]])], 26,
			Color(0.2, 0.55, 0.25) if done else Color(0.35, 0.28, 0.3))
		Art.text(self, Vector2(r.position.x + 190.0, y + 8.0), str(ing["label"]), 18, Color(0.4, 0.34, 0.36))

func _draw_glass() -> void:
	Art.canvas_sprite(self, "glass", GLASS_CENTRE, GLASS_SIZE)
	var shots: int = int(have["booze"])
	if shots >= 1:
		Art.canvas_sprite(self, "fill%d" % clampi(shots * 2 - 1, 0, 5), GLASS_CENTRE, GLASS_SIZE)

	# whatever has gone in floats above the rim so you can count it
	var bits: Array = []
	for i in range(int(have["ice"])):
		bits.append("ice")
	for i in range(int(have["lemon"])):
		bits.append("lemon")
	for i in range(int(have["salt"])):
		bits.append("salt")
	var start_x: float = GLASS_CENTRE.x - 30.0 - float(bits.size() - 1) * 24.0
	for i in range(bits.size()):
		Art.sprite(self, bits[i], Vector2(start_x + float(i) * 48.0, GLASS_CENTRE.y - 132.0), 44.0)

func _draw_stations() -> void:
	for i in range(ingredients.size()):
		var ing: Dictionary = ingredients[i]
		var r: Rect2 = _station_rect(i)
		var hovered: bool = r.has_point(get_global_mouse_position())
		var pastel: Color = ing["pastel"]
		Art.nine(self, "panel_grey", r, 22.0, pastel if hovered else pastel.darkened(0.12))
		Art.sprite(self, ing["tex"], r.position + Vector2(r.size.x * 0.5, 66.0), 74.0)
		Art.text(self, Vector2(r.position.x, r.position.y + 140.0), str(ing["label"]), 20, Color(0.24, 0.19, 0.26), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
