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
const ELEPHANT_ABILITY_COOLDOWN := 8.0
const MONKEY_ABILITY_COOLDOWN := 5.2

var player: CharacterBody3D
var rival: CharacterBody3D
var camera_rig: Node3D
var hud
var player_health := 100.0
var rival_health := 100.0
var energy := 100.0
var rival_energy := 100.0
var player_turbo := 0.0
var rival_turbo := 0.0
var player_ability_cooldown := 0.0
var rival_ability_cooldown := 2.4
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
var gravity_feedback_cooldowns := {"player": 0.0, "rival": 0.0}
var spike_trap: Node3D
var spike_trap_center := Vector3(72, 0, 42)
var spike_hit_cooldowns := {"player": 0.0, "rival": 0.0}
var laser_trap: Node3D
var laser_trap_center := Vector3(70, 0, -48)
var laser_angle := 0.0
var laser_hit_cooldowns := {"player": 0.0, "rival": 0.0}
var pickups: Array[Dictionary] = []
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
	gravity_feedback_cooldowns.player = maxf(0.0, gravity_feedback_cooldowns.player - delta)
	gravity_feedback_cooldowns.rival = maxf(0.0, gravity_feedback_cooldowns.rival - delta)
	player_ability_cooldown = maxf(0.0, player_ability_cooldown - delta)
	rival_ability_cooldown = maxf(0.0, rival_ability_cooldown - delta)
	energy_regen_delay = maxf(0.0, energy_regen_delay - delta)
	player_boost_active = maxf(0.0, player_boost_active - delta)
	rival_boost_active = maxf(0.0, rival_boost_active - delta)
	player_turbo = maxf(0.0, player_turbo - delta)
	rival_turbo = maxf(0.0, rival_turbo - delta)
	rival_energy = minf(100.0, rival_energy + 13.0 * delta)
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
	_update_pickups(delta)
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
	var turbo_factor := 1.42 if player_turbo > 0.0 else 1.0
	# The elephant is intentionally heavier and slightly slower, but resists hits.
	var target_velocity := desired * DRIVE_SPEED * 0.9 * speed_factor * turbo_factor
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
	var wants_ability: bool = Input.is_key_pressed(KEY_E) or (hud != null and hud.consume_ability())
	if wants_ability and player_ability_cooldown <= 0.0:
		_activate_elephant_shockwave()
	player.move_and_slide()

func _update_rival(delta: float) -> void:
	if rival_stun > 0.0:
		rival.velocity = rival.velocity.move_toward(Vector3.ZERO, delta * 8.0)
		rival.move_and_slide()
		return
	var target_position := player.global_position
	var wanted_pickup := ""
	if rival_health < 48.0:
		wanted_pickup = "health"
	elif rival_energy < 34.0:
		wanted_pickup = "energy"
	var pickup_target := _nearest_active_pickup(rival.global_position, wanted_pickup)
	if pickup_target != Vector3.INF:
		target_position = pickup_target
	var offset := target_position - rival.global_position
	var distance := offset.length()
	var desired := offset.normalized() if distance > 0.1 else Vector3.ZERO
	var target_angle := atan2(desired.x, desired.z)
	rival.rotation.y = lerp_angle(rival.rotation.y, target_angle, delta * 3.8)
	var strafe := Vector3(-desired.z, 0, desired.x) * sin(Time.get_ticks_msec() * 0.0016) * 0.38
	var rival_speed := 20.0 if rival_turbo > 0.0 else 14.5
	var target_velocity := (desired + strafe).normalized() * rival_speed
	rival.velocity.x = move_toward(rival.velocity.x, target_velocity.x, 18.0 * delta)
	rival.velocity.z = move_toward(rival.velocity.z, target_velocity.z, 18.0 * delta)
	if rival_boost_cooldown <= 0.0 and distance < 12.0 and rival_energy >= 28.0 and wanted_pickup == "":
		rival.velocity += desired * 20.0
		rival_energy -= 28.0
		rival_boost_active = 0.5
		rival_boost_cooldown = rng.randf_range(2.4, 4.0)
	if rival_ability_cooldown <= 0.0 and distance < 9.5 and wanted_pickup == "":
		_activate_monkey_dash(desired)
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
		_show_damage(rival, 12.0, Color("ff9f35"))
		player_boost_active = 0.0
		camera_shake = 1.0
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.3
		return
	if rival_boost_active > 0.0:
		var resistance := 0.62 if energy <= 1.0 else 0.98
		if hud != null and hud.brace_pressed and energy > 0.0:
			resistance = 1.25
		player.velocity = -normal * 30.0 * (1.35 - resistance * 0.45)
		player.global_position -= normal * 0.28
		player_health = maxf(0.0, player_health - 9.0)
		_show_damage(player, 9.0, Color("ff9f35"))
		rival.velocity = normal * 3.0
		rival_boost_active = 0.0
		camera_shake = 0.9
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.3
		return
	var player_force := maxf(0.0, player.velocity.dot(normal))
	var rival_force := maxf(0.0, rival.velocity.dot(-normal))
	var brace: bool = (hud != null and hud.brace_pressed) or Input.is_key_pressed(KEY_SHIFT)
	var player_resistance := 0.98 if energy > 30.0 else 0.58
	if brace and energy > 0.0:
		player_resistance = 1.25
		energy = maxf(0.0, energy - BRACE_DRAIN * get_physics_process_delta_time())
		energy_regen_delay = ENERGY_REGEN_DELAY
	player.velocity -= normal * rival_force * (1.25 - player_resistance * 0.45)
	rival.velocity += normal * player_force * 0.78
	if hit_cooldown <= 0.0 and player_force + rival_force > 11.0:
		player_health = maxf(0.0, player_health - rival_force * 0.34)
		rival_health = maxf(0.0, rival_health - player_force * 0.34)
		if rival_force > 2.5:
			_show_damage(player, rival_force * 0.34, Color("ffbd55"))
		if player_force > 2.5:
			_show_damage(rival, player_force * 0.34, Color("ffbd55"))
		camera_shake = minf(1.0, (player_force + rival_force) / 28.0)
		_spawn_impact_flash((player.global_position + rival.global_position) * 0.5)
		hit_cooldown = 0.25

