extends Node2D

# Hold the left mouse button to pour, let go when the drink reaches the line.
# The glass art has six liquid levels, so the line is drawn at the exact height
# of whichever level she asked for.

var hud: Hud

const CUPS_NEEDED: int = 3
const LEVELS: int = 6
const SPILL_FILL: float = 7.0 / 6.0
const GLASS_CENTRE := Vector2(690.0, 430.0)
const GLASS_SIZE: float = 520.0
const BOTTLE_TOPLEFT := Vector2(585.0, 55.0)
const BOTTLE_W: float = 460.0

# Where the top of the liquid sits in each fill frame, and where the glass sides
# are, both as a fraction of the shared square canvas. Measured from the PNGs.
const SURFACE: Array = [0.4827, 0.4231, 0.3500, 0.3192, 0.2615, 0.1846]
const GLASS_LEFT: float = 0.3135
const GLASS_RIGHT: float = 0.7519

var cup_index: int = 0
var fill: float = 0.0
var pouring: bool = false
var target_level: int = 3
var spilled: bool = false
var finished: bool = false
var mistakes: int = 0
var anger_t: float = 0.0

func _ready() -> void:
	Game.timer_running = true
	hud = Hud.new()
	add_child(hud)
	hud.title_label.text = "DRINKS STAND"
	_setup_cup()

func _setup_cup() -> void:
	fill = 0.0
	pouring = false
	spilled = false
	target_level = randi_range(2, LEVELS)

func _level() -> int:
	return clampi(int(floor(fill * float(LEVELS))), 0, LEVELS)

func _pour_rate() -> float:
	return 0.13 + 0.045 * float(cup_index)

func _canvas_top() -> float:
	return GLASS_CENTRE.y - GLASS_SIZE * 0.5

func _line_y(level: int) -> float:
	return _canvas_top() + float(SURFACE[clampi(level - 1, 0, LEVELS - 1)]) * GLASS_SIZE

func _input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not spilled:
				pouring = true
				Sfx.play("pour", -10.0)
		elif pouring:
			pouring = false
			_serve()

func _process(delta: float) -> void:
	if finished:
		return
	anger_t = max(0.0, anger_t - delta * 1.1)
	if pouring:
		fill += _pour_rate() * delta
		if fill >= SPILL_FILL:
			fill = SPILL_FILL
			pouring = false
			spilled = true
			_fail("OVERFLOWED EVERYWHERE")
	hud.info_label.text = "GLASS %d OF %d      STOP ON THE LINE" % [min(cup_index + 1, CUPS_NEEDED), CUPS_NEEDED]
	queue_redraw()

func _serve() -> void:
	if _level() == target_level:
		Sfx.play("good", -4.0)
		cup_index += 1
		if cup_index >= CUPS_NEEDED:
			_win()
		else:
			hud.flash("Nice pour", 0.8)
			_setup_cup()
	else:
		_fail("TOO HIGH" if _level() > target_level else "NOT UP TO THE LINE")

func _fail(reason: String) -> void:
	mistakes += 1
	Sfx.play("error")
	anger_t = 1.0
	Game.lose_time(6.0)
	hud.flash(reason + ", minus six seconds", 1.0)
	await get_tree().create_timer(1.0).timeout
	if not finished:
		_setup_cup()

func _win() -> void:
	finished = true
	Game.collect("mixers", max(0, 500 - mistakes * 50))
	hud.flash("Mixers sorted!", 1.2)
	await get_tree().create_timer(1.2).timeout
	Game.goto("res://scenes/Map.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_bar")

	Art.canvas_sprite(self, "glass", GLASS_CENTRE, GLASS_SIZE)

	var lf: float = fill * float(LEVELS)
	var lower: int = clampi(int(floor(lf)), 0, LEVELS)
	var frac: float = lf - float(lower)
	if lower >= 1:
		Art.canvas_sprite(self, "fill%d" % (lower - 1), GLASS_CENTRE, GLASS_SIZE)
	if lower < LEVELS and frac > 0.0:
		Art.canvas_sprite(self, "fill%d" % lower, GLASS_CENTRE, GLASS_SIZE, Color(1, 1, 1, frac))

	_draw_target_line()
	Art.sprite_at(self, "bottle_pour" if pouring else "bottle_idle", BOTTLE_TOPLEFT, BOTTLE_W)
	Art.anger(self, Vector2(430.0, 250.0), anger_t)

func _draw_target_line() -> void:
	var left: float = GLASS_CENTRE.x - GLASS_SIZE * 0.5 + GLASS_LEFT * GLASS_SIZE
	var right: float = GLASS_CENTRE.x - GLASS_SIZE * 0.5 + GLASS_RIGHT * GLASS_SIZE
	var y: float = _line_y(target_level)
	var reached: bool = _level() >= target_level
	var col: Color = Color(0.95, 0.35, 0.3) if reached else Color(0.15, 0.75, 0.35)

	# dashes across the glass, then a solid tail out to the label
	var x: float = left - 34.0
	while x < right + 20.0:
		draw_line(Vector2(x, y), Vector2(min(x + 14.0, right + 20.0), y), col, 5.0)
		x += 24.0
	draw_line(Vector2(right + 20.0, y), Vector2(right + 96.0, y), col, 5.0)

	Art.nine(self, "panel_grey", Rect2(right + 92.0, y - 26.0, 168.0, 52.0), 22.0, Art.PANEL_TINT)
	Art.text(self, Vector2(right + 92.0, y - 2.0), "FILL TO", 18, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, 168.0)
	Art.text(self, Vector2(right + 92.0, y + 18.0), "HERE", 17, col, HORIZONTAL_ALIGNMENT_CENTER, 168.0)
