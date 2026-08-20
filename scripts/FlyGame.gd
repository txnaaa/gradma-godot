extends Node2D

var hud: Hud

const FLY_COUNT: int = 9
const HIT_RADIUS: float = 62.0
const SWATTER_H: float = 300.0
# where the racket head sits inside swatter.png, as a fraction of the image
const HEAD_X: float = 0.62
const HEAD_Y: float = 0.28

var flies: Array = []
var killed: int = 0
var swings: int = 0
var swat_anim: float = 0.0
var finished: bool = false
var anger_t: float = 0.0
var anger_pos := Vector2.ZERO

func _ready() -> void:
	Game.timer_running = true
	hud = Hud.new()
	add_child(hud)
	hud.title_label.text = "Fruit stand"
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for i in range(FLY_COUNT):
		flies.append({
			"pos": Vector2(randf_range(220.0, 1060.0), randf_range(220.0, 560.0)),
			"vel": Vector2(randf_range(-90.0, 90.0), randf_range(-60.0, 60.0)),
			"t": randf_range(0.0, 1.0),
			"wing": randf_range(0.0, 10.0),
		})

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	swat_anim = max(0.0, swat_anim - delta * 5.0)
	anger_t = max(0.0, anger_t - delta * 1.4)
	for f in flies:
		f["t"] -= delta
		f["wing"] += delta * 18.0
		if f["t"] <= 0.0:
			f["t"] = randf_range(0.3, 1.0)
			f["vel"] = Vector2(randf_range(-160.0, 160.0), randf_range(-120.0, 120.0))
		f["pos"] += f["vel"] * delta
		f["pos"].x = clamp(f["pos"].x, 150.0, 1130.0)
		f["pos"].y = clamp(f["pos"].y, 160.0, 620.0)
	hud.info_label.text = "Flies swatted %d of %d      swings %d" % [killed, FLY_COUNT, swings]
	queue_redraw()

func _input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		swat_anim = 1.0
		swings += 1
		var m: Vector2 = get_global_mouse_position()
		var hit: bool = false
		for i in range(flies.size() - 1, -1, -1):
			if flies[i]["pos"].distance_to(m) < HIT_RADIUS:
				flies.remove_at(i)
				killed += 1
				hit = true
				Sfx.play("swat", -6.0, randf_range(0.95, 1.2))
				break
		if not hit:
			Game.lose_time(2.0)
			Sfx.play("error", -12.0)
			anger_t = 1.0
			anger_pos = m + Vector2(60.0, -80.0)
		if killed >= FLY_COUNT and not finished:
			_win()

func _win() -> void:
	finished = true
	Sfx.play("good", -3.0)
	Game.collect("lemon", max(0, 500 - (swings - FLY_COUNT) * 20))
	hud.flash("Lemons are clean!", 1.2)
	await get_tree().create_timer(1.2).timeout
	Game.goto("res://scenes/Map.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_lemons")

	for f in flies:
		var frame: int = int(f["wing"]) % 3
		var fly_name: String = ["fly1", "fly2", "fly3"][frame]
		Art.sprite(self, fly_name, f["pos"], 78.0, sin(f["wing"] * 0.4) * 0.25)

	Art.anger(self, anger_pos, anger_t)
	_draw_swatter(get_global_mouse_position())

func _draw_swatter(m: Vector2) -> void:
	var t: Texture2D = Art.tex("swatter")
	var h: float = SWATTER_H * (1.0 - swat_anim * 0.14)
	if t == null:
		draw_arc(m, HIT_RADIUS, 0.0, TAU, 32, Color(0.9, 0.4, 0.5), 5.0)
		return
	var s: float = h / float(t.get_height())
	var w: float = float(t.get_width()) * s
	# line the racket head up with the mouse
	var topleft: Vector2 = m - Vector2(w * HEAD_X, h * HEAD_Y)
	draw_texture_rect(t, Rect2(topleft, Vector2(w, h)), false)
