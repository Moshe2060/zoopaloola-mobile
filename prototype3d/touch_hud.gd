extends Control

var move_vector := Vector2.ZERO
var boost_pressed := false
var brace_pressed := false
var health := 100.0
var energy := 100.0
var enemy_health := 100.0
var exhausted := false
var result_text := ""
var restart_pressed := false
var camera_yaw_offset := 0.0
var camera_yaw_target := 0.0

var _move_touch := -1
var _boost_touch := -1
var _brace_touch := -1
var _camera_touch := -1
var _stick_origin := Vector2.ZERO
var _stick_knob := Vector2.ZERO
var _camera_last_position := Vector2.ZERO

const CAMERA_DRAG_SENSITIVITY := 0.006
const CAMERA_YAW_LIMIT := deg_to_rad(120.0)
const CAMERA_RETURN_SPEED := 5.5
const CAMERA_FOLLOW_SPEED := 12.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _process(delta: float) -> void:
	if _camera_touch == -1:
		camera_yaw_target = 0.0
	var smoothing := CAMERA_FOLLOW_SPEED if _camera_touch != -1 else CAMERA_RETURN_SPEED
	camera_yaw_offset = lerp(camera_yaw_offset, camera_yaw_target, 1.0 - exp(-delta * smoothing))
	if _camera_touch == -1 and absf(camera_yaw_offset) < 0.002:
		camera_yaw_offset = 0.0
	queue_redraw()

func consume_boost() -> bool:
	var value := boost_pressed
	boost_pressed = false
	return value

func consume_restart() -> bool:
	var value := restart_pressed
	restart_pressed = false
	return value

func _input(event: InputEvent) -> void:
	var size := get_viewport_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			if result_text != "":
				restart_pressed = true
				return
			if event.position.x < size.x * 0.48 and _move_touch == -1:
				_move_touch = event.index
				_stick_origin = event.position
				_stick_knob = event.position
			elif event.position.distance_to(Vector2(size.x - 110.0, size.y - 120.0)) < 90.0:
				_boost_touch = event.index
				boost_pressed = true
			elif event.position.distance_to(Vector2(size.x - 250.0, size.y - 80.0)) < 58.0:
				_brace_touch = event.index
				brace_pressed = true
			elif event.position.x >= size.x * 0.48 and _camera_touch == -1:
				_camera_touch = event.index
				_camera_last_position = event.position
				camera_yaw_target = camera_yaw_offset
		else:
			if event.index == _move_touch:
				_move_touch = -1
				move_vector = Vector2.ZERO
			if event.index == _boost_touch:
				_boost_touch = -1
			if event.index == _brace_touch:
				_brace_touch = -1
				brace_pressed = false
			if event.index == _camera_touch:
				_camera_touch = -1
	elif event is InputEventScreenDrag:
		if event.index == _move_touch:
			_stick_knob = event.position
			move_vector = (_stick_knob - _stick_origin) / 72.0
			if move_vector.length() > 1.0:
				move_vector = move_vector.normalized()
			_stick_knob = _stick_origin + move_vector * 72.0
		elif event.index == _camera_touch:
			# ScreenDrag.relative can become unreliable with a second finger on
			# the movement stick. Track this touch's own position instead.
			var drag_delta: Vector2 = event.position - _camera_last_position
			_camera_last_position = event.position
			var safe_drag: float = clampf(drag_delta.x, -80.0, 80.0)
			camera_yaw_target = clampf(
				camera_yaw_target - safe_drag * CAMERA_DRAG_SENSITIVITY,
				-CAMERA_YAW_LIMIT,
				CAMERA_YAW_LIMIT
			)

func _draw() -> void:
	var size := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	# Top HUD: player and opponent health, plus player push energy.
	draw_rect(Rect2(28, 24, 310, 66), Color(0.02, 0.04, 0.1, 0.86), true)
	draw_string(font, Vector2(43, 46), "PLAYER", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.75, 0.92, 1.0))
	_draw_bar(Rect2(43, 54, 276, 13), health / 100.0, Color(0.18, 0.92, 0.42))
	_draw_bar(Rect2(43, 72, 276, 10), energy / 100.0, Color(1.0, 0.55, 0.08))
	if exhausted:
		draw_string(font, Vector2(43, 106), "EXHAUSTED - VULNERABLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.42, 0.18))
	draw_rect(Rect2(size.x - 338, 24, 310, 48), Color(0.02, 0.04, 0.1, 0.86), true)
	draw_string(font, Vector2(size.x - 323, 46), "RIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.75, 0.75))
	_draw_bar(Rect2(size.x - 323, 54, 276, 13), enemy_health / 100.0, Color(0.95, 0.22, 0.25))

	# Touch controls stay visible even before the first touch.
	var stick_center := Vector2(120, size.y - 120) if _move_touch == -1 else _stick_origin
	var knob := stick_center if _move_touch == -1 else _stick_knob
	draw_circle(stick_center, 82, Color(0.2, 0.55, 0.9, 0.18))
	draw_arc(stick_center, 82, 0, TAU, 48, Color(0.45, 0.82, 1.0, 0.62), 4)
	draw_circle(knob, 34, Color(0.48, 0.82, 1.0, 0.55))
	var boost_center := Vector2(size.x - 110, size.y - 120)
	draw_circle(boost_center, 66, Color(1.0, 0.34, 0.06, 0.72))
	draw_string(font, boost_center + Vector2(-38, 8), "PUSH", HORIZONTAL_ALIGNMENT_CENTER, 76, 18, Color.WHITE)
	var brace_center := Vector2(size.x - 250, size.y - 80)
	draw_circle(brace_center, 42, Color(0.36, 0.32, 0.9, 0.58))
	draw_string(font, brace_center + Vector2(-31, 6), "BRACE", HORIZONTAL_ALIGNMENT_CENTER, 62, 12, Color.WHITE)
	if result_text != "":
		draw_rect(Rect2(0, 0, size.x, size.y), Color(0.01, 0.01, 0.04, 0.72), true)
		draw_string(font, Vector2(0, size.y * 0.43), result_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 54, Color.WHITE)
		draw_string(font, Vector2(0, size.y * 0.54), "TAP TO FIGHT AGAIN", HORIZONTAL_ALIGNMENT_CENTER, size.x, 22, Color(0.65, 0.88, 1.0))

func _draw_bar(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect, Color(0.03, 0.03, 0.05, 0.9), true)
	draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2((rect.size.x - 4) * clampf(ratio, 0.0, 1.0), rect.size.y - 4)), color, true)
