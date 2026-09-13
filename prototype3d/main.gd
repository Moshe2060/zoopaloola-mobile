extends Node3D

const ARENA_RADIUS := 30.0
const DRIVE_SPEED := 15.0
const ACCELERATION := 22.0
const BOOST_SPEED := 24.0
const BOOST_COST := 34.0
const ENERGY_REGEN := 23.0
const ENERGY_REGEN_DELAY := 1.15
const BRACE_DRAIN := 30.0

var player: CharacterBody3D
var rival: CharacterBody3D
var camera_rig: Node3D
var hud
var player_health := 100.0
var rival_health := 100.0
var energy := 100.0
var boost_cooldown := 0.0
var hit_cooldown := 0.0
var rival_boost_cooldown := 1.2
var energy_regen_delay := 0.0
var camera_shake := 0.0
var spinner: Node3D
var spinner_angle := 0.0
var spinner_hit_cooldown := 0.0
var match_finished := false
var sticky_center := Vector3(10, 0, -7)
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_build_world()
	player = _make_hovercraft("Elephant", Color("2478d4"), Vector3(0, 0.9, 13))
	rival = _make_hovercraft("Monkey", Color("e7a51c"), Vector3(0, 0.9, -13))
	rival.rotation.y = PI
	_build_camera()
	_build_hud()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(rival):
		return
	boost_cooldown = maxf(0.0, boost_cooldown - delta)
	hit_cooldown = maxf(0.0, hit_cooldown - delta)
	spinner_hit_cooldown = maxf(0.0, spinner_hit_cooldown - delta)
	energy_regen_delay = maxf(0.0, energy_regen_delay - delta)
	rival_boost_cooldown -= delta
	if match_finished:
		var restart_requested: bool = Input.is_action_just_pressed("ui_accept") or (hud != null and hud.consume_restart())
		if restart_requested:
			_restart_match()
		_update_camera(delta)
		return
	_update_player(delta)
	_update_rival(delta)
	_resolve_vehicle_collision()
	_update_spinner(delta)
	_apply_arena_limits(player)
	_apply_arena_limits(rival)
	_update_camera(delta)
	_update_hud()
	if player_health <= 0.0 or rival_health <= 0.0:
		_finish_match()

func _update_player(delta: float) -> void:
	var input_vec := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if hud and hud.move_vector.length() > 0.05:
		input_vec = hud.move_vector
	var desired := Vector3(input_vec.x, 0, input_vec.y)
	if desired.length() > 0.05:
		desired = desired.normalized()
		var target_angle := atan2(desired.x, desired.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_angle, delta * 7.0)
	var speed_factor := 0.58 if energy <= 1.0 else 1.0
	var sticky := player.global_position.distance_to(sticky_center) < 4.6
	if sticky:
		speed_factor *= 0.38
		player_health = maxf(0.0, player_health - delta * 3.0)
	var target_velocity := desired * DRIVE_SPEED * speed_factor
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, ACCELERATION * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, ACCELERATION * delta)
	var wants_boost: bool = Input.is_action_just_pressed("ui_accept") or (hud != null and hud.consume_boost())
	if wants_boost and boost_cooldown <= 0.0 and energy >= BOOST_COST:
		var forward := Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
		player.velocity += forward * BOOST_SPEED
		energy -= BOOST_COST
		boost_cooldown = 0.55
		energy_regen_delay = ENERGY_REGEN_DELAY
	if energy_regen_delay <= 0.0:
		energy = minf(100.0, energy + ENERGY_REGEN * delta)
	player.move_and_slide()

func _update_rival(delta: float) -> void:
	var offset := player.global_position - rival.global_position
	var distance := offset.length()
	var desired := offset.normalized() if distance > 0.1 else Vector3.ZERO
	var target_angle := atan2(desired.x, desired.z)
	rival.rotation.y = lerp_angle(rival.rotation.y, target_angle, delta * 3.8)
	var strafe := Vector3(-desired.z, 0, desired.x) * sin(Time.get_ticks_msec() * 0.0016) * 0.38
	var target_velocity := (desired + strafe).normalized() * 12.5
	rival.velocity.x = move_toward(rival.velocity.x, target_velocity.x, 18.0 * delta)
	rival.velocity.z = move_toward(rival.velocity.z, target_velocity.z, 18.0 * delta)
	if rival_boost_cooldown <= 0.0 and distance < 12.0:
		rival.velocity += desired * 20.0
		rival_boost_cooldown = rng.randf_range(2.4, 4.0)
	if rival.global_position.distance_to(sticky_center) < 4.6:
		rival.velocity *= 0.92
		rival_health = maxf(0.0, rival_health - delta * 3.0)
	rival.move_and_slide()

