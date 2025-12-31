import WebRTC
import AVFoundation // 🔥 Required for AVAudioSession.Category

final class WebRTCClient: NSObject {

    // MARK: - Core
    private let factory: RTCPeerConnectionFactory
    private var peer: RTCPeerConnection!
    
    // 🔥 Public for Debug View
    var localAudioTrack: RTCAudioTrack? 

    // MARK: - Callbacks
    var onIceCandidate: ((RTCIceCandidate) -> Void)?
    var onLocalAudioLevel: ((Double) -> Void)? // 🔥 Callback for UI volume

    // MARK: - Init
    override init() {
        self.factory = RTCPeerConnectionFactory()
        super.init()
        setupPeer()
        setupAudio()
    }

    // MARK: - Peer Setup
    private func setupPeer() {
        let config = RTCConfiguration()

        config.iceServers = [
            RTCIceServer(urlStrings: [
                "stun:stun.relay.metered.ca:80"
            ]),

            RTCIceServer(
                urlStrings: [
                    "turn:global.relay.metered.ca:80",
                    "turn:global.relay.metered.ca:80?transport=tcp",
                    "turns:global.relay.metered.ca:443",
                    "turns:global.relay.metered.ca:443?transport=tcp"
                ],
                username: "36726cf73dbc7bf92d764894",
                credential: "+7YCgmTXnpk3IV7"
            )
        ]

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
        )

