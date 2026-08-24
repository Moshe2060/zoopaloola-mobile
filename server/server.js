const http = require("node:http");
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const { WebSocketServer, WebSocket } = require("ws");

const PORT = Number(process.env.PORT || 10000);
const rooms = new Map();
const clients = new Map();
const queues = new Map();

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

function clampInt(value, min, max, fallback) {
  const number = Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.max(min, Math.min(max, Math.trunc(number)));
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
    source: room.source,
    arena: room.arena,
    players: room.players.map(publicPlayer)
  };
}

function broadcast(room, message) {
  for (const player of room.players) send(player.socket, message);
}

function broadcastState(room) {
  broadcast(room, roomState(room));
}

function leaveQueue(socket) {
  for (const [arena, waiting] of queues.entries()) {
    const next = waiting.filter((item) => item.socket !== socket);
    if (next.length > 0) queues.set(arena, next);
    else queues.delete(arena);
  }
}

function leaveRoom(socket) {
  const session = clients.get(socket);
  if (!session?.roomCode) return;
  const room = rooms.get(session.roomCode);
  session.roomCode = null;
  if (!room) return;
  const leaving = room.players.find((player) => player.socket === socket);
  room.players = room.players.filter((player) => player.socket !== socket);
  if (room.players.length === 0) {
    rooms.delete(room.code);
    return;
  }
  if (room.status === "playing" && leaving) {
    const winner = room.players[0];
    room.status = "finished";
    broadcast(room, {
      type: "match_over",
      winnerSlot: winner.slot,
      reason: "opponent_left",
      sequence: room.sequence
    });
  }
  room.status = room.status === "finished" ? "finished" : "waiting";
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
    return false;
  }
  const session = clients.get(socket);
  const player = {
    id: session.id,
    socket,
    slot: room.players.length,
    name: String(payload.name || `Player ${room.players.length + 1}`).slice(0, 24),
    animal: clampInt(payload.animal, 0, 5, 0),
    ringColor: clampInt(payload.ringColor, 0, 5, 0),
    level: clampInt(payload.level, 1, 999, 1),
    wins: clampInt(payload.wins, 0, 999999, 0),
    losses: clampInt(payload.losses, 0, 999999, 0),
    ready: false
  };
  room.players.push(player);
  session.roomCode = room.code;
  send(socket, {
    type: "joined",
    roomCode: room.code,
    playerId: player.id,
    slot: player.slot,
    source: room.source,
    arena: room.arena
  });
  broadcastState(room);
  return true;
}

function startMatch(room) {
  room.status = "playing";
  room.turn = 0;
  room.sequence = 0;
  for (const roomPlayer of room.players) {
    roomPlayer.ready = true;
    send(roomPlayer.socket, {
      type: "match_started",
      roomCode: room.code,
      turn: room.turn,
      slot: roomPlayer.slot,
      source: room.source,
      arena: room.arena
    });
  }
  broadcastState(room);
}

function findMatch(socket, payload) {
  leaveRoom(socket);
  leaveQueue(socket);
  const arena = clampInt(payload.arena, 0, 2, 0);
  const waiting = queues.get(arena) || [];
  while (waiting.length > 0 && waiting[0].socket.readyState !== WebSocket.OPEN) {
    waiting.shift();
  }
  if (waiting.length > 0) {
    const opponent = waiting.shift();
    if (waiting.length > 0) queues.set(arena, waiting);
    else queues.delete(arena);
    const code = roomCode();
    const room = {
      code,
      players: [],
      status: "waiting",
      turn: 0,
      sequence: 0,
      updatedAt: Date.now(),
      source: "arena",
      arena
    };
    rooms.set(code, room);
    joinRoom(opponent.socket, room, opponent.payload);
    joinRoom(socket, room, payload);
    startMatch(room);
    return;
  }
  waiting.push({
    socket,
    payload: {
      name: payload.name,
      animal: payload.animal,
      ringColor: payload.ringColor,
      level: payload.level,
      wins: payload.wins,
      losses: payload.losses
    },
    queuedAt: Date.now()
  });
  queues.set(arena, waiting);
  send(socket, { type: "searching", arena });
}

function handleMessage(socket, payload) {
  if (!payload || typeof payload.type !== "string") return;
  const session = clients.get(socket);

  if (payload.type === "create_room") {
    leaveQueue(socket);
    const code = roomCode();
    const room = {
      code,
      players: [],
      status: "waiting",
      turn: 0,
      sequence: 0,
      updatedAt: Date.now(),
      source: "friend",
      arena: -1
    };
    rooms.set(code, room);
    joinRoom(socket, room, payload);
    return;
  }

  if (payload.type === "join_room") {
    leaveQueue(socket);
    const code = String(payload.roomCode || "").trim().toUpperCase();
    const room = rooms.get(code);
    if (!room) {
      send(socket, { type: "error", code: "ROOM_NOT_FOUND", message: "Room not found" });
      return;
    }
    joinRoom(socket, room, payload);
    return;
  }

  if (payload.type === "find_match") {
    findMatch(socket, payload);
    return;
  }

  if (payload.type === "cancel_match") {
    leaveQueue(socket);
    send(socket, { type: "search_cancelled" });
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
    player.animal = clampInt(payload.animal, 0, 5, player.animal);
    player.ringColor = clampInt(payload.ringColor, 0, 5, player.ringColor);
    broadcastState(room);
    return;
  }

  if (payload.type === "ready") {
    player.ready = Boolean(payload.ready);
    if (room.players.length === 2 && room.players.every((item) => item.ready)) {
      startMatch(room);
      return;
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

  if (payload.type === "match_result") {
    if (room.status !== "playing") return;
    const winnerSlot = clampInt(payload.winnerSlot, 0, 1, -1);
    if (winnerSlot < 0) return;
    room.status = "finished";
    broadcast(room, {
      type: "match_over",
      winnerSlot,
      reason: "scored",
      sequence: room.sequence
    });
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

const PUBLIC_DIR = path.join(__dirname, "public");

function servePublic(request, response) {
  const requested = request.url === "/" ? "/index.html" : request.url.split("?")[0];
  const filePath = path.normalize(path.join(PUBLIC_DIR, requested));
  if (!filePath.startsWith(PUBLIC_DIR) || !fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    return false;
  }
  const ext = path.extname(filePath);
  const types = { ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8" };
  response.writeHead(200, { "Content-Type": types[ext] || "application/octet-stream" });
  response.end(fs.readFileSync(filePath));
  return true;
}

const server = http.createServer((request, response) => {
  response.setHeader("Access-Control-Allow-Origin", "*");
  if (request.url === "/health") {
    response.setHeader("Content-Type", "application/json; charset=utf-8");
    response.writeHead(200);
    response.end(JSON.stringify({
      ok: true,
      rooms: rooms.size,
      connections: clients.size,
      queued: [...queues.values()].reduce((sum, list) => sum + list.length, 0)
    }));
    return;
  }
  if (servePublic(request, response)) return;
  response.setHeader("Content-Type", "application/json; charset=utf-8");
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
    leaveQueue(socket);
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
  const queueBefore = Date.now() - 3 * 60 * 1000;
  for (const [arena, waiting] of queues.entries()) {
    const next = [];
    for (const item of waiting) {
      if (item.queuedAt < queueBefore) {
        send(item.socket, { type: "search_cancelled", reason: "timeout" });
      } else {
        next.push(item);
      }
    }
    if (next.length > 0) queues.set(arena, next);
    else queues.delete(arena);
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
