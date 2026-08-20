extends Node2D

var hud: Hud
var page: int = 0
var pages: Array = [
	"Nan made it. The hall smells of coffee and hairspray.",
	"First job: the ladies are thirsty.\nHold the mouse over a glass to pour, stop on the marked level.",
]

func _ready() -> void:
	Game.timer_running = false
	Game.reached_hall = true
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.title_label.text = "Chapter two: bingo night"
	hud.info_label.text = "Click to continue"
	hud.msg_label.add_theme_font_size_override("font_size", 28)
	hud.msg_label.position.y = 150.0
	hud.msg_label.text = pages[page]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Sfx.play("click", -12.0)
		page += 1
		if page >= pages.size():
			Game.goto("res://scenes/Cocktails.tscn")
		else:
			hud.msg_label.text = pages[page]

func _draw() -> void:
	Art.draw_bg(self, "bg_bar")
	draw_rect(Rect2(0, 120, Game.W, 140), Color(0, 0, 0, 0.45))
	Art.sprite_bottom(self, "grandma_walk", Vector2(300, 725), 340)
