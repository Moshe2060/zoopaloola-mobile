extends Node2D

const BOARD_W := 207.0
const BOARD_H := 208.0
# Physics used a noticeably smaller circle than the visible animal ring, so
# balls and rails appeared to overlap before a hit was registered.
const RADIUS := 7.4
# Keep the approved artwork size unchanged while enlarging only its collision
# body. This value is the former 6.0 * 1.36 visual radius in board units.
const GAME_BALL_VISUAL_RADIUS := 8.16
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
const ANIMAL_NAMES := ["ELEPHANT", "ZEBRA", "MONKEY", "HIPPO", "RHINO", "GIRAFFE", "TIGER"]
const ANIMAL_FILES := ["elephant", "zebra", "monkey", "hippo", "rhino", "giraffe", "tiger"]
# The elephant artwork has about 8.6% transparent padding below its soles.
# Compensate when grounding the large hero so every animal meets the stage.
const HERO_GROUND_OFFSETS := [0.086, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
const RING_COLOR_NAMES := ["RED", "ORANGE", "BLUE", "GREEN", "PURPLE", "TURQUOISE", "PINK"]
const RING_COLORS := [
	Color("ef3340"), Color("ff8a00"), Color("1677ff"),
	Color("12c95b"), Color("8f36dc"), Color("08cbd1"), Color("f22888")
]
const HERO_HAND_COLORS := [
	Color("8799a2"), Color("343434"), Color("9b541f"),
	Color("e49aa2"), Color("777187"), Color("c88938"), Color("e28a42")
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
	"choose_animal": "בחרו חיה", "choose_board": "בחרו שולחן משחק", "choose_setup": "בחרו דמות, גלגל ושולחן", "restoring_session": "מחזירים את ההתחברות שלכם...", "red": "אדום", "orange": "כתום", "blue": "כחול", "green": "ירוק", "purple": "סגול", "turquoise": "טורקיז", "pink": "ורוד",
	"elephant": "פיל", "zebra": "זברה", "monkey": "קוף", "hippo": "היפופוטם", "rhino": "קרנף", "giraffe": "ג׳ירפה", "tiger": "טיגריס",
	"arena_title": "בחירת זירה", "arena_title_sub": "בחרו את מגרש המשחק לקרב האונליין",
	"sakura": "גן הסאקורה", "bamboo": "חורשת הבמבוק", "volcano": "מקדש הגעש",
	"entry_free": "כניסה: חינם", "entry": "דמי כניסה: ", "coins": " מטבעות", "prize": "פרס ניצחון: ", "selected": "נבחר", "find_match": "חיפוש יריב אונליין",
	"profile_title": "פרופיל שחקן", "profile_sub": "הדמות, הצבע האהוב וסטטיסטיקות הקריירה שלכם",
	"main_character": "הדמות הראשית", "choose_main": "בחרו דמות ראשית", "favorite_color": "צבע גלגל אהוב",
	"career": "סטטיסטיקות קריירה", "matches": "משחקים", "wins": "ניצחונות", "losses": "הפסדים", "win_rate": "אחוז הצלחה", "best_streak": "רצף שיא", "world_rank": "דירוג עולמי", "current_streak": "רצף ניצחונות נוכחי: ",
	"shop_title": "החנות של זופלולה", "shop_title_sub": "דמויות, גלגלים, אפקטים ושולחנות משחק", "effects": "אפקטים", "collection_info": "אוספים נדירים • עיצובים עונתיים • אנימציות מיוחדות", "coming_soon": "בקרוב",
	"boards": "שולחנות", "boards_sub": "עיצובי מגרש", "boards_section": "שולחנות משחק", "boards_section_sub": "בחרו את עיצוב המגרש לקרב הבא", "board_equipped": "מוגדר למשחק", "board_selected_toast": "שולחן חדש הוגדר!",
	"board_classic": "קלאסי", "board_ice": "קרח", "board_jungle": "ג'ונגל", "board_volcano": "לבה", "board_candy": "עולם הממתקים",
	"free_item": "חינם", "locked_item": "נעול", "buy_item": "קנה", "owned_item": "שלך", "equipped_item": "מצויד", "shop_collected": "%d/%d נאספו", "shop_open_category": "לחצו לפתיחה", "shop_effects_empty": "אפקטים מיוחדים יגיעו בקרוב לחנות", "purchase_success": "נרכש בהצלחה!", "unlock_in_shop": "ניתן לרכוש בחנות", "shop_unlocks_sub": "רכשו דמויות וגלגלים נוספים במטבעות", "host_board_only": "רק מארח החדר בוחר שולחן", "guest_board_locked": "שולחן המארח", "arena_board_fixed": "שולחן הזירה",
	"searching": "מחפשים יריב בזירה...", "cancel_search": "ביטול חיפוש",
	"match_win": "ניצחתם!", "match_lose": "הפסדתם", "draw": "תיקו",
	"play_again": "משחק נוסף", "back_home": "חזרה לבית",
	"you_won_coins": "הרווחתם ", "not_enough_coins": "אין מספיק מטבעות",
	"daily_title": "פרס יומי", "daily_sub": "חזרו כל יום לקבל מטבעות לגלגל ההצלה",
	"claim": "קבלו 80 מטבעות", "claimed": "הפרס של היום כבר נתקבל",
	"daily_claimed_toast": "קיבלתם 80 מטבעות!", "search_timeout": "החיפוש בוטל. נסו שוב.",
	"social_hub": "מועדון השחקנים", "friends_tab": "חברים", "chat_tab": "צ׳אט",
	"add_friend": "שליחת בקשה", "friend_id_hint": "ZP-XXXXXXXX",
	"invite_friend": "הזמנה", "no_friends": "עדיין אין חברים מאושרים",
	"friend_requests_title": "בקשות חברות", "friend_request_accept": "אישור",
	"friend_request_decline": "דחייה", "friend_request_sent": "בקשת חברות נשלחה!",
	"friend_request_pending": "ממתין לאישור", "friend_request_exists": "כבר שלחתם בקשה",
	"friend_request_incoming": "יש לכם בקשה מ-%s", "friend_accepted": "חבר חדש אושר!",
	"friend_invite_offline": "החבר לא מחובר כרגע",
	"lobby_chat_title": "צ׳אט הלובי", "lobby_chat_hint": "כתבו הודעה לקהילה...",
	"online_players": "שחקנים מחוברים", 	"friend_added": "חבר נוסף!", "friend_exists": "החבר כבר ברשימה",
	"friend_not_found": "מזהה לא תקין", "remove_friend": "הסרה", "your_turn_badge": "התור שלך", "extra_turn": "תור נוסף! הכניסו עוד כדור יריב",
	"friend_profile_title": "פרופיל חבר", "friend_online": "מחובר עכשיו", "friend_offline": "לא מחובר",
	"friend_added_you": "%s אישר/ה את בקשת החברות!", "friend_must_open": "בקשו מהחבר לפתוח את המשחק פעם אחת",
	"friend_view_profile": "צפייה בפרופיל", "friend_id_short": "ZP-XXXXXXXX",
	"league_tab": "ליגה", "leaderboard_title": "טבלת מובילים", "league_rookie": "מתחיל",
	"league_amateur": "חובבן", "league_pro": "מקצוען", "league_elite": "עילית", "league_legend": "אגדה",
	"rating_label": "דירוג", "invite_received": "הזמנה למשחק מ-", "join_invite": "הצטרפות",
	"invite_sent_online": "ההזמנה נשלחה!", "invite_sent_offline": "ההזמנה ממתינה לחבר",
	"room_chat": "צ׳אט חדר", "sound_on": "צלילים", "promoted_league": "עליתם לליגה חדשה!",
	"match_found": "נמצא יריב!", "entering_arena": "נכנסים לזירה...",
	"tutorial_title": "מדריך למתחילים", "tutorial_next": "הבא", "tutorial_prev": "הקודם",
	"tutorial_skip": "דלג", "tutorial_done": "בואו נשחק!", "tutorial_help": "מדריך",
	"difficulty": "רמת קושי", "difficulty_easy": "קל", "difficulty_medium": "בינוני", "difficulty_hard": "קשה",
	"ai_name_easy": "מחשב (קל)", "ai_name_medium": "מחשב (בינוני)", "ai_name_hard": "מחשב (קשה)",
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
	"choose_animal": "CHOOSE AN ANIMAL", "choose_board": "CHOOSE A GAME TABLE", "choose_setup": "Choose animal, ring and table", "restoring_session": "Restoring your sign-in...", "red": "RED", "orange": "ORANGE", "blue": "BLUE", "green": "GREEN", "purple": "PURPLE", "turquoise": "TURQUOISE", "pink": "PINK",
	"elephant": "ELEPHANT", "zebra": "ZEBRA", "monkey": "MONKEY", "hippo": "HIPPO", "rhino": "RHINO", "giraffe": "GIRAFFE", "tiger": "TIGER",
	"arena_title": "CHOOSE YOUR ARENA", "arena_title_sub": "Select the battleground for your online match",
	"sakura": "SAKURA GARDEN", "bamboo": "BAMBOO GROVE", "volcano": "VOLCANO TEMPLE",
	"entry_free": "ENTRY: FREE", "entry": "ENTRY: ", "coins": " COINS", "prize": "WIN PRIZE: ", "selected": "SELECTED", "find_match": "FIND ONLINE MATCH",
	"profile_title": "PLAYER PROFILE", "profile_sub": "Your character, favorite color and career statistics",
	"main_character": "MAIN CHARACTER", "choose_main": "CHOOSE YOUR MAIN ANIMAL", "favorite_color": "FAVORITE LIFEBUOY COLOR",
	"career": "CAREER STATISTICS", "matches": "MATCHES", "wins": "WINS", "losses": "LOSSES", "win_rate": "WIN RATE", "best_streak": "BEST STREAK", "world_rank": "WORLD RANK", "current_streak": "CURRENT WIN STREAK: ",
	"shop_title": "ZOOPA SHOP", "shop_title_sub": "Characters, lifebuoys, effects and game tables", "effects": "EFFECTS", "collection_info": "Rare collections • Seasonal designs • Special animations", "coming_soon": "COMING SOON",
	"boards": "TABLES", "boards_sub": "Board skins", "boards_section": "GAME TABLES", "boards_section_sub": "Choose the look of your next match", "board_equipped": "EQUIPPED", "board_selected_toast": "New table equipped!",
	"board_classic": "CLASSIC", "board_ice": "ICE", "board_jungle": "JUNGLE", "board_volcano": "LAVA", "board_candy": "CANDY WORLD",
	"free_item": "FREE", "locked_item": "LOCKED", "buy_item": "BUY", "owned_item": "OWNED", "equipped_item": "EQUIPPED", "shop_collected": "%d/%d COLLECTED", "shop_open_category": "TAP TO OPEN", "shop_effects_empty": "Special effects are coming soon to the shop", "purchase_success": "Purchased!", "unlock_in_shop": "Buy this in the shop", "shop_unlocks_sub": "Unlock more animals and lifebuoys with coins", "host_board_only": "Only the room host picks the table", "guest_board_locked": "Host's table", "arena_board_fixed": "Arena table",
	"searching": "Finding an arena opponent...", "cancel_search": "CANCEL SEARCH",
	"match_win": "YOU WIN!", "match_lose": "YOU LOST", "draw": "DRAW",
	"play_again": "PLAY AGAIN", "back_home": "BACK HOME",
	"you_won_coins": "You earned ", "not_enough_coins": "Not enough coins",
	"daily_title": "DAILY REWARD", "daily_sub": "Come back every day for lifebuoy coins",
	"claim": "CLAIM 80 COINS", "claimed": "ALREADY CLAIMED TODAY",
	"daily_claimed_toast": "You claimed 80 coins!", "search_timeout": "Search cancelled. Try again.",
	"social_hub": "PLAYER CLUB", "friends_tab": "FRIENDS", "chat_tab": "CHAT",
	"add_friend": "SEND REQUEST", "friend_id_hint": "ZP-XXXXXXXX",
	"invite_friend": "INVITE", "no_friends": "No approved friends yet",
	"friend_requests_title": "FRIEND REQUESTS", "friend_request_accept": "ACCEPT",
	"friend_request_decline": "DECLINE", "friend_request_sent": "Friend request sent!",
	"friend_request_pending": "Waiting for approval", "friend_request_exists": "Request already sent",
	"friend_request_incoming": "Request from %s", "friend_accepted": "New friend approved!",
	"friend_invite_offline": "Friend is offline right now",
	"lobby_chat_title": "LOBBY CHAT", "lobby_chat_hint": "Say hello to the community...",
	"online_players": "players online", "friend_added": "Friend added!", "friend_exists": "Friend already added",
	"friend_not_found": "Invalid player ID", "remove_friend": "REMOVE", "your_turn_badge": "YOUR TURN", "extra_turn": "EXTRA TURN! Pocket another enemy ball",
	"friend_profile_title": "FRIEND PROFILE", "friend_online": "Online now", "friend_offline": "Offline",
	"friend_added_you": "%s accepted your friend request!", "friend_must_open": "Ask your friend to open the game once",
	"friend_view_profile": "View profile", "friend_id_short": "ZP-XXXXXXXX",
	"league_tab": "LEAGUE", "leaderboard_title": "LEADERBOARD", "league_rookie": "ROOKIE",
	"league_amateur": "AMATEUR", "league_pro": "PRO", "league_elite": "ELITE", "league_legend": "LEGEND",
	"rating_label": "RATING", "invite_received": "Game invite from ", "join_invite": "JOIN",
	"invite_sent_online": "Invite sent!", "invite_sent_offline": "Invite queued for friend",
	"room_chat": "ROOM CHAT", "sound_on": "SOUND", "promoted_league": "You reached a new league!",
	"match_found": "MATCH FOUND!", "entering_arena": "ENTERING ARENA...",
	"tutorial_title": "HOW TO PLAY", "tutorial_next": "NEXT", "tutorial_prev": "BACK",
	"tutorial_skip": "SKIP", "tutorial_done": "LET'S PLAY!", "tutorial_help": "GUIDE",
	"difficulty": "DIFFICULTY", "difficulty_easy": "EASY", "difficulty_medium": "MEDIUM", "difficulty_hard": "HARD",
	"ai_name_easy": "CPU (EASY)", "ai_name_medium": "CPU (MEDIUM)", "ai_name_hard": "CPU (HARD)",
}
const APP_SPLASH := 0
const APP_HOME := 1
const APP_PROFILE := 2
const APP_SHOP := 3
const APP_GAME := 4
const APP_ARENA := 5
const APP_PLAYER_PROFILE := 6
const APP_FRIEND := 7
const APP_REWARDS := 8
const APP_AUTH := 9
const ARENA_BOARD_THEMES := [0, 2, 3]
const ARENA_ENTRY_COSTS := [0, 100, 500]
const ARENA_WIN_PRIZES := [100, 250, 1200]
const DAILY_REWARD_COINS := 80
const COMPUTER_WIN_COINS := 40
const FRIEND_WIN_COINS := 25
const FREE_UNLOCK_COUNT := 3
const SHOP_PAGE_HUB := "hub"
const SHOP_PAGE_ANIMALS := "animals"
const SHOP_PAGE_RINGS := "rings"
const SHOP_PAGE_EFFECTS := "effects"
const ECONOMY_VERSION := 2
const ANIMAL_UNLOCK_PRICES := [0, 0, 0, 550, 750, 950, 0]
const RING_UNLOCK_PRICES := [0, 0, 0, 350, 450, 550, 0]
const LEAGUE_RATING_THRESHOLDS := [0, 900, 1100, 1300, 1500, 1700]
const LEAGUE_NAME_KEYS := ["league_rookie", "league_amateur", "league_pro", "league_elite", "league_legend", "league_legend"]
const MATCH_SERVER_URL := "wss://zoopaloola-mobile.onrender.com/ws"
const ARENA_MATCH_FOUND_DURATION := 2.2
const FIREBASE_WEB_VAPID_KEY := ""
const TUTORIAL_STEP_COUNT := 8
const TUTORIAL_STEPS_HE := [
	{"title": "ברוכים הבאים לזופלולה!", "body": "משחק גולות חיות על לוח מיוחד עם חורים, נשקים ויריבים אמיתיים.\nעברו בין השלבים כדי ללמוד איך הכל עובד.", "art": "welcome"},
	{"title": "איך יורים?", "body": "בתור שלכם — געו בכדור שלכם, גררו אחורה ושחררו.\nככל שתמשכו רחוק יותר, הכדור יעוף חזק יותר.\nמשיכה קצרה מבטלת את הירייה.", "art": "shoot"},
	{"title": "מה המטרה?", "body": "דחפו את כדורי היריב לחורים בפינות הלוח.\nכדור שנכנס לחור יוצא מהמשחק — מי שמוריד את כל כדורי היריב קודם, מנצח!", "art": "goal"},
	{"title": "חורים מיוחדים", "body": "חלק מהחורים מפעילים נשקים: גומי, מקש, חשמל, אש, קרח ועוד.\nהם יוצרים רגעים מטורפים — נסו לתכנן סביבם!", "art": "weapons"},
	{"title": "תורות", "body": "כל שחקן יורה פעם אחת בתורו.\nאם הכנסתם כדור של היריב לחור — מקבלים תור נוסף!\nהתור עובר רק כשלא הצלחתם להכניס כדור יריב.", "art": "turns"},
	{"title": "מצבי משחק", "body": "שחק — משחק נגד המחשב (מומלץ להתחיל כאן).\nחבר — חדר פרטי עם קוד לשני מכשירים.\nזירה — משחק אונליין מול יריב אקראי עם דירוג ומטבעות.", "art": "modes"},
	{"title": "מסך הבית", "body": "פרופיל — שם, דמות וסטטיסטיקות.\nמועדון שחקנים — חברים, צ׳אט לובי וליגה.\nפרס יומי — מטבעות חינם כל יום.\nהעתיקו את מזהה ZP- שלכם כדי להוסיף חברים.", "art": "hub"},
	{"title": "מוכנים לשחק!", "body": "התחילו במשחק נגד המחשב כדי להתרגל.\nאפשר לפתוח את המדריך שוב בכל עת מכפתור ? בפינה.\nבהצלחה בזירה!", "art": "ready"},
]
const TUTORIAL_STEPS_EN := [
	{"title": "WELCOME TO ZOOPALOOLA!", "body": "A lively marble game on a special board with holes, weapons, and real opponents.\nSwipe through these steps to learn how everything works.", "art": "welcome"},
	{"title": "HOW TO SHOOT", "body": "On your turn, touch your ball, pull back, and release.\nThe farther you pull, the harder the shot.\nA tiny pull cancels the shot.", "art": "shoot"},
	{"title": "THE GOAL", "body": "Knock your opponent's balls into the corner holes.\nA ball that falls in is out — clear all enemy balls first to win!", "art": "goal"},
	{"title": "SPECIAL HOLES", "body": "Some holes trigger weapons: rubber, press, electric, fire, ice, and more.\nThey create wild moments — plan around them!", "art": "weapons"},
	{"title": "TURNS", "body": "Each player shoots once per turn.\nPocket an enemy ball and you shoot again!\nYour turn ends only when you fail to pocket an enemy ball.", "art": "turns"},
	{"title": "GAME MODES", "body": "PLAY — vs computer (best place to start).\nFRIEND — private room with a 4-letter code.\nARENA — online random match with rating and coins.", "art": "modes"},
	{"title": "HOME SCREEN", "body": "Profile — name, character, and stats.\nPlayer Club — friends, lobby chat, and league.\nDaily reward — free coins every day.\nCopy your ZP- ID to add friends.", "art": "hub"},
	{"title": "READY TO PLAY!", "body": "Start with a computer match to practice.\nReopen this guide anytime with the ? button.\nGood luck in the arena!", "art": "ready"},
]
var board_texture: Texture2D
var board_theme_textures: Array[Texture2D] = []
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
var app_screen := APP_AUTH
var splash_elapsed := 0.0
var menu_elapsed := 0.0
var game_mode := "computer"
var profile_name := "PLAYER 1"
var player_coins := 0
var owned_animals: Array = []
var owned_rings: Array = []
var shop_page := SHOP_PAGE_HUB
var selected_arena := 0
const BOARD_THEME_COUNT := 5
var selected_board_theme := 0
var match_board_theme := 0
var room_board_theme := 0
var ui_language := "he"
var player_level := 1
var player_xp := 0
var player_next_level_xp := 500
var player_wins := 0
var player_losses := 0
var player_best_streak := 0
var player_current_streak := 0
var player_world_rank := 0
var player_rating := 1000
var player_league_tier := 0
var global_leaderboard: Array = []
var pending_friend_invite: Dictionary = {}
var pending_friend_invite_send: Dictionary = {}
var pending_friend_invite_target_name := ""
var friend_room_chat_open := false
var home_ambient_particles: Array = []
var sound_enabled := true
var sfx_player: AudioStreamPlayer
var last_daily_claim := ""
var menu_notice := ""
var menu_notice_time := 0.0
var multiplayer_socket := WebSocketPeer.new()
var multiplayer_state := "disconnected"
var multiplayer_room_code := ""
var multiplayer_slot := -1
var multiplayer_players: Array = []
var multiplayer_ready := false
var multiplayer_error := ""
var pending_shared_room_code := ""
var pending_android_auth_handoff := ""
var pending_auth_handoff_payload: Dictionary = {}
var pending_google_handoff_request := false
var multiplayer_local_animal := -1
var multiplayer_local_ring_color := -1
var friend_customizer_open := false
var friend_opponent_profile_open := false
var room_code_input: LineEdit
var chat_input: LineEdit
var profile_name_input: LineEdit
var auth_email_input: LineEdit
var auth_password_input: LineEdit
var auth_email_mode := ""
var firebase_auth_mode := ""
var exit_confirm_open := false
var chat_open := false
var match_chat_messages: Array = []
var matchmaking_searching := false
var pending_find_match := false
var match_source := "computer"
var arena_fx_phase := "idle"
var arena_fx_elapsed := 0.0
var pending_arena_match: Dictionary = {}
var arena_matched_opponent: Dictionary = {}
var fcm_token_registered := ""
var push_setup_done := false
var tutorial_completed := false
var tutorial_open := false
var tutorial_step := 0
var tutorial_dismissed_session := false
var match_finished := false
var match_result_open := false
var match_result_winner := -1
var match_result_coins := 0
var match_result_recorded := false
var turn_shot_committed := false
var turn_pending_resolve := false
var turn_opponent_scored := false
var friends_list: Array = []
var incoming_friend_requests: Array = []
var outgoing_friend_requests: Array = []
var home_social_tab := 0
var home_friend_profile_index := -1
var lobby_chat_messages: Array = []
var friend_id_input: LineEdit
var lobby_chat_input: LineEdit
var friend_lookup_request: HTTPRequest
var pending_friend_lookup_id := ""

func init_home_ambient_particles() -> void:
	if not home_ambient_particles.is_empty():
		return
	for i in 28:
		home_ambient_particles.append({
			"x": randf(),
			"y": randf(),
			"speed": randf_range(0.04, 0.14),
			"size": randf_range(3.0, 11.0),
			"phase": randf() * TAU,
			"kind": i % 3
		})

func make_tone_stream(freq: float, duration: float, volume: float = 0.22) -> AudioStreamWAV:
	var sample_rate := 22050
	var frames := maxi(1, int(sample_rate * duration))
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / float(sample_rate)
		var envelope := 1.0 - float(i) / float(frames)
		var sample := sin(TAU * freq * t) * volume * envelope
		var s16 := int(clampf(sample * 32767.0, -32768.0, 32767.0))
		data[i * 2] = s16 & 0xFF
		data[i * 2 + 1] = (s16 >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func setup_sound() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)

func play_sound(kind: String) -> void:
	if not sound_enabled or sfx_player == null:
		return
	var stream: AudioStreamWAV = null
	match kind:
		"ui":
			stream = make_tone_stream(660.0, 0.06, 0.16)
		"shot":
			stream = make_tone_stream(240.0, 0.10, 0.20)
		"score":
			stream = make_tone_stream(880.0, 0.14, 0.18)
		"invite":
			stream = make_tone_stream(520.0, 0.18, 0.20)
		"win":
			stream = make_tone_stream(740.0, 0.22, 0.22)
		_:
			stream = make_tone_stream(440.0, 0.08, 0.14)
	sfx_player.stream = stream
	sfx_player.play()

func league_tier_for_rating(rating: int) -> int:
	var tier := 0
	for i in LEAGUE_RATING_THRESHOLDS.size():
		if rating >= LEAGUE_RATING_THRESHOLDS[i]:
			tier = i
	return clampi(tier, 0, LEAGUE_NAME_KEYS.size() - 1)

func league_name(tier: int) -> String:
	return ui_text(LEAGUE_NAME_KEYS[clampi(tier, 0, LEAGUE_NAME_KEYS.size() - 1)])

func league_color(tier: int) -> Color:
	var colors := [Color("8cecff"), Color("51d995"), Color("ffe25d"), Color("ff9f24"), Color("e94f78"), Color("c77dff")]
	return colors[clampi(tier, 0, colors.size() - 1)]

func update_player_league_tier() -> void:
	player_league_tier = league_tier_for_rating(player_rating)

func apply_rating_change(did_win: bool, opponent_rating: int = 1000) -> void:
	var expected := 1.0 / (1.0 + pow(10.0, float(opponent_rating - player_rating) / 400.0))
	var score := 1.0 if did_win else 0.0
	var k := 28.0 if player_rating < 1200 else 22.0
	var old_tier := player_league_tier
	player_rating = clampi(int(round(float(player_rating) + k * (score - expected))), 100, 9999)
	update_player_league_tier()
	if player_league_tier > old_tier:
		show_menu_notice(ui_text("promoted_league") + " " + league_name(player_league_tier))
		play_sound("win")

func sync_player_presence() -> void:
	if multiplayer_state != "connected" or firebase_public_id.is_empty():
		return
	send_multiplayer({
		"type": "register_presence",
		"publicId": firebase_public_id,
		"name": profile_name,
		"rating": player_rating,
		"wins": player_wins,
		"losses": player_losses,
		"leagueTier": player_league_tier
	})
	send_multiplayer({"type": "get_leaderboard"})
	register_fcm_token_with_server()

func setup_push_notifications_web() -> void:
	if not OS.has_feature("web") or push_setup_done:
		return
	push_setup_done = true
	var vapid := FIREBASE_WEB_VAPID_KEY
	var script := """
window.zpPushState = {status: 'loading'};
window.zpShowNotification = (title, body, data) => {
  if (!('Notification' in window) || Notification.permission !== 'granted') return;
  try {
    const note = new Notification(title, {
      body: body,
      icon: './zoopaloola-boot-splash-v2.png',
      badge: './zoopaloola-boot-splash-v2.png',
      data: data || {}
    });
    note.onclick = () => {
      if (data && data.roomCode) {
        const url = new URL(window.location.href);
        url.searchParams.set('room', data.roomCode);
        window.location.href = url.toString();
      }
      window.focus();
      note.close();
    };
  } catch (error) {}
};
(async () => {
  try {
    if (!('Notification' in window)) {
      window.zpPushState = {status: 'unsupported'};
      return;
    }
    const permission = await Notification.requestPermission();
    window.zpPushState = {status: permission};
    const vapidKey = '__VAPID__';
    if (!vapidKey || !('serviceWorker' in navigator)) return;
    const registration = await navigator.serviceWorker.register('./firebase-messaging-sw.js');
    const appSdk = await import('https://www.gstatic.com/firebasejs/12.17.1/firebase-app.js');
    const messagingSdk = await import('https://www.gstatic.com/firebasejs/12.17.1/firebase-messaging.js');
    const config = {
      apiKey: '__API_KEY__', authDomain: 'zoopaloola-online.firebaseapp.com',
      projectId: 'zoopaloola-online', storageBucket: 'zoopaloola-online.firebasestorage.app',
      messagingSenderId: '386401966312', appId: '1:386401966312:web:0e781cb13c98fd6dc3515d'
    };
    const app = appSdk.getApps().length ? appSdk.getApps()[0] : appSdk.initializeApp(config);
    const messaging = messagingSdk.getMessaging(app);
    const token = await messagingSdk.getToken(messaging, {vapidKey, serviceWorkerRegistration: registration});
    if (token) {
      window.zpFcmToken = token;
      window.zpPushState.fcmToken = token;
    }
  } catch (error) {
    window.zpPushState = {status: 'error', message: String(error && error.message || error)};
  }
})();
""".replace("__API_KEY__", FIREBASE_API_KEY).replace("__VAPID__", vapid)
	JavaScriptBridge.eval(script, true)

func register_fcm_token_with_server() -> void:
	if not OS.has_feature("web") or firebase_public_id.is_empty() or multiplayer_state != "connected":
		return
	var token := str(JavaScriptBridge.eval("window.zpFcmToken || ''", true)).strip_edges()
	if token.is_empty() or token == fcm_token_registered:
		return
	send_multiplayer({
		"type": "register_fcm_token",
		"publicId": firebase_public_id,
		"token": token,
		"platform": "web"
	})
	fcm_token_registered = token

func show_web_notification(title: String, body: String, data: Dictionary = {}) -> void:
	if not OS.has_feature("web"):
		return
	var payload := JSON.stringify(data)
	JavaScriptBridge.eval(
		"window.zpShowNotification && window.zpShowNotification(%s, %s, %s)" % [
			JSON.stringify(title), JSON.stringify(body), payload
		],
		true
	)

func arena_opponent_data() -> Dictionary:
	var opponent_slot := 1 - multiplayer_slot if multiplayer_slot >= 0 else 1
	if opponent_slot >= 0 and opponent_slot < multiplayer_players.size():
		return multiplayer_players[opponent_slot]
	return {}

func begin_arena_match_found(payload: Dictionary) -> void:
	pending_arena_match = payload.duplicate()
	multiplayer_slot = int(payload.get("slot", multiplayer_slot))
	turn = int(payload.get("turn", 0))
	match_source = "arena"
	matchmaking_searching = false
	pending_find_match = false
	arena_fx_phase = "found"
	arena_fx_elapsed = 0.0
	arena_matched_opponent = arena_opponent_data()
	play_sound("invite")
	queue_redraw()

func apply_match_started(payload: Dictionary) -> void:
	multiplayer_slot = int(payload.get("slot", multiplayer_slot))
	turn = int(payload.get("turn", 0))
	game_mode = "online"
	match_source = str(payload.get("source", "friend"))
	if match_source == "arena":
		var entry: int = int(ARENA_ENTRY_COSTS[clampi(int(payload.get("arena", selected_arena)), 0, ARENA_ENTRY_COSTS.size() - 1)])
		player_coins = maxi(0, player_coins - entry)
		save_player_profile()
	matchmaking_searching = false
	pending_find_match = false
	arena_fx_phase = "idle"
	arena_fx_elapsed = 0.0
	pending_arena_match = {}
	arena_matched_opponent = {}
	app_screen = APP_GAME
	exit_confirm_open = false
	chat_open = false
	match_chat_messages.clear()
	if payload.has("boardTheme"):
		sync_match_board_from_payload(payload)
	elif match_source == "arena":
		sync_match_board_from_payload({"boardTheme": arena_board_theme_for_level(int(payload.get("arena", selected_arena)))})
	new_game()
	turn = int(payload.get("turn", 0))
	turn_shot_committed = false
	turn_pending_resolve = false
	turn_opponent_scored = false

func update_arena_fx(delta: float) -> void:
	if arena_fx_phase == "idle":
		return
	arena_fx_elapsed += delta
	if arena_fx_phase == "found" and arena_fx_elapsed >= ARENA_MATCH_FOUND_DURATION and not pending_arena_match.is_empty():
		apply_match_started(pending_arena_match)

func multiplayer_payload_stats() -> Dictionary:
	return {
		"rating": player_rating,
		"leagueTier": player_league_tier,
		"publicId": firebase_public_id
	}

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
var ai_committed_shot := false
var computer_difficulty := 1
var customizer_open := false
# Start with the combination requested during the visual review: zebra + green.
var player_animal := 1
var player_ring_color := 3
var ai_animal := 0
var ai_ring_color := 0
const PLAYER_PROFILE_PATH := "user://zoopaloola-profile.cfg"
const FIREBASE_API_KEY := "AIzaSyCIcTUM65KhCem-mG8H23oNnrM3K-jDSHQ"
const FIREBASE_PROJECT_ID := "zoopaloola-online"
var firebase_uid := ""
var firebase_public_id := ""
var firebase_id_token := ""
var firebase_refresh_token := ""
var firebase_token_expires_at := 0
var firebase_provider := "guest"
var firebase_email := ""
var firebase_auth_request: HTTPRequest
var firebase_profile_request: HTTPRequest
var firebase_public_id_request: HTTPRequest
var firebase_auth_busy := false
var firebase_profile_dirty := false
var firebase_sync_delay := 0.0
var firebase_web_poll_delay := 0.0
var firebase_status := "מתחבר..."
var session_restore_pending := false
var session_restore_deadline := 0.0
const SESSION_RESTORE_WAIT_SEC := 3.5
const CLIENT_VERSION := "ACCOUNT-6"

func _enter_tree() -> void:
	# Enter native fullscreen before _ready() and before the first game frame.
	# Android's immersive export flag normally hides the navigation bar, but
	# several Samsung devices reveal it again while the activity is starting.
	if OS.has_feature("android"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_system_back()
		return
	# Android may restore its system bars after the app loses focus (for example
	# after opening the recent-apps view). Re-apply fullscreen as soon as the game
	# becomes active instead of waiting until a match starts.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and OS.has_feature("android"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _ready() -> void:
	# Android's system Back button is application navigation. Disable SceneTree's
	# default immediate quit so each screen can decide what "back" means.
	get_tree().quit_on_go_back = false
	# Smooth the original character art when it is enlarged inside HD balls.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Bundled font includes Hebrew and Latin glyphs, so Web/Android render the
	# same readable interface without depending on fonts installed on the device.
	ui_font = load("res://assets/ui/fonts/DejaVuSans-Bold.ttf") as Font
	if ui_font == null:
		ui_font = ThemeDB.fallback_font
	load_player_profile()
	setup_firebase()
	setup_sound()
	if OS.has_feature("web"):
		setup_push_notifications_web()
	init_home_ambient_particles()
	update_player_league_tier()
	room_code_input = LineEdit.new()
	room_code_input.visible = false
	room_code_input.max_length = 4
	room_code_input.placeholder_text = "ABCD"
	room_code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_code_input.add_theme_font_override("font", ui_font)
	room_code_input.add_theme_font_size_override("font_size", 25)
	room_code_input.text_changed.connect(_on_room_code_changed)
	add_child(room_code_input)
	chat_input = LineEdit.new()
	chat_input.visible = false
	chat_input.max_length = 80
	chat_input.placeholder_text = "כתבו הודעה..." if ui_language == "he" else "Type a message..."
	chat_input.add_theme_font_override("font", ui_font)
	chat_input.add_theme_font_size_override("font_size", 20)
	chat_input.text_submitted.connect(_on_chat_submitted)
	add_child(chat_input)
	profile_name_input = LineEdit.new()
	profile_name_input.visible = false
	profile_name_input.max_length = 20
	profile_name_input.text = profile_name
	profile_name_input.placeholder_text = "השם שלכם" if ui_language == "he" else "Your name"
	profile_name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile_name_input.add_theme_font_override("font", ui_font)
	profile_name_input.add_theme_font_size_override("font_size", 21)
	profile_name_input.text_changed.connect(_on_profile_name_changed)
	profile_name_input.text_submitted.connect(_on_profile_name_submitted)
	profile_name_input.focus_exited.connect(commit_profile_name)
	add_child(profile_name_input)
	auth_email_input = LineEdit.new()
	auth_email_input.visible = false
	auth_email_input.placeholder_text = "example@gmail.com"
	auth_email_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	auth_email_input.add_theme_font_override("font", ui_font)
	auth_email_input.add_theme_font_size_override("font_size", 22)
	add_child(auth_email_input)
	auth_password_input = LineEdit.new()
	auth_password_input.visible = false
	auth_password_input.placeholder_text = "סיסמה (לפחות 6 תווים)" if ui_language == "he" else "Password (at least 6 characters)"
	auth_password_input.secret = true
	auth_password_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	auth_password_input.add_theme_font_override("font", ui_font)
	auth_password_input.add_theme_font_size_override("font_size", 22)
	auth_password_input.text_submitted.connect(_on_auth_password_submitted)
	add_child(auth_password_input)
	friend_id_input = LineEdit.new()
	friend_id_input.visible = false
	friend_id_input.max_length = 12
	friend_id_input.placeholder_text = "ZP-XXXXXXXX"
	friend_id_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	friend_id_input.add_theme_font_override("font", ui_font)
	friend_id_input.add_theme_font_size_override("font_size", 18)
	add_child(friend_id_input)
	lobby_chat_input = LineEdit.new()
	lobby_chat_input.visible = false
	lobby_chat_input.max_length = 80
	lobby_chat_input.placeholder_text = ui_text("lobby_chat_hint")
	lobby_chat_input.add_theme_font_override("font", ui_font)
	lobby_chat_input.add_theme_font_size_override("font_size", 18)
	lobby_chat_input.text_submitted.connect(_on_lobby_chat_submitted)
	add_child(lobby_chat_input)
	friend_lookup_request = HTTPRequest.new()
	friend_lookup_request.request_completed.connect(_on_friend_lookup_completed)
	add_child(friend_lookup_request)
	board_texture = load("res://assets/board-clean-modular.webp") as Texture2D
	board_theme_textures = [
		board_texture,
		load("res://assets/boards/board-ice.webp") as Texture2D,
		load("res://assets/boards/board-jungle.webp") as Texture2D,
		load("res://assets/boards/board-lava.webp") as Texture2D,
		load("res://assets/boards/board-candy.webp") as Texture2D,
	]
	lobby_background_texture = load("res://assets/ui/zoopaloola-home-bg-v3.webp") as Texture2D
	loading_team_texture = load("res://assets/ui/zoopaloola-loading-team-v1.webp") as Texture2D
	zoopaloola_logo_texture = load("res://assets/ui/zoopaloola-logo-v1.webp") as Texture2D
	wood_podium_texture = load("res://assets/ui/full_body/lifebuoy/wood-podium-v1.png") as Texture2D
	if board_texture == null:
		push_error("Clean original board could not be loaded.")
	for theme_index in board_theme_textures.size():
		if board_theme_textures[theme_index] == null:
			push_error("Board theme %d could not be loaded." % theme_index)
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
	initialize_saved_session()

func _on_resize() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	# Leave a clearly visible ocean frame around the floating board. The HUD is
	# drawn over the ocean, so the board begins below it instead of hiding under
	# the bar. All gameplay coordinates still use board_rect and stay aligned.
	# Slightly larger than the first ocean layout while retaining a visible water
	# frame on every side of the floating table.
	var side_margin := maxf(8.0, viewport_size.x * 0.008)
	# Grow the entire table uniformly by using more vertical space. Keeping the
	# source aspect ratio avoids stretching the stones or center circle.
	# Balanced framing: enough clear water for the centered turn notice above,
	# a slim visible water line below, and a large prominent board in between.
	var top_margin := 38.0
	var bottom_margin := 26.0
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
	if game_mode != "online":
		match_board_theme = selected_board_theme
	balls.clear()
	active_effects.clear()
	water_floaters.clear()
	contacts.clear()
	turn = 0
	ai_pending = false
	ai_committed_shot = false
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
	match_finished = false
	match_result_open = false
	match_result_winner = -1
	match_result_coins = 0
	match_result_recorded = false
	turn_shot_committed = false
	turn_pending_resolve = false
	turn_opponent_scored = false
	status = "Your turn - touch a red ball, pull back and release"
	queue_redraw()

func _process(delta: float) -> void:
	menu_elapsed += delta
	update_firebase(delta)
	poll_multiplayer()
	update_room_code_input()
	update_chat_input()
	update_profile_name_input()
	update_auth_inputs()
	update_home_social_inputs()
	if app_screen == APP_SPLASH:
		splash_elapsed += delta
		if splash_elapsed >= 3.2:
			app_screen = APP_AUTH
		queue_redraw()
		return
	if app_screen != APP_GAME:
		ensure_home_connected()
		update_arena_fx(delta)
		if app_screen == APP_HOME:
			maybe_start_tutorial()
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
	if ai_pending and not match_finished and effects_allow_next_turn() and not any_ball_moving():
		ai_timer -= delta
		if ai_timer <= 0.0:
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
	if game_mode == "computer" and turn == 1 and not match_finished and not ai_pending and ai_committed_shot and not any_ball_moving() and effects_allow_next_turn():
		resolve_pending_turn()
	elif not match_finished and turn_pending_resolve and not any_ball_moving() and effects_allow_next_turn():
		resolve_pending_turn()

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
	if scored_team != turn:
		turn_opponent_scored = true
	balls[index].alive = false
	balls[index].v = Vector2.ZERO
	active_effects.append({"hole":hole, "elapsed":0.0, "team":scored_team, "piece":index})
	status = "Ball scored!"
	play_sound("score")
	check_match_end()

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

func handle_system_back() -> void:
	# Close the innermost game overlay before navigating away from the match.
	if app_screen == APP_GAME:
		if match_result_open:
			exit_current_match()
		elif customizer_open:
			customizer_open = false
		elif chat_open:
			chat_open = false
			if chat_input != null:
				chat_input.release_focus()
		elif exit_confirm_open:
			exit_confirm_open = false
		else:
			# Match back never quits immediately; it uses the same confirmation
			# dialog as the on-screen arrow.
			exit_confirm_open = true
			selected = -1
			dragging = false
		queue_redraw()
		return

	# The email/password form is a child step of the authentication screen.
	if app_screen == APP_AUTH and not auth_email_mode.is_empty():
		auth_email_mode = ""
		firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
		if auth_email_input != null:
			auth_email_input.release_focus()
		if auth_password_input != null:
			auth_password_input.release_focus()
		update_auth_inputs()
		queue_redraw()
		return

	# Every secondary menu returns to the home screen and performs the same
	# cleanup as its visible Back button.
	if app_screen not in [APP_HOME, APP_AUTH, APP_SPLASH]:
		if app_screen == APP_PLAYER_PROFILE:
			commit_profile_name()
		if app_screen == APP_FRIEND:
			leave_multiplayer_room()
		if app_screen == APP_ARENA:
			cancel_matchmaking()
		app_screen = APP_HOME
		update_room_code_input()
		update_profile_name_input()
		queue_redraw()
		return

	if app_screen == APP_SPLASH:
		app_screen = APP_AUTH
		queue_redraw()
		return

	# Home and the root authentication chooser are the only true app roots.
	if tutorial_open:
		if tutorial_step > 0:
			retreat_tutorial_step()
		else:
			tutorial_open = false
			tutorial_dismissed_session = true
		queue_redraw()
		return

	# Back from either root keeps Android's expected behavior and exits.
	get_tree().quit()

func _input(event: InputEvent) -> void:
	# Mobile browsers only allow fullscreen and orientation locking after a real
	# user gesture. The first tap requests both, so Android can rotate the game
	# automatically without asking the player to rotate the phone manually.
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		request_landscape_mode()
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

func request_landscape_mode() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("""
		(async () => {
			try {
				const root = document.documentElement;
				if (!document.fullscreenElement && root.requestFullscreen) {
					try {
						await root.requestFullscreen({ navigationUI: 'hide' });
					} catch (_) {
						await root.requestFullscreen();
					}
				}
			} catch (_) {}
			try {
				if (screen.orientation && screen.orientation.lock) await screen.orientation.lock('landscape');
			} catch (_) {}
		})();
	""", true)

func pointer_down(screen_pos: Vector2) -> void:
	if app_screen != APP_GAME:
		handle_frontend_touch(screen_pos)
		return
	var viewport_size := get_viewport_rect().size
	if match_result_open:
		if match_result_home_rect(viewport_size).has_point(screen_pos):
			exit_current_match()
		elif game_mode == "computer" and match_result_again_rect(viewport_size).has_point(screen_pos):
			start_computer_setup()
		return
	if customizer_open:
		handle_customizer_touch(screen_pos)
		return
	if exit_confirm_open:
		if exit_confirm_yes_rect(viewport_size).has_point(screen_pos):
			exit_current_match()
		elif exit_confirm_no_rect(viewport_size).has_point(screen_pos):
			exit_confirm_open = false
			queue_redraw()
		return
	if chat_open:
		if chat_close_rect(viewport_size).has_point(screen_pos):
			chat_open = false
			chat_input.release_focus()
		elif chat_send_rect(viewport_size).has_point(screen_pos):
			send_chat_message()
		queue_redraw()
		return
	if game_back_rect().has_point(screen_pos):
		exit_confirm_open = true
		selected = -1
		dragging = false
		queue_redraw()
		return
	if game_mode == "online" and game_chat_rect(viewport_size).has_point(screen_pos):
		chat_open = true
		chat_input.grab_focus()
		queue_redraw()
		return
	if match_finished or (game_mode == "computer" and turn != 0) or (game_mode == "online" and turn != multiplayer_slot) or any_ball_moving() or not effects_allow_next_turn(): return
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
		turn_shot_committed = true
		turn_pending_resolve = true
		turn_opponent_scored = false
		play_sound("shot")
		if game_mode == "online":
			send_multiplayer({"type":"shot", "ballIndex":selected, "pullX":pull.x, "pullY":pull.y, "strength":strength})
			status = "שולח את הזריקה..." if ui_language == "he" else "Sending shot..."
		elif game_mode == "computer":
			balls[selected].v = pull.normalized() * (strength * 0.078)
			ai_committed_shot = false
			status = "מחכים לתוצאת הזריקה..." if ui_language == "he" else "Waiting for the shot to settle..."
		else:
			balls[selected].v = pull.normalized() * (strength * 0.078)
			ai_pending = false
			status = "מחכים לתוצאת הזריקה..." if ui_language == "he" else "Waiting for the shot to settle..."
	else:
		status = "Aim cancelled - choose another ball"
	dragging = false
	selected = -1

func ai_difficulty_settings() -> Dictionary:
	match clampi(computer_difficulty, 0, 2):
		0:
			return {"angle_error": 0.32, "power_error": 0.24, "pick_top": 0.42, "think_min": 0.55, "think_max": 1.25, "rating_bonus": -140, "min_align": 0.05}
		2:
			return {"angle_error": 0.035, "power_error": 0.05, "pick_top": 0.96, "think_min": 0.22, "think_max": 0.62, "rating_bonus": 160, "min_align": 0.22}
	return {"angle_error": 0.11, "power_error": 0.11, "pick_top": 0.74, "think_min": 0.34, "think_max": 0.88, "rating_bonus": 0, "min_align": 0.12}

func ai_think_delay() -> float:
	var settings := ai_difficulty_settings()
	return randf_range(float(settings.think_min), float(settings.think_max))

func ai_opponent_rating() -> int:
	return clampi(940 + player_level * 8 + int(ai_difficulty_settings().rating_bonus), 700, 1800)

func ai_display_name() -> String:
	match clampi(computer_difficulty, 0, 2):
		0: return ui_text("ai_name_easy")
		2: return ui_text("ai_name_hard")
	return ui_text("ai_name_medium")

func ai_collect_shot_candidates(settings: Dictionary) -> Array:
	var candidates: Array = []
	var min_align: float = float(settings.min_align)
	for shooter_index in balls.size():
		var shooter: Dictionary = balls[shooter_index]
		if not shooter.alive or int(shooter.team) != 1:
			continue
		var shooter_pos: Vector2 = shooter.p
		for enemy_index in balls.size():
			var enemy: Dictionary = balls[enemy_index]
			if not enemy.alive or int(enemy.team) != 0:
				continue
			var enemy_pos: Vector2 = enemy.p
			for hole_index in 6:
				var hole_pos: Vector2 = entry_trigger_center(hole_index)
				var to_hole: Vector2 = hole_pos - enemy_pos
				var hole_dist: float = to_hole.length()
				if hole_dist < 2.0:
					continue
				var hole_dir: Vector2 = to_hole / hole_dist
				var contact: Vector2 = enemy_pos - hole_dir * (RADIUS * 2.05)
				var to_contact: Vector2 = contact - shooter_pos
				var shot_dist: float = to_contact.length()
				if shot_dist < MIN_SHOT_PULL or shot_dist > 118.0:
					continue
				var shot_dir: Vector2 = to_contact / shot_dist
				var push_align: float = shot_dir.dot(hole_dir)
				if push_align < min_align:
					continue
				var score: float = push_align * 55.0
				score += (1.0 - clampf(hole_dist / 155.0, 0.0, 1.0)) * 38.0
				score += (1.0 - clampf(shot_dist / 118.0, 0.0, 1.0)) * 18.0
				score -= ai_self_sink_risk(shooter_pos, shot_dir, shot_dist) * 28.0
				candidates.append({
					"shooter": shooter_index,
					"direction": shot_dir,
					"distance": shot_dist,
					"score": score,
					"kind": "pocket"
				})
		for enemy_index in balls.size():
			var enemy: Dictionary = balls[enemy_index]
			if not enemy.alive or int(enemy.team) != 0:
				continue
			var to_enemy: Vector2 = enemy.p - shooter_pos
			var dist: float = to_enemy.length()
			if dist < MIN_SHOT_PULL or dist > 105.0:
				continue
			var dir: Vector2 = to_enemy / dist
			var hole_pos: Vector2 = ai_nearest_hole(enemy.p)
			var hole_dir: Vector2 = (hole_pos - enemy.p).normalized()
			var score: float = dir.dot(hole_dir) * 22.0 + (1.0 - dist / 105.0) * 10.0
			candidates.append({
				"shooter": shooter_index,
				"direction": dir,
				"distance": dist,
				"score": score,
				"kind": "hit"
			})
	return candidates

func ai_nearest_hole(pos: Vector2) -> Vector2:
	var best := entry_trigger_center(0)
	var best_dist := pos.distance_squared_to(best)
	for hole_index in range(1, 6):
		var center := entry_trigger_center(hole_index)
		var dist := pos.distance_squared_to(center)
		if dist < best_dist:
			best_dist = dist
			best = center
	return best

func ai_self_sink_risk(shooter_pos: Vector2, shot_dir: Vector2, shot_dist: float) -> float:
	var risk := 0.0
	var end_pos := shooter_pos + shot_dir * minf(shot_dist * 1.15, 90.0)
	for hole_index in 6:
		var hole_pos: Vector2 = entry_trigger_center(hole_index)
		if end_pos.distance_to(hole_pos) < trap_entry_radii[hole_index] + RADIUS * 2.5:
			risk += 1.0
	for ball in balls:
		if not ball.alive or int(ball.team) != 1:
			continue
		if ball.p.distance_squared_to(shooter_pos) < 0.01:
			continue
		if end_pos.distance_to(ball.p) < RADIUS * 3.0:
			risk += 0.35
	return risk

func ai_pick_shot(candidates: Array, settings: Dictionary) -> Dictionary:
	if candidates.is_empty():
		return {}
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.score) > float(b.score)
	)
	var pick_top: float = float(settings.pick_top)
	var pool_size: int = maxi(1, int(ceil(float(candidates.size()) * pick_top)))
	var choice: Dictionary = candidates[randi() % pool_size]
	return choice