func _apply_arena_limits(body: CharacterBody3D) -> void:
	# Hovercrafts must stay at a fixed hover height. Some impulses are applied
	# close to raised hazards, so never allow a vertical component to accumulate.
	body.global_position.y = 0.9
	body.velocity.y = 0.0
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
	hud.turbo_seconds = player_turbo
	hud.ability_ratio = 1.0 - clampf(player_ability_cooldown / ELEPHANT_ABILITY_COOLDOWN, 0.0, 1.0)
	hud.ability_ready = player_ability_cooldown <= 0.0
	hud.player_map_position = Vector2(player.global_position.x, player.global_position.z)
	hud.rival_map_position = Vector2(rival.global_position.x, rival.global_position.z)
	hud.player_map_heading = player.rotation.y
	var camera: Camera3D = camera_rig.get_child(0)
	var rival_behind := camera.is_position_behind(rival.global_position)
	var rival_screen := camera.unproject_position(rival.global_position + Vector3.UP * 2.7)
	var viewport_size := get_viewport().get_visible_rect().size
	hud.rival_screen_position = rival_screen
	hud.rival_on_screen = not rival_behind and Rect2(Vector2(32, 96), viewport_size - Vector2(64, 150)).has_point(rival_screen)
	var camera_right := camera.global_transform.basis.x
	var to_rival := rival.global_position - camera.global_position
	hud.rival_warning_side = 1.0 if to_rival.dot(camera_right) >= 0.0 else -1.0

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("203d61")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8ec8ff")
	env.ambient_light_energy = 0.92
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-56, -32, 0)
	sun.light_color = Color("ffe1ad")
	sun.light_energy = 1.45
	sun.shadow_enabled = true
	add_child(sun)
	# The playable surface is a floating competition arena rather than a test plane.
	_make_box_static("Arena", Vector3(ARENA_HALF_WIDTH * 2.0, 0.7, ARENA_HALF_DEPTH * 2.0), Vector3(0, -0.4, 0), Color("211d38"))
	_make_box_visual(Vector3(ARENA_HALF_WIDTH * 2.0 + 8.0, 2.4, ARENA_HALF_DEPTH * 2.0 + 8.0), Vector3(0, -1.85, 0), Color("141329"), Color("39286a"), 0.35)
	_make_box_visual(Vector3(ARENA_HALF_WIDTH * 1.35, 3.0, ARENA_HALF_DEPTH * 1.35), Vector3(0, -4.25, 0), Color("0b0d1b"), Color("1c2450"), 0.18)
	_build_arena_floor_design()
	# Low arena rails keep the combat readable without hiding the horizon.
	_make_box_static("NorthBarrier", Vector3(ARENA_HALF_WIDTH * 2.0, 2.7, 1.2), Vector3(0, 0.95, -ARENA_HALF_DEPTH), Color("3c315e"))
	_make_box_static("SouthBarrier", Vector3(ARENA_HALF_WIDTH * 2.0, 2.7, 1.2), Vector3(0, 0.95, ARENA_HALF_DEPTH), Color("3c315e"))
	_make_box_static("WestBarrier", Vector3(1.2, 2.7, ARENA_HALF_DEPTH * 2.0), Vector3(-ARENA_HALF_WIDTH, 0.95, 0), Color("3c315e"))
	_make_box_static("EastBarrier", Vector3(1.2, 2.7, ARENA_HALF_DEPTH * 2.0), Vector3(ARENA_HALF_WIDTH, 0.95, 0), Color("3c315e"))
	_build_arena_architecture()
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
	_build_pickups()

