const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8080 });
let waitingClients = [];

console.log("Signaling server running on ws://localhost:8080");

wss.on("connection", ws => {
    console.log("Client connected");

    ws.on("message", data => {
        const message = JSON.parse(data);

        if (message.type === "join") {
            if (waitingClients.length > 0) {
                const peer = waitingClients.shift();

                ws.room = peer;
                peer.room = ws;

                ws.send(JSON.stringify({ type: "matched", role: "caller" }));
                peer.send(JSON.stringify({ type: "matched", role: "callee" }));
            } else {
                waitingClients.push(ws);
            }
        }

        if (message.type === "leave") {
            console.log("Client left matchmaking");
            waitingClients = waitingClients.filter(c => c !== ws);
            ws.room = null;
        }

        if (message.type === "end") {
            if (ws.room) {
                ws.room.send(JSON.stringify({ type: "end" }));
                ws.room.room = null;
                ws.room = null;
            }
        }

        if (["offer", "answer", "candidate"].includes(message.type)) {
            if (ws.room) {
                ws.room.send(JSON.stringify(message));
            }
        }
    });

    ws.on("close", () => {
        waitingClients = waitingClients.filter(c => c !== ws);
        ws.room = null;
        console.log("Client disconnected");
    });
});
