extends Node2D

var hud: Hud
var page: int = 0

var pages: Array = [
	"Bingo night is at seven. Nan just remembered.",
	"But she promised to bring the drinks and the snacks.",
	"The market tents are still open, just about.\nGrab everything on the list before they shut.",
]

func _ready() -> void:
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.title_label.text = "Chapter one: the market"
	hud.info_label.text = "Click to continue"
	hud.msg_label.add_theme_font_size_override("font_size", 28)
	hud.msg_label.position.y = 180.0
	hud.msg_label.text = pages[page]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Sfx.play("click", -12.0)
		page += 1
		if page >= pages.size():
			Game.timer_running = true
			Game.goto("res://scenes/Map.tscn")
		else:
			hud.msg_label.text = pages[page]

func _draw() -> void:
	Art.draw_bg(self, "bg_market")
	draw_rect(Rect2(0, 150, Game.W, 140), Color(0, 0, 0, 0.4))
	Art.sprite_bottom(self, "grandma_walk", Vector2(560, 715), 340)
	if page == pages.size() - 1:
		Art.sprite(self, "cookie", Vector2(840, 480), 130)