func _build_arena_floor_design() -> void:
	# Large irregular combat zones replace every racing lane.
	_make_cylinder_visual(47.0, 0.06, Vector3(-62, 0.035, -18), Color("29413d"), Color("276b5b"), 0.42)
	_make_cylinder_visual(45.0, 0.06, Vector3(63, 0.038, 22), Color("413437"), Color("7d4935"), 0.42)
	_make_cylinder_visual(35.0, 0.07, Vector3(0, 0.045, 0), Color("332b4b"), Color("8857cf"), 0.72)
	_make_cylinder_visual(27.0, 0.075, Vector3(-92, 0.05, 62), Color("253d49"), Color("2b8faa"), 0.48)
	_make_cylinder_visual(27.0, 0.075, Vector3(94, 0.05, -61), Color("463340"), Color("b04c70"), 0.48)
	# Spacious team bases on opposite sides, sized for several hovercrafts.
	_make_cylinder_visual(19.0, 0.1, Vector3(-38, 0.06, 35), Color("173d5b"), Color("29bfff"), 2.0)
	_make_cylinder_visual(19.0, 0.1, Vector3(38, 0.06, -34), Color("59253f"), Color("ff4f7f"), 2.0)
	_make_cylinder_visual(12.5, 0.12, Vector3(-38, 0.12, 35), Color("203453"), Color("52dcff"), 1.15)
	_make_cylinder_visual(12.5, 0.12, Vector3(38, 0.12, -34), Color("512b42"), Color("ff769d"), 1.15)
	# The center is a contested plaza, not a road intersection.
	_make_cylinder_visual(24.0, 0.1, Vector3(0, 0.08, 0), Color("342852"), Color("9c55ff"), 1.25)
	_make_cylinder_visual(17.5, 0.11, Vector3(0, 0.14, 0), Color("211f3d"), Color("6038a8"), 0.65)

func _build_arena_architecture() -> void:
	# Solid rock clusters and ruined walls break sightlines for ambushes.
	for pos in [Vector3(-78, 1.5, -32), Vector3(-71, 1.5, 38), Vector3(-36, 1.5, -59), Vector3(-29, 1.5, 53), Vector3(32, 1.5, -55), Vector3(39, 1.5, 58), Vector3(72, 1.5, -35), Vector3(78, 1.5, 34)]:
		_make_rock_cover(pos)
	for pos in [Vector3(-53, 0.9, -13), Vector3(-51, 0.9, 17), Vector3(52, 0.9, -17), Vector3(54, 0.9, 14), Vector3(-10, 0.9, -35), Vector3(12, 0.9, 36)]:
		_make_ruin_wall(pos)
	# Dense bush pockets mark hiding positions while nearby stone provides collision cover.
	for pos in [Vector3(-96, 0.4, -45), Vector3(-92, 0.4, 49), Vector3(-52, 0.4, 70), Vector3(-19, 0.4, -73), Vector3(20, 0.4, 72), Vector3(54, 0.4, -70), Vector3(94, 0.4, -45), Vector3(96, 0.4, 48)]:
		_make_bush_cluster(pos)
	# Two open-sided shelters work as flank tunnels and short team regrouping spaces.
	_make_cover_arch(Vector3(-63, 0, 4), 0.0, Color("397063"))
	_make_cover_arch(Vector3(64, 0, -3), PI, Color("765044"))
	# Four large pylons frame the arena and make every quadrant recognizable.
	for pos in [Vector3(-126, 0.5, -80), Vector3(126, 0.5, -80), Vector3(-126, 0.5, 80), Vector3(126, 0.5, 80)]:
		_make_cylinder_static("ArenaPylon", 3.8, 2.4, pos, Color("332850"))
		_make_cylinder_visual(2.2, 6.5, pos + Vector3(0, 4.4, 0), Color("24203f"), Color("805cff"), 1.3)
		_make_cylinder_visual(0.65, 1.0, pos + Vector3(0, 8.1, 0), Color("bdefff"), Color("6ee7ff"), 3.5)
	# Raised visual islands give each hazard a designed location without changing driving height.
	_make_cylinder_visual(13.0, 0.07, gravity_trap_center + Vector3(0, 0.035, 0), Color("30254d"), Color("9f56ff"), 1.0)
	_make_cylinder_visual(13.0, 0.07, spike_trap_center + Vector3(0, 0.035, 0), Color("4b2238"), Color("ff416d"), 1.0)
	_make_cylinder_visual(13.0, 0.07, laser_trap_center + Vector3(0, 0.035, 0), Color("492d25"), Color("ff8c3d"), 1.0)

