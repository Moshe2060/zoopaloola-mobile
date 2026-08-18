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
const RUBBER_TRAP_HOLE := 0
const PRESS_TRAP_HOLE := 1
const ICE_TRAP_HOLE := 4
const FIRE_TRAP_HOLE := 5
const ELECTRIC_TRAP_HOLE := 2
const TRAP_CAPTURE_TIME := 2.35
const TRAP_FALL_TIME := 2.85
const PRESS_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const ICE_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const FIRE_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const ELECTRIC_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const RUBBER_CAPTURE_TIME := TRAP_CAPTURE_TIME
const RUBBER_FALL_TIME := TRAP_FALL_TIME
const RUBBER_EFFECT_DURATION := RUBBER_CAPTURE_TIME + RUBBER_FALL_TIME
var board_texture: Texture2D
var piece_textures: Array[Texture2D] = []
var effect_textures: Array[Texture2D] = []
var rubber_ball_texture: Texture2D
var rubber_hand_textures: Array[Texture2D] = []
var balls: Array = []
var active_effects: Array = []
var contacts := {}

# Touch-friendly rubber effect editor. Values are stored in board-image units.
var effect_editor_enabled := false
var editor_selected_hand := 0
var rubber_top_offset := Vector2(-60.0, -10.0)
var rubber_side_offset := Vector2(20.0, 20.0)
var rubber_top_width := 72.0
var rubber_side_width := 72.0
var rubber_top_rotation := deg_to_rad(-20.0)
var rubber_side_rotation := deg_to_rad(-5.0)
var rubber_top_mirror := false
var rubber_side_mirror := false
# Mobile browsers may emit a synthetic mouse click after every touch.
# Once real touch input is seen, ignore those duplicate mouse events.
var touchscreen_input_seen := false

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
	board_texture = load("res://assets/board-original-clean.png") as Texture2D
	if board_texture == null:
		push_error("Clean original board could not be loaded.")
	for file_name in ["59_id_040.png", "60_id_041.png", "61_id_042.png", "62_id_043.png", "63_id_044.png"]:
		piece_textures.append(load("res://assets/pieces/" + file_name))
	for i in 6:
		effect_textures.append(load("res://assets/remastered_effects/effect-%d.png" % i))
	rubber_ball_texture = load("res://assets/rubber_trap/rubber-ball.png") as Texture2D
	for i in 5:
		rubber_hand_textures.append(load("res://assets/rubber_trap/hands/pose-%d.png" % i))
	new_game()
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _on_resize() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	# Fill almost the entire landscape play area. Every visual and physics
	# coordinate uses this same rectangle, so stretching cannot misalign holes.
	# Let the board extend slightly beyond the top and bottom edges. This keeps
	# its real 2:1 proportions while making it fill modern wide phone screens.
	# Keep a small safe margin around the board so edge weapons remain visible
	# and touchable on phones with browser/system controls.
	var safe_margin := Vector2(22.0, 18.0)
	var play_position := safe_margin
	var available := Vector2(
		maxf(300.0, viewport_size.x - safe_margin.x * 2.0),
		maxf(220.0, viewport_size.y - safe_margin.y * 2.0)
	)
	# Match the clean original board exactly (1829 x 860).
	var target_aspect := 1829.0 / 860.0
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
	if ai_pending and active_effects.is_empty():
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
	var scored_team: int = balls[index].team
	balls[index].alive = false
	balls[index].v = Vector2.ZERO
	active_effects.append({"hole":hole, "elapsed":0.0, "team":scored_team, "piece":index})
	status = "Ball scored!"

func update_effects(delta: float) -> void:
	for effect in active_effects:
		effect.elapsed += delta
	for i in range(active_effects.size() - 1, -1, -1):
		var duration := EFFECT_DURATION
		if active_effects[i].hole == RUBBER_TRAP_HOLE:
			duration = RUBBER_EFFECT_DURATION
		elif active_effects[i].hole == PRESS_TRAP_HOLE:
			duration = PRESS_EFFECT_DURATION
		elif active_effects[i].hole == ICE_TRAP_HOLE:
			duration = ICE_EFFECT_DURATION
		elif active_effects[i].hole == FIRE_TRAP_HOLE:
			duration = FIRE_EFFECT_DURATION
		elif active_effects[i].hole == ELECTRIC_TRAP_HOLE:
			duration = ELECTRIC_EFFECT_DURATION
		if active_effects[i].elapsed >= duration:
			active_effects.remove_at(i)

func _input(event: InputEvent) -> void:
	# The game is landscape-only. Ignore touches until the device is rotated.
	if get_viewport_rect().size.y > get_viewport_rect().size.x:
		return
	if event is InputEventScreenTouch:
		touchscreen_input_seen = true
		if event.pressed: pointer_down(event.position)
		else: pointer_up(event.position)
	elif event is InputEventScreenDrag:
		touchscreen_input_seen = true
		pointer_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not touchscreen_input_seen:
		if event.pressed: pointer_down(event.position)
		else: pointer_up(event.position)
	elif event is InputEventMouseMotion and not touchscreen_input_seen and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pointer_move(event.position)

