const WebSocket = require("ws");
const wss = new WebSocket.Server({ port: 8080 });

let waiting = null;

wss.on("connection", ws => {
    console.log("🟢 Client connected");

    ws.on("message", msg => {
        const data = JSON.parse(msg);

        if (data.type === "join") {
            if (waiting) {
                ws.peer = waiting;
                waiting.peer = ws;

                ws.send(JSON.stringify({ type: "matched", role: "caller" }))
                waiting.send(JSON.stringify({ type: "matched", role: "callee" }))


                waiting = null;
            } else {
                waiting = ws;
            }
            return;
        }

        if (ws.peer) {
            ws.peer.send(msg);
        }
    });

    ws.on("close", () => {
        if (waiting === ws) waiting = null;
    });
});

console.log("🚀 Signaling server running on ws://localhost:8080");