func _make_rock_cover(position: Vector3) -> void:
	_make_cylinder_static("RockCover", 4.2, 3.1, position, Color("3b4650"))
	_make_cylinder_static("RockCover", 2.8, 4.6, position + Vector3(3.4, 0.7, 1.7), Color("46535a"))
	_make_cylinder_static("RockCover", 2.4, 3.7, position + Vector3(-3.1, 0.35, -1.6), Color("35444a"))

func _make_ruin_wall(position: Vector3) -> void:
	_make_box_static("RuinWall", Vector3(10.0, 3.0, 2.2), position, Color("5a5264"))
	_make_box_static("RuinPillar", Vector3(2.2, 5.2, 2.8), position + Vector3(-4.2, 1.0, 0), Color("655a70"))
	_make_box_visual(Vector3(6.0, 0.14, 2.32), position + Vector3(1.0, 1.58, 0), Color("6e8d70"), Color("62b56e"), 0.65)

func _make_bush_cluster(position: Vector3) -> void:
	_make_cylinder_static("BushStone", 2.2, 1.5, position, Color("31463c"))
	add_child(_make_sphere(position + Vector3(0, 1.3, 0), Vector3(3.4, 1.8, 3.0), _material(Color("2e8052"), Color("42a55f"), 0.38)))
	add_child(_make_sphere(position + Vector3(2.4, 1.1, 0.8), Vector3(2.2, 1.45, 2.0), _material(Color("45a35c"), Color("65bd64"), 0.32)))
	add_child(_make_sphere(position + Vector3(-2.2, 1.0, -0.7), Vector3(2.0, 1.35, 1.9), _material(Color("236b49"), Color("3d9857"), 0.32)))

func _make_cover_arch(position: Vector3, yaw: float, color: Color) -> void:
	for x in [-6.0, 6.0]:
		var pillar := _make_box_static("ShelterPillar", Vector3(2.6, 5.4, 4.0), position + Vector3(x, 2.0, 0), color)
		pillar.rotation.y = yaw
	var roof := _make_box_static("ShelterRoof", Vector3(14.5, 1.2, 5.2), position + Vector3(0, 5.0, 0), color.darkened(0.12))
	roof.rotation.y = yaw

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
				_show_damage(body, 8.0, Color("ff9f35"))
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
			var key := "player" if body == player else "rival"
			if body == player:
				player_health = maxf(0.0, player_health - 5.5 * delta)
				camera_shake = maxf(camera_shake, 0.12)
			else:
				rival_health = maxf(0.0, rival_health - 5.5 * delta)
			if gravity_feedback_cooldowns[key] <= 0.0:
				_show_damage(body, 4.0, Color("b54cff"))
				gravity_feedback_cooldowns[key] = 0.75

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
		var escape_direction := body.global_position - spike_trap_center
		escape_direction.y = 0.0
		if escape_direction.length() > 8.1:
			continue
		var key := "player" if body == player else "rival"
		if spike_hit_cooldowns[key] > 0.0:
			continue
		body.velocity *= 0.72
		if escape_direction.length_squared() > 0.001:
			body.velocity += escape_direction.normalized() * 8.0
		body.velocity.y = 0.0
		body.global_position.y = 0.9
		if body == player:
			player_health = maxf(0.0, player_health - 7.0)
			camera_shake = maxf(camera_shake, 0.55)
		else:
			rival_health = maxf(0.0, rival_health - 7.0)
		_show_damage(body, 7.0, Color("ff4168"))
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
		_show_damage(body, 9.0, Color("ffad35"))
		laser_hit_cooldowns[key] = 0.85
		_spawn_impact_flash(body.global_position + Vector3.UP * 0.5)

