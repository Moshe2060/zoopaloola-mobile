const { test } = require("node:test");
const assert = require("node:assert/strict");
const { spawn } = require("node:child_process");
const { WebSocket } = require("ws");

const PORT = 11237;

function connect() {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(`ws://127.0.0.1:${PORT}/ws`);
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
  const child = spawn(process.execPath, ["server.js"], {
    cwd: __dirname,
    env: { ...process.env, PORT: String(PORT) },
    stdio: ["ignore", "pipe", "pipe"]
  });
  context.after(() => child.kill("SIGTERM"));
  await new Promise((resolve, reject) => {
    child.stdout.once("data", resolve);
    child.once("error", reject);
  });

  const first = await connect();
  const second = await connect();
  context.after(() => first.close());
  context.after(() => second.close());

  const joinedFirstPromise = next(first, "joined");
  first.send(JSON.stringify({ type: "create_room", name: "One", animal: 1, ringColor: 3, level: 7, wins: 12, losses: 4 }));
  const joinedFirst = await joinedFirstPromise;
  assert.match(joinedFirst.roomCode, /^[A-Z2-9]{6}$/);

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
