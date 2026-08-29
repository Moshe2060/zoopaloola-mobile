# Zoopaloola match server

Minimal WebSocket prototype for two-device testing. Rooms are intentionally
kept in memory so the first deployment has no database dependency.

## Run locally

```bash
npm install
npm start
```

Health check: `http://localhost:10000/health`

WebSocket endpoint: `ws://localhost:10000/ws`

## Protocol

Client messages:

- `{"type":"create_room","name":"Player 1","animal":1,"ringColor":3}`
- `{"type":"join_room","roomCode":"ABC123","name":"Player 2","animal":0,"ringColor":2}`
- `{"type":"find_match","name":"Player 1","animal":1,"ringColor":3,"arena":0}`
- `{"type":"cancel_match"}`
- `{"type":"ready","ready":true}`
- `{"type":"shot","ballIndex":4,"pullX":-12.5,"pullY":8.0,"strength":18.0}`
- `{"type":"match_result","winnerSlot":0}`
- `{"type":"leave_room"}`
- `{"type":"register_presence","publicId":"ZP-ABCDEFGH","name":"Player","rating":1100}`
- `{"type":"invite_friend","targetPublicId":"ZP-FRIEND01","roomCode":"ABCD","fromName":"Host"}`
- `{"type":"lobby_chat","name":"Player","message":"Hello!"}`
- `{"type":"get_leaderboard"}`
- `{"type":"register_fcm_token","publicId":"ZP-ABCDEFGH","token":"<fcm-token>","platform":"web"}`

The server returns `joined`, `room_state`, `searching`, `search_cancelled`,
`match_started`, `shot`, `turn`, `match_over`, `opponent_left`, `friend_invite`,
`invite_sent`, `leaderboard`, `lobby_chat`, `fcm_registered`, and structured
`error` messages. `find_match` places a player in an in-memory arena queue and
starts a match as soon as a second player searches the same arena.

## Push notifications

Set `FCM_SERVER_KEY` on Render to deliver offline friend invites through Firebase
Cloud Messaging. Clients register tokens with `register_fcm_token`.

## Render

Create a new Blueprint in Render from the repository and select
`server/render.yaml`. The service works on the free plan; after deployment use
`wss://<service-name>.onrender.com/ws` in the game client.

Persistent accounts, inventory and match statistics will be added with
Supabase after the two-device room flow is verified.
