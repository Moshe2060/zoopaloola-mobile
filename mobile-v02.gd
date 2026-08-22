extends Node2D

const BOARD_W := 207.0
const BOARD_H := 208.0
const RADIUS := 6.0
const GAME_BALL_VISUAL_SCALE := 1.25
# Releasing inside this short pull distance cancels aiming. A slightly longer
# pull becomes a shot, giving touch and mouse players a natural way to switch balls.
const MIN_SHOT_PULL := 6.0
const SUBSTEPS := 10
const STEP_TIME := 0.005
# Collision rails fitted to the visible inner stone edge of the modular board.
# The previous board used 38/165 and 27/183, leaving a visible air gap before
# the ball reached the new stones.
const WALL_MIN_X := 33.0
const WALL_MAX_X := 180.0
const WALL_MIN_Y := 22.0
const WALL_MAX_Y := 188.0
# Openings are deliberately wider than on the legacy board, but scoring is a
# separate deeper line. This prevents a near miss from triggering a weapon.
const CORNER_OPEN_LOW := 56.0
const CORNER_OPEN_HIGH := 151.0
const MIDDLE_OPEN_MIN := 76.0
const MIDDLE_OPEN_MAX := 133.0
const SIDE_OPEN_LOW := 67.0
const SIDE_OPEN_HIGH := 141.0
const HOLE_CAPTURE_DEPTH := 2.0
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
const HERO_HAND_COLORS := [
	Color("8799a2"), Color("343434"), Color("9b541f"),
	Color("e49aa2"), Color("777187"), Color("c88938")
]
const UI_TEXT_HE := {
	"player": "שחקן 1", "level": "רמה 1 • שחקן מתחיל",
	"choose_mode": "בחרו מצב משחק",
	"characters": "דמויות", "characters_sub": "בחירת החיה שלכם",
	"rings": "גלגלים", "rings_sub": "בחירת הצבע שלכם",
	"shop": "חנות", "shop_sub": "פריטים ושדרוגים",
	"rewards": "פרסים", "rewards_sub": "מתנות ופרסים",
	"arena": "זירה אונליין", "arena_sub": "משחק מול יריב אקראי",
	"friend": "משחק מול חבר", "friend_sub": "משחק פרטי • שני מכשירים",
	"computer": "משחק מול המחשב", "computer_sub": "שחקן יחיד • נגד המחשב",
	"back": "חזרה", "choose_character": "בחירת דמות", "choose_character_sub": "בחרו חיה וצבע גלגל הצלה",
	"choose_ring": "בחרו גלגל הצלה", "choose_ring_sub": "הצבע שבחרתם יופיע בכל משחק",
	"choose_animal": "בחרו חיה", "red": "אדום", "orange": "כתום", "blue": "כחול", "green": "ירוק", "purple": "סגול", "turquoise": "טורקיז",
	"elephant": "פיל", "zebra": "זברה", "monkey": "קוף", "hippo": "היפופוטם", "rhino": "קרנף", "giraffe": "ג׳ירפה",
	"arena_title": "בחירת זירה", "arena_title_sub": "בחרו את מגרש המשחק לקרב האונליין",
	"sakura": "גן הסאקורה", "bamboo": "חורשת הבמבוק", "volcano": "מקדש הגעש",
	"entry_free": "כניסה: חינם", "entry": "דמי כניסה: ", "coins": " מטבעות", "prize": "פרס ניצחון: ", "selected": "נבחר", "find_match": "חיפוש יריב אונליין",
	"profile_title": "פרופיל שחקן", "profile_sub": "הדמות, הצבע האהוב וסטטיסטיקות הקריירה שלכם",
	"main_character": "הדמות הראשית", "choose_main": "בחרו דמות ראשית", "favorite_color": "צבע גלגל אהוב",
	"career": "סטטיסטיקות קריירה", "matches": "משחקים", "wins": "ניצחונות", "losses": "הפסדים", "win_rate": "אחוז הצלחה", "best_streak": "רצף שיא", "world_rank": "דירוג עולמי", "current_streak": "רצף ניצחונות נוכחי: ",
	"shop_title": "החנות של זופלולה", "shop_title_sub": "דמויות, גלגלים ואפקטים מיוחדים", "effects": "אפקטים", "collection_info": "אוספים נדירים\nעיצובים עונתיים\nאנימציות מיוחדות", "coming_soon": "בקרוב",
}
const UI_TEXT_EN := {
	"player": "PLAYER 1", "level": "LEVEL 1 • ROOKIE EXPLORER",
	"choose_mode": "CHOOSE A GAME MODE",
	"characters": "CHARACTERS", "characters_sub": "Choose your animal",
	"rings": "LIFEBUOYS", "rings_sub": "Choose your color",
	"shop": "SHOP", "shop_sub": "Items and upgrades",
	"rewards": "REWARDS", "rewards_sub": "Gifts and prizes",
	"arena": "ONLINE ARENA", "arena_sub": "Play a random opponent",
	"friend": "PLAY A FRIEND", "friend_sub": "Private match • two devices",
	"computer": "PLAY VS COMPUTER", "computer_sub": "Single player • vs AI",
	"back": "BACK", "choose_character": "CHOOSE YOUR CHARACTER", "choose_character_sub": "Pick an animal and a lifebuoy color",
	"choose_ring": "CHOOSE A LIFEBUOY", "choose_ring_sub": "Your color follows you into every match",
	"choose_animal": "CHOOSE AN ANIMAL", "red": "RED", "orange": "ORANGE", "blue": "BLUE", "green": "GREEN", "purple": "PURPLE", "turquoise": "TURQUOISE",
	"elephant": "ELEPHANT", "zebra": "ZEBRA", "monkey": "MONKEY", "hippo": "HIPPO", "rhino": "RHINO", "giraffe": "GIRAFFE",
	"arena_title": "CHOOSE YOUR ARENA", "arena_title_sub": "Select the battleground for your online match",
	"sakura": "SAKURA GARDEN", "bamboo": "BAMBOO GROVE", "volcano": "VOLCANO TEMPLE",
	"entry_free": "ENTRY: FREE", "entry": "ENTRY: ", "coins": " COINS", "prize": "WIN PRIZE: ", "selected": "SELECTED", "find_match": "FIND ONLINE MATCH",
	"profile_title": "PLAYER PROFILE", "profile_sub": "Your character, favorite color and career statistics",
	"main_character": "MAIN CHARACTER", "choose_main": "CHOOSE YOUR MAIN ANIMAL", "favorite_color": "FAVORITE LIFEBUOY COLOR",
	"career": "CAREER STATISTICS", "matches": "MATCHES", "wins": "WINS", "losses": "LOSSES", "win_rate": "WIN RATE", "best_streak": "BEST STREAK", "world_rank": "WORLD RANK", "current_streak": "CURRENT WIN STREAK: ",
	"shop_title": "ZOOPA SHOP", "shop_title_sub": "Characters, lifebuoys and signature effects", "effects": "EFFECTS", "collection_info": "Rare collections\nSeasonal designs\nSpecial animations", "coming_soon": "COMING SOON",
}
const APP_SPLASH := 0
const APP_HOME := 1
const APP_PROFILE := 2
const APP_SHOP := 3
const APP_GAME := 4
const APP_ARENA := 5
const APP_PLAYER_PROFILE := 6
var board_texture: Texture2D
var ui_font: Font
var lobby_background_texture: Texture2D
var loading_team_texture: Texture2D
var zoopaloola_logo_texture: Texture2D
var wood_podium_texture: Texture2D
var piece_textures: Array[Texture2D] = []
var animal_textures: Array[Texture2D] = []
var full_body_animal_textures: Array[Texture2D] = []
var lifebuoy_hero_textures: Array = []
var animal_ring_masks: Array[Texture2D] = []
var team_piece_textures: Array[Texture2D] = []
var effect_textures: Array[Texture2D] = []
var rubber_ball_texture: Texture2D
var rubber_hand_textures: Array[Texture2D] = []
var rubber_launcher_texture: Texture2D
var rubber_wrap_texture: Texture2D
var press_machine_texture: Texture2D
var fire_launcher_texture: Texture2D
var hammer_texture: Texture2D
var hammer_base_texture: Texture2D
var hammer_idle_texture: Texture2D
var hammer_swing_texture: Texture2D
var hammer_head_side_texture: Texture2D
var hammer_impact_texture: Texture2D
var balls: Array = []
var active_effects: Array = []
var water_floaters: Array = []
var contacts := {}

# Touch-friendly rubber effect editor. Values are stored in board-image units.
var effect_editor_enabled := false
var effect_editor_mode := "electric"
var editor_selected_hand := 0
var rubber_top_offset := Vector2(-60.0, -10.0)
var rubber_side_offset := Vector2(20.0, 20.0)
var rubber_top_width := 72.0
var rubber_side_width := 72.0
var rubber_top_rotation := deg_to_rad(-20.0)
var rubber_side_rotation := deg_to_rad(-5.0)
var rubber_top_mirror := false
var rubber_side_mirror := false
var electric_top_offset := Vector2(-74.0, -78.0)
var electric_right_offset := Vector2(70.0, 58.0)
var electric_top_size := 34.0
var electric_right_size := 34.0
var editor_hole := ELECTRIC_TRAP_HOLE
var editor_target := 0 # 0=weapon 1, 1=weapon 2, 2=ball, 3=fall, 4=entry, 5=table wall
# Approved trap editor snapshot (2026-08-21):
# ICE: weapon1=(26,1) 1.00; weapon2=(-16,2) 1.00; ball=(5,20) 1.00; fall=(0,0); entry=(1,19) radius=11; wall=bottom offset=8 size=1
# FIRE: weapon1=(-5,-10) 1.00; weapon2=(10,0) 1.00; ball=(0,10) 1.00; fall=(-30,-60); entry=(-12,14) radius=12; wall=left offset=-2 size=1
# HAMMER: weapon1=(20,5) 1.10; weapon2=(0,5) 1.00; ball=(10,20) 1.00; fall=(0,0); entry=(12,14) radius=12; wall=right offset=5 size=1
# ELECTRIC: weapon1=(10,40) 1.20; weapon2=(-27,-3) 1.20; ball=(35,-5) 1.00; fall=(-15,45); entry=(11,-2) radius=12; wall=top offset=-7 size=1
# PRESS: weapon1=(-3,0) 1.00; weapon2=(14,-1) 1.00; ball=(4,-5) 1.00; fall=(0,30); entry=(-1,-11) radius=12; wall=top offset=-7 size=1
# RUBBER: weapon1=(0,15) 1.00; weapon2=(10,-5) 1.00; ball=(-10,-15) 1.00; fall=(20,55); entry=(-13,0) radius=13; wall=left offset=-2 size=1
var trap_weapon_offsets: Array[Vector2] = [
	Vector2(0.0, 15.0), Vector2(10.0, -5.0),
	Vector2(-3.0, 0.0), Vector2(14.0, -1.0),
	Vector2(10.0, 40.0), Vector2(-27.0, -3.0),
	Vector2(20.0, 5.0), Vector2(0.0, 5.0),
	Vector2(26.0, 1.0), Vector2(-16.0, 2.0),
	Vector2(-5.0, -10.0), Vector2(10.0, 0.0)
]
var trap_weapon_scales: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.2, 1.2, 1.1, 1.0, 1.0, 1.0, 1.0, 1.0]
var trap_ball_offsets: Array[Vector2] = [Vector2(-10.0, -15.0), Vector2(4.0, -5.0), Vector2(35.0, -5.0), Vector2(10.0, 20.0), Vector2(5.0, 20.0), Vector2(0.0, 10.0)]
var trap_ball_scales: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
var trap_fall_offsets: Array[Vector2] = [Vector2(20.0, 55.0), Vector2(0.0, 30.0), Vector2(-15.0, 45.0), Vector2.ZERO, Vector2.ZERO, Vector2(-30.0, -60.0)]
var trap_entry_offsets: Array[Vector2] = [
	Vector2(-13.0, 0.0), Vector2(-1.0, -11.0), Vector2(11.0, -2.0),
	Vector2(12.0, 14.0), Vector2(1.0, 19.0), Vector2(-12.0, 14.0)
]
var trap_entry_radii: Array[float] = [13.0, 12.0, 12.0, 12.0, 11.0, 12.0]
var table_wall_offsets: Array[float] = [-2.0, -7.0, 5.0, 8.0] # left, top, right, bottom
var table_wall_sizes: Array[float] = [1.0, 1.0, 1.0, 1.0]
# Mobile browsers may emit a synthetic mouse click after every touch.
# Once real touch input is seen, ignore those duplicate mouse events.
var touchscreen_input_seen := false
var app_screen := APP_HOME
var splash_elapsed := 0.0
var menu_elapsed := 0.0
var game_mode := "computer"
var profile_name := "PLAYER 1"
var player_coins := 1250
var selected_arena := 0
var ui_language := "he"
var player_level := 1
var player_xp := 100
var player_next_level_xp := 500
var player_wins := 12
var player_losses := 4
var player_best_streak := 5
var player_current_streak := 3
var player_world_rank := 6394
var menu_notice := ""
var menu_notice_time := 0.0

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
var customizer_open := false
# Start with the combination requested during the visual review: zebra + green.
var player_animal := 1
var player_ring_color := 3
var ai_animal := 0
var ai_ring_color := 0

func _ready() -> void:
	# Smooth the original character art when it is enlarged inside HD balls.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Bundled font includes Hebrew and Latin glyphs, so Web/Android render the
	# same readable interface without depending on fonts installed on the device.
	ui_font = load("res://assets/ui/fonts/DejaVuSans-Bold.ttf") as Font
	board_texture = load("res://assets/board-clean-modular.webp") as Texture2D
	lobby_background_texture = load("res://assets/ui/zoopaloola-home-bg-v3.webp") as Texture2D
	loading_team_texture = load("res://assets/ui/zoopaloola-loading-team-v1.webp") as Texture2D
	zoopaloola_logo_texture = load("res://assets/ui/zoopaloola-logo-v1.webp") as Texture2D
	wood_podium_texture = load("res://assets/ui/full_body/lifebuoy/wood-podium-v1.png") as Texture2D
	if board_texture == null:
		push_error("Clean original board could not be loaded.")
	for file_name in ["59_id_040.png", "60_id_041.png", "61_id_042.png", "62_id_043.png", "63_id_044.png"]:
		piece_textures.append(load("res://assets/pieces/" + file_name))
	for animal_file in ANIMAL_FILES:
		animal_textures.append(load("res://assets/animal_pieces/%s.png" % animal_file))
		animal_ring_masks.append(load("res://assets/animal_pieces/%s-ring-mask.png" % animal_file))
		full_body_animal_textures.append(load("res://assets/ui/full_body/%s.webp" % animal_file))
		var hero_colors: Array[Texture2D] = []
		for ring_name in RING_COLOR_NAMES:
			hero_colors.append(load("res://assets/ui/full_body/lifebuoy/%s-%s.png" % [animal_file, ring_name.to_lower()]) as Texture2D)
		lifebuoy_hero_textures.append(hero_colors)
	rebuild_team_piece_textures()
	for i in 6:
		effect_textures.append(load("res://assets/remastered_effects/effect-%d.png" % i))
	rubber_ball_texture = load("res://assets/rubber_trap/rubber-ball.png") as Texture2D
	for i in 5:
		rubber_hand_textures.append(load("res://assets/rubber_trap/hands/pose-%d.png" % i))
	rubber_launcher_texture = load("res://assets/rubber_launcher/launcher.svg") as Texture2D
	rubber_wrap_texture = load("res://assets/rubber_launcher/wrap-sequence.svg") as Texture2D
	press_machine_texture = load("res://assets/press_trap/industrial-press.svg") as Texture2D
	fire_launcher_texture = load("res://assets/fire_trap/flamethrower-v2.svg") as Texture2D
	hammer_texture = load("res://assets/hammer_trap/mechanical-hammer-v2.svg") as Texture2D
	hammer_base_texture = load("res://assets/hammer_trap/remastered/hammer-base.png") as Texture2D
	hammer_idle_texture = load("res://assets/hammer_trap/remastered/hammer-idle.png") as Texture2D
	hammer_swing_texture = load("res://assets/hammer_trap/remastered/hammer-swing.png") as Texture2D
	hammer_head_side_texture = load("res://assets/hammer_trap/remastered/hammer-head-side.png") as Texture2D
	hammer_impact_texture = load("res://assets/hammer_trap/remastered/hammer-impact.png") as Texture2D
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
	# Grow the entire table uniformly by using more vertical space. Keeping the
	# source aspect ratio avoids stretching the stones or center circle.
	var top_margin := 60.0
	var bottom_margin := 12.0
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
	menu_elapsed += delta
	if app_screen == APP_SPLASH:
		splash_elapsed += delta
		if splash_elapsed >= 3.2:
			app_screen = APP_HOME
		queue_redraw()
		return
	if app_screen != APP_GAME:
		if menu_notice_time > 0.0:
			menu_notice_time -= delta
		queue_redraw()
		return
	accumulator += delta
	while accumulator >= STEP_TIME:
		physics_step()
		accumulator -= STEP_TIME
	update_effects(delta)
	update_water_floaters(delta)
	if ai_pending and effects_allow_next_turn():
		ai_timer -= delta
		if ai_timer <= 0.0 and not any_ball_moving():
			ai_pending = false
			ai_shot()
	queue_redraw()

func effects_allow_next_turn() -> bool:
	# The capture/crush portion must finish, but the longer fall and water
	# continuation may keep playing while the next player starts aiming.
	for effect in active_effects:
		var unlock_time := TRAP_CAPTURE_TIME
		if effect.hole not in [RUBBER_TRAP_HOLE, PRESS_TRAP_HOLE, ELECTRIC_TRAP_HOLE, HAMMER_TRAP_HOLE, ICE_TRAP_HOLE, FIRE_TRAP_HOLE]:
			unlock_time = EFFECT_DURATION * 0.58
		if effect.elapsed < unlock_time:
			return false
	return true

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
	if game_mode == "computer" and turn == 1 and not ai_pending and not any_ball_moving() and effects_allow_next_turn():
		finish_ai_turn()

