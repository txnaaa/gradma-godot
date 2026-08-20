extends Node2D

var hud: Hud
const TARGET: int = 12
const BASKET_W: float = 250.0
const BASKET_Y: float = 596.0
const CATCH_W: float = 210.0
const CATCH_TOP: float = 588.0
const CATCH_H: float = 78.0

var chilli_tex: Array = ["chilli_red1", "chilli_red2", "chilli_red3", "chilli_red4", "chilli_green1", "chilli_green2"]

var grandma_x: float = 640.0
var chillies: Array = []
var caught: int = 0
var missed: int = 0
var spawn_t: float = 0.6
var finished: bool = false
var anger_t: float = 0.0
var anger_pos := Vector2.ZERO

func _ready() -> void:
	Game.timer_running = true
	hud = Hud.new()
	add_child(hud)
	hud.title_label.text = "Spice stand"
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _catch_rect() -> Rect2:
	return Rect2(grandma_x - CATCH_W * 0.5, CATCH_TOP, CATCH_W, CATCH_H)

func _process(delta: float) -> void:
	if finished:
		queue_redraw()
		return

	anger_t = max(0.0, anger_t - delta * 1.1)
	grandma_x = clamp(get_global_mouse_position().x, BASKET_W * 0.5, Game.W - BASKET_W * 0.5)

	spawn_t -= delta
	if spawn_t <= 0.0:
		spawn_t = max(0.34, 1.0 - 0.05 * float(caught))
		chillies.append({
			"pos": Vector2(randf_range(90.0, Game.W - 90.0), -60.0),
			"speed": 210.0 + 26.0 * float(caught) + randf_range(-25.0, 25.0),
			"spin": randf_range(-2.5, 2.5),
			"rot": randf_range(0.0, TAU),
			"tex": chilli_tex[randi_range(0, chilli_tex.size() - 1)],
		})

	var catcher: Rect2 = _catch_rect()
	for i in range(chillies.size() - 1, -1, -1):
		var c: Dictionary = chillies[i]
		c["pos"].y += c["speed"] * delta
		c["rot"] += c["spin"] * delta
		if catcher.has_point(c["pos"]):
			chillies.remove_at(i)
			caught += 1
			Sfx.play("catch", -8.0, randf_range(0.9, 1.15))
			if caught >= TARGET:
				_win()
		elif c["pos"].y > Game.H + 60.0:
			chillies.remove_at(i)
			missed += 1
			Game.lose_time(4.0)
			Sfx.play("error")
			anger_t = 1.0
			anger_pos = Vector2(grandma_x + 130.0, 500.0)
			hud.flash("Dropped one, minus four seconds", 0.8)

	hud.info_label.text = "Caught %d of %d      dropped %d" % [caught, TARGET, missed]
	queue_redraw()

func _win() -> void:
	finished = true
	Sfx.play("good", -3.0)
	Game.collect("chilli", max(0, 500 - missed * 40))
	hud.flash("The vendor hands over the salt!", 1.4)
	await get_tree().create_timer(1.4).timeout
	Game.goto("res://scenes/Map.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_market")
	Art.sprite_bottom(self, "tent_chilli", Vector2(640, 600), 340)

	for c in chillies:
		Art.sprite(self, c["tex"], c["pos"], 90.0, c["rot"])

	var b: Texture2D = Art.tex("basket")
	var bh: float = BASKET_W * (float(b.get_height()) / float(b.get_width())) if b != null else 120.0
	Art.sprite(self, "basket", Vector2(grandma_x, BASKET_Y + bh * 0.5 - 20.0), bh)
	if finished:
		Art.sprite(self, "salt", Vector2(grandma_x, BASKET_Y - 60.0), 120.0)
	Art.anger(self, anger_pos, anger_t)
