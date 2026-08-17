extends Node2D

const BOARD_W := 207.0
const BOARD_H := 208.0
const RADIUS := 6.0
const SUBSTEPS := 10
const STEP_TIME := 0.005
const SCORING_HOLE_CENTERS := [
	Vector2(32, 177), Vector2(32, 104), Vector2(32, 30),
	Vector2(174, 30), Vector2(174, 104), Vector2(174, 177)
]
const EFFECT_DURATION := 1.35
const PORTAL_COLORS := [
	Color("ff9f1c"), Color("ff4f87"), Color("9b5de5"),
	Color("00d4ff"), Color("36d399"), Color("ffd166")
]

var piece_textures: Array[Texture2D] = []
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
var status := "Your turn - touch a red ball, pull back and release"
var ai_pending := false
var ai_timer := 0.0

func _ready() -> void:
	for file_name in ["59_id_040.png", "60_id_041.png", "61_id_042.png", "62_id_043.png", "63_id_044.png"]:
		piece_textures.append(load("res://assets/pieces/" + file_name))
	new_game()
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _on_resize() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	# Fill almost the entire landscape play area. Every visual and physics
	# coordinate uses this same rectangle, so stretching cannot misalign holes.
	var play_position := Vector2(12.0, 82.0)
	var available := Vector2(
		maxf(300.0, viewport_size.x - 24.0),
		maxf(220.0, viewport_size.y - 94.0)
	)
	var target_aspect := 2.05
	var play_size := available
	if play_size.x / play_size.y > target_aspect:
		play_size.x = play_size.y * target_aspect
	else:
		play_size.y = play_size.x / target_aspect
	play_position += (available - play_size) * 0.5
	view_origin = play_position
	board_rect = Rect2(play_position, play_size)
	board_scale = minf(board_rect.size.x / BOARD_H, board_rect.size.y / BOARD_W)
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
	status = "Your turn - touch a red ball, pull back and release"
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
	active_effects.append({"hole":hole, "elapsed":0.0})
	status = "Ball scored!"

func update_effects(delta: float) -> void:
	for effect in active_effects:
		effect.elapsed += delta
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].elapsed >= EFFECT_DURATION:
			active_effects.remove_at(i)

func _input(event: InputEvent) -> void:
	# The game is landscape-only. Ignore touches until the device is rotated.
	if get_viewport_rect().size.y > get_viewport_rect().size.x:
		return
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
			status = "Pull back and release"
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
		status = "Blue player's turn"
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
	status = "Blue player shot..."

func finish_ai_turn() -> void:
	turn = 0
	status = "Your turn - touch a red ball, pull back and release"

func any_ball_moving() -> bool:
	for ball in balls:
		if ball.alive and ball.v.length_squared() > 0.0001: return true
	return false

