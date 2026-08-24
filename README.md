# Zoopaloola

Godot 4 landscape remake of Zoopaloola for Android, iOS, and the web. This copy includes the playable table, home lobby, private friend matches, and now a working online arena queue.

Play the latest published web build: https://moshe2060.github.io/zoopaloola-mobile/

## לפלאפון

- **שחק עכשיו בדפדפן:** https://moshe2060.github.io/zoopaloola-mobile/
- **דף הורדה:** https://moshe2060.github.io/zoopaloola-mobile/download.html
- **הורדת APK:** https://moshe2060.github.io/zoopaloola-mobile/Zoopaloola.apk

## What you can play

- **Vs computer** — start immediately from the home screen.
- **Play a friend** — create or join a 6-character room on two devices.
- **Online arena** — pick Sakura / Bamboo / Volcano and tap Find Match. Two players searching the same arena are paired automatically.
- **Daily reward** — claim 80 coins once per day.
- Career stats (wins, losses, streak, XP) are saved on the device after each finished match.

The shop collection is still a placeholder.

## Run the match server locally

```bash
cd server
npm install
npm test
npm start
```

Health check: `http://localhost:10000/health`  
WebSocket: `ws://localhost:10000/ws`

The shipped client talks to `wss://zoopaloola-mobile.onrender.com/ws`. After you deploy this server, keep that URL or change `MATCH_SERVER_URL` in `mobile-v02.gd`.

## Build the game

The Godot project lives in `Zoopaloola-Godot-Mobile.zip`. GitHub Actions unzip it, overlay `mobile-v02.gd` and the remastered assets, then export:

- **Web** — workflow `Build and publish Web game` deploys GitHub Pages.
- **Android APK** — workflow `Build Android APK` uploads the `Zoopaloola-Android-APK` artifact.

To overlay assets locally after unzipping the Godot project:

```bash
unzip -q Zoopaloola-Godot-Mobile.zip
bash scripts/apply-godot-assets.sh
# Android fullscreen flag:
# bash scripts/apply-godot-assets.sh --android
```

Then open `zoopaloola_godot_mobile/` in Godot 4.4.
