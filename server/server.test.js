const { test } = require("node:test");
const assert = require("node:assert/strict");
const { spawn } = require("node:child_process");
const { WebSocket } = require("ws");

function startServer(port) {
  const child = spawn(process.execPath, ["server.js"], {
    cwd: __dirname,
    env: { ...process.env, PORT: String(port) },
    stdio: ["ignore", "pipe", "pipe"]
  });
  return new Promise((resolve, reject) => {
    child.once("error", reject);
    child.stdout.once("data", () => resolve(child));
  });
}

function connect(port) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(`ws://127.0.0.1:${port}/ws`);
    socket.once("error", reject);
    socket.on("message", function onConnected(buffer) {
      const message = JSON.parse(buffer.toString());
      if (message.type !== "connected") return;
      socket.off("message", onConnected);
      resolve(socket);
    });
  });
}

function next(socket, type, predicate = () => true) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error(`Timed out waiting for ${type}`)), 3000);
    function onMessage(buffer) {
      const message = JSON.parse(buffer.toString());
      if (message.type !== type || !predicate(message)) return;
      clearTimeout(timeout);
      socket.off("message", onMessage);
      resolve(message);
    }
    socket.on("message", onMessage);
  });
}

test("two players create, join, ready and relay a shot", async (context) => {
  const port = 11237;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const first = await connect(port);
  const second = await connect(port);
  context.after(() => first.close());
  context.after(() => second.close());

  const joinedFirstPromise = next(first, "joined");
  first.send(JSON.stringify({ type: "create_room", name: "One", animal: 1, ringColor: 3, level: 7, wins: 12, losses: 4 }));
  const joinedFirst = await joinedFirstPromise;
  assert.match(joinedFirst.roomCode, /^[A-Z2-9]{4}$/);
  assert.equal(joinedFirst.source, "friend");

  const joinedSecondPromise = next(second, "joined");
  second.send(JSON.stringify({ type: "join_room", roomCode: joinedFirst.roomCode, name: "Two" }));
  const joinedSecond = await joinedSecondPromise;
  assert.equal(joinedSecond.slot, 1);

  const profilePromise = next(second, "room_state", (message) => message.players?.[0]?.animal === 5);
  first.send(JSON.stringify({ type: "update_profile", animal: 5, ringColor: 4 }));
  const profileState = await profilePromise;
  assert.equal(profileState.players[0].animal, 5);
  assert.equal(profileState.players[0].ringColor, 4);
  assert.equal(profileState.players[0].level, 7);
  assert.equal(profileState.players[0].wins, 12);
  assert.equal(profileState.players[0].losses, 4);

  const startedPromise = next(first, "match_started");
  const secondStartedPromise = next(second, "match_started");
  first.send(JSON.stringify({ type: "ready", ready: true }));
  second.send(JSON.stringify({ type: "ready", ready: true }));
  const started = await startedPromise;
  const secondStarted = await secondStartedPromise;
  assert.equal(started.turn, 0);
  assert.equal(started.slot, 0);
  assert.equal(secondStarted.slot, 1);

  const shotPromise = next(second, "shot");
  first.send(JSON.stringify({ type: "shot", ballIndex: 4, pullX: -12, pullY: 8, strength: 18 }));
  const shot = await shotPromise;
  assert.equal(shot.ballIndex, 4);
  assert.equal(shot.playerSlot, 0);

  const chatPromise = next(second, "chat");
  first.send(JSON.stringify({ type: "chat", message: "Good luck!" }));
  const chat = await chatPromise;
  assert.equal(chat.playerSlot, 0);
  assert.equal(chat.name, "One");
  assert.equal(chat.message, "Good luck!");
});

test("arena matchmaking pairs two players and reports a winner", async (context) => {
  const port = 11238;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const first = await connect(port);
  const second = await connect(port);
  context.after(() => first.close());
  context.after(() => second.close());

  const searchingPromise = next(first, "searching");
  first.send(JSON.stringify({ type: "find_match", name: "One", animal: 2, ringColor: 1, arena: 0 }));
  const searching = await searchingPromise;
  assert.equal(searching.arena, 0);

  const firstStarted = next(first, "match_started");
  const secondStarted = next(second, "match_started");
  second.send(JSON.stringify({ type: "find_match", name: "Two", animal: 4, ringColor: 5, arena: 0 }));
  const startedA = await firstStarted;
  const startedB = await secondStarted;
  assert.equal(startedA.source, "arena");
  assert.equal(startedB.source, "arena");
  assert.equal(startedA.arena, 0);
  assert.notEqual(startedA.slot, startedB.slot);

  const overPromise = next(second, "match_over");
  first.send(JSON.stringify({ type: "match_result", winnerSlot: startedA.slot }));
  const over = await overPromise;
  assert.equal(over.winnerSlot, startedA.slot);
  assert.equal(over.reason, "scored");
});

test("cancel_match removes a player from the arena queue", async (context) => {
  const port = 11239;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const first = await connect(port);
  const second = await connect(port);
  context.after(() => first.close());
  context.after(() => second.close());

  await Promise.all([
    next(first, "searching"),
    Promise.resolve(first.send(JSON.stringify({ type: "find_match", name: "One", arena: 1 })))
  ]);
  const cancelled = next(first, "search_cancelled");
  first.send(JSON.stringify({ type: "cancel_match" }));
  await cancelled;

  const searchingSecond = next(second, "searching");
  second.send(JSON.stringify({ type: "find_match", name: "Two", arena: 1 }));
  await searchingSecond;
});