func _resolve_vehicle_collision() -> void:
	var delta_pos := rival.global_position - player.global_position
	var distance := delta_pos.length()
	if distance > 3.0 or distance < 0.01:
		return
	var normal := delta_pos.normalized()
	var player_force := maxf(0.0, player.velocity.dot(normal))
	var rival_force := maxf(0.0, rival.velocity.dot(-normal))
	var brace: bool = (hud != null and hud.brace_pressed) or Input.is_key_pressed(KEY_SHIFT)
	var player_resistance := 0.82 if energy > 30.0 else 0.42
	if brace and energy > 0.0:
		player_resistance = 1.25
		energy = maxf(0.0, energy - BRACE_DRAIN * get_physics_process_delta_time())
		energy_regen_delay = ENERGY_REGEN_DELAY
	player.velocity -= normal * rival_force * (1.25 - player_resistance * 0.45)
	rival.velocity += normal * player_force * 0.78
	if hit_cooldown <= 0.0 and player_force + rival_force > 11.0:
		player_health = maxf(0.0, player_health - rival_force * 0.34)
		rival_health = maxf(0.0, rival_health - player_force * 0.34)
		camera_shake = minf(1.0, (player_force + rival_force) / 28.0)
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.25

func _apply_arena_limits(body: CharacterBody3D) -> void:
	var flat := Vector2(body.global_position.x, body.global_position.z)
	if flat.length() > ARENA_RADIUS - 2.0:
		var inward := Vector3(-flat.x, 0, -flat.y).normalized()
		body.global_position.x = flat.normalized().x * (ARENA_RADIUS - 2.0)
		body.global_position.z = flat.normalized().y * (ARENA_RADIUS - 2.0)
		body.velocity += inward * 9.0

func _update_camera(delta: float) -> void:
	var forward := Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
	var desired_pos := player.global_position - forward * 12.5 + Vector3.UP * 7.2
	var target := player.global_position + forward * 5.0 + Vector3.UP * 0.7
	var query := PhysicsRayQueryParameters3D.create(target, desired_pos, 1, [player.get_rid()])
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		desired_pos = collision.position + collision.normal * 0.55
	camera_rig.global_position = camera_rig.global_position.lerp(desired_pos, 1.0 - exp(-delta * 5.5))
	camera_rig.look_at(target, Vector3.UP)
	if camera_shake > 0.01:
		camera_rig.global_position += Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.5, 0.5), rng.randf_range(-1.0, 1.0)) * camera_shake * 0.32
		camera_shake = move_toward(camera_shake, 0.0, delta * 4.5)

func _update_hud() -> void:
	hud.health = player_health
	hud.energy = energy
	hud.enemy_health = rival_health
	hud.exhausted = energy <= 1.0

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("091027")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("647ac4")
	env.ambient_light_energy = 0.78
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-56, -32, 0)
	sun.light_color = Color("c9d6ff")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	_make_cylinder_static("Arena", ARENA_RADIUS, 0.7, Vector3(0, -0.4, 0), Color("292543"))
	# Raised outer barrier segments preserve the arena but leave the horizon visible.
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		var pos := Vector3(sin(angle), 0, cos(angle)) * (ARENA_RADIUS - 0.4)
		var wall := _make_box_static("Barrier", Vector3(7.2, 2.3, 1.0), pos + Vector3.UP * 0.85, Color("3c315e"))
		wall.rotation.y = angle
	# Tactical cover.
	for pos in [Vector3(-9, 0.7, -4), Vector3(8, 0.7, 5), Vector3(-5, 0.7, 9)]:
		_make_box_static("Cover", Vector3(4.4, 1.7, 1.5), pos, Color("50456d"))
	# Sticky plasma: safe but damaging and slow.
	var plasma := MeshInstance3D.new()
	var plasma_mesh := CylinderMesh.new()
	plasma_mesh.top_radius = 4.6
	plasma_mesh.bottom_radius = 4.6
	plasma_mesh.height = 0.08
	plasma.mesh = plasma_mesh
	plasma.position = sticky_center + Vector3(0, 0.06, 0)
	plasma.material_override = _material(Color("19d8d0"), Color("087d98"), 1.7)
	add_child(plasma)
	# Center reactor marker.
	var reactor := MeshInstance3D.new()
	var reactor_mesh := CylinderMesh.new()
	reactor_mesh.top_radius = 2.0
	reactor_mesh.bottom_radius = 2.4
	reactor_mesh.height = 1.0
	reactor.mesh = reactor_mesh
	reactor.position = Vector3(0, 0.5, 0)
	reactor.material_override = _material(Color("5e3da0"), Color("912cff"), 2.2)
	add_child(reactor)
	_build_spinner()