func ai_fallback_shot() -> Dictionary:
	var shooters: Array[int] = []
	for i in balls.size():
		if balls[i].alive and int(balls[i].team) == 1:
			shooters.append(i)
	if shooters.is_empty():
		return {}
	var shooter_index: int = shooters[randi() % shooters.size()]
	var shooter_pos: Vector2 = balls[shooter_index].p
	var target_pos: Vector2 = Vector2(BOARD_W * 0.5, BOARD_H * 0.5)
	var enemy_count := 0
	for ball in balls:
		if ball.alive and int(ball.team) == 0:
			target_pos += ball.p
			enemy_count += 1
	if enemy_count > 0:
		target_pos /= float(enemy_count + 1)
	else:
		target_pos = Vector2(BOARD_W * 0.72, BOARD_H * 0.5)
	var to_target: Vector2 = target_pos - shooter_pos
	var dist: float = to_target.length()
	if dist < MIN_SHOT_PULL:
		to_target = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * MIN_SHOT_PULL
		dist = MIN_SHOT_PULL
	return {
		"shooter": shooter_index,
		"direction": to_target / dist,
		"distance": dist,
		"score": 0.0,
		"kind": "break"
	}

func ai_apply_shot(shot: Dictionary, settings: Dictionary) -> void:
	var shooter_index: int = int(shot.shooter)
	if shooter_index < 0 or shooter_index >= balls.size() or not balls[shooter_index].alive:
		return
	var direction: Vector2 = shot.direction
	var angle_error: float = float(settings.angle_error)
	direction = direction.rotated(randf_range(-angle_error, angle_error))
	if direction.length_squared() < 0.0001:
		direction = Vector2.RIGHT
	else:
		direction = direction.normalized()
	var base_strength: float = clampf(float(shot.distance) * 0.34, MIN_SHOT_PULL, 28.5)
	var power_error: float = float(settings.power_error)
	var strength: float = clampf(base_strength + randf_range(-power_error, power_error) * 12.0, MIN_SHOT_PULL, 30.0)
	balls[shooter_index].v = direction * (strength * 0.078)
	turn_shot_committed = true
	turn_pending_resolve = true
	turn_opponent_scored = false
	ai_committed_shot = true
	play_sound("shot")
	status = "Blue player shot..." if ui_language != "he" else "המחשב יורה..."

func ai_shot() -> void:
	var settings := ai_difficulty_settings()
	var candidates := ai_collect_shot_candidates(settings)
	var shot: Dictionary = ai_pick_shot(candidates, settings)
	if shot.is_empty():
		shot = ai_fallback_shot()
	if shot.is_empty():
		finish_ai_turn()
		return
	ai_apply_shot(shot, settings)

func finish_ai_turn() -> void:
	turn = 0
	turn_shot_committed = false
	turn_pending_resolve = false
	turn_opponent_scored = false
	status = "Your turn - touch a red ball, pull back and release"

func resolve_pending_turn() -> void:
	if match_finished or not turn_pending_resolve or any_ball_moving() or not effects_allow_next_turn():
		return
	var continue_turn := turn_opponent_scored
	turn_opponent_scored = false
	if game_mode == "online":
		if turn == multiplayer_slot:
			send_multiplayer({"type": "resolve_turn", "continueTurn": continue_turn})
		return
	apply_turn_after_shot(continue_turn)

func apply_turn_after_shot(continue_turn: bool) -> void:
	turn_pending_resolve = false
	turn_shot_committed = false
	if continue_turn:
		if game_mode == "computer" and turn == 1:
			ai_committed_shot = false
			ai_pending = true
			ai_timer = ai_think_delay()
			status = ui_text("extra_turn")
		else:
			status = ui_text("extra_turn")
		return
	if game_mode == "computer":
		if turn == 0:
			turn = 1
			ai_committed_shot = false
			ai_pending = true
			ai_timer = ai_think_delay()
			status = ("תור המחשב" if ui_language == "he" else "Computer's turn")
		else:
			finish_ai_turn()
	elif game_mode == "online":
		pass
	else:
		turn = 1 - turn
		status = ("תור שחקן " if ui_language == "he" else "Player ") + str(turn + 1)

func update_turn_status_from_server(continued: bool) -> void:
	if continued:
		status = ui_text("extra_turn")
		return
	if game_mode == "online":
		if turn == multiplayer_slot:
			status = "התור שלכם" if ui_language == "he" else "Your turn"
		else:
			status = "תור היריב" if ui_language == "he" else "Opponent's turn"

func any_ball_moving() -> bool:
	for ball in balls:
		if ball.alive and ball.v.length_squared() > 0.0001: return true
	return false

func show_turn_ball_hint() -> bool:
	if effect_editor_enabled or customizer_open or match_finished or turn_shot_committed:
		return false
	if any_ball_moving() or not effects_allow_next_turn():
		return false
	return true

func show_turn_ball_hint_for_team(team: int) -> bool:
	if not show_turn_ball_hint() or team != turn:
		return false
	if game_mode == "computer" and team != 0:
		return false
	if game_mode == "online" and team != multiplayer_slot:
		return false
	return true

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
		var launch_width: float = minf(viewport_size.x * 0.82, 620.0)
		var launch_rect := Rect2(
			(viewport_size.x - launch_width) * 0.5,
			viewport_size.y * 0.38,
			launch_width,
			112.0
		)
		var launch_shadow := Rect2(launch_rect.position + Vector2(0.0, 8.0), launch_rect.size).grow(8.0)
		draw_style_box(make_box(Color(0.01, 0.04, 0.08, 0.42), 30.0), launch_shadow)
		draw_style_box(make_box(Color("70df12"), 26.0), launch_rect)
		draw_string(ui_font, Vector2(launch_rect.position.x, launch_rect.position.y + 67.0), "לחצו כאן" if ui_language == "he" else "TAP HERE", HORIZONTAL_ALIGNMENT_CENTER, launch_rect.size.x, 46, Color.WHITE)
		draw_string(ui_font, Vector2(0, launch_rect.end.y + 52.0), "המשחק ייפתח לרוחב ובמסך מלא" if ui_language == "he" else "The game will open fullscreen in landscape", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 22, Color.WHITE)
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
	# Each table theme keeps the exact approved gameplay geometry while using
	# its own production texture.
	var active_board_texture := board_theme_texture(active_board_theme())
	if active_board_texture != null:
		draw_texture_rect(active_board_texture, board_rect, false)
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
		var visual_radius := GAME_BALL_VISUAL_RADIUS * board_scale
		if show_turn_ball_hint_for_team(ball.team):
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
	var visual_ball_radius := GAME_BALL_VISUAL_RADIUS * board_scale
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

func team_alive_count(team: int) -> int:
	var count := 0
	for ball in balls:
		if ball.team == team and ball.alive:
			count += 1
	return count

func check_match_end() -> void:
	if match_finished:
		return
	var alive_a := team_alive_count(0)
	var alive_b := team_alive_count(1)
	if alive_a > 0 and alive_b > 0:
		return
	var winner := 0 if alive_b == 0 else 1
	if alive_a == 0 and alive_b == 0:
		winner = 0 if turn == 1 else 1
	if game_mode == "online":
		match_finished = true
		dragging = false
		selected = -1
		send_multiplayer({"type": "match_result", "winnerSlot": winner})
		return
	finish_match(winner)

func finish_match(winner_team: int) -> void:
	match_finished = true
	if match_result_open:
		return
	match_result_open = true
	match_result_winner = winner_team
	dragging = false
	selected = -1
	ai_pending = false
	ai_committed_shot = false
	chat_open = false
	record_match_result(local_player_won(winner_team))
	queue_redraw()

func local_player_won(winner_team: int) -> bool:
	if game_mode == "online":
		return winner_team == multiplayer_slot
	return winner_team == 0

func match_prize_for_win() -> int:
	if match_source == "arena":
		return ARENA_WIN_PRIZES[clampi(selected_arena, 0, ARENA_WIN_PRIZES.size() - 1)]
	if game_mode == "computer":
		return COMPUTER_WIN_COINS
	return FRIEND_WIN_COINS

func record_match_result(did_win: bool) -> void:
	if match_result_recorded:
		return
	match_result_recorded = true
	if did_win:
		player_wins += 1
		player_current_streak += 1
		player_best_streak = maxi(player_best_streak, player_current_streak)
		player_xp += 80
		match_result_coins = match_prize_for_win()
		player_coins += match_result_coins
	else:
		player_losses += 1
		player_current_streak = 0
		player_xp += 20
		match_result_coins = 0
	while player_xp >= player_next_level_xp:
		player_xp -= player_next_level_xp
		player_level += 1
		player_next_level_xp = 500 + (player_level - 1) * 75
	if game_mode == "online":
		var opponent_rating := 1000
		if multiplayer_players.size() > 1:
			var opponent_slot := 1 - multiplayer_slot if multiplayer_slot >= 0 else 1
			for player_data in multiplayer_players:
				if int(player_data.get("slot", -1)) == opponent_slot:
					opponent_rating = int(player_data.get("rating", 1000))
					break
		apply_rating_change(did_win, opponent_rating)
	elif game_mode == "computer":
		apply_rating_change(did_win, ai_opponent_rating())
	if did_win:
		play_sound("win")
	save_player_profile()

func match_result_panel(viewport_size: Vector2) -> Rect2:
	return Rect2((viewport_size - Vector2(560.0, 310.0)) * 0.5, Vector2(560.0, 310.0))

func match_result_home_rect(viewport_size: Vector2) -> Rect2:
	var panel := match_result_panel(viewport_size)
	if game_mode == "computer":
		return Rect2(panel.position + Vector2(40.0, 215.0), Vector2(220.0, 58.0))
	return Rect2(panel.position + Vector2(150.0, 215.0), Vector2(260.0, 58.0))

func match_result_again_rect(viewport_size: Vector2) -> Rect2:
	var panel := match_result_panel(viewport_size)
	return Rect2(panel.position + Vector2(300.0, 215.0), Vector2(220.0, 58.0))