func pointer_down(screen_pos: Vector2) -> void:
	if handle_effect_editor_touch(screen_pos):
		return
	if Rect2(get_viewport_rect().size.x - 174.0, 6.0, 150.0, 42.0).has_point(screen_pos):
		new_game(); return
	if turn != 0 or any_ball_moving() or not active_effects.is_empty(): return
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
	# Approved faithful remaster, created natively in landscape.
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
		if effect.hole == RUBBER_TRAP_HOLE:
			draw_rubber_trap(effect)
		elif effect.hole == PRESS_TRAP_HOLE:
			draw_press_trap(effect)
		elif effect.hole == ICE_TRAP_HOLE:
			draw_ice_trap(effect)
		elif effect.hole == FIRE_TRAP_HOLE:
			draw_fire_trap(effect)
		elif effect.hole == ELECTRIC_TRAP_HOLE:
			draw_electric_trap(effect)
		else:
			draw_hole_effect(effect.hole, effect.elapsed / EFFECT_DURATION)

	if dragging and selected >= 0:
		var start := board_to_screen(balls[selected].p)
		var end := board_to_screen(drag_point)
		draw_line(start, end, Color("f6d365"), 5.0, true)
		draw_circle(end, 10.0, Color("f6d365"), false, 3.0)
		var launch := start + (start - end).limit_length(150.0)
		draw_line(start, launch, Color(1,1,1,0.7), 3.0, true)

	draw_hud(viewport_size)
	draw_effect_editor(viewport_size)