func board_to_screen(p: Vector2) -> Vector2:
	# Rotate the original portrait coordinates clockwise into the landscape board.
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
	if viewport_size.y > viewport_size.x:
		draw_string(ThemeDB.fallback_font, Vector2(0, viewport_size.y * 0.44), "ROTATE YOUR PHONE", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 28, Color("f6d365"))
		draw_string(ThemeDB.fallback_font, Vector2(0, viewport_size.y * 0.50), "Zoopaloola is designed for landscape mode", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 18, Color.WHITE)
		return
	draw_rect(Rect2(0, 0, viewport_size.x, 78), Color("17263a"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 42), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("f6d365"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 75), status, HORIZONTAL_ALIGNMENT_LEFT, viewport_size.x - 260, 20, Color.WHITE)
	var button_rect := Rect2(viewport_size.x - 190.0, 24.0, 160.0, 54.0)
	draw_style_box(make_box(Color("ef5350"), 14.0), button_rect)
	draw_string(ThemeDB.fallback_font, button_rect.position + Vector2(29, 35), "NEW GAME", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

	# Native landscape board. The board, portals, balls, touch input and
	# physics all share board_rect and SCORING_HOLE_CENTERS.
	draw_modern_board()

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
		draw_hole_effect(effect.hole, effect.elapsed / EFFECT_DURATION)

	if dragging and selected >= 0:
		var start := board_to_screen(balls[selected].p)
		var end := board_to_screen(drag_point)
		draw_line(start, end, Color("f6d365"), 5.0, true)
		draw_circle(end, 10.0, Color("f6d365"), false, 3.0)
		var launch := start + (start - end).limit_length(150.0)
		draw_line(start, launch, Color(1,1,1,0.7), 3.0, true)

func draw_modern_board() -> void:
	var shadow := board_rect.grow(-3.0)
	shadow.position += Vector2(0, 8)
	draw_style_box(make_box(Color(0, 0, 0, 0.42), board_rect.size.y * 0.15), shadow)
	draw_style_box(make_box(Color("293746"), board_rect.size.y * 0.15), board_rect)
	var rim := board_rect.grow(-board_rect.size.y * 0.035)
	draw_style_box(make_box(Color("7d8d91"), board_rect.size.y * 0.12), rim)
	var rim_light := rim.grow(-board_rect.size.y * 0.018)
	draw_style_box(make_box(Color("b8c3bd"), board_rect.size.y * 0.10), rim_light)
	var field := board_rect.grow(-board_rect.size.y * 0.105)
	draw_style_box(make_box(Color("67b928"), board_rect.size.y * 0.075), field)
	var inner := field.grow(-board_rect.size.y * 0.025)
	draw_style_box(make_box(Color("5ca921"), board_rect.size.y * 0.055), inner)

	# Subtle arena markings remain crisp at every resolution.
	var line_color := Color(0.82, 1.0, 0.55, 0.18)
	draw_style_box(make_outline_box(line_color, board_rect.size.y * 0.045, 3.0), inner.grow(-board_rect.size.y * 0.06))
	var center := board_rect.get_center()
	draw_arc(center, board_rect.size.y * 0.22, 0.0, TAU, 64, line_color, 3.0, true)
	draw_line(center - Vector2(0, board_rect.size.y * 0.19), center + Vector2(0, board_rect.size.y * 0.19), line_color, 3.0, true)
	draw_string(ThemeDB.fallback_font, center + Vector2(-board_rect.size.x * 0.12, 11), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_CENTER, board_rect.size.x * 0.24, int(board_rect.size.y * 0.055), Color(0.85,1.0,0.6,0.24))

	# The visible portal center is the exact physics scoring center.
	for hole in SCORING_HOLE_CENTERS.size():
		draw_portal(board_to_screen(SCORING_HOLE_CENTERS[hole]), hole)

func draw_portal(center: Vector2, hole: int) -> void:
	var radius := maxf(13.0, board_rect.size.y * 0.043)
	var color: Color = PORTAL_COLORS[hole]
	draw_circle(center + Vector2(0, 4), radius * 1.24, Color(0,0,0,0.35))
	draw_circle(center, radius * 1.22, Color("26323d"))
	draw_circle(center, radius, color.darkened(0.28))
	draw_circle(center, radius * 0.67, Color("111923"))
	draw_arc(center, radius * 0.84, -2.5, -0.25, 18, color.lightened(0.35), maxf(2.0, radius * 0.12), true)
	# A different emblem for every hole; no shared or misplaced patch image.
	match hole:
		0: # fire
			draw_colored_polygon(PackedVector2Array([center+Vector2(0,-radius*0.48), center+Vector2(radius*0.35,radius*0.35), center,center+Vector2(radius*0.55), center+Vector2(-radius*0.35,radius*0.35)]), color)
		1: # cross
			draw_line(center-Vector2(radius*0.42,0), center+Vector2(radius*0.42,0), color, radius*0.22, true)
			draw_line(center-Vector2(0,radius*0.42), center+Vector2(0,radius*0.42), color, radius*0.22, true)
		2: # diamond
			draw_colored_polygon(PackedVector2Array([center+Vector2(0,-radius*0.48),center+Vector2(radius*0.48,0),center+Vector2(0,radius*0.48),center+Vector2(-radius*0.48,0)]), color)
		3: # energy core
			draw_circle(center, radius*0.34, color)
			draw_arc(center, radius*0.48, 0, TAU, 20, Color.WHITE, 2.0, true)
		4: # leaf
			draw_colored_polygon(PackedVector2Array([center+Vector2(-radius*0.42,radius*0.28),center+Vector2(radius*0.42,-radius*0.38),center+Vector2(radius*0.25,radius*0.34)]), color)
		5: # star
			var points := PackedVector2Array()
			for i in 10:
				var r := radius * (0.48 if i % 2 == 0 else 0.22)
				points.append(center + Vector2.UP.rotated(i * PI / 5.0) * r)
			draw_colored_polygon(points, color)

func draw_hole_effect(hole: int, progress: float) -> void:
	var center := board_to_screen(SCORING_HOLE_CENTERS[hole])
	var color: Color = PORTAL_COLORS[hole]
	var fade := 1.0 - progress
	var base := maxf(18.0, board_rect.size.y * 0.052)
	# Transparent, centered particles and rings. Each hole gets its own motion.
	for ring in 3:
		var phase := fmod(progress * (1.5 + hole * 0.08) + ring * 0.24, 1.0)
		var ring_color := Color(color.r, color.g, color.b, (1.0-phase) * fade * 0.8)
		draw_arc(center, base * (0.8 + phase * 2.4), 0, TAU, 40, ring_color, maxf(2.0, base * 0.10), true)
	var particles := 5 + hole
	for i in particles:
		var angle := i * TAU / particles + progress * (2.0 + hole * 0.35)
		var distance := base * (0.5 + progress * (1.6 + (i % 3) * 0.25))
		var particle := center + Vector2.RIGHT.rotated(angle) * distance
		draw_circle(particle, base * 0.12 * fade + 1.0, Color(color.r,color.g,color.b,fade))

func make_outline_box(color: Color, radius: float, width: float) -> StyleBoxFlat:
	var box := make_box(Color(0,0,0,0), radius)
	box.border_color = color
	box.border_width_left = int(width)
	box.border_width_top = int(width)
	box.border_width_right = int(width)
	box.border_width_bottom = int(width)
	return box

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box
