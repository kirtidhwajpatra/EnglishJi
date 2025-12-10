//
//  WebRTCManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 10/12/25.
//

import SwiftUI
import WebRTC
import Combine

class WebRTCManager: ObservableObject {
    // Dependencies
    private let webRTCClient: WebRTCClient
    private let signalingClient: SignalingClient
    
    // State
    @Published var connectionState: String = "Idle"
    
    // Session Info
    private var sessionId: String?
    private var isCaller: Bool = false
    
    init() {
        self.webRTCClient = WebRTCClient()
        self.signalingClient = SignalingClient()
        self.webRTCClient.delegate = self
    }
    
    // MARK: - Main Action: Find Partner & Connect
    func startMatchmaking() {
        self.connectionState = "Searching..."
        
        signalingClient.findOrCreateSession { [weak self] sessionId, isCaller in
            guard let self = self else { return }
            self.sessionId = sessionId
            self.isCaller = isCaller
            self.connectionState = isCaller ? "Waiting for partner..." : "Connecting..."
            
            if isCaller {
                self.startAsCaller()
            } else {
                self.startAsCallee(sessionId: sessionId)
            }
            
            // Start Listening for Candidates from the other side
            self.signalingClient.listenForRemoteCandidates(sessionId: sessionId, isCaller: isCaller) { [weak self] candidate in
                self?.webRTCClient.set(remoteCandidate: candidate) { error in
                    print("Added remote candidate")
                }
            }
        }
    }
    
    private func startAsCaller() {
        self.webRTCClient.offer { [weak self] sdp in
            guard let self = self, let sessionId = self.sessionId else { return }
            
            // 1. Send Offer to Firestore
            self.signalingClient.send(sdp: sdp, sessionId: sessionId)
            
            // 2. Listen for Answer
            self.signalingClient.listenForRemoteSdp(sessionId: sessionId) { [weak self] remoteSdp in
                if remoteSdp.type == .answer {
                    self?.webRTCClient.set(remoteSdp: remoteSdp) { _ in
                        print("Remote Answer Set! Connection should start.")
                    }
                }
            }
        }
    }
    
    private func startAsCallee(sessionId: String) {
        // 1. Listen for Offer
        self.signalingClient.listenForRemoteSdp(sessionId: sessionId) { [weak self] remoteSdp in
            guard let self = self else { return }
            
            if remoteSdp.type == .offer {
                // 2. Set Remote Offer
                self.webRTCClient.set(remoteSdp: remoteSdp) { _ in
                    
                    // 3. Create Answer
                    self.webRTCClient.answer { [weak self] localSdp in
                        guard let self = self else { return }
                        // 4. Send Answer
                        self.signalingClient.send(sdp: localSdp, sessionId: sessionId)
                    }
                }
            }
        }
    }
}

// MARK: - Delegate to handle local candidates
extension WebRTCManager: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        guard let sessionId = self.sessionId else { return }
        self.signalingClient.send(candidate: candidate, sessionId: sessionId, isCaller: self.isCaller)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected, .completed:
                self.connectionState = "Connected"
            case .disconnected, .failed, .closed:
                self.connectionState = "Disconnected"
            default:
                break
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {}
}
