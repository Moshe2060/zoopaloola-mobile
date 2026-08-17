extends Node2D

const BOARD_W := 207.0
const BOARD_H := 208.0
const RADIUS := 6.0
const SUBSTEPS := 10
const STEP_TIME := 0.005
const EFFECT_FRAME_TIME := 0.28

const HOLE_POSITIONS := [Vector2(32,165), Vector2(21,77), Vector2(6,-10), Vector2(147,17), Vector2(165,86), Vector2(128,143)]
const EFFECT_PATHS := [
	["39_id_051.png", "40_id_052.png", "41_id_053.png", "40_id_052.png"],
	["42_id_055.png"],
	["43_id_057.png", "44_id_058.png", "45_id_059.png", "46_id_060.png", "47_id_061.png", "48_id_062.png", "49_id_063.png"],
	["50_id_065.png", "51_id_066.png", "52_id_067.png", "51_id_066.png", "52_id_067.png"],
	["53_id_069.png", "54_id_070.png", "55_id_071.png", "54_id_070.png"],
	["56_id_073.png", "57_id_074.png"]
]
const EFFECT_LOOPS := [3, 1, 1, 2, 2, 6]
const EFFECT_OFFSETS := [Vector2.ZERO, Vector2.ZERO, Vector2(10,10), Vector2.ZERO, Vector2(-4,-1), Vector2.ZERO]

var board_texture: Texture2D
var piece_textures: Array[Texture2D] = []
var effects: Array = []
var balls: Array = []
var active_effects: Array = []
var contacts := {}

var view_origin := Vector2.ZERO
var board_scale := 1.0
var board_rect := Rect2()
var turn := 0
var selected := -1
var dragging := false
var drag_point := Vector2.ZERO
var accumulator := 0.0
var status := "התור שלך — גע בכדור אדום, משוך לאחור ושחרר"
var ai_pending := false
var ai_timer := 0.0

func _ready() -> void:
	board_texture = load("res://assets/board-modern.webp") as Texture2D
	if board_texture == null:
		push_error("Modern board texture could not be loaded; using original board.")
		board_texture = load("res://assets/board.png") as Texture2D
	for file_name in ["59_id_040.png", "60_id_041.png", "61_id_042.png", "62_id_043.png", "63_id_044.png"]:
		piece_textures.append(load("res://assets/pieces/" + file_name))
	for sequence in EFFECT_PATHS:
		var frames: Array[Texture2D] = []
		for file_name in sequence:
			frames.append(load("res://assets/effects/" + file_name))
		effects.append(frames)
	new_game()
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _on_resize() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var available := Vector2(maxf(300.0, viewport_size.x - 24.0), maxf(220.0, viewport_size.y - 88.0))
	var texture_size: Vector2 = board_texture.get_size()
	var fit_scale: float = minf(available.x / texture_size.x, available.y / texture_size.y)
	var drawn_size: Vector2 = texture_size * fit_scale
	view_origin = Vector2((viewport_size.x - drawn_size.x) * 0.5, 82.0 + max(0.0, (available.y - drawn_size.y) * 0.5))
	board_rect = Rect2(view_origin, drawn_size)
	board_scale = min(board_rect.size.x / BOARD_W, board_rect.size.y / BOARD_H)
	queue_redraw()

func new_game() -> void:
	balls.clear()
	active_effects.clear()
	contacts.clear()
	turn = 0
	ai_pending = false
	selected = -1
	dragging = false
	var red_positions := [Vector2(72,82), Vector2(72,104), Vector2(72,126)]
	var blue_positions := [Vector2(135,82), Vector2(135,104), Vector2(135,126)]
	for p in red_positions:
		balls.append({"p":p, "v":Vector2.ZERO, "team":0, "alive":true})
	for p in blue_positions:
		balls.append({"p":p, "v":Vector2.ZERO, "team":1, "alive":true})
	status = "התור שלך — גע בכדור אדום, משוך לאחור ושחרר"
	queue_redraw()

func _process(delta: float) -> void:
	accumulator += delta
	while accumulator >= STEP_TIME:
		physics_step()
		accumulator -= STEP_TIME
	update_effects(delta)
	if ai_pending:
		ai_timer -= delta
		if ai_timer <= 0.0 and not any_ball_moving():
			ai_pending = false
			ai_shot()
	queue_redraw()

