import SwiftUI

struct DebugAudioView: View {
    @ObservedObject var webRTC: WebRTCManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 0 = Live, 1 = Ended, 2 = Muted
            Text("Mic Track: \(webRTC.isLocalAudioTrackEnabled ? "ON" : "OFF")")
            Text("Mic State: \(webRTC.localAudioSourceState)") // 0=Live
            Text("Vol: \(String(format: "%.3f", webRTC.currentMicVolume))")
        }
        .font(.caption2)
        .padding(6)
        .background(Color.black.opacity(0))
        .foregroundColor(.green)
        .cornerRadius(8)
        .allowsHitTesting(false) // Don't block touches
    }
}