func _build_pickups() -> void:
	var definitions := [
		["health", Vector3(-102, 0.8, 56)],
		["health", Vector3(108, 0.8, -12)],
		["energy", Vector3(-24, 0.8, -78)],
		["energy", Vector3(36, 0.8, 70)],
		["turbo", Vector3(-104, 0.8, -6)],
		["turbo", Vector3(112, 0.8, 72)]
	]
	for definition in definitions:
		var kind: String = definition[0]
		var position: Vector3 = definition[1]
		var holder := Node3D.new()
		holder.name = "Pickup_%s" % kind
		holder.position = position
		var color := Color("35ed72") if kind == "health" else (Color("ffb52e") if kind == "energy" else Color("28caff"))
		var orb := _make_sphere(Vector3.ZERO, Vector3(0.48, 0.48, 0.48), _material(color.lightened(0.18), color, 3.0))
		holder.add_child(orb)
		var ring := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.58
		ring_mesh.outer_radius = 0.72
		ring.mesh = ring_mesh
		ring.rotation.x = PI * 0.5
		ring.material_override = _material(color.darkened(0.2), color, 1.8)
		holder.add_child(ring)
		add_child(holder)
		pickups.append({"kind": kind, "node": holder, "position": position, "active": true, "respawn": 0.0, "phase": rng.randf_range(0.0, TAU)})

func _update_pickups(delta: float) -> void:
	for index in range(pickups.size()):
		var pickup: Dictionary = pickups[index]
		var node: Node3D = pickup.node
		if not pickup.active:
			pickup.respawn = maxf(0.0, pickup.respawn - delta)
			if pickup.respawn <= 0.0:
				pickup.active = true
				node.visible = true
			pickups[index] = pickup
			continue
		node.rotation.y += delta * 1.8
		node.position.y = 0.9 + sin(Time.get_ticks_msec() * 0.0025 + pickup.phase) * 0.24
		for candidate in [player, rival]:
			var body: CharacterBody3D = candidate
			if body.global_position.distance_to(pickup.position) > 2.35:
				continue
			_collect_pickup(body, pickup.kind)
			pickup.active = false
			pickup.respawn = 9.0
			node.visible = false
			pickups[index] = pickup
			break

func _collect_pickup(body: CharacterBody3D, kind: String) -> void:
	if body == player:
		if kind == "health":
			player_health = minf(100.0, player_health + 26.0)
		elif kind == "energy":
			energy = minf(100.0, energy + 48.0)
			energy_regen_delay = 0.0
		else:
			player_turbo = 4.5
		hud.show_pickup(kind)
	else:
		if kind == "health":
			rival_health = minf(100.0, rival_health + 26.0)
		elif kind == "energy":
			rival_energy = minf(100.0, rival_energy + 48.0)
		else:
			rival_turbo = 4.5
	_spawn_pickup_flash(body.global_position, kind)
	_play_tone(880.0 if kind == "turbo" else (720.0 if kind == "energy" else 620.0), 0.14, 0.2)

func _nearest_active_pickup(from: Vector3, kind: String) -> Vector3:
	if kind == "":
		return Vector3.INF
	var nearest := Vector3.INF
	var nearest_distance := INF
	for pickup in pickups:
		if not pickup.active or pickup.kind != kind:
			continue
		var distance: float = from.distance_squared_to(pickup.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = pickup.position
	return nearest

func _spawn_pickup_flash(position: Vector3, kind: String) -> void:
	var flash := OmniLight3D.new()
	flash.position = position + Vector3.UP
	flash.light_color = Color("35ed72") if kind == "health" else (Color("ffb52e") if kind == "energy" else Color("28caff"))
	flash.light_energy = 7.0
	flash.omni_range = 9.0
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 0.35)
	tween.tween_callback(flash.queue_free)

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

func _activate_elephant_shockwave() -> void:
	player_ability_cooldown = ELEPHANT_ABILITY_COOLDOWN
	var offset := rival.global_position - player.global_position
	offset.y = 0.0
	if offset.length() <= 9.5 and offset.length() > 0.1:
		rival.velocity += offset.normalized() * 31.0
		rival_stun = maxf(rival_stun, 0.72)
		rival_health = maxf(0.0, rival_health - 6.0)
		_show_damage(rival, 6.0, Color("46d9ff"))
		camera_shake = maxf(camera_shake, 0.55)
	_spawn_ability_ring(player.global_position, Color("43d7ff"), 9.5)
	_play_tone(235.0, 0.24, 0.22)

