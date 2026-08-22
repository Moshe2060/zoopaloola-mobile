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
- `{"type":"ready","ready":true}`
- `{"type":"shot","ballIndex":4,"pullX":-12.5,"pullY":8.0,"strength":18.0}`
- `{"type":"leave_room"}`

The server returns `joined`, `room_state`, `match_started`, `shot`, `turn`,
`opponent_left`, and structured `error` messages.

## Render

Create a new Blueprint in Render from the repository and select
`server/render.yaml`. The service works on the free plan; after deployment use
`wss://<service-name>.onrender.com/ws` in the game client.

Persistent accounts, inventory and match statistics will be added with
Supabase after the two-device room flow is verified.
