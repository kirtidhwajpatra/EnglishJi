import Foundation
import WebRTC
import AVFoundation
import Combine

@MainActor
final class WebRTCManager: ObservableObject {

    // MARK: - UI State (THIS DRIVES SCREENS)
    @Published var isInCall: Bool = false
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

        signaling.onMessage = handleSignal
    }

    // MARK: - Public API (UI)

    func startMatchmaking(userId: String) {
        guard !isConnecting, canStartMatchmaking else { return }

        canStartMatchmaking = false
        isConnecting = true
        resetState()

        rtc = WebRTCClient()
        setupRTCCallbacks()

        connectionState = "Searching"
        log("Connecting signaling...")
        signaling.connect()
        signaling.join()
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
                self.log("Sent answer")

                self.isInCall = true          // 🔥 UI OPENS HERE
                self.connectionState = "Connected"
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

            isInCall = true                 // 🔥 UI OPENS HERE
            connectionState = "Connected"

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

    private func endCallAndResetUI() {
        log("Cleaning up call state")

        rtc?.close()
        rtc = nil

        isConnecting = false
        isRemoteDescriptionSet = false
        pendingICE.removeAll()

        isInCall = false                   // 🔥 UI CLOSES
        connectionState = "Idle"
        canStartMatchmaking = true
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
    }

    // MARK: - Logging

    private func log(_ msg: String) {
        debugLog += "• \(msg)\n"
        print("[WebRTC]", msg)
    }
}

