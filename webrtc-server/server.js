const WebSocket = require("ws");

const PORT = 8080;
const wss = new WebSocket.Server({ port: PORT });

console.log(`🚀 Signaling server running on ws://localhost:${PORT}`);

let waitingClient = null;

wss.on("connection", (ws) => {
  console.log("🟢 Client connected");

  ws.partner = null;

  ws.on("message", (message) => {
    let data;

    try {
      data = JSON.parse(message);
    } catch (e) {
      console.error("❌ Invalid JSON received");
      return;
    }

    console.log("📩 Received:", data.type);

    // ---- JOIN MATCHMAKING ----
    if (data.type === "join") {
      if (waitingClient === null) {
        waitingClient = ws;
        console.log("⏳ Client waiting for match");
      } else {
        ws.partner = waitingClient;
        waitingClient.partner = ws;

        ws.send(JSON.stringify({ type: "matched", role: "caller" }));
        waitingClient.send(
          JSON.stringify({ type: "matched", role: "callee" })
        );

        waitingClient = null;
        console.log("🤝 Clients matched");
      }
      return;
    }

    // ---- RELAY WEBRTC SIGNALS ----
    if (
      data.type === "offer" ||
      data.type === "answer" ||
      data.type === "candidate" ||
      data.type === "ice"
    ) {
      if (ws.partner && ws.partner.readyState === WebSocket.OPEN) {
        ws.partner.send(JSON.stringify(data));
        console.log(`➡️ Relayed ${data.type}`);
      }
      return;
    }

    // ---- CALL END ----
    if (data.type === "leave" || data.type === "end") {
      if (ws.partner) {
        ws.partner.send(JSON.stringify({ type: "leave" }));
        ws.partner.partner = null;
        ws.partner = null;
      }
      console.log("📴 Call ended");
      return;
    }
  });

  ws.on("close", () => {
    console.log("🔴 Client disconnected");

    if (waitingClient === ws) {
      waitingClient = null;
    }

    if (ws.partner) {
      ws.partner.send(JSON.stringify({ type: "leave" }));
      ws.partner.partner = null;
    }
  });

  ws.on("error", (err) => {
    console.error("⚠️ WebSocket error:", err.message);
  });
});