func draw_match_result(viewport_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.03, 0.06, 0.74))
	var panel := match_result_panel(viewport_size)
	draw_style_box(make_box(Color("10283b"), 26.0), panel)
	var won := local_player_won(match_result_winner)
	var title := ui_text("match_win") if won else ui_text("match_lose")
	draw_string(ui_font, panel.position + Vector2(0.0, 78.0), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 36, Color("f6d365") if won else Color("ff8c7a"))
	var subtitle := match_player_name(match_result_winner) + " • " + str(fallen_count(0)) + " - " + str(fallen_count(1))
	draw_string(ui_font, panel.position + Vector2(30.0, 128.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 60.0, 20, Color.WHITE)
	if won and match_result_coins > 0:
		draw_string(ui_font, panel.position + Vector2(30.0, 168.0), ui_text("you_won_coins") + str(match_result_coins) + ui_text("coins"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 60.0, 18, Color("ffe25d"))
	var home := match_result_home_rect(viewport_size)
	draw_style_box(make_box(Color("1b91a8"), 16.0), home)
	draw_string(ui_font, home.position + Vector2(0.0, 38.0), ui_text("back_home"), HORIZONTAL_ALIGNMENT_CENTER, home.size.x, 18, Color.WHITE)
	if game_mode == "computer":
		var again := match_result_again_rect(viewport_size)
		draw_style_box(make_box(Color("12a96b"), 16.0), again)
		draw_string(ui_font, again.position + Vector2(0.0, 38.0), ui_text("play_again"), HORIZONTAL_ALIGNMENT_CENTER, again.size.x, 18, Color.WHITE)

func daily_claim_key() -> String:
	return Time.get_date_string_from_system()

func can_claim_daily() -> bool:
	return last_daily_claim != daily_claim_key()

func claim_daily_reward() -> void:
	if not can_claim_daily():
		show_menu_notice(ui_text("claimed"))
		return
	player_coins += DAILY_REWARD_COINS
	last_daily_claim = daily_claim_key()
	save_player_profile()
	show_menu_notice(ui_text("daily_claimed_toast"))

func draw_scoreboards() -> void:
	# The blue and purple displays baked into the board art are covered by these
	# live panels. Their colors follow each player's selected lifebuoy.
	var centers := [
		board_rect.position + Vector2(board_rect.size.x * 0.289, board_rect.size.y * 0.052),
		board_rect.position + Vector2(board_rect.size.x * 0.683, board_rect.size.y * 0.052)
	]
	var colors := [RING_COLORS[team_ring_color_index(0)], RING_COLORS[team_ring_color_index(1)]]
	var panel_size := Vector2(board_rect.size.x * 0.075, board_rect.size.y * 0.060)
	var corner := maxf(5.0, board_rect.size.y * 0.012)
	var shared_rings := teams_share_ring_color()
	for team in 2:
		var outer_rect := Rect2(centers[team] - panel_size * 0.5, panel_size)
		draw_style_box(make_box(Color(0.08, 0.13, 0.14, 0.96), corner + 3.0), outer_rect.grow(4.0))
		draw_style_box(make_box(colors[team].darkened(0.16), corner), outer_rect)
		if shared_rings:
			draw_style_box(make_box(team_marker_color(team), corner), Rect2(outer_rect.position + Vector2(2.0, 2.0), Vector2(outer_rect.size.x - 4.0, 4.0)))
		var shine_rect := Rect2(outer_rect.position + Vector2(3.0, 3.0), Vector2(outer_rect.size.x - 6.0, outer_rect.size.y * 0.28))
		draw_style_box(make_box(Color(1.0, 1.0, 1.0, 0.20), corner * 0.55), shine_rect)
		var score := str(fallen_count(team))
		var font_size := maxi(18, int(panel_size.y * 0.82))
		var baseline: float = float(centers[team].y) + float(font_size) * 0.34
		draw_string(ui_font, Vector2(outer_rect.position.x, baseline), score, HORIZONTAL_ALIGNMENT_CENTER, outer_rect.size.x, font_size, Color.WHITE)

func draw_hud(viewport_size: Vector2) -> void:
	var back := game_back_rect()
	draw_style_box(make_box(Color(0.04, 0.09, 0.16, 0.94), 18.0), back)
	draw_string(ui_font, back.position + Vector2(0.0, 30.0), "‹", HORIZONTAL_ALIGNMENT_CENTER, back.size.x, 27, Color.WHITE)
	var card_width: float = minf(270.0, viewport_size.x * 0.22)
	# Keep the whole HUD on the water strip, with player identity at the edges.
	draw_match_player_card(Rect2(8.0, 6.0, card_width, 58.0), 0)
	draw_match_player_card(Rect2(viewport_size.x - card_width - 8.0, 6.0, card_width, 58.0), 1)
	if game_mode == "online":
		var chat_rect := game_chat_rect(viewport_size)
		draw_style_box(make_box(Color("1b91a8"), 14.0), chat_rect)
		draw_string(ui_font, chat_rect.position + Vector2(0.0, 31.0), "צ׳אט" if ui_language == "he" else "CHAT", HORIZONTAL_ALIGNMENT_CENTER, chat_rect.size.x, 17, Color.WHITE)
	if exit_confirm_open:
		draw_exit_confirmation(viewport_size)
	elif chat_open:
		draw_match_chat(viewport_size)
	if match_result_open:
		draw_match_result(viewport_size)

func game_back_rect() -> Rect2:
	return Rect2(286.0, 12.0, 46.0, 44.0)

func game_chat_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(viewport_size.x - 382.0, 10.0, 92.0, 48.0)

func match_turn_text() -> String:
	if game_mode == "online":
		return ("התור שלכם" if turn == multiplayer_slot else "תור היריב") if ui_language == "he" else ("YOUR TURN" if turn == multiplayer_slot else "OPPONENT TURN")
	if game_mode == "computer":
		return ("התור שלכם" if turn == 0 else "תור המחשב") if ui_language == "he" else ("YOUR TURN" if turn == 0 else "COMPUTER TURN")
	return ("תור שחקן " if ui_language == "he" else "PLAYER ") + str(turn + 1)

func match_player_name(team: int) -> String:
	if game_mode == "online" and team < multiplayer_players.size():
		return str(multiplayer_players[team].get("name", "שחקן " + str(team + 1)))
	if team == 0:
		return profile_name
	return ai_display_name() if game_mode == "computer" else ("שחקן 2" if ui_language == "he" else "PLAYER 2")

func draw_match_player_card(rect: Rect2, team: int) -> void:
	var active := turn == team
	var pulse := (sin(float(Time.get_ticks_msec()) * 0.005) + 1.0) * 0.5 if active else 0.0
	if active:
		var glow_rect := rect.grow(4.0 + pulse * 3.0)
		draw_style_box(make_box(Color(0.94, 0.82, 0.39, 0.20 + pulse * 0.10), 16.0), glow_rect)
	draw_style_box(make_box(Color(0.03, 0.08, 0.14, 0.94), 14.0), rect)
	if teams_share_ring_color():
		draw_style_box(make_box(team_marker_color(team), 10.0), Rect2(rect.position + Vector2(0.0, 6.0), Vector2(5.0, rect.size.y - 12.0)))
	if active:
		draw_rect(rect.grow(2.0 + pulse * 2.0), Color("f6d365"), false, 3.0 + pulse)
		var badge := ui_text("your_turn_badge") if is_local_player_team(team) else ("תור היריב" if ui_language == "he" else "THEIR TURN")
		var badge_rect := Rect2(rect.position.x + rect.size.x - 92.0, rect.position.y - 10.0, 88.0, 22.0)
		draw_style_box(make_box(Color("12a96b") if is_local_player_team(team) else Color("7256d8"), 10.0), badge_rect)
		draw_string(ui_font, badge_rect.position + Vector2(0.0, 16.0), badge, HORIZONTAL_ALIGNMENT_CENTER, badge_rect.size.x, 11, Color.WHITE)
	if team_piece_textures.size() > team and team_piece_textures[team] != null:
		draw_texture_rect(team_piece_textures[team], Rect2(rect.position + Vector2(7.0, 5.0), Vector2(48.0, 48.0)), false)
	var animal_index := player_animal if team == 0 else ai_animal
	var team_rating := player_rating if team == 0 else ai_opponent_rating()
	var team_league := player_league_tier if team == 0 else league_tier_for_rating(ai_opponent_rating())
	if game_mode == "online" and team < multiplayer_players.size():
		var pdata: Dictionary = multiplayer_players[team]
		team_rating = int(pdata.get("rating", team_rating))
		team_league = int(pdata.get("leagueTier", team_league))
	draw_string(ui_font, rect.position + Vector2(62.0, 25.0), match_player_name(team), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 68.0, 16, Color.WHITE)
	draw_string(ui_font, rect.position + Vector2(62.0, 46.0), league_name(team_league) + " • " + str(team_rating), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 68.0, 11, RING_COLORS[team_ring_color_index(team)].lightened(0.28))

func is_local_player_team(team: int) -> bool:
	if game_mode == "online":
		return team == multiplayer_slot
	if game_mode == "computer":
		return team == 0
	return true

func exit_confirm_panel(viewport_size: Vector2) -> Rect2:
	return Rect2((viewport_size - Vector2(520.0, 245.0)) * 0.5, Vector2(520.0, 245.0))

func exit_confirm_yes_rect(viewport_size: Vector2) -> Rect2:
	var panel := exit_confirm_panel(viewport_size)
	return Rect2(panel.position + Vector2(45.0, 157.0), Vector2(195.0, 58.0))

func exit_confirm_no_rect(viewport_size: Vector2) -> Rect2:
	var panel := exit_confirm_panel(viewport_size)
	return Rect2(panel.position + Vector2(280.0, 157.0), Vector2(195.0, 58.0))

func draw_exit_confirmation(viewport_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.03, 0.06, 0.72))
	var panel := exit_confirm_panel(viewport_size)
	draw_style_box(make_box(Color("10283b"), 24.0), panel)
	draw_string(ui_font, panel.position + Vector2(0.0, 66.0), "לצאת מהמשחק?" if ui_language == "he" else "LEAVE THE MATCH?", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 30, Color("f6d365"))
	draw_string(ui_font, panel.position + Vector2(0.0, 112.0), "המשחק עדיין מתנהל. האם אתם בטוחים?" if ui_language == "he" else "The match is still in progress. Are you sure?", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 18, Color.WHITE)
	var yes := exit_confirm_yes_rect(viewport_size)
	var no := exit_confirm_no_rect(viewport_size)
	draw_style_box(make_box(Color("ef5350"), 16.0), yes)
	draw_style_box(make_box(Color("12a96b"), 16.0), no)
	draw_string(ui_font, yes.position + Vector2(0.0, 37.0), "כן, לצאת" if ui_language == "he" else "LEAVE", HORIZONTAL_ALIGNMENT_CENTER, yes.size.x, 19, Color.WHITE)
	draw_string(ui_font, no.position + Vector2(0.0, 37.0), "להמשיך לשחק" if ui_language == "he" else "KEEP PLAYING", HORIZONTAL_ALIGNMENT_CENTER, no.size.x, 19, Color.WHITE)

func exit_current_match() -> void:
	exit_confirm_open = false
	chat_open = false
	leave_multiplayer_room()
	app_screen = APP_HOME
	selected = -1
	dragging = false
	active_effects.clear()
	queue_redraw()

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
	var radius := trap_ball_radius(ELECTRIC_TRAP_HOLE, GAME_BALL_VISUAL_RADIUS * board_scale)
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
	if teams_share_ring_color():
		var marker := team_marker_color(team)
		draw_arc(position, radius * 1.16, 0.0, TAU, 36, marker, maxf(2.5, radius * 0.16), true)
		draw_circle(position + Vector2(radius * 0.72, -radius * 0.72), radius * 0.22, marker)
		draw_string(ui_font, position + Vector2(radius * 0.56, -radius * 0.58), str(team + 1), HORIZONTAL_ALIGNMENT_CENTER, radius * 0.45, maxi(10, int(radius * 0.42)), Color("173249"))

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
	var size := Vector2(minf(820.0, viewport_size.x - 36.0), minf(560.0, viewport_size.y - 34.0))
	return Rect2((viewport_size - size) * 0.5, size)

func customizer_animal_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 8.0
	var width := (panel.size.x - 40.0 - gap * float(ANIMAL_NAMES.size() - 1)) / float(ANIMAL_NAMES.size())
	return Rect2(panel.position + Vector2(20.0 + index * (width + gap), 82.0), Vector2(width, 68.0))

func customizer_color_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 8.0
	var width := (panel.size.x - 40.0 - gap * float(RING_COLOR_NAMES.size() - 1)) / float(RING_COLOR_NAMES.size())
	return Rect2(panel.position + Vector2(20.0 + index * (width + gap), 205.0), Vector2(width, 58.0))

func customizer_board_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 10.0
	var width := (panel.size.x - 40.0 - gap * float(BOARD_THEME_COUNT - 1)) / float(BOARD_THEME_COUNT)
	return Rect2(panel.position + Vector2(20.0 + float(index) * (width + gap), 262.0), Vector2(width, 76.0))

func customizer_difficulty_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	var gap := 12.0
	var width := (panel.size.x - 40.0 - gap * 2.0) / 3.0
	return Rect2(panel.position + Vector2(20.0 + float(index) * (width + gap), 368.0), Vector2(width, 54.0))

func customizer_start_rect(viewport_size: Vector2) -> Rect2:
	var panel := customizer_panel(viewport_size)
	return Rect2(panel.position + Vector2(panel.size.x * 0.5 - 110.0, panel.size.y - 68.0), Vector2(220.0, 48.0))

func handle_customizer_touch(screen_pos: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	if not customizer_open:
		return false
	for i in ANIMAL_NAMES.size():
		if customizer_animal_rect(i, viewport_size).has_point(screen_pos):
			try_select_animal(i)
			queue_redraw()
			return true
	for i in RING_COLOR_NAMES.size():
		if customizer_color_rect(i, viewport_size).has_point(screen_pos):
			try_select_ring(i)
			queue_redraw()
			return true
	for i in BOARD_THEME_COUNT:
		if customizer_board_rect(i, viewport_size).has_point(screen_pos):
			selected_board_theme = i
			save_player_profile()
			play_sound("ui")
			queue_redraw()
			return true
	for i in 3:
		if customizer_difficulty_rect(i, viewport_size).has_point(screen_pos):
			computer_difficulty = i
			save_player_profile()
			play_sound("ui")
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
	draw_string(ui_font, panel.position + Vector2(0, 38), ui_text("choose_setup"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 22, Color("f6d365"))
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_string(ui_font, panel.position + Vector2(20, 72), "דמות" if ui_language == "he" else "ANIMAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in ANIMAL_NAMES.size():
		var rect := customizer_animal_rect(i, viewport_size)
		draw_style_box(make_box(Color("7256d8") if i == player_animal else Color("26384b"), 10.0), rect)
		if i < full_body_animal_textures.size() and full_body_animal_textures[i] != null:
			var portrait := Rect2(rect.position + Vector2(rect.size.x * 0.5 - 22.0, 4.0), Vector2(44.0, 48.0))
			draw_texture_rect(full_body_animal_textures[i], portrait, false)
		draw_collection_lock_overlay(rect, i, false, unit)
		draw_string(ui_font, rect.position + Vector2(0, 62), ANIMAL_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color.WHITE)
	draw_string(ui_font, panel.position + Vector2(20, 195), "צבע הגלגל" if ui_language == "he" else "LIFEBUOY COLOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in RING_COLOR_NAMES.size():
		var rect := customizer_color_rect(i, viewport_size)
		draw_style_box(make_box(RING_COLORS[i], 10.0), rect)
		if i == player_ring_color:
			draw_rect(rect.grow(3.0), Color.WHITE, false, 3.0)
		draw_collection_lock_overlay(rect, i, true, unit)
		draw_string(ui_font, rect.position + Vector2(0, 36), RING_COLOR_NAMES[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color.WHITE)
	draw_string(ui_font, panel.position + Vector2(20, 248), ui_text("choose_board"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	for i in BOARD_THEME_COUNT:
		draw_board_theme_card(i, customizer_board_rect(i, viewport_size), i == selected_board_theme, unit)
	draw_string(ui_font, panel.position + Vector2(20, 354), ui_text("difficulty"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	var diff_labels := [ui_text("difficulty_easy"), ui_text("difficulty_medium"), ui_text("difficulty_hard")]
	var diff_colors := [Color("51d995"), Color("f6aa20"), Color("e94f78")]
	for i in 3:
		var diff_rect := customizer_difficulty_rect(i, viewport_size)
		var selected := i == computer_difficulty
		draw_style_box(make_box(diff_colors[i] if selected else Color("26384b"), 12.0), diff_rect)
		if selected:
			draw_rect(diff_rect.grow(3.0), Color.WHITE, false, 3.0)
		draw_string(ui_font, diff_rect.position + Vector2(0, 34), diff_labels[i], HORIZONTAL_ALIGNMENT_CENTER, diff_rect.size.x, 14, Color.WHITE)
	var start_rect := customizer_start_rect(viewport_size)
	draw_style_box(make_box(Color("12a96b"), 14.0), start_rect)
	draw_string(ui_font, start_rect.position + Vector2(0, 31), "התחלת משחק" if ui_language == "he" else "START MATCH", HORIZONTAL_ALIGNMENT_CENTER, start_rect.size.x, 17, Color.WHITE)

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
	var ball_radius := trap_ball_radius(RUBBER_TRAP_HOLE, GAME_BALL_VISUAL_RADIUS * board_scale)
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

func home_layout(viewport_size: Vector2) -> Dictionary:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var header_h := 96.0 * unit
	var left_x := 18.0 * unit
	var left_w := 164.0 * unit
	var right_w := 258.0 * unit
	var right_x := viewport_size.x - right_w - 14.0 * unit
	var bottom_bar_h := 88.0 * unit
	var content_top := header_h + 10.0 * unit
	var content_bottom := viewport_size.y - bottom_bar_h - 12.0 * unit
	var center_left := left_x + left_w + 16.0 * unit
	var center_right := right_x - 16.0 * unit
	var center_w := maxf(140.0 * unit, center_right - center_left)
	var stats_h := 58.0 * unit
	var rail_button_h := 74.0 * unit
	var rail_gap := 10.0 * unit
	var rail_start_y := content_top + stats_h + 10.0 * unit
	var bottom_y := viewport_size.y - bottom_bar_h - 4.0 * unit
	var bottom_button_h := 78.0 * unit
	var bottom_gap := 10.0 * unit
	var bottom_avail_w := center_w - bottom_gap * 2.0
	var arena_w := bottom_avail_w * 0.30
	var friend_w := bottom_avail_w * 0.32
	var play_w := bottom_avail_w * 0.38
	var arena_x := center_left
	var friend_x := arena_x + arena_w + bottom_gap
	var play_x := friend_x + friend_w + bottom_gap
	return {
		"unit": unit,
		"header_h": header_h,
		"left_x": left_x,
		"left_w": left_w,
		"right_x": right_x,
		"right_w": right_w,
		"content_top": content_top,
		"content_bottom": content_bottom,
		"center_left": center_left,
		"center_right": center_right,
		"center_w": center_w,
		"stats_h": stats_h,
		"rail_button_h": rail_button_h,
		"rail_gap": rail_gap,
		"rail_start_y": rail_start_y,
		"bottom_y": bottom_y,
		"bottom_button_h": bottom_button_h,
		"arena_w": arena_w,
		"friend_w": friend_w,
		"play_w": play_w,
		"arena_x": arena_x,
		"friend_x": friend_x,
		"play_x": play_x,
	}

func home_stats_rect(viewport_size: Vector2) -> Rect2:
	var layout := home_layout(viewport_size)
	return Rect2(layout.left_x, layout.content_top, layout.left_w, layout.stats_h)

func home_mode_rect(index: int, viewport_size: Vector2) -> Rect2:
	var layout := home_layout(viewport_size)
	if index == 0:
		return Rect2(layout.arena_x, layout.bottom_y, layout.arena_w, layout.bottom_button_h)
	if index == 1:
		return Rect2(layout.friend_x, layout.bottom_y, layout.friend_w, layout.bottom_button_h)
	if index == 2:
		return Rect2(layout.play_x, layout.bottom_y, layout.play_w, layout.bottom_button_h)
	return Rect2()

func arena_card_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var card_size := Vector2(350.0, 430.0) * unit
	var gap := 24.0 * unit
	var total_width := card_size.x * 3.0 + gap * 2.0
	return Rect2(Vector2((viewport_size.x - total_width) * 0.5 + float(index) * (card_size.x + gap), 142.0 * unit), card_size)

func arena_play_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((viewport_size.x - 290.0 * unit) * 0.5, viewport_size.y - 78.0 * unit), Vector2(290.0, 58.0) * unit)

func arena_board_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var gap := 14.0 * unit
	var card_w := minf(200.0 * unit, (viewport_size.x - 100.0 * unit - gap * float(BOARD_THEME_COUNT - 1)) / float(BOARD_THEME_COUNT))
	var total_w := card_w * float(BOARD_THEME_COUNT) + gap * float(BOARD_THEME_COUNT - 1)
	var start_x := (viewport_size.x - total_w) * 0.5
	return Rect2(Vector2(start_x + float(index) * (card_w + gap), 556.0 * unit), Vector2(card_w, 72.0 * unit))

func player_profile_animal_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((62.0 + float(index) * 62.0) * unit, 526.0 * unit), Vector2(54.0, 62.0) * unit)

func player_profile_color_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((70.0 + float(index) * 60.0) * unit, 614.0 * unit), Vector2(44.0, 44.0) * unit)

func player_id_copy_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(1060.0, 620.0) * unit, Vector2(150.0, 42.0) * unit)

func player_google_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(870.0, 620.0) * unit, Vector2(175.0, 42.0) * unit)

func home_profile_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(28.0 * unit, 22.0 * unit, 282.0 * unit, 58.0 * unit)

func home_top_control_rects(viewport_size: Vector2) -> Dictionary:
	var layout := home_layout(viewport_size)
	var unit: float = layout.unit
	var right_x: float = layout.right_x
	var y: float = 22.0 * unit
	var h: float = 54.0 * unit
	var gap: float = 8.0 * unit
	var coin_w: float = 154.0 * unit
	var gem_w: float = 120.0 * unit
	var small_w: float = 54.0 * unit
	var coin_x: float = right_x - coin_w - gap
	var gem_x: float = coin_x - gem_w - gap
	var sound_x: float = gem_x - small_w - gap
	var help_x: float = sound_x - small_w - gap
	var settings_x: float = help_x - small_w - gap
	return {
		"coin": Rect2(coin_x, y, coin_w, h),
		"gems": Rect2(gem_x, y, gem_w, h),
		"sound": Rect2(sound_x, y, small_w, h),
		"help": Rect2(help_x, y, small_w, h),
		"settings": Rect2(settings_x, y, small_w, h),
	}

func home_coin_rect(viewport_size: Vector2) -> Rect2:
	return home_top_control_rects(viewport_size).coin

func home_settings_rect(viewport_size: Vector2) -> Rect2:
	return home_top_control_rects(viewport_size).settings

func home_help_rect(viewport_size: Vector2) -> Rect2:
	return home_top_control_rects(viewport_size).help

func home_sound_toggle_rect(viewport_size: Vector2) -> Rect2:
	return home_top_control_rects(viewport_size).sound

func home_gems_rect(viewport_size: Vector2) -> Rect2:
	return home_top_control_rects(viewport_size).gems

func tutorial_step_data(step: int) -> Dictionary:
	var steps := TUTORIAL_STEPS_HE if ui_language == "he" else TUTORIAL_STEPS_EN
	return steps[clampi(step, 0, steps.size() - 1)]

func tutorial_panel_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var width := minf(760.0 * unit, viewport_size.x - 48.0 * unit)
	var height := minf(520.0 * unit, viewport_size.y - 72.0 * unit)
	return Rect2(Vector2((viewport_size.x - width) * 0.5, (viewport_size.y - height) * 0.5), Vector2(width, height))

func tutorial_prev_rect(viewport_size: Vector2) -> Rect2:
	var panel := tutorial_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.position + Vector2(24.0 * unit, panel.size.y - 64.0 * unit), Vector2(120.0 * unit, 44.0 * unit))

func tutorial_next_rect(viewport_size: Vector2) -> Rect2:
	var panel := tutorial_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.end - Vector2(144.0 * unit, 64.0 * unit), Vector2(120.0 * unit, 44.0 * unit))

func tutorial_skip_rect(viewport_size: Vector2) -> Rect2:
	var panel := tutorial_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.end - Vector2(54.0 * unit, panel.size.y - 8.0 * unit), Vector2(36.0 * unit, 36.0 * unit))

func tutorial_highlight_rect(step: int, viewport_size: Vector2) -> Rect2:
	match step:
		5:
			return home_mode_rect(2, viewport_size).grow(8.0)
		6:
			return home_social_panel_rect(viewport_size).grow(6.0)
		7:
			return home_mode_rect(2, viewport_size).grow(12.0)
	return Rect2()

func maybe_start_tutorial() -> void:
	if tutorial_completed or tutorial_open or tutorial_dismissed_session:
		return
	open_tutorial()

func open_tutorial(from_step: int = 0) -> void:
	tutorial_open = true
	tutorial_step = clampi(from_step, 0, TUTORIAL_STEP_COUNT - 1)
	play_sound("ui")
	queue_redraw()

func complete_tutorial() -> void:
	tutorial_open = false
	tutorial_completed = true
	save_player_profile()
	play_sound("ui")
	queue_redraw()

func advance_tutorial_step() -> void:
	if tutorial_step >= TUTORIAL_STEP_COUNT - 1:
		complete_tutorial()
	else:
		tutorial_step += 1
		play_sound("ui")
		queue_redraw()

func retreat_tutorial_step() -> void:
	tutorial_step = maxi(0, tutorial_step - 1)
	play_sound("ui")
	queue_redraw()

func handle_tutorial_touch(screen_pos: Vector2, viewport_size: Vector2) -> void:
	if tutorial_skip_rect(viewport_size).has_point(screen_pos):
		complete_tutorial()
		return
	if tutorial_step > 0 and tutorial_prev_rect(viewport_size).has_point(screen_pos):
		retreat_tutorial_step()
		return
	if tutorial_next_rect(viewport_size).has_point(screen_pos):
		advance_tutorial_step()
		return

func draw_tutorial_art(art_id: String, rect: Rect2, unit: float) -> void:
	var center := rect.get_center()
	match art_id:
		"welcome":
			draw_circle(center, 58.0 * unit, Color("8cecff", 0.22))
			draw_circle(center + Vector2(-28.0, 8.0) * unit, 22.0 * unit, Color("ef3340"))
			draw_circle(center + Vector2(24.0, -6.0) * unit, 22.0 * unit, Color("1677ff"))
			draw_string(ui_font, center + Vector2(-34.0, 58.0) * unit, "ZOOPA", HORIZONTAL_ALIGNMENT_CENTER, 68.0 * unit, int(22.0 * unit), Color("ffe25d"))
		"shoot":
			var ball_pos := center + Vector2(36.0, 10.0) * unit
			draw_circle(ball_pos, 18.0 * unit, Color("ef3340"))
			draw_line(ball_pos, ball_pos + Vector2(-72.0, 28.0) * unit, Color("ffe25d"), 5.0 * unit, true)
			draw_circle(ball_pos + Vector2(-72.0, 28.0) * unit, 10.0 * unit, Color("ffe25d", 0.55))
			draw_string(ui_font, center + Vector2(-80.0, -42.0) * unit, "← PULL", HORIZONTAL_ALIGNMENT_CENTER, 90.0 * unit, int(14.0 * unit), Color.WHITE)
		"goal":
			var board := Rect2(center + Vector2(-88.0, -48.0) * unit, Vector2(176.0, 176.0) * unit)
			draw_style_box(make_box(Color("5d7f4f"), 12.0 * unit), board)
			for corner in [board.position, board.position + Vector2(board.size.x, 0.0), board.end - board.size, board.end]:
				draw_circle(corner, 14.0 * unit, Color("173249"))
			draw_circle(board.get_center(), 12.0 * unit, Color("ef3340"))
			draw_circle(board.get_center() + Vector2(34.0, -18.0) * unit, 12.0 * unit, Color("1677ff"))
		"weapons":
			var icons := [Color("ef3340"), Color("9d59e8"), Color("ff8a00"), Color("12c95b")]
			for i in icons.size():
				var pos := center + Vector2(-54.0 + float(i) * 36.0, float((i % 2) * 20 - 10)) * unit
				draw_circle(pos, 16.0 * unit, icons[i])
		"turns":
			var left_card := Rect2(center + Vector2(-92.0, -34.0) * unit, Vector2(84.0, 68.0) * unit)
			var right_card := Rect2(center + Vector2(8.0, -34.0) * unit, Vector2(84.0, 68.0) * unit)
			draw_style_box(make_box(Color("ffe25d"), 10.0 * unit), left_card.grow(4.0 * unit))
			draw_style_box(make_box(Color("173249"), 8.0 * unit), left_card)
			draw_style_box(make_box(Color("244d70"), 8.0 * unit), right_card)
			draw_string(ui_font, left_card.position + Vector2(0.0, 42.0) * unit, "YOU", HORIZONTAL_ALIGNMENT_CENTER, left_card.size.x, int(12.0 * unit), Color.WHITE)
		"modes":
			var labels := ["PC", "FR", "AR"]
			var colors := [Color("f6aa20"), Color("315fd0"), Color("7258df")]
			for i in 3:
				var chip := Rect2(center + Vector2(-78.0 + float(i) * 52.0, -18.0) * unit, Vector2(44.0, 44.0) * unit)
				draw_style_box(make_box(colors[i], 10.0 * unit), chip)
				draw_string(ui_font, chip.position + Vector2(0.0, 28.0) * unit, labels[i], HORIZONTAL_ALIGNMENT_CENTER, chip.size.x, int(11.0 * unit), Color.WHITE)
		"hub":
			draw_style_box(make_box(Color("315fd0"), 12.0 * unit), Rect2(center + Vector2(-70.0, -30.0) * unit, Vector2(140.0, 60.0) * unit))
			draw_circle(center + Vector2(-48.0, 42.0) * unit, 14.0 * unit, Color("6965d8"))
			draw_circle(center + Vector2(-16.0, 42.0) * unit, 14.0 * unit, Color("51d995"))
			draw_circle(center + Vector2(16.0, 42.0) * unit, 14.0 * unit, Color("ffe25d"))
		"ready":
			draw_circle(center, 42.0 * unit, Color("6fda18", 0.25))
			draw_string(ui_font, center + Vector2(-28.0, 12.0) * unit, "GO!", HORIZONTAL_ALIGNMENT_CENTER, 56.0 * unit, int(34.0 * unit), Color("6fda18"))

func draw_tutorial_overlay(viewport_size: Vector2) -> void:
	if not tutorial_open:
		return
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var highlight := tutorial_highlight_rect(tutorial_step, viewport_size)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.72))
	if highlight.size.x > 0.0:
		var pulse := 0.55 + sin(menu_elapsed * 5.0) * 0.2
		draw_style_box(make_box(Color("ffe25d", pulse), 18.0 * unit), highlight.grow(6.0 * unit))
	var panel := tutorial_panel_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.13, 0.96), 26.0 * unit), panel.grow(6.0 * unit))
	draw_style_box(make_box(Color("eaf8f1"), 24.0 * unit), panel)
	var step_data := tutorial_step_data(tutorial_step)
	draw_string(ui_font, panel.position + Vector2(0.0, 42.0) * unit, ui_text("tutorial_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(14.0 * unit), Color("2982a6"))
	draw_string(ui_font, panel.position + Vector2(24.0 * unit, 78.0) * unit, str(step_data.get("title", "")), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 48.0 * unit, int(26.0 * unit), Color("173249"))
	var art_rect := Rect2(panel.position + Vector2(panel.size.x * 0.5 - 100.0 * unit, 112.0 * unit), Vector2(200.0, 120.0) * unit)
	draw_tutorial_art(str(step_data.get("art", "")), art_rect, unit)
	var body_y := 250.0 * unit
	var body_lines := str(step_data.get("body", "")).split("\n")
	for line in body_lines:
		draw_string(ui_font, panel.position + Vector2(28.0 * unit, body_y), line, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 56.0 * unit, int(16.0 * unit), Color("354522"))
		body_y += 28.0 * unit
	var dots_x := panel.position.x + panel.size.x * 0.5 - float(TUTORIAL_STEP_COUNT - 1) * 10.0 * unit
	for i in TUTORIAL_STEP_COUNT:
		var dot_center := Vector2(dots_x + float(i) * 20.0 * unit, panel.end.y - 78.0 * unit)
		draw_circle(dot_center, 5.0 * unit, Color("ffe25d") if i == tutorial_step else Color("9ab0c2"))
	if tutorial_step > 0:
		draw_style_box(make_box(Color("244d70"), 12.0 * unit), tutorial_prev_rect(viewport_size))
		draw_string(ui_font, tutorial_prev_rect(viewport_size).position + Vector2(0.0, 29.0) * unit, ui_text("tutorial_prev"), HORIZONTAL_ALIGNMENT_CENTER, tutorial_prev_rect(viewport_size).size.x, int(15.0 * unit), Color.WHITE)
	var next_label := ui_text("tutorial_done") if tutorial_step >= TUTORIAL_STEP_COUNT - 1 else ui_text("tutorial_next")
	draw_style_box(make_box(Color("35b96f"), 12.0 * unit), tutorial_next_rect(viewport_size))
	draw_string(ui_font, tutorial_next_rect(viewport_size).position + Vector2(0.0, 29.0) * unit, next_label, HORIZONTAL_ALIGNMENT_CENTER, tutorial_next_rect(viewport_size).size.x, int(15.0 * unit), Color.WHITE)
	draw_string(ui_font, tutorial_skip_rect(viewport_size).position + Vector2(0.0, 26.0) * unit, "×", HORIZONTAL_ALIGNMENT_CENTER, tutorial_skip_rect(viewport_size).size.x, int(22.0 * unit), Color("607080"))

func home_nav_rect(index: int, viewport_size: Vector2) -> Rect2:
	var layout := home_layout(viewport_size)
	var y: float = layout.rail_start_y + (layout.rail_button_h + layout.rail_gap) * float(index)
	return Rect2(layout.left_x, y, layout.left_w, layout.rail_button_h)

func home_character_rect(viewport_size: Vector2) -> Rect2:
	var layout := home_layout(viewport_size)
	var unit: float = layout.unit
	var center_left: float = layout.center_left
	var center_w: float = layout.center_w
	var content_top: float = layout.content_top
	var content_bottom: float = layout.content_bottom
	var char_w: float = minf(300.0 * unit, center_w * 0.88)
	var char_h: float = minf(390.0 * unit, (content_bottom - content_top) * 0.72)
	var char_x: float = center_left + (center_w - char_w) * 0.5
	var char_y: float = content_top + 6.0 * unit
	return Rect2(char_x, char_y, char_w, char_h)

func draw_home_ambient_effects(viewport_size: Vector2) -> void:
	init_home_ambient_particles()
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	for particle in home_ambient_particles:
		var px: float = float(particle.x) * viewport_size.x
		var py: float = fmod(float(particle.y) + menu_elapsed * float(particle.speed), 1.08) * viewport_size.y - viewport_size.y * 0.04
		var pulse := 0.55 + sin(menu_elapsed * 2.2 + float(particle.phase)) * 0.25
		var size: float = float(particle.size) * unit * pulse
		var color := Color("8cecff", 0.10 + pulse * 0.08) if int(particle.kind) == 0 else Color("ffe25d", 0.08 + pulse * 0.07)
		if int(particle.kind) == 2:
			color = Color("c77dff", 0.07 + pulse * 0.06)
		draw_circle(Vector2(px, py), size, color)
	var ray_alpha := 0.05 + sin(menu_elapsed * 0.7) * 0.02
	draw_rect(Rect2(viewport_size.x * 0.18, 0.0, viewport_size.x * 0.22, viewport_size.y), Color(1.0, 1.0, 1.0, ray_alpha))
	draw_rect(Rect2(viewport_size.x * 0.62, 0.0, viewport_size.x * 0.16, viewport_size.y), Color("8cecff", ray_alpha * 0.8))

func draw_pending_invite_banner(viewport_size: Vector2) -> void:
	if pending_friend_invite.is_empty():
		return
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var banner := Rect2(viewport_size.x * 0.28, 102.0 * unit, viewport_size.x * 0.44, 54.0 * unit)
	draw_style_box(make_box(Color("e94f78"), 16.0 * unit), banner)
	var text := ui_text("invite_received") + str(pending_friend_invite.get("fromName", ""))
	draw_string(ui_font, banner.position + Vector2(16.0 * unit, 22.0 * unit), text, HORIZONTAL_ALIGNMENT_LEFT, banner.size.x - 130.0 * unit, int(14.0 * unit), Color.WHITE)
	var join_rect := Rect2(banner.end.x - 112.0 * unit, banner.position.y + 10.0 * unit, 96.0 * unit, 34.0 * unit)
	draw_style_box(make_box(Color("35b96f"), 12.0 * unit), join_rect)
	draw_string(ui_font, join_rect.position + Vector2(0.0, 23.0) * unit, ui_text("join_invite"), HORIZONTAL_ALIGNMENT_CENTER, join_rect.size.x, int(14.0 * unit), Color.WHITE)

func home_invite_join_rect(viewport_size: Vector2) -> Rect2:
	if pending_friend_invite.is_empty():
		return Rect2()
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var banner := Rect2(viewport_size.x * 0.28, 102.0 * unit, viewport_size.x * 0.44, 54.0 * unit)
	return Rect2(banner.end.x - 112.0 * unit, banner.position.y + 10.0 * unit, 96.0 * unit, 34.0 * unit)

func accept_pending_friend_invite() -> void:
	if pending_friend_invite.is_empty():
		return
	var code := str(pending_friend_invite.get("roomCode", ""))
	pending_friend_invite = {}
	if code.is_empty():
		return
	app_screen = APP_FRIEND
	room_code_input.text = code
	connect_multiplayer()
	if multiplayer_state == "connected":
		join_multiplayer_room()
	else:
		pending_shared_room_code = code
	play_sound("ui")

func friend_room_chat_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(840.0, 320.0) * unit, Vector2(205.0, 48.0) * unit)

func home_social_panel_rect(viewport_size: Vector2) -> Rect2:
	var layout := home_layout(viewport_size)
	return Rect2(layout.right_x, layout.content_top, layout.right_w, layout.content_bottom - layout.content_top)

func home_social_tab_rect(tab: int, viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var width := (panel.size.x - 22.0 * unit) / 3.0
	return Rect2(panel.position + Vector2(9.0 * unit + float(tab) * (width + 2.0 * unit), 14.0 * unit), Vector2(width, 38.0 * unit))

func home_add_friend_rect(viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.position + Vector2(14.0 * unit, panel.size.y - 98.0 * unit), Vector2(panel.size.x - 28.0 * unit, 38.0 * unit))

func home_add_friend_button_rect(viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.position + Vector2(14.0 * unit, panel.size.y - 52.0 * unit), Vector2(panel.size.x - 28.0 * unit, 36.0 * unit))

func home_friend_row_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var start_y := home_friends_content_top(viewport_size)
	return Rect2(panel.position + Vector2(14.0 * unit, start_y + float(index) * 58.0 * unit), Vector2(panel.size.x - 28.0 * unit, 52.0 * unit))

func home_friends_content_top(viewport_size: Vector2) -> float:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var incoming_count := mini(2, incoming_friend_requests.size())
	var header_h := 18.0 * unit if incoming_count > 0 else 0.0
	return 72.0 * unit + header_h + float(incoming_count) * 58.0 * unit

func home_incoming_request_rect(index: int, viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var start_y := 90.0 * unit + float(index) * 58.0 * unit
	return Rect2(panel.position + Vector2(14.0 * unit, start_y), Vector2(panel.size.x - 28.0 * unit, 48.0 * unit))

func home_incoming_accept_rect(index: int, viewport_size: Vector2) -> Rect2:
	var row := home_incoming_request_rect(index, viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(row.position + Vector2(row.size.x - 150.0 * unit, 8.0 * unit), Vector2(68.0, 32.0) * unit)

func home_incoming_decline_rect(index: int, viewport_size: Vector2) -> Rect2:
	var row := home_incoming_request_rect(index, viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(row.position + Vector2(row.size.x - 76.0 * unit, 8.0 * unit), Vector2(68.0, 32.0) * unit)

func home_friend_invite_rect(index: int, viewport_size: Vector2) -> Rect2:
	var row := home_friend_row_rect(index, viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(row.position + Vector2(row.size.x - 86.0 * unit, 10.0 * unit), Vector2(72.0, 32.0) * unit)

func home_friend_profile_modal_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var width := minf(420.0 * unit, viewport_size.x - 80.0 * unit)
	var height := minf(360.0 * unit, viewport_size.y - 120.0 * unit)
	return Rect2(Vector2((viewport_size.x - width) * 0.5, (viewport_size.y - height) * 0.5), Vector2(width, height))

func home_friend_profile_close_rect(viewport_size: Vector2) -> Rect2:
	var modal := home_friend_profile_modal_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(modal.end - Vector2(42.0 * unit, modal.size.y - 10.0 * unit), Vector2(32.0 * unit, 32.0 * unit))

func home_friend_profile_invite_rect(viewport_size: Vector2) -> Rect2:
	var modal := home_friend_profile_modal_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(modal.position + Vector2(24.0 * unit, modal.size.y - 64.0 * unit), Vector2((modal.size.x - 58.0 * unit) * 0.5, 40.0 * unit))

func home_friend_profile_remove_rect(viewport_size: Vector2) -> Rect2:
	var modal := home_friend_profile_modal_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(modal.position + Vector2(modal.size.x * 0.5 + 5.0 * unit, modal.size.y - 64.0 * unit), Vector2((modal.size.x - 58.0 * unit) * 0.5, 40.0 * unit))

func home_lobby_send_rect(viewport_size: Vector2) -> Rect2:
	var panel := home_social_panel_rect(viewport_size)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(panel.position + Vector2(panel.size.x - 96.0 * unit, panel.size.y - 52.0 * unit), Vector2(82.0 * unit, 36.0 * unit))

func ensure_home_connected() -> void:
	if app_screen != APP_HOME:
		return
	if multiplayer_state in ["connected", "connecting"]:
		return
	connect_multiplayer()

func park_line_edit(control: LineEdit) -> void:
	if control == null:
		return
	control.visible = false
	if control.has_focus():
		control.release_focus()
	control.position = Vector2(-4000.0, -4000.0)
	control.size = Vector2(1.0, 1.0)

func update_home_social_inputs() -> void:
	var viewport_size := get_viewport_rect().size
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var panel := home_social_panel_rect(viewport_size)
	var show_social_inputs := app_screen == APP_HOME and not tutorial_open and not customizer_open and not friend_customizer_open
	if friend_id_input != null:
		var show_friend_input := show_social_inputs and home_social_tab == 0
		if show_friend_input:
			friend_id_input.visible = true
			friend_id_input.position = home_add_friend_rect(viewport_size).position
			friend_id_input.size = home_add_friend_rect(viewport_size).size
			friend_id_input.placeholder_text = ui_text("friend_id_hint")
		else:
			park_line_edit(friend_id_input)
	if lobby_chat_input != null:
		var show_chat_input := show_social_inputs and home_social_tab == 1
		if show_chat_input:
			var input_rect := Rect2(panel.position + Vector2(14.0 * unit, panel.size.y - 52.0 * unit), Vector2(panel.size.x - 118.0 * unit, 36.0 * unit))
			lobby_chat_input.visible = true
			lobby_chat_input.position = input_rect.position
			lobby_chat_input.size = input_rect.size
			lobby_chat_input.placeholder_text = ui_text("lobby_chat_hint")
		else:
			park_line_edit(lobby_chat_input)

func send_lobby_chat_message() -> void:
	if lobby_chat_input == null:
		return
	var message := lobby_chat_input.text.strip_edges()
	if message.is_empty():
		return
	if multiplayer_state == "connected":
		send_multiplayer({"type": "lobby_chat", "name": profile_name, "message": message.left(80)})
	else:
		lobby_chat_messages.append({"name": profile_name, "message": message.left(80)})
		while lobby_chat_messages.size() > 30:
			lobby_chat_messages.pop_front()
	lobby_chat_input.clear()
	lobby_chat_input.grab_focus()
	queue_redraw()

func _on_lobby_chat_submitted(_text: String) -> void:
	send_lobby_chat_message()

func normalize_friend_public_id(raw: String) -> String:
	var clean := raw.strip_edges().to_upper().replace(" ", "")
	if clean.is_empty():
		return ""
	if not clean.begins_with("ZP-"):
		clean = "ZP-" + clean.trim_prefix("ZP")
	return clean.left(12)

func friend_already_added(public_id: String) -> bool:
	for entry in friends_list:
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == public_id:
			return true
	return false

func friend_display_name(entry: Dictionary) -> String:
	var pid := str(entry.get("id", ""))
	var name := str(entry.get("name", "")).strip_edges()
	if not name.is_empty() and name != pid and not name.begins_with("ZP-"):
		return name.left(20)
	for lb_entry in global_leaderboard:
		if typeof(lb_entry) == TYPE_DICTIONARY and str(lb_entry.get("publicId", "")) == pid:
			var lb_name := str(lb_entry.get("name", "")).strip_edges()
			if not lb_name.is_empty():
				return lb_name.left(20)
	return pid

func upsert_local_friend(entry: Dictionary) -> void:
	var pid := normalize_friend_public_id(str(entry.get("id", "")))
	if pid.is_empty():
		return
	var normalized := {
		"id": pid,
		"name": str(entry.get("name", "")).strip_edges().left(20),
		"rating": int(entry.get("rating", 1000)),
		"wins": int(entry.get("wins", 0)),
		"losses": int(entry.get("losses", 0)),
		"leagueTier": int(entry.get("leagueTier", 0)),
		"online": bool(entry.get("online", false))
	}
	normalized.name = friend_display_name(normalized)
	for i in friends_list.size():
		if str(friends_list[i].get("id", "")) == pid:
			friends_list[i] = normalized
			save_player_profile()
			queue_redraw()
			return
	friends_list.append(normalized)
	save_player_profile()
	queue_redraw()

func apply_friends_list_from_server(friends: Array) -> void:
	var merged: Array = []
	for item in friends:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var pid := normalize_friend_public_id(str(item.get("id", "")))
		if pid.is_empty():
			continue
		merged.append({
			"id": pid,
			"name": str(item.get("name", pid)).strip_edges().left(20),
			"rating": int(item.get("rating", 1000)),
			"wins": int(item.get("wins", 0)),
			"losses": int(item.get("losses", 0)),
			"leagueTier": int(item.get("leagueTier", 0)),
			"online": bool(item.get("online", false))
		})
	for i in merged.size():
		var entry: Dictionary = merged[i]
		if str(entry.get("name", "")).begins_with("ZP-"):
			entry.name = friend_display_name(entry)
	if merged.is_empty():
		# The match server keeps friends in memory; an empty response must not
		# wipe friends that are still saved locally on the device.
		return
	friends_list = merged
	save_player_profile()
	queue_redraw()

func refresh_friend_names_from_leaderboard() -> void:
	var changed := false
	for i in friends_list.size():
		var entry: Dictionary = friends_list[i]
		var display := friend_display_name(entry)
		if display != str(entry.get("name", "")):
			entry.name = display
			friends_list[i] = entry
			changed = true
	if changed:
		save_player_profile()

func friend_request_display_name(entry: Dictionary) -> String:
	var pid := str(entry.get("id", ""))
	var name := str(entry.get("name", "")).strip_edges()
	if not name.is_empty() and name != pid and not name.begins_with("ZP-"):
		return name.left(20)
	return friend_display_name(entry)

func apply_social_state_from_server(payload: Dictionary) -> void:
	apply_friends_list_from_server(payload.get("friends", []))
	incoming_friend_requests = []
	for item in payload.get("incoming", []):
		if typeof(item) == TYPE_DICTIONARY:
			incoming_friend_requests.append(item)
	outgoing_friend_requests = []
	for item in payload.get("outgoing", []):
		if typeof(item) == TYPE_DICTIONARY:
			outgoing_friend_requests.append(item)
	save_player_profile()
	queue_redraw()

func friend_request_already_sent(public_id: String) -> bool:
	for entry in outgoing_friend_requests:
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == public_id:
			return true
	return false

func send_friend_request_by_id(raw_id: String) -> void:
	var public_id := normalize_friend_public_id(raw_id)
	if public_id.length() < 5:
		show_menu_notice(ui_text("friend_not_found"))
		return
	if public_id == firebase_public_id:
		show_menu_notice(ui_text("friend_exists"))
		return
	if friend_already_added(public_id):
		show_menu_notice(ui_text("friend_exists"))
		return
	if friend_request_already_sent(public_id):
		show_menu_notice(ui_text("friend_request_exists"))
		return
	for entry in incoming_friend_requests:
		if str(entry.get("id", "")) == public_id:
			accept_friend_request_from(str(entry.get("id", "")))
			return
	if multiplayer_state == "connected" and not firebase_public_id.is_empty():
		send_multiplayer({
			"type": "send_friend_request",
			"fromPublicId": firebase_public_id,
			"targetPublicId": public_id,
			"fromName": profile_name,
			"rating": player_rating,
			"wins": player_wins,
			"losses": player_losses,
			"leagueTier": player_league_tier
		})
		if friend_id_input != null:
			friend_id_input.clear()
		return
	outgoing_friend_requests.append({"id": public_id, "name": public_id})
	save_player_profile()
	show_menu_notice(ui_text("friend_request_sent"))
	if friend_id_input != null:
		friend_id_input.clear()
	queue_redraw()

func accept_friend_request_from(from_public_id: String) -> void:
	var public_id := normalize_friend_public_id(from_public_id)
	if public_id.is_empty():
		return
	if multiplayer_state == "connected" and not firebase_public_id.is_empty():
		send_multiplayer({
			"type": "accept_friend_request",
			"publicId": firebase_public_id,
			"fromPublicId": public_id,
			"name": profile_name,
			"rating": player_rating,
			"wins": player_wins,
			"losses": player_losses,
			"leagueTier": player_league_tier
		})
		return
	for i in incoming_friend_requests.size():
		if str(incoming_friend_requests[i].get("id", "")) == public_id:
			upsert_local_friend(incoming_friend_requests[i])
			incoming_friend_requests.remove_at(i)
			break
	show_menu_notice(ui_text("friend_accepted"))
	queue_redraw()

func decline_friend_request_at(index: int) -> void:
	if index < 0 or index >= incoming_friend_requests.size():
		return
	var public_id := str(incoming_friend_requests[index].get("id", ""))
	incoming_friend_requests.remove_at(index)
	if multiplayer_state == "connected" and not firebase_public_id.is_empty() and not public_id.is_empty():
		send_multiplayer({
			"type": "decline_friend_request",
			"publicId": firebase_public_id,
			"fromPublicId": public_id
		})
	save_player_profile()
	queue_redraw()

func add_friend_by_public_id(raw_id: String) -> void:
	send_friend_request_by_id(raw_id)

func _on_friend_lookup_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var public_id := pending_friend_lookup_id
	pending_friend_lookup_id = ""
	if public_id.is_empty():
		return
	var friend_name := public_id
	if response_code >= 200 and response_code < 300:
		var data: Variant = JSON.parse_string(body.get_string_from_utf8())
		if data is Dictionary:
			var fields: Dictionary = data.get("fields", {})
			if fields.has("name"):
				friend_name = str(fields.name.get("stringValue", friend_name)).strip_edges().left(20)
	if response_code == 404:
		show_menu_notice(ui_text("friend_not_found"))
		queue_redraw()
		return
	if friend_already_added(public_id):
		show_menu_notice(ui_text("friend_exists"))
		return
	upsert_local_friend({
		"id": public_id,
		"name": friend_name,
		"rating": 1000,
		"wins": 0,
		"losses": 0,
		"leagueTier": 0,
		"online": false
	})
	show_menu_notice(ui_text("friend_added"))
	if friend_id_input != null:
		friend_id_input.clear()
	queue_redraw()

func remove_friend_at(index: int) -> void:
	if index < 0 or index >= friends_list.size():
		return
	var target_id := str(friends_list[index].get("id", ""))
	friends_list.remove_at(index)
	if home_friend_profile_index == index:
		home_friend_profile_index = -1
	elif home_friend_profile_index > index:
		home_friend_profile_index -= 1
	save_player_profile()
	if multiplayer_state == "connected" and not target_id.is_empty() and not firebase_public_id.is_empty():
		send_multiplayer({
			"type": "remove_friend",
			"fromPublicId": firebase_public_id,
			"targetPublicId": target_id
		})
	queue_redraw()

func maybe_send_pending_friend_invite() -> void:
	if pending_friend_invite_send.is_empty():
		return
	if multiplayer_state != "connected":
		connect_multiplayer()
		return
	if multiplayer_room_code.is_empty():
		create_multiplayer_room()
		return
	flush_pending_friend_invite_send()

func flush_pending_friend_invite_send() -> void:
	if pending_friend_invite_send.is_empty():
		return
	if multiplayer_state != "connected" or multiplayer_room_code.is_empty():
		return
	var target_id := normalize_friend_public_id(str(pending_friend_invite_send.get("targetPublicId", "")))
	if target_id.is_empty():
		pending_friend_invite_send = {}
		return
	pending_friend_invite_target_name = str(pending_friend_invite_send.get("targetName", ""))
	pending_friend_invite_send = {}
	send_multiplayer({
		"type": "invite_friend",
		"targetPublicId": target_id,
		"roomCode": multiplayer_room_code,
		"fromName": profile_name,
		"fromPublicId": firebase_public_id
	})

func invite_friend_to_play(index: int) -> void:
	if index < 0 or index >= friends_list.size():
		return
	var friend_entry: Dictionary = friends_list[index]
	if not bool(friend_entry.get("online", false)):
		show_menu_notice(ui_text("friend_invite_offline"))
		return
	play_sound("ui")
	var target_id := normalize_friend_public_id(str(friend_entry.get("id", "")))
	if target_id.is_empty():
		return
	pending_friend_invite_send = {
		"targetPublicId": target_id,
		"targetName": str(friend_entry.get("name", ""))
	}
	app_screen = APP_FRIEND
	maybe_send_pending_friend_invite()

func character_card_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var card_width := minf(158.0, (viewport_size.x / unit - 30.0 - 12.0 * float(ANIMAL_NAMES.size() - 1)) / float(ANIMAL_NAMES.size()))
	var card_size := Vector2(card_width, 150.0) * unit
	var gap := 12.0 * unit
	var total_width := card_size.x * float(ANIMAL_NAMES.size()) + gap * float(ANIMAL_NAMES.size() - 1)
	var start_x := (viewport_size.x - total_width) * 0.5
	return Rect2(Vector2(start_x + float(index) * (card_size.x + gap), viewport_size.y - 174.0 * unit), card_size)

func character_ring_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var size := Vector2(140.0, 78.0) * unit
	var column := index % 4
	var row := index / 4
	return Rect2(Vector2((590.0 + float(column) * 151.0) * unit, (246.0 + float(row) * 94.0) * unit), size)

func frontend_back_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(24.0, 22.0, 116.0, 48.0)

func friend_create_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(250.0, 245.0) * unit, Vector2(330.0, 82.0) * unit)

func friend_join_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(700.0, 355.0) * unit, Vector2(330.0, 72.0) * unit)

func friend_ready_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(475.0, 570.0) * unit, Vector2(330.0, 72.0) * unit)

func friend_share_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(840.0, 250.0) * unit, Vector2(205.0, 62.0) * unit)

func friend_player_rect(slot: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((210.0 + float(slot) * 500.0) * unit, 345.0 * unit), Vector2(360.0, 165.0) * unit)

func friend_edit_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var card := friend_player_rect(multiplayer_slot if multiplayer_slot >= 0 else 0, viewport_size)
	return Rect2(card.position + Vector2(card.size.x - 125.0 * unit, card.size.y - 44.0 * unit), Vector2(112.0, 34.0) * unit)

func friend_choice_rect(index: int, colors: bool, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((318.0 + float(index) * 110.0) * unit, (330.0 if colors else 220.0) * unit), Vector2(92.0, 92.0) * unit)

func friend_board_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var gap := 12.0 * unit
	var card_w := minf(158.0 * unit, (viewport_size.x - 90.0 * unit - gap * float(BOARD_THEME_COUNT - 1)) / float(BOARD_THEME_COUNT))
	var total_w := card_w * float(BOARD_THEME_COUNT) + gap * float(BOARD_THEME_COUNT - 1)
	var start_x := (viewport_size.x - total_w) * 0.5
	return Rect2(Vector2(start_x + float(index) * (card_w + gap), 418.0 * unit), Vector2(card_w, 82.0 * unit))

func friend_modal_close_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(935.0, 155.0) * unit, Vector2(65.0, 48.0) * unit)

func _on_room_code_changed(value: String) -> void:
	var clean := ""
	for character in value.to_upper():
		if "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".contains(character):
			clean += character
	if clean != value:
		room_code_input.text = clean.left(4)
		room_code_input.caret_column = room_code_input.text.length()

func sync_web_auth_storage() -> void:
	if not OS.has_feature("web"):
		return
	var saved_refresh := str(JavaScriptBridge.eval("localStorage.getItem('zpFirebaseRefreshToken') || ''", true))
	if not saved_refresh.is_empty():
		firebase_refresh_token = saved_refresh
	var saved_provider := str(JavaScriptBridge.eval("localStorage.getItem('zpFirebaseProvider') || ''", true))
	if not saved_provider.is_empty():
		firebase_provider = saved_provider

func persist_web_auth_storage() -> void:
	if not OS.has_feature("web"):
		return
	var script := """
localStorage.setItem('zpFirebaseRefreshToken', __REFRESH__);
localStorage.setItem('zpFirebaseProvider', __PROVIDER__);
"""
	script = script.replace("__REFRESH__", JSON.stringify(firebase_refresh_token)).replace("__PROVIDER__", JSON.stringify(firebase_provider))
	JavaScriptBridge.eval(script, true)

func clear_saved_auth_session() -> void:
	firebase_uid = ""
	firebase_public_id = ""
	firebase_id_token = ""
	firebase_refresh_token = ""
	firebase_token_expires_at = 0
	firebase_email = ""
	firebase_provider = "guest"
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('zpFirebaseRefreshToken'); localStorage.removeItem('zpFirebaseProvider');", true)
	save_player_profile(false)

func auth_token_is_unrecoverable(message: String) -> bool:
	var upper := message.to_upper()
	return upper.contains("INVALID_REFRESH_TOKEN") or upper.contains("USER_DISABLED") or upper.contains("USER_NOT_FOUND") or upper.contains("INVALID_GRANT")

func begin_silent_session_restore() -> void:
	session_restore_pending = false
	app_screen = APP_HOME
	firebase_auth_mode = "resume"
	firebase_status = ui_text("restoring_session")
	start_firebase_auth()

func initialize_saved_session() -> void:
	if OS.has_feature("web"):
		var shared_value: String = str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('room') || ''", true))
		for character in shared_value.to_upper():
			if "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".contains(character):
				pending_shared_room_code += character
		pending_shared_room_code = pending_shared_room_code.left(4)
		var handoff_value: String = str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('androidAuth') || ''", true))
		for character in handoff_value.to_lower():
			if "0123456789abcdef".contains(character):
				pending_android_auth_handoff += character
		pending_android_auth_handoff = pending_android_auth_handoff.left(64)
	sync_web_auth_storage()
	if firebase_refresh_token.is_empty():
		if OS.has_feature("web"):
			session_restore_pending = true
			session_restore_deadline = menu_elapsed + SESSION_RESTORE_WAIT_SEC
			firebase_status = ui_text("restoring_session")
		return
	begin_silent_session_restore()

func open_pending_shared_room() -> void:
	if pending_shared_room_code.is_empty() or room_code_input == null:
		return
	app_screen = APP_FRIEND
	room_code_input.text = pending_shared_room_code
	connect_multiplayer()
	if multiplayer_state == "connected":
		var shared_code: String = pending_shared_room_code
		pending_shared_room_code = ""
		room_code_input.text = shared_code
		join_multiplayer_room()

func share_friend_room() -> void:
	if multiplayer_room_code.is_empty():
		return
	if OS.has_feature("web"):
		var share_text: String = "בואו לשחק איתי Zoopaloola!" if ui_language == "he" else "Join my Zoopaloola game!"
		var script := """
(() => {
  const url = new URL(window.location.href);
  url.searchParams.set('room', __ROOM__);
  const data = {title: 'Zoopaloola', text: __TEXT__, url: url.toString()};
  if (navigator.share) navigator.share(data).catch(() => {});
  else if (navigator.clipboard) navigator.clipboard.writeText(data.text + ' ' + data.url);
})();
"""
		script = script.replace("__ROOM__", JSON.stringify(multiplayer_room_code)).replace("__TEXT__", JSON.stringify(share_text))
		JavaScriptBridge.eval(script, true)
		show_menu_notice("נפתח תפריט השיתוף" if ui_language == "he" else "SHARE MENU OPENED")
	else:
		DisplayServer.clipboard_set(multiplayer_room_code)
		show_menu_notice("קוד החדר הועתק" if ui_language == "he" else "ROOM CODE COPIED")

func update_room_code_input() -> void:
	if room_code_input == null:
		return
	var show_input := app_screen == APP_FRIEND and multiplayer_room_code.is_empty()
	room_code_input.visible = show_input
	if show_input:
		var viewport_size := get_viewport_rect().size
		var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
		room_code_input.position = Vector2(700.0, 260.0) * unit
		room_code_input.size = Vector2(330.0, 72.0) * unit

func team_ring_color_index(team: int) -> int:
	if game_mode == "online" and team >= 0 and team < multiplayer_players.size():
		return int(multiplayer_players[team].get("ringColor", 0))
	return player_ring_color if team == 0 else ai_ring_color

func teams_share_ring_color() -> bool:
	return team_ring_color_index(0) == team_ring_color_index(1)

func team_marker_color(team: int) -> Color:
	return Color("ffd447") if team == 0 else Color("4ad9ff")

func active_board_theme() -> int:
	if game_mode == "online":
		return match_board_theme
	return selected_board_theme

func is_friend_room_host() -> bool:
	return multiplayer_slot == 0

func sync_match_board_from_payload(payload: Dictionary) -> void:
	if not payload.has("boardTheme"):
		return
	var theme := clampi(int(payload.boardTheme), 0, BOARD_THEME_COUNT - 1)
	room_board_theme = theme
	match_board_theme = theme
	if multiplayer_slot == 0:
		selected_board_theme = theme

func update_match_board(theme_index: int) -> void:
	if multiplayer_slot != 0:
		show_menu_notice(ui_text("guest_board_locked"))
		return
	var theme := clampi(theme_index, 0, BOARD_THEME_COUNT - 1)
	selected_board_theme = theme
	room_board_theme = theme
	match_board_theme = theme
	save_player_profile()
	send_multiplayer({"type": "update_profile", "boardTheme": theme})
	play_sound("ui")
	queue_redraw()

func arena_board_theme_for_level(arena_index: int) -> int:
	return ARENA_BOARD_THEMES[clampi(arena_index, 0, ARENA_BOARD_THEMES.size() - 1)]

func initialize_owned_collections() -> void:
	owned_animals.clear()
	owned_rings.clear()
	for i in ANIMAL_NAMES.size():
		owned_animals.append(animal_unlock_price(i) <= 0)
	for i in RING_COLORS.size():
		owned_rings.append(ring_unlock_price(i) <= 0)

func is_animal_unlocked(index: int) -> bool:
	var i := clampi(index, 0, ANIMAL_NAMES.size() - 1)
	return i < owned_animals.size() and bool(owned_animals[i])

func is_ring_unlocked(index: int) -> bool:
	var i := clampi(index, 0, RING_COLORS.size() - 1)
	return i < owned_rings.size() and bool(owned_rings[i])

func animal_unlock_price(index: int) -> int:
	var i := clampi(index, 0, ANIMAL_UNLOCK_PRICES.size() - 1)
	if i < FREE_UNLOCK_COUNT:
		return 0
	return ANIMAL_UNLOCK_PRICES[i]

func ring_unlock_price(index: int) -> int:
	var i := clampi(index, 0, RING_UNLOCK_PRICES.size() - 1)
	if i < FREE_UNLOCK_COUNT:
		return 0
	return RING_UNLOCK_PRICES[i]

func first_unlocked_animal() -> int:
	for i in ANIMAL_NAMES.size():
		if is_animal_unlocked(i):
			return i
	return 0

func first_unlocked_ring() -> int:
	for i in RING_COLORS.size():
		if is_ring_unlocked(i):
			return i
	return 0

func ensure_valid_loadout() -> void:
	if not is_animal_unlocked(player_animal):
		player_animal = first_unlocked_animal()
	if not is_ring_unlocked(player_ring_color):
		player_ring_color = first_unlocked_ring()
	rebuild_team_piece_textures()

func load_owned_collections(config: ConfigFile) -> void:
	initialize_owned_collections()
	var saved_animals: Variant = config.get_value("player", "owned_animals", [])
	var saved_rings: Variant = config.get_value("player", "owned_rings", [])
	if typeof(saved_animals) == TYPE_ARRAY:
		for i in mini(saved_animals.size(), owned_animals.size()):
			owned_animals[i] = bool(saved_animals[i]) or animal_unlock_price(i) <= 0
	if typeof(saved_rings) == TYPE_ARRAY:
		for i in mini(saved_rings.size(), owned_rings.size()):
			owned_rings[i] = bool(saved_rings[i]) or ring_unlock_price(i) <= 0

func apply_economy_migration(config: ConfigFile) -> void:
	var saved_version := int(config.get_value("player", "economy_version", 0))
	if saved_version >= ECONOMY_VERSION:
		return
	player_coins = 0
	initialize_owned_collections()
	ensure_valid_loadout()
	config.set_value("player", "economy_version", ECONOMY_VERSION)
	config.set_value("player", "coins", player_coins)
	config.set_value("player", "owned_animals", owned_animals)
	config.set_value("player", "owned_rings", owned_rings)
	config.save(PLAYER_PROFILE_PATH)

func try_select_animal(index: int) -> bool:
	var i := clampi(index, 0, ANIMAL_NAMES.size() - 1)
	if not is_animal_unlocked(i):
		show_menu_notice(ui_text("unlock_in_shop"))
		return false
	player_animal = i
	rebuild_team_piece_textures()
	save_player_profile()
	return true

func try_select_ring(index: int) -> bool:
	var i := clampi(index, 0, RING_COLORS.size() - 1)
	if not is_ring_unlocked(i):
		show_menu_notice(ui_text("unlock_in_shop"))
		return false
	player_ring_color = i
	rebuild_team_piece_textures()
	save_player_profile()
	return true

func try_purchase_animal(index: int) -> bool:
	var i := clampi(index, 0, ANIMAL_NAMES.size() - 1)
	if is_animal_unlocked(i):
		return try_select_animal(i)
	var price := animal_unlock_price(i)
	if price <= 0:
		return try_select_animal(i)
	if player_coins < price:
		show_menu_notice(ui_text("not_enough_coins"))
		return false
	player_coins -= price
	owned_animals[i] = true
	player_animal = i
	rebuild_team_piece_textures()
	save_player_profile()
	show_menu_notice(ui_text("purchase_success"))
	play_sound("ui")
	return true

func try_purchase_ring(index: int) -> bool:
	var i := clampi(index, 0, RING_COLORS.size() - 1)
	if is_ring_unlocked(i):
		return try_select_ring(i)
	var price := ring_unlock_price(i)
	if price <= 0:
		return try_select_ring(i)
	if player_coins < price:
		show_menu_notice(ui_text("not_enough_coins"))
		return false
	player_coins -= price
	owned_rings[i] = true
	player_ring_color = i
	rebuild_team_piece_textures()
	save_player_profile()
	show_menu_notice(ui_text("purchase_success"))
	play_sound("ui")
	return true

func collection_item_price_label(index: int, is_ring: bool) -> String:
	if is_ring:
		if is_ring_unlocked(index):
			return ui_text("owned_item")
		var price := ring_unlock_price(index)
		return ui_text("free_item") if price <= 0 else str(price) + ui_text("coins")
	if is_animal_unlocked(index):
		return ui_text("owned_item")
	var animal_price := animal_unlock_price(index)
	return ui_text("free_item") if animal_price <= 0 else str(animal_price) + ui_text("coins")

func draw_collection_lock_overlay(rect: Rect2, index: int, is_ring: bool, unit: float) -> void:
	var unlocked := is_ring_unlocked(index) if is_ring else is_animal_unlocked(index)
	if unlocked:
		return
	draw_rect(rect, Color(0.01, 0.03, 0.08, 0.58))
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y * 0.42), "🔒", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(20.0 * unit), Color.WHITE)
	var price_text := collection_item_price_label(index, is_ring)
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y * 0.68), price_text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(11.0 * unit), Color("ffe25d"))

