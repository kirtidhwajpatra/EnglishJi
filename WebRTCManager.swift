
import Foundation
import WebRTC
import AVFoundation
import Combine

/// Manages the WebRTC connection lifecycle, signaling, and call state.
/// Acts as the central coordinator for the calling feature.
@MainActor
final class WebRTCManager: NSObject, ObservableObject {

    // MARK: - UI State
    
    @Published var isInCall: Bool = false
    
    // 🔥 COMPATIBILITY FIX: Views expect 'connectionState' to be a String.
    // We keep the internal enum for logic, but expose the String property.
    @Published private var _connectionState: ConnectionState = .idle
    
    var connectionState: String {
        return _connectionState.rawValue
    }
    
    @Published var debugLog: String = ""
    @Published var showCallSummary: Bool = false
    
    // Audio Stats
    @Published var currentMicVolume: Double = 0.0
    
    var isLocalAudioTrackEnabled: Bool {
        return webRTCClient?.localAudioTrack?.isEnabled ?? false
    }
    
    // 🔥 COMPATIBILITY FIX: Views expect Int (0=Live, 1=Ended, 2=Muted)
    var localAudioSourceState: Int {
        return webRTCClient?.localAudioTrack?.source.state.rawValue ?? 1
    }
    
    @Published var lastCallPartnerId: String = ""
    
    // 🔥 COMPATIBILITY FIX: Views expect 'myUserId' to be available for CallSummary
    var myUserId: String = ""
    
    // MARK: - Core Components
    
    private var webRTCClient: WebRTCClient?
    private let signalingClient = SignalingClient()
    private let audioSessionManager = AudioSessionManager.shared
    
    // MARK: - Internal State
    
    private var isConnecting = false
    private var isRemoteDescriptionSet = false
    private var pendingICECandidates: [RTCIceCandidate] = []
    
    // Determines if we can start a new matchmaking request
    private var canStartMatchmaking: Bool {
        return !isConnecting && _connectionState == .idle
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        log("WebRTCManager initialized")
        
        setupSignalingBindings()
    }
    