func physics_step() -> void:
	contacts.clear()
	for i in balls.size():
		var ball: Dictionary = balls[i]
		if not ball.alive or ball.v == Vector2.ZERO:
			continue
		ball.p += ball.v
		ball.v *= 149.0 / 150.0
		if ball.v.length_squared() < 0.000095:
			ball.v = Vector2.ZERO
		resolve_walls(i)
	for i in balls.size():
		if not balls[i].alive:
			continue
		for j in range(i + 1, balls.size()):
			if balls[j].alive:
				resolve_collision(i, j)
	if turn == 1 and not ai_pending and not any_ball_moving():
		finish_ai_turn()

func resolve_walls(index: int) -> void:
	var ball: Dictionary = balls[index]
	var p: Vector2 = ball.p
	var v: Vector2 = ball.v
	var vertical_open := p.y < 41.0 or (p.y > 90.0 and p.y < 119.0) or p.y > 166.0
	var horizontal_open := p.x < 52.0 or p.x > 156.0
	if p.x - RADIUS < 38.0:
		if vertical_open:
			if p.x - RADIUS < 33.0: score_ball(index, hole_for_vertical(p.y, true)); return
		else:
			p.x = 38.0 + RADIUS; v.x = abs(v.x) * 0.75
	elif p.x + RADIUS > 165.0:
		if vertical_open:
			if p.x + RADIUS >= 170.0: score_ball(index, hole_for_vertical(p.y, false)); return
		else:
			p.x = 165.0 - RADIUS; v.x = -abs(v.x) * 0.75
	if p.y - RADIUS < 27.0:
		if horizontal_open:
			if p.y - RADIUS < 22.0: score_ball(index, 2 if p.x < 104.0 else 3); return
		else:
			p.y = 27.0 + RADIUS; v.y = abs(v.y) * 0.75
	elif p.y + RADIUS > 183.0:
		if horizontal_open:
			if p.y + RADIUS >= 188.0: score_ball(index, 0 if p.x < 104.0 else 5); return
		else:
			p.y = 183.0 - RADIUS; v.y = -abs(v.y) * 0.75
	ball.p = p; ball.v = v

func hole_for_vertical(y: float, left: bool) -> int:
	var k := 0 if y < 41.0 else (1 if y < 119.0 else 2)
	return 2 - k if left else 3 + k

func resolve_collision(a_index: int, b_index: int) -> void:
	var key := Vector2i(a_index, b_index)
	if contacts.has(key): return
	var a: Dictionary = balls[a_index]
	var b: Dictionary = balls[b_index]
	var delta: Vector2 = b.p - a.p
	var distance := delta.length()
	if distance <= 0.001 or distance >= RADIUS * 2.0: return
	contacts[key] = true
	var normal := delta / distance
	var overlap := RADIUS * 2.0 - distance
	a.p -= normal * overlap * 0.5
	b.p += normal * overlap * 0.5
	var relative: Vector2 = b.v - a.v
	var speed := relative.dot(normal)
	if speed < 0.0:
		a.v += normal * speed
		b.v -= normal * speed

func score_ball(index: int, hole: int) -> void:
	balls[index].alive = false
	balls[index].v = Vector2.ZERO
	active_effects.append({"hole":hole, "elapsed":0.0, "frame":0, "loops":0})
	status = "פגיעה בחור!"

