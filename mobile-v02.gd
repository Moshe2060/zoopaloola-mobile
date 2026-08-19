extends Node2D

const BOARD_W := 207.0
const BOARD_H := 208.0
const RADIUS := 6.0
const GAME_BALL_VISUAL_SCALE := 1.25
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
const HAMMER_TRAP_HOLE := 3
const TRAP_CAPTURE_TIME := 2.35
const TRAP_FALL_TIME := 2.85
const PRESS_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const ICE_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const FIRE_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const ELECTRIC_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const HAMMER_EFFECT_DURATION := TRAP_CAPTURE_TIME + TRAP_FALL_TIME
const RUBBER_CAPTURE_TIME := TRAP_CAPTURE_TIME
const RUBBER_FALL_TIME := TRAP_FALL_TIME
const RUBBER_EFFECT_DURATION := RUBBER_CAPTURE_TIME + RUBBER_FALL_TIME
const WATER_FLOAT_TIME := 5.8
const WATER_DRIFT_DELAY := 1.8
const ANIMAL_NAMES := ["ELEPHANT", "ZEBRA", "MONKEY", "HIPPO", "RHINO", "GIRAFFE"]
const ANIMAL_FILES := ["elephant", "zebra", "monkey", "hippo", "rhino", "giraffe"]
const RING_COLOR_NAMES := ["RED", "ORANGE", "BLUE", "GREEN", "PURPLE", "TURQUOISE"]
const RING_COLORS := [
	Color("ef3340"), Color("ff8a00"), Color("1677ff"),
	Color("12c95b"), Color("8f36dc"), Color("08cbd1")
]
var board_texture: Texture2D
var piece_textures: Array[Texture2D] = []
var animal_textures: Array[Texture2D] = []
var animal_ring_masks: Array[Texture2D] = []
var team_piece_textures: Array[Texture2D] = []
var effect_textures: Array[Texture2D] = []
var rubber_ball_texture: Texture2D
var rubber_hand_textures: Array[Texture2D] = []
var rubber_launcher_texture: Texture2D
var rubber_wrap_texture: Texture2D
var balls: Array = []
var active_effects: Array = []
var water_floaters: Array = []
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
var customizer_open := true
# Start with the combination requested during the visual review: zebra + green.
var player_animal := 1
var player_ring_color := 3
var ai_animal := 0
var ai_ring_color := 0