func draw_hud(viewport_size: Vector2) -> void:
	# Overlay the compact HUD so it no longer reserves valuable board height.
	draw_rect(Rect2(0, 0, viewport_size.x, 54), Color(0.09, 0.15, 0.23, 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(18, 33), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f6d365"))
	draw_string(ThemeDB.fallback_font, Vector2(200, 34), status, HORIZONTAL_ALIGNMENT_LEFT, viewport_size.x - 390, 17, Color.WHITE)
	var edit_rect := Rect2(viewport_size.x - 334.0, 6.0, 145.0, 42.0)
	draw_style_box(make_box(Color("7256d8") if effect_editor_enabled else Color("34495e"), 14.0), edit_rect)
	draw_string(ThemeDB.fallback_font, edit_rect.position + Vector2(19, 28), "EDIT EFFECT", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var button_rect := Rect2(viewport_size.x - 174.0, 6.0, 150.0, 42.0)
	draw_style_box(make_box(Color("ef5350"), 14.0), button_rect)
	draw_string(ThemeDB.fallback_font, button_rect.position + Vector2(25, 28), "NEW GAME", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

func draw_hole_effect(hole: int, progress: float) -> void:
	var center := board_to_screen(SCORING_HOLE_CENTERS[hole])
	var texture: Texture2D = effect_textures[hole]
	if texture == null:
		return
	var appear := clampf(progress / 0.16, 0.0, 1.0)
	var disappear := clampf((1.0 - progress) / 0.22, 0.0, 1.0)
	var alpha := minf(appear, disappear)
	var pulse := 0.82 + sin(progress * PI) * 0.28
	var max_size := board_rect.size.y * (0.31 if hole in [0, 3, 4] else 0.24)
	var source_size := texture.get_size()
	var scale_factor := max_size / maxf(source_size.x, source_size.y) * pulse
	var size := source_size * scale_factor
	var rotation := sin(progress * TAU * 1.4) * 0.035
	# Hole 2 received the trap from the opposite side, so mirror its artwork.
	var effect_scale := Vector2(-1.0, 1.0) if hole == 2 else Vector2.ONE
	draw_set_transform(center, rotation, effect_scale)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1,1,1,alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func press_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1276.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func draw_press_rod(anchor_x: float, y: float, tip_x: float, left_side: bool, compression: float) -> void:
	var anchor := press_point(anchor_x, y)
	var tip := press_point(tip_x, y)
	var direction := 1.0 if left_side else -1.0
	var unit_x := board_rect.size.x / 1276.0
	var unit_y := board_rect.size.y / 600.0
	var rod_end := tip - Vector2(direction * 8.0 * unit_x, 0.0)
	draw_line(anchor, rod_end, Color("374957"), 14.0 * unit_y, true)
	draw_line(anchor - Vector2(0, 1.5 * unit_y), rod_end - Vector2(0, 1.5 * unit_y), Color("a9bdc6"), 7.0 * unit_y, true)
	var plate_size := Vector2(16.0 * unit_x, 46.0 * unit_y)
	draw_style_box(make_box(Color("384b57"), 4.0 * unit_y), Rect2(tip - plate_size * 0.5, plate_size))
	var glow_width := 6.0 * unit_x
	var glow_rect := Rect2(tip.x - glow_width * 0.5, tip.y - 19.0 * unit_y, glow_width, 38.0 * unit_y)
	draw_rect(glow_rect, Color(1.0, 0.36, 0.59, 0.34 * compression))

func draw_press_ball(center: Vector2, radius: float, rx_scale: float, ry_scale: float, rotation: float, team: int, piece: int, alpha: float) -> void:
	draw_set_transform(center, rotation, Vector2(rx_scale, ry_scale))
	draw_rubber_game_ball(Vector2.ZERO, radius, team, piece, alpha)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_press_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var cx := 621.0
	var cy := 55.0
	var radius := 26.0
	# The physics ball has already crossed the scoring boundary. Start the
	# animated press ball directly in the opening; never replay a pull from the grass.
	var ball_y := cy
	var rx_scale := 1.0
	var ry_scale := 1.0
	var rotation := 0.0
	# Do not show a duplicate effect ball while the pistons approach. It appears
	# only at the fixed crushing point, eliminating any perceived pull from the grass.
	var alpha := 0.0
	var extend := 0.0
	var retract := 0.0
	extend = smooth_step(seconds / 0.78)
	alpha = smooth_step((extend - 0.52) / 0.12)
	if seconds >= 1.17:
		retract = smooth_step((seconds - 1.17) / 0.62)
	var squeeze := clampf((extend - 0.57) / 0.43, 0.0, 1.0)
	var arm_amount := extend * (1.0 - retract)
	var compressed_rx := lerpf(radius, radius * 0.16, squeeze)
	var left_tip := lerpf(546.0, cx - compressed_rx - 9.0, arm_amount)
	var right_tip := lerpf(695.0, cx + compressed_rx + 9.0, arm_amount)
	rx_scale = lerpf(1.0, 0.16, squeeze)
	ry_scale = lerpf(1.0, 1.10, squeeze)
	if seconds >= 1.79:
		rx_scale = 0.16
		ry_scale = 1.10
		var wait := clampf((seconds - 1.79) / (TRAP_CAPTURE_TIME - 1.79), 0.0, 1.0)
		var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
		var motion := release * release
		rotation = sin(wait * PI) * 0.045 - motion * 0.34
		ball_y = cy - lerpf(0.0, 176.0, motion)
		alpha = 1.0 - release * 0.08
		var shrink := 1.0 - release * 0.30
		rx_scale *= shrink
		ry_scale *= shrink
	if arm_amount > 0.01:
		draw_press_rod(546.0, cy, left_tip, true, squeeze)
		draw_press_rod(695.0, cy, right_tip, false, squeeze)
	var radius_screen := radius * board_rect.size.y / 600.0
	draw_press_ball(press_point(cx, ball_y), radius_screen, rx_scale, ry_scale, rotation, effect.team, effect.piece, alpha)

func electric_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func draw_electric_arc(start: Vector2, finish: Vector2, phase: float, alpha: float, width: float) -> void:
	var points := PackedVector2Array()
	var delta := finish - start
	var normal := delta.normalized().orthogonal() if delta.length_squared() > 0.01 else Vector2.UP
	for i in 11:
		var t := float(i) / 10.0
		var jitter := 0.0
		if i > 0 and i < 10:
			jitter = sin(float(i) * 12.73 + phase * 19.0) * width * 2.2
			jitter += cos(float(i) * 7.31 + phase * 11.0) * width
		points.append(start.lerp(finish, t) + normal * jitter)
	draw_polyline(points, Color(0.72, 0.93, 1.0, alpha * 0.52), width * 2.4, true)
	draw_polyline(points, Color(0.96, 1.0, 1.0, alpha), width, true)

func draw_electric_probe(anchor: Vector2, tip: Vector2, power: float, scale_y: float) -> void:
	draw_line(anchor, tip, Color("334650"), 13.0 * scale_y, true)
	draw_line(anchor, tip, Color("a9bbc2"), 6.0 * scale_y, true)
	var head_size := Vector2(16.0, 34.0) * scale_y
	draw_style_box(make_box(Color("344b57"), 4.0 * scale_y), Rect2(tip - head_size * 0.5, head_size))
	draw_circle(tip, 5.0 * scale_y, Color(0.77, 0.97, 1.0, 0.55 + power * 0.4))

func draw_electric_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	# The two fixed weapons surrounding the upper-right opening.
	var top_weapon := electric_point(965.0, 63.0)
	var right_weapon := electric_point(1125.0, 145.0)
	var shock_point := electric_point(1072.0, 104.0)
	var radius := 27.0 * scale_y
	var charge := smooth_step(seconds / 0.62)
	var charge_fade := 1.0 - smooth_step((seconds - 1.55) / 0.36)
	var beam_power := charge * charge_fade
	var electrified := smooth_step((seconds - 0.18) / 0.68)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := shock_point
	var ball_radius := radius
	var alpha := 1.0

	if release > 0.0:
		# Fall out through the nearby upper-right opening while remaining charged.
		var fall := release * release
		center = shock_point.lerp(electric_point(1198.0, 22.0), fall)
		center.y -= sin(release * PI) * 7.0 * scale_y
		ball_radius *= 1.0 - release * 0.34
		alpha = 1.0 - release * 0.10

	# Both weapons fire only short local bolts directly into the ball.
	if beam_power > 0.01 and release <= 0.0:
		for i in 3:
			draw_electric_arc(top_weapon, shock_point + Vector2((-8.0 + i * 8.0), -radius * 0.45) , seconds * 1.7 + float(i) * 0.33, beam_power * (0.82 - float(i) * 0.16), maxf(1.2, (3.0 - float(i) * 0.55) * scale_y))
			draw_electric_arc(right_weapon, shock_point + Vector2(radius * 0.46, (-8.0 + i * 8.0)), seconds * 1.9 + float(i) * 0.41, beam_power * (0.82 - float(i) * 0.16), maxf(1.2, (3.0 - float(i) * 0.55) * scale_y))

	# Keep the real character ball visible under the electric glow.
	var shake := Vector2.ZERO
	if electrified > 0.05 and release <= 0.0:
		shake = Vector2(sin(seconds * 43.0), cos(seconds * 37.0)) * 2.5 * scale_y * electrified
	draw_rubber_game_ball(center + shake, ball_radius, effect.team, effect.piece, alpha)

	# Compact lightning remains wrapped around the ball, including during its fall.
	var local_power := electrified * (1.0 - release * 0.18)
	if local_power > 0.01:
		draw_circle(center + shake, ball_radius * (1.30 + sin(seconds * 24.0) * 0.07), Color(0.58, 0.90, 1.0, 0.20 * local_power * alpha))
		for i in 8:
			var a := TAU * float(i) / 8.0 + seconds * (2.1 + float(i % 3) * 0.2)
			var inner := center + shake + Vector2(cos(a), sin(a)) * ball_radius * 0.72
			var outer_angle := a + sin(seconds * 17.0 + float(i)) * 0.28
			var outer := center + shake + Vector2(cos(outer_angle), sin(outer_angle)) * ball_radius * (1.22 + 0.18 * sin(seconds * 21.0 + float(i)))
			draw_electric_arc(inner, outer, seconds * 1.4 + float(i), local_power * alpha * 0.82, maxf(1.0, 1.7 * scale_y))


func fire_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func draw_fire_stream(origin: Vector2, target: Vector2, amount: float, seed_offset: float) -> void:
	if amount <= 0.01:
		return
	var end := origin.lerp(target, amount)
	var direction := end - origin
	if direction.length_squared() < 0.01:
		return
	var normal := direction.normalized().orthogonal()
	var scale_y := board_rect.size.y / 600.0
	draw_line(origin, end, Color(1.0, 0.18, 0.01, 0.72), 18.0 * scale_y, true)
	draw_line(origin, end, Color(1.0, 0.58, 0.03, 0.92), 10.0 * scale_y, true)
	draw_line(origin, end, Color(1.0, 0.94, 0.28, 0.94), 4.0 * scale_y, true)
	for i in 17:
		var phase := fmod(float(i) / 16.0 + seed_offset + amount * 1.1, 1.0)
		if phase > amount:
			continue
		var p := origin.lerp(target, phase)
		var wave := sin(phase * 34.0 + seed_offset * 19.0) * 9.0 * scale_y
		p += normal * wave
		var r := (3.0 + float(i % 4) * 1.5) * scale_y
		var flame_color := Color(1.0, 0.25 + 0.16 * float(i % 3), 0.01, 0.88)
		draw_circle(p, r, flame_color)

func draw_burning_ball(center: Vector2, radius: float, burn: float, team: int, piece: int, alpha: float) -> void:
	draw_rubber_game_ball(center, radius, team, piece, (1.0 - burn * 0.88) * alpha)
	var ember_radius := radius * lerpf(0.76, 1.08, burn)
	draw_circle(center, ember_radius * 1.18, Color(1.0, 0.20, 0.01, 0.42 * burn * alpha))
	draw_circle(center, ember_radius, Color(0.055, 0.035, 0.025, burn * alpha))
	draw_arc(center, ember_radius, 0.0, TAU, 40, Color(1.0, 0.34, 0.02, burn * alpha), maxf(2.0, radius * 0.13), true)
	for i in 9:
		var a := TAU * float(i) / 9.0 + sin(float(i) * 2.7) * 0.25
		var base := center + Vector2(cos(a), sin(a)) * ember_radius * 0.72
		var flicker := (7.0 + 6.0 * sin(Time.get_ticks_msec() * 0.012 + float(i))) * burn
		var tip := base + Vector2(cos(a), sin(a)) * flicker
		draw_line(base, tip, Color(1.0, 0.32 + 0.28 * float(i % 2), 0.01, burn * alpha), maxf(2.0, radius * 0.12), true)
	for i in 5:
		var a := float(i) * 1.91 + 0.4
		var crack_a := center + Vector2(cos(a), sin(a)) * ember_radius * 0.15
		var crack_b := center + Vector2(cos(a + 0.28), sin(a + 0.28)) * ember_radius * 0.68
		draw_line(crack_a, crack_b, Color(1.0, 0.29, 0.01, 0.78 * burn * alpha), maxf(1.0, radius * 0.055), true)

func draw_fire_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var left_weapon := fire_point(78.0, 492.0)
	var bottom_weapon := fire_point(188.0, 565.0)
	var burn_point := fire_point(112.0, 536.0)
	var radius := 27.0 * scale_y
	var ignition := smooth_step(seconds / 0.72)
	var burn := smooth_step((seconds - 0.18) / 1.22)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := burn_point
	var alpha := 1.0
	if release > 0.0:
		var gravity_fall := release * release
		center += Vector2(-82.0, 155.0) * scale_y * gravity_fall
		center.x += sin(release * PI) * -7.0 * scale_y
		radius *= 1.0 - release * 0.30
		alpha = 1.0 - release * 0.10
	if seconds < 1.72:
		var stream_strength := ignition * (1.0 - smooth_step((seconds - 1.34) / 0.38))
		draw_fire_stream(left_weapon, burn_point, stream_strength, 0.17)
		draw_fire_stream(bottom_weapon, burn_point, stream_strength, 0.63)
	draw_burning_ball(center, radius, burn, effect.team, effect.piece, alpha)

func ice_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func draw_ice_stream(origin: Vector2, target: Vector2, amount: float, seed_offset: float) -> void:
	if amount <= 0.01:
		return
	var direction := target - origin
	var normal := direction.normalized().orthogonal()
	var end := origin.lerp(target, amount)
	var width := maxf(2.0, board_rect.size.y / 600.0 * 7.0)
	draw_line(origin, end, Color(0.67, 0.93, 1.0, 0.46), width * 2.1, true)
	draw_line(origin, end, Color(0.92, 0.99, 1.0, 0.94), width, true)
	for i in 13:
		var phase := fmod(float(i) / 12.0 + seed_offset + amount * 0.9, 1.0)
		if phase > amount:
			continue
		var p := origin.lerp(target, phase)
		var wobble := sin(phase * 31.0 + seed_offset * 17.0) * width * 1.3
		p += normal * wobble
		var particle_radius := width * (0.38 + float(i % 3) * 0.16)
		draw_circle(p, particle_radius, Color(0.82, 0.97, 1.0, 0.88))

func draw_ice_shell(center: Vector2, radius: float, amount: float, alpha: float = 1.0) -> void:
	if amount <= 0.01:
		return
	var shell_radius := radius * lerpf(0.72, 1.32, amount)
	var points := PackedVector2Array()
	for i in 16:
		var angle := TAU * float(i) / 16.0
		var jag := 1.0 + (0.10 if i % 2 == 0 else -0.04) * amount
		points.append(center + Vector2(cos(angle), sin(angle)) * shell_radius * jag)
	draw_colored_polygon(points, Color(0.64, 0.91, 1.0, (0.18 + amount * 0.46) * alpha))
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, Color(0.88, 0.98, 1.0, 0.92 * alpha), maxf(2.0, radius * 0.09), true)
	for i in 7:
		var a := float(i) * 2.21 + amount
		var inner := center + Vector2(cos(a), sin(a)) * shell_radius * 0.28
		var outer := center + Vector2(cos(a + 0.22), sin(a + 0.22)) * shell_radius * (0.58 + 0.28 * amount)
		draw_line(inner, outer, Color(0.90, 0.99, 1.0, 0.72 * amount * alpha), maxf(1.0, radius * 0.055), true)

func draw_ice_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var left_weapon := ice_point(470.0, 565.0)
	var right_weapon := ice_point(730.0, 565.0)
	var freeze_point := ice_point(600.0, 548.0)
	var radius := 27.0 * scale_y
	var spray := smooth_step(seconds / 0.82)
	var freeze := smooth_step((seconds - 0.22) / 1.18)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := freeze_point
	var alpha := 1.0
	if release > 0.0:
		var gravity_fall := release * release
		center.y += gravity_fall * 190.0 * scale_y
		center.x += sin(release * PI) * 5.0 * scale_y
		radius *= 1.0 - release * 0.28
		alpha = 1.0 - release * 0.12
	if seconds < 1.65:
		var stream_strength := spray * (1.0 - smooth_step((seconds - 1.28) / 0.37))
		draw_ice_stream(left_weapon, freeze_point, stream_strength, 0.13)
		draw_ice_stream(right_weapon, freeze_point, stream_strength, 0.61)
	draw_rubber_game_ball(center, radius, effect.team, effect.piece, 1.0 - freeze * 0.58)
	draw_ice_shell(center, radius, freeze, alpha)
	if freeze > 0.55 and release <= 0.0:
		var sparkle := 0.55 + sin(seconds * 18.0) * 0.35
		for i in 6:
			var a := TAU * float(i) / 6.0 + seconds * 0.7
			var p := center + Vector2(cos(a), sin(a)) * radius * 1.48
			draw_circle(p, maxf(1.5, 2.4 * scale_y), Color(0.91, 1.0, 1.0, sparkle))

func rubber_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func smooth_step(value: float) -> float:
	var v := clampf(value, 0.0, 1.0)
	return v * v * (3.0 - 2.0 * v)

func rubber_hand_pose(value: float) -> int:
	if value < 0.25: return 0
	if value < 0.48: return 1
	if value < 0.68: return 2
	if value < 0.86: return 3
	return 4

func draw_rubber_game_ball(position: Vector2, radius: float, team: int, piece: int, alpha: float) -> void:
	var color := Color("ff5b55") if team == 0 else Color("49a7ff")
	draw_circle(position + Vector2(radius * 0.09, radius * 0.15), radius * 1.08, Color(0, 0, 0, 0.32 * alpha))
	draw_circle(position, radius, Color(color, alpha))
	draw_arc(position, radius, 0.0, TAU, 48, Color(0.43, 0.07, 0.15, alpha), maxf(1.0, radius * 0.13), true)
	if not piece_textures.is_empty():
		var texture := piece_textures[piece % piece_textures.size()]
		var size := Vector2.ONE * radius * 1.58
		draw_texture_rect(texture, Rect2(position - size * 0.5, size), false, Color(1, 1, 1, alpha * 0.76))

func draw_rubber_hand(texture: Texture2D, anchor: Vector2, target: Vector2, width: float, mirror: bool, alpha: float = 1.0, rotation_offset: float = 0.0) -> void:
	if texture == null: return
	var delta := target - anchor
	# Fit the arm to the actual weapon-to-ball distance. The former large
	# minimum made short upper-left arms overshoot the hole and leave the board.
	var height := maxf(width * 1.02, delta.length() * 1.04)
	var angle := delta.angle() + PI * 0.5 + rotation_offset
	draw_set_transform(anchor, angle, Vector2(-1.0 if mirror else 1.0, 1.0))
	draw_texture_rect(texture, Rect2(-width * 0.5, -height, width, height), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_rubber_wrap(position: Vector2, radius: float, amount: float, spin: float) -> void:
	var count := int(floor(amount * 12.0))
	for i in count:
		var points := PackedVector2Array()
		var ellipse_angle := i * 0.91 + spin
		var rx := radius * (0.55 + (i % 3) * 0.12)
		var ry := radius * (0.28 + (i % 4) * 0.08)
		for step in 33:
			var a := TAU * step / 32.0
			var local := Vector2(cos(a) * rx, sin(a) * ry).rotated(ellipse_angle)
			points.append(position + local)
		draw_polyline(points, Color("f7f5ed"), maxf(3.0, radius * 0.13), true)

func draw_rubber_trap(effect: Dictionary) -> void:
	if rubber_ball_texture == null or rubber_hand_textures.size() < 5: return
	var elapsed: float = effect.elapsed
	var t := elapsed / RUBBER_CAPTURE_TIME
	var scale_y := board_rect.size.y / 600.0
	# The rubber-hand weapon is at the upper-left opening on the clean board.
	# These points mirror the former upper-right placement across the board.
	var anchor_top := rubber_point(235, 63) + rubber_top_offset * scale_y
	var anchor_left := rubber_point(75, 145) + rubber_side_offset * scale_y
	var capture := rubber_point(128, 104)
	var ball_radius := 34.0 * scale_y
	# The real gameplay ball has already entered this hole. Start the trap at
	# the capture point so the V4 preview's staged entry is not replayed.
	var ball := capture
	var reach := smooth_step((t - 0.10) / 0.28)
	var hold := clampf((t - 0.32) / 0.38, 0.0, 1.0)
	var wrap := clampf((t - 0.40) / 0.34, 0.0, 1.0)
	var team: int = effect.team
	var piece: int = effect.piece
	if elapsed < RUBBER_CAPTURE_TIME:
		# Mirror the grip paths as well as the artwork: the upper hand now
		# approaches the ball's right side and the side hand its left side.
		var target_1 := ball + Vector2((15.0 - sin(t * 36.0) * 5.0 * hold) * scale_y, (-7.0 + cos(t * 31.0) * 5.0 * hold) * scale_y)
		var target_2 := ball + Vector2((-15.0 + sin(t * 34.0) * 5.0 * hold) * scale_y, (10.0 - cos(t * 29.0) * 5.0 * hold) * scale_y)
		var point_1 := anchor_top.lerp(target_1, reach)
		var point_2 := anchor_left.lerp(target_2, reach)
		var focus := wrap * (1.0 - wrap * 0.45)
		draw_circle(ball, ball_radius * (1.45 + sin(t * 45.0) * 0.08), Color(1.0, 0.965, 0.72, 0.28 * focus))
		draw_rubber_game_ball(ball, ball_radius * (1.0 + sin(t * 40.0) * 0.025 * focus), team, piece, 1.0 - wrap * 0.72)
		if wrap > 0.0: draw_rubber_wrap(ball, ball_radius * 1.05, wrap, t * 20.0)
		var pose := rubber_hand_pose(hold)
		# Reveal the hands from inside their weapons. Drawing the full-width sprite
		# at reach=0 made a complete hand appear before it started extending.
		var hand_emerge := smooth_step(reach / 0.42)
		if hand_emerge > 0.02:
			draw_rubber_hand(rubber_hand_textures[pose], anchor_top, point_1, rubber_top_width * scale_y * hand_emerge, rubber_top_mirror, hand_emerge, rubber_top_rotation)
			draw_rubber_hand(rubber_hand_textures[pose], anchor_left, point_2, rubber_side_width * scale_y * hand_emerge, rubber_side_mirror, hand_emerge, rubber_side_rotation)
	else:
		var release := smooth_step((elapsed - RUBBER_CAPTURE_TIME) / RUBBER_FALL_TIME)
		var fall := release * release
		var out := rubber_point(2, 22)
		ball = capture.lerp(out, fall)
		ball_radius *= 1.0 - release * 0.42
		var retract := 1.0 - clampf(release / 0.32, 0.0, 1.0)
		var point_1 := anchor_top.lerp(capture + Vector2(15, -7) * scale_y, retract)
		var point_2 := anchor_left.lerp(capture + Vector2(-15, 10) * scale_y, retract)
		if retract > 0.08:
			draw_rubber_hand(rubber_hand_textures[4], anchor_top, point_1, rubber_top_width * scale_y, rubber_top_mirror, retract, rubber_top_rotation)
			draw_rubber_hand(rubber_hand_textures[4], anchor_left, point_2, rubber_side_width * scale_y, rubber_side_mirror, retract, rubber_side_rotation)
		draw_set_transform(ball, fall * 3.2, Vector2.ONE)
		draw_texture_rect(rubber_ball_texture, Rect2(-Vector2.ONE * ball_radius, Vector2.ONE * ball_radius * 2.0), false, Color(1, 1, 1, 1.0 - release * 0.05))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func editor_panel_rect(viewport_size: Vector2) -> Rect2:
	# Keep the upper-left trap fully visible while editing. Touch duplication is
	# handled separately, so the bottom panel remains usable on mobile.
	var panel_width := minf(980.0, viewport_size.x - 24.0)
	return Rect2((viewport_size.x - panel_width) * 0.5, viewport_size.y - 162.0, panel_width, 150.0)

func editor_button(index: int, viewport_size: Vector2) -> Rect2:
	var panel := editor_panel_rect(viewport_size)
	var button_w := (panel.size.x - 22.0) / 11.0
	return Rect2(panel.position + Vector2(6.0 + index * button_w, 82.0), Vector2(button_w - 4.0, 56.0))

func handle_effect_editor_touch(screen_pos: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	var toggle := Rect2(viewport_size.x - 334.0, 6.0, 145.0, 42.0)
	if toggle.has_point(screen_pos):
		effect_editor_enabled = not effect_editor_enabled
		if effect_editor_enabled:
			replay_rubber_editor()
		queue_redraw()
		return true
	if not effect_editor_enabled:
		return false
	for i in 11:
		if not editor_button(i, viewport_size).has_point(screen_pos):
			continue
		match i:
			0: editor_selected_hand = 0
			1: editor_selected_hand = 1
			2: change_editor_offset(Vector2(-5, 0))
			3: change_editor_offset(Vector2(5, 0))
			4: change_editor_offset(Vector2(0, -5))
			5: change_editor_offset(Vector2(0, 5))
			6: change_editor_width(-4.0)
			7: change_editor_width(4.0)
			8: change_editor_rotation(deg_to_rad(-5.0))
			9: change_editor_rotation(deg_to_rad(5.0))
			10: toggle_editor_mirror()
		replay_rubber_editor()
		queue_redraw()
		return true
	var replay_rect := Rect2(editor_panel_rect(viewport_size).position + Vector2(6, 8), Vector2(100, 46))
	var copy_rect := Rect2(editor_panel_rect(viewport_size).position + Vector2(114, 8), Vector2(132, 46))
	var preset_a_rect := Rect2(editor_panel_rect(viewport_size).position + Vector2(254, 8), Vector2(112, 46))
	var preset_b_rect := Rect2(editor_panel_rect(viewport_size).position + Vector2(374, 8), Vector2(112, 46))
	if replay_rect.has_point(screen_pos):
		replay_rubber_editor()
		return true
	if copy_rect.has_point(screen_pos):
		DisplayServer.clipboard_set(editor_settings_text())
		status = "Effect settings copied"
		queue_redraw()
		return true
	if preset_a_rect.has_point(screen_pos):
		apply_rubber_preset_a()
		replay_rubber_editor()
		return true
	if preset_b_rect.has_point(screen_pos):
		apply_rubber_preset_b()
		replay_rubber_editor()
		return true
	return editor_panel_rect(viewport_size).has_point(screen_pos)

func change_editor_offset(amount: Vector2) -> void:
	if editor_selected_hand == 0:
		rubber_top_offset += amount
	else:
		rubber_side_offset += amount

func change_editor_width(amount: float) -> void:
	if editor_selected_hand == 0:
		rubber_top_width = clampf(rubber_top_width + amount, 20.0, 100.0)
	else:
		rubber_side_width = clampf(rubber_side_width + amount, 20.0, 100.0)

func change_editor_rotation(amount: float) -> void:
	if editor_selected_hand == 0:
		rubber_top_rotation += amount
	else:
		rubber_side_rotation += amount

func toggle_editor_mirror() -> void:
	if editor_selected_hand == 0:
		rubber_top_mirror = not rubber_top_mirror
	else:
		rubber_side_mirror = not rubber_side_mirror

func apply_rubber_preset_a() -> void:
	rubber_top_offset = Vector2(-60.0, -10.0)
	rubber_side_offset = Vector2(20.0, 20.0)
	rubber_top_width = 72.0
	rubber_side_width = 72.0
	rubber_top_rotation = deg_to_rad(-20.0)
	rubber_side_rotation = deg_to_rad(-5.0)
	rubber_top_mirror = false
	rubber_side_mirror = false
	status = "Rubber preset A"

func apply_rubber_preset_b() -> void:
	rubber_top_offset = Vector2(-40.0, 25.0)
	rubber_side_offset = Vector2(10.0, -20.0)
	rubber_top_width = 72.0
	rubber_side_width = 72.0
	rubber_top_rotation = deg_to_rad(-175.0)
	rubber_side_rotation = deg_to_rad(-165.0)
	rubber_top_mirror = true
	rubber_side_mirror = true
	status = "Rubber preset B"

func replay_rubber_editor() -> void:
	active_effects.clear()
	active_effects.append({"hole":RUBBER_TRAP_HOLE, "elapsed":0.0, "team":0, "piece":0})

func editor_settings_text() -> String:
	return "top_offset=%s; side_offset=%s; top_width=%.1f; side_width=%.1f; top_rotation_deg=%.1f; side_rotation_deg=%.1f; top_mirror=%s; side_mirror=%s" % [rubber_top_offset, rubber_side_offset, rubber_top_width, rubber_side_width, rad_to_deg(rubber_top_rotation), rad_to_deg(rubber_side_rotation), rubber_top_mirror, rubber_side_mirror]

func draw_editor_button(rect: Rect2, label: String, selected_button: bool = false) -> void:
	draw_style_box(make_box(Color("7256d8") if selected_button else Color("26384b"), 8.0), rect)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 36), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color.WHITE)

func draw_effect_editor(viewport_size: Vector2) -> void:
	if not effect_editor_enabled:
		return
	var panel := editor_panel_rect(viewport_size)
	draw_style_box(make_box(Color(0.04, 0.07, 0.12, 0.94), 12.0), panel)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(505, 36), "RUBBER HAND EDITOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f6d365"))
	var selected_name := "TOP HAND" if editor_selected_hand == 0 else "SIDE HAND"
	var values := editor_settings_text()
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(505, 58), selected_name, HORIZONTAL_ALIGNMENT_LEFT, 120, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(625, 58), values, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 635, 10, Color("dbe7f3"))
	draw_editor_button(Rect2(panel.position + Vector2(6, 8), Vector2(100, 46)), "REPLAY")
	draw_editor_button(Rect2(panel.position + Vector2(114, 8), Vector2(132, 46)), "COPY")
	draw_editor_button(Rect2(panel.position + Vector2(254, 8), Vector2(112, 46)), "PRESET A")
	draw_editor_button(Rect2(panel.position + Vector2(374, 8), Vector2(112, 46)), "PRESET B")
	var labels := ["TOP", "SIDE", "LEFT", "RIGHT", "UP", "DOWN", "SIZE-", "SIZE+", "ROT-", "ROT+", "MIRROR"]
	for i in 11:
		draw_editor_button(editor_button(i, viewport_size), labels[i], (i == editor_selected_hand and i < 2))

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box
