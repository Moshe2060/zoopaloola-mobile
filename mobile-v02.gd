Warning: truncated output (original token count: 113927)
Total output lines: 8349

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
const ABYSS_EFFECT_DURATION := 2.65
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
	"computer": "קרב מהיר", "computer_sub": "שחקן יחיד • נגד המחשב",
	"back": "חזרה", "choose_character": "בחירת דמות", "choose_character_sub": "בחרו חיה וצבע גלגל הצלה",
	"choose_ring": "בחרו גלגל הצלה", "choose_ring_sub": "הצבע שבחרתם יופיע בכל משחק",
	"choose_animal": "בחרו חיה", "choose_board": "בחרו שולחן משחק", "choose_setup": "בחרו דמות, גלגל ושולחן", "restoring_session": "מחזירים את ההתחברות שלכם...", "red": "אדום", "orange": "כתום", "blue": "כחול", "green": "ירוק", "purple": "סגול", "turquoise": "טורקיז", "pink": "ורוד",
	"elephant": "פיל", "zebra": "זברה", "monkey": "קוף", "hippo": "היפופוטם", "rhino": "קרנף", "giraffe": "ג׳ירפה", "tiger": "טיגריס",
	"arena_title": "בחירת זירה", "arena_title_sub": "בחרו את מגרש המשחק לקרב האונליין",
	"sakura": "גן הסאקורה", "bamboo": "חורשת הבמבוק", "volcano": "מקדש הגעש",
	"entry_free": "כניסה: חינם", "entry": "דמי כניסה: ", "coins": " מטבעות", "prize": "פרס ניצחון: ", "selected": "נבחר", "find_match": "חיפוש יריב אונליין",
	"profile_title": "פרופיל שחקן", "profile_sub": "הדמות והחללית הייחודית שלה, לצד סטטיסטיקות הקריירה שלכם",
	"main_character": "הדמות הראשית", "choose_main": "בחרו דמות ראשית", "favorite_color": "צבע גלגל אהוב",
	"career": "סטטיסטיקות קריירה", "matches": "משחקים", "wins": "ניצחונות", "losses": "הפסדים", "win_rate": "אחוז הצלחה", "best_streak": "רצף שיא", "world_rank": "דירוג עולמי", "current_streak": "רצף ניצחונות נוכחי: ",
	"shop_title": "החנות של זופלולה", "shop_title_sub": "דמויות וחלליות ייחודיות, אפקטים ושולחנות משחק", "effects": "אפקטים", "collection_info": "אוספים נדירים • עיצובים עונתיים • אנימציות מיוחדות", "coming_soon": "בקרוב",
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
	"computer": "QUICK BATTLE", "computer_sub": "Single player • vs AI",
	"back": "BACK", "choose_character": "CHOOSE YOUR CHARACTER", "choose_character_sub": "Pick an animal and a lifebuoy color",
	"choose_ring": "CHOOSE A LIFEBUOY", "choose_ring_sub": "Your color follows you into every match",
	"choose_animal": "CHOOSE AN ANIMAL", "choose_board": "CHOOSE A GAME TABLE", "choose_setup": "Choose animal, ring and table", "restoring_session": "Restoring your sign-in...", "red": "RED", "orange": "ORANGE", "blue": "BLUE", "green": "GREEN", "purple": "PURPLE", "turquoise": "TURQUOISE", "pink": "PINK",
	"elephant": "ELEPHANT", "zebra": "ZEBRA", "monkey": "MONKEY", "hippo": "HIPPO", "rhino": "RHINO", "giraffe": "GIRAFFE", "tiger": "TIGER",
	"arena_title": "CHOOSE YOUR ARENA", "arena_title_sub": "Select the battleground for your online match",
	"sakura": "SAKURA GARDEN", "bamboo": "BAMBOO GROVE", "volcano": "VOLCANO TEMPLE",
	"entry_free": "ENTRY: FREE", "entry": "ENTRY: ", "coins": " COINS", "prize": "WIN PRIZE: ", "selected": "SELECTED", "find_match": "FIND ONLINE MATCH",
	"profile_title": "PLAYER PROFILE", "profile_sub": "Your character, their unique hovercraft and career statistics",
	"main_character": "MAIN CHARACTER", "choose_main": "CHOOSE YOUR MAIN ANIMAL", "favorite_color": "FAVORITE LIFEBUOY COLOR",
	"career": "CAREER STATISTICS", "matches": "MATCHES", "wins": "WINS", "losses": "LOSSES", "win_rate": "WIN RATE", "best_streak": "BEST STREAK", "world_rank": "WORLD RANK", "current_streak": "CURRENT WIN STREAK: ",
	"shop_title": "ZOOPA SHOP", "shop_title_sub": "Characters with unique hovercrafts, effects and game tables", "effects": "EFFECTS", "collection_info": "Rare collections • Seasonal designs • Special animations", "coming_soon": "COMING SOON",
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
const SHOP_PAGE_BOARDS := "boards"
const SHOP_PAGE_EFFECTS := "effects"
const ECONOMY_VERSION := 2
const TIGER_UNLOCK_FIX_VERSION := 1
const TIGER_ANIMAL_INDEX := 6
const ANIMAL_UNLOCK_PRICES := [0, 0, 0, 550, 750, 950, 1400]
const RING_UNLOCK_PRICES := [0, 0, 0, 350, 450, 550, 0]
const LEAGUE_RATING_THRESHOLDS := [0, 900, 1100, 1300, 1500, 1700]
const LEAGUE_NAME_KEYS := ["league_rookie", "league_amateur", "league_pro", "league_elite", "league_legend", "league_legend"]
const MATCH_SERVER_URL := "wss://zoopaloola-mobile.onrender.com/ws"
const ARENA_MATCH_FOUND_DURATION := 5.0
const ARENA_BOT_FALLBACK_DELAY := 5.0
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
var battle_background_texture: Texture2D
var battle_gates_home_texture: Texture2D
var auth_gates_background_texture: Texture2D
var character_gates_background_texture: Texture2D
var friend_gates_background_texture: Texture2D
var friend_room_concept_texture: Texture2D
var friend_lobby_concept_texture: Texture2D
var quick_battle_concept_texture: Texture2D
var arena_gates_background_texture: Texture2D
var arena_search_concept_texture: Texture2D
var arena_found_concept_texture: Texture2D
var shop_gates_background_texture: Texture2D
var player_profile_gates_background_texture: Texture2D
var leagues_gates_background_texture: Texture2D
var rewards_gates_background_texture: Texture2D
var loading_team_texture: Texture2D
var zoopaloola_logo_texture: Texture2D
var wood_podium_texture: Texture2D
var piece_textures: Array[Texture2D] = []
var animal_textures: Array[Texture2D] = []
var character_portrait_textures: Array[Texture2D] = []
var character_ship_textures: Array[Texture2D] = []
var character_ship_light_masks: Array[Texture2D] = []
# Keep these as explicit preloads. The web exporter cannot discover resources
# whose paths are assembled dynamically at runtime, which would leave the table
# pieces invisible even though the source PNGs exist in the repository.
var battle_hovercraft_textures: Array[Texture2D] = [
	preload("res://assets/ui/battle_pieces/elephant-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/zebra-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/monkey-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/hippo-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/rhino-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/giraffe-hovercraft-v1.png"),
	preload("res://assets/ui/battle_pieces/tiger-hovercraft-v1.png")
]
var hero_saucer_texture: Texture2D
var full_body_animal_textures: Array[Texture2D] = []
var lifebuoy_hero_textures: Array = []
var animal_ring_masks: Array[Texture2D] = []
var team_piece_textures: Array[Texture2D] = []
var effect_textures: Array[Texture2D] = []
var rubber_ball_texture: Texture2D
var rubber_hand_textures: Array[Texture2D] = []
var rubber_launcher_texture: Texture2D
var rubber_wrap_texture: Texture2D
var abyss_bloom_texture: Texture2D
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
var player_gems := 0
var owned_animals: Array = []
var owned_rings: Array = []
var shop_page := SHOP_PAGE_HUB
var shop_preview_animal := 0
var shop_preview_ring := 0
var shop_preview_board := 0
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
var daily_login_streak := 0
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
var arena_bot_cancel_ack_pending := false
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
var battle_gates_league_open := false
var rewards_league_mode := false
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
      icon: './zoovortex-app-icon-v1.jpg',
      badge: './zoovortex-app-icon-v1.jpg',
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

func begin_arena_bot_match() -> void:
	if arena_fx_phase != "searching" or not matchmaking_searching:
		return
	# Leave the live queue before presenting the local fallback so a real match
	# cannot arrive during the reveal countdown.
	arena_bot_cancel_ack_pending = multiplayer_socket.get_ready_state() == WebSocketPeer.STATE_OPEN
	if arena_bot_cancel_ack_pending:
		send_multiplayer({"type": "cancel_match"})
	var bot_names_he: Array[String] = ["נועם", "אורי", "ליאם", "מאיה", "איתי", "דניאל"]
	var bot_names_en: Array[String] = ["Noam", "Ori", "Liam", "Maya", "Itay", "Daniel"]
	var bot_index: int = randi() % bot_names_he.size()
	var bot_animal: int = randi() % ANIMAL_NAMES.size()
	if bot_animal == player_animal:
		bot_animal = (bot_animal + 1) % ANIMAL_NAMES.size()
	var bot_ring: int = randi() % RING_COLORS.size()
	var bot_rating: int = maxi(650, player_rating + (randi() % 121) - 60)
	arena_matched_opponent = {
		"name": bot_names_he[bot_index] if ui_language == "he" else bot_names_en[bot_index],
		"animal": bot_animal,
		"ringColor": bot_ring,
		"level": maxi(1, player_level + (randi() % 5) - 2),
		"rating": bot_rating,
		"isBot": true
	}
	pending_arena_match = {
		"source": "arena",
		"bot": true,
		"slot": 0,
		"turn": 0,
		"arena": selected_arena,
		"boardTheme": arena_board_theme_for_level(selected_arena)
	}
	matchmaking_searching = false
	pending_find_match = false
	arena_fx_phase = "found"
	arena_fx_elapsed = 0.0
	play_sound("invite")
	queue_redraw()

