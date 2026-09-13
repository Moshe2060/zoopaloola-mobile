extends Node3D

const ARENA_HALF_WIDTH := 140.0
const ARENA_HALF_DEPTH := 100.0
const DRIVE_SPEED := 24.0
const ACCELERATION := 40.0
const TURN_SPEED := 3.05
const BOOST_SPEED := 31.0
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
var player_boost_active := 0.0
var rival_boost_active := 0.0
var rival_stun := 0.0
var energy_regen_delay := 0.0
var camera_shake := 0.0
var spinner: Node3D
var spinner_angle := 0.0
var spinner_hit_cooldown := 0.0
var gravity_trap: Node3D
var gravity_trap_center := Vector3(-72, 0, -50)
var spike_trap: Node3D
var spike_trap_center := Vector3(72, 0, 42)
var spike_hit_cooldowns := {"player": 0.0, "rival": 0.0}
var laser_trap: Node3D
var laser_trap_center := Vector3(70, 0, -48)
var laser_angle := 0.0
var laser_hit_cooldowns := {"player": 0.0, "rival": 0.0}
var match_finished := false
var sticky_center := Vector3(82, 0, -54)
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_build_world()
	player = _make_hovercraft("Elephant", Color("2478d4"), Vector3(-38, 0.9, 35))
	rival = _make_hovercraft("Monkey", Color("e7a51c"), Vector3(38, 0.9, -34))
	rival.rotation.y = PI
	_build_camera()
	_build_hud()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(rival):
		return
	boost_cooldown = maxf(0.0, boost_cooldown - delta)
	hit_cooldown = maxf(0.0, hit_cooldown - delta)
	spinner_hit_cooldown = maxf(0.0, spinner_hit_cooldown - delta)
	spike_hit_cooldowns.player = maxf(0.0, spike_hit_cooldowns.player - delta)
	spike_hit_cooldowns.rival = maxf(0.0, spike_hit_cooldowns.rival - delta)
	laser_hit_cooldowns.player = maxf(0.0, laser_hit_cooldowns.player - delta)
	laser_hit_cooldowns.rival = maxf(0.0, laser_hit_cooldowns.rival - delta)
	energy_regen_delay = maxf(0.0, energy_regen_delay - delta)
	player_boost_active = maxf(0.0, player_boost_active - delta)
	rival_boost_active = maxf(0.0, rival_boost_active - delta)
	rival_stun = maxf(0.0, rival_stun - delta)
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
	_update_gravity_trap(delta)
	_update_spike_trap()
	_update_laser_trap(delta)
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
	var steering := input_vec.x
	if absf(steering) > 0.04:
		player.rotation.y -= steering * TURN_SPEED * delta
	var forward := Vector3(sin(player.rotation.y), 0, cos(player.rotation.y))
	var throttle := clampf(-input_vec.y, -0.62, 1.0)
	var desired := forward * throttle
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
		player.velocity += forward * BOOST_SPEED
		energy -= BOOST_COST
		boost_cooldown = 0.55
		player_boost_active = 0.62
		energy_regen_delay = ENERGY_REGEN_DELAY
	if energy_regen_delay <= 0.0:
		energy = minf(100.0, energy + ENERGY_REGEN * delta)
	player.move_and_slide()

func _update_rival(delta: float) -> void:
	if rival_stun > 0.0:
		rival.velocity = rival.velocity.move_toward(Vector3.ZERO, delta * 8.0)
		rival.move_and_slide()
		return
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
		rival_boost_active = 0.5
		rival_boost_cooldown = rng.randf_range(2.4, 4.0)
	if rival.global_position.distance_to(sticky_center) < 4.6:
		rival.velocity *= 0.92
		rival_health = maxf(0.0, rival_health - delta * 3.0)
	rival.move_and_slide()