test("lobby chat broadcasts to connected clients", async (context) => {
  const port = 11241;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const first = await connect(port);
  const second = await connect(port);
  context.after(() => first.close());
  context.after(() => second.close());

  const chatPromise = next(second, "lobby_chat");
  first.send(JSON.stringify({ type: "lobby_chat", name: "One", message: "Hello lobby!" }));
  const chat = await chatPromise;
  assert.equal(chat.name, "One");
  assert.equal(chat.message, "Hello lobby!");
});

test("friend room chat works while waiting", async (context) => {
  const port = 11242;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const host = await connect(port);
  const guest = await connect(port);
  context.after(() => host.close());
  context.after(() => guest.close());

  const joinedHost = next(host, "joined");
  host.send(JSON.stringify({ type: "create_room", name: "Host", animal: 0, ringColor: 0 }));
  const hostJoined = await joinedHost;

  const joinedGuest = next(guest, "joined");
  guest.send(JSON.stringify({ type: "join_room", roomCode: hostJoined.roomCode, name: "Guest" }));
  await joinedGuest;

  const chatPromise = next(host, "chat");
  guest.send(JSON.stringify({ type: "chat", message: "Ready when you are" }));
  const chat = await chatPromise;
  assert.equal(chat.message, "Ready when you are");
  assert.equal(chat.name, "Guest");
});

test("invite_friend delivers to online player", async (context) => {
  const port = 11243;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const host = await connect(port);
  const target = await connect(port);
  context.after(() => host.close());
  context.after(() => target.close());

  host.send(JSON.stringify({ type: "register_presence", publicId: "ZP-HOSTTEST", name: "Host", rating: 1200 }));
  target.send(JSON.stringify({ type: "register_presence", publicId: "ZP-TARGET01", name: "Target", rating: 1100 }));
  await next(host, "leaderboard");
  await next(target, "leaderboard");

  const joined = next(host, "joined");
  host.send(JSON.stringify({ type: "create_room", name: "Host", animal: 0, ringColor: 0, publicId: "ZP-HOSTTEST" }));
  const hostJoined = await joined;

  const invitePromise = next(target, "friend_invite");
  host.send(JSON.stringify({
    type: "invite_friend",
    targetPublicId: "ZP-TARGET01",
    roomCode: hostJoined.roomCode,
    fromName: "Host",
    fromPublicId: "ZP-HOSTTEST"
  }));
  const invite = await invitePromise;
  assert.equal(invite.roomCode, hostJoined.roomCode);
  assert.equal(invite.fromName, "Host");
});

test("add_friend syncs both players and delivers friend list", async (context) => {
  const port = 11245;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const first = await connect(port);
  const second = await connect(port);
  context.after(() => first.close());
  context.after(() => second.close());

  first.send(JSON.stringify({ type: "register_presence", publicId: "ZP-PLAYER01", name: "Moshe", rating: 1200, wins: 3, losses: 1 }));
  await next(first, "leaderboard");
  second.send(JSON.stringify({ type: "register_presence", publicId: "ZP-PLAYER02", name: "Friend", rating: 1100, wins: 2, losses: 2 }));
  await next(second, "leaderboard");

  const firstListPromise = next(first, "friends_list", (message) => message.friends?.length === 1);
  const resultPromise = next(first, "friend_add_result");
  const secondListPromise = next(second, "friends_list", (message) => message.friends?.length === 1);
  const notifyPromise = next(second, "friend_added_notify");
  first.send(JSON.stringify({
    type: "add_friend",
    fromPublicId: "ZP-PLAYER01",
    targetPublicId: "ZP-PLAYER02",
    fromName: "Moshe",
    rating: 1200,
    wins: 3,
    losses: 1,
    leagueTier: 1
  }));
  const firstList = await firstListPromise;
  const result = await resultPromise;
  const secondList = await secondListPromise;
  const notify = await notifyPromise;
  assert.equal(firstList.friends.length, 1);
  assert.equal(result.ok, true);
  assert.equal(result.friend.name, "Friend");
  assert.equal(notify.friend.name, "Moshe");
  assert.equal(secondList.friends.length, 1);
  assert.equal(secondList.friends[0].name, "Moshe");
});

test("register_fcm_token stores token for offline push delivery", async (context) => {
  const port = 11244;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const client = await connect(port);
  context.after(() => client.close());

  const registeredPromise = next(client, "fcm_registered");
  client.send(JSON.stringify({
    type: "register_fcm_token",
    publicId: "ZP-PUSHTEST",
    token: "fcm-token-abcdefghijklmnopqrstuvwxyz"
  }));
  const registered = await registeredPromise;
  assert.equal(registered.publicId, "ZP-PUSHTEST");
  assert.equal(registered.tokenCount, 1);
});

test("browser securely returns Google auth to the waiting Android client", async (context) => {
  const port = 11240;
  const child = await startServer(port);
  context.after(() => child.kill("SIGTERM"));

  const android = await connect(port);
  const browser = await connect(port);
  context.after(() => android.close());
  context.after(() => browser.close());

  const handoffPromise = next(android, "auth_handoff");
  android.send(JSON.stringify({ type: "create_auth_handoff" }));
  const handoff = await handoffPromise;
  const token = new URL(handoff.url).searchParams.get("androidAuth");
  assert.match(token, /^[0-9a-f]{48}$/);

  const completedPromise = next(android, "auth_handoff_complete");
  browser.send(JSON.stringify({
    type: "complete_auth_handoff",
    handoffToken: token,
    localId: "firebase-user",
    idToken: "id-token",
    refreshToken: "refresh-token",
    provider: "google",
    email: "player@gmail.com",
    displayName: "Player Name"
  }));
  const completed = await completedPromise;
  assert.equal(completed.provider, "google");
  assert.equal(completed.email, "player@gmail.com");
  assert.equal(completed.displayName, "Player Name");
});