func _activate_monkey_dash(toward_player: Vector3) -> void:
	rival_ability_cooldown = MONKEY_ABILITY_COOLDOWN
	var side_sign := -1.0 if rng.randf() < 0.5 else 1.0
	var sideways := Vector3(-toward_player.z, 0, toward_player.x) * side_sign
	# A small backward component makes the dash useful as an actual dodge.
	rival.velocity = sideways.normalized() * 29.0 - toward_player * 7.0
	rival_boost_active = 0.0
	_spawn_ability_ring(rival.global_position, Color("ffd13b"), 4.2)
	_play_tone(510.0, 0.12, 0.16)

func _spawn_ability_ring(position: Vector3, color: Color, target_radius: float) -> void:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.78
	mesh.outer_radius = 1.0
	ring.mesh = mesh
	ring.position = position + Vector3.UP * 0.18
	ring.material_override = _material(color.darkened(0.22), color, 4.2)
	add_child(ring)
	var target_scale := Vector3.ONE * target_radius
	var tween := create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", target_scale, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "transparency", 1.0, 0.34)
	tween.chain().tween_callback(ring.queue_free)

func _show_damage(body: CharacterBody3D, amount: float, color: Color) -> void:
	var label := Label3D.new()
	label.text = "-%d" % maxi(1, roundi(amount))
	label.font_size = 48
	label.modulate = color
	label.outline_size = 10
	label.outline_modulate = Color(0.03, 0.02, 0.08, 0.9)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.global_position = body.global_position + Vector3.UP * 2.5
	add_child(label)
	var hit_light := OmniLight3D.new()
	hit_light.position = body.global_position + Vector3.UP * 0.8
	hit_light.light_color = color
	hit_light.light_energy = 4.5
	hit_light.omni_range = 5.5
	add_child(hit_light)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector3.UP * 2.0, 0.75)
	tween.tween_property(label, "modulate:a", 0.0, 0.75)
	tween.tween_property(hit_light, "light_energy", 0.0, 0.18)
	tween.chain().tween_callback(label.queue_free)
	tween.chain().tween_callback(hit_light.queue_free)
	_play_tone(155.0, 0.09, 0.14)

func _play_tone(frequency: float, duration: float, volume: float) -> void:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	var frames := int(stream.mix_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for index in range(frames):
		var fade := 1.0 - float(index) / float(frames)
		var sample := int(sin(TAU * frequency * float(index) / float(stream.mix_rate)) * 32767.0 * volume * fade)
		bytes[index * 2] = sample & 0xff
		bytes[index * 2 + 1] = (sample >> 8) & 0xff
	stream.data = bytes
	var audio := AudioStreamPlayer.new()
	audio.stream = stream
	audio.finished.connect(audio.queue_free)
	add_child(audio)
	audio.play()

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
	rival_energy = 100.0
	player_turbo = 0.0
	rival_turbo = 0.0
	player_ability_cooldown = 0.0
	rival_ability_cooldown = 2.4
	boost_cooldown = 0.0
	energy_regen_delay = 0.0
	rival_boost_cooldown = 1.2
	player_boost_active = 0.0
	rival_boost_active = 0.0
	rival_stun = 0.0
	spike_hit_cooldowns = {"player": 0.0, "rival": 0.0}
	laser_hit_cooldowns = {"player": 0.0, "rival": 0.0}
	gravity_feedback_cooldowns = {"player": 0.0, "rival": 0.0}
	for index in range(pickups.size()):
		pickups[index].active = true
		pickups[index].respawn = 0.0
		pickups[index].node.visible = true
	player.global_position = Vector3(-38, 0.9, 35)
	rival.global_position = Vector3(38, 0.9, -34)
	player.rotation.y = PI
	rival.rotation.y = 0.0
	player.velocity = Vector3.ZERO
	rival.velocity = Vector3.ZERO
	hud.result_text = ""

func _make_box_visual(size: Vector3, position: Vector3, color: Color, emission: Color, energy_value: float) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, emission, energy_value)
	add_child(mesh_instance)
	return mesh_instance

func _make_cylinder_visual(radius: float, height: float, position: Vector3, color: Color, emission: Color, energy_value: float) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color, emission, energy_value)
	add_child(mesh_instance)
	return mesh_instance

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