func _resolve_vehicle_collision() -> void:
	var delta_pos := rival.global_position - player.global_position
	var distance := delta_pos.length()
	if distance > 3.35 or distance < 0.01:
		return
	var normal := delta_pos.normalized()
	if player_boost_active > 0.0:
		rival.velocity = normal * 34.0
		rival.global_position += normal * 0.32
		player.velocity = -normal * 5.5
		rival_stun = 0.58
		rival_health = maxf(0.0, rival_health - 12.0)
		player_boost_active = 0.0
		camera_shake = 1.0
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.3
		return
	if rival_boost_active > 0.0:
		var resistance := 0.48 if energy <= 1.0 else 0.82
		if hud != null and hud.brace_pressed and energy > 0.0:
			resistance = 1.25
		player.velocity = -normal * 30.0 * (1.35 - resistance * 0.45)
		player.global_position -= normal * 0.28
		player_health = maxf(0.0, player_health - 9.0)
		rival.velocity = normal * 3.0
		rival_boost_active = 0.0
		camera_shake = 0.9
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.3
		return
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
	var bounced := false
	if absf(body.global_position.x) > ARENA_HALF_WIDTH - 2.0:
		body.global_position.x = clampf(body.global_position.x, -ARENA_HALF_WIDTH + 2.0, ARENA_HALF_WIDTH - 2.0)
		body.velocity.x *= -0.48
		bounced = true
	if absf(body.global_position.z) > ARENA_HALF_DEPTH - 2.0:
		body.global_position.z = clampf(body.global_position.z, -ARENA_HALF_DEPTH + 2.0, ARENA_HALF_DEPTH - 2.0)
		body.velocity.z *= -0.48
		bounced = true
	if bounced and body == player:
		camera_shake = maxf(camera_shake, 0.28)

func _update_camera(delta: float) -> void:
	var camera_offset: float = hud.camera_yaw_offset if hud != null else 0.0
	var view_angle := player.rotation.y + camera_offset
	var view_forward := Vector3(sin(view_angle), 0, cos(view_angle))
	var desired_pos := player.global_position - view_forward * 12.5 + Vector3.UP * 7.2
	var target := player.global_position + view_forward * 5.0 + Vector3.UP * 0.7
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
	hud.player_map_position = Vector2(player.global_position.x, player.global_position.z)
	hud.rival_map_position = Vector2(rival.global_position.x, rival.global_position.z)
	hud.player_map_heading = player.rotation.y

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
	_make_box_static("Arena", Vector3(ARENA_HALF_WIDTH * 2.0, 0.7, ARENA_HALF_DEPTH * 2.0), Vector3(0, -0.4, 0), Color("292543"))
	# A large rectangular arena creates travel routes instead of circular laps.
	_make_box_static("NorthBarrier", Vector3(ARENA_HALF_WIDTH * 2.0, 2.7, 1.2), Vector3(0, 0.95, -ARENA_HALF_DEPTH), Color("3c315e"))
	_make_box_static("SouthBarrier", Vector3(ARENA_HALF_WIDTH * 2.0, 2.7, 1.2), Vector3(0, 0.95, ARENA_HALF_DEPTH), Color("3c315e"))
	_make_box_static("WestBarrier", Vector3(1.2, 2.7, ARENA_HALF_DEPTH * 2.0), Vector3(-ARENA_HALF_WIDTH, 0.95, 0), Color("3c315e"))
	_make_box_static("EastBarrier", Vector3(1.2, 2.7, ARENA_HALF_DEPTH * 2.0), Vector3(ARENA_HALF_WIDTH, 0.95, 0), Color("3c315e"))
	# Landmarks form three recognizable districts with several routes between them.
	for pos in [Vector3(-105, 0.7, -68), Vector3(-78, 0.7, -22), Vector3(-112, 0.7, 38), Vector3(-67, 0.7, 72), Vector3(-24, 0.7, -61), Vector3(32, 0.7, -77), Vector3(70, 0.7, -28), Vector3(112, 0.7, 18), Vector3(73, 0.7, 63), Vector3(21, 0.7, 74)]:
		_make_box_static("Cover", Vector3(11.0, 2.2, 2.5), pos, Color("50456d"))
	for pos in [Vector3(-124, 0.5, 4), Vector3(-57, 0.5, 14), Vector3(123, 0.5, -70), Vector3(103, 0.5, 77), Vector3(-22, 0.5, 89)]:
		_make_cylinder_static("Landmark", 3.0, 1.1, pos, Color("44326d"))
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
	# The center hub is a real obstacle, not only a decorative mesh.
	_make_cylinder_static("ReactorCollision", 2.35, 1.7, Vector3(0, 0.72, 0), Color("5e3da0"))
	_build_spinner()
	_build_gravity_trap()
	_build_spike_trap()
	_build_laser_trap()

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
	if title == "Elephant":
		_add_elephant_pilot(body)
		_add_elephant_armor(body)
	elif title == "Monkey":
		_add_monkey_pilot(body)
	var nose := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.34, 0.18, 0.62)
	nose.mesh = nose_mesh
	nose.position = Vector3(0, 0.22, 1.56)
	nose.material_override = _material(Color("eaf6ff"), color, 1.9)
	body.add_child(nose)
	add_child(body)
	return body