func resolve_walls(index: int) -> void:
	var ball: Dictionary = balls[index]
	var p: Vector2 = ball.p
	var v: Vector2 = ball.v
	var vertical_open := p.y < CORNER_OPEN_LOW or (p.y > MIDDLE_OPEN_MIN and p.y < MIDDLE_OPEN_MAX) or p.y > CORNER_OPEN_HIGH
	var horizontal_open := p.x < SIDE_OPEN_LOW or p.x > SIDE_OPEN_HIGH
	var wall_min_x := effective_wall_min_x()
	var wall_max_x := effective_wall_max_x()
	var wall_min_y := effective_wall_min_y()
	var wall_max_y := effective_wall_max_y()
	if p.x - RADIUS < wall_min_x:
		if vertical_open:
			# Capture only after the ball center is genuinely behind the rail.
			var hole := hole_for_vertical(p.y, true)
			if entry_triggered(p, hole): score_ball(index, hole); return
		# The visual opening is wider than the editable ENTRY circle. Everything
		# outside that circle must still behave as a rail instead of leaking out.
		p.x = wall_min_x + RADIUS; v.x = abs(v.x) * 0.75
	elif p.x + RADIUS > wall_max_x:
		if vertical_open:
			var hole := hole_for_vertical(p.y, false)
			if entry_triggered(p, hole): score_ball(index, hole); return
		p.x = wall_max_x - RADIUS; v.x = -abs(v.x) * 0.75
	if p.y - RADIUS < wall_min_y:
		if horizontal_open:
			var hole := 2 if p.x < 104.0 else 3
			if entry_triggered(p, hole): score_ball(index, hole); return
		p.y = wall_min_y + RADIUS; v.y = abs(v.y) * 0.75
	elif p.y + RADIUS > wall_max_y:
		if horizontal_open:
			var hole := 0 if p.x < 104.0 else 5
			if entry_triggered(p, hole): score_ball(index, hole); return
		p.y = wall_max_y - RADIUS; v.y = -abs(v.y) * 0.75
	ball.p = p; ball.v = v

func hole_for_vertical(y: float, left: bool) -> int:
	var k := 0 if y < CORNER_OPEN_LOW else (1 if y < MIDDLE_OPEN_MAX else 2)
	return 2 - k if left else 3 + k

func editor_wall_side(hole: int) -> int:
	match hole:
		0, 5: return 0 # visible left
		1, 2: return 1 # visible top
		3: return 2 # visible right
		4: return 3 # visible bottom
	return 0

func effective_wall_min_x() -> float:
	return WALL_MIN_X + table_wall_offsets[1] + (table_wall_sizes[1] - 4.0) * 0.5

func effective_wall_max_x() -> float:
	return WALL_MAX_X + table_wall_offsets[3] - (table_wall_sizes[3] - 4.0) * 0.5

func effective_wall_min_y() -> float:
	return WALL_MIN_Y - table_wall_offsets[2] + (table_wall_sizes[2] - 4.0) * 0.5

func effective_wall_max_y() -> float:
	return WALL_MAX_Y - table_wall_offsets[0] - (table_wall_sizes[0] - 4.0) * 0.5

func entry_trigger_center(hole: int) -> Vector2:
	# ENTRY offsets use the visible screen axes. Convert them back into the
	# rotated physics coordinates used by the board.
	var offset := trap_entry_offsets[hole]
	return SCORING_HOLE_CENTERS[hole] + Vector2(offset.y, -offset.x)

func entry_triggered(ball_position: Vector2, hole: int) -> bool:
	return ball_position.distance_to(entry_trigger_center(hole)) <= trap_entry_radii[hole]

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
	var endpoint := board_to_screen(SCORING_HOLE_CENTERS[hole])
	match hole:
		RUBBER_TRAP_HOLE:
			endpoint = rubber_point(2.0, 22.0)
		PRESS_TRAP_HOLE:
			# Stop in the narrow water strip above the table instead of continuing
			# behind the HUD and outside the visible screen.
			endpoint = press_point(621.0, -12.0)
		ELECTRIC_TRAP_HOLE:
			endpoint = electric_point(1198.0, 22.0)
		HAMMER_TRAP_HOLE:
			endpoint = hammer_point(1198.0, 598.0)
		ICE_TRAP_HOLE:
			# Match the visible water strip immediately below the table.
			endpoint = ice_point(600.0, 612.0)
		FIRE_TRAP_HOLE:
			endpoint = fire_point(112.0, 536.0) + Vector2(-54.0, 76.0) * scale_y
	return endpoint + trap_fall_offsets[hole] * scale_y

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
	if app_screen != APP_GAME:
		handle_frontend_touch(screen_pos)
		return
	if Rect2(8.0, 6.0, 116.0, 42.0).has_point(screen_pos):
		app_screen = APP_HOME
		selected = -1
		dragging = false
		active_effects.clear()
		queue_redraw()
		return
	if handle_customizer_touch(screen_pos):
		return
	if handle_effect_editor_touch(screen_pos):
		return
	if Rect2(get_viewport_rect().size.x - 454.0, 6.0, 105.0, 42.0).has_point(screen_pos):
		if not any_ball_moving() and effects_allow_next_turn():
			customizer_open = true
			queue_redraw()
		return
	if Rect2(get_viewport_rect().size.x - 174.0, 6.0, 150.0, 42.0).has_point(screen_pos):
		new_game(); return
	if (game_mode == "computer" and turn != 0) or any_ball_moving() or not effects_allow_next_turn(): return
	var board_pos := screen_to_board(screen_pos)
	for i in balls.size():
		if balls[i].alive and balls[i].team == turn and balls[i].p.distance_to(board_pos) <= 16.0:
			selected = i
			dragging = true
			drag_point = board_pos
			status = "Pull back and release"
			return

func pointer_move(screen_pos: Vector2) -> void:
	if dragging and selected >= 0:
		drag_point = screen_to_board(screen_pos)
		var pull_distance: float = balls[selected].p.distance_to(drag_point)
		status = "Release to shoot" if pull_distance >= MIN_SHOT_PULL else "Release to cancel"

func pointer_up(screen_pos: Vector2) -> void:
	if not dragging or selected < 0: return
	drag_point = screen_to_board(screen_pos)
	var pull: Vector2 = balls[selected].p - drag_point
	var pull_distance: float = pull.length()
	var strength: float = clampf(pull_distance, MIN_SHOT_PULL, 30.0)
	if pull_distance >= MIN_SHOT_PULL:
		balls[selected].v = pull.normalized() * (strength * 0.078)
		if game_mode == "computer":
			turn = 1
			ai_pending = true
			ai_timer = 0.28
			status = "Computer's turn"
		else:
			turn = 1 - turn
			ai_pending = false
			status = ("Red" if turn == 0 else "Blue") + " player's turn"
	else:
		status = "Aim cancelled - choose another ball"
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
	balls[shooter].v = direction.normalized() * randf_range(1.25, 2.2)
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
		draw_string(ui_font, Vector2(0, viewport_size.y * 0.44), "ROTATE YOUR PHONE", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 28, Color("f6d365"))
		draw_string(ui_font, Vector2(0, viewport_size.y * 0.50), "Zoopaloola is designed for landscape mode", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 18, Color.WHITE)
		return
	if app_screen == APP_SPLASH:
		draw_splash_screen(viewport_size)
		return
	if app_screen != APP_GAME:
		draw_frontend(viewport_size)
		return
	# Floating animals stay behind the elevated table and only remain visible on
	# the surrounding water.
	draw_water_floaters(viewport_size)
	# Approved faithful remaster, created natively in landscape.
	draw_texture_rect(board_texture, board_rect, false)
	draw_scoreboards()
	draw_rubber_launchers_idle()
	draw_press_weapons_idle()
	draw_electric_weapons_idle()
	draw_ice_weapons_idle()
	draw_fire_weapons_idle()
	draw_hammer_weapons_idle()

	for i in balls.size():
		var ball: Dictionary = balls[i]
		if not ball.alive: continue
		var sp := board_to_screen(ball.p)
		var visual_radius := RADIUS * board_scale * GAME_BALL_VISUAL_SCALE
		if ball.team == turn and not effect_editor_enabled and not customizer_open:
			var pulse := (sin(float(Time.get_ticks_msec()) * 0.006) + 1.0) * 0.5
			var halo_radius := visual_radius * (1.34 + pulse * 0.10)
			draw_circle(sp, halo_radius, Color(0.54, 1.0, 0.62, 0.16 + pulse * 0.08))
			draw_circle(sp, halo_radius, Color(0.76, 1.0, 0.80, 0.68), false, maxf(2.0, visual_radius * 0.12), true)
		draw_rubber_game_ball(sp, visual_radius, ball.team, i, 1.0)

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
		draw_original_style_aim(start, end)

	draw_ball_hitbox_editor_overlay()
	draw_entry_editor_marker()
	draw_table_wall_editor_overlay()

	draw_hud(viewport_size)
	draw_effect_editor(viewport_size)
	draw_customizer(viewport_size)

func draw_aim_arrow(origin: Vector2, direction: Vector2, length: float) -> void:
	var tip := origin + direction * length
	var head_base := tip - direction * 22.0
	var normal := Vector2(-direction.y, direction.x)
	var arrow_color := Color(0.86, 1.0, 0.88, 0.88)
	# Soft wide glow plus a solid inner shaft reproduces the chunky original
	# direction arrow and keeps it readable over the green field.
	draw_line(origin, head_base, Color(0.78, 1.0, 0.82, 0.24), 18.0, true)
	draw_line(origin, head_base, arrow_color, 8.0, true)
	var head := PackedVector2Array([
		tip,
		head_base + normal * 15.0,
		head_base - normal * 15.0
	])
	draw_colored_polygon(head, arrow_color)

func predicted_aim_collision(origin: Vector2, direction: Vector2, combined_radius: float) -> Dictionary:
	var best_distance := INF
	var best_center := Vector2.ZERO
	for i in balls.size():
		if i == selected or not balls[i].alive:
			continue
		# Perform prediction in the same portrait physics coordinates used by
		# resolve_collision(). Screen coordinates are rotated and stretched.
		var center: Vector2 = balls[i].p
		var delta := center - origin
		var along := delta.dot(direction)
		if along <= 0.0:
			continue
		var perpendicular_squared := delta.length_squared() - along * along
		var radius_squared := combined_radius * combined_radius
		if perpendicular_squared > radius_squared:
			continue
		var contact_distance := along - sqrt(maxf(0.0, radius_squared - perpendicular_squared))
		if contact_distance < best_distance:
			best_distance = contact_distance
			best_center = center
	if best_distance == INF:
		return {}
	var moving_center_at_contact := origin + direction * best_distance
	var target_direction := (best_center - moving_center_at_contact).normalized()
	return {
		"distance": best_distance,
		"center": best_center,
		"direction": target_direction
	}

func draw_original_style_aim(ball_center: Vector2, pull_point: Vector2) -> void:
	var screen_pull := pull_point - ball_center
	var physics_origin: Vector2 = balls[selected].p
	var physics_shot := physics_origin - drag_point
	if screen_pull.length_squared() < 4.0 or physics_shot.length_squared() < 0.01:
		return
	var physics_direction := physics_shot.normalized()
	var shot_direction := (board_to_screen(physics_origin + physics_direction) - ball_center).normalized()
	var pull_direction := -shot_direction
	var visual_ball_radius := RADIUS * board_scale * GAME_BALL_VISUAL_SCALE
	var pull_length := screen_pull.length()

	# Mechanical cue behind the ball: dark outline, silver body, highlight and
	# the pale round cap visible in the supplied original-game screenshot.
	var cue_near := ball_center + pull_direction * (visual_ball_radius * 0.92)
	var cue_length := clampf(pull_length, 72.0, 142.0)
	var cue_far := cue_near + pull_direction * cue_length
	var cue_normal := Vector2(-pull_direction.y, pull_direction.x)
	draw_line(cue_near, cue_far, Color("17212b"), 18.0, true)
	draw_line(cue_near, cue_far, Color("697985"), 12.0, true)
	draw_line(cue_near + cue_normal * 2.0, cue_far + cue_normal * 2.0, Color("d9e2e6"), 4.0, true)
	draw_circle(cue_far, 11.0, Color("263441"))
	draw_circle(cue_far, 7.5, Color("c7d9ef"))
	draw_circle(cue_near, 6.0, Color("d6e0e5"))

	var arrow_start := ball_center + shot_direction * (visual_ball_radius * 1.10)
	var arrow_length := clampf(pull_length * 1.18, 88.0, 175.0)
	var collision := predicted_aim_collision(physics_origin, physics_direction, RADIUS * 2.0)
	if collision.is_empty():
		draw_aim_arrow(arrow_start, shot_direction, arrow_length)
	else:
		# Stop the shooter's guide at the predicted contact point and show the
		# second arrow on the ball that will receive the impact.
		var contact_center := board_to_screen(physics_origin + physics_direction * float(collision.distance))
		var contact_length: float = maxf(34.0, (contact_center - arrow_start).dot(shot_direction))
		draw_aim_arrow(arrow_start, shot_direction, contact_length)
		var target_physics_center: Vector2 = collision.center
		var target_physics_direction: Vector2 = collision.direction
		var target_center := board_to_screen(target_physics_center)
		var target_direction := (board_to_screen(target_physics_center + target_physics_direction) - target_center).normalized()
		var target_start := target_center + target_direction * (visual_ball_radius * 1.10)
		var target_length := clampf(pull_length * 0.82, 62.0, 128.0)
		draw_aim_arrow(target_start, target_direction, target_length)

func draw_entry_editor_marker() -> void:
	if not effect_editor_enabled or editor_target != 4:
		return
	var trigger_center := entry_trigger_center(editor_hole)
	var marker := board_to_screen(trigger_center)
	var radius := trap_entry_radii[editor_hole]
	var color := Color("ffdf3d")
	var glow := Color(1.0, 0.24, 0.18, 0.30)
	var ring := PackedVector2Array()
	for i in 49:
		var angle := TAU * float(i) / 48.0
		ring.append(board_to_screen(trigger_center + Vector2(cos(angle), sin(angle)) * radius))
	draw_colored_polygon(ring, Color(1.0, 0.24, 0.18, 0.14))
	draw_polyline(ring, color, 4.0, true)
	draw_circle(marker, 19.0, glow)
	draw_circle(marker, 12.0, color, false, 4.0, true)
	draw_line(marker + Vector2(-22.0, 0.0), marker + Vector2(22.0, 0.0), color, 3.0, true)
	draw_line(marker + Vector2(0.0, -22.0), marker + Vector2(0.0, 22.0), color, 3.0, true)
	draw_string(ui_font, marker + Vector2(-34.0, -27.0), "ENTRY", HORIZONTAL_ALIGNMENT_CENTER, 68.0, 13, Color.WHITE)

func draw_physics_radius_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	var ring := PackedVector2Array()
	for i in 33:
		var angle := TAU * float(i) / 32.0
		ring.append(board_to_screen(center + Vector2(cos(angle), sin(angle)) * radius))
	draw_polyline(ring, color, width, true)

func draw_ball_hitbox_editor_overlay() -> void:
	if not effect_editor_enabled or editor_target not in [2, 4, 5]:
		return
	var color := Color(0.20, 0.92, 1.0, 0.90)
	# Outline the real collision radius around every live gameplay ball.
	for ball in balls:
		if ball.alive:
			draw_physics_radius_ring(ball.p, RADIUS, color, 3.0)
	# Also place a same-size reference ring at the selected hole so ENTRY and
	# WALL can be compared directly with the incoming ball's collider.
	if editor_target == 4 or editor_target == 5:
		var center := entry_trigger_center(editor_hole)
		draw_physics_radius_ring(center, RADIUS, Color(0.20, 0.92, 1.0, 0.72), 3.0)
		var label_position := board_to_screen(center) + Vector2(-48.0, 38.0)
		draw_string(ui_font, label_position, "BALL HITBOX", HORIZONTAL_ALIGNMENT_CENTER, 96.0, 12, Color.WHITE)

func draw_table_wall_editor_overlay() -> void:
	if not effect_editor_enabled or editor_target != 5:
		return
	var selected_side := editor_wall_side(editor_hole)
	var top_y := board_to_screen(Vector2(effective_wall_min_x(), 0.0)).y
	var bottom_y := board_to_screen(Vector2(effective_wall_max_x(), 0.0)).y
	var left_x := board_to_screen(Vector2(0.0, effective_wall_max_y())).x
	var right_x := board_to_screen(Vector2(0.0, effective_wall_min_y())).x
	var positions := [left_x, top_y, right_x, bottom_y]
	for side in 4:
		var selected_wall := side == selected_side
		var color := Color(1.0, 0.20, 0.12, 0.72 if selected_wall else 0.30)
		var thickness := maxf(4.0, table_wall_sizes[side] * 3.0)
		if side == 0 or side == 2:
			draw_line(Vector2(positions[side], board_rect.position.y), Vector2(positions[side], board_rect.end.y), color, thickness, true)
		else:
			draw_line(Vector2(board_rect.position.x, positions[side]), Vector2(board_rect.end.x, positions[side]), color, thickness, true)
	# Hole openings remain editable through ENTRY, but show all of them here so
	# the relationship between the rails and each opening is visible at once.
	for hole in 6:
		var trigger_center := entry_trigger_center(hole)
		var ring := PackedVector2Array()
		for i in 33:
			var angle := TAU * float(i) / 32.0
			ring.append(board_to_screen(trigger_center + Vector2(cos(angle), sin(angle)) * trap_entry_radii[hole]))
		draw_polyline(ring, Color(1.0, 0.88, 0.24, 0.72), 3.0, true)
	var side_names := ["LEFT WALL", "TOP WALL", "RIGHT WALL", "BOTTOM WALL"]
	draw_string(ui_font, board_rect.position + Vector2(12.0, 24.0), side_names[selected_side], HORIZONTAL_ALIGNMENT_LEFT, 180.0, 16, Color.WHITE)

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
		draw_string(ui_font, Vector2(outer_rect.position.x, baseline), score, HORIZONTAL_ALIGNMENT_CENTER, outer_rect.size.x, font_size, Color.WHITE)

