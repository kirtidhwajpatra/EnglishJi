import Foundation
import WebRTC
import Combine
import AVFoundation

class WebRTCManager: ObservableObject {
    
    // MARK: - Dependencies
    private let signalingClient = SignalingClient()
    private let webRTCClient = WebRTCClient() // Assumes WebRTCClient is initialized properly
    
    // MARK: - State Properties
    @Published var connectionState: String = "Idle"
    @Published var debugLog: String = "Ready..."
    
    private var currentRoomId: String?
    private var isCaller: Bool = false
    private var myUserId: String?
    
    init() {
        self.webRTCClient.delegate = self
        // Redirect Signaling logs to our debug log
        self.signalingClient.onLog = { [weak self] message in
            DispatchQueue.main.async {
                self?.debugLog += "\n\(message)"
            }
        }
    }
    
    func startMatchmaking(userId: String) {
        self.myUserId = userId
        self.connectionState = "Searching..."
        self.debugLog = "🔍 Starting matchmaking for \(userId)..."
        
        signalingClient.startMatchmaking(userId: userId) { [weak self] (roomId, isCaller) in
            guard let self = self else { return }
            self.currentRoomId = roomId
            self.isCaller = isCaller
            
            DispatchQueue.main.async {
                self.connectionState = "Connecting..."
                self.debugLog += "\n✅ Match Found! Room: \(roomId)"
                self.startCall(roomId: roomId, isCaller: isCaller)
            }
        }
    }
    
    func cancelMatchmaking() {
        if let userId = myUserId {
            signalingClient.cancelMatchmaking(userId: userId)
        }
        disconnect()
    }
    
    func disconnect() {
        if let roomId = currentRoomId {
            // Optional: Send "bye" message
            signalingClient.deleteCall(sessionId: roomId)
        }
        
        webRTCClient.close()
        signalingClient.cancelListeners()
        
        self.currentRoomId = nil
        self.connectionState = "Disconnected"
        self.debugLog += "\n🛑 Disconnected."
    }
    
    func toggleMute(isMuted: Bool) {
        webRTCClient.muteAudio(isMuted)
        print("Microphone is now: \(isMuted ? "Muted" : "Unmuted")")
    }
    
    // MARK: - Private Call Logic
    
    private func startCall(roomId: String, isCaller: Bool) {
        // 1. Listen for ICE Candidates
        signalingClient.listenForRemoteCandidates(sessionId: roomId, isCaller: isCaller) { [weak self] candidate in
            self?.webRTCClient.set(remoteCandidate: candidate) { error in
                if let error = error { print("❌ Error setting remote candidate: \(error)") }
            }
        }
        
        // 2. Handle SDP Exchange
        if isCaller {
            // I am CALLER: Create Offer
            webRTCClient.offer { [weak self] sdp in
                self?.signalingClient.send(sdp: sdp, sessionId: roomId)
            }
            
            // Listen for Answer
            signalingClient.listenForRemoteSdp(sessionId: roomId, isCaller: isCaller) { [weak self] sdp in
                guard let sdp = sdp else { return }
                self?.webRTCClient.set(remoteSdp: sdp) { error in
                   if let error = error { print("❌ Error setting remote answer: \(error)") }
                }
            }
            
        } else {
            // I am CALLEE: Listen for Offer
            signalingClient.listenForRemoteSdp(sessionId: roomId, isCaller: isCaller) { [weak self] sdp in
                guard let sdp = sdp else { return }
                
                // Set Remote Offer
                self?.webRTCClient.set(remoteSdp: sdp) { error in
                    if let error = error {
                        print("❌ Error setting remote offer: \(error)")
                        return
                    }
                    
                    // Create Answer
                    self?.webRTCClient.answer { [weak self] answerSdp in
                        self?.signalingClient.send(sdp: answerSdp, sessionId: roomId)
                    }
                }
            }
        }
    }
}

extension WebRTCManager: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        // Send local candidate to Firestore
        if let roomId = currentRoomId {
            signalingClient.send(candidate: candidate, sessionId: roomId, isCaller: self.isCaller)
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected, .completed:
                self.connectionState = "Connected"
            case .disconnected, .failed, .closed:
                self.connectionState = "Disconnected"
            case .checking:
                self.connectionState = "Connecting..."
            default:
                break
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        // Handle data channel if needed
    }
}