func update_effects(delta: float) -> void:
	for effect in active_effects:
		effect.elapsed += delta
		if effect.elapsed >= EFFECT_FRAME_TIME:
			effect.elapsed -= EFFECT_FRAME_TIME
			effect.frame += 1
			if effect.frame >= effects[effect.hole].size():
				effect.frame = 0
				effect.loops += 1
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].loops >= EFFECT_LOOPS[active_effects[i].hole]:
			active_effects.remove_at(i)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed: pointer_down(event.position)
		else: pointer_up(event.position)
	elif event is InputEventScreenDrag:
		pointer_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: pointer_down(event.position)
		else: pointer_up(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pointer_move(event.position)

func pointer_down(screen_pos: Vector2) -> void:
	if Rect2(get_viewport_rect().size.x - 190.0, 24.0, 160.0, 54.0).has_point(screen_pos):
		new_game(); return
	if turn != 0 or any_ball_moving(): return
	var board_pos := screen_to_board(screen_pos)
	for i in balls.size():
		if balls[i].alive and balls[i].team == 0 and balls[i].p.distance_to(board_pos) <= 16.0:
			selected = i
			dragging = true
			drag_point = board_pos
			status = "משוך לאחור ושחרר"
			return

func pointer_move(screen_pos: Vector2) -> void:
	if dragging:
		drag_point = screen_to_board(screen_pos)

func pointer_up(screen_pos: Vector2) -> void:
	if not dragging or selected < 0: return
	drag_point = screen_to_board(screen_pos)
	var pull: Vector2 = balls[selected].p - drag_point
	var strength: float = clampf(pull.length(), 5.0, 30.0)
	if pull.length() >= 4.0:
		balls[selected].v = pull.normalized() * (strength * 0.0995)
		turn = 1
		ai_pending = true
		ai_timer = 0.75
		status = "התור של הכחול"
	dragging = false
	selected = -1

func ai_shot() -> void:
	var candidates: Array[int] = []
	for i in balls.size():
		if balls[i].alive and balls[i].team == 1: candidates.append(i)
	if candidates.is_empty(): finish_ai_turn(); return
	var shooter := candidates[randi() % candidates.size()]
	var target := Vector2(38.0, [25.0, 104.0, 183.0][randi() % 3])
	var direction: Vector2 = target - balls[shooter].p
	balls[shooter].v = direction.normalized() * randf_range(1.5, 2.7)
	status = "הכחול ירה..."

func finish_ai_turn() -> void:
	turn = 0
	status = "התור שלך — גע בכדור אדום, משוך לאחור ושחרר"

func any_ball_moving() -> bool:
	for ball in balls:
		if ball.alive and ball.v.length_squared() > 0.0001: return true
	return false

func board_to_screen(p: Vector2) -> Vector2:
	# The physics board is portrait-oriented; map it clockwise onto the landscape artwork.
	return board_rect.position + Vector2(
		(BOARD_H - p.y) / BOARD_H * board_rect.size.x,
		p.x / BOARD_W * board_rect.size.y
	)

func screen_to_board(p: Vector2) -> Vector2:
	var local: Vector2 = p - board_rect.position
	return Vector2(
		local.y / board_rect.size.y * BOARD_W,
		BOARD_H - (local.x / board_rect.size.x * BOARD_H)
	)

func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("101a28"))
	draw_rect(Rect2(0, 0, viewport_size.x, 78), Color("17263a"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 42), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("f6d365"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 75), status, HORIZONTAL_ALIGNMENT_LEFT, viewport_size.x - 260, 20, Color.WHITE)
	var button_rect := Rect2(viewport_size.x - 190.0, 24.0, 160.0, 54.0)
	draw_style_box(make_box(Color("ef5350"), 14.0), button_rect)
	draw_string(ThemeDB.fallback_font, button_rect.position + Vector2(29, 35), "משחק חדש", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

	# The approved board is already a landscape texture.
	draw_texture_rect(board_texture, board_rect, false)

	for i in balls.size():
		var ball: Dictionary = balls[i]
		if not ball.alive: continue
		var sp := board_to_screen(ball.p)
		var color := Color("ff5b55") if ball.team == 0 else Color("49a7ff")
		draw_circle(sp + Vector2(0, 4), RADIUS * board_scale * 1.62, Color(0,0,0,0.38))
		draw_circle(sp, RADIUS * board_scale * 1.52, color)
		draw_circle(sp - Vector2(2,2) * board_scale, RADIUS * board_scale * 0.40, Color(1,1,1,0.62))
		var texture := piece_textures[i % piece_textures.size()]
		var size := texture.get_size() * board_scale * 1.45
		draw_texture_rect(texture, Rect2(sp - size * 0.5, size), false, Color(1,1,1,0.7))

	for effect in active_effects:
		var hole: int = effect.hole
		var texture: Texture2D = effects[hole][effect.frame]
		# Effect frames are board patches, not centered sprites. Draw each patch
		# at its original top-left board coordinate using the board transform.
		var effect_scale: Vector2 = Vector2(board_rect.size.y / BOARD_W, board_rect.size.x / BOARD_H)
		draw_set_transform(board_rect.position + Vector2(board_rect.size.x, 0.0), PI / 2.0, effect_scale)
		draw_texture(texture, HOLE_POSITIONS[hole])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	if dragging and selected >= 0:
		var start := board_to_screen(balls[selected].p)
		var end := board_to_screen(drag_point)
		draw_line(start, end, Color("f6d365"), 5.0, true)
		draw_circle(end, 10.0, Color("f6d365"), false, 3.0)
		var launch := start + (start - end).limit_length(150.0)
		draw_line(start, launch, Color(1,1,1,0.7), 3.0, true)

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box
