//
//  SignalingClient.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 14/12/25.
//
import Foundation


final class SignalingClient {

    private var socket: URLSessionWebSocketTask?
    var onMessage: (([String: Any]) -> Void)?

    func connect() {
        let url = URL(string: "ws://10.109.124.242:8080")!
        socket = URLSession.shared.webSocketTask(with: url)
        socket?.resume()
        listen()
        print("🟢 Signaling connected")
    }

    func join() {
        send(["type": "join"])
        print("📨 Sent join")
    }

    func send(_ dict: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: dict)
        let text = String(data: data, encoding: .utf8)!
        socket?.send(.string(text)) { _ in }
    }

    private func listen() {
        socket?.receive { [weak self] result in
            if case let .success(.string(text)) = result {
                let json = try! JSONSerialization.jsonObject(
                    with: Data(text.utf8)
                ) as! [String: Any]

                print("⬇️ Received:", json)
                self?.onMessage?(json)
            }
            self?.listen()
        }
    }
    
    func close() {
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
    }

}