func _add_elephant_pilot(body: Node3D) -> void:
	var skin := _material(Color("7f899c"), Color("3e4863"), 0.18)
	var head := _make_sphere(Vector3(0, 1.18, 0.08), Vector3(0.62, 0.58, 0.64), skin)
	body.add_child(head)
	for side in [-1.0, 1.0]:
		var ear := _make_sphere(Vector3(side * 0.58, 1.2, 0.02), Vector3(0.42, 0.5, 0.16), skin)
		body.add_child(ear)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CapsuleMesh.new()
	trunk_mesh.radius = 0.16
	trunk_mesh.height = 0.92
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0, 0.88, 0.56)
	trunk.rotation.x = deg_to_rad(63.0)
	trunk.material_override = skin
	body.add_child(trunk)
	var dark := _material(Color("141820"), Color.BLACK, 0.0)
	for side in [-1.0, 1.0]:
		body.add_child(_make_sphere(Vector3(side * 0.2, 1.3, 0.55), Vector3(0.07, 0.07, 0.045), dark))
		var arm := MeshInstance3D.new()
		var arm_mesh := CapsuleMesh.new()
		arm_mesh.radius = 0.13
		arm_mesh.height = 0.86
		arm.mesh = arm_mesh
		arm.position = Vector3(side * 0.42, 0.79, 0.48)
		arm.rotation.x = deg_to_rad(68.0)
		arm.rotation.z = deg_to_rad(side * 18.0)
		arm.material_override = skin
		body.add_child(arm)

func _add_elephant_armor(body: Node3D) -> void:
	var blue := _material(Color("1e64bd"), Color("2d8dff"), 0.48)
	var gold := _material(Color("c38a27"), Color("ffb43a"), 0.35)
	var bumper := _material(Color("202536"), Color("17213f"), 0.18)
	var glow := _material(Color("d9f4ff"), Color("57b8ff"), 2.5)
	# Layered side armor and rear engine housings.
	for side in [-1.0, 1.0]:
		body.add_child(_make_box_part(Vector3(side * 1.36, 0.18, 0.0), Vector3(0.38, 0.56, 1.24), blue))
		body.add_child(_make_box_part(Vector3(side * 0.82, 0.28, -1.25), Vector3(0.62, 0.72, 0.62), blue))
		body.add_child(_make_box_part(Vector3(side * 0.82, 0.24, -1.59), Vector3(0.38, 0.3, 0.08), glow))
		body.add_child(_make_box_part(Vector3(side * 1.08, 0.36, 0.72), Vector3(0.32, 0.16, 0.5), gold))
	# Reinforced segmented pushing bumper at the front.
	for index in range(3):
		var x := (float(index) - 1.0) * 0.82
		body.add_child(_make_box_part(Vector3(x, 0.12, 1.58), Vector3(0.72, 0.42, 0.34), bumper))
	# Four visible hover emitters underneath.
	for pos in [Vector3(-0.92, -0.4, -0.7), Vector3(0.92, -0.4, -0.7), Vector3(-0.92, -0.4, 0.72), Vector3(0.92, -0.4, 0.72)]:
		var thruster := MeshInstance3D.new()
		var thruster_mesh := CylinderMesh.new()
		thruster_mesh.top_radius = 0.2
		thruster_mesh.bottom_radius = 0.28
		thruster_mesh.height = 0.16
		thruster.mesh = thruster_mesh
		thruster.position = pos
		thruster.material_override = glow
		body.add_child(thruster)

