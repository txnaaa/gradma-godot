extends Node2D

# The start page is your painted image, PLAY button and all, so the button here is
# just a hotspot over where it sits in the picture.

var hud: Hud
var hover: float = 0.0
var t: float = 0.0

const PLAY_RECT := Rect2(506.0, 548.0, 280.0, 108.0)

func _ready() -> void:
	Game.reset_run()
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.head_panel.visible = false
	hud.title_label.text = ""
	hud.info_label.text = ""

func _process(delta: float) -> void:
	t += delta
	var over: bool = PLAY_RECT.has_point(get_global_mouse_position())
	hover = move_toward(hover, 1.0 if over else 0.0, delta * 7.0)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if PLAY_RECT.has_point(get_global_mouse_position()):
			Sfx.play("click")
			Game.goto("res://scenes/Cutscene.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_start", Color(0.72, 0.82, 0.45))
	# the button is painted into the picture, so zoom that patch of it on hover
	var pulse: float = 1.0 + hover * 0.10 + sin(t * 2.4) * 0.015
	if pulse > 1.001:
		Art.zoom_region(self, "bg_start", PLAY_RECT, pulse)