func _ready() -> void:
	# Smooth the original character art when it is enlarged inside HD balls.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	board_texture = load("res://assets/board-clean-modular.webp") as Texture2D
	if board_texture == null:
		push_error("Clean original board could not be loaded.")
	for file_name in ["59_id_040.png", "60_id_041.png", "61_id_042.png", "62_id_043.png", "63_id_044.png"]:
		piece_textures.append(load("res://assets/pieces/" + file_name))
	for animal_file in ANIMAL_FILES:
		animal_textures.append(load("res://assets/animal_pieces/%s.png" % animal_file))
		animal_ring_masks.append(load("res://assets/animal_pieces/%s-ring-mask.png" % animal_file))
	rebuild_team_piece_textures()
	for i in 6:
		effect_textures.append(load("res://assets/remastered_effects/effect-%d.png" % i))
	rubber_ball_texture = load("res://assets/rubber_trap/rubber-ball.png") as Texture2D
	for i in 5:
		rubber_hand_textures.append(load("res://assets/rubber_trap/hands/pose-%d.png" % i))
	rubber_launcher_texture = load("res://assets/rubber_launcher/launcher.svg") as Texture2D
	rubber_wrap_texture = load("res://assets/rubber_launcher/wrap-sequence.svg") as Texture2D
	new_game()
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _on_resize() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	# Leave a clearly visible ocean frame around the floating board. The HUD is
	# drawn over the ocean, so the board begins below it instead of hiding under
	# the bar. All gameplay coordinates still use board_rect and stay aligned.
	# Slightly larger than the first ocean layout while retaining a visible water
	# frame on every side of the floating table.
	var side_margin := maxf(56.0, viewport_size.x * 0.055)
	var top_margin := 74.0
	var bottom_margin := 28.0
	var play_position := Vector2(side_margin, top_margin)
	var available := Vector2(
		maxf(300.0, viewport_size.x - side_margin * 2.0),
		maxf(220.0, viewport_size.y - top_margin - bottom_margin)
	)
	# Preserve the actual modular board proportions (1480 x 1063). The previous
	# landscape ratio stretched the stones and center circle horizontally.
	var target_aspect := 1480.0 / 1063.0
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
	water_floaters.clear()
	contacts.clear()
	turn = 0
	ai_pending = false
	selected = -1
	dragging = false
	# Match the original opening formation: sixteen pieces wrap around the white
	# center circle, with two additional pieces on the far left and two on the
	# far right. Centers were measured from the supplied original screenshot and
	# are ordered clockwise so the two players alternate around the formation.
	var screen_formation := [
		Vector2(0.493, 0.209), Vector2(0.579, 0.241),
		Vector2(0.659, 0.304), Vector2(0.839, 0.397), Vector2(0.699, 0.397),
		Vector2(0.718, 0.524), Vector2(0.699, 0.653), Vector2(0.839, 0.653),
		Vector2(0.659, 0.740), Vector2(0.579, 0.795), Vector2(0.493, 0.817),
		Vector2(0.406, 0.795), Vector2(0.328, 0.740),
		Vector2(0.155, 0.653), Vector2(0.279, 0.653), Vector2(0.264, 0.524),
		Vector2(0.279, 0.397), Vector2(0.155, 0.397),
		Vector2(0.328, 0.304), Vector2(0.406, 0.241)
	]
	# The four detached side pieces are indices 3, 7, 13 and 17. Keep each
	# detached pair together: both left pieces belong to the player and both
	# right pieces belong to the opponent.
	var outside_teams := {3: 1, 7: 1, 13: 0, 17: 0}
	var inner_index := 0
	for i in screen_formation.size():
		var normalized: Vector2 = screen_formation[i]
		# Invert board_to_screen so these readable landscape coordinates continue
		# to use the original rotated physics coordinate system.
		var p := Vector2(normalized.y * BOARD_W, BOARD_H - normalized.x * BOARD_H)
		var team: int
		if outside_teams.has(i):
			team = outside_teams[i]
		else:
			team = inner_index % 2
			inner_index += 1
		balls.append({"p":p, "v":Vector2.ZERO, "team":team, "alive":true})
	status = "Your turn - touch a red ball, pull back and release"
	queue_redraw()

func _process(delta: float) -> void:
	accumulator += delta
	while accumulator >= STEP_TIME:
		physics_step()
		accumulator -= STEP_TIME
	update_effects(delta)
	update_water_floaters(delta)
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
		elif active_effects[i].hole == HAMMER_TRAP_HOLE:
			duration = HAMMER_EFFECT_DURATION
		if active_effects[i].elapsed >= duration:
			spawn_water_floater(active_effects[i])
			active_effects.remove_at(i)

func spawn_water_floater(effect: Dictionary) -> void:
	# Continue from the exact final frame of each weapon fall. Spawning again at
	# the hole made the animal grow and appear to fall from the table twice.
	var landing := effect_fall_endpoint(effect.hole)
	var outward := (landing - board_rect.get_center()).normalized()
	if outward.length_squared() < 0.01:
		outward = Vector2.DOWN
	# Keep the distant perspective size reached at the end of the fall.
	var radius := 15.0 * board_rect.size.y / 600.0
	water_floaters.append({
		"elapsed": 0.0,
		"team": effect.team,
		"piece": effect.piece,
		"start": landing,
		"direction": outward,
		"radius": radius
	})

