import Foundation
import WebRTC
import AVFoundation
import Combine

@MainActor
final class WebRTCManager: ObservableObject {

    // MARK: - UI Bindings
    @Published var connectionState: String = "Idle"
    @Published var debugLog: String = ""

    // MARK: - Core
    private let rtc = WebRTCClient()
    private let signaling = SignalingClient()

    // MARK: - State
    private var isConnecting = false
    private var isRemoteDescriptionSet = false
    private var pendingICE: [RTCIceCandidate] = []

    // MARK: - Init
    init() {
        AudioSessionManager.configure()
        log("Manager initialized")

        rtc.onIceCandidate = { [weak self] candidate in
            guard let self else { return }

            if self.isRemoteDescriptionSet {
                self.sendICE(candidate)
            } else {
                self.pendingICE.append(candidate)
                self.log("Queued ICE")
            }
        }

        signaling.onMessage = handleSignal
    }

    // MARK: - Public API (UI calls)

    func startMatchmaking(userId: String) {
        guard !isConnecting else { return }
        isConnecting = true

        resetState()

        connectionState = "Searching"
        log("Connecting signaling…")

        signaling.connect()
        signaling.join()
    }

    func disconnect() {
        guard isConnecting else { return }

        log("Ending call")

        signaling.send([
            "type": "end"
        ])

        cleanup()
    }


    func toggleMute(isMuted: Bool) {
        rtc.setMuted(isMuted)
        log(isMuted ? "Mic muted" : "Mic unmuted")
    }

    // MARK: - Signaling

    private func handleSignal(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { return }

        switch type {

        case "matched":
            let role = json["role"] as? String ?? "callee"
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
            log("Received offer")

            let sdp = RTCSessionDescription(
                type: .offer,
                sdp: json["sdp"] as! String
            )

            rtc.setRemote(sdp)
            isRemoteDescriptionSet = true
            flushICE()

            rtc.createAnswer { answer in
                self.signaling.send([
                    "type": "answer",
                    "sdp": answer.sdp
                ])
                self.log("Sent answer")
                self.connectionState = "Connected"
            }

        case "answer":
            log("Received answer")

            let sdp = RTCSessionDescription(
                type: .answer,
                sdp: json["sdp"] as! String
            )

            rtc.setRemote(sdp)
            isRemoteDescriptionSet = true
            flushICE()

            connectionState = "Connected"

        case "candidate":
            let candidate = RTCIceCandidate(
                sdp: json["candidate"] as! String,
                sdpMLineIndex: json["sdpMLineIndex"] as! Int32,
                sdpMid: json["sdpMid"] as? String
            )
            rtc.addCandidate(candidate)
            log("Added ICE")
            
        case "end":
            log("Remote ended call")
            cleanup()


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
    
    

    // MARK: - Logging

    private func log(_ message: String) {
        debugLog += "• \(message)\n"
        print("[WebRTC]", message)
    }
    
    
    private func cleanup() {
        isConnecting = false
        isRemoteDescriptionSet = false
        pendingICE.removeAll()

        rtc.close()
        signaling.close()

        connectionState = "Disconnected"
        log("Call cleaned up")
    }

}