func load_player_profile() -> void:
	var config := ConfigFile.new()
	initialize_owned_collections()
	if config.load(PLAYER_PROFILE_PATH) != OK:
		ensure_valid_loadout()
		return
	profile_name = str(config.get_value("player", "name", profile_name)).strip_edges().left(20)
	if profile_name.is_empty():
		profile_name = "PLAYER 1"
	player_animal = clampi(int(config.get_value("player", "animal", player_animal)), 0, ANIMAL_NAMES.size() - 1)
	player_ring_color = clampi(int(config.get_value("player", "ring_color", player_ring_color)), 0, RING_COLORS.size() - 1)
	player_coins = maxi(0, int(config.get_value("player", "coins", player_coins)))
	player_level = clampi(int(config.get_value("player", "level", player_level)), 1, 999)
	player_xp = maxi(0, int(config.get_value("player", "xp", player_xp)))
	player_wins = maxi(0, int(config.get_value("player", "wins", player_wins)))
	player_losses = maxi(0, int(config.get_value("player", "losses", player_losses)))
	player_best_streak = maxi(0, int(config.get_value("player", "best_streak", player_best_streak)))
	player_current_streak = maxi(0, int(config.get_value("player", "current_streak", player_current_streak)))
	player_rating = clampi(int(config.get_value("player", "rating", player_rating)), 100, 9999)
	player_league_tier = clampi(int(config.get_value("player", "league_tier", player_league_tier)), 0, LEAGUE_NAME_KEYS.size() - 1)
	sound_enabled = bool(config.get_value("settings", "sound_enabled", sound_enabled))
	tutorial_completed = bool(config.get_value("settings", "tutorial_completed", tutorial_completed))
	computer_difficulty = clampi(int(config.get_value("settings", "computer_difficulty", computer_difficulty)), 0, 2)
	selected_board_theme = clampi(int(config.get_value("settings", "board_theme", selected_board_theme)), 0, BOARD_THEME_COUNT - 1)
	last_daily_claim = str(config.get_value("player", "last_daily_claim", last_daily_claim))
	ui_language = str(config.get_value("settings", "language", ui_language))
	friends_list = config.get_value("social", "friends", [])
	if typeof(friends_list) != TYPE_ARRAY:
		friends_list = []
	incoming_friend_requests = config.get_value("social", "incoming_requests", [])
	if typeof(incoming_friend_requests) != TYPE_ARRAY:
		incoming_friend_requests = []
	outgoing_friend_requests = config.get_value("social", "outgoing_requests", [])
	if typeof(outgoing_friend_requests) != TYPE_ARRAY:
		outgoing_friend_requests = []
	update_player_league_tier()
	firebase_uid = str(config.get_value("firebase", "uid", ""))
	firebase_public_id = str(config.get_value("firebase", "public_id", ""))
	firebase_id_token = str(config.get_value("firebase", "id_token", ""))
	firebase_refresh_token = str(config.get_value("firebase", "refresh_token", ""))
	firebase_token_expires_at = int(config.get_value("firebase", "expires_at", 0))
	firebase_provider = str(config.get_value("firebase", "provider", firebase_provider))
	firebase_email = str(config.get_value("firebase", "email", firebase_email))
	load_owned_collections(config)
	apply_economy_migration(config)
	ensure_valid_loadout()

func save_player_profile(sync_cloud: bool = true) -> void:
	var config := ConfigFile.new()
	config.set_value("player", "name", profile_name)
	config.set_value("player", "animal", player_animal)
	config.set_value("player", "ring_color", player_ring_color)
	config.set_value("player", "coins", player_coins)
	config.set_value("player", "economy_version", ECONOMY_VERSION)
	config.set_value("player", "owned_animals", owned_animals)
	config.set_value("player", "owned_rings", owned_rings)
	config.set_value("player", "level", player_level)
	config.set_value("player", "xp", player_xp)
	config.set_value("player", "wins", player_wins)
	config.set_value("player", "losses", player_losses)
	config.set_value("player", "best_streak", player_best_streak)
	config.set_value("player", "current_streak", player_current_streak)
	config.set_value("player", "rating", player_rating)
	config.set_value("player", "league_tier", player_league_tier)
	config.set_value("player", "last_daily_claim", last_daily_claim)
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "tutorial_completed", tutorial_completed)
	config.set_value("settings", "computer_difficulty", computer_difficulty)
	config.set_value("settings", "board_theme", selected_board_theme)
	config.set_value("settings", "language", ui_language)
	config.set_value("social", "friends", friends_list)
	config.set_value("social", "incoming_requests", incoming_friend_requests)
	config.set_value("social", "outgoing_requests", outgoing_friend_requests)
	config.set_value("firebase", "uid", firebase_uid)
	config.set_value("firebase", "public_id", firebase_public_id)
	config.set_value("firebase", "id_token", firebase_id_token)
	config.set_value("firebase", "refresh_token", firebase_refresh_token)
	config.set_value("firebase", "expires_at", firebase_token_expires_at)
	config.set_value("firebase", "provider", firebase_provider)
	config.set_value("firebase", "email", firebase_email)
	config.save(PLAYER_PROFILE_PATH)
	if sync_cloud and not firebase_uid.is_empty():
		firebase_profile_dirty = true
		firebase_sync_delay = 0.8

func setup_firebase() -> void:
	firebase_auth_request = HTTPRequest.new()
	firebase_auth_request.request_completed.connect(_on_firebase_auth_completed)
	add_child(firebase_auth_request)
	firebase_profile_request = HTTPRequest.new()
	firebase_profile_request.request_completed.connect(_on_firebase_profile_completed)
	add_child(firebase_profile_request)
	firebase_public_id_request = HTTPRequest.new()
	firebase_public_id_request.request_completed.connect(_on_firebase_public_id_completed)
	add_child(firebase_public_id_request)
	firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
	if OS.has_feature("web"):
		setup_firebase_google_web()

func start_firebase_auth() -> void:
	if firebase_auth_busy or firebase_auth_request == null:
		return
	firebase_auth_busy = true
	firebase_status = "מתחבר..." if ui_language == "he" else "CONNECTING..."
	if OS.has_feature("web"):
		start_firebase_web_auth()
		return
	var error := OK
	if not firebase_refresh_token.is_empty():
		var refresh_url := "https://securetoken.googleapis.com/v1/token?key=" + FIREBASE_API_KEY
		var refresh_body := "grant_type=refresh_token&refresh_token=" + firebase_refresh_token.uri_encode()
		error = firebase_auth_request.request(refresh_url, ["Content-Type: application/x-www-form-urlencoded", "Accept: application/json"], HTTPClient.METHOD_POST, refresh_body)
	else:
		var signup_url := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_API_KEY
		error = firebase_auth_request.request(signup_url, ["Content-Type: application/json", "Accept: application/json"], HTTPClient.METHOD_POST, "{\"returnSecureToken\":true}")
	if error != OK:
		firebase_auth_busy = false
		firebase_status = "אין חיבור לענן" if ui_language == "he" else "CLOUD OFFLINE"

func begin_guest_sign_in() -> void:
	if not firebase_refresh_token.is_empty():
		firebase_auth_mode = "resume"
		firebase_status = ui_text("restoring_session")
		start_firebase_auth()
		return
	firebase_auth_mode = "guest"
	firebase_provider = "guest"
	firebase_email = ""
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('zpFirebaseRefreshToken'); localStorage.removeItem('zpFirebaseProvider');", true)
	firebase_uid = ""
	firebase_public_id = ""
	firebase_id_token = ""
	firebase_refresh_token = ""
	firebase_token_expires_at = 0
	profile_name = ("אורח-" if ui_language == "he" else "Guest-") + str(randi_range(1000, 9999))
	if profile_name_input != null:
		profile_name_input.text = profile_name
	start_firebase_auth()

func start_email_auth(register_account: bool) -> void:
	if firebase_auth_busy or auth_email_input == null or auth_password_input == null:
		return
	var email := auth_email_input.text.strip_edges()
	var password := auth_password_input.text
	if not email.contains("@"):
		firebase_status = "יש להזין כתובת מייל תקינה" if ui_language == "he" else "ENTER A VALID EMAIL"
		return
	if password.length() < 6:
		firebase_status = "הסיסמה חייבת להכיל לפחות 6 תווים" if ui_language == "he" else "PASSWORD MUST HAVE 6 CHARACTERS"
		return
	firebase_auth_busy = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.zpManualAuth = 'active';", true)
	firebase_auth_mode = "register" if register_account else "email"
	firebase_status = "יוצר חשבון..." if register_account else "מתחבר..."
	var action := "signUp" if register_account else "signInWithPassword"
	var url := "https://identitytoolkit.googleapis.com/v1/accounts:%s?key=%s" % [action, FIREBASE_API_KEY]
	var payload := JSON.stringify({"email": email, "password": password, "returnSecureToken": true})
	if OS.has_feature("web"):
		var script := """
window.zpAuthState = {status: 'loading'};
(async () => {
  try {
    const response = await fetch(__URL__, {method:'POST', mode:'cors', credentials:'omit', headers:{'Content-Type':'application/json'}, body:__BODY__});
    const data = await response.json();
    if (!response.ok) throw new Error((data.error && data.error.message) || ('HTTP ' + response.status));
    localStorage.setItem('zpFirebaseRefreshToken', data.refreshToken || '');
    localStorage.setItem('zpFirebaseProvider', 'email');
    window.zpAuthState = {status:'done', localId:data.localId, idToken:data.idToken, refreshToken:data.refreshToken, expiresIn:data.expiresIn || '3600', provider:'email', email:data.email || __EMAIL__};
  } catch (error) { window.zpAuthState = {status:'error', message:String(error && error.message || error)}; }
})();
"""
		script = script.replace("__URL__", JSON.stringify(url)).replace("__BODY__", JSON.stringify(payload)).replace("__EMAIL__", JSON.stringify(email))
		JavaScriptBridge.eval(script, true)
		firebase_web_poll_delay = 0.15
	else:
		var error := firebase_auth_request.request(url, ["Content-Type: application/json", "Accept: application/json"], HTTPClient.METHOD_POST, payload)
		if error != OK:
			firebase_auth_busy = false
			firebase_status = "אין חיבור לענן" if ui_language == "he" else "CLOUD OFFLINE"

func _on_auth_password_submitted(_value: String) -> void:
	start_email_auth(auth_email_mode == "register")

func start_firebase_web_auth() -> void:
	var script := """
window.zpAuthState = {status: 'loading'};
(async () => {
  try {
    const key = '__API_KEY__';
    const savedRefresh = __USE_REFRESH__ ? (localStorage.getItem('zpFirebaseRefreshToken') || '') : '';
    let response;
    if (savedRefresh) {
      response = await fetch('https://securetoken.googleapis.com/v1/token?key=' + key, {
        method: 'POST', mode: 'cors', credentials: 'omit',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=refresh_token&refresh_token=' + encodeURIComponent(savedRefresh)
      });
    } else {
      response = await fetch('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=' + key, {
        method: 'POST', mode: 'cors', credentials: 'omit',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({returnSecureToken: true})
      });
    }
    const data = await response.json();
    if (!response.ok) throw new Error((data.error && data.error.message) || ('HTTP ' + response.status));
    const refreshToken = data.refreshToken || data.refresh_token || savedRefresh;
    localStorage.setItem('zpFirebaseRefreshToken', refreshToken);
    if (!savedRefresh) {
      localStorage.setItem('zpFirebaseProvider', 'guest');
    }
    window.zpAuthState = {
      status: 'done', localId: data.localId || data.user_id,
      idToken: data.idToken || data.id_token, refreshToken: refreshToken,
      expiresIn: data.expiresIn || data.expires_in || '3600'
    };
  } catch (error) {
    window.zpAuthState = {status: 'error', message: String(error && error.message || error)};
  }
})();
""".replace("__API_KEY__", FIREBASE_API_KEY).replace("__USE_REFRESH__", "true" if firebase_auth_mode != "guest" else "false")
	JavaScriptBridge.eval(script, true)
	firebase_web_poll_delay = 0.15

