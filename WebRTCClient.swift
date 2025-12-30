import WebRTC

final class WebRTCClient: NSObject {

    // MARK: - Core
    private let factory: RTCPeerConnectionFactory
    private var peer: RTCPeerConnection!
    private var audioTrack: RTCAudioTrack?

    // MARK: - Callbacks
    var onIceCandidate: ((RTCIceCandidate) -> Void)?

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
    private func setupAudio() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let source = factory.audioSource(with: constraints)
        let track = factory.audioTrack(with: source, trackId: "audio0")
        self.audioTrack = track
        
        // 🔥 Use Transceiver for robust bidirectional audio
        let initConfig = RTCRtpTransceiverInit()
        initConfig.direction = .sendRecv
        initConfig.streamIds = ["stream0"]
        
        if let transceiver = peer.addTransceiver(with: track, init: initConfig) {
            transceiver.setDirection(.sendRecv, error: nil)
            print("[WebRTCClient] Added Audio Transceiver with direction: sendRecv")
        } else {
            print("[WebRTCClient] ❌ FAILED to add Audio Transceiver")
        }
    }

    func setMuted(_ muted: Bool) {
        audioTrack?.isEnabled = !muted
    }

    // MARK: - SDP
    func createOffer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peer.offer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            print("[WebRTCClient] Generated Offer SDP: \n\(sdp.sdp)") // 🔥 DEBUG SDP
            self.peer.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func createAnswer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
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
    
    // MARK: - Cleanup
    
    func close() {
        audioTrack?.isEnabled = false
        audioTrack = nil
        
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

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didAdd stream: RTCMediaStream) {
        print("[WebRTCClient] Received Remote Stream: \(stream.streamId) with \(stream.audioTracks.count) audio tracks")
        stream.audioTracks.forEach { track in
            track.isEnabled = true
            print("[WebRTCClient] Forced Audio Track enabled: \(track.trackId)")
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove stream: RTCMediaStream) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {}

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {}
}