func _add_monkey_pilot(body: Node3D) -> void:
	var fur := _material(Color("774326"), Color("3c2015"), 0.12)
	var face := _material(Color("d8a068"), Color("6e4329"), 0.1)
	body.add_child(_make_sphere(Vector3(0, 1.18, 0.08), Vector3(0.58, 0.58, 0.58), fur))
	body.add_child(_make_sphere(Vector3(0, 1.08, 0.48), Vector3(0.38, 0.3, 0.3), face))
	for side in [-1.0, 1.0]:
		body.add_child(_make_sphere(Vector3(side * 0.55, 1.22, 0.04), Vector3(0.26, 0.3, 0.16), fur))

func _make_sphere(position: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.72
	mesh.height = 1.44
	part.mesh = mesh
	part.position = position
	part.scale = scale_value
	part.material_override = material
	return part

func _make_box_part(position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.position = position
	part.material_override = material
	return part

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

func _build_gravity_trap() -> void:
	gravity_trap = Node3D.new()
	gravity_trap.name = "GravityMagnet"
	gravity_trap.position = gravity_trap_center + Vector3.UP * 0.08
	add_child(gravity_trap)
	for index in range(3):
		var ring := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		var radius := 6.5 - float(index) * 1.65
		mesh.top_radius = radius
		mesh.bottom_radius = radius
		mesh.height = 0.055 + float(index) * 0.025
		ring.mesh = mesh
		ring.position.y = float(index) * 0.055
		ring.material_override = _material(Color("34205e").lightened(float(index) * 0.08), Color("a338ff"), 1.6 + float(index) * 0.35)
		gravity_trap.add_child(ring)

func _update_gravity_trap(delta: float) -> void:
	gravity_trap.rotation.y += delta * 0.9
	for candidate in [player, rival]:
		var body: CharacterBody3D = candidate
		var offset: Vector3 = gravity_trap_center - body.global_position
		offset.y = 0.0
		var distance: float = offset.length()
		if distance >= 15.0 or distance < 0.1:
			continue
		var pull_strength := lerpf(7.0, 29.0, 1.0 - distance / 15.0)
		body.velocity += offset.normalized() * pull_strength * delta
		if distance < 6.0:
			if body == player:
				player_health = maxf(0.0, player_health - 5.5 * delta)
				camera_shake = maxf(camera_shake, 0.12)
			else:
				rival_health = maxf(0.0, rival_health - 5.5 * delta)

func _build_spike_trap() -> void:
	spike_trap = Node3D.new()
	spike_trap.name = "SpikeField"
	spike_trap.position = spike_trap_center
	add_child(spike_trap)
	var warning := MeshInstance3D.new()
	var warning_mesh := CylinderMesh.new()
	warning_mesh.top_radius = 8.0
	warning_mesh.bottom_radius = 8.0
	warning_mesh.height = 0.06
	warning.mesh = warning_mesh
	warning.position.y = 0.04
	warning.material_override = _material(Color("53192e"), Color("ff245f"), 1.25)
	spike_trap.add_child(warning)
	var spike_material := _material(Color("9a304c"), Color("ff496e"), 0.7)
	for ring in range(3):
		var radius := 2.0 + float(ring) * 2.15
		var count := 6 + ring * 4
		for index in range(count):
			var angle := TAU * float(index) / float(count) + float(ring) * 0.28
			var spike := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.04
			mesh.bottom_radius = 0.38
			mesh.height = 1.25
			spike.mesh = mesh
			spike.position = Vector3(sin(angle) * radius, 0.64, cos(angle) * radius)
			spike.material_override = spike_material
			spike_trap.add_child(spike)

func _update_spike_trap() -> void:
	for candidate in [player, rival]:
		var body: CharacterBody3D = candidate
		if body.global_position.distance_to(spike_trap_center) > 8.1:
			continue
		var key := "player" if body == player else "rival"
		if spike_hit_cooldowns[key] > 0.0:
			continue
		body.velocity *= 0.72
		body.velocity += (body.global_position - spike_trap_center).normalized() * 8.0
		if body == player:
			player_health = maxf(0.0, player_health - 7.0)
			camera_shake = maxf(camera_shake, 0.55)
		else:
			rival_health = maxf(0.0, rival_health - 7.0)
		spike_hit_cooldowns[key] = 0.72
		_spawn_impact_flash(body.global_position + Vector3.UP * 0.35)

func _build_laser_trap() -> void:
	laser_trap = Node3D.new()
	laser_trap.name = "RotatingLaser"
	laser_trap.position = laser_trap_center
	add_child(laser_trap)
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.35
	base_mesh.bottom_radius = 1.7
	base_mesh.height = 1.4
	base.mesh = base_mesh
	base.position.y = 0.7
	base.material_override = _material(Color("2a334e"), Color("6073bc"), 0.35)
	laser_trap.add_child(base)
	laser_trap.add_child(_make_sphere(Vector3(0, 1.65, 0), Vector3(0.44, 0.44, 0.44), _material(Color("ffdfdf"), Color("ff173d"), 3.8)))
	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(0.24, 0.24, 24.0)
	beam.mesh = beam_mesh
	beam.position = Vector3(0, 1.65, 12.0)
	beam.material_override = _material(Color("ff5971"), Color("ff082f"), 5.0)
	laser_trap.add_child(beam)

func _update_laser_trap(delta: float) -> void:
	laser_angle = fmod(laser_angle + delta * 0.88, TAU)
	laser_trap.rotation.y = laser_angle
	var beam_direction := Vector3(sin(laser_angle), 0, cos(laser_angle))
	for candidate in [player, rival]:
		var body: CharacterBody3D = candidate
		var local_offset := body.global_position - laser_trap_center
		local_offset.y = 0.0
		var along := local_offset.dot(beam_direction)
		var sideways := absf(local_offset.cross(beam_direction).y)
		if along < 0.8 or along > 24.0 or sideways > 1.35:
			continue
		var key := "player" if body == player else "rival"
		if laser_hit_cooldowns[key] > 0.0:
			continue
		body.velocity += beam_direction * 12.0
		if body == player:
			player_health = maxf(0.0, player_health - 9.0)
			camera_shake = maxf(camera_shake, 0.7)
		else:
			rival_health = maxf(0.0, rival_health - 9.0)
		laser_hit_cooldowns[key] = 0.85
		_spawn_impact_flash(body.global_position + Vector3.UP * 0.5)

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
	player_boost_active = 0.0
	rival_boost_active = 0.0
	rival_stun = 0.0
	spike_hit_cooldowns = {"player": 0.0, "rival": 0.0}
	laser_hit_cooldowns = {"player": 0.0, "rival": 0.0}
	player.global_position = Vector3(-38, 0.9, 35)
	rival.global_position = Vector3(38, 0.9, -34)
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