func setup_firebase_google_web() -> void:
	var script := """
    window.zpGoogleState = {status: 'loading-sdk'};
    window.zpManualAuth = 'idle';
(async () => {
  try {
    const appSdk = await import('https://www.gstatic.com/firebasejs/12.17.1/firebase-app.js');
    const authSdk = await import('https://www.gstatic.com/firebasejs/12.17.1/firebase-auth.js');
    const config = {
      apiKey: '__API_KEY__', authDomain: 'zoopaloola-online.firebaseapp.com',
      projectId: 'zoopaloola-online', storageBucket: 'zoopaloola-online.firebasestorage.app',
      messagingSenderId: '386401966312', appId: '1:386401966312:web:0e781cb13c98fd6dc3515d'
    };
    const app = appSdk.getApps().length ? appSdk.getApps()[0] : appSdk.initializeApp(config);
    const auth = authSdk.getAuth(app);
    await authSdk.setPersistence(auth, authSdk.browserLocalPersistence);
    const provider = new authSdk.GoogleAuthProvider();
    const resolveProvider = (user) => {
      if (!user) return 'guest';
      if (user.isAnonymous) return 'guest';
      const providerId = (user.providerData && user.providerData[0] && user.providerData[0].providerId) || '';
      if (providerId === 'google.com') return 'google';
      if (providerId === 'password') return 'email';
      return 'google';
    };
    authSdk.onAuthStateChanged(auth, async (user) => {
      if (!user) {
        window.zpSessionRestoreChecked = true;
        return;
      }
      if (window.zpManualAuth === 'active') return;
      try {
        const idToken = await user.getIdToken();
        const refreshToken = user.refreshToken || '';
        const provider = resolveProvider(user);
        localStorage.setItem('zpFirebaseRefreshToken', refreshToken);
        localStorage.setItem('zpFirebaseProvider', provider);
        window.zpAuthState = {
          status: 'done', localId: user.uid, idToken: idToken,
          refreshToken: refreshToken, expiresIn: '3600',
          provider: provider, email: user.email || '',
          displayName: user.displayName || ''
        };
      } catch (error) {
        window.zpAuthState = {status: 'error', message: String(error && (error.code || error.message) || error)};
      } finally {
        window.zpSessionRestoreChecked = true;
      }
    });
    window.zpBeginGoogleLink = (oldToken, publicUrl, playerName) => {
      window.zpManualAuth = 'active';
      window.zpGoogleState = {status: 'opening'};
      authSdk.signInWithPopup(auth, provider).then(async (result) => {
        const user = result.user;
        const idToken = await user.getIdToken(true);
        localStorage.setItem('zpFirebaseRefreshToken', user.refreshToken || '');
        localStorage.setItem('zpFirebaseProvider', 'google');
        window.zpGoogleState = {
          status: 'done', localId: user.uid, idToken: idToken,
          refreshToken: user.refreshToken || '', expiresIn: '3600',
          provider: 'google', email: user.email || '', displayName: user.displayName || ''
        };
      }).catch((error) => {
        window.zpGoogleState = {status: 'error', message: String(error && (error.code || error.message) || error)};
      }).finally(() => {
        window.zpManualAuth = 'idle';
      });
    };
    window.zpGoogleState = {status: 'ready'};
  } catch (error) {
    window.zpGoogleState = {status: 'error', message: String(error && error.message || error)};
  }
})();
""".replace("__API_KEY__", FIREBASE_API_KEY)
	JavaScriptBridge.eval(script, true)

func begin_google_sign_in() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.zpManualAuth = 'active';", true)
	if OS.has_feature("android"):
		firebase_status = "פותח כניסה מאובטחת ל-Google..." if ui_language == "he" else "OPENING SECURE GOOGLE SIGN-IN..."
		pending_google_handoff_request = true
		connect_multiplayer()
		if multiplayer_state == "connected":
			send_multiplayer({"type":"create_auth_handoff"})
			pending_google_handoff_request = false
		queue_redraw()
		return
	if not OS.has_feature("web"):
		show_menu_notice("Google login is unavailable on this device")
		return
	var public_url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/publicIds/%s" % [FIREBASE_PROJECT_ID, firebase_public_id]
	var call_script := "window.zpBeginGoogleLink && window.zpBeginGoogleLink(%s, %s, %s)" % [JSON.stringify(firebase_id_token), JSON.stringify(public_url), JSON.stringify(profile_name)]
	JavaScriptBridge.eval(call_script, true)
	firebase_status = "פותח Google..." if ui_language == "he" else "OPENING GOOGLE..."
	queue_redraw()

func _on_firebase_auth_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	firebase_auth_busy = false
	if response_code < 200 or response_code >= 300:
		firebase_status = "אין חיבור לענן" if ui_language == "he" else "CLOUD OFFLINE"
		if firebase_auth_mode == "resume" and response_code >= 400 and response_code < 500:
			clear_saved_auth_session()
			app_screen = APP_AUTH
			firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
		return
	var response_text := body.get_string_from_utf8().strip_edges()
	var json := JSON.new()
	var parse_error := json.parse(response_text)
	if parse_error != OK or typeof(json.data) != TYPE_DICTIONARY:
		var diagnostic := response_text.left(32).replace("\n", " ")
		firebase_status = (("שגיאת חשבון: " if ui_language == "he" else "ACCOUNT ERROR: ") + diagnostic).strip_edges()
		push_error("Firebase auth response could not be parsed (HTTP %d): %s" % [response_code, response_text.left(240)])
		queue_redraw()
		return
	var response: Dictionary = json.data
	apply_firebase_auth_response(response)

func apply_firebase_auth_response(response: Dictionary) -> void:
	firebase_auth_busy = false
	session_restore_pending = false
	var previous_uid := firebase_uid
	firebase_uid = str(response.get("localId", response.get("user_id", firebase_uid)))
	if response.has("provider"):
		firebase_provider = str(response.provider)
	if response.has("email"):
		firebase_email = str(response.email)
	elif firebase_auth_mode == "email" or firebase_auth_mode == "register":
		firebase_provider = "email"
		firebase_email = auth_email_input.text.strip_edges() if auth_email_input != null else ""
	elif firebase_auth_mode == "guest" or firebase_auth_mode == "guest_resume":
		firebase_provider = "guest"
		firebase_email = ""
	firebase_id_token = str(response.get("idToken", response.get("id_token", "")))
	firebase_refresh_token = str(response.get("refreshToken", response.get("refresh_token", firebase_refresh_token)))
	persist_web_auth_storage()
	var expires_in := int(str(response.get("expiresIn", response.get("expires_in", "3600"))))
	firebase_token_expires_at = int(Time.get_unix_time_from_system()) + maxi(60, expires_in)
	if not firebase_uid.is_empty():
		# The public ID is deterministic per Firebase user. This also repairs older
		# profiles whose anonymous ID was carried into a Google account and caused
		# Firestore ownership rules to return HTTP 403.
		var expected_public_id := "ZP-" + firebase_uid.sha256_text().substr(0, 8).to_upper()
		if firebase_public_id != expected_public_id or previous_uid != firebase_uid:
			firebase_public_id = expected_public_id
	save_player_profile(false)
	firebase_status = "מסונכרן" if ui_language == "he" else "SYNCED"
	sync_firebase_profile()
	sync_firebase_public_id()
	if app_screen == APP_AUTH:
		auth_email_mode = ""
		app_screen = APP_HOME
	maybe_start_tutorial()
	if not pending_shared_room_code.is_empty():
		open_pending_shared_room()
	if OS.has_feature("web") and not pending_android_auth_handoff.is_empty() and firebase_provider == "google":
		pending_auth_handoff_payload = {
			"type":"complete_auth_handoff",
			"handoffToken":pending_android_auth_handoff,
			"localId":firebase_uid,
			"idToken":firebase_id_token,
			"refreshToken":firebase_refresh_token,
			"expiresIn":str(maxi(60, firebase_token_expires_at - int(Time.get_unix_time_from_system()))),
			"provider":"google",
			"email":firebase_email,
			"displayName":profile_name
		}
		connect_multiplayer()
		if multiplayer_state == "connected":
			send_multiplayer(pending_auth_handoff_payload)
			pending_auth_handoff_payload = {}
			pending_android_auth_handoff = ""
			show_menu_notice("החשבון נשלח לאפליקציה" if ui_language == "he" else "ACCOUNT SENT TO THE APP")
	queue_redraw()

func update_firebase(delta: float) -> void:
	if session_restore_pending:
		session_restore_deadline -= delta
		if session_restore_deadline <= 0.0:
			session_restore_pending = false
			if firebase_refresh_token.is_empty() and app_screen != APP_HOME:
				app_screen = APP_AUTH
				firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
	if OS.has_feature("web"):
		firebase_web_poll_delay -= delta
		if firebase_web_poll_delay <= 0.0:
			firebase_web_poll_delay = 0.25
			poll_firebase_web_state()
	if app_screen != APP_AUTH and not firebase_refresh_token.is_empty() and not firebase_auth_busy:
		if firebase_token_expires_at <= int(Time.get_unix_time_from_system()) + 120:
			start_firebase_auth()
	if firebase_profile_dirty:
		firebase_sync_delay -= delta
		if firebase_sync_delay <= 0.0:
				sync_firebase_profile()

func poll_firebase_web_state() -> void:
	if firebase_auth_busy:
		var auth_text := str(JavaScriptBridge.eval("JSON.stringify(window.zpAuthState || {})", true))
		var auth_data: Variant = JSON.parse_string(auth_text)
		if auth_data is Dictionary:
			var auth_state := auth_data as Dictionary
			var auth_status := str(auth_state.get("status", ""))
			if auth_status == "done":
				apply_firebase_auth_response(auth_state)
			elif auth_status == "error":
				firebase_auth_busy = false
				var auth_error := str(auth_state.get("message", "Unknown error"))
				firebase_status = ("שגיאת חיבור: " if ui_language == "he" else "SIGN-IN ERROR: ") + auth_error.left(34)
				if firebase_auth_mode == "resume" and auth_token_is_unrecoverable(auth_error):
					clear_saved_auth_session()
					app_screen = APP_AUTH
					firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
				queue_redraw()
		if session_restore_pending:
			var restore_checked := str(JavaScriptBridge.eval("window.zpSessionRestoreChecked ? '1' : '0'", true)) == "1"
			if restore_checked and firebase_refresh_token.is_empty() and not firebase_auth_busy:
				session_restore_pending = false
				app_screen = APP_AUTH
				firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
	var google_text := str(JavaScriptBridge.eval("JSON.stringify(window.zpGoogleState || {})", true))
	var google_data: Variant = JSON.parse_string(google_text)
	if google_data is Dictionary:
		var google_state := google_data as Dictionary
		var google_status := str(google_state.get("status", ""))
		if google_status == "done":
			firebase_provider = "google"
			firebase_email = str(google_state.get("email", ""))
			var google_name: String = str(google_state.get("displayName", "")).strip_edges().left(20)
			if not google_name.is_empty():
				profile_name = google_name
				if profile_name_input != null:
					profile_name_input.text = profile_name
			apply_firebase_auth_response(google_state)
			JavaScriptBridge.eval("window.zpGoogleState = {status: 'connected'}", true)
		elif google_status == "error":
			firebase_status = ("שגיאת Google: " if ui_language == "he" else "GOOGLE ERROR: ") + str(google_state.get("message", "Unknown error")).left(34)
			JavaScriptBridge.eval("window.zpGoogleState = {status: 'ready'}", true)
			queue_redraw()
	var profile_text := str(JavaScriptBridge.eval("JSON.stringify(window.zpProfileState || {})", true))
	var profile_data: Variant = JSON.parse_string(profile_text)
	if profile_data is Dictionary:
		var profile_state := profile_data as Dictionary
		var profile_status := str(profile_state.get("status", ""))
		if profile_status == "done":
			firebase_status = "מסונכרן" if ui_language == "he" else "SYNCED"
			JavaScriptBridge.eval("window.zpProfileState = {}", true)
			queue_redraw()
		elif profile_status == "error":
			firebase_status = ("שגיאת סנכרון: " if ui_language == "he" else "SYNC ERROR: ") + str(profile_state.get("message", "Unknown error")).left(28)
			JavaScriptBridge.eval("window.zpProfileState = {}", true)
			queue_redraw()

func firestore_fields(include_public_id: bool = true) -> Dictionary:
	var fields := {
		"name": {"stringValue": profile_name},
		"animal": {"integerValue": str(player_animal)},
		"ringColor": {"integerValue": str(player_ring_color)},
		"coins": {"integerValue": str(player_coins)},
		"economyVersion": {"integerValue": str(ECONOMY_VERSION)},
		"ownedAnimals": {"stringValue": JSON.stringify(owned_animals)},
		"ownedRings": {"stringValue": JSON.stringify(owned_rings)},
		"level": {"integerValue": str(player_level)},
		"xp": {"integerValue": str(player_xp)},
		"wins": {"integerValue": str(player_wins)},
		"losses": {"integerValue": str(player_losses)},
		"bestStreak": {"integerValue": str(player_best_streak)},
		"currentStreak": {"integerValue": str(player_current_streak)},
		"rating": {"integerValue": str(player_rating)},
		"leagueTier": {"integerValue": str(player_league_tier)}
	}
	if include_public_id:
		fields["publicId"] = {"stringValue": firebase_public_id}
	return fields

func sync_firebase_profile() -> void:
	if firebase_uid.is_empty() or firebase_id_token.is_empty() or firebase_profile_request == null:
		return
	if OS.has_feature("web"):
		firebase_profile_dirty = false
		firebase_status = "מסנכרן..." if ui_language == "he" else "SYNCING..."
		var profile_url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/users/%s" % [FIREBASE_PROJECT_ID, firebase_uid]
		var public_url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/publicIds/%s" % [FIREBASE_PROJECT_ID, firebase_public_id]
		var profile_payload := JSON.stringify({"fields": firestore_fields()})
		var public_fields := {"uid": {"stringValue": firebase_uid}, "name": {"stringValue": profile_name}}
		var public_payload := JSON.stringify({"fields": public_fields})
		var web_script := """
window.zpProfileState = {status: 'loading'};
(async () => {
  try {
    const headers = {'Authorization': 'Bearer ' + __TOKEN__, 'Content-Type': 'application/json'};
    const responses = await Promise.all([
      fetch(__PROFILE_URL__, {method: 'PATCH', mode: 'cors', credentials: 'omit', headers, body: __PROFILE_BODY__}),
      fetch(__PUBLIC_URL__, {method: 'PATCH', mode: 'cors', credentials: 'omit', headers, body: __PUBLIC_BODY__})
    ]);
    for (const response of responses) {
      if (!response.ok) throw new Error('HTTP ' + response.status + ': ' + (await response.text()).slice(0, 80));
    }
    window.zpProfileState = {status: 'done'};
  } catch (error) {
    window.zpProfileState = {status: 'error', message: String(error && error.message || error)};
  }
})();
"""
		web_script = web_script.replace("__TOKEN__", JSON.stringify(firebase_id_token))
		web_script = web_script.replace("__PROFILE_URL__", JSON.stringify(profile_url))
		web_script = web_script.replace("__PUBLIC_URL__", JSON.stringify(public_url))
		web_script = web_script.replace("__PROFILE_BODY__", JSON.stringify(profile_payload))
		web_script = web_script.replace("__PUBLIC_BODY__", JSON.stringify(public_payload))
		JavaScriptBridge.eval(web_script, true)
		return
	if firebase_profile_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	firebase_profile_dirty = false
	firebase_status = "מסנכרן..." if ui_language == "he" else "SYNCING..."
	var url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/users/%s" % [FIREBASE_PROJECT_ID, firebase_uid]
	var payload := JSON.stringify({"fields": firestore_fields()})
	var error := firebase_profile_request.request(url, ["Authorization: Bearer " + firebase_id_token, "Content-Type: application/json"], HTTPClient.METHOD_PATCH, payload)
	if error != OK:
		firebase_profile_dirty = true
		firebase_sync_delay = 5.0

func sync_firebase_public_id() -> void:
	if firebase_public_id.is_empty() or firebase_id_token.is_empty() or firebase_public_id_request == null:
		return
	if firebase_public_id_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/publicIds/%s" % [FIREBASE_PROJECT_ID, firebase_public_id]
	var fields := {"uid": {"stringValue": firebase_uid}, "name": {"stringValue": profile_name}}
	firebase_public_id_request.request(url, ["Authorization: Bearer " + firebase_id_token, "Content-Type: application/json"], HTTPClient.METHOD_PATCH, JSON.stringify({"fields": fields}))

func _on_firebase_profile_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code >= 200 and response_code < 300:
		firebase_status = "מסונכרן" if ui_language == "he" else "SYNCED"
	else:
		firebase_status = "ממתין לסנכרון" if ui_language == "he" else "SYNC PENDING"
		firebase_profile_dirty = true
		firebase_sync_delay = 8.0
	queue_redraw()

func _on_firebase_public_id_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	pass

func _on_profile_name_changed(value: String) -> void:
	var clean := value.strip_edges().left(20)
	if clean.is_empty():
		return
	profile_name = clean
	save_player_profile()
	queue_redraw()

func _on_profile_name_submitted(_value: String) -> void:
	commit_profile_name()
	profile_name_input.release_focus()

func commit_profile_name() -> void:
	if profile_name_input == null:
		return
	var clean := profile_name_input.text.strip_edges().left(20)
	if clean.is_empty():
		profile_name_input.text = profile_name
		return
	profile_name = clean
	save_player_profile()
	queue_redraw()

func update_profile_name_input() -> void:
	if profile_name_input == null:
		return
	var should_show := app_screen == APP_PLAYER_PROFILE
	profile_name_input.visible = should_show
	if should_show:
		var viewport_size := get_viewport_rect().size
		var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
		profile_name_input.position = Vector2(602.0, 139.0) * unit
		profile_name_input.size = Vector2(350.0, 50.0) * unit

func update_auth_inputs() -> void:
	if auth_email_input == null or auth_password_input == null:
		return
	var should_show := app_screen == APP_AUTH and not auth_email_mode.is_empty()
	auth_email_input.visible = should_show
	auth_password_input.visible = should_show
	if should_show:
		var viewport_size := get_viewport_rect().size
		var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
		auth_email_input.position = Vector2(430.0, 278.0) * unit
		auth_email_input.size = Vector2(420.0, 58.0) * unit
		auth_password_input.position = Vector2(430.0, 355.0) * unit
		auth_password_input.size = Vector2(420.0, 58.0) * unit

func auth_choice_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(430.0, 230.0 + float(index) * 78.0) * unit, Vector2(420.0, 62.0) * unit)

func auth_submit_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(430.0, 445.0) * unit, Vector2(420.0, 64.0) * unit)

func auth_cancel_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(500.0, 530.0) * unit, Vector2(280.0, 52.0) * unit)

func chat_panel(viewport_size: Vector2) -> Rect2:
	return Rect2((viewport_size - Vector2(650.0, 390.0)) * 0.5, Vector2(650.0, 390.0))

func chat_close_rect(viewport_size: Vector2) -> Rect2:
	var panel := chat_panel(viewport_size)
	return Rect2(panel.end.x - 55.0, panel.position.y + 12.0, 42.0, 42.0)

func chat_send_rect(viewport_size: Vector2) -> Rect2:
	var panel := chat_panel(viewport_size)
	return Rect2(panel.end.x - 135.0, panel.end.y - 72.0, 112.0, 50.0)

func update_chat_input() -> void:
	if chat_input == null:
		return
	var should_show := (app_screen == APP_GAME and game_mode == "online" and chat_open and not exit_confirm_open) or (app_screen == APP_FRIEND and friend_room_chat_open and not multiplayer_room_code.is_empty())
	chat_input.visible = should_show
	if should_show:
		var panel := chat_panel(get_viewport_rect().size)
		chat_input.position = panel.position + Vector2(24.0, panel.size.y - 72.0)
		chat_input.size = Vector2(panel.size.x - 174.0, 50.0)

func _on_chat_submitted(_value: String) -> void:
	send_chat_message()

func send_chat_message() -> void:
	if chat_input == null:
		return
	var message := chat_input.text.strip_edges()
	if message.is_empty():
		return
	send_multiplayer({"type":"chat", "message":message.left(80)})
	chat_input.clear()
	chat_input.grab_focus()
	play_sound("ui")

func draw_match_chat(viewport_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.03, 0.06, 0.68))
	var panel := chat_panel(viewport_size)
	draw_style_box(make_box(Color("10283b"), 24.0), panel)
	draw_string(ui_font, panel.position + Vector2(0.0, 48.0), "צ׳אט עם החבר" if ui_language == "he" else "FRIEND CHAT", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 25, Color("f6d365"))
	var close := chat_close_rect(viewport_size)
	draw_style_box(make_box(Color("ef5350"), 12.0), close)
	draw_string(ui_font, close.position + Vector2(0.0, 29.0), "×", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, 24, Color.WHITE)
	var first_index: int = maxi(0, match_chat_messages.size() - 6)
	var row := 0
	for i in range(first_index, match_chat_messages.size()):
		var message: Dictionary = match_chat_messages[i]
		var sender_slot := int(message.get("slot", -1))
		var sender := str(message.get("name", ""))
		var line := sender + ": " + str(message.get("message", ""))
		var ring_index := player_ring_color
		for player_data in multiplayer_players:
			if int(player_data.get("slot", -1)) == sender_slot:
				ring_index = int(player_data.get("ringColor", ring_index))
				break
		var color: Color = RING_COLORS[clampi(ring_index, 0, RING_COLORS.size() - 1)].lightened(0.35)
		draw_string(ui_font, panel.position + Vector2(28.0, 92.0 + row * 38.0), line, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 56.0, 18, color)
		row += 1
	var send_rect := chat_send_rect(viewport_size)
	draw_style_box(make_box(Color("12a96b"), 14.0), send_rect)
	draw_string(ui_font, send_rect.position + Vector2(0.0, 32.0), "שליחה" if ui_language == "he" else "SEND", HORIZONTAL_ALIGNMENT_CENTER, send_rect.size.x, 17, Color.WHITE)

func connect_multiplayer() -> void:
	if multiplayer_socket.get_ready_state() in [WebSocketPeer.STATE_OPEN, WebSocketPeer.STATE_CONNECTING]:
		return
	multiplayer_socket = WebSocketPeer.new()
	var error := multiplayer_socket.connect_to_url(MATCH_SERVER_URL)
	if error != OK:
		multiplayer_state = "error"
		multiplayer_error = "לא ניתן להתחבר לשרת" if ui_language == "he" else "Could not connect to server"
	else:
		multiplayer_state = "connecting"
		multiplayer_error = ""

func poll_multiplayer() -> void:
	if multiplayer_socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if multiplayer_state not in ["disconnected", "error"]:
			multiplayer_state = "disconnected"
			multiplayer_error = "החיבור לשרת נותק" if ui_language == "he" else "Server connection closed"
			if matchmaking_searching:
				matchmaking_searching = false
				pending_find_match = false
				arena_fx_phase = "idle"
				arena_fx_elapsed = 0.0
				pending_arena_match = {}
				arena_matched_opponent = {}
		return
	multiplayer_socket.poll()
	if multiplayer_socket.get_ready_state() == WebSocketPeer.STATE_OPEN and multiplayer_state == "connecting":
		multiplayer_state = "connected"
	while multiplayer_socket.get_ready_state() == WebSocketPeer.STATE_OPEN and multiplayer_socket.get_available_packet_count() > 0:
		var payload = JSON.parse_string(multiplayer_socket.get_packet().get_string_from_utf8())
		if typeof(payload) == TYPE_DICTIONARY:
			handle_multiplayer_message(payload)

func send_multiplayer(payload: Dictionary) -> void:
	if multiplayer_socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		multiplayer_socket.send_text(JSON.stringify(payload))

func send_find_match() -> void:
	commit_profile_name()
	pending_find_match = false
	matchmaking_searching = true
	multiplayer_local_animal = player_animal
	multiplayer_local_ring_color = player_ring_color
	send_multiplayer({
		"type": "find_match",
		"name": profile_name,
		"animal": player_animal,
		"ringColor": player_ring_color,
		"level": player_level,
		"wins": player_wins,
		"losses": player_losses,
		"arena": selected_arena,
		"rating": player_rating,
		"leagueTier": player_league_tier,
		"publicId": firebase_public_id
	})

func start_arena_search() -> void:
	var entry: int = int(ARENA_ENTRY_COSTS[clampi(selected_arena, 0, ARENA_ENTRY_COSTS.size() - 1)])
	if player_coins < entry:
		show_menu_notice(ui_text("not_enough_coins"))
		return
	pending_find_match = true
	matchmaking_searching = true
	match_source = "arena"
	arena_fx_phase = "searching"
	arena_fx_elapsed = 0.0
	multiplayer_error = ""
	if multiplayer_state != "connected":
		connect_multiplayer()
		multiplayer_error = "השרת מתעורר, נסו שוב בעוד כמה שניות" if ui_language == "he" else "Server is waking up, try again shortly"
		return
	send_find_match()

func cancel_matchmaking() -> void:
	pending_find_match = false
	matchmaking_searching = false
	arena_fx_phase = "idle"
	arena_fx_elapsed = 0.0
	pending_arena_match = {}
	arena_matched_opponent = {}
	send_multiplayer({"type": "cancel_match"})

func create_multiplayer_room() -> void:
	commit_profile_name()
	if multiplayer_state != "connected":
		connect_multiplayer()
		multiplayer_error = "השרת מתעורר, נסו שוב בעוד כמה שניות" if ui_language == "he" else "Server is waking up, try again shortly"
		return
	multiplayer_local_animal = player_animal
	multiplayer_local_ring_color = player_ring_color
	send_multiplayer({
		"type":"create_room",
		"name":profile_name,
		"animal":player_animal,
		"ringColor":player_ring_color,
		"boardTheme":selected_board_theme,
		"level":player_level,
		"wins":player_wins,
		"losses":player_losses,
		"rating":player_rating,
		"leagueTier":player_league_tier,
		"publicId":firebase_public_id
	})

func join_multiplayer_room() -> void:
	commit_profile_name()
	var code := room_code_input.text.strip_edges().to_upper()
	if code.length() != 4:
		multiplayer_error = "הכניסו קוד חדר בן 4 תווים" if ui_language == "he" else "Enter a 4-character room code"
		return
	if multiplayer_state != "connected":
		connect_multiplayer()
		multiplayer_error = "השרת מתעורר, נסו שוב בעוד כמה שניות" if ui_language == "he" else "Server is waking up, try again shortly"
		return
	multiplayer_local_animal = player_animal
	multiplayer_local_ring_color = player_ring_color
	send_multiplayer({
		"type":"join_room",
		"roomCode":code,
		"name":profile_name,
		"animal":player_animal,
		"ringColor":player_ring_color,
		"level":player_level,
		"wins":player_wins,
		"losses":player_losses,
		"rating":player_rating,
		"leagueTier":player_league_tier,
		"publicId":firebase_public_id
	})

func update_match_character(animal: int = -1, ring_color: int = -1) -> void:
	if multiplayer_slot < 0:
		return
	var current_animal: int = player_animal if multiplayer_slot == 0 else ai_animal
	var current_ring: int = player_ring_color if multiplayer_slot == 0 else ai_ring_color
	if animal >= 0:
		if not is_animal_unlocked(animal):
			show_menu_notice(ui_text("unlock_in_shop"))
			return
		current_animal = animal
	if ring_color >= 0:
		if not is_ring_unlocked(ring_color):
			show_menu_notice(ui_text("unlock_in_shop"))
			return
		current_ring = ring_color
	if multiplayer_slot == 0:
		player_animal = current_animal
		player_ring_color = current_ring
	else:
		ai_animal = current_animal
		ai_ring_color = current_ring
	rebuild_team_piece_textures()
	send_multiplayer({"type":"update_profile", "animal":current_animal, "ringColor":current_ring})

func toggle_multiplayer_ready() -> void:
	multiplayer_ready = not multiplayer_ready
	send_multiplayer({"type":"ready", "ready":multiplayer_ready})

func leave_multiplayer_room() -> void:
	if multiplayer_room_code != "":
		send_multiplayer({"type":"leave_room"})
	multiplayer_room_code = ""
	multiplayer_players.clear()
	multiplayer_slot = -1
	multiplayer_ready = false
	friend_customizer_open = false
	friend_opponent_profile_open = false
	matchmaking_searching = false
	pending_find_match = false
	if multiplayer_local_animal >= 0:
		player_animal = multiplayer_local_animal
		player_ring_color = multiplayer_local_ring_color
		rebuild_team_piece_textures()
	multiplayer_local_animal = -1
	multiplayer_local_ring_color = -1

func handle_multiplayer_message(payload: Dictionary) -> void:
	match str(payload.get("type", "")):
		"connected":
			multiplayer_state = "connected"
			multiplayer_error = ""
			var history = payload.get("lobbyChat", [])
			if typeof(history) == TYPE_ARRAY and history.size() > 0:
				lobby_chat_messages = history
				while lobby_chat_messages.size() > 30:
					lobby_chat_messages.pop_front()
			if pending_google_handoff_request:
				send_multiplayer({"type":"create_auth_handoff"})
				pending_google_handoff_request = false
			if not pending_auth_handoff_payload.is_empty():
				send_multiplayer(pending_auth_handoff_payload)
				pending_auth_handoff_payload = {}
				pending_android_auth_handoff = ""
			if not pending_shared_room_code.is_empty():
				var shared_code: String = pending_shared_room_code
				pending_shared_room_code = ""
				room_code_input.text = shared_code
				join_multiplayer_room()
			elif pending_find_match:
				send_find_match()
			elif not pending_friend_invite_send.is_empty():
				maybe_send_pending_friend_invite()
			sync_player_presence()
			register_fcm_token_with_server()
		"fcm_registered":
			pass
		"leaderboard":
			global_leaderboard = payload.get("entries", [])
			refresh_friend_names_from_leaderboard()
			for i in global_leaderboard.size():
				var entry: Dictionary = global_leaderboard[i]
				if str(entry.get("publicId", "")) == firebase_public_id:
					player_world_rank = int(entry.get("rank", 0))
					break
		"friends_list", "social_state":
			if str(payload.get("type", "")) == "social_state":
				apply_social_state_from_server(payload)
			else:
				apply_friends_list_from_server(payload.get("friends", []))
		"friend_request_result":
			if bool(payload.get("ok", false)):
				show_menu_notice(ui_text("friend_request_sent"))
			else:
				var code := str(payload.get("code", ""))
				if code == "EXISTS":
					show_menu_notice(ui_text("friend_exists"))
				elif code == "PENDING":
					show_menu_notice(ui_text("friend_request_exists"))
				elif code == "INCOMING":
					accept_friend_request_from(str(payload.get("targetPublicId", "")))
				else:
					show_menu_notice(ui_text("friend_not_found"))
		"friend_accept_result":
			if bool(payload.get("ok", false)):
				show_menu_notice(ui_text("friend_accepted"))
			else:
				show_menu_notice(ui_text("friend_not_found"))
		"friend_request_notify":
			home_social_tab = 0
			var request_name := str(payload.get("request", {}).get("name", ""))
			show_menu_notice(ui_text("friend_request_incoming") % request_name)
			play_sound("invite")
		"friend_accepted_notify":
			home_social_tab = 0
			var accepted_name := str(payload.get("fromName", payload.get("friend", {}).get("name", "")))
			show_menu_notice(ui_text("friend_added_you") % accepted_name)
			play_sound("invite")
		"friend_add_result":
			pass
		"friend_added_notify":
			pass
		"friend_invite":
			pending_friend_invite = {
				"fromName": str(payload.get("fromName", "")),
				"fromPublicId": str(payload.get("fromPublicId", "")),
				"roomCode": str(payload.get("roomCode", ""))
			}
			play_sound("invite")
			show_menu_notice(ui_text("invite_received") + pending_friend_invite.fromName)
			show_web_notification(
				"Zoopaloola",
				ui_text("invite_received") + str(pending_friend_invite.get("fromName", "")),
				{"roomCode": str(pending_friend_invite.get("roomCode", "")), "type": "friend_invite"}
			)
		"invite_sent":
			var online := bool(payload.get("online", false))
			var target_name := pending_friend_invite_target_name
			pending_friend_invite_target_name = ""
			if not target_name.is_empty():
				show_menu_notice(("הזמנה ל" if ui_language == "he" else "Invite sent to ") + target_name)
			else:
				show_menu_notice(ui_text("invite_sent_online") if online else ui_text("invite_sent_offline"))
		"auth_handoff":
			var auth_url: String = str(payload.get("url", ""))
			if OS.has_feature("android") and auth_url.begins_with("https://moshe2060.github.io/zoopaloola-mobile/"):
				firebase_status = "השלימו את הכניסה בדפדפן" if ui_language == "he" else "FINISH SIGN-IN IN YOUR BROWSER"
				OS.shell_open(auth_url)
		"auth_handoff_complete":
			var google_name: String = str(payload.get("displayName", "")).strip_edges().left(20)
			if not google_name.is_empty():
				profile_name = google_name
				if profile_name_input != null:
					profile_name_input.text = profile_name
			apply_firebase_auth_response(payload)
			show_menu_notice("התחברת עם Google" if ui_language == "he" else "SIGNED IN WITH GOOGLE")
		"joined":
			multiplayer_room_code = str(payload.get("roomCode", ""))
			multiplayer_slot = int(payload.get("slot", -1))
			multiplayer_ready = false
			if str(payload.get("source", "")) == "arena":
				match_source = "arena"
			maybe_send_pending_friend_invite()
		"searching":
			matchmaking_searching = true
			multiplayer_error = ""
		"search_cancelled":
			matchmaking_searching = false
			pending_find_match = false
			arena_fx_phase = "idle"
			arena_fx_elapsed = 0.0
			pending_arena_match = {}
			arena_matched_opponent = {}
			if str(payload.get("reason", "")) == "timeout":
				show_menu_notice(ui_text("search_timeout"))
		"room_state":
			multiplayer_players = payload.get("players", [])
			turn = int(payload.get("turn", 0))
			sync_match_board_from_payload(payload)
			if arena_fx_phase == "found":
				arena_matched_opponent = arena_opponent_data()
			if multiplayer_players.size() > 0:
				var first_player: Dictionary = multiplayer_players[0]
				player_animal = int(first_player.get("animal", player_animal))
				player_ring_color = int(first_player.get("ringColor", player_ring_color))
			if multiplayer_players.size() > 1:
				var second_player: Dictionary = multiplayer_players[1]
				ai_animal = int(second_player.get("animal", ai_animal))
				ai_ring_color = int(second_player.get("ringColor", ai_ring_color))
			rebuild_team_piece_textures()
		"match_started":
			if str(payload.get("source", "friend")) == "arena":
				begin_arena_match_found(payload)
			else:
				apply_match_started(payload)
		"shot":
			var ball_index := int(payload.get("ballIndex", -1))
			if ball_index >= 0 and ball_index < balls.size() and balls[ball_index].alive:
				var pull := Vector2(float(payload.get("pullX", 0.0)), float(payload.get("pullY", 0.0)))
				var strength := float(payload.get("strength", 0.0))
				if pull.length_squared() > 0.0:
					balls[ball_index].v = pull.normalized() * (strength * 0.078)
					turn_shot_committed = true
					turn_pending_resolve = true
					turn_opponent_scored = false
		"turn":
			turn = int(payload.get("turn", 0))
			turn_shot_committed = false
			turn_pending_resolve = false
			turn_opponent_scored = false
			update_turn_status_from_server(bool(payload.get("continueTurn", false)))
		"chat":
			match_chat_messages.append({
				"slot": int(payload.get("playerSlot", -1)),
				"name": str(payload.get("name", "")),
				"message": str(payload.get("message", ""))
			})
			while match_chat_messages.size() > 20:
				match_chat_messages.pop_front()
		"lobby_chat":
			lobby_chat_messages.append({
				"name": str(payload.get("name", "Player")),
				"message": str(payload.get("message", ""))
			})
			while lobby_chat_messages.size() > 30:
				lobby_chat_messages.pop_front()
		"match_over":
			var winner_slot := int(payload.get("winnerSlot", -1))
			if winner_slot >= 0:
				finish_match(winner_slot)
		"opponent_left":
			if match_finished:
				pass
			else:
				if match_source == "arena":
					app_screen = APP_ARENA
					matchmaking_searching = false
				else:
					app_screen = APP_FRIEND
				multiplayer_ready = false
				multiplayer_error = "היריב יצא מהחדר" if ui_language == "he" else "Opponent left the room"
		"error":
			multiplayer_error = str(payload.get("message", "Server error"))
	queue_redraw()

func start_selected_mode(mode: String) -> void:
	game_mode = mode
	match_source = mode
	customizer_open = false
	effect_editor_enabled = false
	exit_confirm_open = false
	chat_open = false
	match_chat_messages.clear()
	matchmaking_searching = false
	pending_find_match = false
	app_screen = APP_GAME
	new_game()
	if game_mode == "friend":
		status = "Red player's turn - local match"
	else:
		status = "Your turn - touch a red ball, pull back and release"