func apply_match_started(payload: Dictionary) -> void:
	multiplayer_slot = int(payload.get("slot", multiplayer_slot))
	turn = int(payload.get("turn", 0))
	var is_bot_match: bool = bool(payload.get("bot", false))
	game_mode = "computer" if is_bot_match else "online"
	match_source = str(payload.get("source", "friend"))
	if is_bot_match:
		ai_animal = clampi(int(arena_matched_opponent.get("animal", 1)), 0, ANIMAL_NAMES.size() - 1)
		ai_ring_color = clampi(int(arena_matched_opponent.get("ringColor", 2)), 0, RING_COLORS.size() - 1)
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
	if arena_fx_phase == "searching" and arena_fx_elapsed >= ARENA_BOT_FALLBACK_DELAY:
		begin_arena_bot_match()
		return
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
	# The friend screen draws each code character inside its illustrated slot.
	# Keep the real LineEdit active for keyboard/touch input, but visually clear.
	var empty_input_style := StyleBoxEmpty.new()
	room_code_input.add_theme_stylebox_override("normal", empty_input_style)
	room_code_input.add_theme_stylebox_override("focus", empty_input_style)
	room_code_input.add_theme_color_override("font_color", Color.TRANSPARENT)
	room_code_input.add_theme_color_override("font_placeholder_color", Color.TRANSPARENT)
	room_code_input.add_theme_color_override("caret_color", Color.TRANSPARENT)
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
	# Keep the gameplay artwork aligned with the existing pocket/trap anchors.
	# The Vortex draft has different baked-in pocket and scoreboard geometry,
	# so scaling it cannot align all gameplay anchors at the same time.
	board_texture = load("res://assets/boards/board-vortex-v2.webp") as Texture2D
	board_theme_textures = [
		board_texture,
		load("res://assets/boards/board-ice.webp") as Texture2D,
		load("res://assets/boards/board-jungle.webp") as Texture2D,
		load("res://assets/boards/board-lava.webp") as Texture2D,
		load("res://assets/boards/board-candy.webp") as Texture2D,
	]
	lobby_background_texture = load("res://assets/ui/zoopaloola-home-bg-v3.webp") as Texture2D
	battle_background_texture = load("res://assets/ui/battle-sky-bg-v1.webp") as Texture2D
	battle_gates_home_texture = load("res://assets/ui/battle-gates-home-clean-v2.webp") as Texture2D
	auth_gates_background_texture = load("res://assets/ui/screens/auth-gates-bg-v1.webp") as Texture2D
	character_gates_background_texture = load("res://assets/ui/screens/character-gates-bg-v1.webp") as Texture2D
	friend_gates_background_texture = load("res://assets/ui/screens/friend-gates-bg-v1.webp") as Texture2D
	friend_room_concept_texture = load("res://assets/ui/screens/friend-room-concept-v1.webp") as Texture2D
	friend_lobby_concept_texture = load("res://assets/ui/screens/friend-lobby-concept-v1.webp") as Texture2D
	quick_battle_concept_texture = load("res://assets/ui/screens/quick-battle-concept-v1.webp") as Texture2D
	arena_gates_background_texture = load("res://assets/ui/screens/arena-gates-bg-v1.webp") as Texture2D
	arena_search_concept_texture = load("res://assets/ui/screens/arena-search-concept-v1.webp") as Texture2D
	arena_found_concept_texture = load("res://assets/ui/screens/arena-found-concept-v2.webp") as Texture2D
	shop_gates_background_texture = load("res://assets/ui/screens/shop-gates-bg-v1.webp") as Texture2D
	player_profile_gates_background_texture = load("res://assets/ui/screens/player-profile-gates-bg-v1.webp") as Texture2D
	leagues_gates_background_texture = load("res://assets/ui/screens/leagues-gates-bg-v1.webp") as Texture2D
	rewards_gates_background_texture = load("res://assets/ui/screens/rewards-gates-bg-v1.webp") as Texture2D
	loading_team_texture = load("res://assets/ui/zoovortex-loading-v2.webp") as Texture2D
	# The new splash artwork already contains the approved ZOOVORTEX wordmark.
	zoopaloola_logo_texture = null
	wood_podium_texture = load("res://assets/ui/full_body/lifebuoy/wood-podium-v1.png") as Texture2D
	hero_saucer_texture = load("res://assets/ui/ships/hero-saucer-base-v1.png") as Texture2D
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
	for portrait_file in ["elephant-v1.png", "zebra-v1.png", "monkey-v1.png", "hippo-v1.png", "rhino-v1.png", "giraffe-v1.png", "tiger-v1.png"]:
		character_portrait_textures.append(load("res://assets/ui/character_portraits/" + portrait_file))
	for ship_file in ["elephant-pilot-v2.png", "zebra-pilot-v2.png", "monkey-pilot-v3.png", "hippo-pilot-v2.png", "rhino-pilot-v2.png", "giraffe-pilot-v2.png", "tiger-pilot-v2.png"]:
		character_ship_textures.append(load("res://assets/ui/character_ships/" + ship_file))
	for light_file in ["elephant-pilot-v2-lights.png", "zebra-pilot-v2-lights.png", "monkey-pilot-v3-lights.png", "hippo-pilot-v2-lights.png", "rhino-pilot-v2-lights.png", "giraffe-pilot-v2-lights.png", "tiger-pilot-v2-lights.png"]:
		character_ship_light_masks.append(load("res://assets/ui/character_ships/light_masks/" + light_file))
	rebuild_team_piece_textures()
	for i in 6:
		effect_textures.append(load("res://assets/remastered_effects/effect-%d.png" % i))
	rubber_ball_texture = load("res://assets/rubber_trap/rubber-ball.png") as Texture2D
	for i in 5:
		rubber_hand_textures.append(load("res://assets/rubber_trap/hands/pose-%d.png" % i))
	rubber_launcher_texture = load("res://assets/rubber_launcher/launcher.svg") as Texture2D
	rubber_wrap_texture = load("res://assets/rubber_launcher/wrap-sequence.svg") as Texture2D
	abyss_bloom_texture = load("res://assets/abyss_bloom/abyss-bloom-clean-v3.webp") as Texture2D
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
			duration = ABYSS_EFFECT_DURATION
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
			# Abyss Bloom consumes the piece inside the hole. Unlike the old
			# rubber weapon, it never throws or respawns the piece in the water.
			if active_effects[i].hole != RUBBER_TRAP_HOLE:
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
			app_screen = APP_HOME
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
	# Preserve the original match geometry while presenting the table above the
	# new floating-islands battle world.
	if battle_background_texture != null:
		draw_texture_rect(battle_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
	# Floating animals stay behind the elevated table and only remain visible on
	# the surrounding water.
	draw_water_floaters(viewport_size)
	# Each table theme keeps the exact approved gameplay geometry while using
	# its own production texture.
	var active_board_texture := board_theme_texture(active_board_theme())
	if active_board_texture != null:
		draw_texture_rect(active_board_texture, board_rect, false)
	draw_scoreboards()
	draw_abyss_bloom_idle()
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
			draw_abyss_bloom_trap(effect)
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
	var won := local_player_won(match_result_winner)
	draw_gate_panel(panel, Color("f6d365") if won else Color("b25cff"), 1.0, 0.97)
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
	var today_unix := Time.get_unix_time_from_datetime_string(daily_claim_key() + "T00:00:00")
	var previous_unix := Time.get_unix_time_from_datetime_string(last_daily_claim + "T00:00:00") if not last_daily_claim.is_empty() else 0
	if previous_unix > 0 and int((today_unix - previous_unix) / 86400.0) == 1:
		daily_login_streak += 1
	else:
		daily_login_streak = 1
	var rewards := [50, 60, 70, 80, 100, 120, 200]
	var reward_index := (daily_login_streak - 1) % rewards.size()
	var reward_coins: int = rewards[reward_index]
	player_coins += reward_coins
	last_daily_claim = daily_claim_key()
	save_player_profile()
	show_menu_notice(("קיבלתם %d מטבעות!" if ui_language == "he" else "YOU RECEIVED %d COINS!") % reward_coins)

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
	draw_gate_panel(panel, Color("a868ff"), 1.0, 0.98)
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

func hamm…53927 tokens truncated…"
		var slot_x := 760.0 + float(i) * 79.0
		draw_string(ui_font, Vector2(slot_x, 458.0) * unit, character, HORIZONTAL_ALIGNMENT_CENTER, 62.0 * unit, int(31.0 * unit), Color.WHITE if i < clean_code.length() else Color("7b69a5"), 0, TextServer.DIRECTION_LTR)

	var connection_text := "מחובר לשרת" if multiplayer_state == "connected" else ("מתחבר לשרת..." if multiplayer_state == "connecting" else "השרת לא מחובר")
	if ui_language != "he":
		connection_text = "CONNECTED" if multiplayer_state == "connected" else ("CONNECTING..." if multiplayer_state == "connecting" else "DISCONNECTED")
	var connection_color := Color("65ef9d") if multiplayer_state == "connected" else Color("ffd05a")
	draw_circle(Vector2(563.0, 586.0) * unit, 8.0 * unit, connection_color)
	draw_centered_ui_text(Vector2(574.0, 592.0) * unit, connection_text, 145.0 * unit, int(16.0 * unit), Color.WHITE)
	draw_centered_ui_text(Vector2(325.0, 676.0) * unit, "שתפו את קוד החדר עם החבר כדי שיצטרף אליכם" if ui_language == "he" else "SHARE THE ROOM CODE WITH YOUR FRIEND", 635.0 * unit, int(17.0 * unit), Color("d9f4ff"))
	if multiplayer_error != "":
		draw_string(ui_font, Vector2(325.0, 620.0) * unit, multiplayer_error, HORIZONTAL_ALIGNMENT_CENTER, 635.0 * unit, int(15.0 * unit), Color("ff8c7a"))

func draw_centered_ui_text(position: Vector2, text: String, width: float, font_size: int, color: Color) -> void:
	var direction := TextServer.DIRECTION_RTL if ui_language == "he" else TextServer.DIRECTION_LTR
	draw_string(ui_font, position, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color, 0, direction)

func draw_friend_lobby_concept_overlay(viewport_size: Vector2, unit: float) -> void:
	draw_centered_ui_text(Vector2(382.0, 83.0) * unit, "חדר פרטי" if ui_language == "he" else "PRIVATE ROOM", 516.0 * unit, int(38.0 * unit), Color("fff1c4"))
	draw_centered_ui_text(Vector2(382.0, 120.0) * unit, "הזמינו חבר והתכוננו לקרב" if ui_language == "he" else "INVITE A FRIEND AND GET READY", 516.0 * unit, int(18.0 * unit), Color("d9f4ff"))
	draw_centered_ui_text(Vector2(24.0, 66.0) * unit, "חזרה  ❮" if ui_language == "he" else "❮  BACK", 145.0 * unit, int(21.0 * unit), Color.WHITE)
	draw_centered_ui_text(Vector2(498.0, 181.0) * unit, "קוד החדר" if ui_language == "he" else "ROOM CODE", 235.0 * unit, int(16.0 * unit), Color.WHITE)
	draw_string(ui_font, Vector2(498.0, 235.0) * unit, multiplayer_room_code, HORIZONTAL_ALIGNMENT_CENTER, 235.0 * unit, int(38.0 * unit), Color("ffe25d"), 0, TextServer.DIRECTION_LTR)
	draw_centered_ui_text(Vector2(735.0, 200.0) * unit, "שיתוף לחבר" if ui_language == "he" else "SHARE INVITE", 185.0 * unit, int(17.0 * unit), Color.WHITE)
	draw_centered_ui_text(Vector2(735.0, 254.0) * unit, "יציאה מהחדר" if ui_language == "he" else "LEAVE ROOM", 185.0 * unit, int(15.0 * unit), Color.WHITE)

	for i in 2:
		var portal_center := Vector2(360.0 + float(i) * 610.0, 335.0) * unit
		# The name/status copy belongs to the plaque beneath each portal. Keep its
		# center aligned with the portal instead of offsetting it toward the edge.
		var info_x := 190.0 + float(i) * 610.0
		if i < multiplayer_players.size():
			var player_data: Dictionary = multiplayer_players[i]
			var animal := clampi(int(player_data.get("animal", 0)), 0, ANIMAL_NAMES.size() - 1)
			var ring := clampi(int(player_data.get("ringColor", 0)), 0, RING_COLORS.size() - 1)
			draw_matchmaking_ship(Rect2(portal_center - Vector2(108.0, 108.0) * unit, Vector2(216.0, 216.0) * unit), animal, ring)
			draw_centered_ui_text(Vector2(info_x, 466.0) * unit, str(player_data.get("name", "Player")), 340.0 * unit, int(23.0 * unit), Color.WHITE)
			draw_centered_ui_text(Vector2(info_x, 493.0) * unit, ("רמה %d" if ui_language == "he" else "LEVEL %d") % int(player_data.get("level", 1)), 340.0 * unit, int(15.0 * unit), Color("cdefff"))
			var is_ready := bool(player_data.get("ready", false))
			draw_centered_ui_text(Vector2(info_x, 518.0) * unit, ("מוכן" if ui_language == "he" else "READY") if is_ready else ("לא מוכן" if ui_language == "he" else "NOT READY"), 340.0 * unit, int(15.0 * unit), Color("65ef9d") if is_ready else Color("ffd05a"))
		else:
			# A private room reserves this portal for the invited friend. Keep one
			# calm placeholder instead of cycling silhouettes like matchmaking.
			draw_mystery_matchmaking_ship(portal_center, unit, 0)
			draw_string(ui_font, portal_center + Vector2(-30.0, 17.0) * unit, "?", HORIZONTAL_ALIGNMENT_CENTER, 60.0 * unit, int(48.0 * unit), Color.WHITE)
			draw_centered_ui_text(Vector2(info_x, 486.0) * unit, "ממתינים לחבר..." if ui_language == "he" else "WAITING FOR A FRIEND...", 340.0 * unit, int(23.0 * unit), Color.WHITE)

	var ready_text := ("ביטול מוכנות" if multiplayer_ready else "אני מוכן") if ui_language == "he" else ("NOT READY" if multiplayer_ready else "I'M READY")
	draw_centered_ui_text(Vector2(412.0, 617.0) * unit, ready_text, 456.0 * unit, int(32.0 * unit), Color.WHITE)
	var connection_text := "מחובר לשרת" if multiplayer_state == "connected" else ("מתחבר..." if ui_language == "he" else "CONNECTING...")
	if ui_language != "he" and multiplayer_state == "connected":
		connection_text = "CONNECTED"
	draw_circle(Vector2(43.0, 683.0) * unit, 8.0 * unit, Color("65ef9d") if multiplayer_state == "connected" else Color("ffd05a"))
	draw_centered_ui_text(Vector2(55.0, 690.0) * unit, connection_text, 130.0 * unit, int(14.0 * unit), Color.WHITE)
	var chat_rect := Rect2(1040.0, 658.0, 190.0, 44.0)
	draw_style_box(make_box(Color("1b91a8"), 12.0 * unit), chat_rect)
	draw_centered_ui_text(chat_rect.position + Vector2(0.0, 31.0) * unit, ui_text("room_chat"), chat_rect.size.x, int(15.0 * unit), Color.WHITE)
	if multiplayer_error != "":
		draw_centered_ui_text(Vector2(420.0, 688.0) * unit, multiplayer_error, 440.0 * unit, int(14.0 * unit), Color("ff8c7a"))

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
	draw_gate_panel(modal, Color("a868ff"), unit, 0.98)
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
	draw_gate_panel(rect, accent, unit, 0.97)
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
	draw_style_box(make_box(Color(0.025, 0.075, 0.16, 0.98), 8.0 * unit), name_bar)
	var card_name := profile_name if is_local_player else ("מחפשים..." if ui_language == "he" else "SEARCHING...")
	if not is_local_player and not opponent.is_empty():
		card_name = str(opponent.get("name", card_name))
	draw_string(ui_font, name_bar.position + Vector2(10.0, 31.0) * unit, card_name, HORIZONTAL_ALIGNMENT_CENTER, name_bar.size.x - 20.0 * unit, int(21.0 * unit), Color.WHITE)
	var detail := player_level_label() if is_local_player else ("יריב מתאים יצטרף בקרוב" if ui_language == "he" else "A MATCHED OPPONENT WILL APPEAR")
	if not is_local_player and not opponent.is_empty():
		if bool(opponent.get("isBot", false)):
			detail = ("יריב אימון • דירוג %d" if ui_language == "he" else "TRAINING RIVAL • RATING %d") % int(opponent.get("rating", 1000))
		else:
			detail = ("דירוג: %d" if ui_language == "he" else "RATING: %d") % int(opponent.get("rating", 1000))
	draw_string(ui_font, name_bar.position + Vector2(10.0, 54.0) * unit, detail, HORIZONTAL_ALIGNMENT_CENTER, name_bar.size.x - 20.0 * unit, int(11.0 * unit), Color("a9cde2"))
	var badge_center := rect.position + Vector2(24.0, 24.0) * unit
	draw_circle(badge_center, 23.0 * unit, Color("ffe25d") if is_local_player else Color("59d7f0"))
	var badge_value := str(player_level) if is_local_player else "?"
	if not is_local_player and not opponent.is_empty():
		badge_value = str(int(opponent.get("level", 1)))
	draw_string(ui_font, badge_center + Vector2(-18.0, 7.0) * unit, badge_value, HORIZONTAL_ALIGNMENT_CENTER, 36.0 * unit, int(17.0 * unit), Color("173249"))

func matchmaking_hero_texture(animal: int, ring_color: int) -> Texture2D:
	var safe_animal := clampi(animal, 0, ANIMAL_NAMES.size() - 1)
	if safe_animal < character_ship_textures.size():
		return character_ship_textures[safe_animal]
	return null

func draw_matchmaking_ship(rect: Rect2, animal: int, ring_color: int, tint: Color = Color.WHITE) -> void:
	var safe_animal := clampi(animal, 0, ANIMAL_NAMES.size() - 1)
	var safe_ring := clampi(ring_color, 0, RING_COLORS.size() - 1)
	var ship := matchmaking_hero_texture(safe_animal, safe_ring)
	if ship == null:
		return
	draw_texture_rect(ship, rect, false, tint)
	if tint == Color.WHITE and safe_animal < character_ship_light_masks.size():
		var light_mask: Texture2D = character_ship_light_masks[safe_animal]
		if light_mask != null:
			draw_texture_rect(light_mask, rect, false, RING_COLORS[safe_ring].lightened(0.12))

func draw_mystery_matchmaking_ship(center: Vector2, unit: float, animal: int) -> void:
	# Cycle through the actual character ships while hiding their identity. The
	# centered square matches the player's placement and stays inside the portal.
	var size := 225.0 * unit
	draw_matchmaking_ship(Rect2(center - Vector2(size, size) * 0.5, Vector2(size, size)), animal, 2, Color(0.018, 0.010, 0.070, 0.92))

func draw_concept_matchmaking_screen(viewport_size: Vector2) -> bool:
	var found: bool = arena_fx_phase == "found"
	var background: Texture2D = arena_found_concept_texture if found else arena_search_concept_texture
	if background == null:
		return false
	draw_texture_rect(background, Rect2(Vector2.ZERO, viewport_size), false)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var opponent: Dictionary = arena_matched_opponent if found else {}
	if found:
		var found_ship_size := 310.0 * unit
		draw_matchmaking_ship(Rect2(viewport_size.x * 0.165 - found_ship_size * 0.5, 130.0 * unit, found_ship_size, found_ship_size), player_animal, player_ring_color)
		var opponent_animal := clampi(int(opponent.get("animal", 0)), 0, ANIMAL_NAMES.size() - 1)
		var opponent_ring := clampi(int(opponent.get("ringColor", 2)), 0, RING_COLORS.size() - 1)
		draw_matchmaking_ship(Rect2(viewport_size.x * 0.835 - found_ship_size * 0.5, 130.0 * unit, found_ship_size, found_ship_size), opponent_animal, opponent_ring)
		draw_string(ui_font, Vector2(0.0, 77.0 * unit), ui_text("match_found"), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(42.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(0.0, 118.0 * unit), "מתכוננים לקרב" if ui_language == "he" else "GET READY TO BATTLE", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(22.0 * unit), Color("d8efff"))
		draw_string(ui_font, Vector2(viewport_size.x * 0.035, 520.0 * unit), profile_name, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.34, int(28.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(viewport_size.x * 0.625, 520.0 * unit), str(opponent.get("name", "יריב")), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.34, int(28.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(viewport_size.x * 0.035, 557.0 * unit), ("רמה %d  •  דירוג %d" if ui_language == "he" else "LEVEL %d  •  RATING %d") % [player_level, player_rating], HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.34, int(18.0 * unit), Color("cdefff"))
		draw_string(ui_font, Vector2(viewport_size.x * 0.625, 557.0 * unit), ("רמה %d  •  דירוג %d" if ui_language == "he" else "LEVEL %d  •  RATING %d") % [int(opponent.get("level", 1)), int(opponent.get("rating", 1000))], HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.34, int(18.0 * unit), Color("f2d7ff"))
		var countdown := maxi(1, int(ceil(ARENA_MATCH_FOUND_DURATION - arena_fx_elapsed)))
		draw_string(ui_font, Vector2(0.0, 638.0 * unit), str(countdown), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(48.0 * unit), Color.WHITE)
	else:
		var search_ship_size := 250.0 * unit
		draw_matchmaking_ship(Rect2(viewport_size.x * 0.160 - search_ship_size * 0.5, 120.0 * unit, search_ship_size, search_ship_size), player_animal, player_ring_color)
		var preview_animal := int(floor(menu_elapsed * 2.5)) % ANIMAL_NAMES.size()
		draw_mystery_matchmaking_ship(Vector2(viewport_size.x * 0.792, 232.0 * unit), unit, preview_animal)
		draw_string(ui_font, Vector2(0.0, 77.0 * unit), "מחפשים יריב" if ui_language == "he" else "FINDING AN OPPONENT", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(40.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(viewport_size.x * 0.045, 354.0 * unit), profile_name, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.30, int(25.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(viewport_size.x * 0.655, 354.0 * unit), "מחפשים..." if ui_language == "he" else "SEARCHING...", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.30, int(25.0 * unit), Color.WHITE)
		draw_string(ui_font, Vector2(viewport_size.x * 0.785, 278.0 * unit), "?", HORIZONTAL_ALIGNMENT_CENTER, 90.0 * unit, int(62.0 * unit), Color.WHITE)
	var arena_names: Array[String] = ["שער הירח", "ממלכת השמיים", "מבצר הכתר"]
	var arena_name := arena_names[clampi(selected_arena, 0, 2)]
	var arena_title_y := 480.0 if found else 510.0
	var arena_prize_y := 508.0 if found else 541.0
	draw_string(ui_font, Vector2(0.0, arena_title_y * unit), arena_name, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int((25.0 if found else 30.0) * unit), Color.WHITE)
	draw_string(ui_font, Vector2(0.0, arena_prize_y * unit), ("פרס הקרב %d" if ui_language == "he" else "BATTLE PRIZE %d") % int(ARENA_WIN_PRIZES[clampi(selected_arena, 0, 2)]), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(18.0 * unit), Color("ffe25d"))
	if found:
		draw_string(ui_font, Vector2(0.0, 690.0 * unit), "ביטול" if ui_language == "he" else "CANCEL", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(27.0 * unit), Color.WHITE)
	else:
		draw_string(ui_font, Vector2(0.0, 663.0 * unit), ui_text("cancel_search"), HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(29.0 * unit), Color.WHITE)
	return true

func draw_arena_search_screen(viewport_size: Vector2) -> void:
	if draw_concept_matchmaking_screen(viewport_size):
		return
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	# Matchmaking is its own cinematic scene: one active gate replaces the
	# three-gate selection view, matching the approved search concept.
	if battle_background_texture != null:
		draw_texture_rect(battle_background_texture, Rect2(Vector2.ZERO, viewport_size), false)
	if arena_gates_background_texture != null:
		var gate_size := Vector2(510.0, 430.0) * unit
		var gate_rect := Rect2(Vector2(viewport_size.x * 0.5 - gate_size.x * 0.5, 104.0 * unit), gate_size)
		var gate_source := Rect2(565.0, 80.0, 790.0, 720.0)
		draw_texture_rect_region(arena_gates_background_texture, gate_rect, gate_source, Color.WHITE)
	draw_arena_tunnel_fx(viewport_size, 1.0 if arena_fx_phase == "searching" else 1.35)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.005, 0.035, 0.07, 0.18))
	var header_title := "מחפשים יריב" if ui_language == "he" else "FINDING AN OPPONENT"
	if arena_fx_phase == "found":
		header_title = ui_text("match_found")
	draw_frontend_header(viewport_size, header_title, ("פותחים את שער הקרב..." if arena_fx_phase != "found" else "מתכוננים לקרב") if ui_language == "he" else ("OPENING THE BATTLE GATE..." if arena_fx_phase != "found" else "PREPARING FOR BATTLE"))
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
	draw_circle(vs_center, vs_pulse * unit, Color(0.02, 0.08, 0.18, 0.96))
	draw_circle(vs_center, 55.0 * unit, Color("58dcff") if arena_fx_phase != "found" else Color("ffe25d"), false, 7.0 * unit, true)
	draw_string(ui_font, vs_center + Vector2(-58.0, 20.0) * unit, "VS", HORIZONTAL_ALIGNMENT_CENTER, 116.0 * unit, int(48.0 * unit), Color("b6f13f"))
	var dots: String = [".", "..", "..."][int(menu_elapsed * 2.2) % 3]
	var status_line := ("מחפשים יריב מתאים" if ui_language == "he" else "SEARCHING FOR A MATCH") + dots
	if arena_fx_phase == "found":
		var countdown: int = maxi(1, int(ceil(ARENA_MATCH_FOUND_DURATION - arena_fx_elapsed)))
		status_line = ("הקרב מתחיל בעוד %d" if ui_language == "he" else "BATTLE STARTS IN %d") % countdown
	draw_string(ui_font, Vector2(0.0, 566.0 * unit), status_line, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(22.0 * unit), Color("ffe25d"))
	var arena_names: Array[String] = []
	if ui_language == "he":
		arena_names.assign(["שער הירח", "ממלכת השמיים", "מבצר הכתר"])
	else:
		arena_names.assign(["MOON GATE", "SKY KINGDOM", "CROWN FORTRESS"])
	var arena_info := arena_names[clampi(selected_arena, 0, 2)] + ("  •  פרס הקרב " if ui_language == "he" else "  •  BATTLE PRIZE ") + str(ARENA_WIN_PRIZES[clampi(selected_arena, 0, 2)])
	draw_string(ui_font, Vector2(0.0, 598.0 * unit), arena_info, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, int(15.0 * unit), Color("c9edf7"))
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
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.035, 0.08, 0.05))
	draw_frontend_header(viewport_size, "זירה תחרותית" if ui_language == "he" else "COMPETITIVE ARENA", "בחרו זירה והילחמו על הדירוג" if ui_language == "he" else "CHOOSE AN ARENA AND FIGHT FOR RANK")
	draw_shop_coin_box(viewport_size, unit)
	var names: Array[String] = []
	if ui_language == "he":
		names.assign(["שער הירח", "ממלכת השמיים", "מבצר הכתר"])
	else:
		names.assign(["MOON GATE", "SKY KINGDOM", "CROWN FORTRESS"])
	var entries: Array[int] = [int(ARENA_ENTRY_COSTS[0]), int(ARENA_ENTRY_COSTS[1]), int(ARENA_ENTRY_COSTS[2])]
	var prizes: Array[int] = [int(ARENA_WIN_PRIZES[0]), int(ARENA_WIN_PRIZES[1]), int(ARENA_WIN_PRIZES[2])]
	var rating_requirements: Array[int] = [0, 1000, 1300]
	var card_colors: Array[Color] = [Color("9a4ff1"), Color("21c8ff"), Color("ffad24")]
	for i in 3:
		var card := arena_card_rect(i, viewport_size)
		var selected: bool = i == selected_arena
		var pulse: float = (sin(menu_elapsed * 4.2) + 1.0) * 0.5 if selected else 0.0
		var border: Color = Color("ffe25d") if selected else card_colors[i].lightened(0.18)
		# The portals live in the background art. These outlines and plaques turn
		# each one into a large, tactile gate without covering the illustration.
		if selected:
			draw_style_box(make_box(Color("ffe25d", 0.20 + pulse * 0.12), 28.0 * unit), card.grow((7.0 + pulse * 3.0) * unit))
			draw_rect(card.grow(4.0 * unit), Color("ffe25d"), false, 4.0 * unit)
		var title_rect := Rect2(card.position + Vector2(12.0, 250.0) * unit, Vector2(card.size.x - 24.0 * unit, 58.0 * unit))
		draw_style_box(make_box(Color(0.015, 0.045, 0.11, 0.96), 13.0 * unit), title_rect.grow(5.0 * unit))
		draw_style_box(make_box(Color(card_colors[i].r, card_colors[i].g, card_colors[i].b, 0.90), 11.0 * unit), title_rect)
		draw_rect(title_rect, border, false, (4.0 if selected else 2.0) * unit)
		draw_string(ui_font, title_rect.position + Vector2(0.0, 38.0 * unit), names[i], HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, int(22.0 * unit), Color.WHITE)

		var info_rect := Rect2(card.position + Vector2(7.0, 316.0) * unit, Vector2(card.size.x - 14.0 * unit, 119.0 * unit))
		draw_style_box(make_box(Color(0.012, 0.045, 0.105, 0.96), 15.0 * unit), info_rect.grow(4.0 * unit))
		draw_style_box(make_box(Color(0.025, 0.085, 0.18, 0.96), 13.0 * unit), info_rect)
		draw_rect(info_rect, Color(border.r, border.g, border.b, 0.88), false, (3.0 if selected else 2.0) * unit)
		var column_width: float = info_rect.size.x / 3.0
		for divider in [1, 2]:
			var divider_x: float = info_rect.position.x + column_width * float(divider)
			draw_line(Vector2(divider_x, info_rect.position.y + 14.0 * unit), Vector2(divider_x, info_rect.end.y - 14.0 * unit), Color("47769e", 0.65), 2.0 * unit)
		var labels: Array[String] = []
		if ui_language == "he":
			labels.assign(["כניסה", "פרס ניצחון", "דירוג נדרש"])
		else:
			labels.assign(["ENTRY", "WIN PRIZE", "RATING"])
		var entry_value: String = "חינם" if entries[i] == 0 and ui_language == "he" else ("FREE" if entries[i] == 0 else str(entries[i]))
		var rating_value: String = "—" if rating_requirements[i] == 0 else str(rating_requirements[i])
		var values: Array[String] = [entry_value, str(prizes[i]), rating_value]
		for column in 3:
			var column_x: float = info_rect.position.x + column_width * float(column)
			draw_string(ui_font, Vector2(column_x, info_rect.position.y + 31.0 * unit), labels[column], HORIZONTAL_ALIGNMENT_CENTER, column_width, int(12.0 * unit), Color("c9edf7"))
			if column < 2 and not (column == 0 and entries[i] == 0):
				draw_circle(Vector2(column_x + column_width * 0.50, info_rect.position.y + 63.0 * unit), 12.0 * unit, Color("ffc83d"))
				draw_string(ui_font, Vector2(column_x, info_rect.position.y + 101.0 * unit), values[column], HORIZONTAL_ALIGNMENT_CENTER, column_width, int(18.0 * unit), Color("ffe25d"))
			else:
				draw_string(ui_font, Vector2(column_x, info_rect.position.y + 78.0 * unit), values[column], HORIZONTAL_ALIGNMENT_CENTER, column_width, int(20.0 * unit), Color("65efa9") if entries[i] == 0 else Color("ffe25d"))
		if selected:
			var pointer := Vector2(card.get_center().x, info_rect.end.y + 8.0 * unit)
			draw_colored_polygon(PackedVector2Array([pointer + Vector2(-14.0, 0.0) * unit, pointer + Vector2(14.0, 0.0) * unit, pointer + Vector2(0.0, 18.0) * unit]), Color("ffe25d"))
	var play := arena_play_rect(viewport_size)
	var button_pulse: float = (sin(menu_elapsed * 4.0) + 1.0) * 0.5
	draw_style_box(make_box(Color("071b3d"), 20.0 * unit), play.grow((7.0 + button_pulse * 2.0) * unit))
	draw_style_box(make_box(Color("159fe1"), 17.0 * unit), play)
	draw_rect(play, Color("72e8ff"), false, 4.0 * unit)
	draw_string(ui_font, play.position + Vector2(0.0, 43.0 * unit), "⚔  חיפוש יריב  ⚔" if ui_language == "he" else "⚔  FIND OPPONENT  ⚔", HORIZONTAL_ALIGNMENT_CENTER, play.size.x, int(25.0 * unit), Color.WHITE)

func draw_profile_stat_card(rect: Rect2, label: String, value: String, accent: Color, unit: float) -> void:
	draw_style_box(make_box(Color(accent.r, accent.g, accent.b, 0.82), 15.0 * unit), rect.grow(3.0 * unit))
	draw_style_box(make_box(Color(0.018, 0.075, 0.17, 0.98), 13.0 * unit), rect)
	var icon_center := rect.position + Vector2(rect.size.x * 0.50, 29.0 * unit)
	draw_circle(icon_center, 17.0 * unit, Color(accent.r, accent.g, accent.b, 0.18))
	draw_colored_polygon(PackedVector2Array([icon_center + Vector2(0.0, -11.0) * unit, icon_center + Vector2(10.0, 0.0) * unit, icon_center + Vector2(0.0, 11.0) * unit, icon_center + Vector2(-10.0, 0.0) * unit]), accent)
	draw_string(ui_font, rect.position + Vector2(0.0, 67.0) * unit, label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(13.0 * unit), Color("bfeaff"))
	draw_string(ui_font, rect.position + Vector2(0.0, 104.0) * unit, value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(28.0 * unit), Color.WHITE)

func draw_player_profile_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.08, 0.12))
	draw_frontend_header(viewport_size, "פרופיל שחקן" if ui_language == "he" else "PLAYER PROFILE", "המסע וההישגים שלכם" if ui_language == "he" else "YOUR JOURNEY AND ACHIEVEMENTS")

	# Large selected pilot with the same live energy color as character selection.
	var hover: float = sin(menu_elapsed * 1.7) * 5.0 * unit
	var hero_rect := Rect2(Vector2(18.0, 126.0) * unit + Vector2(0.0, hover), Vector2(448.0, 448.0) * unit)
	if player_animal < character_ship_textures.size() and character_ship_textures[player_animal] != null:
		draw_texture_rect(character_ship_textures[player_animal], hero_rect, false)
		if player_animal < character_ship_light_masks.size() and character_ship_light_masks[player_animal] != null:
			var hero_energy: Color = RING_COLORS[clampi(player_ring_color, 0, RING_COLORS.size() - 1)].lightened(0.12)
			draw_texture_rect(character_ship_light_masks[player_animal], hero_rect, false, hero_energy)
	var platform_center := Vector2(242.0, 566.0) * unit
	draw_set_transform(platform_center, 0.0, Vector2(1.0, 0.30))
	draw_circle(Vector2.ZERO, 166.0 * unit, Color(0.05, 0.14, 0.25, 0.82))
	draw_arc(Vector2.ZERO, 158.0 * unit, 0.0, TAU, 72, Color("58dcff"), 7.0 * unit, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var name_plaque := Rect2(Vector2(88.0, 584.0) * unit, Vector2(310.0, 75.0) * unit)
	draw_gate_panel(name_plaque, league_color(player_league_tier), unit, 0.92)
	draw_string(ui_font, name_plaque.position + Vector2(0.0, 34.0) * unit, profile_name, HORIZONTAL_ALIGNMENT_CENTER, name_plaque.size.x, int(23.0 * unit), Color.WHITE)
	draw_string(ui_font, name_plaque.position + Vector2(0.0, 61.0) * unit, league_name(player_league_tier) + "  •  " + ("רמה " if ui_language == "he" else "LEVEL ") + str(player_level), HORIZONTAL_ALIGNMENT_CENTER, name_plaque.size.x, int(14.0 * unit), Color("ffe25d"))

	var info_panel := Rect2(Vector2(474.0, 102.0) * unit, Vector2(768.0, 570.0) * unit)
	draw_gate_panel(info_panel, Color("58dcff"), unit, 0.96)
	draw_circle(info_panel.position + Vector2(66.0, 70.0) * unit, 47.0 * unit, Color("d6a62f"))
	draw_circle(info_panel.position + Vector2(66.0, 70.0) * unit, 40.0 * unit, Color("092657"))
	var avatar_texture: Texture2D = character_ship_textures[player_animal] if player_animal < character_ship_textures.size() else null
	if avatar_texture != null:
		draw_texture_rect(avatar_texture, Rect2(info_panel.position + Vector2(31.0, 35.0) * unit, Vector2(70.0, 70.0) * unit), false)
	draw_string(ui_font, info_panel.position + Vector2(180.0, 28.0) * unit, "שם השחקן" if ui_language == "he" else "PLAYER NAME", HORIZONTAL_ALIGNMENT_LEFT, 350.0 * unit, int(12.0 * unit), Color("8cecff"))
	var pending_id := "מתחבר..." if ui_language == "he" else "CONNECTING..."
	var public_id_text := firebase_public_id if not firebase_public_id.is_empty() else pending_id
	draw_string(ui_font, info_panel.position + Vector2(180.0, 99.0) * unit, public_id_text, HORIZONTAL_ALIGNMENT_LEFT, 380.0 * unit, int(14.0 * unit), Color("bfeaff"))
	var coin_box := Rect2(info_panel.position + Vector2(590.0, 34.0) * unit, Vector2(142.0, 60.0) * unit)
	draw_style_box(make_box(Color("172f59"), 16.0 * unit), coin_box)
	draw_circle(coin_box.position + Vector2(30.0, 30.0) * unit, 16.0 * unit, Color("ffc83d"))
	draw_string(ui_font, coin_box.position + Vector2(55.0, 39.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, 76.0 * unit, int(20.0 * unit), Color.WHITE)
	var xp_rect := Rect2(info_panel.position + Vector2(180.0, 116.0) * unit, Vector2(500.0, 18.0) * unit)
	draw_style_box(make_box(Color("14294c"), 9.0 * unit), xp_rect.grow(3.0 * unit))
	var xp_ratio := clampf(float(player_xp) / float(maxi(1, player_next_level_xp)), 0.0, 1.0)
	draw_style_box(make_box(Color("38dfff"), 9.0 * unit), Rect2(xp_rect.position, Vector2(xp_rect.size.x * xp_ratio, xp_rect.size.y)))
	draw_string(ui_font, info_panel.position + Vector2(180.0, 158.0) * unit, ("רמה " if ui_language == "he" else "LEVEL ") + str(player_level), HORIZONTAL_ALIGNMENT_LEFT, 180.0 * unit, int(13.0 * unit), Color("ffe25d"))
	draw_string(ui_font, info_panel.position + Vector2(490.0, 158.0) * unit, str(player_xp) + " / " + str(player_next_level_xp) + " XP", HORIZONTAL_ALIGNMENT_RIGHT, 190.0 * unit, int(12.0 * unit), Color("bfeaff"))

	var total_matches := player_wins + player_losses
	var win_rate := 0
	if total_matches > 0:
		win_rate = int(round(float(player_wins) * 100.0 / float(total_matches)))
	var labels := [ui_text("matches"), ui_text("wins"), ui_text("win_rate"), ui_text("rating_label")]
	var values := [str(total_matches), str(player_wins), str(win_rate) + "%", str(player_rating)]
	var accents := [Color("58dcff"), Color("ffc83d"), Color("5fe3c0"), Color("ffd45c")]
	for i in 4:
		var stat_rect := Rect2(info_panel.position + Vector2(30.0 + float(i) * 178.0, 184.0) * unit, Vector2(164.0, 116.0) * unit)
		draw_profile_stat_card(stat_rect, labels[i], values[i], accents[i], unit)

	var league_card := Rect2(info_panel.position + Vector2(30.0, 322.0) * unit, Vector2(330.0, 174.0) * unit)
	var achievement_card := Rect2(info_panel.position + Vector2(378.0, 322.0) * unit, Vector2(360.0, 174.0) * unit)
	for card in [league_card, achievement_card]:
		draw_style_box(make_box(Color("234b80"), 16.0 * unit), card.grow(3.0 * unit))
		draw_style_box(make_box(Color("061b3e"), 14.0 * unit), card)
	draw_string(ui_font, league_card.position + Vector2(0.0, 34.0) * unit, "הליגה שלי" if ui_language == "he" else "MY LEAGUE", HORIZONTAL_ALIGNMENT_CENTER, league_card.size.x, int(19.0 * unit), Color.WHITE)
	var badge_center := league_card.position + Vector2(165.0, 92.0) * unit
	draw_colored_polygon(PackedVector2Array([badge_center + Vector2(0.0, -42.0) * unit, badge_center + Vector2(42.0, -12.0) * unit, badge_center + Vector2(30.0, 36.0) * unit, badge_center, badge_center + Vector2(-30.0, 36.0) * unit, badge_center + Vector2(-42.0, -12.0) * unit]), league_color(player_league_tier))
	draw_colored_polygon(PackedVector2Array([badge_center + Vector2(0.0, -25.0) * unit, badge_center + Vector2(20.0, 0.0) * unit, badge_center + Vector2(0.0, 26.0) * unit, badge_center + Vector2(-20.0, 0.0) * unit]), Color("fff0a0"))
	draw_string(ui_font, league_card.position + Vector2(0.0, 158.0) * unit, league_name(player_league_tier) + "  •  " + str(player_rating), HORIZONTAL_ALIGNMENT_CENTER, league_card.size.x, int(16.0 * unit), Color("ffe25d"))

	draw_string(ui_font, achievement_card.position + Vector2(0.0, 34.0) * unit, "הישגים" if ui_language == "he" else "ACHIEVEMENTS", HORIZONTAL_ALIGNMENT_CENTER, achievement_card.size.x, int(19.0 * unit), Color.WHITE)
	for medal in 3:
		var medal_center := achievement_card.position + Vector2(92.0 + float(medal) * 88.0, 92.0) * unit
		var medal_color: Color = [Color("d68a47"), Color("c7d8f0"), Color("4e668d")][medal]
		draw_circle(medal_center, 30.0 * unit, Color("102b57"))
		draw_circle(medal_center, 24.0 * unit, medal_color)
		draw_colored_polygon(PackedVector2Array([medal_center + Vector2(0.0, -13.0) * unit, medal_center + Vector2(12.0, -4.0) * unit, medal_center + Vector2(8.0, 12.0) * unit, medal_center, medal_center + Vector2(-8.0, 12.0) * unit, medal_center + Vector2(-12.0, -4.0) * unit]), Color("fff2b0") if medal < 2 else Color("71839b"))
	var achievement_bar := Rect2(achievement_card.position + Vector2(28.0, 137.0) * unit, Vector2(304.0, 16.0) * unit)
	draw_style_box(make_box(Color("162c50"), 8.0 * unit), achievement_bar)
	draw_style_box(make_box(Color("33dfff"), 8.0 * unit), Rect2(achievement_bar.position, Vector2(achievement_bar.size.x * 0.45, achievement_bar.size.y)))
	draw_string(ui_font, achievement_card.position + Vector2(250.0, 158.0) * unit, "18 / 40", HORIZONTAL_ALIGNMENT_RIGHT, 82.0 * unit, int(12.0 * unit), Color.WHITE)

	var edit_rect := player_edit_profile_rect(viewport_size)
	draw_style_box(make_box(Color("70420b"), 15.0 * unit), edit_rect.grow(4.0 * unit))
	draw_style_box(make_box(Color("e8a21d"), 13.0 * unit), edit_rect)
	draw_line(edit_rect.position + Vector2(22.0, 7.0) * unit, Vector2(edit_rect.end.x - 22.0 * unit, edit_rect.position.y + 7.0 * unit), Color("fff1a8"), 2.0 * unit, true)
	var pencil_center := edit_rect.position + Vector2(47.0, 24.0) * unit
	draw_line(pencil_center + Vector2(-8.0, 7.0) * unit, pencil_center + Vector2(8.0, -9.0) * unit, Color.WHITE, 6.0 * unit, true)
	draw_colored_polygon(PackedVector2Array([pencil_center + Vector2(-11.0, 10.0) * unit, pencil_center + Vector2(-5.0, 8.0) * unit, pencil_center + Vector2(-9.0, 4.0) * unit]), Color("fff1a8"))
	draw_string(ui_font, edit_rect.position + Vector2(28.0, 32.0) * unit, "עריכת פרופיל" if ui_language == "he" else "EDIT PROFILE", HORIZONTAL_ALIGNMENT_CENTER, edit_rect.size.x - 45.0 * unit, int(18.0 * unit), Color.WHITE)
	var copy_rect := player_id_copy_rect(viewport_size)
	draw_style_box(make_box(Color("173d72") if not firebase_public_id.is_empty() else Color("44556a"), 10.0 * unit), copy_rect)
	draw_rect(Rect2(copy_rect.position + Vector2(15.0, 9.0) * unit, Vector2(15.0, 15.0) * unit), Color("8cecff"), false, 2.0 * unit)
	draw_rect(Rect2(copy_rect.position + Vector2(20.0, 14.0) * unit, Vector2(15.0, 15.0) * unit), Color.WHITE, false, 2.0 * unit)

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
	if battle_gates_home_texture != null:
		draw_battle_gates_home_screen(viewport_size)
		return
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

func draw_battle_gates_home_screen(viewport_size: Vector2) -> void:
	if battle_gates_league_open:
		draw_battle_gates_league_screen(viewport_size)
		return
	draw_texture_rect(battle_gates_home_texture, Rect2(Vector2.ZERO, viewport_size), false)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)

	# All account data and labels are live UI. Nothing user-specific is baked
	# into the background artwork, so language and progression update instantly.
	var title_rect := Rect2(Vector2(viewport_size.x * 0.365, 18.0 * unit), Vector2(viewport_size.x * 0.270, 78.0 * unit))
	draw_gate_panel(title_rect, Color("58dcff"), unit, 0.93)
	draw_string(ui_font, title_rect.position + Vector2(0.0, 51.0) * unit, "שערי הקרב" if ui_language == "he" else "BATTLE GATES", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, int(29.0 * unit), Color.WHITE)

	var profile := home_profile_rect(viewport_size)
	draw_gate_panel(profile, Color("58dcff"), unit, 0.95)
	var avatar_center := profile.position + Vector2(45.0, 43.0) * unit
	draw_circle(avatar_center, 34.0 * unit, Color("d6a62f"))
	draw_circle(avatar_center, 28.0 * unit, Color("173d72"))
	draw_string(ui_font, avatar_center + Vector2(-25.0, 10.0) * unit, profile_initial(), HORIZONTAL_ALIGNMENT_CENTER, 50.0 * unit, int(25.0 * unit), Color.WHITE)
	draw_string(ui_font, profile.position + Vector2(88.0, 32.0) * unit, profile_name, HORIZONTAL_ALIGNMENT_LEFT, profile.size.x - 100.0 * unit, int(20.0 * unit), Color.WHITE)
	draw_string(ui_font, profile.position + Vector2(88.0, 57.0) * unit, ("רמה %d" if ui_language == "he" else "LEVEL %d") % player_level, HORIZONTAL_ALIGNMENT_LEFT, 105.0 * unit, int(13.0 * unit), Color("8cecff"))
	var xp_track := Rect2(profile.position + Vector2(88.0, 65.0) * unit, Vector2(112.0, 7.0) * unit)
	draw_style_box(make_box(Color("13294a"), 4.0 * unit), xp_track)
	var xp_ratio := clampf(float(player_xp) / float(maxi(1, player_next_level_xp)), 0.0, 1.0)
	draw_style_box(make_box(Color("42dfff"), 4.0 * unit), Rect2(xp_track.position, Vector2(xp_track.size.x * xp_ratio, xp_track.size.y)))
	var id_rect := player_id_copy_rect(viewport_size)
	var id_text := firebase_public_id if not firebase_public_id.is_empty() else ("מתחבר..." if ui_language == "he" else "CONNECTING...")
	draw_style_box(make_box(Color(0.035, 0.10, 0.22, 0.96), 10.0), id_rect)
	draw_string(ui_font, id_rect.position + Vector2(8.0, id_rect.size.y * 0.67), id_text, HORIZONTAL_ALIGNMENT_LEFT, id_rect.size.x - 36.0, maxi(10, int(viewport_size.y * 0.018)), Color("dff6ff"))
	draw_string(ui_font, id_rect.position + Vector2(id_rect.size.x - 30.0, id_rect.size.y * 0.68), "▣", HORIZONTAL_ALIGNMENT_CENTER, 24.0, maxi(11, int(viewport_size.y * 0.020)), Color("8cecff"))

	var coin_rect := home_coin_rect(viewport_size)
	var gem_rect := home_gems_rect(viewport_size)
	for currency_rect in [coin_rect, gem_rect]:
		draw_style_box(make_box(Color("071c43"), 15.0 * unit), currency_rect.grow(3.0 * unit))
		draw_style_box(make_box(Color(0.035, 0.10, 0.22, 0.96), 13.0 * unit), currency_rect)
	draw_circle(coin_rect.position + Vector2(25.0, 27.0) * unit, 15.0 * unit, Color("ffc83d"))
	draw_circle(coin_rect.position + Vector2(25.0, 27.0) * unit, 9.0 * unit, Color("e9971b"), false, 3.0 * unit, true)
	draw_string(ui_font, coin_rect.position + Vector2(48.0, 35.0) * unit, str(player_coins), HORIZONTAL_ALIGNMENT_LEFT, coin_rect.size.x - 54.0 * unit, int(19.0 * unit), Color.WHITE)
	var gem_center := gem_rect.position + Vector2(24.0, 27.0) * unit
	draw_colored_polygon(PackedVector2Array([gem_center + Vector2(0.0, -15.0) * unit, gem_center + Vector2(13.0, -3.0) * unit, gem_center + Vector2(8.0, 14.0) * unit, gem_center + Vector2(-8.0, 14.0) * unit, gem_center + Vector2(-13.0, -3.0) * unit]), Color("62eaff"))
	draw_string(ui_font, gem_rect.position + Vector2(47.0, 35.0) * unit, str(player_gems), HORIZONTAL_ALIGNMENT_LEFT, gem_rect.size.x - 52.0 * unit, int(19.0 * unit), Color.WHITE)
	var settings := home_settings_rect(viewport_size)
	draw_gate_panel(settings, Color("58dcff"), unit, 0.95)
	draw_string(ui_font, settings.position + Vector2(0.0, 31.0) * unit, "HE" if ui_language == "he" else "EN", HORIZONTAL_ALIGNMENT_CENTER, settings.size.x, int(14.0 * unit), Color.WHITE)

	var mode_labels := ["זירה תחרותית", "קרב עם חבר", "קרב מהיר"] if ui_language == "he" else ["COMPETITIVE", "PLAY A FRIEND", "QUICK BATTLE"]
	var mode_colors := [Color("f0a52a"), Color("a64eff"), Color("25bff2")]
	for i in 3:
		var button := home_mode_rect(i, viewport_size)
		var plaque_w := button.size.x * (0.70 if i != 2 else 0.82)
		var plaque := Rect2(Vector2(button.get_center().x - plaque_w * 0.5, button.end.y - 72.0 * unit), Vector2(plaque_w, 58.0 * unit))
		draw_gate_panel(plaque, mode_colors[i], unit, 0.92)
		draw_string(ui_font, plaque.position + Vector2(0.0, 39.0) * unit, mode_labels[i], HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x, int((19.0 if i != 2 else 24.0) * unit), Color.WHITE)

	var nav_labels := ["דמויות", "ליגות", "חנות", "פרסים"] if ui_language == "he" else ["CHARACTERS", "LEAGUES", "SHOP", "REWARDS"]
	var nav_panel := Rect2(Vector2(viewport_size.x * 0.225, viewport_size.y * 0.855), Vector2(viewport_size.x * 0.55, viewport_size.y * 0.14))
	draw_style_box(make_box(Color(0.02, 0.075, 0.17, 0.96), 28.0 * unit), nav_panel)
	draw_rect(Rect2(nav_panel.position, Vector2(nav_panel.size.x, 3.0 * unit)), Color("58dcff"))
	for i in 4:
		var nav := home_nav_rect(i, viewport_size)
		if i > 0:
			draw_line(Vector2(nav.position.x, nav.position.y + 18.0 * unit), Vector2(nav.position.x, nav.end.y - 14.0 * unit), Color("39709a"), 2.0 * unit)
		draw_battle_home_nav_icon(i, nav.position + Vector2(nav.size.x * 0.5, 32.0 * unit), unit)
		draw_string(ui_font, nav.position + Vector2(0.0, 72.0) * unit, nav_labels[i], HORIZONTAL_ALIGNMENT_CENTER, nav.size.x, int(14.0 * unit), Color.WHITE)
	draw_home_friend_profile(viewport_size)
	draw_tutorial_overlay(viewport_size)

func draw_battle_home_nav_icon(kind: int, center: Vector2, unit: float) -> void:
	var color := Color("8cecff")
	if kind == 0:
		for offset in [-10.0, 10.0]:
			draw_circle(center + Vector2(offset, -5.0) * unit, 6.0 * unit, color)
			draw_arc(center + Vector2(offset, 9.0) * unit, 10.0 * unit, PI, TAU, 14, color, 4.0 * unit, true)
	elif kind == 1:
		var cup := Rect2(center + Vector2(-12.0, -11.0) * unit, Vector2(24.0, 17.0) * unit)
		draw_rect(cup, color, false, 4.0 * unit)
		draw_arc(center + Vector2(-13.0, -3.0) * unit, 8.0 * unit, PI * 0.5, PI * 1.5, 12, color, 3.0 * unit, true)
		draw_arc(center + Vector2(13.0, -3.0) * unit, 8.0 * unit, -PI * 0.5, PI * 0.5, 12, color, 3.0 * unit, true)
		draw_line(center + Vector2(0.0, 6.0) * unit, center + Vector2(0.0, 15.0) * unit, color, 4.0 * unit)
		draw_line(center + Vector2(-9.0, 15.0) * unit, center + Vector2(9.0, 15.0) * unit, color, 4.0 * unit)
	elif kind == 2:
		var basket := Rect2(center + Vector2(-14.0, -5.0) * unit, Vector2(28.0, 18.0) * unit)
		draw_rect(basket, color, false, 4.0 * unit)
		draw_line(center + Vector2(-18.0, -11.0) * unit, center + Vector2(-13.0, -5.0) * unit, color, 4.0 * unit)
		for offset in [-8.0, 8.0]:
			draw_circle(center + Vector2(offset, 18.0) * unit, 3.5 * unit, color)
	else:
		var gift := Rect2(center + Vector2(-13.0, -7.0) * unit, Vector2(26.0, 21.0) * unit)
		draw_rect(gift, color, false, 4.0 * unit)
		draw_line(center + Vector2(0.0, -7.0) * unit, center + Vector2(0.0, 14.0) * unit, color, 3.0 * unit)
		draw_line(center + Vector2(-13.0, 0.0) * unit, center + Vector2(13.0, 0.0) * unit, color, 3.0 * unit)

func league_rewards_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(730.0, 630.0) * unit, Vector2(390.0, 60.0) * unit)

