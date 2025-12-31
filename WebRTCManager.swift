import Foundation
import WebRTC
import AVFoundation
import Combine

@MainActor
final class WebRTCManager: NSObject, ObservableObject {

    // MARK: - UI State (THIS DRIVES SCREENS)
    @Published var isInCall: Bool = false
    @Published var connectionState: String = "Idle"
    @Published var debugLog: String = ""
    @Published var showCallSummary: Bool = false
    
    // 🔥 DEBUG AUDIO STATS
    @Published var currentMicVolume: Double = 0.0
    
    // Public Accessor for Debug View (Refactored to primitives to avoid Import issues in View)
    var isLocalAudioTrackEnabled: Bool {
        return rtc?.localAudioTrack?.isEnabled ?? false
    }
    
    var localAudioSourceState: Int {
        // 0=Live, 1=Ended, 2=Muted
        return rtc?.localAudioTrack?.source.state.rawValue ?? -1
    }
    
    // Derived partner ID for the demo (in real app, simpler to store from signaling)
    @Published var lastCallPartnerId: String = "" // 🔥 Actual Partner ID

    // MARK: - Core
    private var rtc: WebRTCClient?
    private let signaling = SignalingClient()

    // MARK: - State
    private var isConnecting = false
    private var isRemoteDescriptionSet = false
    private var pendingICE: [RTCIceCandidate] = []
    private var canStartMatchmaking = true
    var myUserId: String = "" // Store my ID (Public for CallSummaryView)

    // MARK: - Init
    override init() {
        super.init()
        log("Manager init start (Global Init Mode)")
        
        // 🔥 USER REQUEST: HARDWARE-ALIGNED MODE
        // WebRTCClient now handles all audio setup with specific 48kHz config.
        // We do nothing here to avoid conflicts.
        // let session = RTCAudioSession.sharedInstance()
        // session.useManualAudio = false // Default
        
        signaling.onMessage = handleSignal
        
        // Monitor for interruptions
        RTCAudioSession.sharedInstance().add(self)
        
        log("Manager init complete (Waiting for Signaling)")
    }

    private func onConnected() {
        // 🔥 Connection established. 
        // We rely on AudioSessionManager's ".defaultToSpeaker" config now.
        log("WebRTC Connected - Flushing any final ICE")
        flushICE()
    }

    // MARK: - Public API (UI)