        self.peer = factory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
    }


    // MARK: - Audio
    // MARK: - Audio
    private func setupAudio() {
        // 🔥 USER REQUEST: HARDWARE-ALIGNED CONFIGURATION
        // This stops the Sample Rate Mismatch Crash (Mic State 1).
        
        let session = RTCAudioSession.sharedInstance()
        
        // 1. Disable Manual Audio (Let WebRTC Engine Drive)
        session.useManualAudio = false
        
        session.lockForConfiguration()
        
        // 2. Use the WebRTC C++ Configuration Helper
        let config = RTCAudioSessionConfiguration.webRTC()
        config.category = AVAudioSession.Category.playAndRecord.rawValue
        config.categoryOptions = [.allowBluetooth, .defaultToSpeaker, .allowBluetoothA2DP, .mixWithOthers] // Added mixWithOthers
        config.mode = AVAudioSession.Mode.videoChat.rawValue
        
        // 3. FORCE HARDWARE ALIGNMENT (The Fix for State 1)
        config.sampleRate = 48000.0 // Force Native 48k
        config.ioBufferDuration = 0.005 // Force Low Latency (5ms)
        
        do {
            try session.setConfiguration(config)
            // try session.setActive(true) // 🔥 REMOVED: Let WebRTC Activate it internally when track starts
            print("[WebRTCClient] ✅ Audio Session Configured (48kHz, 5ms, mixWithOthers)")
        } catch {
            print("[WebRTCClient] ❌ Audio Config Failed: \(error)")
        }
        session.unlockForConfiguration()
        
        // 4. Create Track with NIL constraints (Safe Mode)
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        
        let source = factory.audioSource(with: constraints)
        let track = factory.audioTrack(with: source, trackId: "audio0")
        self.localAudioTrack = track
        
        // 🔥 DEBUG: Track Liveness Check
        print("[WebRTCClient] 🎤 Local Track Created. Enabled: \(track.isEnabled), State: \(track.readyState.rawValue)")
        print("[WebRTCClient] 🎤 Source State: \(source.state.rawValue)") // 0=Live, 1=Ended, 2=Muted
        
        // 🔥 BRUTE FORCE TRANSCEIVER: Explicitly add with setDirection(.sendRecv)
        let initConfig = RTCRtpTransceiverInit()
        initConfig.direction = .sendRecv
        initConfig.streamIds = ["stream0"]
        
        if let transceiver = peer.addTransceiver(with: track, init: initConfig) {
            transceiver.setDirection(.sendRecv, error: nil)
            print("[WebRTCClient] ✅ Added Audio Transceiver & Forced .sendRecv")
        } else {
            print("[WebRTCClient] ❌ FAILED to add Audio Transceiver")
        }
    }

    func setMuted(_ muted: Bool) {
        localAudioTrack?.isEnabled = !muted
    }

    // MARK: - SDP
    func createOffer(completion: @escaping (RTCSessionDescription) -> Void) {
        // 🔥 FIX: Force SDP to include Audio Request
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "false" 
            ],
            optionalConstraints: nil
        )
        peer.offer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            
            // 🔥 BRUTE FORCE: Verify SDP contains direction
            if sdp.sdp.contains("a=sendrecv") {
                 print("[WebRTCClient] ✅ Offer SDP contains 'a=sendrecv'")
            } else {
                 print("[WebRTCClient] ⚠️ Offer SDP MISSING 'a=sendrecv'. Check Transceiver!")
            }
            // print("[WebRTCClient] Generated Offer SDP: \n\(sdp.sdp)") 
            
            self.peer.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }

    func createAnswer(completion: @escaping (RTCSessionDescription) -> Void) {
        // 🔥 FIX: Force SDP to include Audio Request
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "false"
            ],
            optionalConstraints: nil
        )
        peer.answer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            print("[WebRTCClient] Generated Answer SDP: \n\(sdp.sdp)") // 🔥 DEBUG SDP
            self.peer.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func setRemote(_ sdp: RTCSessionDescription) {
        peer.setRemoteDescription(sdp, completionHandler: { _ in })
    }

    // MARK: - ICE
    func addCandidate(_ candidate: RTCIceCandidate) {
        peer?.add(candidate)
    }
    
    // MARK: - Stats Monitoring (User Request)
    func startAudioMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.peer.statistics { report in
                for (id, stats) in report.statistics {
                    // 1. Mic Check (audioLevel)
                    if stats.type == "media-source" && stats.values["kind"] as? String == "audio" {
                        if let level = stats.values["audioLevel"] as? Double {
                            // print("🎤 [Stats] Mic Level: \(level)")
                            DispatchQueue.main.async {
                                self.onLocalAudioLevel?(level)
                            }
                        }
                    }
                    
                    // 2. Network Check (bytesSent)
                    if stats.type == "outbound-rtp" && stats.values["mediaType"] as? String == "audio" {
                         if let bytes = stats.values["bytesSent"] as? Int {
                             print("📡 [Stats] Bytes Sent: \(bytes)")
                         }
                    }
                    
                    // 3. Connection Check (RTT)
                    if stats.type == "candidate-pair" && stats.values["state"] as? String == "succeeded" {
                        if let rtt = stats.values["currentRoundTripTime"] as? Double {
                            print("📶 [Stats] RTT: \(rtt * 1000) ms")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    func close() {
        localAudioTrack?.isEnabled = false
        localAudioTrack = nil
        
        peer?.close()
        peer = nil
        
        print("[WebRTCClient] Resources freed")
    }

}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClient: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didGenerate candidate: RTCIceCandidate) {
        onIceCandidate?(candidate)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange stateChanged: RTCSignalingState) {
        // print("Signaling State: \(stateChanged.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceConnectionState) {
         print("[WebRTCClient] ICE Connection State: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceGatheringState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("[WebRTCClient] Received Remote Stream: \(stream.streamId)") 
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("[WebRTCClient] Removed Remote Stream")
    }
    
    // 🔥 FIX: Unified Plan Transceiver Delegate
    // This is the MODERN way to handle incoming tracks.
    func peerConnection(_ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver) {
        print("[WebRTCClient] Transceiver started receiving: \(transceiver.mediaType == .audio ? "Audio" : "Video")")
        
        if transceiver.mediaType == .audio {
             // Force the remote track to be enabled
             transceiver.receiver.track?.isEnabled = true
             print("[WebRTCClient] 🔥 FORCE_ENABLED Remote Audio Track")
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {}

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {}
}
