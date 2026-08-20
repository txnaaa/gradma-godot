extends Node2D

# Plays res://video/intro.ogv if it is there, otherwise goes straight to the menu.
# Godot 4 only plays Ogg Theora, so an mp4 has to be converted first. See README.

var player: VideoStreamPlayer
var leaving: bool = false

const VIDEO_PATH: String = "res://video/intro.ogv"

func _ready() -> void:
	Game.timer_running = false
	Sfx.stop_music()
	if not ResourceLoader.exists(VIDEO_PATH):
		call_deferred("_leave")
		return

	player = VideoStreamPlayer.new()
	player.stream = load(VIDEO_PATH)
	player.expand = true
	player.position = Vector2.ZERO
	player.size = Vector2(Game.W, Game.H)
	player.finished.connect(_leave)
	add_child(player)
	player.play()

	# added after the player, so it draws on top of the video
	var skip := Label.new()
	skip.text = "CLICK TO SKIP"
	skip.position = Vector2(Game.W - 250.0, Game.H - 52.0)
	var f: Font = Art.font()
	if f != null:
		skip.add_theme_font_override("font", f)
	skip.add_theme_font_size_override("font_size", 18)
	skip.add_theme_color_override("font_color", Art.INK)
	skip.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	skip.add_theme_constant_override("shadow_offset_x", 2)
	skip.add_theme_constant_override("shadow_offset_y", 2)
	add_child(skip)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_leave()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER]:
		_leave()

func _leave() -> void:
	if leaving:
		return
	leaving = true
	if player != null:
		player.stop()
	Game.goto("res://scenes/Intro.tscn")

func _draw() -> void:
	draw_rect(Rect2(0, 0, Game.W, Game.H), Color(0, 0, 0))