func start_computer_setup() -> void:
	# Prepare the board behind the modal, but do not allow a shot until the
	# player confirms the animal and lifebuoy for this computer match.
	start_selected_mode("computer")
	customizer_open = true
	status = ui_text("choose_setup")
	queue_redraw()

func show_menu_notice(text: String) -> void:
	menu_notice = text
	menu_notice_time = 2.4

func player_level_label() -> String:
	if ui_language == "he":
		return "רמה %d" % player_level
	return "LEVEL %d" % player_level

func daily_claim_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2((viewport_size.x - 420.0 * unit) * 0.5, viewport_size.y * 0.62), Vector2(420.0, 78.0) * unit)

func draw_rewards_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.48))
	draw_frontend_header(viewport_size, ui_text("daily_title"), ui_text("daily_sub"))
	var card := Rect2(Vector2((viewport_size.x - 640.0 * unit) * 0.5, 160.0 * unit), Vector2(640.0, 420.0) * unit)
	draw_style_box(make_box(Color(0.02, 0.08, 0.14, 0.92), 28.0 * unit), card.grow(6.0 * unit))
	draw_style_box(make_box(Color("e94f78"), 24.0 * unit), card)
	draw_circle(card.position + Vector2(card.size.x * 0.5, 140.0 * unit), 58.0 * unit, Color("ffc83d"))
	draw_circle(card.position + Vector2(card.size.x * 0.5, 140.0 * unit), 36.0 * unit, Color("e9971b"), false, 8.0 * unit, true)
	draw_string(ui_font, card.position + Vector2(30.0, 250.0) * unit, "+" + str(DAILY_REWARD_COINS) + ui_text("coins"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 60.0 * unit, int(28.0 * unit), Color.WHITE)
	draw_string(ui_font, card.position + Vector2(40.0, 292.0) * unit, ("יתרה: %d" if ui_language == "he" else "Balance: %d") % player_coins, HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 80.0 * unit, int(16.0 * unit), Color("fff0c7"))
	var claim := daily_claim_rect(viewport_size)
	var ready := can_claim_daily()
	draw_style_box(make_box(Color("12a96b") if ready else Color("31485d"), 18.0 * unit), claim)
	draw_string(ui_font, claim.position + Vector2(0.0, 50.0) * unit, ui_text("claim") if ready else ui_text("claimed"), HORIZONTAL_ALIGNMENT_CENTER, claim.size.x, int(22.0 * unit), Color.WHITE)

func ui_text(key: String) -> String:
	if ui_language == "he":
		return str(UI_TEXT_HE.get(key, UI_TEXT_EN.get(key, key)))
	return str(UI_TEXT_EN.get(key, key))

func ui_animal_name(index: int) -> String:
	var keys := ["elephant", "zebra", "monkey", "hippo", "rhino", "giraffe", "tiger"]
	return ui_text(keys[clampi(index, 0, keys.size() - 1)])

func ui_ring_name(index: int) -> String:
	var keys := ["red", "orange", "blue", "green", "purple", "turquoise", "pink"]
	return ui_text(keys[clampi(index, 0, keys.size() - 1)])

func profile_initial() -> String:
	var clean := profile_name.strip_edges()
	return clean.left(1).to_upper() if not clean.is_empty() else "P"

func handle_frontend_touch(screen_pos: Vector2) -> void:
	var viewport_size := get_viewport_rect().size
	if home_invite_join_rect(viewport_size).has_point(screen_pos):
		accept_pending_friend_invite()
		return
	if app_screen == APP_SPLASH:
		app_screen = APP_AUTH
		return
	if app_screen == APP_AUTH:
		if session_restore_pending:
			return
		if auth_email_mode.is_empty():
			if auth_choice_rect(0, viewport_size).has_point(screen_pos):
				firebase_auth_mode = "google"
				begin_google_sign_in()
			elif auth_choice_rect(1, viewport_size).has_point(screen_pos):
				auth_email_mode = "login"
				firebase_status = "הזינו מייל וסיסמה" if ui_language == "he" else "ENTER EMAIL AND PASSWORD"
			elif auth_choice_rect(2, viewport_size).has_point(screen_pos):
				begin_guest_sign_in()
			elif auth_choice_rect(3, viewport_size).has_point(screen_pos):
				auth_email_mode = "register"
				firebase_status = "צרו חשבון חדש" if ui_language == "he" else "CREATE A NEW ACCOUNT"
		else:
			if auth_submit_rect(viewport_size).has_point(screen_pos):
				start_email_auth(auth_email_mode == "register")
			elif auth_cancel_rect(viewport_size).has_point(screen_pos):
				auth_email_mode = ""
				firebase_status = "בחרו דרך כניסה" if ui_language == "he" else "CHOOSE HOW TO SIGN IN"
		queue_redraw()
		return
	if app_screen == APP_HOME:
		if tutorial_open:
			handle_tutorial_touch(screen_pos, viewport_size)
			return
		if home_friend_profile_index >= 0:
			if home_friend_profile_close_rect(viewport_size).has_point(screen_pos):
				home_friend_profile_index = -1
				queue_redraw()
				return
			if home_friend_profile_invite_rect(viewport_size).has_point(screen_pos):
				var invite_index := home_friend_profile_index
				var friend_entry: Dictionary = friends_list[invite_index] if invite_index >= 0 and invite_index < friends_list.size() else {}
				if bool(friend_entry.get("online", false)):
					home_friend_profile_index = -1
					invite_friend_to_play(invite_index)
				else:
					show_menu_notice(ui_text("friend_invite_offline"))
				return
			if home_friend_profile_remove_rect(viewport_size).has_point(screen_pos):
				remove_friend_at(home_friend_profile_index)
				return
			if not home_friend_profile_modal_rect(viewport_size).has_point(screen_pos):
				home_friend_profile_index = -1
				queue_redraw()
			return
		var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
		if home_help_rect(viewport_size).has_point(screen_pos):
			open_tutorial()
			return
		if home_social_tab_rect(0, viewport_size).has_point(screen_pos):
			home_social_tab = 0
			if lobby_chat_input != null:
				lobby_chat_input.release_focus()
			queue_redraw()
			return
		if home_social_tab_rect(1, viewport_size).has_point(screen_pos):
			home_social_tab = 1
			if friend_id_input != null:
				friend_id_input.release_focus()
			queue_redraw()
			return
		if home_social_tab_rect(2, viewport_size).has_point(screen_pos):
			home_social_tab = 2
			send_multiplayer({"type": "get_leaderboard"})
			queue_redraw()
			return
		if home_invite_join_rect(viewport_size).has_point(screen_pos):
			accept_pending_friend_invite()
			return
		if home_sound_toggle_rect(viewport_size).has_point(screen_pos):
			sound_enabled = not sound_enabled
			save_player_profile()
			play_sound("ui")
			queue_redraw()
			return
		if home_social_tab == 0:
			for i in mini(2, incoming_friend_requests.size()):
				if home_incoming_accept_rect(i, viewport_size).has_point(screen_pos):
					accept_friend_request_from(str(incoming_friend_requests[i].get("id", "")))
					return
				if home_incoming_decline_rect(i, viewport_size).has_point(screen_pos):
					decline_friend_request_at(i)
					return
			if home_add_friend_button_rect(viewport_size).has_point(screen_pos):
				if friend_id_input != null:
					send_friend_request_by_id(friend_id_input.text)
				return
			for i in mini(3, friends_list.size()):
				var row := home_friend_row_rect(i, viewport_size)
				var invite_rect := home_friend_invite_rect(i, viewport_size)
				if invite_rect.has_point(screen_pos):
					invite_friend_to_play(i)
					return
				if row.has_point(screen_pos):
					home_friend_profile_index = i
					play_sound("ui")
					queue_redraw()
					return
		elif home_social_tab == 1:
			if home_lobby_send_rect(viewport_size).has_point(screen_pos):
				send_lobby_chat_message()
				return
		if home_character_rect(viewport_size).has_point(screen_pos):
			app_screen = APP_PROFILE
			return
		if home_profile_rect(viewport_size).has_point(screen_pos):
			app_screen = APP_PLAYER_PROFILE
			return
		if home_settings_rect(viewport_size).has_point(screen_pos):
			ui_language = "en" if ui_language == "he" else "he"
			save_player_profile()
			show_menu_notice("English interface" if ui_language == "en" else "הממשק הוחלף לעברית")
			return
		for i in 2:
			if not home_nav_rect(i, viewport_size).has_point(screen_pos):
				continue
			if i == 0:
				app_screen = APP_SHOP
				shop_page = SHOP_PAGE_HUB
			else:
				app_screen = APP_REWARDS
			return
		if home_mode_rect(0, viewport_size).has_point(screen_pos):
			app_screen = APP_ARENA
			return
		if home_mode_rect(1, viewport_size).has_point(screen_pos):
			app_screen = APP_FRIEND
			connect_multiplayer()
			return
		if home_mode_rect(2, viewport_size).has_point(screen_pos):
			play_sound("ui")
			start_computer_setup()
			return
	else:
		if frontend_back_rect(viewport_size).has_point(screen_pos):
			if app_screen == APP_SHOP and shop_page != SHOP_PAGE_HUB:
				shop_page = SHOP_PAGE_HUB
				play_sound("ui")
				queue_redraw()
				return
			if app_screen == APP_PLAYER_PROFILE:
				commit_profile_name()
			if app_screen == APP_FRIEND:
				leave_multiplayer_room()
			if app_screen == APP_ARENA:
				cancel_matchmaking()
			app_screen = APP_HOME
			return
		if app_screen == APP_PROFILE:
			for i in ANIMAL_NAMES.size():
				if character_card_rect(i, viewport_size).has_point(screen_pos):
					try_select_animal(i)
					queue_redraw()
					return
			for i in RING_COLOR_NAMES.size():
				if character_ring_rect(i, viewport_size).has_point(screen_pos):
					try_select_ring(i)
					queue_redraw()
					return
		elif app_screen == APP_SHOP:
			if shop_page == SHOP_PAGE_HUB:
				for i in 3:
					if shop_category_rect(i, viewport_size).has_point(screen_pos):
						shop_page = [SHOP_PAGE_ANIMALS, SHOP_PAGE_RINGS, SHOP_PAGE_EFFECTS][i]
						play_sound("ui")
						queue_redraw()
						return
			elif shop_page == SHOP_PAGE_ANIMALS:
				for i in ANIMAL_NAMES.size():
					if shop_detail_grid_rect(i, viewport_size, ANIMAL_NAMES.size()).has_point(screen_pos):
						try_purchase_animal(i)
						queue_redraw()
						return
			elif shop_page == SHOP_PAGE_RINGS:
				for i in RING_COLOR_NAMES.size():
					if shop_detail_grid_rect(i, viewport_size, RING_COLOR_NAMES.size()).has_point(screen_pos):
						try_purchase_ring(i)
						queue_redraw()
						return
		elif app_screen == APP_ARENA:
			for i in 3:
				if arena_card_rect(i, viewport_size).has_point(screen_pos):
					selected_arena = i
					return
			if arena_play_rect(viewport_size).has_point(screen_pos):
				if matchmaking_searching:
					cancel_matchmaking()
				else:
					start_arena_search()
				return
		elif app_screen == APP_REWARDS:
			if daily_claim_rect(viewport_size).has_point(screen_pos):
				claim_daily_reward()
				return
		elif app_screen == APP_PLAYER_PROFILE:
			if player_google_rect(viewport_size).has_point(screen_pos):
				if firebase_provider != "google":
					begin_google_sign_in()
				return
			if player_id_copy_rect(viewport_size).has_point(screen_pos):
				if not firebase_public_id.is_empty():
					DisplayServer.clipboard_set(firebase_public_id)
					show_menu_notice("המזהה הועתק" if ui_language == "he" else "PLAYER ID COPIED")
				return
			for i in ANIMAL_NAMES.size():
				if player_profile_animal_rect(i, viewport_size).has_point(screen_pos):
					try_select_animal(i)
					queue_redraw()
					return
			for i in RING_COLOR_NAMES.size():
				if player_profile_color_rect(i, viewport_size).has_point(screen_pos):
					try_select_ring(i)
					queue_redraw()
					return
		elif app_screen == APP_FRIEND:
			if friend_room_chat_open:
				if chat_close_rect(viewport_size).has_point(screen_pos):
					friend_room_chat_open = false
					if chat_input != null:
						chat_input.release_focus()
					return
				if chat_send_rect(viewport_size).has_point(screen_pos):
					send_chat_message()
					return
			if friend_customizer_open or friend_opponent_profile_open:
				if friend_modal_close_rect(viewport_size).has_point(screen_pos):
					friend_customizer_open = false
					friend_opponent_profile_open = false
					return
				if friend_customizer_open:
					for i in ANIMAL_NAMES.size():
						if friend_choice_rect(i, false, viewport_size).has_point(screen_pos):
							if try_select_animal(i):
								update_match_character(i, -1)
							return
						if friend_choice_rect(i, true, viewport_size).has_point(screen_pos):
							if try_select_ring(i):
								update_match_character(-1, i)
							return
					for i in BOARD_THEME_COUNT:
						if friend_board_rect(i, viewport_size).has_point(screen_pos):
							update_match_board(i)
							return
				return
			if multiplayer_room_code.is_empty():
				if friend_create_rect(viewport_size).has_point(screen_pos):
					create_multiplayer_room()
					return
				if friend_join_rect(viewport_size).has_point(screen_pos):
					join_multiplayer_room()
					return
			else:
				if friend_share_rect(viewport_size).has_point(screen_pos):
					share_friend_room()
					return
				if friend_room_chat_rect(viewport_size).has_point(screen_pos):
					friend_room_chat_open = true
					if chat_input != null:
						chat_input.grab_focus()
					play_sound("ui")
					return
				var local_slot := multiplayer_slot if multiplayer_slot >= 0 else 0
				if friend_player_rect(local_slot, viewport_size).has_point(screen_pos):
					friend_customizer_open = true
					return
				var opponent_slot := 1 - multiplayer_slot
				if opponent_slot >= 0 and opponent_slot < multiplayer_players.size() and friend_player_rect(opponent_slot, viewport_size).has_point(screen_pos):
					friend_opponent_profile_open = true
					return
				if friend_ready_rect(viewport_size).has_point(screen_pos):
					toggle_multiplayer_ready()
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
	if app_screen == APP_AUTH:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_auth_screen(viewport_size)
	elif app_screen == APP_HOME:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		else:
			draw_menu_background(viewport_size)
		draw_home_screen(viewport_size)
	elif app_screen == APP_PROFILE:
		draw_menu_background(viewport_size)
		draw_profile_screen(viewport_size)
	elif app_screen == APP_SHOP:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_shop_screen(viewport_size)
	elif app_screen == APP_ARENA:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_arena_screen(viewport_size)
	elif app_screen == APP_PLAYER_PROFILE:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_player_profile_screen(viewport_size)
	elif app_screen == APP_FRIEND:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_friend_screen(viewport_size)
	elif app_screen == APP_REWARDS:
		if lobby_background_texture != null:
			draw_texture_rect(lobby_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
		draw_rewards_screen(viewport_size)
	draw_pending_invite_banner(viewport_size)
	if menu_notice_time > 0.0:
		var toast := Rect2(viewport_size.x * 0.31, viewport_size.y - 68.0, viewport_size.x * 0.38, 46.0)
		draw_style_box(make_box(Color(0.04, 0.08, 0.14, 0.94), 14.0), toast)
		draw_string(ui_font, toast.position + Vector2(0.0, 29.0), menu_notice, HORIZONTAL_ALIGNMENT_CENTER, toast.size.x, 14, Color("f6d365"))

func draw_auth_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.09, 0.70))
	var panel := Rect2(Vector2(350.0, 72.0) * unit, Vector2(580.0, 580.0) * unit)
	draw_style_box(make_box(Color(0.025, 0.09, 0.16, 0.97), 30.0 * unit), panel)
	draw_string(ui_font, Vector2(panel.position.x, panel.position.y + 70.0 * unit), "ברוכים הבאים ל־ZOOPALOOLA" if ui_language == "he" else "WELCOME TO ZOOPALOOLA", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(30.0 * unit), Color("ffd83d"))
	draw_string(ui_font, Vector2(panel.position.x, panel.position.y + 110.0 * unit), ("בחרו איך להיכנס למשחק" if auth_email_mode.is_empty() else ("הרשמה חדשה" if auth_email_mode == "register" else "כניסה עם מייל")) if ui_language == "he" else ("CHOOSE HOW TO SIGN IN" if auth_email_mode.is_empty() else ("CREATE ACCOUNT" if auth_email_mode == "register" else "EMAIL SIGN IN")), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(20.0 * unit), Color.WHITE)
	if session_restore_pending and auth_email_mode.is_empty():
		draw_string(ui_font, Vector2(panel.position.x, panel.position.y + 300.0 * unit), ui_text("restoring_session"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(22.0 * unit), Color("9fd9ef"))
	elif auth_email_mode.is_empty():
		var labels := ["כניסה עם Gmail", "כניסה עם מייל", "כניסה כאורח", "הרשמה"] if ui_language == "he" else ["CONTINUE WITH GOOGLE", "SIGN IN WITH EMAIL", "CONTINUE AS GUEST", "REGISTER"]
		var colors := [Color("4285f4"), Color("2f9ed1"), Color("35bd78"), Color("ff9f2e")]
		var icons := ["G", "@", "☺", "+"]
		for i in 4:
			var rect := auth_choice_rect(i, viewport_size)
			draw_style_box(make_box(colors[i], 16.0 * unit), rect)
			draw_circle(rect.position + Vector2(37.0, 31.0) * unit, 21.0 * unit, Color(1, 1, 1, 0.22))
			draw_string(ui_font, rect.position + Vector2(16.0, 40.0) * unit, icons[i], HORIZONTAL_ALIGNMENT_CENTER, 42.0 * unit, int(22.0 * unit), Color.WHITE)
			draw_string(ui_font, rect.position + Vector2(58.0, 40.0) * unit, labels[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 78.0 * unit, int(22.0 * unit), Color.WHITE)
	else:
		draw_string(ui_font, Vector2(panel.position.x, 248.0 * unit), "כתובת מייל" if ui_language == "he" else "EMAIL ADDRESS", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(15.0 * unit), Color("9fd9ef"))
		draw_string(ui_font, Vector2(panel.position.x, 326.0 * unit), "סיסמה" if ui_language == "he" else "PASSWORD", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(15.0 * unit), Color("9fd9ef"))
		var submit := auth_submit_rect(viewport_size)
		draw_style_box(make_box(Color("35bd78"), 17.0 * unit), submit)
		draw_string(ui_font, submit.position + Vector2(0.0, 41.0) * unit, ("יצירת חשבון" if auth_email_mode == "register" else "כניסה") if ui_language == "he" else ("CREATE ACCOUNT" if auth_email_mode == "register" else "SIGN IN"), HORIZONTAL_ALIGNMENT_CENTER, submit.size.x, int(23.0 * unit), Color.WHITE)
		var cancel := auth_cancel_rect(viewport_size)
		draw_style_box(make_box(Color("203a59"), 14.0 * unit), cancel)
		draw_string(ui_font, cancel.position + Vector2(0.0, 34.0) * unit, "חזרה לאפשרויות" if ui_language == "he" else "BACK TO OPTIONS", HORIZONTAL_ALIGNMENT_CENTER, cancel.size.x, int(18.0 * unit), Color.WHITE)
	var status_color := Color("7ee4ae") if not ("שגיא" in firebase_status or "ERROR" in firebase_status) else Color("ff7777")
	draw_string(ui_font, Vector2(panel.position.x + 20.0 * unit, panel.end.y - 25.0 * unit), firebase_status, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 40.0 * unit, int(15.0 * unit), status_color)

func draw_friend_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.05, 0.10, 0.66))
	draw_frontend_header(viewport_size, "משחק מול חבר" if ui_language == "he" else "PLAY A FRIEND", "צרו חדר או הצטרפו באמצעות קוד" if ui_language == "he" else "Create a room or join with a code")
	var panel := Rect2(Vector2(175.0, 125.0) * unit, Vector2(930.0, 535.0) * unit)
	draw_style_box(make_box(Color(0.025, 0.09, 0.16, 0.95), 28.0 * unit), panel)
	var connection_text := "מחובר לשרת" if multiplayer_state == "connected" else ("מתחבר לשרת..." if multiplayer_state == "connecting" else "השרת לא מחובר")
	if ui_language != "he":
		connection_text = "Connected" if multiplayer_state == "connected" else ("Connecting..." if multiplayer_state == "connecting" else "Disconnected")
	var connection_color := Color("51d995") if multiplayer_state == "connected" else Color("ffd05a")
	var status_pill := Rect2(panel.position + Vector2(330.0, 20.0) * unit, Vector2(270.0, 55.0) * unit)
	draw_style_box(make_box(Color(0.04, 0.20, 0.24, 0.96), 20.0 * unit), status_pill)
	draw_circle(status_pill.position + Vector2(35.0, 27.0) * unit, 10.0 * unit, connection_color)
	draw_string(ui_font, status_pill.position + Vector2(0.0, 36.0) * unit, connection_text, HORIZONTAL_ALIGNMENT_CENTER, status_pill.size.x, int(23.0 * unit), Color.WHITE)
	if multiplayer_room_code.is_empty():
		var create_rect := friend_create_rect(viewport_size)
		draw_style_box(make_box(Color("7655df"), 18.0 * unit), create_rect)
		draw_string(ui_font, create_rect.position + Vector2(0.0, 50.0) * unit, "יצירת חדר חדש" if ui_language == "he" else "CREATE ROOM", HORIZONTAL_ALIGNMENT_CENTER, create_rect.size.x, int(23.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(0.0, 222.0 * unit), "או" if ui_language == "he" else "OR", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(19.0 * unit), Color("a9cde2"))
		draw_string(ui_font, Vector2(700.0, 245.0) * unit, "קוד החדר" if ui_language == "he" else "ROOM CODE", HORIZONTAL_ALIGNMENT_CENTER, 330.0 * unit, int(16.0 * unit), Color("d7f6ff"))
		var join_rect := friend_join_rect(viewport_size)
		draw_style_box(make_box(Color("ff7b43"), 18.0 * unit), join_rect)
		draw_string(ui_font, join_rect.position + Vector2(0.0, 45.0) * unit, "הצטרפות לחדר" if ui_language == "he" else "JOIN ROOM", HORIZONTAL_ALIGNMENT_CENTER, join_rect.size.x, int(22.0 * unit), Color.WHITE)
	else:
		draw_string(ui_font, panel.position + Vector2(0.0, 125.0) * unit, "קוד החדר" if ui_language == "he" else "ROOM CODE", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(18.0 * unit), Color("a9cde2"))
		draw_string(ui_font, panel.position + Vector2(0.0, 190.0) * unit, multiplayer_room_code, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(48.0 * unit), Color("ffe25d"))
		var share_rect := friend_share_rect(viewport_size)
		draw_style_box(make_box(Color("1f9fd0"), 16.0 * unit), share_rect)
		draw_string(ui_font, share_rect.position + Vector2(0.0, 40.0) * unit, "שיתוף לחבר" if ui_language == "he" else "SHARE INVITE", HORIZONTAL_ALIGNMENT_CENTER, share_rect.size.x, int(18.0 * unit), Color.WHITE)
		for i in 2:
			var player_rect := friend_player_rect(i, viewport_size)
			draw_style_box(make_box(Color("1d405b"), 17.0 * unit), player_rect)
			var player_label := "ממתין לשחקן..." if ui_language == "he" else "Waiting for player..."
			var ready_label := ""
			var is_ready := false
			if i < multiplayer_players.size():
				var player_data: Dictionary = multiplayer_players[i]
				player_label = str(player_data.get("name", "Player"))
				is_ready = bool(player_data.get("ready", false))
				ready_label = ("מוכן" if ui_language == "he" else "READY") if is_ready else ("לא מוכן" if ui_language == "he" else "NOT READY")
				var avatar_index := int(player_data.get("animal", 0))
				if avatar_index >= 0 and avatar_index < full_body_animal_textures.size():
					draw_texture_rect(full_body_animal_textures[avatar_index], Rect2(player_rect.position + Vector2(12.0, 12.0) * unit, Vector2(105.0, 130.0) * unit), false)
				draw_string(ui_font, player_rect.position + Vector2(125.0, 39.0) * unit, player_label, HORIZONTAL_ALIGNMENT_LEFT, 125.0 * unit, int(21.0 * unit), Color.WHITE)
				draw_string(ui_font, player_rect.position + Vector2(125.0, 70.0) * unit, ("רמה %d" if ui_language == "he" else "LEVEL %d") % int(player_data.get("level", 1)), HORIZONTAL_ALIGNMENT_LEFT, 125.0 * unit, int(14.0 * unit), Color("a9cde2"))
				draw_string(ui_font, player_rect.position + Vector2(125.0, 96.0) * unit, ui_animal_name(avatar_index), HORIZONTAL_ALIGNMENT_LEFT, 125.0 * unit, int(14.0 * unit), Color("ffe25d"))
				draw_small_lifebuoy(player_rect.position + Vector2(302.0, 78.0) * unit, int(player_data.get("ringColor", 0)), 35.0 * unit)
			else:
				draw_string(ui_font, player_rect.position + Vector2(0.0, 72.0) * unit, player_label, HORIZONTAL_ALIGNMENT_CENTER, player_rect.size.x, int(21.0 * unit), Color.WHITE)
			draw_string(ui_font, player_rect.position + Vector2(125.0, 127.0) * unit, ready_label, HORIZONTAL_ALIGNMENT_LEFT, 125.0 * unit, int(15.0 * unit), Color("51d995") if is_ready else Color("a9cde2"))
			if i == multiplayer_slot:
				draw_string(ui_font, player_rect.position + Vector2(250.0, 145.0) * unit, "לחצו לשינוי" if ui_language == "he" else "TAP TO CHANGE", HORIZONTAL_ALIGNMENT_CENTER, 104.0 * unit, int(11.0 * unit), Color("70dfff"))
			elif i < multiplayer_players.size():
				draw_string(ui_font, player_rect.position + Vector2(125.0, 151.0) * unit, "לחצו לפרופיל" if ui_language == "he" else "TAP FOR PROFILE", HORIZONTAL_ALIGNMENT_LEFT, 210.0 * unit, int(12.0 * unit), Color("70dfff"))
		var ready_rect := friend_ready_rect(viewport_size)
		draw_style_box(make_box(Color("35b96f") if not multiplayer_ready else Color("d49b2f"), 18.0 * unit), ready_rect)
		draw_string(ui_font, ready_rect.position + Vector2(0.0, 45.0) * unit, ("ביטול מוכנות" if multiplayer_ready else "אני מוכן") if ui_language == "he" else ("NOT READY" if multiplayer_ready else "I'M READY"), HORIZONTAL_ALIGNMENT_CENTER, ready_rect.size.x, int(22.0 * unit), Color.WHITE)
		var chat_rect := friend_room_chat_rect(viewport_size)
		draw_style_box(make_box(Color("1b91a8"), 14.0 * unit), chat_rect)
		draw_string(ui_font, chat_rect.position + Vector2(0.0, 31.0) * unit, ui_text("room_chat"), HORIZONTAL_ALIGNMENT_CENTER, chat_rect.size.x, int(15.0 * unit), Color.WHITE)
	if multiplayer_error != "":
		draw_string(ui_font, panel.position + Vector2(35.0, panel.size.y - 25.0) * unit, multiplayer_error, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 70.0 * unit, int(15.0 * unit), Color("ff8c7a"))
	if friend_customizer_open:
		draw_friend_customizer(viewport_size)
	elif friend_opponent_profile_open:
		draw_friend_opponent_profile(viewport_size)
	elif friend_room_chat_open:
		draw_match_chat(viewport_size)

func draw_small_lifebuoy(center: Vector2, color_index: int, radius: float) -> void:
	var ring_color: Color = RING_COLORS[clampi(color_index, 0, RING_COLORS.size() - 1)]
	draw_circle(center, radius, Color(0.01, 0.04, 0.08, 0.35))
	draw_circle(center, radius * 0.82, ring_color, false, radius * 0.34, true)
	var band_angles: Array[float] = [0.0, PI * 0.5, PI, PI * 1.5]
	for angle: float in band_angles:
		draw_arc(center, radius * 0.82, angle - 0.20, angle + 0.20, 8, Color("fff4dc"), radius * 0.35, true)
	draw_circle(center, radius * 0.43, Color("1d405b"))

func draw_friend_modal_base(viewport_size: Vector2, title: String, modal_height: float = 510.0) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.0, 0.02, 0.05, 0.72))
	var modal_y := maxf(70.0, (viewport_size.y / unit - modal_height) * 0.5)
	var modal := Rect2(Vector2(270.0, modal_y) * unit, Vector2(740.0, modal_height) * unit)
	draw_style_box(make_box(Color("09243a"), 28.0 * unit), modal)
	draw_string(ui_font, modal.position + Vector2(0.0, 65.0) * unit, title, HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(30.0 * unit), Color("ffe25d"))
	var close := friend_modal_close_rect(viewport_size)
	draw_style_box(make_box(Color("d75159"), 13.0 * unit), close)
	draw_string(ui_font, close.position + Vector2(0.0, 33.0) * unit, "סגור" if ui_language == "he" else "CLOSE", HORIZONTAL_ALIGNMENT_CENTER, close.size.x, int(15.0 * unit), Color.WHITE)
	return modal

func draw_friend_customizer(viewport_size: Vector2) -> void:
	var modal := draw_friend_modal_base(viewport_size, ui_text("choose_setup"), 560.0)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var selected_animal: int = player_animal if multiplayer_slot == 0 else ai_animal
	var selected_ring: int = player_ring_color if multiplayer_slot == 0 else ai_ring_color
	draw_string(ui_font, modal.position + Vector2(0.0, 112.0) * unit, "בחרו דמות" if ui_language == "he" else "CHOOSE AN ANIMAL", HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(19.0 * unit), Color.WHITE)
	for i in ANIMAL_NAMES.size():
		var choice := friend_choice_rect(i, false, viewport_size)
		if i == selected_animal:
			draw_style_box(make_box(Color("ffe25d"), 17.0 * unit), choice.grow(6.0 * unit))
		draw_style_box(make_box(Color("1d405b"), 15.0 * unit), choice)
		draw_texture_rect(full_body_animal_textures[i], choice.grow(-7.0 * unit), false)
		draw_collection_lock_overlay(choice, i, false, unit)
		if i == selected_animal:
			draw_circle(choice.position + Vector2(78.0, 14.0) * unit, 12.0 * unit, Color("ffe25d"))
			draw_string(ui_font, choice.position + Vector2(67.0, 19.0) * unit, "✓", HORIZONTAL_ALIGNMENT_CENTER, 22.0 * unit, int(14.0 * unit), Color("173249"))
	draw_string(ui_font, modal.position + Vector2(0.0, 222.0) * unit, "בחרו צבע גלגל" if ui_language == "he" else "CHOOSE A RING COLOR", HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(19.0 * unit), Color.WHITE)
	for i in RING_COLORS.size():
		var color_choice := friend_choice_rect(i, true, viewport_size)
		if i == selected_ring:
			draw_style_box(make_box(Color("ffe25d"), 17.0 * unit), color_choice.grow(6.0 * unit))
		draw_style_box(make_box(Color("1d405b"), 15.0 * unit), color_choice)
		draw_circle(color_choice.get_center(), 29.0 * unit, RING_COLORS[i])
		draw_collection_lock_overlay(color_choice, i, true, unit)
		if i == selected_ring:
			draw_circle(color_choice.get_center(), 36.0 * unit, Color.WHITE, false, 4.0 * unit, true)
	draw_string(ui_font, modal.position + Vector2(0.0, 332.0) * unit, ui_text("choose_board") if is_friend_room_host() else ui_text("guest_board_locked"), HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(19.0 * unit), Color.WHITE)
	var display_board := selected_board_theme if is_friend_room_host() else room_board_theme
	for i in BOARD_THEME_COUNT:
		var board_rect_item := friend_board_rect(i, viewport_size)
		draw_board_theme_card(i, board_rect_item, i == display_board, unit)
		if not is_friend_room_host():
			draw_rect(board_rect_item, Color(0.01, 0.03, 0.08, 0.35))
	if not is_friend_room_host():
		draw_string(ui_font, modal.position + Vector2(0.0, 500.0) * unit, ui_text("host_board_only"), HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(14.0 * unit), Color("a9cde2"))
	draw_string(ui_font, modal.position + Vector2(0.0, 518.0) * unit, ("נבחרו: %s • %s • %s" if ui_language == "he" else "Selected: %s • %s • %s") % [ui_animal_name(selected_animal), ui_ring_name(selected_ring), board_theme_name(display_board)], HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(18.0 * unit), Color("ffe25d"))
	draw_string(ui_font, modal.position + Vector2(0.0, 548.0) * unit, "השינוי חל רק בחדר ובמשחק הנוכחי" if ui_language == "he" else "This choice applies only to this match", HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(16.0 * unit), Color("a9cde2"))

func draw_friend_opponent_profile(viewport_size: Vector2) -> void:
	var modal := draw_friend_modal_base(viewport_size, "פרופיל היריב" if ui_language == "he" else "OPPONENT PROFILE")
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var opponent_slot := 1 - multiplayer_slot
	if opponent_slot < 0 or opponent_slot >= multiplayer_players.size():
		return
	var data: Dictionary = multiplayer_players[opponent_slot]
	var animal := int(data.get("animal", 0))
	draw_texture_rect(full_body_animal_textures[animal], Rect2(modal.position + Vector2(55.0, 105.0) * unit, Vector2(240.0, 300.0) * unit), false)
	draw_string(ui_font, modal.position + Vector2(330.0, 155.0) * unit, str(data.get("name", "Player")), HORIZONTAL_ALIGNMENT_LEFT, 330.0 * unit, int(30.0 * unit), Color.WHITE)
	draw_string(ui_font, modal.position + Vector2(330.0, 205.0) * unit, ("רמה: %d" if ui_language == "he" else "Level: %d") % int(data.get("level", 1)), HORIZONTAL_ALIGNMENT_LEFT, 330.0 * unit, int(20.0 * unit), Color("a9cde2"))
	draw_string(ui_font, modal.position + Vector2(330.0, 250.0) * unit, ("דמות: " if ui_language == "he" else "Animal: ") + ui_animal_name(animal), HORIZONTAL_ALIGNMENT_LEFT, 330.0 * unit, int(20.0 * unit), Color("ffe25d"))
	draw_string(ui_font, modal.position + Vector2(330.0, 290.0) * unit, ("גלגל: " if ui_language == "he" else "Ring: ") + ui_ring_name(int(data.get("ringColor", 0))), HORIZONTAL_ALIGNMENT_LEFT, 330.0 * unit, int(20.0 * unit), Color("ffe25d"))
	draw_string(ui_font, modal.position + Vector2(330.0, 350.0) * unit, ("ניצחונות: %d  •  הפסדים: %d" if ui_language == "he" else "Wins: %d  •  Losses: %d") % [int(data.get("wins", 0)), int(data.get("losses", 0))], HORIZONTAL_ALIGNMENT_LEFT, 350.0 * unit, int(19.0 * unit), Color.WHITE)
	draw_string(ui_font, modal.position + Vector2(0.0, 465.0) * unit, "אפשרויות חברתיות ונתונים נוספים יתווספו בהמשך" if ui_language == "he" else "More social options and stats are coming later", HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(16.0 * unit), Color("70dfff"))

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

