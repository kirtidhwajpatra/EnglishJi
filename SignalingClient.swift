//
//  SignalingClient.swift
//  EnglishJi
//
//  Maintained by Senior iOS Engineer
//

import Foundation
import Combine

/// Dedicated client for handling WebSocket signaling with the matchmaking server.
final class SignalingClient: ObservableObject {

    // MARK: - Types
    
    enum SignalingError: Error {
        case connectionFailed
        case invalidData
        case encodingFailed
        case disconnected
    }

    // MARK: - Properties
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// Callback for incoming messages.
    /// Result type allows for robust error handling upstream.
    var onMessageReceived: ((Result<[String: Any], SignalingError>) -> Void)?
    
    private let serverURL = URL(string: "wss://englishcallingapp.onrender.com")!
    
    // Connection State
    @Published private(set) var isConnected: Bool = false

    // MARK: - Configuration
    
    private let urlSession: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: config)
    }

    // MARK: - Connection Management
    
    func connect() {
        disconnect() // Ensure clean slate
        
        webSocketTask = urlSession.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        
        // Optimistically set connected, real validation happens on messages
        isConnected = true
        print("[SignalingClient] Connector started: \(serverURL)")
        
        listenForMessages()
    }
    
    func disconnect() {
        guard isConnected || webSocketTask != nil else { return }
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        print("[SignalingClient] Disconnected")
    }
    
    // MARK: - Matchmaking Handlers
    
    func sendJoinRequest(userId: String) {
        let payload: [String: Any] = [
            "type": "join",
            "userId": userId
        ]
        send(payload)
        print("[SignalingClient] 📨 Join request sent for user: \(userId)")
    }
    
    func sendSDP(type: String, sdp: String) {
        let payload: [String: Any] = [
            "type": type,
            "sdp": sdp
        ]
        send(payload)
    }
    
    func sendCandidate(sdp: String, sdpMid: String?, sdpMLineIndex: Int32) {
         let payload: [String: Any] = [
            "type": "candidate",
            "candidate": sdp,
            "sdpMid": sdpMid ?? "",
            "sdpMLineIndex": sdpMLineIndex
        ]
        send(payload)
    }

    // MARK: - Private Messaging Logic
    
    func send(_ dictionary: [String: Any]) {
        guard let socket = webSocketTask else {
            print("[SignalingClient] ❌ Error: Socket not connected")
            return 
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            if let text = String(data: data, encoding: .utf8) {
                socket.send(.string(text)) { [weak self] error in
                    if let error = error {
                        print("[SignalingClient] ❌ Send failed: \(error.localizedDescription)")
                        self?.isConnected = false
                    }
                }
            }
        } catch {
            print("[SignalingClient] ❌ JSON Encoding failed: \(error.localizedDescription)")
        }
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleIncomingMessage(message)
                self.listenForMessages() // Recursive loop
                
            case .failure(let error):
                print("[SignalingClient] ❌ Receive error: \(error.localizedDescription)")
                self.isConnected = false
                self.onMessageReceived?(.failure(.connectionFailed))
            }
        }
    }
    
    private func handleIncomingMessage(_ message: URLSessionWebSocketTask.Message) {
        var jsonData: Data?
        
        switch message {
        case .string(let text):
            jsonData = text.data(using: .utf8)
        case .data(let data):
            jsonData = data
        @unknown default:
            return
        }
        
        guard let data = jsonData,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[SignalingClient] ⚠️ Received invalid JSON data")
            onMessageReceived?(.failure(.invalidData))
            return
        }
        
        // Dispatch to main thread for safety if updating UI logic
        DispatchQueue.main.async {
            self.onMessageReceived?(.success(json))
        }
    }
}
