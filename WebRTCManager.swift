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
    private var rtc: WebRTCClient?

    private let signaling = SignalingClient()

    // MARK: - State
    private var isConnecting = false
    private var isRemoteDescriptionSet = false
    private var pendingICE: [RTCIceCandidate] = []
    
    private var canStartMatchmaking = true


    // MARK: - Init
    init() {
        AudioSessionManager.configure()
        log("Manager initialized")

        // ✅ ONLY signaling is safe here
        signaling.onmsg = handleSignal
    }

    // MARK: - Public API (UI calls)

    func startMatchmaking(userId: String) {
        guard !isConnecting, canStartMatchmaking else { return }

        canStartMatchmaking = false
        isConnecting = true

        resetState()

        // ✅ CREATE A NEW RTC INSTANCE PER CALL
        rtc = WebRTCClient()
        setupRTCCallbacks()

        connectionState = "Searching"
        log("Connecting signaling...")
        signaling.connect()
        signaling.join()
    }




    func disconnect() {
        guard isConnecting else { return }

        log("Ending call")
        signaling.send(["type": "end"])
        // ❌ DO NOT call cleanup here
    }

    func toggleMute(isMuted: Bool) {
        guard let rtc = rtc else {
            log("Mute ignored — RTC not ready")
            return
        }

        rtc.setMuted(isMuted)
        log(isMuted ? "Mic muted" : "Mic unmuted")
    }


    // MARK: - Signaling

    private func handleSignal(_ json: [String: Any]) {
        guard let type = json["type"] as? String else { return }

        switch type {

        case "matched":
            guard let rtc = rtc else {
                log("RTC not ready on matched")
                return
            }

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
            guard let rtc = rtc else {
                log("RTC missing on offer")
                return
            }

            log("Received offer")

            guard let sdpString = json["sdp"] as? String else { return }

            let sdp = RTCSessionDescription(
                type: .offer,
                sdp: sdpString
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
            guard let rtc = rtc else {
                log("RTC missing on answer")
                return
            }

            log("Received answer")

            guard let sdpString = json["sdp"] as? String else { return }

            let sdp = RTCSessionDescription(
                type: .answer,
                sdp: sdpString
            )

            rtc.setRemote(sdp)
            isRemoteDescriptionSet = true
            flushICE()

            connectionState = "Connected"

        case "candidate":
            guard let rtc = rtc else {
                log("RTC missing on candidate")
                return
            }

            guard
                let sdp = json["candidate"] as? String,
                let sdpMLineIndex = json["sdpMLineIndex"] as? Int32
            else { return }

            let candidate = RTCIceCandidate(
                sdp: sdp,
                sdpMLineIndex: sdpMLineIndex,
                sdpMid: json["sdpMid"] as? String
            )

            rtc.addCandidate(candidate)
            log("Added ICE")

        case "end":
            log("Remote ended call")
            cleanup()

        case "leave":
            log("Remote left")
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

    private func log(_ msg: String) {
        debugLog += "• \(msg)\n"
        print("[WebRTC]", msg)
    }
    
    private func cleanup() {
        isConnecting = false
        resetState()

        signaling.send(["type": "leave"])
        signaling.close()

        rtc?.close()
        rtc = nil   // 🔴 REQUIRED

        connectionState = "Disconnected"
        log("Call cleaned up")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.canStartMatchmaking = true
            self.log("Ready for match")
        }
    }


    
    // MARK: - RTCCallbacks
    
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
    }





}