func draw_league_badge(center: Vector2, tier: int, radius: float, active: bool, unit: float) -> void:
	var color: Color = league_color(tier)
	if active:
		draw_circle(center, radius * 1.28, Color(color.r, color.g, color.b, 0.20))
		draw_circle(center, radius * 1.10, Color("ffe25d"))
	draw_circle(center, radius, color)
	draw_circle(center, radius * 0.76, Color(0.03, 0.10, 0.22, 0.94))
	for i in 5:
		var angle := -PI * 0.5 + float(i) * TAU / 5.0
		draw_circle(center + Vector2(cos(angle), sin(angle)) * radius * 0.31, radius * 0.12, color.lightened(0.28))
	draw_circle(center + Vector2(0.0, radius * 0.12), radius * 0.25, color.lightened(0.18))
	if tier >= 3:
		for side in [-1.0, 1.0]:
			draw_colored_polygon(PackedVector2Array([center + Vector2(side * radius * 0.72, -radius * 0.25), center + Vector2(side * radius * 1.15, -radius * 0.55), center + Vector2(side * radius * 0.92, radius * 0.30)]), Color("f2b633"))
	if tier == 4:
		draw_colored_polygon(PackedVector2Array([center + Vector2(-radius * 0.48, -radius * 0.88), center + Vector2(-radius * 0.18, -radius * 1.20), center, center + Vector2(radius * 0.18, -radius * 1.20), center + Vector2(radius * 0.48, -radius * 0.88)]), Color("ffd85a"))