    private func setupSignalingBindings() {
        signalingClient.onMessageReceived = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let payload):
                self.handleSignalingMessage(payload)
            case .failure(let error):
                self.log("Signaling error: \(error)")
                // Optionally handle disconnection or retry logic here
            }
        }
    }

    // MARK: - Public API

    func startMatchmaking(userId: String) {
        // Compatibility: Store userId
        self.myUserId = userId
        
        guard canStartMatchmaking else {
            log("Matchmaking ignored: Already active or connecting.")
            return
        }
        
        isConnecting = true
        _connectionState = .searching
        objectWillChange.send() // Force UI update since _connectionState is wrapped
        
        // Ensure permissions before proceeding
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            
            Task { @MainActor in
                if granted {
                    self.beginConnectionSequence(userId: userId)
                } else {
                    self.log("Microphone permission denied.")
                    self.resetState()
                }
            }
        }
    }
    
    func disconnect() {
        log("Disconnect requested by user.")
        endCall(reason: "User hangup")
    }
    
    func toggleMute(isMuted: Bool) {
        webRTCClient?.setMuted(isMuted)
        log("Microphone muted: \(isMuted)")
    }
    
    // MARK: - Connection Logic
    
    private func beginConnectionSequence(userId: String) {
        // 1. Reset any previous state
        resetState(keepUI: true)
        
        // 2. Prepare Audio
        audioSessionManager.configureAudioSession()
        audioSessionManager.activateSession()
        
        // 3. Initialize WebRTC
        webRTCClient = WebRTCClient()
        setupWebRTCCallbacks()
        
        // 4. Connect Signaling
        log("Connecting to signaling server...")
        signalingClient.connect()
        signalingClient.sendJoinRequest(userId: userId)
    }

    private func endCall(reason: String) {
        log("Ending call. Reason: \(reason)")
        
        // Notify remote peer
        signalingClient.send(["type": "leave"])
        
        // Cleanup resources
        cleanup()
    }

    private func cleanup() {
        webRTCClient?.close()
        webRTCClient = nil
        
        signalingClient.disconnect()
        audioSessionManager.deactivateSession()
        
        isConnecting = false
        isRemoteDescriptionSet = false
        pendingICECandidates.removeAll()
        
        isInCall = false
        _connectionState = .idle
        objectWillChange.send() // Force UI update
        
        // Trigger summary if we actually had a conversation
        if !lastCallPartnerId.isEmpty {
            showCallSummary = true
        }
    }
    
    private func resetState(keepUI: Bool = false) {
        if !keepUI {
            isInCall = false
            _connectionState = .idle
            showCallSummary = false
            objectWillChange.send() // Force UI update
        }
        isRemoteDescriptionSet = false
        pendingICECandidates.removeAll()
        isConnecting = false
    }

    // MARK: - Signaling Handling

    private func handleSignalingMessage(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { return }

        switch type {
        case "matched":
            handleMatched(json)
        case "offer":
            handleOffer(json)
        case "answer":
            handleAnswer(json)
        case "candidate":
            handleRemoteCandidate(json)
        case "leave":
            log("Remote peer disconnected.")
            cleanup()
        default:
            break
        }
    }
    
    private func handleMatched(_ json: [String: Any]) {
        log("Match found.")
        guard let role = json["role"] as? String else { return }
        
        // Extract partner ID
        if let partnerId = json["partnerId"] as? String ?? json["partner_id"] as? String ?? json["from"] as? String {
            self.lastCallPartnerId = partnerId
            log("Partner ID: \(partnerId)")
        }

        _connectionState = .connecting
        objectWillChange.send() // Force UI update

        if role == "caller" {
            webRTCClient?.createOffer { [weak self] offer in
                self?.signalingClient.sendSDP(type: "offer", sdp: offer.sdp)
                self?.log("Sent Offer")
            }
        }
    }
    
    private func handleOffer(_ json: [String: Any]) {
        guard let sdp = json["sdp"] as? String else { return }
        log("Received Offer")
        
        webRTCClient?.setRemote(RTCSessionDescription(type: .offer, sdp: sdp))
        isRemoteDescriptionSet = true
        flushICECandidates()
        
        webRTCClient?.createAnswer { [weak self] answer in
            self?.signalingClient.sendSDP(type: "answer", sdp: answer.sdp)
            self?.flushICECandidates() // Important: flush after local desc is ready
            self?.log("Sent Answer")
            self?.transitionToConnected()
        }
    }
    
    private func handleAnswer(_ json: [String: Any]) {
        guard let sdp = json["sdp"] as? String else { return }
        log("Received Answer")
        
        webRTCClient?.setRemote(RTCSessionDescription(type: .answer, sdp: sdp))
        isRemoteDescriptionSet = true
        flushICECandidates()
        transitionToConnected()
    }
    
    private func handleRemoteCandidate(_ json: [String: Any]) {
        guard let sdp = json["candidate"] as? String,
              let sdpMLineIndex = json["sdpMLineIndex"] as? Int32 else { return }
        
        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: json["sdpMid"] as? String)
        webRTCClient?.addCandidate(candidate)
        log("Added Remote ICE Candidate")
    }
    
    private func transitionToConnected() {
        Task { @MainActor in
            self.isInCall = true
            self._connectionState = .connected
            self.objectWillChange.send() // Force UI update
            self.webRTCClient?.startAudioMonitoring()
        }
    }

    // MARK: - ICE Handling
    
    private func setupWebRTCCallbacks() {
        webRTCClient?.onIceCandidate = { [weak self] candidate in
            guard let self = self else { return }
            
            if self.isRemoteDescriptionSet {
                self.signalingClient.sendCandidate(sdp: candidate.sdp, sdpMid: candidate.sdpMid, sdpMLineIndex: candidate.sdpMLineIndex)
            } else {
                self.pendingICECandidates.append(candidate)
            }
        }
        
        webRTCClient?.onLocalAudioLevel = { [weak self] level in
            // Must be on main thread
            Task { @MainActor in
                self?.currentMicVolume = level
            }
        }
    }
    
    private func flushICECandidates() {
        guard !pendingICECandidates.isEmpty else { return }
        for candidate in pendingICECandidates {
            signalingClient.sendCandidate(sdp: candidate.sdp, sdpMid: candidate.sdpMid, sdpMLineIndex: candidate.sdpMLineIndex)
        }
        pendingICECandidates.removeAll()
    }
    
    // MARK: - Helpers
    
    private func log(_ message: String) {
        print("[WebRTCManager] \(message)")
        debugLog += "• \(message)\n"
    }
}

// MARK: - UI Enums

enum ConnectionState: String {
    case idle = "Idle"
    case searching = "Searching"
    case connecting = "Connecting"
    case connected = "Connected"
    case disconnected = "Disconnected"
}