func effect_fall_endpoint(hole: int) -> Vector2:
	var scale_y := board_rect.size.y / 600.0
	match hole:
		RUBBER_TRAP_HOLE:
			return rubber_point(2.0, 22.0)
		PRESS_TRAP_HOLE:
			# Stop in the narrow water strip above the table instead of continuing
			# behind the HUD and outside the visible screen.
			return press_point(621.0, -12.0)
		ELECTRIC_TRAP_HOLE:
			return electric_point(1198.0, 22.0)
		HAMMER_TRAP_HOLE:
			return hammer_point(1198.0, 598.0)
		ICE_TRAP_HOLE:
			# Match the visible water strip immediately below the table.
			return ice_point(600.0, 612.0)
		FIRE_TRAP_HOLE:
			return fire_point(112.0, 536.0) + Vector2(-82.0, 155.0) * scale_y
	return board_to_screen(SCORING_HOLE_CENTERS[hole])

func update_water_floaters(delta: float) -> void:
	for floater in water_floaters:
		floater.elapsed += delta
	for i in range(water_floaters.size() - 1, -1, -1):
		if water_floaters[i].elapsed >= WATER_FLOAT_TIME:
			water_floaters.remove_at(i)

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
	if handle_customizer_touch(screen_pos):
		return
	if handle_effect_editor_touch(screen_pos):
		return
	if Rect2(get_viewport_rect().size.x - 454.0, 6.0, 105.0, 42.0).has_point(screen_pos):
		if not any_ball_moving() and active_effects.is_empty():
			customizer_open = true
			queue_redraw()
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
	draw_ocean(viewport_size)
	if viewport_size.y > viewport_size.x:
		draw_string(ThemeDB.fallback_font, Vector2(0, viewport_size.y * 0.44), "ROTATE YOUR PHONE", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 28, Color("f6d365"))
		draw_string(ThemeDB.fallback_font, Vector2(0, viewport_size.y * 0.50), "Zoopaloola is designed for landscape mode", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 18, Color.WHITE)
		return
	# Floating animals stay behind the elevated table and only remain visible on
	# the surrounding water.
	draw_water_floaters(viewport_size)
	# Approved faithful remaster, created natively in landscape.
	draw_texture_rect(board_texture, board_rect, false)
	draw_scoreboards()
	draw_rubber_launchers_idle()

	for i in balls.size():
		var ball: Dictionary = balls[i]
		if not ball.alive: continue
		var sp := board_to_screen(ball.p)
		draw_rubber_game_ball(sp, RADIUS * board_scale * GAME_BALL_VISUAL_SCALE, ball.team, i, 1.0)

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
		elif effect.hole == HAMMER_TRAP_HOLE:
			draw_hammer_trap(effect)
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
	draw_customizer(viewport_size)

func draw_ocean(viewport_size: Vector2) -> void:
	# Bright layered water makes the space around the table read as sea even on
	# small phone screens. The curves are intentionally subtle so they do not
	# compete with the balls or the weapon effects.
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("087fa8"))
	var band_height := maxf(34.0, viewport_size.y / 10.0)
	for band in 10:
		var y := float(band) * band_height
		var band_color := Color("0797bd") if band % 2 == 0 else Color("078db5")
		draw_rect(Rect2(0.0, y, viewport_size.x, band_height + 1.0), band_color)
	var wave_color := Color(0.68, 0.94, 1.0, 0.34)
	var wave_shadow := Color(0.01, 0.39, 0.60, 0.28)
	var spacing := maxf(46.0, viewport_size.y / 9.0)
	var amplitude := clampf(viewport_size.y * 0.011, 5.0, 10.0)
	for row in 11:
		var points := PackedVector2Array()
		var shadow_points := PackedVector2Array()
		var base_y := float(row) * spacing + 12.0
		var phase := float(row % 2) * PI
		for x_step in 33:
			var x := float(x_step) / 32.0 * viewport_size.x
			var y := base_y + sin(float(x_step) * 0.72 + phase) * amplitude
			points.append(Vector2(x, y))
			shadow_points.append(Vector2(x, y + 7.0))
		draw_polyline(shadow_points, wave_shadow, 3.0, true)
		draw_polyline(points, wave_color, 2.0, true)

