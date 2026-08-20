extends Node2D

# The market half ran out of time. One message, one clear way onwards. The flaming
# icon is not used here, it means replay and this screen does not replay anything.

var hud: Hud
var hover: float = 0.0

const BTN := Rect2(880.0, 560.0, 260.0, 66.0)

func _ready() -> void:
	Game.timer_running = false
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.title_label.text = "The shutters came down"
	hud.info_label.text = ""
	hud.msg_label.position.y = 180.0
	hud.msg_label.add_theme_font_size_override("font_size", 32)
	hud.msg_label.text = "Nan ran out of time.\nNo snacks, no bingo."

func _process(delta: float) -> void:
	hover = move_toward(hover, 1.0 if BTN.has_point(get_global_mouse_position()) else 0.0, delta * 7.0)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if BTN.has_point(get_global_mouse_position()):
			Sfx.play("click")
			Game.goto("res://scenes/Ending.tscn")
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE, KEY_ENTER]:
		Sfx.play("click")
		Game.goto("res://scenes/Ending.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_market")
	draw_rect(Rect2(0, 0, Game.W, Game.H), Color(0.05, 0.04, 0.09, 0.42))
	Art.sprite_bottom(self, "grandma_angry", Vector2(420, 730), 400)
	Art.sprite(self, "anger", Vector2(580, 380), 120)

	var grow: float = hover * 6.0
	var box := Rect2(BTN.position - Vector2(grow, grow), BTN.size + Vector2(grow, grow) * 2.0)
	Art.nine(self, "panel_green", box, 22.0, Color(1, 1, 1).lerp(Color(1.25, 1.25, 1.25), hover))
	Art.text(self, Vector2(box.position.x, box.position.y + box.size.y * 0.66), "CONTINUE", 24, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, box.size.x)
