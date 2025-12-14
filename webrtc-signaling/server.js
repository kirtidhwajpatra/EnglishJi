const WebSocket = require("ws");
const wss = new WebSocket.Server({ port: 8080 });

let waiting = null;

wss.on("connection", ws => {
    console.log("🟢 Client connected");

    ws.on("message", message => {
        const data = JSON.parse(message);

        // JOIN
        if (data.type === "join") {
            if (waiting) {
                ws.peer = waiting;
                waiting.peer = ws;

                ws.send(JSON.stringify({ type: "matched", role: "caller" }));
                waiting.send(JSON.stringify({ type: "matched", role: "callee" }));

                waiting = null;
            } else {
                waiting = ws;
            }
            return;
        }

        // RELAY EVERYTHING ELSE SAFELY
        if (ws.peer && ws.peer.readyState === WebSocket.OPEN) {
            ws.peer.send(JSON.stringify(data));
        }
    });

    ws.on("close", () => {
        if (waiting === ws) waiting = null;
        if (ws.peer) ws.peer.peer = null;
    });
});

console.log("🚀 Signaling server running on ws://0.0.0.0:8080");
