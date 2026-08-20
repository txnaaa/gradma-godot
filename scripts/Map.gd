extends Node2D

# The market is wider than the window, so Nan walks with the arrow keys and a camera
# follows her. Her position is kept in Game.map_x, so coming back from a stall puts
# her where she left off instead of back at the gate.

var hud: Hud
var cam: Camera2D
var grandma_x: float = 150.0
var target_x: float = -1.0
var facing_right: bool = true
var pending_scene: String = ""
var walk_speed: float = 320.0
var bob: float = 0.0
var walking: bool = false
var list_open: bool = false

const WORLD_W: float = 2800.0
const GROUND_Y: float = 655.0
const TENT_H: float = 300.0
const GRANDMA_H: float = 215.0
const ART_FACES_RIGHT: bool = true
const REACH: float = 190.0

var stalls: Array = [
	{"key": "chilli", "label": "SPICE STAND", "x": 430.0, "tex": "tent_chilli",
		"pastel": Color(1.0, 0.82, 0.72), "scene": "res://scenes/Chilli.tscn"},
	{"key": "mixers", "label": "DRINKS STAND", "x": 1150.0, "tex": "tent_drinks",
		"pastel": Color(0.74, 0.86, 1.0), "scene": "res://scenes/Drinks.tscn"},
	{"key": "lemon", "label": "FRUIT STAND", "x": 1870.0, "tex": "tent_fruit",
		"pastel": Color(1.0, 0.95, 0.72), "scene": "res://scenes/Flies.tscn"},
]

const HALL_X: float = 2500.0
const HALL_H: float = 420.0
const HALL_W: float = 724.0
const HALL_PASTEL := Color(0.83, 0.78, 1.0)
const PLAQUE_INK := Color(0.24, 0.19, 0.26)

func _ready() -> void:
	Game.timer_running = true
	Sfx.play_music("music_rock")

	if Game.map_x >= 0.0:
		grandma_x = Game.map_x

	cam = Camera2D.new()
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(WORLD_W)
	cam.limit_bottom = int(Game.H)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 5.0
	cam.position = Vector2(clamp(grandma_x, Game.W * 0.5, WORLD_W - Game.W * 0.5), Game.H * 0.5)
	add_child(cam)
	cam.make_current()

	hud = Hud.new()
	add_child(hud)
	hud.title_label.text = "The market"

func _process(delta: float) -> void:
	var axis: float = Input.get_axis("ui_left", "ui_right")
	walking = false

	if absf(axis) > 0.02:
		target_x = -1.0
		pending_scene = ""
		grandma_x = clamp(grandma_x + axis * walk_speed * delta, 40.0, WORLD_W - 40.0)
		facing_right = axis > 0.0
		walking = true
	elif target_x >= 0.0:
		var diff: float = target_x - grandma_x
		if absf(diff) > 5.0:
			facing_right = diff > 0.0
			grandma_x += signf(diff) * walk_speed * delta
			walking = true
		else:
			grandma_x = target_x
			target_x = -1.0
			if pending_scene != "":
				_enter(pending_scene)
				return

	if walking:
		bob += delta * 9.0

	cam.position.x = clamp(grandma_x, Game.W * 0.5, WORLD_W - Game.W * 0.5)
	Game.map_x = grandma_x

	var near: Dictionary = _nearest()
	if near.is_empty():
		hud.info_label.text = "Arrow keys to walk"
	else:
		hud.info_label.text = "Space to go into the " + str(near["name"])
	queue_redraw()

func _enter(path: String) -> void:
	Game.map_x = grandma_x
	Sfx.play("click")
	Game.goto(path)

# whatever Nan is standing in front of, if anything
func _nearest() -> Dictionary:
	for s in stalls:
		if not Game.groceries[s["key"]] and absf(float(s["x"]) - grandma_x) < REACH:
			return {"name": "spice stand" if s["key"] == "chilli" else ("drinks stand" if s["key"] == "mixers" else "fruit stand"), "scene": s["scene"]}
	if Game.all_collected() and absf(HALL_X - grandma_x) < REACH + 90.0:
		return {"name": "bingo hall", "scene": "res://scenes/BingoHall.tscn"}
	return {}

func _ui_origin() -> Vector2:
	if cam == null:
		return Vector2.ZERO
	return cam.get_screen_center_position() - Vector2(Game.W, Game.H) * 0.5

func _list_button_rect() -> Rect2:
	return Rect2(_ui_origin() + Vector2(24.0, 112.0), Vector2(230.0, 46.0))

func _list_panel_rect() -> Rect2:
	return Rect2(_ui_origin() + Vector2(24.0, 164.0), Vector2(300.0, 32.0 + float(Game.groceries.size()) * 48.0))

