const http = require("node:http");
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const { WebSocketServer, WebSocket } = require("ws");

const PORT = Number(process.env.PORT || 10000);
const rooms = new Map();
const clients = new Map();
const queues = new Map();
const authHandoffs = new Map();
const lobbyChat = [];
const LOBBY_CHAT_LIMIT = 40;
const presenceByPublicId = new Map();
const leaderboard = new Map();
const pendingInvites = new Map();
const fcmTokens = new Map();
const INVITE_TTL_MS = 15 * 60 * 1000;
const LEADERBOARD_LIMIT = 80;
const FCM_TOKEN_LIMIT = 4;

async function sendFcmPush(publicId, notification, data = {}) {
  const serverKey = process.env.FCM_SERVER_KEY;
  if (!serverKey) return;
  const tokens = fcmTokens.get(publicId) || [];
  if (!tokens.length) return;
  const body = JSON.stringify({
    registration_ids: tokens,
    notification,
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
    priority: "high"
  });
  try {
    const response = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${serverKey}`
      },
      body
    });
    if (!response.ok) return;
    const result = await response.json();
    const invalid = new Set();
    if (Array.isArray(result.results)) {
      result.results.forEach((item, index) => {
        if (item.error === "NotRegistered" || item.error === "InvalidRegistration") {
          invalid.add(tokens[index]);
        }
      });
    }
    if (invalid.size > 0) {
      fcmTokens.set(publicId, tokens.filter((token) => !invalid.has(token)));
    }
  } catch {
    // Push delivery is best-effort; offline invites are still queued in memory.
  }
}

function normalizePublicId(value) {
  const raw = String(value || "").trim().toUpperCase().replace(/\s+/g, "");
  if (!raw) return "";
  if (raw.startsWith("ZP-")) return raw.slice(0, 12);
  return (`ZP-${raw}`).slice(0, 12);
}

function upsertLeaderboard(entry) {
  const publicId = normalizePublicId(entry.publicId);
  if (!publicId) return;
  leaderboard.set(publicId, {
    publicId,
    name: String(entry.name || "Player").slice(0, 24),
    rating: clampInt(entry.rating, 0, 9999, 1000),
    wins: clampInt(entry.wins, 0, 999999, 0),
    losses: clampInt(entry.losses, 0, 999999, 0),
    leagueTier: clampInt(entry.leagueTier, 0, 5, 0),
    updatedAt: Date.now()
  });
  while (leaderboard.size > LEADERBOARD_LIMIT) {
    const oldest = [...leaderboard.entries()].sort((a, b) => a[1].updatedAt - b[1].updatedAt)[0];
    if (!oldest) break;
    leaderboard.delete(oldest[0]);
  }
}

function leaderboardSnapshot(limit = 10) {
  return [...leaderboard.values()]
    .sort((a, b) => b.rating - a.rating || b.wins - a.wins)
    .slice(0, limit)
    .map((item, index) => ({ rank: index + 1, ...item }));
}

function deliverPendingInvites(socket, publicId) {
  const queue = pendingInvites.get(publicId) || [];
  pendingInvites.delete(publicId);
  const now = Date.now();
  for (const invite of queue) {
    if (now - invite.at > INVITE_TTL_MS) continue;
    send(socket, {
      type: "friend_invite",
      fromName: invite.fromName,
      fromPublicId: invite.fromPublicId,
      roomCode: invite.roomCode
    });
  }
}

function send(socket, message) {
  if (socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify(message));
  }
}

function roomCode() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  for (let attempt = 0; attempt < 100; attempt += 1) {
    let code = "";
    for (let i = 0; i < 4; i += 1) {
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
    rating: player.rating ?? 1000,
    leagueTier: player.leagueTier ?? 0,
    publicId: player.publicId || "",
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
    rating: clampInt(payload.rating, 0, 9999, 1000),
    leagueTier: clampInt(payload.leagueTier, 0, 5, 0),
    publicId: normalizePublicId(payload.publicId),
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

function broadcastLobby(message) {
  for (const [socket] of clients.entries()) {
    send(socket, message);
  }
}

function handleMessage(socket, payload) {
  if (!payload || typeof payload.type !== "string") return;
  const session = clients.get(socket);

  if (payload.type === "lobby_chat") {
    const message = String(payload.message || "").trim().slice(0, 80);
    if (!message) return;
    const name = String(payload.name || "Player").slice(0, 24);
    const entry = { name, message, at: Date.now() };
    lobbyChat.push(entry);
    while (lobbyChat.length > LOBBY_CHAT_LIMIT) lobbyChat.shift();
    broadcastLobby({ type: "lobby_chat", ...entry });
    return;
  }

  if (payload.type === "register_fcm_token") {
    const publicId = normalizePublicId(payload.publicId || session.publicId);
    const token = String(payload.token || "").trim().slice(0, 512);
    if (!publicId || token.length < 20) {
      send(socket, { type: "error", code: "INVALID_FCM_TOKEN", message: "Invalid FCM token" });
      return;
    }
    session.publicId = publicId;
    const existing = fcmTokens.get(publicId) || [];
    const next = [token, ...existing.filter((item) => item !== token)].slice(0, FCM_TOKEN_LIMIT);
    fcmTokens.set(publicId, next);
    send(socket, { type: "fcm_registered", publicId, tokenCount: next.length });
    return;
  }

  if (payload.type === "register_presence") {
    const publicId = normalizePublicId(payload.publicId);
    if (!publicId) return;
    session.publicId = publicId;
    presenceByPublicId.set(publicId, socket);
    upsertLeaderboard({
      publicId,
      name: payload.name,
      rating: payload.rating,
      wins: payload.wins,
      losses: payload.losses,
      leagueTier: payload.leagueTier
    });
    deliverPendingInvites(socket, publicId);
    send(socket, { type: "leaderboard", entries: leaderboardSnapshot(12) });
    return;
  }

  if (payload.type === "get_leaderboard") {
    send(socket, { type: "leaderboard", entries: leaderboardSnapshot(12) });
    return;
  }

  if (payload.type === "invite_friend") {
    const inviterPublicId = normalizePublicId(payload.fromPublicId || session.publicId);
    const targetPublicId = normalizePublicId(payload.targetPublicId);
    const roomCode = String(payload.roomCode || session.roomCode || "").trim().toUpperCase();
    if (!targetPublicId || roomCode.length !== 4) {
      send(socket, { type: "error", code: "INVALID_INVITE", message: "Invalid invite target or room" });
      return;
    }
    const invite = {
      fromName: String(payload.fromName || "Player").slice(0, 24),
      fromPublicId: inviterPublicId,
      roomCode,
      at: Date.now()
    };
    const targetSocket = presenceByPublicId.get(targetPublicId);
    if (targetSocket && targetSocket.readyState === WebSocket.OPEN) {
      send(targetSocket, { type: "friend_invite", ...invite });
      send(socket, { type: "invite_sent", targetPublicId, online: true });
    } else {
      const queue = pendingInvites.get(targetPublicId) || [];
      queue.push(invite);
      pendingInvites.set(targetPublicId, queue.filter((item) => Date.now() - item.at <= INVITE_TTL_MS).slice(-5));
      send(socket, { type: "invite_sent", targetPublicId, online: false });
      void sendFcmPush(
        targetPublicId,
        {
          title: "Zoopaloola",
          body: `${invite.fromName} invited you to play!`
        },
        {
          type: "friend_invite",
          roomCode: invite.roomCode,
          fromName: invite.fromName,
          fromPublicId: invite.fromPublicId
        }
      );
    }
    return;
  }

  if (payload.type === "create_auth_handoff") {
    const token = crypto.randomBytes(24).toString("hex");
    authHandoffs.set(token, { socket, createdAt: Date.now() });
    send(socket, {
      type: "auth_handoff",
      url: `https://moshe2060.github.io/zoopaloola-mobile/?androidAuth=${token}`
    });
    return;
  }

  if (payload.type === "complete_auth_handoff") {
    const token = String(payload.handoffToken || "").toLowerCase();
    const handoff = /^[0-9a-f]{48}$/.test(token) ? authHandoffs.get(token) : null;
    if (!handoff || handoff.socket.readyState !== WebSocket.OPEN) {
      send(socket, { type: "error", code: "AUTH_HANDOFF_EXPIRED", message: "Android sign-in request expired" });
      return;
    }
    send(handoff.socket, {
      type: "auth_handoff_complete",
      localId: String(payload.localId || "").slice(0, 128),
      idToken: String(payload.idToken || "").slice(0, 4096),
      refreshToken: String(payload.refreshToken || "").slice(0, 1024),
      expiresIn: String(payload.expiresIn || "3600").slice(0, 12),
      provider: "google",
      email: String(payload.email || "").slice(0, 254),
      displayName: String(payload.displayName || "").slice(0, 24)
    });
    authHandoffs.delete(token);
    send(socket, { type: "auth_handoff_delivered" });
    return;
  }

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
    const canChat = room.status === "playing" || (room.status === "waiting" && room.source === "friend");
    if (!canChat) return;
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
  send(socket, { type: "connected", playerId: id, lobbyChat: lobbyChat.slice(-20) });

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
    const session = clients.get(socket);
    if (session?.publicId) presenceByPublicId.delete(session.publicId);
    clients.delete(socket);
	for (const [token, handoff] of authHandoffs.entries()) {
	  if (handoff.socket === socket) authHandoffs.delete(token);
	}
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
	const authBefore = Date.now() - 10 * 60 * 1000;
	for (const [token, handoff] of authHandoffs.entries()) {
	  if (handoff.createdAt < authBefore) authHandoffs.delete(token);
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