    func startMatchmaking(userId: String) {
        // 🔥 FIX: Check State Synchronously to prevent Double-Tap Race Condition
        guard !isConnecting, canStartMatchmaking else {
            print("⚠️ WebRTCManager: Matchmaking ignored (Already connecting)")
            return
        }
        
        // Lock immediately
        self.canStartMatchmaking = false
        self.isConnecting = true
        self.myUserId = userId

        // 🔥 USER REQUEST: Explicit Recursive Permission Check
        let permission = AVAudioSession.sharedInstance().recordPermission
        if permission != .granted {
            print("⚠️ WebRTCManager: Permission not granted yet. Requesting...")
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                         // Recursive call? No, just continue logic or reset and recall.
                         // Better: Just continue setup since we are on Main Thread now.
                         self.continueMatchmaking(userId: userId)
                    } else {
                        print("❌ WebRTCManager: Microphone permission DENIED.")
                        // Unlock state
                        self.isConnecting = false
                        self.canStartMatchmaking = true
                    }
                }
            }
            return
        }
        
        // Proceed if granted
        DispatchQueue.main.async {
            self.continueMatchmaking(userId: userId)
        }
    }
    
    private func continueMatchmaking(userId: String) {
        self.resetState()

        // 🔥 2. Ensure Audio is Configured & Active
        // Self.activateAudioSession() // Already active from Init, but good to ensure
        
        self.rtc = WebRTCClient()
        self.setupRTCCallbacks()

        self.connectionState = "Searching"
        self.log("Connecting signaling...")
        self.signaling.connect()
        // 🔥 Send User ID in Join Payload
        self.signaling.join(userId: userId)
    }

    /// Used by End button OR when screen is dismissed
    func disconnect() {
        guard isConnecting else { return }
        endCall()
    }

    /// LOCAL hang-up
    func endCall() {
        guard isConnecting else { return }

        log("Local user ended call")

        // 1️⃣ Notify remote
        signaling.send(["type": "leave"])

        // 2️⃣ Allow async WebSocket send to flush
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.endCallAndResetUI()
        }
    }

    func toggleMute(isMuted: Bool) {
        guard let rtc else { return }
        rtc.setMuted(isMuted)
        log(isMuted ? "Mic muted" : "Mic unmuted")
    }

    // MARK: - Signaling

    private func handleSignal(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { return }

        switch type {

        case "matched":
            guard let rtc else { return }

            let role = json["role"] as? String ?? "callee"
            
            // 🔥 Capture Partner ID (Check multiple keys)
            if let partnerId = json["partnerId"] as? String ?? json["partner_id"] as? String ?? json["from"] as? String {
                self.lastCallPartnerId = partnerId
                log("Partner ID: \(partnerId)")
                print("🤝 WebRTCManager: MATCHED with Partner: \(partnerId)")
            } else {
                // It's okay if missing, server handles routing
                print("⚠️ WebRTCManager: Matched (No explicit partnerId in payload)")
            }
            
            log("Matched as \(role)")
            connectionState = "Connecting"

            if role == "caller" {
                rtc.createOffer { offer in
                    self.signaling.send([
                        "type": "offer",
                        "sdp": offer.sdp
                    ])
                    self.log("Sent offer")
                }
            }

        case "offer":
            guard let rtc,
                  let sdpString = json["sdp"] as? String else { return }

            log("Received offer")

            rtc.setRemote(
                RTCSessionDescription(type: .offer, sdp: sdpString)
            )

            isRemoteDescriptionSet = true
            flushICE()

            rtc.createAnswer { answer in
                self.signaling.send([
                    "type": "answer",
                    "sdp": answer.sdp
                ])
                
                // 🔥 FIX: Flush any pending ICE candidates NOW that we have a local description
                self.flushICE()
                
                self.log("Sent answer")

                DispatchQueue.main.async {
                    self.isInCall = true          // 🔥 UI OPENS HERE
                    self.connectionState = "Connected"
                    self.rtc?.startAudioMonitoring() // 🔥 Start Stats
                }
            }

        case "answer":
            guard let rtc,
                  let sdpString = json["sdp"] as? String else { return }

            log("Received answer")

            rtc.setRemote(
                RTCSessionDescription(type: .answer, sdp: sdpString)
            )

            isRemoteDescriptionSet = true
            flushICE()

            DispatchQueue.main.async {
                self.isInCall = true                 // 🔥 UI OPENS HERE
                self.connectionState = "Connected"
                self.rtc?.startAudioMonitoring() // 🔥 Start Stats
            }

        case "candidate":
            guard let rtc,
                  let sdp = json["candidate"] as? String,
                  let index = json["sdpMLineIndex"] as? Int32 else { return }

            let candidate = RTCIceCandidate(
                sdp: sdp,
                sdpMLineIndex: index,
                sdpMid: json["sdpMid"] as? String
            )

            rtc.addCandidate(candidate)
            log("Added ICE")

        case "leave":
            log("Remote ended call")
            endCallAndResetUI()              // 🔥 UI CLOSES HERE

        default:
            break
        }
    }

    // MARK: - ICE

    private func sendICE(_ candidate: RTCIceCandidate) {
        signaling.send([
            "type": "candidate",
            "candidate": candidate.sdp,
            "sdpMid": candidate.sdpMid ?? "",
            "sdpMLineIndex": candidate.sdpMLineIndex
        ])
        log("Sent ICE")
    }

    private func flushICE() {
        guard !pendingICE.isEmpty else { return }
        pendingICE.forEach { sendICE($0) }
        pendingICE.removeAll()
        log("Flushed ICE")
    }

    // MARK: - Reset

    private func resetState() {
        isRemoteDescriptionSet = false
        pendingICE.removeAll()
    }

    // MARK: - FINAL CLEANUP (NO SIGNALING HERE)

    // MARK: - FINAL CLEANUP (NO SIGNALING HERE)

    private func endCallAndResetUI() {
        log("Cleaning up call state")

        rtc?.close()
        rtc = nil
        
        // 🔥 Clean up socket
        signaling.close()

        isConnecting = false
        isRemoteDescriptionSet = false
        pendingICE.removeAll()
        


        isInCall = false                   // 🔥 UI CLOSES
        connectionState = "Idle"
        canStartMatchmaking = true
        
        // 🔥 Trigger Call Summary ONLY if we had a partner
        if !lastCallPartnerId.isEmpty {
            showCallSummary = true
        } else {
             showCallSummary = false
        }
    }

    // MARK: - RTC Callbacks

    private func setupRTCCallbacks() {
        rtc?.onIceCandidate = { [weak self] candidate in
            guard let self else { return }

            if self.isRemoteDescriptionSet {
                self.sendICE(candidate)
            } else {
                self.pendingICE.append(candidate)
                self.log("Queued ICE")
            }
        }
        
        rtc?.onLocalAudioLevel = { [weak self] level in
            self?.currentMicVolume = level
        }
    }

    // MARK: - Logging

    private func log(_ msg: String) {
        DispatchQueue.main.async {
            self.debugLog += "• \(msg)\n"
            print("[WebRTC]", msg)
        }
    }
}

// MARK: - Audio Session Delegate
// MARK: - Audio Session Delegate
extension WebRTCManager: RTCAudioSessionDelegate {
    
    func audioSessionDidStartPlayOrRecord(_ session: RTCAudioSession) {
        log("RTCAudioSession DidStartPlayOrRecord - Re-applying Config")
        // 🔥 FIX: Dispatch async to avoid deadlocking with WebRTC's internal lock
        // DispatchQueue.main.async {
        //     AudioSessionManager.configure() // DELETED: Global Init handles this now
        // }
    }
    
    func audioSessionDidStopPlayOrRecord(_ session: RTCAudioSession) {
        log("RTCAudioSession DidStop")
    }
}