func _hall_rect() -> Rect2:
	return Rect2(HALL_X - HALL_W * 0.5, GROUND_Y - HALL_H, HALL_W, HALL_H)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER]:
			var near: Dictionary = _nearest()
			if not near.is_empty():
				_enter(str(near["scene"]))
		elif event.keycode == KEY_TAB:
			list_open = not list_open
			Sfx.play("click", -12.0)
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var m: Vector2 = get_global_mouse_position()
		if _list_button_rect().has_point(m):
			list_open = not list_open
			Sfx.play("click", -12.0)
			return
		if list_open and _list_panel_rect().has_point(m):
			return
		# clicking a stall you can see still walks her over to it
		for s in stalls:
			if Game.groceries[s["key"]]:
				continue
			if Rect2(s["x"] - 140.0, GROUND_Y - TENT_H, 280.0, TENT_H).has_point(m):
				target_x = s["x"]
				pending_scene = s["scene"]
				return
		if Game.all_collected() and _hall_rect().has_point(m):
			target_x = HALL_X
			pending_scene = "res://scenes/BingoHall.tscn"

func _draw() -> void:
	var tiles: int = int(ceil(WORLD_W / Game.W)) + 1
	for i in range(tiles):
		Art.draw_bg_at(self, "bg_market", Rect2(float(i) * Game.W, 0.0, Game.W, Game.H), i % 2 == 1)

	for s in stalls:
		var done: bool = Game.groceries[s["key"]]
		var tint: Color = Color(0.62, 0.62, 0.68) if done else Color(1, 1, 1)
		Art.sprite_bottom(self, s["tex"], Vector2(s["x"], GROUND_Y), TENT_H, false, tint)
		_plaque(Vector2(s["x"], GROUND_Y + 14.0), str(s["label"]) if not done else str(s["label"]) + " - DONE", s["pastel"])
		if done:
			Art.sprite(self, "cookie", Vector2(s["x"], GROUND_Y - TENT_H - 40.0), 70)

	if Game.all_collected():
		Art.sprite_bottom(self, "hall", Vector2(HALL_X, GROUND_Y), HALL_H)

	var lift: float = absf(sin(bob)) * 8.0 if walking else 0.0
	var mirror: bool = not facing_right if ART_FACES_RIGHT else facing_right
	Art.sprite_bottom(self, "grandma_walk", Vector2(grandma_x, GROUND_Y - lift), GRANDMA_H, mirror)

	_draw_prompt()
	_draw_arrows()
	_draw_checklist()

func _plaque(centre: Vector2, label: String, pastel: Color) -> void:
	var w: float = 260.0
	Art.nine(self, "panel_grey", Rect2(centre.x - w * 0.5, centre.y, w, 40.0), 22.0, pastel)
	Art.text(self, Vector2(centre.x - w * 0.5, centre.y + 27.0), label, 18, PLAQUE_INK, HORIZONTAL_ALIGNMENT_CENTER, w)

func _draw_prompt() -> void:
	if _nearest().is_empty():
		return
	var r := Rect2(grandma_x - 110.0, GROUND_Y - GRANDMA_H - 66.0, 220.0, 48.0)
	Art.panel(self, r)
	Art.text(self, Vector2(r.position.x, r.position.y + 32.0), "PRESS SPACE", 20, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)

# little nudges at the screen edges pointing at what is still to do
func _draw_arrows() -> void:
	var o: Vector2 = _ui_origin()
	var left_todo: bool = false
	var right_todo: bool = false
	var spots: Array = []
	for s in stalls:
		if not Game.groceries[s["key"]]:
			spots.append(float(s["x"]))
	if Game.all_collected():
		spots.append(HALL_X)
	for x in spots:
		if x < o.x + 60.0:
			left_todo = true
		elif x > o.x + Game.W - 60.0:
			right_todo = true
	if left_todo:
		Art.panel(self, Rect2(o + Vector2(10.0, 330.0), Vector2(56.0, 60.0)))
		Art.text(self, Vector2(o.x + 10.0, o.y + 372.0), "<", 34, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, 56.0, true)
	if right_todo:
		Art.panel(self, Rect2(o + Vector2(Game.W - 66.0, 330.0), Vector2(56.0, 60.0)))
		Art.text(self, Vector2(o.x + Game.W - 66.0, o.y + 372.0), ">", 34, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, 56.0, true)

func _draw_checklist() -> void:
	var b: Rect2 = _list_button_rect()
	var hovered: bool = b.has_point(get_global_mouse_position())
	Art.panel(self, b, Art.PANEL_WARM.lightened(0.12) if hovered else Art.PANEL_WARM)
	Art.text(self, Vector2(b.position.x, b.position.y + 30.0),
		"GROCERY LIST  " + ("v" if list_open else ">"), 20, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, b.size.x)
	if not list_open:
		return

	var p: Rect2 = _list_panel_rect()
	Art.panel(self, p, Color(0.97, 0.94, 0.86, 0.97))
	var i: int = 0
	for k in Game.groceries.keys():
		var y: float = p.position.y + 40.0 + float(i) * 48.0
		var got: bool = Game.groceries[k]
		Art.sprite(self, "box_tick" if got else "box_empty", Vector2(p.position.x + 40.0, y), 34.0)
		Art.text(self, Vector2(p.position.x + 70.0, y + 9.0), str(Game.grocery_names[k]).to_upper(), 19,
			Color(0.35, 0.55, 0.32) if got else PLAQUE_INK)
		i += 1
