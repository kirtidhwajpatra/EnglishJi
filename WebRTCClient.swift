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
        RTCInitializeSSL()
        self.factory = RTCPeerConnectionFactory()
        super.init()
        setupPeer()
        setupAudio()
    }

    // MARK: - Peer Setup
    private func setupPeer() {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])
        ]

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
        )

        peer = factory.peerConnection(
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
        peer.add(track, streamIds: ["stream0"])
    }

    func setMuted(_ muted: Bool) {
        audioTrack?.isEnabled = !muted
    }

    // MARK: - SDP
    func createOffer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peer.offer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            self.peer.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func createAnswer(completion: @escaping (RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peer.answer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            self.peer.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func setRemote(_ sdp: RTCSessionDescription) {
        peer.setRemoteDescription(sdp, completionHandler: { _ in })
    }

    // MARK: - ICE
    func addCandidate(_ candidate: RTCIceCandidate) {
        peer.add(candidate, completionHandler: { _ in })
    }
    
    func close() {
        audioTrack = nil
        peer.close()
    }

}

// MARK: - RTCPeerConnectionDelegate
extension WebRTCClient: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didGenerate candidate: RTCIceCandidate) {
        onIceCandidate?(candidate)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange stateChanged: RTCSignalingState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceConnectionState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didChange newState: RTCIceGatheringState) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didAdd stream: RTCMediaStream) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove stream: RTCMediaStream) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didRemove candidates: [RTCIceCandidate]) {}

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}

    func peerConnection(_ peerConnection: RTCPeerConnection,
                        didOpen dataChannel: RTCDataChannel) {}
}