func draw_arena_tunnel_fx(viewport_size: Vector2, intensity: float) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var center := viewport_size * 0.5
	for ring in 8:
		var phase := arena_fx_elapsed * (1.4 + float(ring) * 0.18) + float(ring) * 0.7
		var radius := fmod(phase, 1.0) * maxf(viewport_size.x, viewport_size.y) * 0.62
		var alpha := (1.0 - fmod(phase, 1.0)) * 0.14 * intensity
		draw_arc(center, radius, 0.0, TAU, 72, Color("8cecff", alpha), 3.0 * unit, true)
	for ray in 12:
		var angle := arena_fx_elapsed * 0.9 + float(ray) * TAU / 12.0
		var length := maxf(viewport_size.x, viewport_size.y) * 0.55
		var end := center + Vector2(cos(angle), sin(angle)) * length
		draw_line(center, end, Color("ffe25d", 0.03 * intensity), 2.0 * unit, true)

func draw_arena_match_found_flash(viewport_size: Vector2) -> void:
	if arena_fx_phase != "found":
		return
	var progress := clampf(arena_fx_elapsed / ARENA_MATCH_FOUND_DURATION, 0.0, 1.0)
	var flash := 0.0
	if progress < 0.18:
		flash = 1.0 - progress / 0.18
	elif progress > 0.82:
		flash = (progress - 0.82) / 0.18
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(1.0, 0.96, 0.72, flash * 0.42))
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var banner := Rect2(viewport_size.x * 0.22, 34.0 * unit, viewport_size.x * 0.56, 72.0 * unit)
	var pulse := 0.92 + sin(arena_fx_elapsed * 8.0) * 0.08
	draw_style_box(make_box(Color("ffe25d", 0.92 * pulse), 20.0 * unit), banner)
	draw_string(ui_font, banner.position + Vector2(0.0, 48.0) * unit, ui_text("match_found"), HORIZONTAL_ALIGNMENT_CENTER, banner.size.x, int(34.0 * unit), Color("173249"))
	if progress > 0.45:
		draw_string(ui_font, Vector2(0.0, banner.end.y + 18.0 * unit), ui_text("entering_arena"), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(16.0 * unit), Color("ffe25d"))

func draw_matchmaking_card(rect: Rect2, is_local_player: bool, unit: float, opponent: Dictionary = {}) -> void:
	var accent: Color = RING_COLORS[clampi(player_ring_color, 0, RING_COLORS.size() - 1)] if is_local_player else Color("3fb6df")
	if not is_local_player and not opponent.is_empty():
		accent = RING_COLORS[clampi(int(opponent.get("ringColor", 2)), 0, RING_COLORS.size() - 1)]
	var card_glow := 7.0
	if not is_local_player and arena_fx_phase == "found":
		card_glow = 7.0 + sin(arena_fx_elapsed * 7.0) * 4.0
	draw_style_box(make_box(Color(0.01, 0.04, 0.08, 0.94), 24.0 * unit), rect.grow(card_glow * unit))
	draw_style_box(make_box(Color("f5f2df"), 20.0 * unit), rect)
	var portrait := Rect2(rect.position + Vector2(15.0, 15.0) * unit, Vector2(rect.size.x - 30.0 * unit, rect.size.y - 96.0 * unit))
	draw_style_box(make_box(accent.darkened(0.42), 16.0 * unit), portrait)
	draw_circle(portrait.get_center(), 112.0 * unit, Color(accent, 0.23))
	if is_local_player:
		var hero: Texture2D = null
		if player_animal >= 0 and player_animal < lifebuoy_hero_textures.size():
			var colors: Array = lifebuoy_hero_textures[player_animal]
			if player_ring_color >= 0 and player_ring_color < colors.size():
				hero = colors[player_ring_color] as Texture2D
		if hero != null:
			var hero_size := Vector2(210.0, 270.0) * unit
			draw_texture_rect(hero, Rect2(portrait.get_center() - hero_size * 0.5 + Vector2(0.0, 8.0) * unit, hero_size), false)
		elif full_body_animal_textures[player_animal] != null:
			draw_texture_rect(full_body_animal_textures[player_animal], portrait.grow(-22.0 * unit), false)
	else:
		var matched := not opponent.is_empty()
		if matched:
			var opponent_animal := clampi(int(opponent.get("animal", 0)), 0, ANIMAL_NAMES.size() - 1)
			var opponent_ring := clampi(int(opponent.get("ringColor", 0)), 0, RING_COLORS.size() - 1)
			var hero: Texture2D = null
			if opponent_animal >= 0 and opponent_animal < lifebuoy_hero_textures.size():
				var colors: Array = lifebuoy_hero_textures[opponent_animal]
				if opponent_ring >= 0 and opponent_ring < colors.size():
					hero = colors[opponent_ring] as Texture2D
			if hero != null:
				var hero_size := Vector2(210.0, 270.0) * unit
				draw_texture_rect(hero, Rect2(portrait.get_center() - hero_size * 0.5 + Vector2(0.0, 8.0) * unit, hero_size), false)
			elif opponent_animal < full_body_animal_textures.size() and full_body_animal_textures[opponent_animal] != null:
				draw_texture_rect(full_body_animal_textures[opponent_animal], portrait.grow(-22.0 * unit), false)
		else:
			# Cycle silhouettes while searching to suggest many possible opponents,
			# but never pretend that a specific player has already been found.
			var preview_animal := int(floor(menu_elapsed * 2.5)) % ANIMAL_NAMES.size()
			var preview_texture: Texture2D = full_body_animal_textures[preview_animal]
			if preview_texture != null:
				var silhouette_size := Vector2(190.0, 250.0) * unit
				draw_texture_rect(preview_texture, Rect2(portrait.get_center() - silhouette_size * 0.5 + Vector2(0.0, 12.0) * unit, silhouette_size), false, Color(0.04, 0.12, 0.18, 0.72))
			draw_circle(portrait.get_center() + Vector2(0.0, 5.0) * unit, 40.0 * unit, Color(0.03, 0.08, 0.12, 0.78))
			draw_string(ui_font, portrait.get_center() + Vector2(-31.0, 20.0) * unit, "?", HORIZONTAL_ALIGNMENT_CENTER, 62.0 * unit, int(54.0 * unit), Color.WHITE)
	var name_bar := Rect2(rect.position + Vector2(0.0, rect.size.y - 70.0 * unit), Vector2(rect.size.x, 70.0 * unit))
	draw_style_box(make_box(Color("ffffff"), 0.0), name_bar)
	var card_name := profile_name if is_local_player else ("מחפשים..." if ui_language == "he" else "SEARCHING...")
	if not is_local_player and not opponent.is_empty():
		card_name = str(opponent.get("name", card_name))
	draw_string(ui_font, name_bar.position + Vector2(10.0, 31.0) * unit, card_name, HORIZONTAL_ALIGNMENT_CENTER, name_bar.size.x - 20.0 * unit, int(21.0 * unit), Color("173249"))
	var detail := player_level_label() if is_local_player else ("יריב מתאים יצטרף בקרוב" if ui_language == "he" else "A MATCHED OPPONENT WILL APPEAR")
	if not is_local_player and not opponent.is_empty():
		detail = ("דירוג: %d" if ui_language == "he" else "RATING: %d") % int(opponent.get("rating", 1000))
	draw_string(ui_font, name_bar.position + Vector2(10.0, 54.0) * unit, detail, HORIZONTAL_ALIGNMENT_CENTER, name_bar.size.x - 20.0 * unit, int(11.0 * unit), Color("5f7180"))
	var badge_center := rect.position + Vector2(24.0, 24.0) * unit
	draw_circle(badge_center, 23.0 * unit, Color("ffe25d") if is_local_player else Color("59d7f0"))
	var badge_value := str(player_level) if is_local_player else "?"
	if not is_local_player and not opponent.is_empty():
		badge_value = str(int(opponent.get("level", 1)))
	draw_string(ui_font, badge_center + Vector2(-18.0, 7.0) * unit, badge_value, HORIZONTAL_ALIGNMENT_CENTER, 36.0 * unit, int(17.0 * unit), Color("173249"))

func draw_arena_search_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_arena_tunnel_fx(viewport_size, 1.0 if arena_fx_phase == "searching" else 1.35)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.005, 0.035, 0.07, 0.70))
	var header_title := "מחפשים יריב" if ui_language == "he" else "FINDING AN OPPONENT"
	if arena_fx_phase == "found":
		header_title = ui_text("match_found")
	draw_frontend_header(viewport_size, header_title, "זירה אונליין" if ui_language == "he" else "ONLINE ARENA")
	var card_size := Vector2(300.0, 390.0) * unit
	var gap := 105.0 * unit
	var total_width := card_size.x * 2.0 + gap
	var start_x := (viewport_size.x - total_width) * 0.5
	var card_y := 132.0 * unit
	if arena_fx_phase == "found":
		var snap := 1.0 - pow(1.0 - clampf(arena_fx_elapsed / 0.45, 0.0, 1.0), 3.0)
		card_y = lerpf(180.0 * unit, 132.0 * unit, snap)
	var local_card := Rect2(Vector2(start_x, card_y), card_size)
	var opponent_card := Rect2(Vector2(start_x + card_size.x + gap, card_y), card_size)
	var opponent_data := arena_matched_opponent if arena_fx_phase == "found" else {}
	draw_matchmaking_card(local_card, true, unit)
	draw_matchmaking_card(opponent_card, false, unit, opponent_data)
	var vs_center := Vector2(viewport_size.x * 0.5, card_y + card_size.y * 0.48)
	var vs_pulse := 62.0 + sin(menu_elapsed * 3.0) * 4.0
	if arena_fx_phase == "found":
		vs_pulse = 68.0 + sin(arena_fx_elapsed * 9.0) * 8.0
	draw_circle(vs_center, vs_pulse * unit, Color(0.02, 0.08, 0.13, 0.92))
	draw_circle(vs_center, 55.0 * unit, Color("7bdc1f") if arena_fx_phase != "found" else Color("ffe25d"), false, 7.0 * unit, true)
	draw_string(ui_font, vs_center + Vector2(-58.0, 20.0) * unit, "VS", HORIZONTAL_ALIGNMENT_CENTER, 116.0 * unit, int(48.0 * unit), Color("b6f13f"))
	var dots: String = [".", "..", "..."][int(menu_elapsed * 2.2) % 3]
	var status_line := ("מחפשים יריב מתאים" if ui_language == "he" else "SEARCHING FOR A MATCH") + dots
	if arena_fx_phase == "found":
		status_line = str(opponent_data.get("name", "")) + (" מוכן לקרב!" if ui_language == "he" else " is ready!")
	draw_string(ui_font, Vector2(0.0, 566.0 * unit), status_line, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(22.0 * unit), Color("ffe25d"))
	var arena_names := [ui_text("sakura"), ui_text("bamboo"), ui_text("volcano")]
	draw_string(ui_font, Vector2(0.0, 598.0 * unit), ("הזירה שנבחרה: " if ui_language == "he" else "SELECTED ARENA: ") + arena_names[clampi(selected_arena, 0, 2)], HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(14.0 * unit), Color("c9edf7"))
	var cancel := arena_play_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.92), 18.0 * unit), cancel.grow(5.0 * unit))
	draw_style_box(make_box(Color("d94b45"), 16.0 * unit), cancel)
	draw_string(ui_font, cancel.position + Vector2(0.0, 38.0) * unit, ui_text("cancel_search"), HORIZONTAL_ALIGNMENT_CENTER, cancel.size.x, int(20.0 * unit), Color.WHITE)
	draw_arena_match_found_flash(viewport_size)

func draw_arena_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	if matchmaking_searching or arena_fx_phase == "found":
		draw_arena_search_screen(viewport_size)
		return
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.42))
	draw_frontend_header(viewport_size, ui_text("arena_title"), ui_text("arena_title_sub"))
	var names := [ui_text("sakura"), ui_text("bamboo"), ui_text("volcano")]
	var entries := [0, 100, 500]
	var prizes := [100, 250, 1200]
	var card_colors := [Color("f08aac"), Color("62b55d"), Color("e65b36")]
	for i in 3:
		var card := arena_card_rect(i, viewport_size)
		var selected := i == selected_arena
		var pulse := sin(menu_elapsed * 4.2 + float(i) * 0.8) * 3.0 if selected else 0.0
		var border := Color("ffe25d") if selected else Color(0.02, 0.07, 0.12, 0.92)
		draw_style_box(make_box(border, 25.0 * unit), card.grow((8.0 + pulse if selected else 5.0) * unit))
		draw_style_box(make_box(Color("f8f2cf"), 22.0 * unit), card)
		if selected:
			draw_style_box(make_box(Color("ffe25d", 0.18 + sin(menu_elapsed * 5.0) * 0.08), 24.0 * unit), card.grow(10.0 * unit))
		var preview := Rect2(card.position + Vector2(15.0, 15.0) * unit, Vector2(card.size.x - 30.0 * unit, 205.0 * unit))
		draw_style_box(make_box(card_colors[i], 17.0 * unit), preview.grow(3.0 * unit))
		draw_arena_preview(preview, i, unit)
		var title_rect := Rect2(card.position + Vector2(15.0, 232.0) * unit, Vector2(card.size.x - 30.0 * unit, 54.0 * unit))
		draw_style_box(make_box(Color("314f22"), 13.0 * unit), title_rect)
		draw_string(ui_font, title_rect.position + Vector2(0.0, 36.0) * unit, names[i], HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, int(21.0 * unit), Color.WHITE)
		var entry_text := ui_text("entry_free") if entries[i] == 0 else ui_text("entry") + str(entries[i]) + ui_text("coins")
		draw_string(ui_font, card.position + Vector2(22.0, 325.0) * unit, entry_text, HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 44.0 * unit, int(15.0 * unit), Color("354522"))
		draw_string(ui_font, card.position + Vector2(22.0, 363.0) * unit, ui_text("prize") + str(prizes[i]) + ui_text("coins"), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 44.0 * unit, int(17.0 * unit), Color("a66013"))
		draw_string(ui_font, card.position + Vector2(22.0, 392.0) * unit, ui_text("arena_board_fixed") + ": " + board_theme_name(arena_board_theme_for_level(i)), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 44.0 * unit, int(13.0 * unit), Color("2982a6"))
		if selected:
			draw_string(ui_font, card.position + Vector2(0.0, 408.0) * unit, ui_text("selected"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(15.0 * unit), Color("16845b"))
	var play := arena_play_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.90), 18.0 * unit), play.grow(5.0 * unit))
	draw_style_box(make_box(Color("d49b2f") if matchmaking_searching else Color("6fda18"), 16.0 * unit), play)
	draw_string(ui_font, play.position + Vector2(0.0, 38.0) * unit, ui_text("cancel_search") if matchmaking_searching else ui_text("find_match"), HORIZONTAL_ALIGNMENT_CENTER, play.size.x, int(20.0 * unit), Color.WHITE)
	if matchmaking_searching:
		draw_string(ui_font, Vector2(0.0, play.position.y - 28.0 * unit), ui_text("searching"), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(16.0 * unit), Color("ffe25d"))

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
		var ground_offset: float = hero_size.y * float(HERO_GROUND_OFFSETS[clampi(player_animal, 0, HERO_GROUND_OFFSETS.size() - 1)])
		var hero_center := hero_panel.position + Vector2(hero_panel.size.x * 0.50, 186.0 * unit + ground_offset)
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
		draw_collection_lock_overlay(animal_rect, i, false, unit)
	draw_string(ui_font, hero_panel.position + Vector2(22.0, 506.0) * unit, ui_text("favorite_color"), HORIZONTAL_ALIGNMENT_CENTER, hero_panel.size.x - 44.0 * unit, int(12.0 * unit), Color("173249"))
	for i in RING_COLORS.size():
		var color_rect := player_profile_color_rect(i, viewport_size)
		var color_center := color_rect.get_center()
		if i == player_ring_color:
			draw_circle(color_center, 25.0 * unit, Color.WHITE)
			draw_circle(color_center, 21.0 * unit, Color("ffe25d"))
		draw_circle(color_center, 17.0 * unit, RING_COLORS[i])
		draw_collection_lock_overlay(color_rect, i, true, unit)

	var info_panel := Rect2(Vector2(474.0, 102.0) * unit, Vector2(768.0, 570.0) * unit)
	draw_style_box(make_box(Color(0.02, 0.08, 0.14, 0.92), 27.0 * unit), info_panel.grow(5.0 * unit))
	draw_style_box(make_box(Color("eaf8f1"), 24.0 * unit), info_panel)
	draw_circle(info_panel.position + Vector2(66.0, 69.0) * unit, 45.0 * unit, Color("6965d8"))
	draw_string(ui_font, info_panel.position + Vector2(21.0, 84.0) * unit, profile_initial(), HORIZONTAL_ALIGNMENT_CENTER, 90.0 * unit, int(42.0 * unit), Color.WHITE)
	draw_string(ui_font, info_panel.position + Vector2(130.0, 32.0) * unit, "שם השחקן" if ui_language == "he" else "PLAYER NAME", HORIZONTAL_ALIGNMENT_LEFT, 350.0 * unit, int(13.0 * unit), Color("2982a6"))
	var coin_box := Rect2(info_panel.position + Vector2(558.0, 27.0) * unit, Vector2(176.0, 74.0) * unit)
	draw_style_box(make_box(Color("253e67"), 17.0 * unit), coin_box)
	draw_circle(coin_box.position + Vector2(35.0, 37.0) * unit, 17.0 * unit, Color("ffc83d"))
	draw_string(ui_font, coin_box.position + Vector2(65.0, 47.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 95.0 * unit, int(22.0 * unit), Color.WHITE)
	var xp_rect := Rect2(info_panel.position + Vector2(130.0, 104.0) * unit, Vector2(400.0, 20.0) * unit)
	draw_style_box(make_box(Color("cadbd5"), 9.0 * unit), xp_rect)
	var xp_ratio := clampf(float(player_xp) / float(maxi(1, player_next_level_xp)), 0.0, 1.0)
	draw_style_box(make_box(Color("49c984"), 9.0 * unit), Rect2(xp_rect.position, Vector2(xp_rect.size.x * xp_ratio, xp_rect.size.y)))
	draw_string(ui_font, info_panel.position + Vector2(545.0, 121.0) * unit, str(player_xp) + " / " + str(player_next_level_xp) + " XP", HORIZONTAL_ALIGNMENT_LEFT, 170.0 * unit, int(11.0 * unit), Color("526b72"))
	var account_type := ("Google: " + firebase_email) if firebase_provider == "google" else ("חשבון אורח" if ui_language == "he" else "GUEST ACCOUNT")
	draw_string(ui_font, info_panel.position + Vector2(130.0, 148.0) * unit, account_type + " • " + firebase_status + " • " + CLIENT_VERSION, HORIZONTAL_ALIGNMENT_LEFT, 585.0 * unit, int(14.0 * unit), Color("2982a6"))
	draw_string(ui_font, info_panel.position + Vector2(30.0, 165.0) * unit, ui_text("career"), HORIZONTAL_ALIGNMENT_CENTER, info_panel.size.x - 60.0 * unit, int(20.0 * unit), Color("173249"))
	var total_matches := player_wins + player_losses
	var win_rate := 0
	if total_matches > 0:
		win_rate = int(round(float(player_wins) * 100.0 / float(total_matches)))
	var labels := [ui_text("matches"), ui_text("wins"), ui_text("losses"), ui_text("win_rate"), ui_text("best_streak"), ui_text("world_rank")]
	var rank_value := ("—" if player_world_rank <= 0 else "#" + str(player_world_rank)) if player_wins + player_losses > 0 else str(player_rating)
	var values := [str(total_matches), str(player_wins), str(player_losses), str(win_rate) + "%", str(player_best_streak), rank_value]
	var accents := [Color("42b8e8"), Color("49c984"), Color("ef6b65"), Color("ffc83d"), Color("9d59e8"), Color("ff8b3d")]
	for i in 6:
		var column := i % 2
		var row := i / 2
		var stat_rect := Rect2(info_panel.position + Vector2(30.0 + float(column) * 354.0, 190.0 + float(row) * 112.0) * unit, Vector2(330.0, 88.0) * unit)
		draw_profile_stat_card(stat_rect, labels[i], values[i], accents[i], unit)
	var id_box := Rect2(info_panel.position + Vector2(30.0, 518.0) * unit, Vector2(350.0, 42.0) * unit)
	draw_style_box(make_box(Color("d8eee8"), 12.0 * unit), id_box)
	var pending_id := "מתחבר..." if ui_language == "he" else "CONNECTING..."
	var account_id_text := ("מזהה אישי: " if ui_language == "he" else "PLAYER ID: ") + (firebase_public_id if not firebase_public_id.is_empty() else pending_id)
	draw_string(ui_font, id_box.position + Vector2(16.0, 29.0) * unit, account_id_text, HORIZONTAL_ALIGNMENT_LEFT, id_box.size.x - 32.0 * unit, int(18.0 * unit), Color("173249"))
	var google_rect := player_google_rect(viewport_size)
	var google_connected := firebase_provider == "google"
	draw_style_box(make_box(Color("4c9a68") if google_connected else Color("4285f4"), 12.0 * unit), google_rect)
	var google_label := ("Google מחובר" if ui_language == "he" else "GOOGLE LINKED") if google_connected else ("חיבור Google" if ui_language == "he" else "CONNECT GOOGLE")
	draw_string(ui_font, google_rect.position + Vector2(0.0, 29.0) * unit, google_label, HORIZONTAL_ALIGNMENT_CENTER, google_rect.size.x, int(15.0 * unit), Color.WHITE)
	var copy_rect := player_id_copy_rect(viewport_size)
	draw_style_box(make_box(Color("2982a6") if not firebase_public_id.is_empty() else Color("70858d"), 12.0 * unit), copy_rect)
	draw_string(ui_font, copy_rect.position + Vector2(0.0, 29.0) * unit, "העתקה" if ui_language == "he" else "COPY ID", HORIZONTAL_ALIGNMENT_CENTER, copy_rect.size.x, int(16.0 * unit), Color.WHITE)

func draw_home_social_panel(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var panel := home_social_panel_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.13, 0.93), 22.0 * unit), panel.grow(5.0 * unit))
	draw_style_box(make_box(Color(0.04, 0.12, 0.20, 0.97), 20.0 * unit), panel)
	draw_string(ui_font, panel.position + Vector2(0.0, 34.0) * unit, ui_text("social_hub"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(18.0 * unit), Color("f6d365"))
	for tab in 3:
		var tab_rect := home_social_tab_rect(tab, viewport_size)
		var selected := tab == home_social_tab
		draw_style_box(make_box(Color("315fd0") if selected else Color("1d405b"), 14.0 * unit), tab_rect)
		var tab_label := ui_text("friends_tab")
		if tab == 1:
			tab_label = ui_text("chat_tab")
		elif tab == 2:
			tab_label = ui_text("league_tab")
		draw_string(ui_font, tab_rect.position + Vector2(0.0, 26.0) * unit, tab_label, HORIZONTAL_ALIGNMENT_CENTER, tab_rect.size.x, int(13.0 * unit), Color.WHITE)
	if home_social_tab == 0:
		var incoming_count := mini(2, incoming_friend_requests.size())
		if incoming_count > 0:
			draw_string(ui_font, panel.position + Vector2(0.0, 84.0) * unit, ui_text("friend_requests_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(12.0 * unit), Color("ffe25d"))
		for i in incoming_count:
			var request_row := home_incoming_request_rect(i, viewport_size)
			var request_entry: Dictionary = incoming_friend_requests[i]
			var request_name := friend_request_display_name(request_entry)
			draw_style_box(make_box(Color("2a4560"), 12.0 * unit), request_row)
			draw_circle(request_row.position + Vector2(22.0, 24.0) * unit, 14.0 * unit, Color("ffe25d"))
			draw_string(ui_font, request_row.position + Vector2(14.0, 30.0) * unit, request_name.substr(0, 1), HORIZONTAL_ALIGNMENT_CENTER, 16.0 * unit, int(14.0 * unit), Color("173249"))
			draw_string(ui_font, request_row.position + Vector2(42.0, 20.0) * unit, request_name, HORIZONTAL_ALIGNMENT_LEFT, request_row.size.x - 170.0 * unit, int(13.0 * unit), Color.WHITE)
			draw_string(ui_font, request_row.position + Vector2(42.0, 36.0) * unit, str(request_entry.get("id", "")), HORIZONTAL_ALIGNMENT_LEFT, request_row.size.x - 170.0 * unit, int(9.0 * unit), Color("8cecff"))
			var accept_rect := home_incoming_accept_rect(i, viewport_size)
			var decline_rect := home_incoming_decline_rect(i, viewport_size)
			draw_style_box(make_box(Color("35b96f"), 10.0 * unit), accept_rect)
			draw_style_box(make_box(Color("e94f78"), 10.0 * unit), decline_rect)
			draw_string(ui_font, accept_rect.position + Vector2(0.0, 22.0) * unit, ui_text("friend_request_accept"), HORIZONTAL_ALIGNMENT_CENTER, accept_rect.size.x, int(11.0 * unit), Color.WHITE)
			draw_string(ui_font, decline_rect.position + Vector2(0.0, 22.0) * unit, ui_text("friend_request_decline"), HORIZONTAL_ALIGNMENT_CENTER, decline_rect.size.x, int(11.0 * unit), Color.WHITE)
		var visible_count := mini(3, friends_list.size())
		if visible_count == 0 and incoming_count == 0 and outgoing_friend_requests.is_empty():
			draw_string(ui_font, panel.position + Vector2(0.0, 170.0) * unit, ui_text("no_friends"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 20.0 * unit, int(14.0 * unit), Color("8cecff"))
		for i in visible_count:
			var row := home_friend_row_rect(i, viewport_size)
			var friend_entry: Dictionary = friends_list[i]
			var display_name := friend_display_name(friend_entry)
			var is_online := bool(friend_entry.get("online", false))
			var selected := i == home_friend_profile_index
			draw_style_box(make_box(Color("244d70") if selected else Color("173249"), 14.0 * unit), row)
			draw_circle(row.position + Vector2(24.0, 26.0) * unit, 16.0 * unit, Color("35b96f") if is_online else Color("ef6b65"))
			draw_circle(row.position + Vector2(24.0, 26.0) * unit, 6.0 * unit, Color.WHITE if is_online else Color("ffd0d0"))
			var initial := display_name.substr(0, 1)
			draw_string(ui_font, row.position + Vector2(16.0, 32.0) * unit, initial, HORIZONTAL_ALIGNMENT_CENTER, 16.0 * unit, int(16.0 * unit), Color.WHITE)
			draw_string(ui_font, row.position + Vector2(48.0, 22.0) * unit, display_name, HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 150.0 * unit, int(15.0 * unit), Color.WHITE)
			var status_text := ui_text("friend_online") if is_online else ui_text("friend_offline")
			draw_string(ui_font, row.position + Vector2(48.0, 40.0) * unit, status_text, HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 150.0 * unit, int(10.0 * unit), Color("35b96f") if is_online else Color("ef6b65"))
			var invite_rect := home_friend_invite_rect(i, viewport_size)
			draw_style_box(make_box(Color("35b96f") if is_online else Color("5a6675"), 10.0 * unit), invite_rect)
			draw_string(ui_font, invite_rect.position + Vector2(0.0, 22.0) * unit, ui_text("invite_friend"), HORIZONTAL_ALIGNMENT_CENTER, invite_rect.size.x, int(12.0 * unit), Color.WHITE)
		if not outgoing_friend_requests.is_empty():
			var pending_y := home_friends_content_top(viewport_size) + float(mini(3, friends_list.size())) * 58.0 * unit + 6.0 * unit
			draw_string(ui_font, panel.position + Vector2(18.0 * unit, pending_y), ui_text("friend_request_pending") + " (" + str(outgoing_friend_requests.size()) + ")", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 36.0 * unit, int(11.0 * unit), Color("ffe25d"))
		draw_style_box(make_box(Color("10283b"), 12.0 * unit), home_add_friend_rect(viewport_size))
		draw_style_box(make_box(Color("7655df"), 14.0 * unit), home_add_friend_button_rect(viewport_size))
		draw_string(ui_font, home_add_friend_button_rect(viewport_size).position + Vector2(0.0, 24.0) * unit, ui_text("add_friend"), HORIZONTAL_ALIGNMENT_CENTER, home_add_friend_button_rect(viewport_size).size.x, int(15.0 * unit), Color.WHITE)
	elif home_social_tab == 1:
		draw_string(ui_font, panel.position + Vector2(0.0, 72.0) * unit, ui_text("lobby_chat_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(14.0 * unit), Color("a9cde2"))
		var first_index: int = maxi(0, lobby_chat_messages.size() - 7)
		var row := 0
		for i in range(first_index, lobby_chat_messages.size()):
			var message: Dictionary = lobby_chat_messages[i]
			var line := str(message.get("name", "")) + ": " + str(message.get("message", ""))
			draw_string(ui_font, panel.position + Vector2(18.0 * unit, 104.0 * unit + row * 34.0 * unit), line, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 36.0 * unit, int(14.0 * unit), Color("d7f6ff"))
			row += 1
		var input_bg := Rect2(panel.position + Vector2(14.0 * unit, panel.size.y - 52.0 * unit), Vector2(panel.size.x - 118.0 * unit, 36.0 * unit))
		draw_style_box(make_box(Color("10283b"), 12.0 * unit), input_bg)
		draw_style_box(make_box(Color("12a96b"), 12.0 * unit), home_lobby_send_rect(viewport_size))
		draw_string(ui_font, home_lobby_send_rect(viewport_size).position + Vector2(0.0, 24.0) * unit, "שליחה" if ui_language == "he" else "SEND", HORIZONTAL_ALIGNMENT_CENTER, home_lobby_send_rect(viewport_size).size.x, int(14.0 * unit), Color.WHITE)
	else:
		draw_string(ui_font, panel.position + Vector2(0.0, 72.0) * unit, ui_text("leaderboard_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(14.0 * unit), Color("a9cde2"))
		var league_rect := Rect2(panel.position + Vector2(14.0 * unit, 88.0 * unit), Vector2(panel.size.x - 28.0 * unit, 52.0 * unit))
		draw_style_box(make_box(league_color(player_league_tier), 14.0 * unit), league_rect)
		draw_string(ui_font, league_rect.position + Vector2(14.0, 22.0) * unit, league_name(player_league_tier), HORIZONTAL_ALIGNMENT_LEFT, league_rect.size.x - 28.0 * unit, int(16.0 * unit), Color.WHITE)
		draw_string(ui_font, league_rect.position + Vector2(14.0, 42.0) * unit, ui_text("rating_label") + ": " + str(player_rating), HORIZONTAL_ALIGNMENT_LEFT, league_rect.size.x - 28.0 * unit, int(12.0 * unit), Color("173249"))
		var board_count := mini(5, global_leaderboard.size())
		if board_count == 0:
			draw_string(ui_font, panel.position + Vector2(0.0, 210.0) * unit, "..." if ui_language == "he" else "Loading rankings...", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(13.0 * unit), Color("8cecff"))
		for i in board_count:
			var entry: Dictionary = global_leaderboard[i]
			var row_y := 154.0 + float(i) * 46.0
			var row := Rect2(panel.position + Vector2(14.0 * unit, row_y * unit), Vector2(panel.size.x - 28.0 * unit, 40.0 * unit))
			var is_me := str(entry.get("publicId", "")) == firebase_public_id
			draw_style_box(make_box(Color("ffe6a8") if is_me else Color("173249"), 12.0 * unit), row)
			var row_color := Color("173249") if is_me else Color.WHITE
			draw_string(ui_font, row.position + Vector2(10.0, 26.0) * unit, "#" + str(entry.get("rank", i + 1)) + " " + str(entry.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 90.0 * unit, int(13.0 * unit), row_color)
			draw_string(ui_font, row.position + Vector2(row.size.x - 72.0 * unit, 26.0) * unit, str(entry.get("rating", 0)), HORIZONTAL_ALIGNMENT_CENTER, 62.0 * unit, int(13.0 * unit), row_color)

func draw_home_friend_profile(viewport_size: Vector2) -> void:
	if home_friend_profile_index < 0 or home_friend_profile_index >= friends_list.size():
		return
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.72))
	var modal := home_friend_profile_modal_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.13, 0.96), 24.0 * unit), modal.grow(6.0 * unit))
	draw_style_box(make_box(Color("eaf8f1"), 22.0 * unit), modal)
	draw_string(ui_font, modal.position + Vector2(0.0, 34.0) * unit, ui_text("friend_profile_title"), HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(18.0 * unit), Color("173249"))
	draw_string(ui_font, home_friend_profile_close_rect(viewport_size).position + Vector2(0.0, 24.0) * unit, "×", HORIZONTAL_ALIGNMENT_CENTER, home_friend_profile_close_rect(viewport_size).size.x, int(22.0 * unit), Color("607080"))
	var friend_entry: Dictionary = friends_list[home_friend_profile_index]
	var display_name := friend_display_name(friend_entry)
	var avatar_center := modal.position + Vector2(modal.size.x * 0.5, 92.0 * unit)
	draw_circle(avatar_center, 34.0 * unit, Color("6965d8"))
	draw_string(ui_font, avatar_center + Vector2(-18.0, 12.0) * unit, display_name.substr(0, 1), HORIZONTAL_ALIGNMENT_CENTER, 36.0 * unit, int(28.0 * unit), Color.WHITE)
	draw_string(ui_font, modal.position + Vector2(0.0, 148.0) * unit, display_name, HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(22.0 * unit), Color("173249"))
	draw_string(ui_font, modal.position + Vector2(0.0, 174.0) * unit, str(friend_entry.get("id", "")), HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(12.0 * unit), Color("527184"))
	var online_text := ui_text("friend_online") if bool(friend_entry.get("online", false)) else ui_text("friend_offline")
	var online_color := Color("35b96f") if bool(friend_entry.get("online", false)) else Color("ef6b65")
	draw_string(ui_font, modal.position + Vector2(0.0, 198.0) * unit, online_text, HORIZONTAL_ALIGNMENT_CENTER, modal.size.x, int(13.0 * unit), online_color)
	var stats := Rect2(modal.position + Vector2(24.0 * unit, 214.0 * unit), Vector2(modal.size.x - 48.0 * unit, 72.0 * unit))
	draw_style_box(make_box(Color("d8f2fb"), 14.0 * unit), stats)
	draw_string(ui_font, stats.position + Vector2(14.0, 24.0) * unit, league_name(int(friend_entry.get("leagueTier", 0))), HORIZONTAL_ALIGNMENT_LEFT, stats.size.x - 28.0 * unit, int(14.0 * unit), Color("173249"))
	draw_string(ui_font, stats.position + Vector2(14.0, 44.0) * unit, ui_text("rating_label") + ": " + str(friend_entry.get("rating", 1000)), HORIZONTAL_ALIGNMENT_LEFT, stats.size.x - 28.0 * unit, int(12.0 * unit), Color("527184"))
	draw_string(ui_font, stats.position + Vector2(14.0, 62.0) * unit, ui_text("wins") + ": " + str(friend_entry.get("wins", 0)) + "  " + ui_text("losses") + ": " + str(friend_entry.get("losses", 0)), HORIZONTAL_ALIGNMENT_LEFT, stats.size.x - 28.0 * unit, int(12.0 * unit), Color("527184"))
	var invite_rect := home_friend_profile_invite_rect(viewport_size)
	var can_invite := bool(friend_entry.get("online", false))
	draw_style_box(make_box(Color("35b96f") if can_invite else Color("5a6675"), 12.0 * unit), invite_rect)
	draw_string(ui_font, invite_rect.position + Vector2(0.0, 26.0) * unit, ui_text("invite_friend"), HORIZONTAL_ALIGNMENT_CENTER, invite_rect.size.x, int(14.0 * unit), Color.WHITE)
	draw_style_box(make_box(Color("e94f78"), 12.0 * unit), home_friend_profile_remove_rect(viewport_size))
	draw_string(ui_font, home_friend_profile_remove_rect(viewport_size).position + Vector2(0.0, 26.0) * unit, ui_text("remove_friend"), HORIZONTAL_ALIGNMENT_CENTER, home_friend_profile_remove_rect(viewport_size).size.x, int(14.0 * unit), Color.WHITE)

func draw_home_screen(viewport_size: Vector2) -> void:
	var layout := home_layout(viewport_size)
	var unit: float = layout.unit
	draw_home_ambient_effects(viewport_size)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.10))
	draw_rect(Rect2(0.0, 0.0, viewport_size.x, layout.header_h), Color(0.015, 0.055, 0.12, 0.94))
	draw_rect(Rect2(0.0, layout.header_h - 4.0 * unit, viewport_size.x, 4.0 * unit), Color("58c9e8"))
	var left_bg_w: float = layout.left_x + layout.left_w + 10.0 * unit
	draw_rect(Rect2(0.0, layout.header_h, left_bg_w, viewport_size.y - layout.header_h), Color(0.01, 0.05, 0.10, 0.20))
	var stats_strip := home_stats_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.08, 0.14, 0.90), 16.0 * unit), stats_strip)
	draw_string(ui_font, stats_strip.position + Vector2(12.0, 22.0) * unit, ("ניצחונות: %d" if ui_language == "he" else "WINS: %d") % player_wins, HORIZONTAL_ALIGNMENT_LEFT, stats_strip.size.x - 16.0 * unit, int(13.0 * unit), Color.WHITE)
	draw_string(ui_font, stats_strip.position + Vector2(12.0, 40.0) * unit, ("רצף: %d" if ui_language == "he" else "STREAK: %d") % player_current_streak, HORIZONTAL_ALIGNMENT_LEFT, stats_strip.size.x - 16.0 * unit, int(12.0 * unit), Color("8cecff"))
	draw_string(ui_font, stats_strip.position + Vector2(12.0, 54.0) * unit, league_name(player_league_tier) + " • " + str(player_rating), HORIZONTAL_ALIGNMENT_LEFT, stats_strip.size.x - 16.0 * unit, int(11.0 * unit), Color("ffe25d"))

	# Full-body hero with the selected lifebuoy wrapped around its waist.
	var character_area := home_character_rect(viewport_size)
	var idle_phase := menu_elapsed * 1.55
	# Keep the soles slightly inside the visible top plane so the idle motion
	# never makes the animal appear to float above the wooden stage.
	var hero_size := character_area.size
	var ground_offset: float = hero_size.y * float(HERO_GROUND_OFFSETS[clampi(player_animal, 0, HERO_GROUND_OFFSETS.size() - 1)])
	var hero_center := character_area.position + Vector2(character_area.size.x * 0.50, character_area.size.y * 0.425 + 12.0 * unit + ground_offset)
	var breathe := 1.0 + sin(idle_phase) * 0.006
	# Keep only a tiny idle movement so the feet stay planted on the stage.
	var gentle_float := sin(idle_phase * 0.72) * 0.45 * unit
	var animated_center := hero_center + Vector2(0.0, gentle_float)
	var waist_center := character_area.position + Vector2(character_area.size.x * 0.50, character_area.size.y * 0.58 + gentle_float)
	var ring_radius := 96.0 * unit
	var ring_width := 42.0 * unit
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
	var sound_toggle := home_sound_toggle_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), sound_toggle.grow(4.0))
	draw_style_box(make_box(Color("35b96f") if sound_enabled else Color("5a6675"), 16.0), sound_toggle)
	draw_string(ui_font, sound_toggle.position + Vector2(0.0, 35.0) * unit, "♪" if sound_enabled else "×", HORIZONTAL_ALIGNMENT_CENTER, sound_toggle.size.x, int(18.0 * unit), Color.WHITE)
	var coin_rect := home_coin_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), coin_rect.grow(4.0))
	draw_style_box(make_box(Color("253e67"), 16.0), coin_rect)
	draw_circle(coin_rect.position + Vector2(29.0, 27.0) * unit, 15.0 * unit, Color("ffc83d"))
	draw_circle(coin_rect.position + Vector2(29.0, 27.0) * unit, 9.0 * unit, Color("e9971b"), false, 3.0 * unit, true)
	draw_string(ui_font, coin_rect.position + Vector2(54.0, 35.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 82.0 * unit, int(20.0 * unit), Color.WHITE)
	var gems := home_gems_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 18.0), gems.grow(4.0))
	draw_style_box(make_box(Color("253e67"), 16.0), gems)
	var gem_center := gems.position + Vector2(28.0, 27.0) * unit
	var gem_shape := PackedVector2Array([gem_center + Vector2(0.0, -15.0) * unit, gem_center + Vector2(14.0, -3.0) * unit, gem_center + Vector2(8.0, 14.0) * unit, gem_center + Vector2(-8.0, 14.0) * unit, gem_center + Vector2(-14.0, -3.0) * unit])
	draw_colored_polygon(gem_shape, Color("42e4ff"))
	draw_string(ui_font, gems.position + Vector2(52.0, 35.0) * unit, "0", HORIZONTAL_ALIGNMENT_LEFT, 52.0 * unit, int(20.0 * unit), Color.WHITE)
	var profile := home_profile_rect(viewport_size)
	draw_style_box(make_box(Color(0.02, 0.09, 0.16, 0.92), 19.0), profile.grow(4.0))
	draw_style_box(make_box(Color("244d70"), 17.0), profile)
	draw_circle(profile.position + Vector2(31.0, 29.0) * unit, 24.0 * unit, Color("6965d8"))
	draw_string(ui_font, profile.position + Vector2(7.0, 38.0) * unit, profile_initial(), HORIZONTAL_ALIGNMENT_CENTER, 48.0 * unit, int(25.0 * unit), Color.WHITE)
	draw_string(ui_font, profile.position + Vector2(65.0, 27.0) * unit, profile_name, HORIZONTAL_ALIGNMENT_LEFT, profile.size.x - 76.0 * unit, int(19.0 * unit), Color.WHITE)
	draw_string(ui_font, profile.position + Vector2(65.0, 47.0) * unit, player_level_label(), HORIZONTAL_ALIGNMENT_LEFT, profile.size.x - 76.0 * unit, int(11.0 * unit), Color("8cecff"))
	var progress_bg := Rect2(profile.position + Vector2(65.0, 49.0) * unit, Vector2(profile.size.x - 84.0 * unit, 6.0 * unit))
	draw_style_box(make_box(Color("162c49"), 3.0 * unit), progress_bg)
	draw_style_box(make_box(Color("5f78ff"), 3.0 * unit), Rect2(progress_bg.position, Vector2(progress_bg.size.x * 0.62, progress_bg.size.y)))

	var bottom_bar := Rect2(layout.center_left - 8.0 * unit, layout.bottom_y - 8.0 * unit, layout.center_w + 16.0 * unit, layout.bottom_button_h + 16.0 * unit)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.55), 18.0 * unit), bottom_bar)

	# Bottom row: online arena, friend match, then vs computer.
	var arena_button := home_mode_rect(0, viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.88), 18.0), arena_button.grow(5.0 * unit))
	draw_style_box(make_box(Color("7258df"), 16.0), arena_button)
	var arena_icon := arena_button.position + Vector2(arena_button.size.x * 0.5, arena_button.size.y * 0.38)
	draw_home_mode_icon(0, arena_icon, unit)
	draw_string(ui_font, arena_button.position + Vector2(6.0, arena_button.size.y * 0.72), ui_text("arena"), HORIZONTAL_ALIGNMENT_CENTER, arena_button.size.x - 12.0 * unit, int(13.0 * unit), Color.WHITE)

	var friend_button := home_mode_rect(1, viewport_size)
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.88), 18.0), friend_button.grow(5.0 * unit))
	draw_style_box(make_box(Color("315fd0"), 16.0), friend_button)
	var friend_icon := friend_button.position + Vector2(friend_button.size.x * 0.5, friend_button.size.y * 0.38)
	draw_home_mode_icon(1, friend_icon, unit)
	draw_string(ui_font, friend_button.position + Vector2(6.0, friend_button.size.y * 0.72), ui_text("friend"), HORIZONTAL_ALIGNMENT_CENTER, friend_button.size.x - 12.0 * unit, int(13.0 * unit), Color.WHITE)

	var play_rect := home_mode_rect(2, viewport_size)
	var pulse := (sin(menu_elapsed * 3.0) + 1.0) * 0.5
	draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.88), 22.0), play_rect.grow((5.0 + pulse * 2.0) * unit))
	draw_style_box(make_box(Color("f6aa20"), 20.0), play_rect)
	var play_center := play_rect.position + Vector2(play_rect.size.x * 0.22, play_rect.size.y * 0.42)
	draw_circle(play_center, 24.0 * unit, Color("df7b12"))
	draw_home_mode_icon(2, play_center, unit)
	var play_text_x := play_rect.position.x + play_rect.size.x * 0.40
	draw_string(ui_font, Vector2(play_text_x, play_rect.position.y + play_rect.size.y * 0.44), "שחק" if ui_language == "he" else "PLAY", HORIZONTAL_ALIGNMENT_LEFT, play_rect.size.x * 0.56, int(24.0 * unit), Color.WHITE)
	draw_string(ui_font, Vector2(play_text_x, play_rect.position.y + play_rect.size.y * 0.72), ui_text("computer_sub"), HORIZONTAL_ALIGNMENT_LEFT, play_rect.size.x * 0.56, int(9.0 * unit), Color("fff4cf"))

	# Collection shortcuts stay close to the hero character.
	var nav_labels := [ui_text("shop"), ui_text("rewards")]
	var nav_subtitles := [ui_text("shop_sub"), ui_text("rewards_sub")]
	var nav_colors := [Color("ff9f24"), Color("e94f78")]
	for i in 2:
		var nav := home_nav_rect(i, viewport_size)
		draw_style_box(make_box(Color(0.02, 0.07, 0.12, 0.86), 17.0), nav.grow(4.0 * unit))
		draw_style_box(make_box(nav_colors[i], 15.0), nav)
		var nav_icon_center := nav.position + Vector2(nav.size.x * 0.18, nav.size.y * 0.42)
		draw_circle(nav_icon_center, 20.0 * unit, Color(1.0, 1.0, 1.0, 0.22))
		draw_home_nav_icon(i, nav_icon_center, unit)
		draw_string(ui_font, nav.position + Vector2(nav.size.x * 0.34, nav.size.y * 0.38), nav_labels[i], HORIZONTAL_ALIGNMENT_LEFT, nav.size.x * 0.58, int(17.0 * unit), Color.WHITE)
		draw_string(ui_font, nav.position + Vector2(nav.size.x * 0.34, nav.size.y * 0.72), nav_subtitles[i], HORIZONTAL_ALIGNMENT_LEFT, nav.size.x * 0.58, int(9.0 * unit), Color("fff0c7"))
	draw_home_social_panel(viewport_size)
	var help_toggle := home_help_rect(viewport_size)
	draw_style_box(make_box(Color("35b96f") if tutorial_open else Color("2982a6"), 16.0 * unit), help_toggle)
	draw_string(ui_font, help_toggle.position + Vector2(0.0, 35.0) * unit, "?", HORIZONTAL_ALIGNMENT_CENTER, help_toggle.size.x, int(22.0 * unit), Color.WHITE)
	draw_home_friend_profile(viewport_size)
	draw_tutorial_overlay(viewport_size)

