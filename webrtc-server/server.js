import express from "express";
import fetch from "node-fetch";
import http from "http";
import WebSocket from "ws";

import { WebSocketServer } from "ws";

const app = express();
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

const PORT = process.env.PORT || 8080;

/* ===============================
   🔐 TURN CREDENTIALS ENDPOINT
   =============================== */

app.get("/turn-credentials", async (req, res) => {
  try {
    const response = await fetch(
      `https://englishji.metered.live/api/v1/turn/credentials?apiKey=${process.env.METERED_API_KEY}`
    );

    const iceServers = await response.json();
    res.json(iceServers);
  } catch (err) {
    console.error("❌ TURN fetch failed", err);
    res.status(500).json({ error: "Failed to fetch TURN credentials" });
  }
});

/* ===============================
   📡 WEBSOCKET SIGNALING
   =============================== */

let waitingClient = null;

wss.on("connection", (ws) => {
  console.log("🟢 Client connected");

  ws.partner = null;

  ws.on("message", (message) => {
    let data;

    try {
      data = JSON.parse(message);
    } catch {
      console.error("❌ Invalid JSON");
      return;
    }

    console.log("📩 Received:", data.type);

    // ---- JOIN MATCHMAKING ----
    if (data.type === "join") {
      ws.userId = data.userId; // Save the user ID

      if (!waitingClient) {
        waitingClient = ws;
        console.log(`⏳ Client waiting (ID: ${ws.userId})`);
      } else {
        ws.partner = waitingClient;
        waitingClient.partner = ws;

        // Send 'matched' with the *OTHER* person's ID
        ws.send(JSON.stringify({
          type: "matched",
          role: "caller",
          partnerId: waitingClient.userId
        }));

        waitingClient.send(
          JSON.stringify({
            type: "matched",
            role: "callee",
            partnerId: ws.userId
          })
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
    }
  });

  ws.on("close", () => {
    console.log("🔴 Client disconnected");

    if (waitingClient === ws) waitingClient = null;

    if (ws.partner) {
      ws.partner.send(JSON.stringify({ type: "leave" }));
      ws.partner.partner = null;
    }
  });

  ws.on("error", (err) => {
    console.error("⚠️ WebSocket error:", err.message);
  });
});

/* ===============================
   🚀 START SERVER
   =============================== */

server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📡 WebSocket on ws://localhost:${PORT}`);
});
