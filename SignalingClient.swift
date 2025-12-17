//
//  SignalingClient.swift
//  EnglishJi
//

//final change code date: dec 17, 10am

import Foundation

final class SignalingClient {

    // MARK: - Properties
    private var socket: URLSessionWebSocketTask?
    var onMessage: (([String: Any]) -> Void)?

    private let serverURL = URL(string: "ws://10.238.253.242:8080")!

    // MARK: - Connect
    func connect() {
        close() // ensure clean state

        let session = URLSession(configuration: .default)
        socket = session.webSocketTask(with: serverURL)
        socket?.resume()

        print("🟢 Signaling connecting to \(serverURL)")
        listen()
    }

    // MARK: - Join matchmaking
    func join() {
        send(["type": "join"])
        print("📨 Sent join")
    }

    // MARK: - Send message
    func send(_ dict: [String: Any]) {
        guard let socket else { return }

        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            let text = String(data: data, encoding: .utf8) ?? ""
            socket.send(.string(text)) { error in
                if let error {
                    print("❌ Send error:", error)
                }
            }
        } catch {
            print("❌ JSON encode error:", error)
        }
    }

    // MARK: - Listen for messages
    private func listen() {
        socket?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("⬇️ Received:", json)
                        self.onMessage?(json)
                    }
                case .data(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("⬇️ Received:", json)
                        self.onMessage?(json)
                    }
                @unknown default:
                    break
                }

                // continue listening
                self.listen()

            case .failure(let error):
                print("❌ Receive error:", error)
            }
        }
    }

    // MARK: - Close connection
    func close() {
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
    }
}