func draw_water_floaters(viewport_size: Vector2) -> void:
	for floater in water_floaters:
		var seconds: float = floater.elapsed
		var direction: Vector2 = floater.direction
		var start: Vector2 = floater.start
		var drift := smooth_step((seconds - WATER_DRIFT_DELAY) / (WATER_FLOAT_TIME - WATER_DRIFT_DELAY))
		var drift_distance := maxf(viewport_size.x, viewport_size.y) * 0.72
		var settle := smooth_step(seconds / 0.75)
		var sideways := direction.orthogonal() * sin(seconds * 1.25 + float(floater.piece)) * 12.0 * settle
		var bob := Vector2(0.0, sin(seconds * 3.1 + float(floater.piece)) * 5.0 * settle)
		var position := start + direction * drift_distance * drift * drift + sideways + bob
		var radius: float = floater.radius
		var splash := 1.0 - smooth_step(seconds / 0.65)
		if splash > 0.01:
			draw_circle(position, radius * (1.1 + (1.0 - splash) * 1.25), Color(0.78, 0.96, 1.0, splash * 0.58), false, maxf(2.0, radius * 0.14), true)
			for i in 7:
				var angle := TAU * float(i) / 7.0
				var drop_start := position + Vector2(cos(angle), sin(angle)) * radius * 1.05
				var drop_end := position + Vector2(cos(angle), sin(angle)) * radius * (1.22 + (1.0 - splash) * 0.65)
				draw_line(drop_start, drop_end, Color(0.84, 0.98, 1.0, splash * 0.75), maxf(1.0, radius * 0.10), true)
		var ripple_alpha := 0.34 * (1.0 - drift * 0.45)
		draw_arc(position + Vector2(0.0, radius * 0.55), radius * 1.22, 0.08, PI - 0.08, 28, Color(0.72, 0.95, 1.0, ripple_alpha), maxf(1.5, radius * 0.10), true)
		draw_rubber_game_ball(position, radius, floater.team, floater.piece, 1.0)

func fallen_count(team: int) -> int:
	var count := 0
	for ball in balls:
		if ball.team == team and not ball.alive:
			count += 1
	return count

func draw_scoreboards() -> void:
	# The blue and purple displays baked into the board art are covered by these
	# live panels. Their colors follow each player's selected lifebuoy.
	var centers := [
		board_rect.position + Vector2(board_rect.size.x * 0.289, board_rect.size.y * 0.052),
		board_rect.position + Vector2(board_rect.size.x * 0.683, board_rect.size.y * 0.052)
	]
	var colors := [RING_COLORS[player_ring_color], RING_COLORS[ai_ring_color]]
	var panel_size := Vector2(board_rect.size.x * 0.075, board_rect.size.y * 0.060)
	var corner := maxf(5.0, board_rect.size.y * 0.012)
	for team in 2:
		var outer_rect := Rect2(centers[team] - panel_size * 0.5, panel_size)
		draw_style_box(make_box(Color(0.08, 0.13, 0.14, 0.96), corner + 3.0), outer_rect.grow(4.0))
		draw_style_box(make_box(colors[team].darkened(0.16), corner), outer_rect)
		var shine_rect := Rect2(outer_rect.position + Vector2(3.0, 3.0), Vector2(outer_rect.size.x - 6.0, outer_rect.size.y * 0.28))
		draw_style_box(make_box(Color(1.0, 1.0, 1.0, 0.20), corner * 0.55), shine_rect)
		var score := str(fallen_count(team))
		var font_size := maxi(18, int(panel_size.y * 0.82))
		var baseline: float = float(centers[team].y) + float(font_size) * 0.34
		draw_string(ThemeDB.fallback_font, Vector2(outer_rect.position.x, baseline), score, HORIZONTAL_ALIGNMENT_CENTER, outer_rect.size.x, font_size, Color.WHITE)