func draw_hud(viewport_size: Vector2) -> void:
	# Overlay the compact HUD so it no longer reserves valuable board height.
	draw_rect(Rect2(0, 0, viewport_size.x, 54), Color(0.09, 0.15, 0.23, 0.78))
	draw_style_box(make_box(Color("172b42"), 12.0), Rect2(8.0, 6.0, 116.0, 42.0))
	draw_string(ui_font, Vector2(8, 34), "MENU", HORIZONTAL_ALIGNMENT_CENTER, 116, 17, Color("f6d365"))
	draw_string(ui_font, Vector2(142, 34), status, HORIZONTAL_ALIGNMENT_LEFT, viewport_size.x - 617, 17, Color.WHITE)
	var choose_rect := Rect2(viewport_size.x - 454.0, 6.0, 105.0, 42.0)
	draw_style_box(make_box(Color("1b91a8"), 14.0), choose_rect)
	draw_string(ui_font, choose_rect.position + Vector2(0, 28), "CHOOSE", HORIZONTAL_ALIGNMENT_CENTER, choose_rect.size.x, 15, Color.WHITE)
	var edit_rect := Rect2(viewport_size.x - 334.0, 6.0, 145.0, 42.0)
	draw_style_box(make_box(Color("7256d8") if effect_editor_enabled else Color("34495e"), 14.0), edit_rect)
	draw_string(ui_font, edit_rect.position + Vector2(19, 28), "EDIT EFFECT", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var button_rect := Rect2(viewport_size.x - 174.0, 6.0, 150.0, 42.0)
	draw_style_box(make_box(Color("ef5350"), 14.0), button_rect)
	draw_string(ui_font, button_rect.position + Vector2(25, 28), "NEW GAME", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

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

func trap_weapon_offset(hole: int, weapon: int) -> Vector2:
	return trap_weapon_offsets[hole * 2 + weapon] * (board_rect.size.y / 600.0)

func trap_weapon_scale(hole: int, weapon: int) -> float:
	return trap_weapon_scales[hole * 2 + weapon]

func trap_ball_position(hole: int, base: Vector2) -> Vector2:
	return base + trap_ball_offsets[hole] * (board_rect.size.y / 600.0)

func trap_ball_radius(hole: int, base: float) -> float:
	return base * trap_ball_scales[hole]

func press_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1276.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func draw_press_rod(anchor_x: float, y: float, tip_x: float, left_side: bool, compression: float, machine_activity: float = 0.0) -> void:
	var anchor: Vector2 = press_point(anchor_x, y)
	var tip: Vector2 = press_point(tip_x, y)
	var weapon_index := 0 if left_side else 1
	var edit_offset := trap_weapon_offset(PRESS_TRAP_HOLE, weapon_index)
	var edit_scale := trap_weapon_scale(PRESS_TRAP_HOLE, weapon_index)
	anchor += edit_offset
	tip += edit_offset
	var direction := 1.0 if left_side else -1.0
	var unit_x := board_rect.size.x / 1276.0
	var unit_y := board_rect.size.y / 600.0
	# High-detail scalable industrial press sprite. The animation keeps the rod and
	# plate procedural, but the fixed machine is now a serious hydraulic assembly.
	var base_radius := 22.0 * unit_y * edit_scale
	var machine_height := 68.0 * unit_y * edit_scale
	if press_machine_texture != null:
		var source := press_machine_texture.get_size()
		var factor := machine_height / maxf(1.0, source.y)
		var machine_size := source * factor
		var pivot := Vector2(source.x * 0.46, source.y * 0.50) * factor
		draw_set_transform(anchor, 0.0 if left_side else PI, Vector2.ONE)
		draw_texture_rect(press_machine_texture, Rect2(-pivot, machine_size), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Animated gearbox overlay centered exactly over the large gear in the
		# vector machine. It spins only while the hydraulic piston is moving.
		var gear_local := Vector2(158.0 - source.x * 0.46, 185.0 - source.y * 0.50) * factor
		var gear_center: Vector2 = anchor + gear_local * direction
		var gear_radius := 57.0 * factor
		var spin_direction := 1.0 if left_side else -1.0
		var gear_rotation := float(Time.get_ticks_msec()) * 0.010 * spin_direction
		var gear_points := PackedVector2Array()
		for tooth in 24:
			var tooth_angle := gear_rotation + TAU * float(tooth) / 24.0
			var tooth_radius := gear_radius * (1.0 if tooth % 2 == 0 else 0.80)
			gear_points.append(gear_center + Vector2(cos(tooth_angle), sin(tooth_angle)) * tooth_radius)
		if machine_activity > 0.01:
			draw_colored_polygon(gear_points, Color("30464f"))
			var gear_outline := gear_points.duplicate()
			gear_outline.append(gear_points[0])
			draw_polyline(gear_outline, Color(0.76, 0.84, 0.84, 0.70 + machine_activity * 0.25), maxf(1.0, gear_radius * 0.10), true)
			draw_circle(gear_center, gear_radius * 0.47, Color("162a32"))
			draw_circle(gear_center, gear_radius * 0.20, Color("e0b33e"))
			draw_circle(gear_center - Vector2(gear_radius * 0.13, gear_radius * 0.17), gear_radius * 0.10, Color(0.96, 1.0, 1.0, 0.42 * machine_activity))
	else:
		draw_circle(anchor, base_radius, Color("31464f"))
		draw_circle(anchor, base_radius * 0.62, Color("a9b9ba"))
	var collar_center := anchor + Vector2(direction * 25.0 * unit_x * edit_scale, 0.0)
	var collar_size := Vector2(13.0 * unit_x, 38.0 * unit_y) * edit_scale
	var rod_start := collar_center + Vector2(direction * collar_size.x * 0.38, 0.0)
	var rod_end := tip - Vector2(direction * 8.0 * unit_x, 0.0)
	draw_line(rod_start, rod_end, Color("263944"), 15.0 * unit_y * edit_scale, true)
	draw_line(rod_start - Vector2(0, 1.5 * unit_y), rod_end - Vector2(0, 1.5 * unit_y), Color("b9cbd0"), 7.0 * unit_y * edit_scale, true)
	var plate_size := Vector2(18.0 * unit_x, 48.0 * unit_y) * edit_scale
	draw_style_box(make_box(Color("273943"), 4.0 * unit_y), Rect2(tip - plate_size * 0.5, plate_size))
	draw_rect(Rect2(tip - plate_size * 0.34, plate_size * 0.68), Color("91a5aa"))
	var glow_width := 6.0 * unit_x
	var glow_rect := Rect2(tip.x - glow_width * 0.5, tip.y - 19.0 * unit_y, glow_width, 38.0 * unit_y)
	draw_rect(glow_rect, Color(0.72, 0.34, 1.0, 0.48 * compression))

func press_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == PRESS_TRAP_HOLE:
			return true
	return false

func draw_press_weapons_idle() -> void:
	if customizer_open or press_trap_is_active():
		return
	# The plates rest close to their stone-mounted motors, exactly as in the
	# source animation, instead of disappearing until a ball reaches the pocket.
	draw_press_rod(546.0, 55.0, 570.0, true, 0.0)
	draw_press_rod(695.0, 55.0, 671.0, false, 0.0)

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
	# The physics ball is hidden as soon as it scores, so its effect replacement
	# must be visible immediately while the pistons approach.
	var alpha := 1.0
	var extend := 0.0
	var retract := 0.0
	var release := 0.0
	# Close steadily instead of delivering a sudden final hit. Compression begins
	# while the plates are approaching and increases continuously until contact.
	extend = smooth_step((seconds - 0.10) / 1.02)
	if seconds >= 1.32:
		retract = smooth_step((seconds - 1.32) / 0.58)
	var squeeze := smooth_step(clampf((extend - 0.18) / 0.82, 0.0, 1.0))
	var arm_amount := extend * (1.0 - retract)
	# Keep the gearbox running throughout extension and retraction, then ease it
	# to a stop as the plates settle at their front collars.
	var machine_activity := smooth_step(extend) * (1.0 - smooth_step((retract - 0.78) / 0.22))
	var compressed_rx := lerpf(radius, radius * 0.32, squeeze)
	# Rest at the front collars, never at the center of the weapon housing.
	var left_rest_tip := 570.0
	var right_rest_tip := 671.0
	var left_tip := lerpf(left_rest_tip, cx - compressed_rx - 9.0, arm_amount)
	var right_tip := lerpf(right_rest_tip, cx + compressed_rx + 9.0, arm_amount)
	rx_scale = lerpf(1.0, 0.32, squeeze)
	ry_scale = lerpf(1.0, 1.10, squeeze)
	if seconds >= 1.79:
		rx_scale = 0.32
		ry_scale = 1.10
		var wait := clampf((seconds - 1.79) / (TRAP_CAPTURE_TIME - 1.79), 0.0, 1.0)
		release = smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
		var motion := release * release
		rotation = sin(wait * PI) * 0.045 - motion * 0.34
		# Land just above the table in visible water; the previous -121 target
		# continued behind the HUD before the floating phase began.
		ball_y = cy - lerpf(0.0, 67.0, motion)
		alpha = 1.0 - release * 0.08
		var shrink := 1.0 - release * 0.30
		rx_scale *= shrink
		ry_scale *= shrink
	var radius_screen := trap_ball_radius(PRESS_TRAP_HOLE, radius * board_rect.size.y / 600.0)
	var press_center := trap_ball_position(PRESS_TRAP_HOLE, press_point(cx, ball_y))
	if release > 0.0:
		var press_start := trap_ball_position(PRESS_TRAP_HOLE, press_point(cx, cy))
		press_center = press_start.lerp(effect_fall_endpoint(PRESS_TRAP_HOLE), release * release)
	# Draw the animal first so both plates visibly close over it. The old order
	# placed the ball on top of the pistons and made the squeeze look fake.
	draw_press_ball(press_center, radius_screen, rx_scale, ry_scale, rotation, effect.team, effect.piece, alpha)
	# Always draw the complete machines. During retraction they return to their
	# idle positions while the crushed disc remains in the center.
	draw_press_rod(546.0, cy, left_tip, true, squeeze, machine_activity)
	draw_press_rod(695.0, cy, right_tip, false, squeeze, machine_activity)

func hammer_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func hammer_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == HAMMER_TRAP_HOLE:
			return true
	return false

func hammer_weapon_points() -> Dictionary:
	var hit := trap_ball_position(HAMMER_TRAP_HOLE, hammer_point(1072.0, 522.0))
	var scale_y := board_rect.size.y / 600.0
	return {
		# Mounts sit deep on the two stones, far away from the capture point, just
		# like the supplied original screenshots. The heads point away from the
		# hole while idle and swing inward only during a strike.
		"right": hit + Vector2(12.0, -52.0) * scale_y + trap_weapon_offset(HAMMER_TRAP_HOLE, 0),
		"bottom": hit + Vector2(-64.0, 22.0) * scale_y + trap_weapon_offset(HAMMER_TRAP_HOLE, 1),
		"hit": hit
	}

func hammer_strike_amount(seconds: float, first_start: float) -> float:
	# Each hammer gets its own repeated stroke. Their starts are separated by
	# half a cycle, producing right-left-right-left impacts without overlap.
	if seconds < first_start or seconds >= 2.20:
		return 0.0
	var local := fmod(seconds - first_start, 0.68)
	if local < 0.12:
		return smooth_step(local / 0.12)
	if local < 0.17:
		return 1.0
	if local < 0.32:
		return 1.0 - smooth_step((local - 0.17) / 0.15)
	return 0.0

func draw_hammer_sprite_frame(texture: Texture2D, anchor: Vector2, angle: float, target_length: float, pivot_ratio: Vector2, head_ratio: Vector2, alpha: float) -> void:
	if texture == null or alpha <= 0.01:
		return
	var source := texture.get_size()
	var pivot := source * pivot_ratio
	var head := source * head_ratio
	var internal_angle := (head - pivot).angle()
	var internal_length := maxf(1.0, pivot.distance_to(head))
	var factor := target_length / internal_length
	draw_set_transform(anchor, angle - internal_angle, Vector2.ONE)
	draw_texture_rect(texture, Rect2(-pivot * factor, source * factor), false, Color(1.0, 1.0, 1.0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_hammer_cutout(texture: Texture2D, center: Vector2, target_height: float, rotation: float, alpha: float = 1.0) -> void:
	if texture == null or alpha <= 0.01:
		return
	var source := texture.get_size()
	var factor := target_height / maxf(1.0, source.y)
	var size := source * factor
	draw_set_transform(center, rotation, Vector2.ONE)
	draw_texture_rect(texture, Rect2(-size * 0.5, size), false, Color(1.0, 1.0, 1.0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_trap_hammer(anchor: Vector2, hit_point: Vector2, rest_angle: float, amount: float, weapon_scale: float, mirrored: bool) -> void:
	var strike_angle := (hit_point - anchor).angle()
	var angle := lerp_angle(rest_angle, strike_angle, amount)
	var target_length := anchor.distance_to(hit_point) * weapon_scale
	# Rotate the complete restored hammer around the center of its stone-mounted
	# base. Nothing is translated into the pocket; only the arm swings inward.
	var swing_mix := smooth_step((amount - 0.52) / 0.28)
	draw_hammer_sprite_frame(hammer_idle_texture, anchor, angle, target_length, Vector2(0.50, 0.91), Vector2(0.50, 0.15), 1.0 - swing_mix)
	draw_hammer_sprite_frame(hammer_swing_texture, anchor, angle, target_length, Vector2(0.75, 0.17), Vector2(0.38, 0.78), swing_mix)

func draw_hammer_weapons_idle() -> void:
	if hammer_trap_is_active():
		return
	var points := hammer_weapon_points()
	draw_trap_hammer(points.right, points.hit, deg_to_rad(-90.0), 0.0, trap_weapon_scale(HAMMER_TRAP_HOLE, 0), false)
	draw_trap_hammer(points.bottom, points.hit, deg_to_rad(180.0), 0.0, trap_weapon_scale(HAMMER_TRAP_HOLE, 1), true)

func draw_hammer_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var points := hammer_weapon_points()
	var right_weapon: Vector2 = points.right
	var bottom_weapon: Vector2 = points.bottom
	var hit_point: Vector2 = points.hit
	var radius := trap_ball_radius(HAMMER_TRAP_HOLE, 27.0 * scale_y)
	var right_amount := hammer_strike_amount(seconds, 0.20)
	var bottom_amount := hammer_strike_amount(seconds, 0.54)
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
		center = hit_point.lerp(effect_fall_endpoint(HAMMER_TRAP_HOLE), fall)
		center.y -= sin(release * PI) * 5.0 * scale_y
		ball_radius *= 1.0 - release * 0.32
		alpha = 1.0 - release * 0.10

	var squash_x := 1.0
	var squash_y := 1.0
	var ball_rotation := 0.0
	# The ball stays progressively crushed after every alternating blow instead
	# of returning completely to its original size between hits.
	var completed_hits := clampi(int(floor((seconds - 0.20) / 0.34)) + 1, 0, 6)
	var permanent_crush := float(completed_hits) / 6.0
	# Keep the accumulated crushed shape during the fall as well. Previously
	# this was applied only before release, so the ball briefly grew back.
	ball_radius *= lerpf(1.0, 0.72, permanent_crush)
	squash_x = lerpf(1.0, 1.10, permanent_crush)
	squash_y = lerpf(1.0, 0.70, permanent_crush)
	if release <= 0.0 and impact > 0.01:
		ball_radius *= lerpf(1.0, 0.88, impact)
		if right_amount >= bottom_amount:
			squash_x *= lerpf(1.0, 0.48, impact)
			squash_y *= lerpf(1.0, 1.42, impact)
			ball_rotation = -0.13 * impact
		else:
			squash_x *= lerpf(1.0, 1.42, impact)
			squash_y *= lerpf(1.0, 0.48, impact)
			ball_rotation = 0.13 * impact

	# Draw the ball first, then the hammers, so their heads visibly land on top.
	draw_press_ball(center, ball_radius, squash_x, squash_y, ball_rotation, effect.team, effect.piece, alpha)
	if release <= 0.0:
		draw_trap_hammer(right_weapon, hit_point + Vector2(radius * 0.12, -radius * 0.08), deg_to_rad(-90.0), right_amount, trap_weapon_scale(HAMMER_TRAP_HOLE, 0), false)
		draw_trap_hammer(bottom_weapon, hit_point + Vector2(-radius * 0.08, radius * 0.12), deg_to_rad(180.0), bottom_amount, trap_weapon_scale(HAMMER_TRAP_HOLE, 1), true)
	else:
		# Return both hammers to their stone-mounted idle poses as soon as the
		# crushing ends. The active fall continues, but the weapons never vanish.
		draw_trap_hammer(right_weapon, hit_point, deg_to_rad(-90.0), 0.0, trap_weapon_scale(HAMMER_TRAP_HOLE, 0), false)
		draw_trap_hammer(bottom_weapon, hit_point, deg_to_rad(180.0), 0.0, trap_weapon_scale(HAMMER_TRAP_HOLE, 1), true)

	if impact > 0.05 and release <= 0.0:
		draw_circle(center, ball_radius * 0.78, Color(1.0, 0.98, 0.82, 0.72 * impact))
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

func electric_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == ELECTRIC_TRAP_HOLE:
			return true
	return false

func electric_weapon_points() -> Dictionary:
	var capture := trap_ball_position(ELECTRIC_TRAP_HOLE, board_to_screen(SCORING_HOLE_CENTERS[ELECTRIC_TRAP_HOLE]))
	var scale_y := board_rect.size.y / 600.0
	return {
		"capture": capture,
		"top": capture + electric_top_offset * scale_y + trap_weapon_offset(ELECTRIC_TRAP_HOLE, 0),
		"right": capture + electric_right_offset * scale_y + trap_weapon_offset(ELECTRIC_TRAP_HOLE, 1)
	}

func draw_electric_emitter(center: Vector2, target: Vector2, size: float, power: float = 0.0) -> Vector2:
	var direction := (target - center).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	# Heavy stone-mounted high-voltage generator: steel housing, copper coil,
	# ceramic insulators and a forked discharge head. Everything is drawn in the
	# weapon's local axis so both emitters retain the editor-approved positions.
	draw_set_transform(center + Vector2(0.0, size * 0.10), angle, Vector2.ONE)
	var shadow_rect := Rect2(Vector2(-size * 0.52, -size * 0.39) + Vector2(0.0, size * 0.10), Vector2(size * 0.86, size * 0.78))
	draw_style_box(make_box(Color(0.02, 0.04, 0.06, 0.32), size * 0.14), shadow_rect)
	var body_rect := Rect2(Vector2(-size * 0.52, -size * 0.39), Vector2(size * 0.86, size * 0.78))
	draw_style_box(make_box(Color("1f3039"), size * 0.13), body_rect)
	var inner_rect := Rect2(Vector2(-size * 0.43, -size * 0.30), Vector2(size * 0.65, size * 0.60))
	draw_style_box(make_box(Color("6f858e"), size * 0.10), inner_rect)
	# Rear mounting band and four warm metal bolts.
	draw_rect(Rect2(Vector2(-size * 0.47, -size * 0.32), Vector2(size * 0.13, size * 0.64)), Color("314650"))
	for bolt_y in [-0.22, 0.22]:
		draw_circle(Vector2(-size * 0.405, size * bolt_y), size * 0.045, Color("e6bd43"))
	# Bright copper induction coil wrapped around a dark magnetic core.
	draw_rect(Rect2(Vector2(-size * 0.27, -size * 0.20), Vector2(size * 0.39, size * 0.40)), Color("243740"))
	for i in 5:
		var coil_x := size * (-0.235 + float(i) * 0.078)
		draw_line(Vector2(coil_x, -size * 0.22), Vector2(coil_x, size * 0.22), Color("6f2b18"), size * 0.090, true)
		draw_line(Vector2(coil_x - size * 0.012, -size * 0.20), Vector2(coil_x - size * 0.012, size * 0.20), Color("f18a2b"), size * 0.045, true)
	# Two pale ceramic insulators lead into the forked electrode.
	for insulator_y in [-0.17, 0.17]:
		draw_line(Vector2(size * 0.14, size * insulator_y), Vector2(size * 0.42, size * insulator_y), Color("24343b"), size * 0.15, true)
		draw_line(Vector2(size * 0.16, size * insulator_y), Vector2(size * 0.39, size * insulator_y), Color("d9e7e4"), size * 0.085, true)
		for ring_x in [0.20, 0.29, 0.38]:
			draw_line(Vector2(size * ring_x, size * (insulator_y - 0.075)), Vector2(size * ring_x, size * (insulator_y + 0.075)), Color("6d8790"), size * 0.035, true)
	# Fork tips focus the discharge into a single bright muzzle point.
	var fork_color := Color("a9c0c5")
	draw_line(Vector2(size * 0.40, -size * 0.17), Vector2(size * 0.62, -size * 0.08), fork_color, size * 0.075, true)
	draw_line(Vector2(size * 0.40, size * 0.17), Vector2(size * 0.62, size * 0.08), fork_color, size * 0.075, true)
	draw_circle(Vector2(size * 0.62, -size * 0.08), size * 0.065, Color("d8f6ff"))
	draw_circle(Vector2(size * 0.62, size * 0.08), size * 0.065, Color("d8f6ff"))
	# Animated energy window remains subtle at idle and brightens before firing.
	var core_alpha := 0.34 + power * 0.58
	draw_circle(Vector2(-size * 0.07, 0.0), size * (0.095 + power * 0.018), Color(0.35, 0.88, 1.0, core_alpha))
	draw_circle(Vector2(-size * 0.07, 0.0), size * 0.17, Color(0.18, 0.70, 1.0, 0.10 + power * 0.16), false, maxf(1.0, size * 0.035), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var upper_tip := center + direction * size * 0.62 - direction.orthogonal() * size * 0.08
	var lower_tip := center + direction * size * 0.62 + direction.orthogonal() * size * 0.08
	var tip := center + direction * size * 0.70
	if power > 0.01:
		draw_electric_arc(upper_tip, lower_tip, float(Time.get_ticks_msec()) * 0.006, 0.30 + power * 0.65, maxf(1.0, size * 0.035))
		draw_circle(tip, size * (0.08 + power * 0.045), Color(0.82, 0.97, 1.0, 0.42 + power * 0.50))
	return tip

func draw_electric_weapons_idle() -> void:
	if customizer_open or electric_trap_is_active():
		return
	var points := electric_weapon_points()
	var scale_y := board_rect.size.y / 600.0
	var pulse := (sin(float(Time.get_ticks_msec()) * 0.0045) + 1.0) * 0.5
	draw_electric_emitter(points.top, points.capture, electric_top_size * scale_y * trap_weapon_scale(ELECTRIC_TRAP_HOLE, 0), pulse * 0.20)
	draw_electric_emitter(points.right, points.capture, electric_right_size * scale_y * trap_weapon_scale(ELECTRIC_TRAP_HOLE, 1), pulse * 0.20)

func draw_electric_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var points := electric_weapon_points()
	var top_weapon: Vector2 = points.top
	var right_weapon: Vector2 = points.right
	var shock_point: Vector2 = points.capture
	var radius := trap_ball_radius(ELECTRIC_TRAP_HOLE, RADIUS * board_scale * GAME_BALL_VISUAL_SCALE)
	var charge := smooth_step(seconds / 0.30)
	var charge_fade := 1.0 - smooth_step((seconds - 1.12) / 0.28)
	var beam_power := charge * charge_fade
	var electrified := smooth_step((seconds - 0.10) / 0.38)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := shock_point
	var ball_radius := radius
	var alpha := 1.0

	if release > 0.0:
		# Fall out through the nearby upper-right opening while remaining charged.
		var fall := release * release
		center = shock_point.lerp(effect_fall_endpoint(ELECTRIC_TRAP_HOLE), fall)
		center.y -= sin(release * PI) * 7.0 * scale_y
		ball_radius *= 1.0 - release * 0.34
		alpha = 1.0 - release * 0.10

	var top_tip := draw_electric_emitter(top_weapon, shock_point, electric_top_size * scale_y * trap_weapon_scale(ELECTRIC_TRAP_HOLE, 0), beam_power)
	var right_tip := draw_electric_emitter(right_weapon, shock_point, electric_right_size * scale_y * trap_weapon_scale(ELECTRIC_TRAP_HOLE, 1), beam_power)

	# One short, bright discharge from each weapon, as in the source animation.
	if beam_power > 0.01 and release <= 0.0:
		draw_electric_arc(top_tip, shock_point - Vector2(radius * 0.34, radius * 0.30), seconds * 2.3, beam_power, maxf(1.4, 2.5 * scale_y))
		draw_electric_arc(right_tip, shock_point + Vector2(radius * 0.34, radius * 0.28), seconds * 2.7 + 0.43, beam_power, maxf(1.4, 2.5 * scale_y))

	# Keep the real character ball visible under the electric glow.
	var shake := Vector2.ZERO
	if electrified > 0.05 and release <= 0.0:
		shake = Vector2(sin(seconds * 43.0), cos(seconds * 37.0)) * 2.5 * scale_y * electrified
	draw_rubber_game_ball(center + shake, ball_radius, effect.team, effect.piece, alpha)
	# Strong irregular white/yellow flashes repeatedly wash over the whole ball.
	var flash_wave := sin(seconds * 17.0) * 0.5 + sin(seconds * 29.0 + 0.7) * 0.3 + 0.2
	var flash := smooth_step(clampf((flash_wave - 0.12) / 0.48, 0.0, 1.0)) * electrified
	if flash > 0.02:
		draw_circle(center + shake, ball_radius * (1.04 + flash * 0.10), Color(1.0, 0.96, 0.60, flash * 0.72 * alpha), true, -1.0, true)
		draw_circle(center + shake, ball_radius * (1.36 + flash * 0.18), Color(1.0, 0.88, 0.24, flash * 0.20 * alpha), false, maxf(2.0, 4.0 * scale_y), true)

	# Compact lightning remains wrapped around the ball, including during its fall.
	var local_power := electrified * (1.0 - release * 0.18)
	if local_power > 0.01:
		draw_circle(center + shake, ball_radius * (1.30 + sin(seconds * 24.0) * 0.07), Color(0.82, 0.96, 1.0, 0.18 * local_power * alpha))
		for i in 10:
			var a := TAU * float(i) / 10.0 + seconds * (2.1 + float(i % 3) * 0.2)
			var inner := center + shake + Vector2(cos(a), sin(a)) * ball_radius * 0.82
			var outer_angle := a + sin(seconds * 17.0 + float(i)) * 0.28
			var outer := center + shake + Vector2(cos(outer_angle), sin(outer_angle)) * ball_radius * (1.30 + 0.22 * sin(seconds * 21.0 + float(i)))
			draw_electric_arc(inner, outer, seconds * 1.4 + float(i), local_power * alpha * 0.92, maxf(1.0, 1.8 * scale_y))


func fire_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func fire_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == FIRE_TRAP_HOLE:
			return true
	return false

func draw_fire_emitter(center: Vector2, target: Vector2, size: float, heat: float = 0.0) -> Vector2:
	var direction := (target - center).normalized()
	if fire_launcher_texture == null:
		return center
	var source := fire_launcher_texture.get_size()
	var factor := size / source.y
	# The generated turret's rotation center is inside the large round base,
	# not at the center of its square canvas.
	var pivot := Vector2(source.x * 0.43, source.y * 0.52)
	var draw_size := source * factor
	draw_set_transform(center, direction.angle(), Vector2.ONE)
	draw_texture_rect(fire_launcher_texture, Rect2(-pivot * factor, draw_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var nozzle_tip := center + direction * (source.x - pivot.x) * factor
	if heat > 0.01:
		draw_circle(nozzle_tip, size * (0.055 + heat * 0.035), Color(1.0, 0.66, 0.12, 0.45 + heat * 0.45))
	return nozzle_tip

func fire_weapon_points() -> Dictionary:
	var burn := trap_ball_position(FIRE_TRAP_HOLE, fire_point(112.0, 536.0))
	return {
		"burn": burn,
		"left": fire_point(78.0, 492.0) + trap_weapon_offset(FIRE_TRAP_HOLE, 0),
		"bottom": fire_point(188.0, 565.0) + trap_weapon_offset(FIRE_TRAP_HOLE, 1)
	}

func draw_fire_weapons_idle() -> void:
	if customizer_open or fire_trap_is_active():
		return
	var points := fire_weapon_points()
	var scale_y := board_rect.size.y / 600.0
	draw_fire_emitter(points.left, points.burn, 58.0 * scale_y * trap_weapon_scale(FIRE_TRAP_HOLE, 0))
	draw_fire_emitter(points.bottom, points.burn, 58.0 * scale_y * trap_weapon_scale(FIRE_TRAP_HOLE, 1))

func draw_fire_stream(origin: Vector2, target: Vector2, amount: float, seed_offset: float, edit_scale: float = 1.0) -> void:
	if amount <= 0.01:
		return
	var end := origin.lerp(target, amount)
	var direction := end - origin
	if direction.length_squared() < 0.01:
		return
	var normal := direction.normalized().orthogonal()
	var scale_y := board_rect.size.y / 600.0 * edit_scale
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 14:
		var t := float(i) / 13.0
		var wave := sin(t * 18.0 + seed_offset * 13.0 + float(Time.get_ticks_msec()) * 0.018) * 7.0 * scale_y
		outer.append(origin.lerp(end, t) + normal * wave)
		inner.append(origin.lerp(end, t) + normal * wave * 0.42)
	draw_polyline(outer, Color(0.82, 0.08, 0.005, 0.92), 24.0 * scale_y, true)
	draw_polyline(outer, Color(1.0, 0.32, 0.01, 0.98), 16.0 * scale_y, true)
	draw_polyline(inner, Color(1.0, 0.82, 0.12, 0.98), 7.0 * scale_y, true)
	for i in 12:
		var phase := fmod(float(i) / 11.0 + seed_offset + float(Time.get_ticks_msec()) * 0.0007, 1.0) * amount
		var p := origin.lerp(target, phase)
		p += normal * sin(phase * 29.0 + seed_offset * 17.0) * 13.0 * scale_y
		var r := (3.5 + float(i % 4) * 1.7) * scale_y
		draw_circle(p, r, Color(1.0, 0.20 + 0.14 * float(i % 3), 0.005, 0.88))

func draw_burning_ball(center: Vector2, radius: float, burn: float, team: int, piece: int, alpha: float) -> void:
	var now := float(Time.get_ticks_msec()) * 0.001
	# Let the animal remain visible while soot spreads over it instead of
	# replacing it instantly with a flat black fire icon.
	draw_rubber_game_ball(center, radius, team, piece, (1.0 - burn * 0.78) * alpha)
	var ember_radius := radius * lerpf(0.88, 1.02, burn)
	# Soft heat haze and deep ember body.
	draw_circle(center, ember_radius * 1.34, Color(1.0, 0.14, 0.01, 0.10 * burn * alpha))
	draw_circle(center, ember_radius * 1.15, Color(1.0, 0.30, 0.015, 0.12 * burn * alpha))
	draw_circle(center, ember_radius, Color(0.025, 0.018, 0.014, 0.82 * burn * alpha))
	# Irregular soot patches keep the surface organic and textured.
	for i in 13:
		var a := float(i) * 2.399 + 0.31
		var distance := ember_radius * (0.18 + 0.56 * absf(sin(float(i) * 1.73)))
		var soot_center: Vector2 = center + Vector2(cos(a), sin(a)) * distance
		var soot_size := ember_radius * (0.13 + 0.09 * absf(cos(float(i) * 2.11)))
		draw_circle(soot_center, soot_size, Color(0.005, 0.004, 0.003, (0.34 + float(i % 3) * 0.10) * burn * alpha))
	# Fine glowing fissures rather than thick cartoon spokes.
	for i in 7:
		var a := float(i) * 2.31 + 0.52
		var crack_a: Vector2 = center + Vector2(cos(a), sin(a)) * ember_radius * 0.18
		var elbow: Vector2 = center + Vector2(cos(a + 0.20), sin(a + 0.20)) * ember_radius * 0.46
		var crack_b: Vector2 = center + Vector2(cos(a - 0.10), sin(a - 0.10)) * ember_radius * 0.78
		var heat := (0.58 + 0.42 * sin(now * 7.0 + float(i) * 1.7)) * burn * alpha
		draw_line(crack_a, elbow, Color(1.0, 0.16, 0.005, heat * 0.75), maxf(1.0, radius * 0.035), true)
		draw_line(elbow, crack_b, Color(1.0, 0.42, 0.015, heat), maxf(1.0, radius * 0.045), true)
	# Flames rise upward in translucent, constantly changing tongues.
	for i in 8:
		var x_ratio := -0.82 + float(i) * 1.64 / 7.0
		var surface_y := sqrt(maxf(0.0, 1.0 - x_ratio * x_ratio))
		var flame_base: Vector2 = center + Vector2(x_ratio * ember_radius, -surface_y * ember_radius * 0.72)
		var sway := sin(now * (5.2 + float(i % 3)) + float(i) * 1.91)
		var flame_height := radius * (0.34 + 0.30 * absf(sin(now * 6.4 + float(i)))) * burn
		var flame_tip: Vector2 = flame_base + Vector2(sway * radius * 0.16, -flame_height)
		var flame_width := radius * (0.09 + 0.035 * float(i % 3)) * burn
		var tongue := PackedVector2Array([
			flame_base - Vector2(flame_width, 0.0),
			flame_tip,
			flame_base + Vector2(flame_width, 0.0)
		])
		draw_colored_polygon(tongue, Color(1.0, 0.15, 0.005, 0.48 * burn * alpha))
		draw_line(flame_base, flame_tip.lerp(flame_base, 0.36), Color(1.0, 0.72, 0.10, 0.66 * burn * alpha), maxf(1.0, flame_width * 0.48), true)
	# Sparse sparks and smoke sell the heat without forming a uniform outline.
	for i in 7:
		var phase := fmod(now * (0.52 + float(i) * 0.035) + float(i) * 0.173, 1.0)
		var spark: Vector2 = center + Vector2(sin(float(i) * 3.17 + now) * radius * 0.72, -radius * (0.75 + phase * 1.75))
		draw_circle(spark, maxf(0.8, radius * (0.045 - phase * 0.018)), Color(1.0, 0.55 + phase * 0.30, 0.08, (1.0 - phase) * burn * alpha))
	for i in 4:
		var smoke_phase := fmod(now * 0.22 + float(i) * 0.24, 1.0)
		var smoke: Vector2 = center + Vector2(sin(now * 1.4 + float(i)) * radius * 0.45, -radius * (1.15 + smoke_phase * 1.65))
		var smoke_radius := radius * (0.12 + smoke_phase * 0.18)
		draw_circle(smoke, smoke_radius, Color(0.08, 0.075, 0.07, (1.0 - smoke_phase) * 0.18 * burn * alpha))

func draw_fire_trap(effect: Dictionary) -> void:
	var seconds: float = effect.elapsed
	var scale_y := board_rect.size.y / 600.0
	var points := fire_weapon_points()
	var left_weapon: Vector2 = points.left
	var bottom_weapon: Vector2 = points.bottom
	var burn_point: Vector2 = points.burn
	var radius := trap_ball_radius(FIRE_TRAP_HOLE, 27.0 * scale_y)
	var ignition := smooth_step(seconds / 0.38)
	var burn := smooth_step((seconds - 0.12) / 1.48)
	var fire_fall_start := 2.72
	var release := smooth_step((seconds - fire_fall_start) / (FIRE_EFFECT_DURATION - fire_fall_start))
	var center := burn_point
	var alpha := 1.0
	if release > 0.0:
		var gravity_fall := release * release
		# End in the visible water strip close to the lower-left corner.
		center = burn_point.lerp(effect_fall_endpoint(FIRE_TRAP_HOLE), gravity_fall)
		center.x += sin(release * PI) * -6.0 * scale_y
		radius *= 1.0 - release * 0.22
		alpha = 1.0 - release * 0.10
	var stream_strength := ignition * (1.0 - smooth_step((seconds - 1.62) / 0.42))
	var left_tip := draw_fire_emitter(left_weapon, burn_point, 58.0 * scale_y * trap_weapon_scale(FIRE_TRAP_HOLE, 0), stream_strength)
	var bottom_tip := draw_fire_emitter(bottom_weapon, burn_point, 58.0 * scale_y * trap_weapon_scale(FIRE_TRAP_HOLE, 1), stream_strength)
	if stream_strength > 0.01:
		draw_fire_stream(left_tip, burn_point, stream_strength, 0.17, trap_weapon_scale(FIRE_TRAP_HOLE, 0))
		draw_fire_stream(bottom_tip, burn_point, stream_strength, 0.63, trap_weapon_scale(FIRE_TRAP_HOLE, 1))
	draw_burning_ball(center, radius, burn, effect.team, effect.piece, alpha)

func ice_point(x: float, y: float) -> Vector2:
	return board_rect.position + Vector2(x / 1200.0 * board_rect.size.x, y / 600.0 * board_rect.size.y)

func ice_weapon_points() -> Dictionary:
	var freeze := trap_ball_position(ICE_TRAP_HOLE, ice_point(600.0, 548.0))
	return {
		"freeze": freeze,
		"left": ice_point(470.0, 565.0) + trap_weapon_offset(ICE_TRAP_HOLE, 0),
		"right": ice_point(730.0, 565.0) + trap_weapon_offset(ICE_TRAP_HOLE, 1)
	}

func ice_trap_is_active() -> bool:
	for effect in active_effects:
		if effect.hole == ICE_TRAP_HOLE:
			return true
	return false

func draw_ice_emitter(center: Vector2, target: Vector2, size: float, frost_power: float = 0.0) -> Vector2:
	var direction := (target - center).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT
	var angle := direction.angle()
	# Detailed cryogenic cannon based on the source animation: a permanent
	# stone-mounted base, violet coolant reservoir and stepped silver nozzle.
	draw_set_transform(center, angle, Vector2.ONE)
	var shadow := Rect2(Vector2(-size * 0.53, -size * 0.34) + Vector2(0.0, size * 0.10), Vector2(size * 0.86, size * 0.68))
	draw_style_box(make_box(Color(0.02, 0.04, 0.07, 0.30), size * 0.15), shadow)
	var mount := Rect2(Vector2(-size * 0.53, -size * 0.34), Vector2(size * 0.45, size * 0.68))
	draw_style_box(make_box(Color("253844"), size * 0.14), mount)
	var mount_inner := Rect2(Vector2(-size * 0.45, -size * 0.26), Vector2(size * 0.30, size * 0.52))
	draw_style_box(make_box(Color("8498a0"), size * 0.11), mount_inner)
	for bolt_y in [-0.20, 0.20]:
		draw_circle(Vector2(-size * 0.39, size * bolt_y), size * 0.043, Color("d7e5e7"))
	# Rounded insulated coolant tank with layered shading and a polished highlight.
	var tank_start := Vector2(-size * 0.12, 0.0)
	var tank_end := Vector2(size * 0.25, 0.0)
	draw_line(tank_start, tank_end, Color("171d3a"), size * 0.58, true)
	draw_line(tank_start, tank_end, Color("4a43aa"), size * 0.48, true)
	draw_line(tank_start, tank_end, Color("6860d5"), size * 0.38, true)
	draw_line(tank_start - Vector2(0.0, size * 0.075), tank_end - Vector2(0.0, size * 0.075), Color(0.76, 0.72, 1.0, 0.80), size * 0.085, true)
	draw_line(tank_start + Vector2(0.0, size * 0.12), tank_end + Vector2(0.0, size * 0.12), Color(0.10, 0.12, 0.30, 0.55), size * 0.07, true)
	# Cooling bands use a dark rim and a bright steel center.
	for band_x in [-0.07, 0.08, 0.22]:
		draw_line(Vector2(size * band_x, -size * 0.27), Vector2(size * band_x, size * 0.27), Color("182934"), size * 0.095, true)
		draw_line(Vector2(size * band_x, -size * 0.24), Vector2(size * band_x, size * 0.24), Color("9fb3ba"), size * 0.045, true)
	# Illuminated snowflake pressure window.
	var gauge_center := Vector2(size * 0.01, 0.0)
	draw_circle(gauge_center, size * 0.12, Color("172b39"))
	draw_circle(gauge_center, size * 0.085, Color(0.42, 0.88, 1.0, 0.42 + frost_power * 0.48))
	for spoke in 3:
		var spoke_angle := float(spoke) * PI / 3.0
		var spoke_vector := Vector2(cos(spoke_angle), sin(spoke_angle)) * size * 0.061
		draw_line(gauge_center - spoke_vector, gauge_center + spoke_vector, Color(0.91, 1.0, 1.0, 0.88), maxf(1.0, size * 0.018), true)
	# Stepped nozzle with a pale ceramic cold tip.
	draw_line(Vector2(size * 0.27, 0.0), Vector2(size * 0.53, 0.0), Color("263844"), size * 0.27, true)
	draw_line(Vector2(size * 0.29, 0.0), Vector2(size * 0.51, 0.0), Color("a8bcc1"), size * 0.15, true)
	for ring_x in [0.31, 0.42, 0.52]:
		draw_line(Vector2(size * ring_x, -size * 0.18), Vector2(size * ring_x, size * 0.18), Color("343768"), size * 0.07, true)
	var local_tip := Vector2(size * 0.62, 0.0)
	draw_circle(local_tip, size * 0.12, Color("25364b"))
	draw_circle(local_tip, size * (0.072 + frost_power * 0.018), Color(0.83, 0.98, 1.0, 0.62 + frost_power * 0.34))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tip := center + direction * size * 0.62
	# Cold vapor and tiny ice crystals make the nozzle feel active without
	# obscuring the weapon or the gameplay ball.
	var vapor_phase := float(Time.get_ticks_msec()) * 0.0025
	for i in 4:
		var drift := fmod(vapor_phase + float(i) * 0.24, 1.0)
		var vapor_center := tip + direction * size * drift * 0.23 + direction.orthogonal() * sin(vapor_phase * 3.0 + float(i)) * size * 0.055
		var vapor_alpha := (1.0 - drift) * (0.08 + frost_power * 0.18)
		draw_circle(vapor_center, size * (0.035 + drift * 0.055), Color(0.78, 0.96, 1.0, vapor_alpha))
	if frost_power > 0.01:
		draw_circle(tip, size * (0.12 + frost_power * 0.04), Color(0.63, 0.92, 1.0, 0.14 + frost_power * 0.20))
		for i in 3:
			var crystal_angle := vapor_phase * 4.0 + TAU * float(i) / 3.0
			var crystal := tip + Vector2(cos(crystal_angle), sin(crystal_angle)) * size * 0.16
			draw_circle(crystal, maxf(1.0, size * 0.022), Color(0.91, 1.0, 1.0, 0.60 * frost_power))
	return tip

func draw_ice_weapons_idle() -> void:
	if customizer_open or ice_trap_is_active():
		return
	var points := ice_weapon_points()
	var scale_y := board_rect.size.y / 600.0
	var pulse := (sin(float(Time.get_ticks_msec()) * 0.0038) + 1.0) * 0.5
	draw_ice_emitter(points.left, points.freeze, 53.0 * scale_y * trap_weapon_scale(ICE_TRAP_HOLE, 0), pulse * 0.16)
	draw_ice_emitter(points.right, points.freeze, 53.0 * scale_y * trap_weapon_scale(ICE_TRAP_HOLE, 1), pulse * 0.16)

func draw_ice_stream(origin: Vector2, target: Vector2, amount: float, seed_offset: float, edit_scale: float = 1.0) -> void:
	if amount <= 0.01:
		return
	var direction := target - origin
	var normal := direction.normalized().orthogonal()
	var end := origin.lerp(target, amount)
	var width := maxf(2.0, board_rect.size.y / 600.0 * 7.0 * edit_scale)
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
	var points := ice_weapon_points()
	var left_weapon: Vector2 = points.left
	var right_weapon: Vector2 = points.right
	var freeze_point: Vector2 = points.freeze
	var radius := trap_ball_radius(ICE_TRAP_HOLE, 27.0 * scale_y)
	var spray := smooth_step(seconds / 0.82)
	var freeze := smooth_step((seconds - 0.22) / 1.18)
	var release := smooth_step((seconds - TRAP_CAPTURE_TIME) / TRAP_FALL_TIME)
	var center := freeze_point
	var alpha := 1.0
	if release > 0.0:
		var gravity_fall := release * release
		# Finish just below the table so the small frozen animal remains visible
		# when the water-floating phase takes over.
		center = freeze_point.lerp(effect_fall_endpoint(ICE_TRAP_HOLE), gravity_fall)
		center.x += sin(release * PI) * 5.0 * scale_y
		radius *= 1.0 - release * 0.28
		alpha = 1.0 - release * 0.12
	var stream_strength := spray * (1.0 - smooth_step((seconds - 1.28) / 0.37))
	var left_tip := draw_ice_emitter(left_weapon, freeze_point, 53.0 * scale_y * trap_weapon_scale(ICE_TRAP_HOLE, 0), stream_strength)
	var right_tip := draw_ice_emitter(right_weapon, freeze_point, 53.0 * scale_y * trap_weapon_scale(ICE_TRAP_HOLE, 1), stream_strength)
	if seconds < 1.65:
		draw_ice_stream(left_tip, freeze_point, stream_strength, 0.13, trap_weapon_scale(ICE_TRAP_HOLE, 0))
		draw_ice_stream(right_tip, freeze_point, stream_strength, 0.61, trap_weapon_scale(ICE_TRAP_HOLE, 1))
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
	draw_string(ui_font, panel.position + Vector2(0, 38), "CHOOSE YOUR ANIMAL AND LIFEBUOY", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 22, Color("f6d365"))
	draw_string(ui_font, panel.position + Vector2(20, 72), "ANIMAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in ANIMAL_NAMES.size():
		var rect := customizer_animal_rect(i, viewport_size)
		draw_style_box(make_box(Color("7256d8") if i == player_animal else Color("26384b"), 10.0), rect)
		draw_string(ui_font, rect.position + Vector2(0, 40), ANIMAL_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 12, Color.WHITE)
	draw_string(ui_font, panel.position + Vector2(20, 195), "LIFEBUOY COLOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in RING_COLOR_NAMES.size():
		var rect := customizer_color_rect(i, viewport_size)
		draw_style_box(make_box(RING_COLORS[i], 10.0), rect)
		if i == player_ring_color:
			draw_rect(rect.grow(3.0), Color.WHITE, false, 3.0)
		draw_string(ui_font, rect.position + Vector2(0, 36), RING_COLOR_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color.WHITE)
	var start_rect := customizer_start_rect(viewport_size)
	draw_style_box(make_box(Color("12a96b"), 14.0), start_rect)
	draw_string(ui_font, start_rect.position + Vector2(0, 31), "START GAME", HORIZONTAL_ALIGNMENT_CENTER, start_rect.size.x, 17, Color.WHITE)

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
	var capture := trap_ball_position(RUBBER_TRAP_HOLE, rubber_point(128.0, 104.0))
	return {
		"capture": capture,
		# Measured from the source video: the launchers sit diagonally across
		# the opening, not directly above and left of the captured ball.
		"top": rubber_point(223.0, 33.0) + trap_weapon_offset(RUBBER_TRAP_HOLE, 0),
		"side": rubber_point(54.0, 177.0) + trap_weapon_offset(RUBBER_TRAP_HOLE, 1)
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
	draw_rubber_launcher(points.top, points.capture, 44.0 * scale_y * trap_weapon_scale(RUBBER_TRAP_HOLE, 0), pulse * 0.18)
	draw_rubber_launcher(points.side, points.capture, 44.0 * scale_y * trap_weapon_scale(RUBBER_TRAP_HOLE, 1), pulse * 0.18)

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
	var ball_radius := trap_ball_radius(RUBBER_TRAP_HOLE, RADIUS * board_scale * GAME_BALL_VISUAL_SCALE)
	# The real gameplay ball has already entered this hole. Start the trap at
	# the capture point so the V4 preview's staged entry is not replayed.
	var ball := capture
	var reach := smooth_step((t - 0.04) / 0.18)
	var wrap := smooth_step((t - 0.05) / 0.72)
	var team: int = effect.team
	var piece: int = effect.piece
	draw_rubber_launcher(anchor_top, capture, 44.0 * scale_y * trap_weapon_scale(RUBBER_TRAP_HOLE, 0), reach)
	draw_rubber_launcher(anchor_left, capture, 44.0 * scale_y * trap_weapon_scale(RUBBER_TRAP_HOLE, 1), reach)
	if elapsed < RUBBER_CAPTURE_TIME:
		var focus := wrap * (1.0 - wrap * 0.45)
		draw_circle(ball, ball_radius * (1.45 + sin(t * 45.0) * 0.08), Color(1.0, 0.965, 0.72, 0.28 * focus))
		# Once wrapping begins, draw only the cocoon. Fading the original ball
		# underneath it left a visible duplicate through the first wrapping pass.
		if wrap <= 0.001:
			draw_rubber_game_ball(ball, ball_radius, team, piece, 1.0)
		if wrap > 0.0:
			draw_rubber_wrap(ball, ball_radius, wrap, 0.0)
	else:
		var release := smooth_step((elapsed - RUBBER_CAPTURE_TIME) / RUBBER_FALL_TIME)
		var fall := release * release
		var out := effect_fall_endpoint(RUBBER_TRAP_HOLE)
		ball = capture.lerp(out, fall)
		ball_radius *= 1.0 - release * 0.42
		# Keep the cocoon on the falling ball exactly like the source frames.
		draw_rubber_wrap(ball, ball_radius, 1.0, 0.0)

func editor_panel_rect(viewport_size: Vector2) -> Rect2:
	# Keep the editor in the vertical center so it does not cover the weapons
	# and capture points along the bottom edge of the table.
	var panel_width := minf(980.0, viewport_size.x - 24.0)
	return Rect2((viewport_size.x - panel_width) * 0.5, (viewport_size.y - 150.0) * 0.5, panel_width, 150.0)

func editor_button(index: int, viewport_size: Vector2) -> Rect2:
	var panel := editor_panel_rect(viewport_size)
	var button_w := (panel.size.x - 22.0) / 14.0
	return Rect2(panel.position + Vector2(6.0 + index * button_w, 82.0), Vector2(button_w - 4.0, 56.0))

func editor_top_button(index: int, viewport_size: Vector2) -> Rect2:
	var panel := editor_panel_rect(viewport_size)
	var button_w := (panel.size.x - 12.0) / 7.0
	return Rect2(panel.position + Vector2(6.0 + index * button_w, 8.0), Vector2(button_w - 4.0, 46.0))

func handle_effect_editor_touch(screen_pos: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	var toggle := Rect2(viewport_size.x - 334.0, 6.0, 145.0, 42.0)
	if toggle.has_point(screen_pos):
		effect_editor_enabled = not effect_editor_enabled
		if effect_editor_enabled:
			replay_effect_editor()
		queue_redraw()
		return true
	if not effect_editor_enabled:
		return false
	for i in 7:
		if not editor_top_button(i, viewport_size).has_point(screen_pos):
			continue
		if i == 0:
			DisplayServer.clipboard_set(editor_settings_text())
			status = "Effect settings copied"
		else:
			editor_hole = i - 1
			editor_target = 0
			replay_effect_editor()
		queue_redraw()
		return true
	for i in 14:
		if not editor_button(i, viewport_size).has_point(screen_pos):
			continue
		match i:
			0: editor_target = 0
			1: editor_target = 1
			2: editor_target = 2
			3: editor_target = 3
			4: editor_target = 4
			5: editor_target = 5
			6: change_editor_offset(Vector2(-1, 0))
			7: change_editor_offset(Vector2(1, 0))
			8: change_editor_offset(Vector2(0, -1))
			9: change_editor_offset(Vector2(0, 1))
			10: change_editor_width(-0.10)
			11: change_editor_width(0.10)
			12: reset_editor_target()
			13: replay_effect_editor()
		replay_effect_editor()
		queue_redraw()
		return true
	return editor_panel_rect(viewport_size).has_point(screen_pos)

func change_editor_offset(amount: Vector2) -> void:
	if editor_target == 5:
		var side := editor_wall_side(editor_hole)
		if side == 0 or side == 2:
			table_wall_offsets[side] += amount.x
		else:
			table_wall_offsets[side] += amount.y
	elif editor_target == 4:
		trap_entry_offsets[editor_hole] += amount
	elif editor_target == 3:
		trap_fall_offsets[editor_hole] += amount
	elif editor_target == 2:
		trap_ball_offsets[editor_hole] += amount
	else:
		trap_weapon_offsets[editor_hole * 2 + editor_target] += amount

func change_editor_width(amount: float) -> void:
	if editor_target == 5:
		var side := editor_wall_side(editor_hole)
		table_wall_sizes[side] = clampf(table_wall_sizes[side] + amount * 10.0, 1.0, 12.0)
		return
	if editor_target == 4:
		trap_entry_radii[editor_hole] = clampf(trap_entry_radii[editor_hole] + amount * 10.0, 2.0, 40.0)
		return
	if editor_target == 3:
		return
	if editor_target == 2:
		trap_ball_scales[editor_hole] = clampf(trap_ball_scales[editor_hole] + amount, 0.4, 2.0)
	else:
		var index := editor_hole * 2 + editor_target
		trap_weapon_scales[index] = clampf(trap_weapon_scales[index] + amount, 0.4, 2.0)

func approved_weapon_offset(hole: int, weapon: int) -> Vector2:
	var approved: Array[Vector2] = [
		Vector2(0.0, 15.0), Vector2(10.0, -5.0),
		Vector2(-3.0, 0.0), Vector2(14.0, -1.0),
		Vector2(10.0, 40.0), Vector2(-27.0, -3.0),
		Vector2(20.0, 5.0), Vector2(0.0, 5.0),
		Vector2(26.0, 1.0), Vector2(-16.0, 2.0),
		Vector2(-5.0, -10.0), Vector2(10.0, 0.0)
	]
	return approved[hole * 2 + weapon]

func approved_weapon_scale(hole: int, weapon: int) -> float:
	var approved: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.2, 1.2, 1.1, 1.0, 1.0, 1.0, 1.0, 1.0]
	return approved[hole * 2 + weapon]

func approved_ball_offset(hole: int) -> Vector2:
	var approved: Array[Vector2] = [Vector2(-10.0, -15.0), Vector2(4.0, -5.0), Vector2(35.0, -5.0), Vector2(10.0, 20.0), Vector2(5.0, 20.0), Vector2(0.0, 10.0)]
	return approved[hole]

func approved_ball_scale(hole: int) -> float:
	var approved: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	return approved[hole]

func approved_fall_offset(hole: int) -> Vector2:
	var approved: Array[Vector2] = [Vector2(20.0, 55.0), Vector2(0.0, 30.0), Vector2(-15.0, 45.0), Vector2.ZERO, Vector2.ZERO, Vector2(-30.0, -60.0)]
	return approved[hole]

func approved_entry_offset(hole: int) -> Vector2:
	var approved: Array[Vector2] = [
		Vector2(-13.0, 0.0), Vector2(-1.0, -11.0), Vector2(11.0, -2.0),
		Vector2(12.0, 14.0), Vector2(1.0, 19.0), Vector2(-12.0, 14.0)
	]
	return approved[hole]

func approved_entry_radius(hole: int) -> float:
	var approved: Array[float] = [13.0, 12.0, 12.0, 12.0, 11.0, 12.0]
	return approved[hole]

func approved_wall_offset(side: int) -> float:
	var approved: Array[float] = [-2.0, -7.0, 5.0, 8.0]
	return approved[side]

func approved_wall_size(side: int) -> float:
	var approved: Array[float] = [1.0, 1.0, 1.0, 1.0]
	return approved[side]

func reset_editor_target() -> void:
	if editor_target == 5:
		var side := editor_wall_side(editor_hole)
		table_wall_offsets[side] = approved_wall_offset(side)
		table_wall_sizes[side] = approved_wall_size(side)
	elif editor_target == 4:
		trap_entry_offsets[editor_hole] = approved_entry_offset(editor_hole)
		trap_entry_radii[editor_hole] = approved_entry_radius(editor_hole)
	elif editor_target == 3:
		trap_fall_offsets[editor_hole] = approved_fall_offset(editor_hole)
	elif editor_target == 2:
		trap_ball_offsets[editor_hole] = approved_ball_offset(editor_hole)
		trap_ball_scales[editor_hole] = approved_ball_scale(editor_hole)
	else:
		var index := editor_hole * 2 + editor_target
		trap_weapon_offsets[index] = approved_weapon_offset(editor_hole, editor_target)
		trap_weapon_scales[index] = approved_weapon_scale(editor_hole, editor_target)

func change_editor_rotation(amount: float) -> void:
	if effect_editor_mode == "electric":
		return
	if editor_selected_hand == 0:
		rubber_top_rotation += amount
	else:
		rubber_side_rotation += amount

func toggle_editor_mirror() -> void:
	if effect_editor_mode == "electric":
		return
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

func replay_effect_editor() -> void:
	active_effects.clear()
	active_effects.append({"hole":editor_hole, "elapsed":0.0, "team":0, "piece":0})

func editor_settings_text() -> String:
	var names := ["RUBBER", "PRESS", "ELECTRIC", "HAMMER", "ICE", "FIRE"]
	var first := editor_hole * 2
	var wall_side := editor_wall_side(editor_hole)
	var wall_names := ["left", "top", "right", "bottom"]
	return "%s: weapon1=%s %.2f; weapon2=%s %.2f; ball=%s %.2f; fall=%s; entry=%s radius=%.1f; wall=%s offset=%.1f size=%.1f" % [names[editor_hole], trap_weapon_offsets[first], trap_weapon_scales[first], trap_weapon_offsets[first + 1], trap_weapon_scales[first + 1], trap_ball_offsets[editor_hole], trap_ball_scales[editor_hole], trap_fall_offsets[editor_hole], trap_entry_offsets[editor_hole], trap_entry_radii[editor_hole], wall_names[wall_side], table_wall_offsets[wall_side], table_wall_sizes[wall_side]]

func draw_editor_button(rect: Rect2, label: String, selected_button: bool = false) -> void:
	draw_style_box(make_box(Color("7256d8") if selected_button else Color("26384b"), 8.0), rect)
	draw_string(ui_font, rect.position + Vector2(0, 36), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color.WHITE)

func draw_effect_editor(viewport_size: Vector2) -> void:
	if not effect_editor_enabled:
		return
	var panel := editor_panel_rect(viewport_size)
	draw_style_box(make_box(Color(0.04, 0.07, 0.12, 0.94), 12.0), panel)
	var names := ["RUBBER", "PRESS", "ELECTRIC", "HAMMER", "ICE", "FIRE"]
	var editor_title := "ALL WEAPONS + CAPTURE BALL EDITOR"
	draw_string(ui_font, panel.position + Vector2(8, 76), editor_title, HORIZONTAL_ALIGNMENT_LEFT, 330, 14, Color("f6d365"))
	var selected_name: String = ["WEAPON 1", "WEAPON 2", "BALL", "FALL", "ENTRY", "WALL"][editor_target]
	var values := editor_settings_text()
	draw_string(ui_font, panel.position + Vector2(345, 76), names[editor_hole] + " / " + selected_name, HORIZONTAL_ALIGNMENT_LEFT, 180, 13, Color.WHITE)
	draw_string(ui_font, panel.position + Vector2(530, 76), values, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 540, 9, Color("dbe7f3"))
	draw_editor_button(editor_top_button(0, viewport_size), "COPY")
	for i in 6:
		draw_editor_button(editor_top_button(i + 1, viewport_size), names[i], editor_hole == i)
	var labels := ["WEAPON 1", "WEAPON 2", "BALL", "FALL", "ENTRY", "WALL", "X -", "X +", "Y -", "Y +", "SIZE-", "SIZE+", "RESET", "REPLAY"]
	for i in 14:
		draw_editor_button(editor_button(i, viewport_size), labels[i], (i == editor_target and i < 6))

func frontend_top_button(index: int, viewport_size: Vector2) -> Rect2:
	return Rect2(viewport_size.x - 300.0 + index * 142.0, 22.0, 126.0, 48.0)

func frontend_mode_rect(index: int, viewport_size: Vector2) -> Rect2:
	var card_width := minf(286.0, (viewport_size.x - 128.0) / 3.0)
	var total_width := card_width * 3.0 + 32.0
	return Rect2(Vector2((viewport_size.x - total_width) * 0.5 + index * (card_width + 16.0), viewport_size.y * 0.43), Vector2(card_width, minf(225.0, viewport_size.y * 0.34)))

func home_mode_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	if index == 2:
		return Rect2(viewport_size.x - 385.0 * unit, viewport_size.y - 178.0 * unit, 350.0 * unit, 120.0 * unit)
	return Rect2(viewport_size.x - 385.0 * unit, (202.0 + float(index) * 98.0) * unit, 350.0 * unit, 82.0 * unit)

func arena_card_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var card_size := Vector2(350.0, 430.0) * unit
	var gap := 24.0 * unit
	var total_width := card_size.x * 3.0 + gap * 2.0
	return Rect2(Vector2((viewport_size.x - total_width) * 0.5 + float(index) * (card_size.x + gap), 142.0 * unit), card_size)

func arena_play_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((viewport_size.x - 290.0 * unit) * 0.5, viewport_size.y - 78.0 * unit), Vector2(290.0, 58.0) * unit)

func player_profile_animal_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((62.0 + float(index) * 62.0) * unit, 526.0 * unit), Vector2(54.0, 62.0) * unit)

func player_profile_color_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((70.0 + float(index) * 60.0) * unit, 614.0 * unit), Vector2(44.0, 44.0) * unit)

func home_profile_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(28.0 * unit, 22.0 * unit, 282.0 * unit, 58.0 * unit)

func home_coin_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(viewport_size.x - 374.0 * unit, 22.0 * unit, 154.0 * unit, 54.0 * unit)

func home_settings_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(viewport_size.x - 78.0 * unit, 22.0 * unit, 54.0 * unit, 54.0 * unit)

func home_nav_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(20.0 * unit, (126.0 + float(index) * 94.0) * unit, 178.0 * unit, 78.0 * unit)

func home_character_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(viewport_size.x * 0.29, viewport_size.y * 0.16), Vector2(280.0, 410.0) * unit)

func character_card_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var card_size := Vector2(158.0, 150.0) * unit
	var gap := 12.0 * unit
	var total_width := card_size.x * 6.0 + gap * 5.0
	var start_x := (viewport_size.x - total_width) * 0.5
	return Rect2(Vector2(start_x + float(index) * (card_size.x + gap), viewport_size.y - 174.0 * unit), card_size)

func character_ring_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var size := Vector2(180.0, 78.0) * unit
	var column := index % 3
	var row := index / 3
	return Rect2(Vector2((596.0 + float(column) * 196.0) * unit, (246.0 + float(row) * 94.0) * unit), size)

func frontend_back_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(24.0, 22.0, 116.0, 48.0)

func start_selected_mode(mode: String) -> void:
	game_mode = mode
	customizer_open = false
	effect_editor_enabled = false
	app_screen = APP_GAME
	new_game()
	if game_mode == "friend":
		status = "Red player's turn - local match"
	else:
		status = "Your turn - touch a red ball, pull back and release"

func show_menu_notice(text: String) -> void:
	menu_notice = text
	menu_notice_time = 2.4

func ui_text(key: String) -> String:
	if ui_language == "he":
		return str(UI_TEXT_HE.get(key, UI_TEXT_EN.get(key, key)))
	return str(UI_TEXT_EN.get(key, key))

func ui_animal_name(index: int) -> String:
	var keys := ["elephant", "zebra", "monkey", "hippo", "rhino", "giraffe"]
	return ui_text(keys[clampi(index, 0, keys.size() - 1)])

func ui_ring_name(index: int) -> String:
	var keys := ["red", "orange", "blue", "green", "purple", "turquoise"]
	return ui_text(keys[clampi(index, 0, keys.size() - 1)])

func handle_frontend_touch(screen_pos: Vector2) -> void:
	var viewport_size := get_viewport_rect().size
	if app_screen == APP_SPLASH:
		app_screen = APP_HOME
		return
	if app_screen == APP_HOME:
		if home_character_rect(viewport_size).has_point(screen_pos):
			app_screen = APP_PROFILE
			return
		if home_profile_rect(viewport_size).has_point(screen_pos):
			app_screen = APP_PLAYER_PROFILE
			return
		if home_settings_rect(viewport_size).has_point(screen_pos):
			ui_language = "en" if ui_language == "he" else "he"
			show_menu_notice("English interface" if ui_language == "en" else "הממשק הוחלף לעברית")
			return
		for i in 4:
			if not home_nav_rect(i, viewport_size).has_point(screen_pos):
				continue
			if i == 0 or i == 1:
				app_screen = APP_PROFILE
			elif i == 2:
				app_screen = APP_SHOP
			else:
				show_menu_notice("DAILY REWARDS - COMING NEXT")
			return
		if home_mode_rect(0, viewport_size).has_point(screen_pos):
			app_screen = APP_ARENA
			return
		if home_mode_rect(1, viewport_size).has_point(screen_pos):
			show_menu_notice("PRIVATE FRIEND MATCH - TWO DEVICES - COMING SOON")
			return
		if home_mode_rect(2, viewport_size).has_point(screen_pos):
			start_selected_mode("computer")
			return
	else:
		if frontend_back_rect(viewport_size).has_point(screen_pos):
			app_screen = APP_HOME
			return
		if app_screen == APP_PROFILE:
			for i in ANIMAL_NAMES.size():
				if character_card_rect(i, viewport_size).has_point(screen_pos):
					player_animal = i
					rebuild_team_piece_textures()
					return
			for i in RING_COLOR_NAMES.size():
				if character_ring_rect(i, viewport_size).has_point(screen_pos):
					player_ring_color = i
					rebuild_team_piece_textures()
					return
		elif app_screen == APP_SHOP:
			show_menu_notice("THE FIRST SHOP COLLECTION IS COMING SOON")
		elif app_screen == APP_ARENA:
			for i in 3:
				if arena_card_rect(i, viewport_size).has_point(screen_pos):
					selected_arena = i
					return
			if arena_play_rect(viewport_size).has_point(screen_pos):
				show_menu_notice("ONLINE MATCHMAKING FOR THIS ARENA - COMING SOON")
		elif app_screen == APP_PLAYER_PROFILE:
			for i in ANIMAL_NAMES.size():
				if player_profile_animal_rect(i, viewport_size).has_point(screen_pos):
					player_animal = i
					rebuild_team_piece_textures()
					return
			for i in RING_COLOR_NAMES.size():
				if player_profile_color_rect(i, viewport_size).has_point(screen_pos):
					player_ring_color = i
					rebuild_team_piece_textures()
					return

func draw_menu_background(viewport_size: Vector2) -> void:
	var overlay := Color(0.015, 0.055, 0.11, 0.62)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), overlay)
	for i in 18:
		var phase := fmod(menu_elapsed * (10.0 + float(i % 4) * 3.0) + float(i * 67), viewport_size.y + 120.0)
		var x := fmod(float(i * 149 + 71), viewport_size.x)
		var y := viewport_size.y + 40.0 - phase
		var radius := 3.0 + float(i % 5) * 1.6
		draw_circle(Vector2(x, y), radius, Color(0.65, 0.94, 1.0, 0.16), false, 2.0, true)
	var horizon := Rect2(0.0, viewport_size.y * 0.76, viewport_size.x, viewport_size.y * 0.24)
	draw_rect(horizon, Color(0.0, 0.20, 0.31, 0.35))

func draw_zoopaloola_logo(center: Vector2, scale: float, reveal: float = 1.0) -> void:
	var bob := sin(menu_elapsed * 2.5) * 5.0 * scale
	var c := center + Vector2(0.0, bob)
	var ring_radius := 66.0 * scale
	draw_circle(c, ring_radius * 1.18, Color(0.15, 0.90, 1.0, 0.16 * reveal))
	draw_circle(c, ring_radius, Color("ff5a55"), false, 20.0 * scale, true)
	draw_arc(c, ring_radius, -2.35, -0.78, 30, Color.WHITE, 20.0 * scale, true)
	draw_arc(c, ring_radius, 0.78, 2.35, 30, Color.WHITE, 20.0 * scale, true)
	var ear := 24.0 * scale
	draw_circle(c + Vector2(-31.0, -34.0) * scale, ear, Color("607d8b"))
	draw_circle(c + Vector2(31.0, -34.0) * scale, ear, Color("607d8b"))
	draw_circle(c + Vector2.ZERO, 43.0 * scale, Color("93aeb8"))
	draw_circle(c + Vector2(-14.0, -7.0) * scale, 6.0 * scale, Color("102338"))
	draw_circle(c + Vector2(14.0, -7.0) * scale, 6.0 * scale, Color("102338"))
	draw_line(c + Vector2(0.0, 3.0) * scale, c + Vector2(4.0, 29.0) * scale, Color("667f8b"), 12.0 * scale, true)
	draw_string(ui_font, c + Vector2(-225.0, 118.0) * scale, "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_CENTER, 450.0 * scale, int(54.0 * scale), Color(1.0, 0.86, 0.25, reveal))

func draw_splash_screen(viewport_size: Vector2) -> void:
	if loading_team_texture != null:
		draw_texture_rect(loading_team_texture, Rect2(Vector2.ZERO, viewport_size), false)
	else:
		draw_menu_background(viewport_size)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.03, 0.08, 0.08))
	var entrance := smooth_step(splash_elapsed / 0.75)
	var exit_alpha := 1.0 - smooth_step((splash_elapsed - 2.65) / 0.55)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var logo_width := 510.0 * unit * (0.92 + entrance * 0.08)
	var logo_height := logo_width * 174.0 / 540.0
	var logo_rect := Rect2(Vector2((viewport_size.x - logo_width) * 0.5, 14.0 * unit), Vector2(logo_width, logo_height))
	if zoopaloola_logo_texture != null:
		draw_texture_rect(zoopaloola_logo_texture, logo_rect, false, Color(1.0, 1.0, 1.0, entrance * exit_alpha))
	else:
		draw_zoopaloola_logo(Vector2(viewport_size.x * 0.5, 102.0 * unit), (0.50 + entrance * 0.10) * unit, entrance * exit_alpha)
	var loading_width := minf(620.0 * unit, viewport_size.x * 0.52)
	var loading_rect := Rect2((viewport_size.x - loading_width) * 0.5, viewport_size.y - 58.0 * unit, loading_width, 23.0 * unit)
	draw_style_box(make_box(Color(0.015, 0.035, 0.07, 0.92), 12.0), loading_rect.grow(5.0 * unit))
	draw_style_box(make_box(Color("25385d"), 10.0), loading_rect)
	var progress := clampf(splash_elapsed / 2.85, 0.0, 1.0)
	var fill_rect := Rect2(loading_rect.position, Vector2(maxf(12.0 * unit, loading_rect.size.x * progress), loading_rect.size.y))
	draw_style_box(make_box(Color("ffd83d"), 10.0), fill_rect)
	draw_string(ui_font, Vector2(0.0, loading_rect.position.y - 12.0 * unit), "LOADING THE ISLAND...", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(13.0 * unit), Color.WHITE)

func draw_frontend(viewport_size: Vector2) -> void:
	if app_screen == APP_HOME:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		else:
			draw_menu_background(viewport_size)
		draw_home_screen(viewport_size)
	elif app_screen == APP_PROFILE:
		draw_menu_background(viewport_size)
		draw_profile_screen(viewport_size)
	elif app_screen == APP_SHOP:
		draw_menu_background(viewport_size)
		draw_shop_screen(viewport_size)
	elif app_screen == APP_ARENA:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_arena_screen(viewport_size)
	elif app_screen == APP_PLAYER_PROFILE:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_player_profile_screen(viewport_size)
	if menu_notice_time > 0.0:
		var toast := Rect2(viewport_size.x * 0.31, viewport_size.y - 68.0, viewport_size.x * 0.38, 46.0)
		draw_style_box(make_box(Color(0.04, 0.08, 0.14, 0.94), 14.0), toast)
		draw_string(ui_font, toast.position + Vector2(0.0, 29.0), menu_notice, HORIZONTAL_ALIGNMENT_CENTER, toast.size.x, 14, Color("f6d365"))

func draw_arena_preview(preview: Rect2, arena_index: int, unit: float) -> void:
	if arena_index == 0:
		draw_rect(preview, Color("f8b7c6"))
		draw_circle(preview.position + Vector2(preview.size.x * 0.78, preview.size.y * 0.25), 34.0 * unit, Color("ffd884"))
		draw_rect(Rect2(preview.position + Vector2(0.0, preview.size.y * 0.68), Vector2(preview.size.x, preview.size.y * 0.32)), Color("5eaf72"))
		var gate_x := preview.position.x + preview.size.x * 0.22
		var gate_y := preview.position.y + preview.size.y * 0.46
		draw_line(Vector2(gate_x - 45.0 * unit, gate_y), Vector2(gate_x + 45.0 * unit, gate_y), Color("b92f2f"), 13.0 * unit, true)
		draw_line(Vector2(gate_x - 31.0 * unit, gate_y), Vector2(gate_x - 31.0 * unit, gate_y + 72.0 * unit), Color("8f2525"), 10.0 * unit, true)
		draw_line(Vector2(gate_x + 31.0 * unit, gate_y), Vector2(gate_x + 31.0 * unit, gate_y + 72.0 * unit), Color("8f2525"), 10.0 * unit, true)
		var tree_center := preview.position + Vector2(preview.size.x * 0.73, preview.size.y * 0.49)
		draw_line(tree_center, tree_center + Vector2(-16.0, 78.0) * unit, Color("70432f"), 15.0 * unit, true)
		for offset in [Vector2(-42.0, -13.0), Vector2(-8.0, -35.0), Vector2(31.0, -18.0), Vector2(52.0, 9.0), Vector2(8.0, 4.0)]:
			draw_circle(tree_center + offset * unit, 31.0 * unit, Color("f06f9c"))
	elif arena_index == 1:
		draw_rect(preview, Color("8ed17b"))
		draw_rect(Rect2(preview.position + Vector2(0.0, preview.size.y * 0.72), Vector2(preview.size.x, preview.size.y * 0.28)), Color("b88a4e"))
		for i in 9:
			var x := preview.position.x + (22.0 + float(i) * 38.0) * unit
			var lean := float((i % 3) - 1) * 8.0 * unit
			draw_line(Vector2(x, preview.position.y - 4.0), Vector2(x + lean, preview.position.y + preview.size.y * 0.86), Color("236c3e"), 13.0 * unit, true)
			for j in 4:
				var y := preview.position.y + (34.0 + float(j) * 43.0) * unit
				draw_line(Vector2(x - 6.0 * unit, y), Vector2(x + 7.0 * unit, y), Color("c1e15d"), 3.0 * unit, true)
		var platform := preview.position + Vector2(preview.size.x * 0.58, preview.size.y * 0.75)
		draw_circle(platform, 58.0 * unit, Color("d0a95c"))
		draw_circle(platform, 45.0 * unit, Color("a47a3d"), false, 4.0 * unit, true)
	else:
		draw_rect(preview, Color("30284a"))
		draw_circle(preview.position + Vector2(preview.size.x * 0.78, preview.size.y * 0.20), 30.0 * unit, Color("ff9954"))
		var mountain := PackedVector2Array([
			preview.position + Vector2(0.0, preview.size.y),
			preview.position + Vector2(preview.size.x * 0.50, preview.size.y * 0.28),
			preview.end,
		])
		draw_colored_polygon(mountain, Color("513841"))
		var lava_top := preview.position + Vector2(preview.size.x * 0.50, preview.size.y * 0.29)
		draw_line(lava_top, preview.position + Vector2(preview.size.x * 0.43, preview.size.y), Color("ff5b2d"), 20.0 * unit, true)
		draw_line(lava_top, preview.position + Vector2(preview.size.x * 0.57, preview.size.y), Color("ffb12b"), 8.0 * unit, true)

func draw_arena_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.42))
	draw_frontend_header(viewport_size, ui_text("arena_title"), ui_text("arena_title_sub"))
	var names := [ui_text("sakura"), ui_text("bamboo"), ui_text("volcano")]
	var entries := [0, 100, 500]
	var prizes := [100, 250, 1200]
	var card_colors := [Color("f08aac"), Color("62b55d"), Color("e65b36")]
	for i in 3:
		var card := arena_card_rect(i, viewport_size)
		var selected := i == selected_arena
		var border := Color("ffe25d") if selected else Color(0.02, 0.07, 0.12, 0.92)
		draw_style_box(make_box(border, 25.0 * unit), card.grow((8.0 if selected else 5.0) * unit))
		draw_style_box(make_box(Color("f8f2cf"), 22.0 * unit), card)
		var preview := Rect2(card.position + Vector2(15.0, 15.0) * unit, Vector2(card.size.x - 30.0 * unit, 205.0 * unit))
		draw_style_box(make_box(card_colors[i], 17.0 * unit), preview.grow(3.0 * unit))
		draw_arena_preview(preview, i, unit)
		var title_rect := Rect2(card.position + Vector2(15.0, 232.0) * unit, Vector2(card.size.x - 30.0 * unit, 54.0 * unit))
		draw_style_box(make_box(Color("314f22"), 13.0 * unit), title_rect)
		draw_string(ui_font, title_rect.position + Vector2(0.0, 36.0) * unit, names[i], HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, int(21.0 * unit), Color.WHITE)
		var entry_text := ui_text("entry_free") if entries[i] == 0 else ui_text("entry") + str(entries[i]) + ui_text("coins")
		draw_string(ui_font, card.position + Vector2(22.0, 325.0) * unit, entry_text, HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 44.0 * unit, int(15.0 * unit), Color("354522"))
		draw_string(ui_font, card.position + Vector2(22.0, 363.0) * unit, ui_text("prize") + str(prizes[i]) + ui_text("coins"), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 44.0 * unit, int(17.0 * unit), Color("a66013"))
		if selected:
			draw_string(ui_font, card.position + Vector2(0.0, 408.0) * unit, ui_text("selected"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(15.0 * unit), Color("16845b"))
	var play := arena_play_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.90), 18.0 * unit), play.grow(5.0 * unit))
	draw_style_box(make_box(Color("6fda18"), 16.0 * unit), play)
	draw_string(ui_font, play.position + Vector2(0.0, 38.0) * unit, ui_text("find_match"), HORIZONTAL_ALIGNMENT_CENTER, play.size.x, int(20.0 * unit), Color.WHITE)

func draw_profile_stat_card(rect: Rect2, label: String, value: String, accent: Color, unit: float) -> void:
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.88), 17.0 * unit), rect.grow(3.0 * unit))
	draw_style_box(make_box(Color("f4f1df"), 15.0 * unit), rect)
	draw_circle(rect.position + Vector2(28.0 * unit, rect.size.y * 0.50), 14.0 * unit, accent)
	draw_string(ui_font, rect.position + Vector2(53.0, 30.0) * unit, label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 65.0 * unit, int(12.0 * unit), Color("607080"))
	draw_string(ui_font, rect.position + Vector2(53.0, 62.0) * unit, value, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 65.0 * unit, int(24.0 * unit), Color("173249"))

