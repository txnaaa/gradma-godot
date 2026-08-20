extends Node2D

# One card. Win and you get the bingo picture with the buttons in the middle.
# Lose and Nan turns on you: gunshot, cracked screen, and the same two buttons.

var hud: Hud
var hover_replay: float = 0.0
var hover_quit: float = 0.0
var t: float = 0.0
var shot_done: bool = false

const BTN_W: float = 230.0
const BTN_H: float = 62.0
const BAR_Y: float = 596.0
# the win artwork already has replay and Quit painted on the telly, so on that
# screen the buttons are hotspots over the painted ones instead of drawn panels
const WIN_REPLAY := Rect2(474.0, 326.0, 164.0, 88.0)
const WIN_QUIT := Rect2(736.0, 326.0, 162.0, 88.0)

func _ready() -> void:
	Game.timer_running = false
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.head_panel.visible = false
	hud.title_label.text = ""
	hud.info_label.text = ""
	if not Game.bingo_won:
		Sfx.stop_music()
		Sfx.play("gunshot", -2.0)
		shot_done = true

func _replay_rect() -> Rect2:
	return WIN_REPLAY if Game.bingo_won else Rect2(716.0, BAR_Y + 8.0, BTN_W, BTN_H)

func _quit_rect() -> Rect2:
	return WIN_QUIT if Game.bingo_won else Rect2(976.0, BAR_Y + 8.0, BTN_W, BTN_H)

func _process(delta: float) -> void:
	t += delta
	var m: Vector2 = get_global_mouse_position()
	hover_replay = move_toward(hover_replay, 1.0 if _replay_rect().has_point(m) else 0.0, delta * 7.0)
	hover_quit = move_toward(hover_quit, 1.0 if _quit_rect().has_point(m) else 0.0, delta * 7.0)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var m: Vector2 = get_global_mouse_position()
		if _replay_rect().has_point(m):
			Sfx.play("click")
			Game.goto("res://scenes/MainMenu.tscn")
		elif _quit_rect().has_point(m):
			Sfx.play("click")
			get_tree().quit()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_R]:
			Game.goto("res://scenes/MainMenu.tscn")

func _draw() -> void:
	if Game.bingo_won:
		Art.draw_bg(self, "bg_win")
		Art.sprite(self, "cookie", Vector2(180, 250 + sin(t * 2.0) * 8.0), 96)
	else:
		Art.draw_bg(self, "bg_end")
		# she is pointing it right at you
		var recoil: float = max(0.0, 1.0 - t * 3.5)
		Art.sprite_bottom(self, "grandma_angry", Vector2(150, 736 + recoil * 10.0), 292 + recoil * 16.0)
		Art.sprite(self, "anger", Vector2(268, 470), 92)

	# everything lives in a bar along the bottom, so the artwork stays visible
	var caption: String = "SHE GOT HER LINE" if Game.bingo_won else ("THE SHOPS BEAT HER" if not Game.reached_hall else "NO LINE TONIGHT")
	var r := Rect2(300.0, BAR_Y, 380.0, 100.0)
	Art.panel(self, r)
	Art.text(self, Vector2(r.position.x, r.position.y + 36.0), caption, 20, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
	Art.text(self, Vector2(r.position.x, r.position.y + 84.0), str(Game.total_score()), 38, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, true)

	if Game.bingo_won:
		# nudge the painted buttons rather than covering them
		if hover_replay > 0.01:
			Art.zoom_region(self, "bg_win", WIN_REPLAY, 1.0 + hover_replay * 0.13)
		if hover_quit > 0.01:
			Art.zoom_region(self, "bg_win", WIN_QUIT, 1.0 + hover_quit * 0.13)
	else:
		_draw_button(_replay_rect(), "panel_green", "REPLAY", hover_replay)
		_draw_button(_quit_rect(), "panel_red", "QUIT", hover_quit)
		Art.sprite(self, "icon_retry", Vector2(_replay_rect().position.x + 26.0, _replay_rect().position.y + BTN_H * 0.5), 46.0)

func _draw_button(r: Rect2, panel: String, label: String, hover: float) -> void:
	var grow: float = hover * 6.0
	var box := Rect2(r.position - Vector2(grow, grow), r.size + Vector2(grow, grow) * 2.0)
	Art.nine(self, panel, box, 22.0, Color(1, 1, 1).lerp(Color(1.25, 1.25, 1.25), hover))
	Art.text(self, Vector2(box.position.x + 24.0, box.position.y + box.size.y * 0.66), label, 24, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, box.size.x)
