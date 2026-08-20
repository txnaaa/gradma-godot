extends Node2D

var hud: Hud

const CELL_W: float = 136.0
const CELL_H: float = 58.0
const ORIGIN := Vector2(300.0, 410.0)
const BALL_CENTRE := Vector2(657.0, 224.0)
const BALL_R: float = 88.0
const CALL_INTERVAL: float = 2.4
const MAX_CALLS: int = 40

var card: Array = []
var marked: Array = []
var called_number: int = 0
var call_timer: float = CALL_INTERVAL
var calls_made: int = 0
var pool: Array = []
var missed_calls: int = 0
var finished: bool = false
var flash_cell := Vector2(-1, -1)
var flash_t: float = 0.0

func _ready() -> void:
	Game.timer_running = false
	Sfx.play_music("music_rock")
	hud = Hud.new()
	hud.show_timer = false
	add_child(hud)
	hud.title_label.text = "Eyes down"
	_build_card()
	for n in range(1, 76):
		pool.append(n)
	pool.shuffle()
	_call_next()

func _build_card() -> void:
	card.clear()
	marked.clear()
	for col in range(5):
		var low: int = col * 15 + 1
		var nums: Array = []
		for n in range(low, low + 15):
			nums.append(n)
		nums.shuffle()
		var column: Array = []
		var marks: Array = []
		for row in range(5):
			column.append(nums[row])
			marks.append(false)
		card.append(column)
		marked.append(marks)
	marked[2][2] = true

func _card_numbers_left() -> Array:
	var left: Array = []
	for col in range(5):
		for row in range(5):
			if not marked[col][row]:
				left.append(card[col][row])
	return left

func _call_next() -> void:
	if called_number != 0 and _is_on_card(called_number) and not _is_marked(called_number):
		missed_calls += 1
	calls_made += 1
	if calls_made > MAX_CALLS:
		_finish(false)
		return
	var wanted: Array = _card_numbers_left()
	var pick: int = 0
	if wanted.size() > 0 and randf() < 0.45:
		pick = wanted[randi_range(0, wanted.size() - 1)]
		pool.erase(pick)
	else:
		if pool.is_empty():
			_finish(false)
			return
		pick = pool.pop_back()
	called_number = pick
	call_timer = CALL_INTERVAL
	Sfx.play("call", -10.0)

func _is_on_card(n: int) -> bool:
	for col in range(5):
		for row in range(5):
			if card[col][row] == n:
				return true
	return false

func _is_marked(n: int) -> bool:
	for col in range(5):
		for row in range(5):
			if card[col][row] == n and marked[col][row]:
				return true
	return false

func _process(delta: float) -> void:
	if finished:
		return
	flash_t = max(0.0, flash_t - delta * 2.0)
	call_timer -= delta
	if call_timer <= 0.0:
		_call_next()
	hud.info_label.text = "Call %d of %d      missed %d" % [calls_made, MAX_CALLS, missed_calls]
	queue_redraw()

func _cell_rect(col: int, row: int) -> Rect2:
	return Rect2(ORIGIN.x + float(col) * CELL_W, ORIGIN.y + float(row) * CELL_H, CELL_W - 5.0, CELL_H - 5.0)

func _input(event: InputEvent) -> void:
	if finished:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var m: Vector2 = get_global_mouse_position()
		for col in range(5):
			for row in range(5):
				if _cell_rect(col, row).has_point(m):
					if card[col][row] == called_number and not marked[col][row]:
						marked[col][row] = true
						Sfx.play("mark", -6.0)
						flash_cell = Vector2(col, row)
						flash_t = 1.0
						if _has_line():
							_finish(true)
					return

func _has_line() -> bool:
	for row in range(5):
		var ok: bool = true
		for col in range(5):
			if not marked[col][row]:
				ok = false
		if ok:
			return true
	for col in range(5):
		var ok2: bool = true
		for row in range(5):
			if not marked[col][row]:
				ok2 = false
		if ok2:
			return true
	var d1: bool = true
	var d2: bool = true
	for i in range(5):
		if not marked[i][i]:
			d1 = false
		if not marked[i][4 - i]:
			d2 = false
	return d1 or d2

func _finish(won: bool) -> void:
	finished = true
	Sfx.play("win" if won else "error", -3.0)
	Game.bingo_won = won
	Game.scores["bingo"] = (800 - missed_calls * 30) if won else 0
	hud.flash("BINGO!" if won else "No line tonight", 1.6)
	await get_tree().create_timer(1.6).timeout
	Game.goto("res://scenes/Ending.tscn")

func _draw() -> void:
	Art.draw_bg(self, "bg_bingo")

	# a chip covers the number painted on the telly and carries the live call
	Art.sprite(self, "ball", BALL_CENTRE, BALL_R * 2.0)
	Art.text(self, BALL_CENTRE + Vector2(-BALL_R, 26.0), str(called_number), 66, Color(0.16, 0.16, 0.2), HORIZONTAL_ALIGNMENT_CENTER, BALL_R * 2.0, true)

	# time until the next call
	var f: float = clamp(call_timer / CALL_INTERVAL, 0.0, 1.0)
	Art.nine(self, "panel_grey", Rect2(BALL_CENTRE.x - 96.0, BALL_CENTRE.y + BALL_R + 10.0, 192.0, 30.0), 14.0)
	Art.nine(self, "panel_yellow", Rect2(BALL_CENTRE.x - 90.0, BALL_CENTRE.y + BALL_R + 14.0, max(30.0, 180.0 * f), 22.0), 11.0)

	# the card
	Art.nine(self, "panel_grey", Rect2(ORIGIN.x - 18.0, ORIGIN.y - 52.0, CELL_W * 5.0 + 30.0, CELL_H * 5.0 + 66.0), 22.0, Art.PANEL_TINT)
	var headers: Array = ["B", "I", "N", "G", "O"]
	for col in range(5):
		Art.text(self, Vector2(ORIGIN.x + float(col) * CELL_W, ORIGIN.y - 12.0), headers[col], 34, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, CELL_W - 5.0, true)

	for col in range(5):
		for row in range(5):
			var r: Rect2 = _cell_rect(col, row)
			var panel: String = "panel_blue"
			if card[col][row] == called_number and not marked[col][row]:
				panel = "panel_yellow"
			var tint: Color = Color(1, 1, 1)
			if flash_t > 0.0 and flash_cell == Vector2(col, row):
				tint = Color(1, 1, 1).lightened(flash_t * 0.4)
			Art.nine(self, panel, r, 16.0, tint)
			if marked[col][row]:
				Art.sprite(self, "chip_red", r.position + r.size * 0.5, r.size.y * 0.88, 0.0, Color(1, 1, 1, 0.95))
			var label: String = "FREE" if (col == 2 and row == 2) else str(card[col][row])
			Art.text(self, Vector2(r.position.x, r.position.y + 39.0), label, 25, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)

	Art.nine(self, "panel_grey", Rect2(24, 300, 250, 84), 22.0, Art.PANEL_TINT)
	Art.text(self, Vector2(24, 336), "CLICK THE NUMBER", 20, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, 250.0)
	Art.text(self, Vector2(24, 364), "BEFORE THE NEXT CALL", 20, Art.INK, HORIZONTAL_ALIGNMENT_CENTER, 250.0)