func draw_player_profile_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.48))
	draw_frontend_header(viewport_size, ui_text("profile_title"), ui_text("profile_sub"))
	var hero_panel := Rect2(Vector2(38.0, 102.0) * unit, Vector2(410.0, 570.0) * unit)
	draw_style_box(make_box(Color(0.02, 0.08, 0.14, 0.88), 27.0 * unit), hero_panel.grow(5.0 * unit))
	draw_style_box(make_box(Color("48c4d1"), 24.0 * unit), hero_panel)
	var glow_center := hero_panel.position + Vector2(hero_panel.size.x * 0.50, 178.0 * unit)
	draw_circle(glow_center, 145.0 * unit, Color(0.82, 0.98, 1.0, 0.28))
	var podium_center := hero_panel.position + Vector2(hero_panel.size.x * 0.50, 328.0 * unit)
	draw_wood_podium(podium_center, unit * 0.66, false)
	var hero_texture: Texture2D = null
	if player_animal < lifebuoy_hero_textures.size():
		var hero_colors: Array = lifebuoy_hero_textures[player_animal]
		if player_ring_color < hero_colors.size():
			hero_texture = hero_colors[player_ring_color] as Texture2D
	if hero_texture != null:
		var hero_size := Vector2(220.0, 286.0) * unit
		var hero_center := hero_panel.position + Vector2(hero_panel.size.x * 0.50, 176.0 * unit)
		draw_texture_rect(hero_texture, Rect2(hero_center - hero_size * 0.5, hero_size), false)
	draw_string(ui_font, hero_panel.position + Vector2(0.0, 382.0) * unit, ui_text("main_character"), HORIZONTAL_ALIGNMENT_CENTER, hero_panel.size.x, int(12.0 * unit), Color("d8f8ff"))
	draw_string(ui_font, hero_panel.position + Vector2(0.0, 411.0) * unit, ui_animal_name(player_animal), HORIZONTAL_ALIGNMENT_CENTER, hero_panel.size.x, int(22.0 * unit), Color.WHITE)
	draw_string(ui_font, hero_panel.position + Vector2(22.0, 451.0) * unit, ui_text("choose_main"), HORIZONTAL_ALIGNMENT_CENTER, hero_panel.size.x - 44.0 * unit, int(12.0 * unit), Color("173249"))
	for i in ANIMAL_NAMES.size():
		var animal_rect := player_profile_animal_rect(i, viewport_size)
		var animal_selected := i == player_animal
		draw_style_box(make_box(Color("ffe25d") if animal_selected else Color("244d70"), 13.0 * unit), animal_rect.grow((4.0 if animal_selected else 2.0) * unit))
		draw_style_box(make_box(Color("e9f9f4"), 11.0 * unit), animal_rect)
		if i < full_body_animal_textures.size() and full_body_animal_textures[i] != null:
			draw_texture_rect(full_body_animal_textures[i], animal_rect.grow(-5.0 * unit), false)
	draw_string(ui_font, hero_panel.position + Vector2(22.0, 506.0) * unit, ui_text("favorite_color"), HORIZONTAL_ALIGNMENT_CENTER, hero_panel.size.x - 44.0 * unit, int(12.0 * unit), Color("173249"))
	for i in RING_COLORS.size():
		var color_rect := player_profile_color_rect(i, viewport_size)
		var color_center := color_rect.get_center()
		if i == player_ring_color:
			draw_circle(color_center, 25.0 * unit, Color.WHITE)
			draw_circle(color_center, 21.0 * unit, Color("ffe25d"))
		draw_circle(color_center, 17.0 * unit, RING_COLORS[i])

	var info_panel := Rect2(Vector2(474.0, 102.0) * unit, Vector2(768.0, 570.0) * unit)
	draw_style_box(make_box(Color(0.02, 0.08, 0.14, 0.92), 27.0 * unit), info_panel.grow(5.0 * unit))
	draw_style_box(make_box(Color("eaf8f1"), 24.0 * unit), info_panel)
	draw_circle(info_panel.position + Vector2(66.0, 69.0) * unit, 45.0 * unit, RING_COLORS[player_ring_color])
	if team_piece_textures.size() > 0 and team_piece_textures[0] != null:
		draw_texture_rect(team_piece_textures[0], Rect2(info_panel.position + Vector2(27.0, 30.0) * unit, Vector2(78.0, 78.0) * unit), false)
	draw_string(ui_font, info_panel.position + Vector2(130.0, 58.0) * unit, ui_text("player"), HORIZONTAL_ALIGNMENT_LEFT, 390.0 * unit, int(30.0 * unit), Color("173249"))
	draw_string(ui_font, info_panel.position + Vector2(130.0, 87.0) * unit, ui_text("level"), HORIZONTAL_ALIGNMENT_LEFT, 390.0 * unit, int(13.0 * unit), Color("2982a6"))
	var coin_box := Rect2(info_panel.position + Vector2(558.0, 27.0) * unit, Vector2(176.0, 74.0) * unit)
	draw_style_box(make_box(Color("253e67"), 17.0 * unit), coin_box)
	draw_circle(coin_box.position + Vector2(35.0, 37.0) * unit, 17.0 * unit, Color("ffc83d"))
	draw_string(ui_font, coin_box.position + Vector2(65.0, 47.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 95.0 * unit, int(22.0 * unit), Color.WHITE)
	var xp_rect := Rect2(info_panel.position + Vector2(130.0, 104.0) * unit, Vector2(400.0, 20.0) * unit)
	draw_style_box(make_box(Color("cadbd5"), 9.0 * unit), xp_rect)
	var xp_ratio := clampf(float(player_xp) / float(maxi(1, player_next_level_xp)), 0.0, 1.0)
	draw_style_box(make_box(Color("49c984"), 9.0 * unit), Rect2(xp_rect.position, Vector2(xp_rect.size.x * xp_ratio, xp_rect.size.y)))
	draw_string(ui_font, info_panel.position + Vector2(545.0, 121.0) * unit, str(player_xp) + " / " + str(player_next_level_xp) + " XP", HORIZONTAL_ALIGNMENT_LEFT, 170.0 * unit, int(11.0 * unit), Color("526b72"))
	draw_string(ui_font, info_panel.position + Vector2(30.0, 165.0) * unit, ui_text("career"), HORIZONTAL_ALIGNMENT_CENTER, info_panel.size.x - 60.0 * unit, int(20.0 * unit), Color("173249"))
	var total_matches := player_wins + player_losses
	var win_rate := 0
	if total_matches > 0:
		win_rate = int(round(float(player_wins) * 100.0 / float(total_matches)))
	var labels := [ui_text("matches"), ui_text("wins"), ui_text("losses"), ui_text("win_rate"), ui_text("best_streak"), ui_text("world_rank")]
	var values := [str(total_matches), str(player_wins), str(player_losses), str(win_rate) + "%", str(player_best_streak), "#" + str(player_world_rank)]
	var accents := [Color("42b8e8"), Color("49c984"), Color("ef6b65"), Color("ffc83d"), Color("9d59e8"), Color("ff8b3d")]
	for i in 6:
		var column := i % 2
		var row := i / 2
		var stat_rect := Rect2(info_panel.position + Vector2(30.0 + float(column) * 354.0, 190.0 + float(row) * 112.0) * unit, Vector2(330.0, 88.0) * unit)
		draw_profile_stat_card(stat_rect, labels[i], values[i], accents[i], unit)
	draw_string(ui_font, info_panel.position + Vector2(30.0, 548.0) * unit, ui_text("current_streak") + str(player_current_streak), HORIZONTAL_ALIGNMENT_CENTER, info_panel.size.x - 60.0 * unit, int(14.0 * unit), Color("526b72"))

func draw_home_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	# Readability gradients preserve the illustrated island while separating the controls.
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.05))
	draw_rect(Rect2(0.0, 0.0, 205.0 * unit, viewport_size.y), Color(0.02, 0.06, 0.12, 0.36))
	draw_rect(Rect2(viewport_size.x - 395.0 * unit, 92.0 * unit, 395.0 * unit, viewport_size.y - 92.0 * unit), Color(0.02, 0.06, 0.12, 0.18))

	# Full-body hero with the selected lifebuoy wrapped around its waist.
	var character_area := home_character_rect(viewport_size)
	var idle_phase := menu_elapsed * 1.55
	# Keep the soles slightly inside the visible top plane so the idle motion
	# never makes the animal appear to float above the wooden stage.
	var hero_center := character_area.position + Vector2(character_area.size.x * 0.50, character_area.size.y * 0.405)
	var hero_size := character_area.size
	var breathe := 1.0 + sin(idle_phase) * 0.006
	var gentle_float := sin(idle_phase * 0.72) * 1.2 * unit
	var animated_center := hero_center + Vector2(0.0, gentle_float)
	var waist_center := character_area.position + Vector2(character_area.size.x * 0.50, character_area.size.y * 0.58 + gentle_float)
	var ring_radius := 88.0 * unit
	var ring_width := 40.0 * unit
	var ring_color: Color = RING_COLORS[clampi(player_ring_color, 0, RING_COLORS.size() - 1)]
	var hand_color: Color = HERO_HAND_COLORS[clampi(player_animal, 0, HERO_HAND_COLORS.size() - 1)]
	var podium_center := character_area.position + Vector2(character_area.size.x * 0.50, character_area.size.y * 0.94)
	draw_wood_podium(podium_center, unit, true)
	var integrated_hero: Texture2D = null
	if player_animal >= 0 and player_animal < lifebuoy_hero_textures.size():
		var hero_colors: Array = lifebuoy_hero_textures[player_animal]
		if player_ring_color >= 0 and player_ring_color < hero_colors.size():
			integrated_hero = hero_colors[player_ring_color] as Texture2D
	if integrated_hero != null:
		# This sprite contains the real pose: both arms reach the tube and both
		# hands curl over it. Every animal and ring color has a dedicated asset.
		draw_set_transform(animated_center, 0.0, Vector2.ONE * breathe)
		draw_texture_rect(integrated_hero, Rect2(-hero_size * 0.5, hero_size), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		# Back half of the buoy sits behind the torso.
		draw_set_transform(waist_center, 0.0, Vector2(1.0, 0.62))
		draw_arc(Vector2.ZERO, ring_radius, PI, TAU, 32, ring_color, ring_width, true)
		draw_arc(Vector2.ZERO, ring_radius, PI + 0.18, PI + 0.60, 10, Color("fff4dc"), ring_width, true)
		draw_arc(Vector2.ZERO, ring_radius, TAU - 0.60, TAU - 0.18, 10, Color("fff4dc"), ring_width, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if player_animal >= 0 and player_animal < full_body_animal_textures.size() and full_body_animal_textures[player_animal] != null:
			draw_set_transform(animated_center, 0.0, Vector2.ONE * breathe)
			draw_texture_rect(full_body_animal_textures[player_animal], Rect2(-hero_size * 0.5, hero_size), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Front half passes in front of the waist, making it clear the hero is inside the buoy.
		draw_set_transform(waist_center, 0.0, Vector2(1.0, 0.62))
		draw_arc(Vector2.ZERO, ring_radius, 0.0, PI, 32, ring_color, ring_width, true)
		draw_arc(Vector2.ZERO, ring_radius, 0.18, 0.60, 10, Color("fff4dc"), ring_width, true)
		draw_arc(Vector2.ZERO, ring_radius, PI - 0.60, PI - 0.18, 10, Color("fff4dc"), ring_width, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# Fallback grip marks for combinations that do not yet have a dedicated pose.
		for grip_side in [-1.0, 1.0]:
			var grip_center := waist_center + Vector2(grip_side * ring_radius * 0.72, -ring_radius * 0.18)
			draw_set_transform(grip_center, grip_side * 0.10, Vector2(0.82, 1.16))
			draw_circle(Vector2.ZERO, 20.0 * unit, Color("182431"))
			draw_circle(Vector2.ZERO, 15.5 * unit, hand_color)
			draw_arc(Vector2(0.0, 2.0 * unit), 8.0 * unit, 0.18, PI - 0.18, 12, hand_color.lightened(0.24), 2.4 * unit, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# The character itself remains tappable; the left CHARACTERS button is the
	# explicit entry point, so no label is allowed to cover the podium artwork.

	# Top HUD: player identity on the left, currencies and settings on the right.
	var settings := home_settings_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), settings.grow(4.0))
	draw_style_box(make_box(Color("486889"), 16.0), settings)
	draw_circle(settings.get_center(), 18.0 * unit, Color("d8f5ff"), false, 3.0 * unit, true)
	draw_string(ui_font, settings.position + Vector2(0.0, 35.0) * unit, "HE" if ui_language == "he" else "EN", HORIZONTAL_ALIGNMENT_CENTER, settings.size.x, int(14.0 * unit), Color.WHITE)
	var coin_rect := home_coin_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), coin_rect.grow(4.0))
	draw_style_box(make_box(Color("253e67"), 16.0), coin_rect)
	draw_circle(coin_rect.position + Vector2(29.0, 27.0) * unit, 15.0 * unit, Color("ffc83d"))
	draw_circle(coin_rect.position + Vector2(29.0, 27.0) * unit, 9.0 * unit, Color("e9971b"), false, 3.0 * unit, true)
	draw_string(ui_font, coin_rect.position + Vector2(54.0, 35.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 82.0 * unit, int(20.0 * unit), Color.WHITE)
	var gems := Rect2(viewport_size.x - 210.0 * unit, 22.0 * unit, 120.0 * unit, 54.0 * unit)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), gems.grow(4.0))
	draw_style_box(make_box(Color("253e67"), 16.0), gems)
	var gem_center := gems.position + Vector2(28.0, 27.0) * unit
	var gem_shape := PackedVector2Array([gem_center + Vector2(0.0, -15.0) * unit, gem_center + Vector2(14.0, -3.0) * unit, gem_center + Vector2(8.0, 14.0) * unit, gem_center + Vector2(-8.0, 14.0) * unit, gem_center + Vector2(-14.0, -3.0) * unit])
	draw_colored_polygon(gem_shape, Color("42e4ff"))
	draw_string(ui_font, gems.position + Vector2(52.0, 35.0) * unit, "0", HORIZONTAL_ALIGNMENT_LEFT, 52.0 * unit, int(20.0 * unit), Color.WHITE)
	var profile := home_profile_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 19.0), profile.grow(4.0))
	draw_style_box(make_box(Color("244d70"), 17.0), profile)
	draw_circle(profile.position + Vector2(31.0, 29.0) * unit, 24.0 * unit, RING_COLORS[player_ring_color])
	if team_piece_textures.size() > 0 and team_piece_textures[0] != null:
		draw_texture_rect(team_piece_textures[0], Rect2(profile.position + Vector2(9.0, 7.0) * unit, Vector2(44.0, 44.0) * unit), false)
	draw_string(ui_font, profile.position + Vector2(65.0, 27.0) * unit, ui_text("player"), HORIZONTAL_ALIGNMENT_LEFT, profile.size.x - 76.0 * unit, int(19.0 * unit), Color.WHITE)
	draw_string(ui_font, profile.position + Vector2(65.0, 47.0) * unit, ui_text("level"), HORIZONTAL_ALIGNMENT_LEFT, profile.size.x - 76.0 * unit, int(11.0 * unit), Color("8cecff"))

	# Brand title floats above the clear play area.
	draw_string(ui_font, Vector2(viewport_size.x - 390.0 * unit, 132.0 * unit), "ZOOPALOOLA", HORIZONTAL_ALIGNMENT_CENTER, 360.0 * unit, int(34.0 * unit), Color("ffe25d"))
	draw_string(ui_font, Vector2(viewport_size.x - 390.0 * unit, 161.0 * unit), ui_text("choose_mode"), HORIZONTAL_ALIGNMENT_CENTER, 360.0 * unit, int(16.0 * unit), Color.WHITE)

	# Three clearly separated modes: public online matchmaking, a private online
	# friend match on two devices, and the immediately playable computer mode.
	var small_titles := [ui_text("arena"), ui_text("friend")]
	var small_subtitles := [ui_text("arena_sub"), ui_text("friend_sub")]
	var small_colors := [Color("9d59e8"), Color("ff7b43")]
	for i in 2:
		var button := home_mode_rect(i, viewport_size)
		draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.84), 18.0), button.grow(5.0 * unit))
		draw_style_box(make_box(small_colors[i], 16.0), button)
		draw_circle(button.position + Vector2(38.0, 41.0) * unit, 24.0 * unit, Color(1.0, 1.0, 1.0, 0.20))
		draw_string(ui_font, button.position + Vector2(70.0, 36.0) * unit, small_titles[i], HORIZONTAL_ALIGNMENT_CENTER, button.size.x - 102.0 * unit, int(22.0 * unit), Color.WHITE)
		draw_string(ui_font, button.position + Vector2(70.0, 62.0) * unit, small_subtitles[i], HORIZONTAL_ALIGNMENT_CENTER, button.size.x - 102.0 * unit, int(11.0 * unit), Color("fff5d2"))
		draw_string(ui_font, button.position + Vector2(button.size.x - 34.0 * unit, 52.0 * unit), ">", HORIZONTAL_ALIGNMENT_CENTER, 24.0 * unit, int(24.0 * unit), Color.WHITE)

	var play_rect := home_mode_rect(2, viewport_size)
	var pulse := (sin(menu_elapsed * 3.0) + 1.0) * 0.5
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.88), 25.0), play_rect.grow((6.0 + pulse * 2.0) * unit))
	draw_style_box(make_box(Color("6fda18"), 22.0), play_rect)
	var play_center := play_rect.position + Vector2(58.0, 60.0) * unit
	draw_circle(play_center, 39.0 * unit, Color("4cb900"))
	var triangle := PackedVector2Array([
		play_center + Vector2(-10.0, -18.0) * unit,
		play_center + Vector2(-10.0, 18.0) * unit,
		play_center + Vector2(22.0, 0.0) * unit
	])
	draw_colored_polygon(triangle, Color.WHITE)
	draw_string(ui_font, play_rect.position + Vector2(104.0, 53.0) * unit, ui_text("computer"), HORIZONTAL_ALIGNMENT_CENTER, 220.0 * unit, int(25.0 * unit), Color.WHITE)
	draw_string(ui_font, play_rect.position + Vector2(104.0, 84.0) * unit, ui_text("computer_sub"), HORIZONTAL_ALIGNMENT_CENTER, 220.0 * unit, int(12.0 * unit), Color("eaffcf"))

	# Collection shortcuts stay close to the hero character.
	var nav_labels := [ui_text("characters"), ui_text("rings"), ui_text("shop"), ui_text("rewards")]
	var nav_subtitles := [ui_text("characters_sub"), ui_text("rings_sub"), ui_text("shop_sub"), ui_text("rewards_sub")]
	var nav_colors := [Color("2a9bd5"), Color("8e55df"), Color("ff9f24"), Color("e94f78")]
	for i in 4:
		var nav := home_nav_rect(i, viewport_size)
		draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.86), 17.0), nav.grow(4.0 * unit))
		draw_style_box(make_box(nav_colors[i], 15.0), nav)
		draw_string(ui_font, nav.position + Vector2(0.0, 34.0) * unit, nav_labels[i], HORIZONTAL_ALIGNMENT_CENTER, nav.size.x, int(19.0 * unit), Color.WHITE)
		draw_string(ui_font, nav.position + Vector2(0.0, 61.0) * unit, nav_subtitles[i], HORIZONTAL_ALIGNMENT_CENTER, nav.size.x, int(10.0 * unit), Color("fff0c7"))

