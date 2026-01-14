
import WebRTC
import AVFoundation

final class WebRTCClient: NSObject {

    // MARK: - Properties
    
    private let factory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    
    // Public for potential UI/Debug usage
    var localAudioTrack: RTCAudioTrack?
    
    // Callbacks
    var onIceCandidate: ((RTCIceCandidate) -> Void)?
    var onLocalAudioLevel: ((Double) -> Void)?
    
    // MARK: - Constants
    
    private let rtcConfig: RTCConfiguration = {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.relay.metered.ca:80"]),
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
        config.sdpSemantics = .unifiedPlan
        return config
    }()
    
    private let mediaConstraints = RTCMediaConstraints(
        mandatoryConstraints: nil,
        optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
    )

    // MARK: - Initialization
    
    override init() {
        self.factory = RTCPeerConnectionFactory()
        super.init()
        setupPeerConnection()
        setupLocalMedia()
    }
    
    deinit {
        close()
    }
    
    // MARK: - Setup
    
    private func setupPeerConnection() {
        self.peerConnection = factory.peerConnection(with: rtcConfig, constraints: mediaConstraints, delegate: self)
    }
    
    private func setupLocalMedia() {
        // Audio source and track
        // Constraints are nil to allow WebRTC/AudioSessionManager to dictate defaults
        let source = factory.audioSource(with: nil)
        let track = factory.audioTrack(with: source, trackId: "audio0")
        self.localAudioTrack = track
        
        let transceiverInit = RTCRtpTransceiverInit()
        transceiverInit.direction = .sendRecv
        transceiverInit.streamIds = ["stream0"]
        
        if let transceiver = peerConnection?.addTransceiver(with: track, init: transceiverInit) {
            transceiver.setDirection(.sendRecv, error: nil)
        }
        
        print("[WebRTCClient] Local audio track setup complete.")
    }
    
    func setMuted(_ muted: Bool) {
        localAudioTrack?.isEnabled = !muted
    }
    
    // MARK: - Signaling
    
    func createOffer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "false"
            ],
            optionalConstraints: nil
        )
        
        peerConnection?.offer(for: constraints) { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else {
                print("[WebRTCClient] Failed to create offer: \(String(describing: error))")
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }
    
    func createAnswer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": "false"
            ],
            optionalConstraints: nil
        )
        
        peerConnection?.answer(for: constraints) { [weak self] sdp, error in
            guard let self = self, let sdp = sdp else {
                 print("[WebRTCClient] Failed to create answer: \(String(describing: error))")
                return
            }
            
            self.peerConnection?.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }
    
    func setRemote(_ sdp: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(sdp) { error in
            if let error = error {
                 print("[WebRTCClient] Failed to set remote description: \(error)")
            }
        }
    }
    
    func addCandidate(_ candidate: RTCIceCandidate) {
        peerConnection?.add(candidate)
    }
    
    // MARK: - Stats
    
    func startAudioMonitoring() {
        // Monitor stats locally if needed
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self, let peer = self.peerConnection else {
                timer.invalidate()
                return
            }
            
            peer.statistics { report in
                for (_, stats) in report.statistics {
                     if stats.type == "media-source",
                        stats.values["kind"] as? String == "audio",
                        let level = stats.values["audioLevel"] as? Double {
                         DispatchQueue.main.async {
                             self.onLocalAudioLevel?(level)
                         }
                     }
                }
            }
        }
    }
    
    // MARK: - Teardown
    
    func close() {
        localAudioTrack?.isEnabled = false
        localAudioTrack = nil
        
        peerConnection?.close()
        peerConnection = nil
    }
}

// MARK: - RTCPeerConnectionDelegate

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        onIceCandidate?(candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("[WebRTCClient] ICE State: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver) {
        if transceiver.mediaType == .audio {
            transceiver.receiver.track?.isEnabled = true
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