func draw_home_mode_icon(kind: int, center: Vector2, unit: float) -> void:
	if kind == 0:
		# Arena: a lifebuoy with a small winner star.
		draw_circle(center, 15.0 * unit, Color.WHITE, false, 5.0 * unit, true)
		draw_circle(center, 5.0 * unit, Color(1.0, 1.0, 1.0, 0.25))
		draw_string(ui_font, center + Vector2(-10.0, -10.0) * unit, "★", HORIZONTAL_ALIGNMENT_CENTER, 20.0 * unit, int(12.0 * unit), Color("ffe25d"))
	elif kind == 1:
		# Private friend match: two clearly different players.
		draw_circle(center + Vector2(-8.0, -7.0) * unit, 7.0 * unit, Color.WHITE)
		draw_circle(center + Vector2(9.0, -7.0) * unit, 7.0 * unit, Color("d8f5ff"))
		draw_arc(center + Vector2(-8.0, 12.0) * unit, 11.0 * unit, PI, TAU, 14, Color.WHITE, 5.0 * unit, true)
		draw_arc(center + Vector2(9.0, 12.0) * unit, 11.0 * unit, PI, TAU, 14, Color("d8f5ff"), 5.0 * unit, true)
	else:
		# Single player: a player faces a monitor/AI.
		draw_circle(center + Vector2(-12.0, -4.0) * unit, 7.0 * unit, Color.WHITE)
		draw_arc(center + Vector2(-12.0, 13.0) * unit, 11.0 * unit, PI, TAU, 14, Color.WHITE, 5.0 * unit, true)
		var monitor := Rect2(center + Vector2(2.0, -12.0) * unit, Vector2(23.0, 19.0) * unit)
		draw_rect(monitor, Color("173249"), true)
		draw_rect(monitor, Color.WHITE, false, 3.0 * unit)
		draw_line(center + Vector2(13.0, 7.0) * unit, center + Vector2(13.0, 15.0) * unit, Color.WHITE, 3.0 * unit)

func draw_home_nav_icon(kind: int, center: Vector2, unit: float) -> void:
	if kind == 0:
		var bag := Rect2(center + Vector2(-12.0, -8.0) * unit, Vector2(24.0, 22.0) * unit)
		draw_rect(bag, Color.WHITE, false, 4.0 * unit)
		draw_arc(center + Vector2(0.0, -7.0) * unit, 7.0 * unit, PI, TAU, 12, Color.WHITE, 3.0 * unit, true)
	else:
		var gift := Rect2(center + Vector2(-13.0, -8.0) * unit, Vector2(26.0, 22.0) * unit)
		draw_rect(gift, Color.WHITE, false, 4.0 * unit)
		draw_line(center + Vector2(0.0, -8.0) * unit, center + Vector2(0.0, 14.0) * unit, Color.WHITE, 3.0 * unit)
		draw_line(center + Vector2(-13.0, -1.0) * unit, center + Vector2(13.0, -1.0) * unit, Color.WHITE, 3.0 * unit)

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
	draw_string(ui_font, panel.position + Vector2(0.0, 28.0), ui_text("leaderboard_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 16, Color("173249"))
	var entries := global_leaderboard.duplicate()
	if entries.is_empty():
		entries = [{"rank": 1, "name": profile_name, "rating": player_rating, "publicId": firebase_public_id}]
	var count := mini(4, entries.size())
	for i in count:
		var entry: Dictionary = entries[i]
		var row := Rect2(panel.position + Vector2(10.0, 38.0 + i * 48.0), Vector2(panel.size.x - 20.0, 42.0))
		var is_me := str(entry.get("publicId", "")) == firebase_public_id
		draw_style_box(make_box(Color("ffe6a8") if is_me else Color(0.95, 0.99, 0.97, 0.96), 13.0), row)
		draw_string(ui_font, row.position + Vector2(8.0, 27.0), "#" + str(entry.get("rank", i + 1)), HORIZONTAL_ALIGNMENT_CENTER, 28.0, 13, Color("173249"))
		draw_string(ui_font, row.position + Vector2(38.0, 20.0), str(entry.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 90.0, 12, Color("173249"))
		draw_string(ui_font, row.position + Vector2(38.0, 35.0), str(entry.get("rating", 0)) + " " + ui_text("rating_label"), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 90.0, 9, Color("527184"))

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
	var ground_offset: float = hero_size.y * float(HERO_GROUND_OFFSETS[clampi(player_animal, 0, HERO_GROUND_OFFSETS.size() - 1)])
	var hero_center := display.position + Vector2(display.size.x * 0.50, display.size.y * 0.405 + 10.0 * unit + ground_offset + sin(menu_elapsed * 1.4) * 0.45 * unit)
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
		var ring_center := ring_button.position + Vector2(34.0, 39.0) * unit
		draw_circle(ring_center, 27.0 * unit, RING_COLORS[i])
		draw_circle(ring_center, 12.0 * unit, Color("14324c"))
		draw_arc(ring_center, 27.0 * unit, -0.70, 0.15, 10, Color("fff4dc"), 8.0 * unit, true)
		draw_arc(ring_center, 27.0 * unit, 2.45, 3.30, 10, Color("fff4dc"), 8.0 * unit, true)
		draw_collection_lock_overlay(ring_button, i, true, unit)
		draw_string(ui_font, ring_button.position + Vector2(63.0, 47.0) * unit, ui_ring_name(i), HORIZONTAL_ALIGNMENT_CENTER, ring_button.size.x - 69.0 * unit, int(11.0 * unit), Color.WHITE)
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
		draw_collection_lock_overlay(card, i, false, unit)
		draw_rect(Rect2(card.position + Vector2(0.0, 114.0) * unit, Vector2(card.size.x, 36.0 * unit)), Color(0.01, 0.05, 0.10, 0.80))
		draw_string(ui_font, card.position + Vector2(0.0, 139.0) * unit, ui_animal_name(i), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(12.0 * unit), Color.WHITE)
		if selected_card:
			draw_circle(card.position + Vector2(card.size.x - 15.0 * unit, 15.0 * unit), 14.0 * unit, Color("ffe25d"))
			draw_string(ui_font, card.position + Vector2(card.size.x - 29.0 * unit, 21.0 * unit), "✓", HORIZONTAL_ALIGNMENT_CENTER, 28.0 * unit, int(14.0 * unit), Color("173249"))

func board_theme_name(index: int) -> String:
	var keys := ["board_classic", "board_ice", "board_jungle", "board_volcano", "board_candy"]
	return ui_text(keys[clampi(index, 0, keys.size() - 1)])

func board_theme_texture(index: int) -> Texture2D:
	if board_theme_textures.is_empty():
		return board_texture
	var texture := board_theme_textures[clampi(index, 0, board_theme_textures.size() - 1)]
	return texture if texture != null else board_texture

func board_theme_accent(index: int) -> Color:
	var accents := [Color("58c9e8"), Color("8cecff"), Color("6fda18"), Color("ff7b43"), Color("ff78b7")]
	return accents[clampi(index, 0, accents.size() - 1)]

func board_theme_modulate(index: int) -> Color:
	match clampi(index, 0, BOARD_THEME_COUNT - 1):
		1:
			return Color(0.86, 0.95, 1.0)
		2:
			return Color(0.92, 1.0, 0.88)
		3:
			return Color(1.0, 0.90, 0.82)
		_:
			return Color.WHITE

func draw_board_theme_overlay(theme_index: int) -> void:
	draw_board_theme_overlay_on_rect(theme_index, board_rect, board_scale)

func draw_board_theme_card(theme_index: int, card: Rect2, selected: bool, unit: float) -> void:
	draw_style_box(make_box(Color("ffe25d") if selected else Color(0.02, 0.06, 0.12, 0.90), 14.0 * unit), card.grow((4.0 if selected else 2.0) * unit))
	var preview := Rect2(card.position + Vector2(6.0 * unit, 6.0 * unit), Vector2(card.size.x - 12.0 * unit, card.size.y - 24.0 * unit))
	draw_shop_board_preview(theme_index, preview, unit)
	draw_string(ui_font, card.position + Vector2(0.0, card.size.y - 12.0 * unit), board_theme_name(theme_index), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(10.0 * unit), Color.WHITE)
	if selected:
		draw_circle(card.position + Vector2(card.size.x - 12.0 * unit, 12.0 * unit), 9.0 * unit, Color("ffe25d"))
		draw_string(ui_font, card.position + Vector2(card.size.x - 21.0 * unit, 16.0 * unit), "✓", HORIZONTAL_ALIGNMENT_CENTER, 18.0 * unit, int(11.0 * unit), Color("173249"))

func shop_unlocked_count(is_ring: bool) -> int:
	var total := 0
	if is_ring:
		for i in RING_COLORS.size():
			if is_ring_unlocked(i):
				total += 1
	else:
		for i in ANIMAL_NAMES.size():
			if is_animal_unlocked(i):
				total += 1
	return total

func shop_page_title() -> String:
	match shop_page:
		SHOP_PAGE_ANIMALS:
			return ui_text("characters")
		SHOP_PAGE_RINGS:
			return ui_text("rings")
		SHOP_PAGE_EFFECTS:
			return ui_text("effects")
		_:
			return ui_text("shop_title")

func shop_page_subtitle() -> String:
	match shop_page:
		SHOP_PAGE_ANIMALS:
			return ui_text("characters_sub")
		SHOP_PAGE_RINGS:
			return ui_text("rings_sub")
		SHOP_PAGE_EFFECTS:
			return ui_text("collection_info")
		_:
			return ui_text("shop_unlocks_sub")

func shop_category_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var gap := 22.0 * unit
	var card_w := minf(300.0 * unit, (viewport_size.x - 100.0 * unit - gap * 2.0) / 3.0)
	var card_h := minf(380.0 * unit, viewport_size.y - 200.0 * unit)
	var total_w := card_w * 3.0 + gap * 2.0
	var start_x := (viewport_size.x - total_w) * 0.5
	var start_y := maxf(150.0 * unit, (viewport_size.y - card_h) * 0.5)
	return Rect2(Vector2(start_x + float(index) * (card_w + gap), start_y), Vector2(card_w, card_h))

func shop_detail_columns(item_count: int) -> int:
	return mini(4, maxi(2, item_count))

func shop_detail_grid_rect(index: int, viewport_size: Vector2, item_count: int) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var columns := shop_detail_columns(item_count)
	var rows := int(ceil(float(item_count) / float(columns)))
	var gap := 16.0 * unit
	var top := 126.0 * unit
	var bottom_margin := 28.0 * unit
	var available_h := viewport_size.y - top - bottom_margin
	var available_w := viewport_size.x - 72.0 * unit
	var card_w := (available_w - gap * float(columns - 1)) / float(columns)
	var card_h := minf(360.0 * unit, (available_h - gap * float(rows - 1)) / float(rows))
	var col := index % columns
	var row := int(index / columns)
	var items_in_row := mini(columns, item_count - row * columns)
	var row_width := card_w * float(items_in_row) + gap * float(items_in_row - 1)
	var start_x := (viewport_size.x - row_width) * 0.5
	return Rect2(Vector2(start_x + float(col) * (card_w + gap), top + float(row) * (card_h + gap)), Vector2(card_w, card_h))

func shop_detail_price_label(index: int, is_ring: bool) -> String:
	var unlocked := is_ring_unlocked(index) if is_ring else is_animal_unlocked(index)
	var selected := (player_ring_color == index) if is_ring else (player_animal == index)
	if selected and unlocked:
		return ui_text("equipped_item")
	if unlocked:
		return ui_text("owned_item")
	var price := ring_unlock_price(index) if is_ring else animal_unlock_price(index)
	if price <= 0:
		return ui_text("free_item")
	return str(price) + ui_text("coins")

func draw_shop_category_icon(kind: int, center: Vector2, size: float, unit: float) -> void:
	draw_circle(center, size * 0.52, Color(1.0, 1.0, 1.0, 0.10))
	if kind == 0:
		if full_body_animal_textures.size() > 0 and full_body_animal_textures[0] != null:
			var portrait_size := Vector2(size * 0.95, size * 1.15)
			draw_texture_rect(full_body_animal_textures[0], Rect2(center - portrait_size * 0.5, portrait_size), false)
		else:
			draw_circle(center + Vector2(0.0, -size * 0.08), size * 0.22, Color("f2c9a0"))
			draw_circle(center + Vector2(0.0, size * 0.18), size * 0.30, Color("f2c9a0"))
	elif kind == 1:
		draw_set_transform(center, 0.0, Vector2(1.0, 0.55))
		draw_arc(Vector2.ZERO, size * 0.42, 0.0, TAU, 36, Color("ff7b43"), size * 0.16, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_circle(center, size * 0.14, Color("173249"))
	elif kind == 2:
		for i in 6:
			var angle := float(i) * TAU / 6.0 + menu_elapsed * 0.4
			var spark := center + Vector2(cos(angle), sin(angle)) * size * 0.34
			draw_circle(spark, size * 0.08, Color("ffe25d", 0.85))
		draw_circle(center, size * 0.16, Color("9a58dc", 0.55))
		draw_circle(center, size * 0.08, Color.WHITE)

func draw_shop_board_preview(theme_index: int, preview: Rect2, unit: float) -> void:
	var theme := clampi(theme_index, 0, BOARD_THEME_COUNT - 1)
	var accent := board_theme_accent(theme)
	draw_style_box(make_box(Color(0.02, 0.06, 0.11, 0.92), 14.0 * unit), preview.grow(3.0 * unit))
	draw_style_box(make_box(accent.darkened(0.55), 12.0 * unit), preview)
	var inner := preview.grow(-10.0 * unit)
	draw_rect(inner, Color("1a3048"))
	var preview_texture := board_theme_texture(theme)
	if preview_texture != null:
		draw_texture_rect(preview_texture, inner, false)
	draw_style_box(make_box(Color(accent.r, accent.g, accent.b, 0.35), 10.0 * unit), Rect2(inner.position, Vector2(inner.size.x, 3.0 * unit)))

func draw_shop_coin_box(viewport_size: Vector2, unit: float) -> void:
	var coin_box := Rect2(viewport_size.x - 220.0 * unit, 24.0 * unit, 180.0 * unit, 54.0 * unit)
	draw_style_box(make_box(Color("253e67"), 14.0 * unit), coin_box)
	draw_circle(coin_box.position + Vector2(28.0, 27.0) * unit, 15.0 * unit, Color("ffc83d"))
	draw_string(ui_font, coin_box.position + Vector2(52.0, 35.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 110.0 * unit, int(20.0 * unit), Color.WHITE)

func draw_texture_fit(texture: Texture2D, rect: Rect2) -> void:
	if texture == null:
		return
	var tex_size := texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var scale := minf(rect.size.x / tex_size.x, rect.size.y / tex_size.y)
	var draw_size := tex_size * scale
	var pos := rect.position + (rect.size - draw_size) * 0.5
	draw_texture_rect(texture, Rect2(pos, draw_size), false)

func draw_shop_ring_preview(art_rect: Rect2, index: int) -> void:
	var preview_animal := 0
	if preview_animal < lifebuoy_hero_textures.size():
		var colors: Array = lifebuoy_hero_textures[preview_animal]
		if index < colors.size() and colors[index] != null:
			draw_texture_fit(colors[index] as Texture2D, art_rect)
			return
	var center := art_rect.get_center()
	var radius := minf(art_rect.size.x, art_rect.size.y) * 0.34
	draw_set_transform(center, 0.0, Vector2(1.0, 0.52))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, RING_COLORS[index], radius * 0.30, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(center, radius * 0.34, Color(0.02, 0.06, 0.12, 0.88))

func draw_shop_detail_card(index: int, rect: Rect2, is_ring: bool, unit: float) -> void:
	var unlocked := is_ring_unlocked(index) if is_ring else is_animal_unlocked(index)
	var selected := (player_ring_color == index) if is_ring else (player_animal == index)
	var accent := Color("467ce8") if is_ring else Color("24b889")
	draw_style_box(make_box(Color("ffe25d") if selected else Color(0.02, 0.06, 0.12, 0.90), 16.0 * unit), rect.grow((5.0 if selected else 2.0) * unit))
	draw_style_box(make_box(accent.darkened(0.58), 14.0 * unit), rect)
	var art_rect := Rect2(rect.position + Vector2(10.0 * unit, 10.0 * unit), Vector2(rect.size.x - 20.0 * unit, rect.size.y - 92.0 * unit))
	draw_style_box(make_box(Color(0.01, 0.04, 0.09, 0.72), 12.0 * unit), art_rect)
	if is_ring:
		draw_shop_ring_preview(art_rect.grow(-8.0 * unit), index)
	else:
		if index < full_body_animal_textures.size() and full_body_animal_textures[index] != null:
			draw_texture_fit(full_body_animal_textures[index], art_rect.grow(-6.0 * unit))
	if not unlocked:
		draw_rect(art_rect, Color(0.01, 0.03, 0.08, 0.62))
		draw_string(ui_font, art_rect.position + Vector2(0.0, art_rect.size.y * 0.48), "🔒", HORIZONTAL_ALIGNMENT_CENTER, art_rect.size.x, int(24.0 * unit), Color.WHITE)
	if selected and unlocked:
		draw_style_box(make_box(Color("ffe25d"), 10.0 * unit), Rect2(rect.position + Vector2(8.0 * unit, 8.0 * unit), Vector2(rect.size.x - 16.0 * unit, 22.0 * unit)))
		draw_string(ui_font, rect.position + Vector2(0.0, 24.0 * unit), ui_text("equipped_item"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(10.0 * unit), Color("173249"))
	var label := ui_ring_name(index) if is_ring else ui_animal_name(index)
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y - 58.0 * unit), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(14.0 * unit), Color.WHITE)
	var price_text := shop_detail_price_label(index, is_ring)
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y - 30.0 * unit), price_text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(13.0 * unit), Color("ffe25d"))

func draw_shop_hub(viewport_size: Vector2, unit: float) -> void:
	var categories := [ui_text("characters"), ui_text("rings"), ui_text("effects")]
	var category_colors := [Color("24b889"), Color("467ce8"), Color("9a58dc")]
	var category_counts := [ANIMAL_NAMES.size(), RING_COLOR_NAMES.size(), 0]
	for i in 3:
		var card := shop_category_rect(i, viewport_size)
		var accent: Color = category_colors[i]
		draw_style_box(make_box(Color(0.02, 0.06, 0.12, 0.94), 22.0 * unit), card.grow(4.0 * unit))
		draw_style_box(make_box(accent.darkened(0.62), 18.0 * unit), card)
		draw_rect(Rect2(card.position + Vector2(10.0 * unit, 10.0 * unit), Vector2(card.size.x - 20.0 * unit, 3.0 * unit)), Color(accent.lightened(0.25), 0.55))
		var icon_center := card.position + Vector2(card.size.x * 0.5, card.size.y * 0.34)
		draw_shop_category_icon(i, icon_center, 72.0 * unit, unit)
		draw_string(ui_font, card.position + Vector2(0.0, card.size.y * 0.58), categories[i], HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(26.0 * unit), Color.WHITE)
		if i < 2:
			var collected := shop_unlocked_count(i == 1)
			draw_string(ui_font, card.position + Vector2(0.0, card.size.y * 0.70), ui_text("shop_collected") % [collected, category_counts[i]], HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(13.0 * unit), Color("ffe25d"))
		else:
			draw_string(ui_font, card.position + Vector2(0.0, card.size.y * 0.70), ui_text("coming_soon"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(13.0 * unit), Color("d7f6ff"))
		draw_string(ui_font, card.position + Vector2(0.0, card.size.y * 0.86), ui_text("shop_open_category"), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(12.0 * unit), Color("ffe25d"))

func draw_shop_detail_page(viewport_size: Vector2, item_count: int, is_ring: bool, unit: float) -> void:
	var panel := Rect2(24.0 * unit, 108.0 * unit, viewport_size.x - 48.0 * unit, viewport_size.y - 132.0 * unit)
	draw_style_box(make_box(Color(0.01, 0.04, 0.10, 0.82), 20.0 * unit), panel)
	var collected := shop_unlocked_count(is_ring)
	var total := RING_COLOR_NAMES.size() if is_ring else ANIMAL_NAMES.size()
	draw_string(ui_font, panel.position + Vector2(0.0, 28.0 * unit), ui_text("shop_collected") % [collected, total], HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(15.0 * unit), Color("ffe25d"))
	for i in item_count:
		draw_shop_detail_card(i, shop_detail_grid_rect(i, viewport_size, item_count), is_ring, unit)

func draw_shop_animals_page(viewport_size: Vector2, unit: float) -> void:
	draw_shop_detail_page(viewport_size, ANIMAL_NAMES.size(), false, unit)

func draw_shop_rings_page(viewport_size: Vector2, unit: float) -> void:
	draw_shop_detail_page(viewport_size, RING_COLOR_NAMES.size(), true, unit)

func draw_shop_effects_page(viewport_size: Vector2, unit: float) -> void:
	var panel := Rect2((viewport_size.x - 760.0 * unit) * 0.5, 180.0 * unit, 760.0 * unit, 360.0 * unit)
	draw_style_box(make_box(Color(0.02, 0.06, 0.12, 0.94), 24.0 * unit), panel)
	draw_shop_category_icon(2, panel.position + Vector2(panel.size.x * 0.5, 120.0 * unit), 72.0 * unit, unit)
	draw_string(ui_font, panel.position + Vector2(0.0, 210.0) * unit, ui_text("coming_soon"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(28.0 * unit), Color("ffe25d"))
	draw_string(ui_font, panel.position + Vector2(40.0 * unit, 260.0) * unit, ui_text("shop_effects_empty"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 80.0 * unit, int(15.0 * unit), Color("d7f6ff"))

func draw_shop_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.09, 0.72 if shop_page == SHOP_PAGE_HUB else 0.82))
	draw_frontend_header(viewport_size, shop_page_title(), shop_page_subtitle())
	draw_shop_coin_box(viewport_size, unit)
	match shop_page:
		SHOP_PAGE_ANIMALS:
			draw_shop_animals_page(viewport_size, unit)
		SHOP_PAGE_RINGS:
			draw_shop_rings_page(viewport_size, unit)
		SHOP_PAGE_EFFECTS:
			draw_shop_effects_page(viewport_size, unit)
		_:
			draw_shop_hub(viewport_size, unit)

func draw_board_theme_overlay_on_rect(theme_index: int, rect: Rect2, unit: float) -> void:
	var theme := clampi(theme_index, 0, BOARD_THEME_COUNT - 1)
	if theme == 0:
		draw_rect(rect, Color("58c9e8", 0.08))
		return
	if theme == 1:
		draw_rect(rect, Color("8cecff", 0.18))
		for i in 8:
			draw_circle(rect.position + Vector2(rect.size.x * (0.1 + float(i % 4) * 0.22), rect.size.y * (0.14 + float(i / 4) * 0.28)), (4.0 + float(i % 3) * 2.5) * unit, Color(1.0, 1.0, 1.0, 0.38))
		for i in 5:
			var crystal := rect.position + Vector2(rect.size.x * (0.12 + float(i) * 0.17), rect.size.y * (0.62 + float(i % 2) * 0.16))
			draw_colored_polygon(PackedVector2Array([crystal + Vector2(0.0, -12.0) * unit, crystal + Vector2(10.0, 0.0) * unit, crystal + Vector2(0.0, 14.0) * unit, crystal + Vector2(-10.0, 0.0) * unit]), Color("d8f8ff", 0.82))
		draw_rect(rect.grow(-3.0 * unit), Color("8cecff", 0.14), false, maxf(2.0, 3.0 * unit))
	elif theme == 2:
		draw_rect(rect, Color("6fda18", 0.16))
		for i in 6:
			var x := rect.position.x + rect.size.x * (0.08 + float(i) * 0.15)
			draw_line(Vector2(x, rect.position.y - 4.0 * unit), Vector2(x + 10.0 * unit, rect.end.y + 4.0 * unit), Color("3f8f3a", 0.62), 4.5 * unit, true)
		for i in 4:
			draw_circle(rect.position + Vector2(rect.size.x * (0.18 + float(i) * 0.2), rect.size.y * 0.22), 5.0 * unit, Color("b8ff7a", 0.55))
	else:
		draw_rect(rect, Color("ff5b2d", 0.18))
		var lava := PackedVector2Array([rect.position + Vector2(0.0, rect.size.y), rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.28), rect.position + Vector2(rect.size.x * 0.72, rect.size.y * 0.55), rect.end])
		draw_colored_polygon(lava, Color("ff5b2d", 0.34))
		for i in 10:
			var ember := rect.position + Vector2(rect.size.x * (0.08 + float(i) * 0.09), rect.size.y * (0.12 + float(i % 5) * 0.15))
			draw_circle(ember, (3.0 + float(i % 3) * 2.0) * unit, Color("ffb12b", 0.35 + sin(menu_elapsed * 4.0 + float(i)) * 0.15))

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box