func draw_battle_gates_league_screen(viewport_size: Vector2) -> void:
	# The old leagues artwork contains its previous panels baked into the image.
	# Use the clean floating-islands scene so only the new live UI is visible.
	draw_screen_background(battle_background_texture, viewport_size, 0.12)
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	draw_frontend_header(viewport_size, "ליגות ודירוג" if ui_language == "he" else "LEAGUES & RANKING", "הדרך שלכם לפסגה" if ui_language == "he" else "YOUR ROAD TO THE TOP")
	var hero_rect := Rect2(Vector2(16.0, 126.0) * unit, Vector2(430.0, 430.0) * unit)
	if player_animal < character_ship_textures.size() and character_ship_textures[player_animal] != null:
		draw_texture_rect(character_ship_textures[player_animal], hero_rect, false)
		if player_animal < character_ship_light_masks.size() and character_ship_light_masks[player_animal] != null:
			draw_texture_rect(character_ship_light_masks[player_animal], hero_rect, false, RING_COLORS[player_ring_color].lightened(0.12))
	var platform := Vector2(230.0, 555.0) * unit
	draw_set_transform(platform, 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, 160.0 * unit, Color(0.02, 0.10, 0.22, 0.90))
	draw_arc(Vector2.ZERO, 154.0 * unit, 0.0, TAU, 72, Color("58dcff"), 7.0 * unit, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var league_plaque := Rect2(Vector2(70.0, 570.0) * unit, Vector2(320.0, 100.0) * unit)
	draw_gate_panel(league_plaque, league_color(player_league_tier), unit, 0.95)
	draw_league_badge(league_plaque.position + Vector2(55.0, 50.0) * unit, player_league_tier, 30.0 * unit, true, unit)
	draw_string(ui_font, league_plaque.position + Vector2(92.0, 45.0) * unit, league_name(player_league_tier), HORIZONTAL_ALIGNMENT_CENTER, league_plaque.size.x - 112.0 * unit, int(24.0 * unit), Color.WHITE)
	draw_string(ui_font, league_plaque.position + Vector2(92.0, 73.0) * unit, str(player_rating) + " " + ui_text("rating_label"), HORIZONTAL_ALIGNMENT_CENTER, league_plaque.size.x - 112.0 * unit, int(14.0 * unit), Color("ffe25d"))

	var panel := Rect2(Vector2(450.0, 112.0) * unit, Vector2(790.0, 570.0) * unit)
	draw_gate_panel(panel, Color("58dcff"), unit, 0.95)
	var visible_tier: int = mini(player_league_tier, 4)
	var path_y := panel.position.y + 92.0 * unit
	draw_line(Vector2(panel.position.x + 74.0 * unit, path_y), Vector2(panel.end.x - 74.0 * unit, path_y), Color("48d7ff"), 5.0 * unit, true)
	for i in 5:
		var badge_center := Vector2(panel.position.x + (80.0 + float(i) * 157.0) * unit, path_y)
		draw_league_badge(badge_center, i, (39.0 if i == visible_tier else 30.0) * unit, i == visible_tier, unit)
		draw_string(ui_font, badge_center + Vector2(-65.0, 66.0) * unit, league_name(i), HORIZONTAL_ALIGNMENT_CENTER, 130.0 * unit, int(14.0 * unit), Color("ffe25d") if i == visible_tier else Color.WHITE)
	var current_floor: int = LEAGUE_RATING_THRESHOLDS[clampi(player_league_tier, 0, LEAGUE_RATING_THRESHOLDS.size() - 1)]
	var next_target: int = LEAGUE_RATING_THRESHOLDS[mini(player_league_tier + 1, LEAGUE_RATING_THRESHOLDS.size() - 1)]
	var progress: float = 1.0 if player_league_tier >= 4 else clampf(float(player_rating - current_floor) / float(maxi(1, next_target - current_floor)), 0.0, 1.0)
	var progress_rect := Rect2(panel.position + Vector2(112.0, 175.0) * unit, Vector2(566.0, 20.0) * unit)
	draw_style_box(make_box(Color("10294e"), 10.0 * unit), progress_rect.grow(4.0 * unit))
	draw_style_box(make_box(Color("ffd23f"), 8.0 * unit), Rect2(progress_rect.position, Vector2(maxf(12.0 * unit, progress_rect.size.x * progress), progress_rect.size.y)))
	draw_string(ui_font, panel.position + Vector2(0.0, 215.0) * unit, str(player_rating) + " / " + str(next_target), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(15.0 * unit), Color("d7f6ff"))
	var entries := global_leaderboard.duplicate()
	if entries.is_empty():
		entries = [{"rank": 1, "name": profile_name, "rating": player_rating, "publicId": firebase_public_id}]
	var count := mini(5, entries.size())
	for i in count:
		var entry: Dictionary = entries[i]
		var row := Rect2(panel.position + Vector2(42.0, 240.0 + float(i) * 59.0) * unit, Vector2(706.0, 50.0) * unit)
		var is_me := str(entry.get("publicId", "")) == firebase_public_id
		draw_style_box(make_box(Color(0.46, 0.28, 0.06, 0.94) if is_me else Color(0.015, 0.07, 0.17, 0.88), 13.0 * unit), row)
		if is_me:
			draw_rect(row, Color("ffe25d"), false, 3.0 * unit)
		var rank := int(entry.get("rank", i + 1))
		draw_circle(row.position + Vector2(30.0, 25.0) * unit, 19.0 * unit, Color("f5bf35") if rank <= 3 else Color("29486b"))
		draw_string(ui_font, row.position + Vector2(12.0, 32.0) * unit, str(rank), HORIZONTAL_ALIGNMENT_CENTER, 36.0 * unit, int(16.0 * unit), Color("173249") if rank <= 3 else Color.WHITE)
		var avatar_index := clampi(int(entry.get("animal", entry.get("animalIndex", i % ANIMAL_NAMES.size()))), 0, ANIMAL_NAMES.size() - 1)
		if avatar_index < character_portrait_textures.size() and character_portrait_textures[avatar_index] != null:
			draw_texture_rect(character_portrait_textures[avatar_index], Rect2(row.position + Vector2(58.0, 5.0) * unit, Vector2(40.0, 40.0) * unit), false)
		draw_string(ui_font, row.position + Vector2(110.0, 32.0) * unit, str(entry.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, 350.0 * unit, int(17.0 * unit), Color("ffe25d") if is_me else Color.WHITE)
		draw_string(ui_font, row.position + Vector2(490.0, 32.0) * unit, str(entry.get("rating", 0)), HORIZONTAL_ALIGNMENT_CENTER, 105.0 * unit, int(17.0 * unit), Color("8cecff"))
		draw_circle(row.position + Vector2(626.0, 25.0) * unit, 10.0 * unit, Color("ffc83d"))
		draw_string(ui_font, row.position + Vector2(644.0, 31.0) * unit, str(maxi(50, 250 - i * 40)), HORIZONTAL_ALIGNMENT_LEFT, 55.0 * unit, int(14.0 * unit), Color("ffe25d"))
	var rewards := league_rewards_rect(viewport_size)
	draw_style_box(make_box(Color("70420b"), 17.0 * unit), rewards.grow(5.0 * unit))
	draw_style_box(make_box(Color("f0a51e"), 14.0 * unit), rewards)
	draw_string(ui_font, rewards.position + Vector2(0.0, 39.0 * unit), "צפייה בפרסי הליגה" if ui_language == "he" else "VIEW LEAGUE REWARDS", HORIZONTAL_ALIGNMENT_CENTER, rewards.size.x, int(21.0 * unit), Color.WHITE)

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
	draw_gate_panel(panel, Color("f6d365"), 1.0, 0.98)
	draw_string(ui_font, panel.position + Vector2(0.0, 28.0), ui_text("leaderboard_title"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 16, Color("ffe25d"))
	var entries := global_leaderboard.duplicate()
	if entries.is_empty():
		entries = [{"rank": 1, "name": profile_name, "rating": player_rating, "publicId": firebase_public_id}]
	var count := mini(4, entries.size())
	for i in count:
		var entry: Dictionary = entries[i]
		var row := Rect2(panel.position + Vector2(10.0, 38.0 + i * 48.0), Vector2(panel.size.x - 20.0, 42.0))
		var is_me := str(entry.get("publicId", "")) == firebase_public_id
		draw_style_box(make_box(Color("7256d8") if is_me else Color(0.04, 0.12, 0.24, 0.96), 13.0), row)
		draw_string(ui_font, row.position + Vector2(8.0, 27.0), "#" + str(entry.get("rank", i + 1)), HORIZONTAL_ALIGNMENT_CENTER, 28.0, 13, Color("ffe25d"))
		draw_string(ui_font, row.position + Vector2(38.0, 20.0), str(entry.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 90.0, 12, Color.WHITE)
		draw_string(ui_font, row.position + Vector2(38.0, 35.0), str(entry.get("rating", 0)) + " " + ui_text("rating_label"), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 90.0, 9, Color("a9cde2"))

func draw_frontend_header(viewport_size: Vector2, title: String, subtitle: String) -> void:
	var back := frontend_back_rect(viewport_size)
	draw_style_box(make_box(Color("07152f"), 15.0), back.grow(4.0))
	draw_style_box(make_box(Color("244d78"), 13.0), back)
	draw_line(back.position + Vector2(10.0, back.size.y - 3.0), back.end - Vector2(10.0, 3.0), Color("58dcff"), 2.0, true)
	draw_string(ui_font, back.position + Vector2(0.0, 31.0), ui_text("back"), HORIZONTAL_ALIGNMENT_CENTER, back.size.x, 16, Color.WHITE)
	var title_plaque := Rect2(viewport_size.x * 0.28, 8.0, viewport_size.x * 0.44, 80.0)
	draw_gate_panel(title_plaque, Color("58dcff"), 1.0, 0.94)
	var crest := Vector2(viewport_size.x * 0.50, title_plaque.position.y + 5.0)
	draw_colored_polygon(PackedVector2Array([crest + Vector2(0.0, -8.0), crest + Vector2(10.0, 0.0), crest + Vector2(0.0, 12.0), crest + Vector2(-10.0, 0.0)]), Color("8cecff"))
	draw_string(ui_font, Vector2(0.0, 46.0), title, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 28, Color.WHITE)
	draw_string(ui_font, Vector2(0.0, 78.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 14, Color(0.78, 0.91, 0.98))

func draw_profile_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	# Choosing an animal also chooses its unique hovercraft. There is no separate
	# hovercraft/color picker in the new character system.
	var back := frontend_back_rect(viewport_size)
	draw_style_box(make_box(Color("07152f"), 15.0 * unit), back.grow(5.0 * unit))
	draw_style_box(make_box(Color("173d72"), 13.0 * unit), back)
	draw_string(ui_font, back.position + Vector2(0.0, 32.0) * unit, "‹  " + ui_text("back"), HORIZONTAL_ALIGNMENT_CENTER, back.size.x, int(17.0 * unit), Color.WHITE)

	var board := Rect2(Vector2(455.0, 92.0) * unit, Vector2(790.0, 370.0) * unit)
	draw_gate_panel(board, Color("58dcff"), unit, 0.82)
	draw_string(ui_font, board.position + Vector2(0.0, 58.0) * unit, ui_text("choose_character"), HORIZONTAL_ALIGNMENT_CENTER, board.size.x, int(32.0 * unit), Color.WHITE)
	draw_string(ui_font, board.position + Vector2(0.0, 88.0) * unit, ui_text("choose_character_sub"), HORIZONTAL_ALIGNMENT_CENTER, board.size.x, int(14.0 * unit), Color("8cecff"))
	draw_string(ui_font, board.position + Vector2(0.0, 132.0) * unit, ui_text("choose_animal"), HORIZONTAL_ALIGNMENT_CENTER, board.size.x, int(21.0 * unit), Color.WHITE)
	draw_line(board.position + Vector2(36.0, 145.0) * unit, board.position + Vector2(board.size.x - 36.0 * unit, 145.0 * unit), Color("32bfff", 0.62), 2.0 * unit, true)

	# Each hero is a complete, production-quality pilot asset.  The animal's
	# torso, hands and cockpit contact are baked together to match the concept.
	var hover: float = sin(menu_elapsed * 1.7) * 5.0 * unit
	var ship_hero: Texture2D = character_ship_textures[player_animal] if player_animal < character_ship_textures.size() else null
	if ship_hero != null:
		var hero_rect := Rect2(Vector2(25.0, 135.0) * unit + Vector2(0.0, hover), Vector2(440.0, 440.0) * unit)
		draw_texture_rect(ship_hero, hero_rect, false)
		if player_animal < character_ship_light_masks.size():
			var light_mask: Texture2D = character_ship_light_masks[player_animal]
			if light_mask != null:
				var energy_color: Color = RING_COLORS[clampi(player_ring_color, 0, RING_COLORS.size() - 1)].lightened(0.12)
				draw_texture_rect(light_mask, hero_rect, false, energy_color)
	draw_string(ui_font, Vector2(70.0, 635.0) * unit, ui_animal_name(player_animal), HORIZONTAL_ALIGNMENT_CENTER, 360.0 * unit, int(23.0 * unit), Color.WHITE)

	for i in ANIMAL_NAMES.size():
		var card := character_card_rect(i, viewport_size)
		var selected := i == player_animal
		var center := card.get_center()
		draw_circle(center, 48.0 * unit, Color("ffe25d") if selected else Color("6e8ca7"))
		draw_circle(center, 42.0 * unit, Color("08234b"))
		var portrait: Texture2D = character_ship_textures[i] if i < character_ship_textures.size() else animal_textures[i]
		if portrait != null:
			draw_texture_rect(portrait, Rect2(center - Vector2(41.0, 41.0) * unit, Vector2(82.0, 82.0) * unit), false)
		draw_collection_lock_overlay(card, i, false, unit)
		if selected:
			draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, -58.0) * unit, center + Vector2(9.0, -47.0) * unit, center + Vector2(0.0, -38.0) * unit, center + Vector2(-9.0, -47.0) * unit]), Color("58dcff"))

	draw_string(ui_font, board.position + Vector2(0.0, 328.0) * unit, "החללית הייחודית נבחרת אוטומטית עם החיה" if ui_language == "he" else "EACH CHARACTER INCLUDES THEIR UNIQUE HOVERCRAFT", HORIZONTAL_ALIGNMENT_CENTER, board.size.x, int(17.0 * unit), Color("8cecff"))

	var save := character_save_rect(viewport_size)
	draw_style_box(make_box(Color("70420b"), 22.0 * unit), save.grow(7.0 * unit))
	draw_style_box(make_box(Color("f0a51e"), 18.0 * unit), save)
	draw_line(save.position + Vector2(28.0, 8.0) * unit, Vector2(save.end.x - 28.0 * unit, save.position.y + 8.0 * unit), Color("fff1a8"), 3.0 * unit, true)
	draw_string(ui_font, save.position + Vector2(0.0, 50.0) * unit, "שמירת הבחירה" if ui_language == "he" else "SAVE SELECTION", HORIZONTAL_ALIGNMENT_CENTER, save.size.x, int(25.0 * unit), Color.WHITE)

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
		SHOP_PAGE_BOARDS:
			return "שולחנות" if ui_language == "he" else "TABLES"
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
		SHOP_PAGE_BOARDS:
			return "בחרו את עולם המשחק שלכם" if ui_language == "he" else "CHOOSE YOUR GAME WORLD"
		SHOP_PAGE_EFFECTS:
			return ui_text("collection_info")
		_:
			return ui_text("shop_unlocks_sub")

func shop_category_rect(index: int, viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var gap := 10.0 * unit
	var card_w := 174.0 * unit
	var total_w := card_w * 3.0 + gap * 2.0
	return Rect2(Vector2((viewport_size.x - total_w) * 0.5 + float(index) * (card_w + gap), 92.0 * unit), Vector2(card_w, 54.0 * unit))

func shop_action_rect(viewport_size: Vector2) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	return Rect2(Vector2(70.0, 610.0) * unit, Vector2(326.0, 66.0) * unit)

func shop_detail_columns(item_count: int) -> int:
	return 4 if item_count > 6 else 3

func shop_detail_grid_rect(index: int, viewport_size: Vector2, item_count: int) -> Rect2:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	var columns := shop_detail_columns(item_count)
	var rows := int(ceil(float(item_count) / float(columns)))
	var gap := 16.0 * unit
	var top := 190.0 * unit
	var bottom_margin := 28.0 * unit
	var available_h := viewport_size.y - top - bottom_margin
	var available_w := viewport_size.x - 510.0 * unit
	var card_w := (available_w - gap * float(columns - 1)) / float(columns)
	var card_h := minf(360.0 * unit, (available_h - gap * float(rows - 1)) / float(rows))
	var col := index % columns
	var row := int(index / columns)
	var items_in_row := mini(columns, item_count - row * columns)
	var row_width := card_w * float(items_in_row) + gap * float(items_in_row - 1)
	var start_x := 470.0 * unit + (available_w - row_width) * 0.5
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
	var center := art_rect.get_center()
	var radius := minf(art_rect.size.x, art_rect.size.y) * 0.36
	var light_color: Color = RING_COLORS[clampi(index, 0, RING_COLORS.size() - 1)]
	draw_set_transform(center, 0.0, Vector2(1.0, 0.52))
	draw_circle(Vector2(0.0, radius * 0.68), radius * 0.74, Color(light_color.r, light_color.g, light_color.b, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if hero_saucer_texture != null:
		draw_texture_fit(hero_saucer_texture, art_rect.grow(-4.0))
	draw_set_transform(center + Vector2(0.0, radius * 0.45), 0.0, Vector2(1.0, 0.34))
	draw_arc(Vector2.ZERO, radius * 0.85, 0.0, TAU, 40, light_color.lightened(0.15), radius * 0.11, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_shop_detail_card(index: int, rect: Rect2, is_ring: bool, unit: float) -> void:
	var unlocked := is_ring_unlocked(index) if is_ring else is_animal_unlocked(index)
	var selected := (shop_preview_ring == index) if is_ring else (shop_preview_animal == index)
	var accent := Color("467ce8") if is_ring else Color("24b889")
	draw_gate_panel(rect, Color("ffe25d") if selected else accent, unit, 0.96)
	var art_rect := Rect2(rect.position + Vector2(10.0 * unit, 10.0 * unit), Vector2(rect.size.x - 20.0 * unit, rect.size.y - 92.0 * unit))
	draw_style_box(make_box(Color(0.01, 0.04, 0.09, 0.72), 12.0 * unit), art_rect)
	if is_ring:
		draw_shop_ring_preview(art_rect.grow(-8.0 * unit), index)
	else:
		if index < character_ship_textures.size() and character_ship_textures[index] != null:
			draw_texture_fit(character_ship_textures[index], art_rect.grow(-6.0 * unit))
	if not unlocked:
		draw_rect(art_rect, Color(0.01, 0.03, 0.08, 0.62))
		var lock_center := art_rect.get_center()
		draw_arc(lock_center + Vector2(0.0, -9.0 * unit), 14.0 * unit, PI, TAU, 24, Color("ffe25d"), 6.0 * unit, true)
		draw_style_box(make_box(Color("f0a51e"), 6.0 * unit), Rect2(lock_center - Vector2(20.0, 7.0) * unit, Vector2(40.0, 34.0) * unit))
		draw_circle(lock_center + Vector2(0.0, 7.0 * unit), 4.0 * unit, Color("173249"))
	if selected:
		draw_style_box(make_box(Color("ffe25d"), 10.0 * unit), Rect2(rect.position + Vector2(8.0 * unit, 8.0 * unit), Vector2(rect.size.x - 16.0 * unit, 22.0 * unit)))
		draw_string(ui_font, rect.position + Vector2(0.0, 24.0 * unit), "תצוגה" if ui_language == "he" else "PREVIEW", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(10.0 * unit), Color("173249"))
	var label := ui_ring_name(index) if is_ring else ui_animal_name(index)
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y - 58.0 * unit), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(14.0 * unit), Color.WHITE)
	var price_text := shop_detail_price_label(index, is_ring)
	draw_string(ui_font, rect.position + Vector2(0.0, rect.size.y - 30.0 * unit), price_text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, int(13.0 * unit), Color("ffe25d"))

func draw_shop_hub(viewport_size: Vector2, unit: float) -> void:
	var categories := [ui_text("characters"), "שולחנות" if ui_language == "he" else "TABLES", ui_text("effects")]
	var category_colors := [Color("24b889"), Color("f0a51e"), Color("9a58dc")]
	for i in 3:
		var card := shop_category_rect(i, viewport_size)
		var accent: Color = category_colors[i]
		var active: bool = shop_page == [SHOP_PAGE_ANIMALS, SHOP_PAGE_BOARDS, SHOP_PAGE_EFFECTS][i]
		draw_gate_panel(card, Color("ffe25d") if active else accent, unit, 0.92)
		draw_string(ui_font, card.position + Vector2(0.0, 35.0 * unit), categories[i], HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(18.0 * unit), Color("ffe25d") if active else Color.WHITE)

func draw_shop_feature(viewport_size: Vector2, unit: float) -> void:
	var panel := Rect2(32.0 * unit, 166.0 * unit, 402.0 * unit, viewport_size.y - 194.0 * unit)
	draw_gate_panel(panel, Color("58dcff"), unit, 0.80)
	var art := Rect2(panel.position + Vector2(18.0, 18.0) * unit, Vector2(panel.size.x - 36.0 * unit, panel.size.y - 122.0 * unit))
	if shop_page == SHOP_PAGE_ANIMALS:
		if shop_preview_animal < character_ship_textures.size():
			draw_texture_fit(character_ship_textures[shop_preview_animal], art)
		if shop_preview_animal < character_ship_light_masks.size() and character_ship_light_masks[shop_preview_animal] != null:
			var mask: Texture2D = character_ship_light_masks[shop_preview_animal]
			var mask_size := mask.get_size()
			var mask_scale := minf(art.size.x / mask_size.x, art.size.y / mask_size.y)
			var draw_size := mask_size * mask_scale
			draw_texture_rect(mask, Rect2(art.position + (art.size - draw_size) * 0.5, draw_size), false, RING_COLORS[player_ring_color])
	elif shop_page == SHOP_PAGE_RINGS:
		draw_shop_ring_preview(art.grow(-24.0 * unit), shop_preview_ring)
	elif shop_page == SHOP_PAGE_BOARDS:
		draw_shop_board_preview(shop_preview_board, art.grow(-16.0 * unit), unit)
	else:
		draw_shop_category_icon(2, art.get_center(), 110.0 * unit, unit)
	var title := ui_animal_name(shop_preview_animal)
	if shop_page == SHOP_PAGE_RINGS:
		title = ui_ring_name(shop_preview_ring)
	elif shop_page == SHOP_PAGE_BOARDS:
		title = board_theme_name(shop_preview_board)
	elif shop_page == SHOP_PAGE_EFFECTS:
		title = ui_text("coming_soon")
	var title_box := Rect2(panel.position + Vector2(28.0 * unit, panel.size.y - 142.0 * unit), Vector2(panel.size.x - 56.0 * unit, 46.0 * unit))
	draw_style_box(make_box(Color(0.02, 0.07, 0.14, 0.96), 14.0 * unit), title_box)
	draw_string(ui_font, title_box.position + Vector2(0.0, 34.0 * unit), title, HORIZONTAL_ALIGNMENT_CENTER, title_box.size.x, int(20.0 * unit), Color.WHITE)
	if shop_page != SHOP_PAGE_EFFECTS:
		var action := shop_action_rect(viewport_size)
		var action_text := ""
		if shop_page == SHOP_PAGE_ANIMALS:
			if is_animal_unlocked(shop_preview_animal):
				action_text = ui_text("equipped_item") if shop_preview_animal == player_animal else ("בחר דמות" if ui_language == "he" else "SELECT CHARACTER")
			else:
				action_text = ("קנה ב־%d מטבעות" if ui_language == "he" else "BUY FOR %d COINS") % animal_unlock_price(shop_preview_animal)
		elif shop_page == SHOP_PAGE_RINGS:
			if is_ring_unlocked(shop_preview_ring):
				action_text = ui_text("equipped_item") if shop_preview_ring == player_ring_color else ("בחר צבע תאורה" if ui_language == "he" else "SELECT LIGHT COLOR")
			else:
				action_text = ("קנה ב־%d מטבעות" if ui_language == "he" else "BUY FOR %d COINS") % ring_unlock_price(shop_preview_ring)
		else:
			action_text = ui_text("equipped_item") if shop_preview_board == selected_board_theme else ("בחר שולחן" if ui_language == "he" else "EQUIP TABLE")
		draw_style_box(make_box(Color("70420b"), 18.0 * unit), action.grow(5.0 * unit))
		draw_style_box(make_box(Color("f0a51e"), 15.0 * unit), action)
		draw_string(ui_font, action.position + Vector2(0.0, 42.0 * unit), action_text, HORIZONTAL_ALIGNMENT_CENTER, action.size.x, int(21.0 * unit), Color.WHITE)

func draw_shop_detail_page(viewport_size: Vector2, item_count: int, is_ring: bool, unit: float) -> void:
	var panel := Rect2(450.0 * unit, 166.0 * unit, viewport_size.x - 474.0 * unit, viewport_size.y - 194.0 * unit)
	draw_gate_panel(panel, Color("58dcff"), unit, 0.88)
	var collected := shop_unlocked_count(is_ring)
	var total := RING_COLOR_NAMES.size() if is_ring else ANIMAL_NAMES.size()
	draw_string(ui_font, panel.position + Vector2(0.0, 28.0 * unit), ui_text("shop_collected") % [collected, total], HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(15.0 * unit), Color("ffe25d"))
	for i in item_count:
		draw_shop_detail_card(i, shop_detail_grid_rect(i, viewport_size, item_count), is_ring, unit)

func draw_shop_animals_page(viewport_size: Vector2, unit: float) -> void:
	draw_shop_detail_page(viewport_size, ANIMAL_NAMES.size(), false, unit)

func draw_shop_rings_page(viewport_size: Vector2, unit: float) -> void:
	draw_shop_detail_page(viewport_size, RING_COLOR_NAMES.size(), true, unit)

func draw_shop_boards_page(viewport_size: Vector2, unit: float) -> void:
	var panel := Rect2(450.0 * unit, 166.0 * unit, viewport_size.x - 474.0 * unit, viewport_size.y - 194.0 * unit)
	draw_gate_panel(panel, Color("58dcff"), unit, 0.88)
	for i in BOARD_THEME_COUNT:
		var card := shop_detail_grid_rect(i, viewport_size, BOARD_THEME_COUNT)
		draw_gate_panel(card, Color("ffe25d") if i == shop_preview_board else board_theme_accent(i), unit, 0.96)
		draw_shop_board_preview(i, card.grow(-12.0 * unit), unit)
		draw_string(ui_font, card.position + Vector2(0.0, card.size.y - 15.0 * unit), board_theme_name(i), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, int(13.0 * unit), Color.WHITE)

func draw_shop_effects_page(viewport_size: Vector2, unit: float) -> void:
	var panel := Rect2(450.0 * unit, 166.0 * unit, viewport_size.x - 474.0 * unit, viewport_size.y - 194.0 * unit)
	draw_style_box(make_box(Color(0.02, 0.06, 0.12, 0.94), 24.0 * unit), panel)
	draw_shop_category_icon(2, panel.position + Vector2(panel.size.x * 0.5, 120.0 * unit), 72.0 * unit, unit)
	draw_string(ui_font, panel.position + Vector2(0.0, 210.0) * unit, ui_text("coming_soon"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, int(28.0 * unit), Color("ffe25d"))
	draw_string(ui_font, panel.position + Vector2(40.0 * unit, 260.0) * unit, ui_text("shop_effects_empty"), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 80.0 * unit, int(15.0 * unit), Color("d7f6ff"))

func draw_shop_screen(viewport_size: Vector2) -> void:
	var unit := minf(viewport_size.x / 1280.0, viewport_size.y / 720.0)
	if shop_page == SHOP_PAGE_HUB:
		shop_page = SHOP_PAGE_ANIMALS
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.01, 0.04, 0.09, 0.44))
	draw_frontend_header(viewport_size, shop_page_title(), shop_page_subtitle())
	draw_shop_coin_box(viewport_size, unit)
	draw_shop_hub(viewport_size, unit)
	draw_shop_feature(viewport_size, unit)
	match shop_page:
		SHOP_PAGE_ANIMALS:
			draw_shop_animals_page(viewport_size, unit)
		SHOP_PAGE_RINGS:
			draw_shop_rings_page(viewport_size, unit)
		SHOP_PAGE_BOARDS:
			draw_shop_boards_page(viewport_size, unit)
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
