class_name Hud
extends CanvasLayer

# Shared heads up display. Panels are Kenney's CC0 UI pack as NinePatchRects, so they
# stretch to any size without the rounded corners smearing.

var title_label: Label
var info_label: Label
var msg_label: Label
var timer_label: Label
var head_panel: NinePatchRect
var bar_bg: NinePatchRect
var bar_fill: NinePatchRect
var show_timer: bool = true

const BAR_W: float = 372.0

func _ready() -> void:
	layer = 10

	head_panel = _panel("panel_grey", Vector2(16.0, 12.0), Vector2(520.0, 86.0))
	head_panel.modulate = Art.PANEL_TINT
	bar_bg = _panel("panel_grey", Vector2(Game.W - 404.0, 14.0), Vector2(BAR_W + 16.0, 78.0))
	bar_bg.modulate = Art.PANEL_TINT
	bar_fill = _panel("panel_green", Vector2(Game.W - 396.0, 52.0), Vector2(BAR_W, 30.0))

	title_label = _make_label(Vector2(32.0, 18.0), 28, Art.INK, true)
	info_label = _make_label(Vector2(32.0, 58.0), 19, Art.INK, true)
	timer_label = _make_label(Vector2(Game.W - 396.0, 20.0), 19, Art.INK, true)
	timer_label.size = Vector2(BAR_W, 24.0)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	msg_label = _make_label(Vector2(0.0, 300.0), 42, Art.INK, true)
	msg_label.size = Vector2(Game.W, 60.0)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _panel(tex_name: String, pos: Vector2, size: Vector2) -> NinePatchRect:
	var np := NinePatchRect.new()
	np.texture = Art.tex(tex_name)
	for side in ["left", "top", "right", "bottom"]:
		np.set("patch_margin_" + side, 22)
	np.position = pos
	np.size = size
	add_child(np)
	return np

func _make_label(pos: Vector2, fsize: int, col: Color, game_font: bool) -> Label:
	var l := Label.new()
	l.position = pos
	l.text = ""
	if game_font:
		var f: Font = Art.font()
		if f != null:
			l.add_theme_font_override("font", f)
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	add_child(l)
	return l

func _process(_delta: float) -> void:
	bar_bg.visible = show_timer
	bar_fill.visible = show_timer
	timer_label.visible = show_timer
	if show_timer:
		var f: float = clamp(Game.shop_time_left / Game.SHOP_TIME, 0.0, 1.0)
		bar_fill.size.x = max(46.0, BAR_W * f)
		bar_fill.visible = f > 0.02
		bar_fill.texture = Art.tex("panel_red" if f < 0.25 else "panel_yellow")
		timer_label.text = "SHOPS CLOSE IN %d" % int(ceil(Game.shop_time_left))

func flash(text: String, seconds: float = 1.1) -> void:
	msg_label.text = text
	await get_tree().create_timer(seconds).timeout
	if is_instance_valid(msg_label) and msg_label.text == text:
		msg_label.text = ""
