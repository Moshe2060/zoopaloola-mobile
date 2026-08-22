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

function next(socket, type) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error(`Timed out waiting for ${type}`)), 3000);
    function onMessage(buffer) {
      const message = JSON.parse(buffer.toString());
      if (message.type !== type) return;
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
  first.send(JSON.stringify({ type: "create_room", name: "One", animal: 1, ringColor: 3 }));
  const joinedFirst = await joinedFirstPromise;
  assert.match(joinedFirst.roomCode, /^[A-Z2-9]{6}$/);

  const joinedSecondPromise = next(second, "joined");
  second.send(JSON.stringify({ type: "join_room", roomCode: joinedFirst.roomCode, name: "Two" }));
  const joinedSecond = await joinedSecondPromise;
  assert.equal(joinedSecond.slot, 1);

  const startedPromise = next(first, "match_started");
  first.send(JSON.stringify({ type: "ready", ready: true }));
  second.send(JSON.stringify({ type: "ready", ready: true }));
  const started = await startedPromise;
  assert.equal(started.turn, 0);

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