func draw_wood_podium(center: Vector2, scale: float, show_side_steps: bool) -> void:
	if wood_podium_texture != null:
		var podium_size := Vector2(440.0, 210.0) * scale if show_side_steps else Vector2(340.0, 165.0) * scale
		# The usable standing surface is high in the source asset, so the image
		# extends mostly below the supplied center point.
		var podium_rect := Rect2(center - Vector2(podium_size.x * 0.5, podium_size.y * 0.37), podium_size)
		draw_texture_rect(wood_podium_texture, podium_rect, false)
		return
	# Minimal fallback used only if the podium asset did not import.
	var fallback := Rect2(center - Vector2(120.0, 30.0) * scale, Vector2(240.0, 70.0) * scale)
	draw_style_box(make_box(Color("9b582c"), 12.0 * scale), fallback)
	draw_circle(center, 21.0 * scale, Color("f7c943"))
	draw_string(ui_font, center + Vector2(-17.0, 8.0) * scale, "1", HORIZONTAL_ALIGNMENT_CENTER, 34.0 * scale, int(22.0 * scale), Color("744018"))

func draw_home_character(animal_index: int, center: Vector2, size: float, phase: float, outfit_color: Color) -> void:
	if animal_index < 0 or animal_index >= animal_textures.size() or animal_textures[animal_index] == null:
		return
	var bob := sin(menu_elapsed * 2.0 + phase) * 8.0
	var tilt := sin(menu_elapsed * 1.4 + phase) * 0.055
	var position := center + Vector2(0.0, bob)
	draw_circle(position + Vector2(0.0, size * 0.12), size * 0.46, Color(outfit_color, 0.30))
	draw_set_transform(position, tilt, Vector2.ONE)
	draw_texture_rect(animal_textures[animal_index], Rect2(Vector2.ONE * -size * 0.5, Vector2.ONE * size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_home_leaderboard(panel: Rect2) -> void:
	draw_style_box(make_box(Color(0.025, 0.075, 0.13, 0.92), 24.0), panel.grow(4.0))
	draw_style_box(make_box(Color("eaf8f1"), 21.0), panel)
	draw_string(ui_font, panel.position + Vector2(0.0, 36.0), "LEADERBOARD", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 20, Color("173249"))
	draw_string(ui_font, panel.position + Vector2(0.0, 57.0), "WEEKLY", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 11, Color("2982a6"))
	var names := ["WaveRider", "JungleJoe", "SplashCat", "RhinoKing", profile_name]
	var scores := [1280, 1140, 980, 820, 100]
	for i in 5:
		var row := Rect2(panel.position + Vector2(14.0, 72.0 + i * 55.0), Vector2(panel.size.x - 28.0, 46.0))
		var row_color := Color("ffe6a8") if i == 4 else Color(0.95, 0.99, 0.97, 0.96)
		draw_style_box(make_box(row_color, 13.0), row)
		draw_circle(row.position + Vector2(24.0, 23.0), 16.0, Color("ffc83d") if i < 3 else Color("77b8ca"))
		draw_string(ui_font, row.position + Vector2(8.0, 29.0), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, 32.0, 14, Color("173249"))
		draw_string(ui_font, row.position + Vector2(49.0, 22.0), names[i], HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 115.0, 13, Color("173249"))
		draw_string(ui_font, row.position + Vector2(49.0, 37.0), str(scores[i]) + " PTS", HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 115.0, 9, Color("527184"))
		draw_string(ui_font, row.position + Vector2(row.size.x - 66.0, 29.0), str(18 - i * 2) + " W", HORIZONTAL_ALIGNMENT_CENTER, 56.0, 12, Color("1c936b"))

func draw_frontend_header(viewport_size: Vector2, title: String, subtitle: String) -> void:
	var back := frontend_back_rect(viewport_size)
	draw_style_box(make_box(Color("1b314a"), 14.0), back)
	draw_string(ui_font, back.position + Vector2(0.0, 31.0), ui_text("back"), HORIZONTAL_ALIGNMENT_CENTER, back.size.x, 16, Color.WHITE)
	draw_string(ui_font, Vector2(0.0, 52.0), title, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 30, Color("f6d365"))
	draw_string(ui_font, Vector2(0.0, 78.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 14, Color(0.78, 0.91, 0.98))

func draw_profile_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_frontend_header(viewport_size, ui_text("choose_character"), ui_text("choose_character_sub"))
	# Bright aqua showroom inspired by the sea surrounding the Zoopaloola table.
	draw_rect(Rect2(0.0, 92.0 * unit, viewport_size.x, viewport_size.y - 92.0 * unit), Color(0.16, 0.72, 0.86, 0.20))
	var display := Rect2(72.0 * unit, 106.0 * unit, 470.0 * unit, 414.0 * unit)
	draw_style_box(make_box(Color(0.02, 0.10, 0.17, 0.78), 28.0 * unit), display.grow(5.0 * unit))
	draw_style_box(make_box(Color("4fcbd5"), 25.0 * unit), display)
	# A small wooden winner podium grounds the full-body hero.
	var podium_center := display.position + Vector2(display.size.x * 0.50, display.size.y * 0.83)
	draw_wood_podium(podium_center, unit * 0.72, false)
	var hero_size := Vector2(270.0, 350.0) * unit
	var hero_center := display.position + Vector2(display.size.x * 0.50, display.size.y * 0.405 + sin(menu_elapsed * 1.4) * 1.5 * unit)
	var hero_texture: Texture2D = null
	if player_animal < lifebuoy_hero_textures.size():
		var colors: Array = lifebuoy_hero_textures[player_animal]
		if player_ring_color < colors.size():
			hero_texture = colors[player_ring_color] as Texture2D
	if hero_texture != null:
		draw_texture_rect(hero_texture, Rect2(hero_center - hero_size * 0.5, hero_size), false)
	draw_string(ui_font, display.position + Vector2(0.0, display.size.y - 18.0 * unit), ui_animal_name(player_animal), HORIZONTAL_ALIGNMENT_CENTER, display.size.x, int(22.0 * unit), Color.WHITE)

	var info := Rect2(570.0 * unit, 118.0 * unit, 638.0 * unit, 326.0 * unit)
	draw_style_box(make_box(Color(0.025, 0.075, 0.14, 0.88), 24.0 * unit), info)
	draw_string(ui_font, info.position + Vector2(0.0, 47.0) * unit, ui_text("choose_ring"), HORIZONTAL_ALIGNMENT_CENTER, info.size.x, int(24.0 * unit), Color("ffe25d"))
	draw_string(ui_font, info.position + Vector2(0.0, 76.0) * unit, ui_text("choose_ring_sub"), HORIZONTAL_ALIGNMENT_CENTER, info.size.x, int(12.0 * unit), Color("d7f6ff"))
	for i in RING_COLOR_NAMES.size():
		var ring_button := character_ring_rect(i, viewport_size)
		var ring_selected := i == player_ring_color
		draw_style_box(make_box(Color("ffe25d") if ring_selected else Color("173a56"), 17.0 * unit), ring_button.grow((4.0 if ring_selected else 2.0) * unit))
		draw_style_box(make_box(Color("285b73") if ring_selected else Color("123047"), 14.0 * unit), ring_button)
		var ring_center := ring_button.position + Vector2(42.0, 39.0) * unit
		draw_circle(ring_center, 27.0 * unit, RING_COLORS[i])
		draw_circle(ring_center, 12.0 * unit, Color("14324c"))
		draw_arc(ring_center, 27.0 * unit, -0.70, 0.15, 10, Color("fff4dc"), 8.0 * unit, true)
		draw_arc(ring_center, 27.0 * unit, 2.45, 3.30, 10, Color("fff4dc"), 8.0 * unit, true)
		draw_string(ui_font, ring_button.position + Vector2(78.0, 47.0) * unit, ui_ring_name(i), HORIZONTAL_ALIGNMENT_CENTER, 86.0 * unit, int(12.0 * unit), Color.WHITE)
		if i == player_ring_color:
			draw_circle(ring_button.position + Vector2(ring_button.size.x - 14.0 * unit, 14.0 * unit), 13.0 * unit, Color("ffe25d"))
			draw_string(ui_font, ring_button.position + Vector2(ring_button.size.x - 27.0 * unit, 20.0 * unit), "✓", HORIZONTAL_ALIGNMENT_CENTER, 26.0 * unit, int(13.0 * unit), Color("173249"))

	draw_string(ui_font, Vector2(0.0, viewport_size.y - 194.0 * unit), ui_text("choose_animal"), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(16.0 * unit), Color.WHITE)
	for i in ANIMAL_NAMES.size():
		var card := character_card_rect(i, viewport_size)
		var selected_card := i == player_animal
		draw_style_box(make_box(Color("ffe25d") if selected_card else Color(0.02, 0.08, 0.14, 0.90), 19.0 * unit), card.grow((5.0 if selected_card else 3.0) * unit))
		draw_style_box(make_box(Color("35bfc8") if selected_card else Color("244b67"), 16.0 * unit), card)
		var portrait := full_body_animal_textures[i]
		if portrait != null:
			var portrait_rect := Rect2(card.position + Vector2(30.0, 2.0) * unit, Vector2(98.0, 116.0) * unit)
			draw_texture_rect(portrait, portrait_rect, false)
		draw_rect(Rect2(card.position + Vector2(0.0, 114.0) * unit, Vector2(card.size.x, 36.0 * unit)), Color(0.01, 0.05, 0.10, 0.80))
		draw_string(ui_font, card.position + Vector2(0.0, 139.0) * unit, ui_animal_name(i), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(12.0 * unit), Color.WHITE)
		if selected_card:
			draw_circle(card.position + Vector2(card.size.x - 15.0 * unit, 15.0 * unit), 14.0 * unit, Color("ffe25d"))
			draw_string(ui_font, card.position + Vector2(card.size.x - 29.0 * unit, 21.0 * unit), "✓", HORIZONTAL_ALIGNMENT_CENTER, 28.0 * unit, int(14.0 * unit), Color("173249"))

func draw_shop_screen(viewport_size: Vector2) -> void:
	draw_frontend_header(viewport_size, ui_text("shop_title"), ui_text("shop_title_sub"))
	var categories := [ui_text("characters"), ui_text("rings"), ui_text("effects")]
	var colors := [Color("24b889"), Color("467ce8"), Color("9a58dc")]
	for i in 3:
		var card := frontend_mode_rect(i, viewport_size)
		card.position.y = viewport_size.y * 0.28
		card.size.y = viewport_size.y * 0.50
		draw_style_box(make_box(Color(0.035, 0.075, 0.13, 0.97), 22.0), card)
		draw_circle(card.position + Vector2(card.size.x * 0.5, 82.0), 48.0, Color(colors[i], 0.30))
		draw_circle(card.position + Vector2(card.size.x * 0.5, 82.0), 32.0, colors[i], false, 8.0, true)
		draw_string(ui_font, card.position + Vector2(0.0, 160.0), categories[i], HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 22, Color.WHITE)
		draw_string(ui_font, card.position + Vector2(20.0, 198.0), ui_text("collection_info"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 40.0, 14, Color(0.74, 0.86, 0.94))
		var button := Rect2(card.position + Vector2(24.0, card.size.y - 62.0), Vector2(card.size.x - 48.0, 42.0))
		draw_style_box(make_box(colors[i], 13.0), button)
		draw_string(ui_font, button.position + Vector2(0.0, 27.0), ui_text("coming_soon"), HORIZONTAL_ALIGNMENT_CENTER, button.size.x, 14, Color.WHITE)

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box
