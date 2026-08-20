class_name Art
extends RefCounted

# Loads and draws the PNGs in res://art. Everything falls back to a plain colour
# if a texture is missing, so the game still runs if a file gets renamed.

# One place for the look of every panel and label in the game.
const PANEL_TINT := Color(0.44, 0.58, 0.40, 0.95)   # pastel dark green
const PANEL_WARM := Color(0.66, 0.50, 0.36, 0.95)   # pastel brown, for accents
const INK := Color(1.0, 0.93, 0.58)                 # light yellow on the panels
const INK_DARK := Color(0.26, 0.21, 0.13)           # for pastel plaques

static var _cache: Dictionary = {}
static var _font: Font = null
static var _font_wide: Font = null

static func tex(name: String) -> Texture2D:
	if not _cache.has(name):
		var path: String = "res://art/%s.png" % name
		if not ResourceLoader.exists(path):
			path = "res://art/ui/%s.png" % name
		_cache[name] = load(path) if ResourceLoader.exists(path) else null
	return _cache[name]

static func draw_bg(c: CanvasItem, name: String, fallback: Color = Color(0.18, 0.16, 0.22)) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		c.draw_rect(Rect2(0, 0, 1280, 720), fallback)
	else:
		c.draw_texture_rect(t, Rect2(0, 0, 1280, 720), false)

# Draw centred on a point, sized by height, optionally rotated or mirrored.
static func sprite(c: CanvasItem, name: String, centre: Vector2, height: float, rot: float = 0.0, mod: Color = Color(1, 1, 1), flip: bool = false) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		return
	var s: float = height / float(t.get_height())
	var w: float = float(t.get_width()) * s
	c.draw_set_transform(centre, rot, Vector2(-1.0 if flip else 1.0, 1.0))
	c.draw_texture_rect(t, Rect2(-w * 0.5, -height * 0.5, w, height), false, mod)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# Same but anchored at the feet, for anything standing on the ground.
static func sprite_bottom(c: CanvasItem, name: String, feet: Vector2, height: float, flip: bool = false, mod: Color = Color(1, 1, 1)) -> void:
	sprite(c, name, feet - Vector2(0, height * 0.5), height, 0.0, mod, flip)

# Anchored at the top left and sized by width.
static func sprite_at(c: CanvasItem, name: String, topleft: Vector2, width: float, mod: Color = Color(1, 1, 1)) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		return
	var s: float = width / float(t.get_width())
	c.draw_texture_rect(t, Rect2(topleft, Vector2(width, float(t.get_height()) * s)), false, mod)

# The glass and the six liquid levels share one square canvas, so they must be
# drawn with the same centre and size or the liquid will not sit in the glass.
static func canvas_sprite(c: CanvasItem, name: String, centre: Vector2, size: float, mod: Color = Color(1, 1, 1)) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		return
	c.draw_texture_rect(t, Rect2(centre - Vector2(size, size) * 0.5, Vector2(size, size)), false, mod)

static func font(wide: bool = false) -> Font:
	if wide:
		if _font_wide == null:
			var pw: String = "res://fonts/LuckiestGuy.ttf"
			_font_wide = load(pw) if ResourceLoader.exists(pw) else ThemeDB.fallback_font
		return _font_wide
	if _font == null:
		var pn: String = "res://fonts/Chewy.ttf"
		_font = load(pn) if ResourceLoader.exists(pn) else ThemeDB.fallback_font
	return _font

static func text(c: CanvasItem, pos: Vector2, s: String, size: int = 20, col: Color = Color(1, 1, 1), align: int = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0, wide: bool = false) -> void:
	c.draw_string(font(wide), pos, s, align, width, size, col)

# Nine slice a UI panel to any size so the rounded corners stay round.
static func nine(c: CanvasItem, name: String, rect: Rect2, m: float = 22.0, mod: Color = Color(1, 1, 1)) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		c.draw_rect(rect, Color(0.08, 0.07, 0.11, 0.75))
		return
	var w: float = float(t.get_width())
	var h: float = float(t.get_height())
	var mm: float = min(m, min(rect.size.x, rect.size.y) * 0.45)
	var x0: float = rect.position.x
	var y0: float = rect.position.y
	var x1: float = x0 + rect.size.x
	var y1: float = y0 + rect.size.y
	var iw: float = rect.size.x - 2.0 * mm
	var ih: float = rect.size.y - 2.0 * mm
	c.draw_texture_rect_region(t, Rect2(x0, y0, mm, mm), Rect2(0, 0, m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x1 - mm, y0, mm, mm), Rect2(w - m, 0, m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x0, y1 - mm, mm, mm), Rect2(0, h - m, m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x1 - mm, y1 - mm, mm, mm), Rect2(w - m, h - m, m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x0 + mm, y0, iw, mm), Rect2(m, 0, w - 2.0 * m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x0 + mm, y1 - mm, iw, mm), Rect2(m, h - m, w - 2.0 * m, m), mod)
	c.draw_texture_rect_region(t, Rect2(x0, y0 + mm, mm, ih), Rect2(0, m, m, h - 2.0 * m), mod)
	c.draw_texture_rect_region(t, Rect2(x1 - mm, y0 + mm, mm, ih), Rect2(w - m, m, m, h - 2.0 * m), mod)
	c.draw_texture_rect_region(t, Rect2(x0 + mm, y0 + mm, iw, ih), Rect2(m, m, w - 2.0 * m, h - 2.0 * m), mod)

# Little red anger mark that pops up when Nan is not happy with you.
static func anger(c: CanvasItem, pos: Vector2, t: float) -> void:
	if t <= 0.0:
		return
	var a: float = clamp(t, 0.0, 1.0)
	sprite(c, "anger", pos - Vector2(0.0, (1.0 - a) * 28.0), 70.0 + a * 22.0, 0.0, Color(1, 1, 1, a))

# Grows a sprite slightly while the mouse is over it. Returns its rect for hit testing.
static func button_rect(name: String, centre: Vector2, height: float) -> Rect2:
	var t: Texture2D = tex(name)
	var w: float = height * 2.2
	if t != null:
		w = height * float(t.get_width()) / float(t.get_height())
	return Rect2(centre - Vector2(w, height) * 0.5, Vector2(w, height))

# A panel in the game's colours, so every screen matches.
static func panel(c: CanvasItem, rect: Rect2, tint: Color = PANEL_TINT, m: float = 22.0) -> void:
	nine(c, "panel_grey", rect, m, tint)

# Draws part of a texture blown up around a point, used for the PLAY button on the
# start page which is painted into the background image.
static func zoom_region(c: CanvasItem, name: String, src: Rect2, scale: float) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		return
	var centre: Vector2 = src.position + src.size * 0.5
	var dst := Rect2(centre - src.size * scale * 0.5, src.size * scale)
	c.draw_texture_rect_region(t, dst, src)

# Background drawn at a given rect, optionally mirrored. Mirroring alternate copies
# makes a wide scrolling backdrop tile without a visible seam.
static func draw_bg_at(c: CanvasItem, name: String, rect: Rect2, flip: bool = false) -> void:
	var t: Texture2D = tex(name)
	if t == null:
		c.draw_rect(rect, Color(0.42, 0.58, 0.78))
		return
	if flip:
		c.draw_set_transform(rect.position + Vector2(rect.size.x, 0.0), 0.0, Vector2(-1.0, 1.0))
		c.draw_texture_rect(t, Rect2(0.0, 0.0, rect.size.x, rect.size.y), false)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		c.draw_texture_rect(t, rect, false)
