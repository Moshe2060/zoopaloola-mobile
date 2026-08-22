const http = require("node:http");
const crypto = require("node:crypto");
const { WebSocketServer, WebSocket } = require("ws");

const PORT = Number(process.env.PORT || 10000);
const rooms = new Map();
const clients = new Map();

function send(socket, message) {
  if (socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify(message));
  }
}

function roomCode() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  for (let attempt = 0; attempt < 100; attempt += 1) {
    let code = "";
    for (let i = 0; i < 6; i += 1) {
      code += alphabet[crypto.randomInt(alphabet.length)];
    }
    if (!rooms.has(code)) return code;
  }
  throw new Error("Could not allocate room code");
}

function publicPlayer(player) {
  return {
    id: player.id,
    slot: player.slot,
    name: player.name,
    animal: player.animal,
    ringColor: player.ringColor,
    level: player.level,
    wins: player.wins,
    losses: player.losses,
    ready: player.ready
  };
}

function roomState(room) {
  return {
    type: "room_state",
    roomCode: room.code,
    status: room.status,
    turn: room.turn,
    sequence: room.sequence,
    players: room.players.map(publicPlayer)
  };
}

function broadcast(room, message) {
  for (const player of room.players) send(player.socket, message);
}

function broadcastState(room) {
  broadcast(room, roomState(room));
}

function leaveRoom(socket) {
  const session = clients.get(socket);
  if (!session?.roomCode) return;
  const room = rooms.get(session.roomCode);
  session.roomCode = null;
  if (!room) return;
  room.players = room.players.filter((player) => player.socket !== socket);
  if (room.players.length === 0) {
    rooms.delete(room.code);
    return;
  }
  room.status = "waiting";
  room.turn = 0;
  room.players.forEach((player, index) => {
    player.slot = index;
    player.ready = false;
  });
  broadcast(room, { type: "opponent_left" });
  broadcastState(room);
}

function joinRoom(socket, room, payload) {
  leaveRoom(socket);
  if (room.players.length >= 2) {
    send(socket, { type: "error", code: "ROOM_FULL", message: "Room is full" });
    return;
  }
  const session = clients.get(socket);
  const player = {
    id: session.id,
    socket,
    slot: room.players.length,
    name: String(payload.name || `Player ${room.players.length + 1}`).slice(0, 24),
    animal: Math.max(0, Math.min(5, Number(payload.animal) || 0)),
    ringColor: Math.max(0, Math.min(5, Number(payload.ringColor) || 0)),
    level: Math.max(1, Math.min(999, Number(payload.level) || 1)),
    wins: Math.max(0, Math.min(999999, Number(payload.wins) || 0)),
    losses: Math.max(0, Math.min(999999, Number(payload.losses) || 0)),
    ready: false
  };
  room.players.push(player);
  session.roomCode = room.code;
  send(socket, { type: "joined", roomCode: room.code, playerId: player.id, slot: player.slot });
  broadcastState(room);
}

function handleMessage(socket, payload) {
  if (!payload || typeof payload.type !== "string") return;
  const session = clients.get(socket);

  if (payload.type === "create_room") {
    const code = roomCode();
    const room = { code, players: [], status: "waiting", turn: 0, sequence: 0, updatedAt: Date.now() };
    rooms.set(code, room);
    joinRoom(socket, room, payload);
    return;
  }

  if (payload.type === "join_room") {
    const code = String(payload.roomCode || "").trim().toUpperCase();
    const room = rooms.get(code);
    if (!room) {
      send(socket, { type: "error", code: "ROOM_NOT_FOUND", message: "Room not found" });
      return;
    }
    joinRoom(socket, room, payload);
    return;
  }

  const room = rooms.get(session.roomCode);
  const player = room?.players.find((item) => item.socket === socket);
  if (!room || !player) {
    send(socket, { type: "error", code: "NOT_IN_ROOM", message: "Join a room first" });
    return;
  }
  room.updatedAt = Date.now();

  if (payload.type === "update_profile") {
    if (room.status !== "waiting") return;
    player.animal = Math.max(0, Math.min(5, Number(payload.animal) || 0));
    player.ringColor = Math.max(0, Math.min(5, Number(payload.ringColor) || 0));
    broadcastState(room);
    return;
  }

  if (payload.type === "ready") {
    player.ready = Boolean(payload.ready);
    if (room.players.length === 2 && room.players.every((item) => item.ready)) {
      room.status = "playing";
      room.turn = 0;
      room.sequence = 0;
      for (const roomPlayer of room.players) {
        send(roomPlayer.socket, {
          type: "match_started",
          roomCode: room.code,
          turn: room.turn,
          slot: roomPlayer.slot
        });
      }
    }
    broadcastState(room);
    return;
  }

  if (payload.type === "shot") {
    if (room.status !== "playing" || player.slot !== room.turn) {
      send(socket, { type: "error", code: "NOT_YOUR_TURN", message: "Not your turn" });
      return;
    }
    room.sequence += 1;
    broadcast(room, {
      type: "shot",
      sequence: room.sequence,
      playerSlot: player.slot,
      ballIndex: Number(payload.ballIndex),
      pullX: Number(payload.pullX),
      pullY: Number(payload.pullY),
      strength: Number(payload.strength)
    });
    room.turn = 1 - room.turn;
    broadcast(room, { type: "turn", turn: room.turn, sequence: room.sequence });
    return;
  }

  if (payload.type === "chat") {
    if (room.status !== "playing") return;
    const message = String(payload.message || "").trim().slice(0, 80);
    if (!message) return;
    broadcast(room, {
      type: "chat",
      playerSlot: player.slot,
      name: player.name,
      message
    });
    return;
  }

  if (payload.type === "leave_room") leaveRoom(socket);
}

const server = http.createServer((request, response) => {
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Content-Type", "application/json; charset=utf-8");
  if (request.url === "/health") {
    response.writeHead(200);
    response.end(JSON.stringify({ ok: true, rooms: rooms.size, connections: clients.size }));
    return;
  }
  response.writeHead(200);
  response.end(JSON.stringify({ service: "zoopaloola-match-server", websocket: "/ws" }));
});

const wss = new WebSocketServer({ server, path: "/ws" });
wss.on("connection", (socket) => {
  const id = crypto.randomUUID();
  clients.set(socket, { id, roomCode: null, alive: true });
  send(socket, { type: "connected", playerId: id });

  socket.on("pong", () => {
    const session = clients.get(socket);
    if (session) session.alive = true;
  });
  socket.on("message", (buffer) => {
    try {
      handleMessage(socket, JSON.parse(buffer.toString("utf8")));
    } catch {
      send(socket, { type: "error", code: "BAD_MESSAGE", message: "Invalid JSON message" });
    }
  });
  socket.on("close", () => {
    leaveRoom(socket);
    clients.delete(socket);
  });
});

const heartbeat = setInterval(() => {
  for (const [socket, session] of clients.entries()) {
    if (!session.alive) {
      socket.terminate();
      continue;
    }
    session.alive = false;
    socket.ping();
  }
  const staleBefore = Date.now() - 2 * 60 * 60 * 1000;
  for (const [code, room] of rooms.entries()) {
    if (room.updatedAt < staleBefore) rooms.delete(code);
  }
}, 30000);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Zoopaloola match server listening on ${PORT}`);
});

function shutdown() {
  clearInterval(heartbeat);
  server.close(() => process.exit(0));
}
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