func _make_hovercraft(title: String, color: Color, position: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.name = title
	body.position = position
	body.floor_stop_on_slope = false
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.45
	shape.height = 0.8
	collision.shape = shape
	body.add_child(collision)
	var hull := MeshInstance3D.new()
	var hull_mesh := CylinderMesh.new()
	hull_mesh.top_radius = 1.32
	hull_mesh.bottom_radius = 1.62
	hull_mesh.height = 0.72
	hull.mesh = hull_mesh
	hull.material_override = _material(color, color.lightened(0.15), 0.75)
	body.add_child(hull)
	var cockpit := MeshInstance3D.new()
	var cockpit_mesh := SphereMesh.new()
	cockpit_mesh.radius = 0.72
	cockpit_mesh.height = 1.15
	cockpit.mesh = cockpit_mesh
	cockpit.position = Vector3(0, 0.6, 0)
	cockpit.scale = Vector3(0.85, 0.72, 0.85)
	cockpit.material_override = _material(Color("1b213d"), Color("5275ba"), 0.55)
	body.add_child(cockpit)
	var nose := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.34, 0.18, 0.62)
	nose.mesh = nose_mesh
	nose.position = Vector3(0, 0.22, 1.56)
	nose.material_override = _material(Color("eaf6ff"), color, 1.9)
	body.add_child(nose)
	add_child(body)
	return body

func _build_camera() -> void:
	camera_rig = Node3D.new()
	camera_rig.position = Vector3(0, 8, 25)
	add_child(camera_rig)
	var camera := Camera3D.new()
	camera.fov = 68.0
	camera.current = true
	camera_rig.add_child(camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = preload("res://touch_hud.gd").new()
	layer.add_child(hud)

func _build_spinner() -> void:
	spinner = Node3D.new()
	spinner.name = "RotatingBumper"
	spinner.position = Vector3(0, 0.72, 0)
	add_child(spinner)
	for index in range(3):
		var arm := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.05, 0.72, 7.2)
		arm.mesh = mesh
		var angle := TAU * float(index) / 3.0
		arm.position = Vector3(sin(angle) * 4.5, 0, cos(angle) * 4.5)
		arm.rotation.y = angle
		arm.material_override = _material(Color("5d426f"), Color("ff8b21"), 0.8)
		spinner.add_child(arm)

func _update_spinner(delta: float) -> void:
	spinner_angle = fmod(spinner_angle + delta * 0.72, TAU)
	spinner.rotation.y = spinner_angle
	if spinner_hit_cooldown > 0.0:
		return
	for body in [player, rival]:
		var flat := Vector2(body.global_position.x, body.global_position.z)
		if flat.length() < 2.4 or flat.length() > 8.8:
			continue
		var body_angle := atan2(flat.x, flat.y)
		for arm_index in range(3):
			var arm_angle := spinner_angle + TAU * float(arm_index) / 3.0
			if absf(wrapf(body_angle - arm_angle, -PI, PI)) < 0.17:
				var tangent := Vector3(cos(arm_angle), 0, -sin(arm_angle)).normalized()
				body.velocity += tangent * 23.0
				if body == player:
					player_health = maxf(0.0, player_health - 8.0)
					camera_shake = 0.8
				else:
					rival_health = maxf(0.0, rival_health - 8.0)
				_spawn_impact_flash(body.global_position + Vector3.UP * 0.4)
				spinner_hit_cooldown = 0.48
				return

func _spawn_impact_flash(position: Vector3) -> void:
	var flash := OmniLight3D.new()
	flash.position = position
	flash.light_color = Color("ffb04a")
	flash.light_energy = 5.0
	flash.omni_range = 7.0
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.18)
	tween.tween_callback(flash.queue_free)

func _finish_match() -> void:
	match_finished = true
	player.velocity = Vector3.ZERO
	rival.velocity = Vector3.ZERO
	hud.result_text = "VICTORY" if rival_health <= 0.0 else "DEFEAT"

func _restart_match() -> void:
	match_finished = false
	player_health = 100.0
	rival_health = 100.0
	energy = 100.0
	boost_cooldown = 0.0
	energy_regen_delay = 0.0
	rival_boost_cooldown = 1.2
	player.global_position = Vector3(0, 0.9, 13)
	rival.global_position = Vector3(0, 0.9, -13)
	player.rotation.y = PI
	rival.rotation.y = 0.0
	player.velocity = Vector3.ZERO
	rival.velocity = Vector3.ZERO
	hud.result_text = ""

func _make_box_static(title: String, size: Vector3, position: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = title
	body.position = position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _material(color, color.lightened(0.15), 0.35)
	body.add_child(mesh_instance)
	add_child(body)
	return body

func _make_cylinder_static(title: String, radius: float, height: float, position: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = title
	body.position = position
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _material(color, Color("7a3cc7"), 0.25)
	body.add_child(mesh_instance)
	add_child(body)
	return body

func _material(color: Color, emission: Color, energy_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.58
	material.roughness = 0.34
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = energy_value
	return material