func draw_hud(viewport_size: Vector2) -> void:
	# Overlay the compact HUD so it no longer reserves valuable board height.
	draw_rect(Rect2(0, 0, viewport_size.x, 54), Color(0.09, 0.15, 0.23, 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(18, 33), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f6d365"))
	draw_string(ThemeDB.fallback_font, Vector2(200, 34), status, HORIZONTAL_ALIGNMENT_LEFT, viewport_size.x - 675, 17, Color.WHITE)
	var choose_rect := Rect2(viewport_size.x - 454.0, 6.0, 105.0, 42.0)
	draw_style_box(make_box(Color("1b91a8"), 14.0), choose_rect)
	draw_string(ThemeDB.fallback_font, choose_rect.position + Vector2(0, 28), "CHOOSE", HORIZONTAL_ALIGNMENT_CENTER, choose_rect.size.x, 15, Color.WHITE)
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
		# Land just above the table in visible water; the previous -121 target
		# continued behind the HUD before the floating phase began.
		ball_y = cy - lerpf(0.0, 67.0, motion)
		alpha = 1.0 - release * 0.08
		var shrink := 1.0 - release * 0.30
		rx_scale *= shrink
		ry_scale *= shrink
	if arm_amount > 0.01:
		draw_press_rod(546.0, cy, left_tip, true, squeeze)
		draw_press_rod(695.0, cy, right_tip, false, squeeze)
	var radius_screen := radius * board_rect.size.y / 600.0
	draw_press_ball(press_point(cx, ball_y), radius_screen, rx_scale, ry_scale, rotation, effect.team, effect.piece, alpha)

func hammer_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func hammer_strike_amount(seconds: float, offset: float) -> float:
	var local := fmod(maxf(0.0, seconds - offset), 0.72) / 0.72
	if seconds < offset:
		return 0.0
	if local < 0.34:
		return smooth_step(local / 0.34)
	return 1.0 - smooth_step((local - 0.34) / 0.66)

func draw_trap_hammer(anchor: Vector2, hit_point: Vector2, amount: float, scale_y: float) -> void:
	if amount <= 0.01:
		return
	var direction := hit_point - anchor
	var tip := anchor.lerp(hit_point, amount)
	var angle := direction.angle()
	var handle_end := tip - direction.normalized() * 12.0 * scale_y
	draw_line(anchor, handle_end, Color("38464d"), 17.0 * scale_y, true)
	draw_line(anchor, handle_end, Color("a8b2b5"), 7.0 * scale_y, true)
	var head_size := Vector2(66.0, 38.0) * scale_y
	draw_set_transform(tip, angle, Vector2.ONE)
	draw_style_box(make_box(Color("d96513"), 5.0 * scale_y), Rect2(-head_size * 0.5, head_size))
	draw_rect(Rect2(Vector2(-head_size.x * 0.34, -head_size.y * 0.36), Vector2(head_size.x * 0.68, head_size.y * 0.24)), Color("ffab32"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_hammer_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var right_weapon := hammer_point(1128.0, 455.0)
	var bottom_weapon := hammer_point(1010.0, 565.0)
	var hit_point := hammer_point(1072.0, 522.0)
	var radius := 27.0 * scale_y
	var hammering := 1.0 - smooth_step((seconds - 1.82) / 0.30)
	var right_amount := hammer_strike_amount(seconds, 0.04) * hammering
	var bottom_amount := hammer_strike_amount(seconds, 0.39) * hammering
	var impact := maxf(
		smooth_step((right_amount - 0.52) / 0.44),
		smooth_step((bottom_amount - 0.52) / 0.44)
	)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := hit_point
	var ball_radius := radius
	var alpha := 1.0
	if release > 0.0:
		var fall := release * release
		center = hit_point.lerp(hammer_point(1198.0, 598.0), fall)
		center.y -= sin(release * PI) * 5.0 * scale_y
		ball_radius *= 1.0 - release * 0.32
		alpha = 1.0 - release * 0.10

	var squash_x := 1.0
	var squash_y := 1.0
	var ball_rotation := 0.0
	if release <= 0.0 and impact > 0.01:
		# Make every strike visibly compress and briefly shrink the ball.
		ball_radius *= lerpf(1.0, 0.76, impact)
		if right_amount >= bottom_amount:
			squash_x = lerpf(1.0, 0.44, impact)
			squash_y = lerpf(1.0, 1.34, impact)
			ball_rotation = -0.13 * impact
		else:
			squash_x = lerpf(1.0, 1.34, impact)
			squash_y = lerpf(1.0, 0.44, impact)
			ball_rotation = 0.13 * impact

	# Draw the ball first, then the hammers, so their heads visibly land on top.
	draw_press_ball(center, ball_radius, squash_x, squash_y, ball_rotation, effect.team, effect.piece, alpha)
	if release <= 0.0:
		draw_trap_hammer(right_weapon, hit_point + Vector2(radius * 0.28, 0.0), right_amount, scale_y)
		draw_trap_hammer(bottom_weapon, hit_point + Vector2(0.0, radius * 0.28), bottom_amount, scale_y)

	if impact > 0.05 and release <= 0.0:
		draw_circle(center, ball_radius * (1.32 + impact * 0.18), Color(1.0, 0.77, 0.25, 0.28 * impact), false, maxf(2.0, 4.0 * scale_y))
		for i in 6:
			var a := TAU * float(i) / 6.0
			var p1 := center + Vector2(cos(a), sin(a)) * ball_radius * 1.10
			var p2 := center + Vector2(cos(a), sin(a)) * ball_radius * (1.35 + impact * 0.28)
			draw_line(p1, p2, Color(1.0, 0.90, 0.50, 0.82 * impact), maxf(1.0, 2.0 * scale_y), true)

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
		# Finish just below the table so the small frozen animal remains visible
		# when the water-floating phase takes over.
		center.y += gravity_fall * 64.0 * scale_y
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
	if team_piece_textures.size() < 2 or team_piece_textures[team] == null:
		return
	var texture := team_piece_textures[team]
	var size := Vector2.ONE * radius * 2.34
	draw_circle(position + Vector2(radius * 0.09, radius * 0.15), radius * 1.08, Color(0, 0, 0, 0.30 * alpha), true, -1.0, true)
	draw_texture_rect(texture, Rect2(position - size * 0.5, size), false, Color(1, 1, 1, alpha))

func rebuild_team_piece_textures() -> void:
	team_piece_textures.clear()
	team_piece_textures.append(make_colored_animal_texture(player_animal, RING_COLORS[player_ring_color]))
	team_piece_textures.append(make_colored_animal_texture(ai_animal, RING_COLORS[ai_ring_color]))

func make_colored_animal_texture(animal_index: int, target_color: Color) -> Texture2D:
	if animal_index < 0 or animal_index >= animal_textures.size():
		return null
	var image: Image = animal_textures[animal_index].get_image().duplicate()
	var mask: Image = animal_ring_masks[animal_index].get_image()
	for y in image.get_height():
		for x in image.get_width():
			var amount: float = mask.get_pixel(x, y).r
			if amount <= 0.001:
				continue
			var original: Color = image.get_pixel(x, y)
			var recolored: Color = Color.from_hsv(target_color.h, maxf(original.s, target_color.s * 0.82), original.v, original.a)
			image.set_pixel(x, y, original.lerp(recolored, amount))
	return ImageTexture.create_from_image(image)

func customizer_panel(viewport_size: Vector2) -> Rect2:
	var size := Vector2(minf(820.0, viewport_size.x - 36.0), minf(390.0, viewport_size.y - 34.0))
	return Rect2((viewport_size - size) * 0.5, size)

func customizer_animal_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 8.0
	var width := (panel.size.x - 40.0 - gap * 5.0) / 6.0
	return Rect2(panel.position + Vector2(20.0 + index * (width + gap), 82.0), Vector2(width, 68.0))

func customizer_color_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 8.0
	var width := (panel.size.x - 40.0 - gap * 5.0) / 6.0
	return Rect2(panel.position + Vector2(20.0 + index * (width + gap), 205.0), Vector2(width, 58.0))

func customizer_start_rect(viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	return Rect2(panel.position + Vector2(panel.size.x * 0.5 - 95.0, panel.size.y - 68.0), Vector2(190.0, 48.0))

func handle_customizer_touch(screen_pos: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	if not customizer_open:
		return false
	for i in ANIMAL_NAMES.size():
		if customizer_animal_rect(i, viewport_size).has_point(screen_pos):
			player_animal = i
			rebuild_team_piece_textures()
			queue_redraw()
			return true
	for i in RING_COLOR_NAMES.size():
		if customizer_color_rect(i, viewport_size).has_point(screen_pos):
			player_ring_color = i
			rebuild_team_piece_textures()
			queue_redraw()
			return true
	if customizer_start_rect(viewport_size).has_point(screen_pos):
		ai_animal = randi() % ANIMAL_NAMES.size()
		ai_ring_color = randi() % RING_COLOR_NAMES.size()
		rebuild_team_piece_textures()
		customizer_open = false
		new_game()
		return true
	return true

func draw_customizer(viewport_size: Vector2) -> void:
	if not customizer_open:
		return
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.02, 0.04, 0.08, 0.72))
	var panel := customizer_panel(viewport_size)
	draw_style_box(make_box(Color("122337"), 18.0), panel)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(0, 38), "CHOOSE YOUR ANIMAL AND LIFEBUOY", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 22, Color("f6d365"))
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(20, 72), "ANIMAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in ANIMAL_NAMES.size():
		var rect := customizer_animal_rect(i, viewport_size)
		draw_style_box(make_box(Color("7256d8") if i == player_animal else Color("26384b"), 10.0), rect)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 40), ANIMAL_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(20, 195), "LIFEBUOY COLOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in RING_COLOR_NAMES.size():
		var rect := customizer_color_rect(i, viewport_size)
		draw_style_box(make_box(RING_COLORS[i], 10.0), rect)
		if i == player_ring_color:
			draw_rect(rect.grow(3.0), Color.WHITE, false, 3.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 36), RING_COLOR_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color.WHITE)
	var start_rect := customizer_start_rect(viewport_size)
	draw_style_box(make_box(Color("12a96b"), 14.0), start_rect)
	draw_string(ThemeDB.fallback_font, start_rect.position + Vector2(0, 31), "START GAME", HORIZONTAL_ALIGNMENT_CENTER, start_rect.size.x, 17, Color.WHITE)

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
	if rubber_wrap_texture == null or amount <= 0.001:
		return
	# Twelve extracted stages reproduce the original wide crossing strips,
	# irregular outer loops and final compact cocoon instead of invented rings.
	var frame := clampi(int(floor(amount * 11.99)), 0, 11)
	var source := Rect2(0.0, float(frame * 210), 210.0, 210.0)
	var size := Vector2.ONE * radius * 5.35
	var top_left := position - Vector2(102.0, 108.0) / 210.0 * size
	draw_texture_rect_region(rubber_wrap_texture, Rect2(top_left, size), source, Color.WHITE)

func rubber_launcher_points() -> Dictionary:
	return {
		"capture": rubber_point(128.0, 104.0),
		# Measured from the source video: the launchers sit diagonally across
		# the opening, not directly above and left of the captured ball.
		"top": rubber_point(223.0, 33.0),
		"side": rubber_point(54.0, 177.0)
	}

func rubber_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == RUBBER_TRAP_HOLE:
			return true
	return false

func draw_rubber_launcher(center: Vector2, target: Vector2, size: float, pulse: float = 0.0) -> Vector2:
	var direction := (target - center).normalized()
	if rubber_launcher_texture == null:
		return center
	# The HD sprite faces right. Its body center is at x=205 in a 512x412
	# image, so rotate around the machine body rather than the image midpoint.
	# This keeps both launchers seated on their stones like the original.
	var source := rubber_launcher_texture.get_size()
	var draw_height := size * (1.0 + pulse * 0.025)
	var factor := draw_height / source.y
	var draw_size := source * factor
	var body_center_x := 205.0 * factor
	draw_set_transform(center, direction.angle(), Vector2.ONE)
	draw_texture_rect(rubber_launcher_texture, Rect2(Vector2(-body_center_x, -draw_size.y * 0.5), draw_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return center + direction * (307.0 * factor)

func draw_rubber_launchers_idle() -> void:
	if customizer_open or rubber_trap_is_active():
		return
	var points := rubber_launcher_points()
	var scale_y := board_rect.size.y / 600.0
	var pulse := (sin(float(Time.get_ticks_msec()) * 0.004) + 1.0) * 0.5
	draw_rubber_launcher(points.top, points.capture, 44.0 * scale_y, pulse * 0.18)
	draw_rubber_launcher(points.side, points.capture, 44.0 * scale_y, pulse * 0.18)

func draw_elastic_tape(origin: Vector2, target: Vector2, amount: float, bend: float, width: float) -> void:
	if amount <= 0.001:
		return
	var end := origin.lerp(target, amount)
	var delta := end - origin
	var normal := Vector2(-delta.y, delta.x).normalized()
	var points := PackedVector2Array()
	for i in 17:
		var u := float(i) / 16.0
		var wave := sin(u * PI) * bend + sin(u * TAU * 2.0 + amount * 8.0) * bend * 0.12
		points.append(origin.lerp(end, u) + normal * wave)
	draw_polyline(points, Color(0.43, 0.45, 0.48, 0.90), width * 1.55, true)
	draw_polyline(points, Color("faf8f0"), width, true)
	# A slim pink edge reproduces the colored elastic seam seen in the frames.
	var seam := PackedVector2Array()
	for p in points:
		seam.append(p + normal * width * 0.32)
	draw_polyline(seam, Color("d95caf"), maxf(1.0, width * 0.22), true)

func draw_rubber_trap(effect: Dictionary) -> void:
	var elapsed: float = effect.elapsed
	var t := elapsed / RUBBER_CAPTURE_TIME
	var scale_y := board_rect.size.y / 600.0
	var points := rubber_launcher_points()
	var anchor_top: Vector2 = points.top
	var anchor_left: Vector2 = points.side
	var capture: Vector2 = points.capture
	# Use exactly the same on-screen radius as the live gameplay piece. The old
	# fixed effect radius was about 1.5x larger and caused a visible size pop on
	# the first wrapping frame.
	var ball_radius := RADIUS * board_scale * GAME_BALL_VISUAL_SCALE
	# The real gameplay ball has already entered this hole. Start the trap at
	# the capture point so the V4 preview's staged entry is not replayed.
	var ball := capture
	var reach := smooth_step((t - 0.04) / 0.18)
	var wrap := smooth_step((t - 0.05) / 0.72)
	var team: int = effect.team
	var piece: int = effect.piece
	draw_rubber_launcher(anchor_top, capture, 44.0 * scale_y, reach)
	draw_rubber_launcher(anchor_left, capture, 44.0 * scale_y, reach)
	if elapsed < RUBBER_CAPTURE_TIME:
		var focus := wrap * (1.0 - wrap * 0.45)
		draw_circle(ball, ball_radius * (1.45 + sin(t * 45.0) * 0.08), Color(1.0, 0.965, 0.72, 0.28 * focus))
		draw_rubber_game_ball(ball, ball_radius * (1.0 + sin(t * 40.0) * 0.025 * focus), team, piece, 1.0 - wrap)
		if wrap > 0.0:
			draw_rubber_wrap(ball, ball_radius, wrap, 0.0)
	else:
		var release := smooth_step((elapsed - RUBBER_CAPTURE_TIME) / RUBBER_FALL_TIME)
		var fall := release * release
		var out := rubber_point(2, 22)
		ball = capture.lerp(out, fall)
		ball_radius *= 1.0 - release * 0.42
		# Keep the cocoon on the falling ball exactly like the source frames.
		draw_rubber_wrap(ball, ball_radius, 1.0, 0.0)

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
