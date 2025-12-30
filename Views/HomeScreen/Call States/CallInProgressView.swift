import SwiftUI

struct CallInProgressView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    // MARK: - State
    @State private var isMuted = false
    @State private var callDurationSeconds = 0
    @State private var timer: Timer?
    @State private var isSpeakerOn = false // Added state for speaker UI toggle

    // MARK: - Configuration (Replace with dynamic data if needed)
    let partnerName: String = "Veena Singh"
    let partnerLocation: String = "Delhi, India"
    let partnerImageURL: String = "https://i.pravatar.cc/300?img=5" // Using a closer match to reference

    var body: some View {
        ZStack {
            // 1. Background (Pure White as per reference)
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                
                // --- Top Spacer ---
                Spacer().frame(height: 80)

                // --- 2. Avatar Section ---
                ZStack {
                    // Subtle Glow Effect behind avatar
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    // Profile Image
                    AsyncImage(url: URL(string: partnerImageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.gray.opacity(0.1)
                        }
                    }
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    // Optional: Inner border if needed
                    .overlay(Circle().stroke(Color.white, lineWidth: 0))
                }
                .padding(.bottom, 25)

                // --- 3. Info Section ---
                Text(partnerName)
                    .font(.system(size: 32, weight: .regular)) // Clean, large font
                    .foregroundColor(.black)
                    .padding(.bottom, 8)

                HStack(spacing: 6) {
                    Image(systemName: "location.fill") // Or "paperplane.fill" icon
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(partnerLocation)
                        .font(.body)
                        .foregroundColor(.gray)
                }

                // --- Spacer to push controls to bottom ---
                Spacer()

                // --- 4. Timer & Waveform Section ---
                VStack(spacing: 15) {
                    // Timer
                    Text(formattedDuration)
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .monospacedDigit()

                    // Waveform Row
                    HStack(spacing: 30) {
                        // Mute Button (Left)
                        Button {
                            toggleMute()
                        } label: {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundColor(isMuted ? .red : .gray)
                                .frame(width: 44, height: 44)
                        }

                        // Static Waveform Visual (Matches reference style)
                        WaveformShape()
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 120, height: 20)

                        // Speaker Button (Right)
                        Button {
                            toggleSpeaker()
                        } label: {
                            Image(systemName: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.wave.3.fill")
                                .font(.title2)
                                .foregroundColor(isSpeakerOn ? .blue : .black) // Blue when active
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .padding(.bottom, 40)

                // --- 5. End Call Button ---
                Button {
                    endCall()
                } label: {
                    Text("End Call")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 235/255, green: 85/255, blue: 85/255)) // Custom Coral Red
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40) // Bottom safe area padding
            }
        }
        // Force Light Mode to match reference exactly
        .preferredColorScheme(.light)
        .onAppear {
//            // 1. Configure Audio FIRST
//            AudioManager.shared.configureAudioSession()
            
            // 2. Then start your timer
            startTimer()
        }
        .onDisappear { stopTimer() }
    }

    // MARK: - Logic Helpers

    private var formattedDuration: String {
        let m = callDurationSeconds / 60
        let s = callDurationSeconds % 60
        return String(format: "%d:%02d", m, s) // e.g., 3:25
    }

    private func startTimer() {
        // Prevent duplicate timers
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            callDurationSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func toggleMute() {
        isMuted.toggle()
        webRTCManager.toggleMute(isMuted: isMuted)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func toggleSpeaker() {
        isSpeakerOn.toggle()
        // Add your WebRTC speaker toggle logic here if available
        // webRTCManager.toggleSpeaker(...)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func endCall() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        stopTimer()
        webRTCManager.disconnect()
    }
}

// MARK: - Custom Waveform Shape
struct WaveformShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Simple squiggly line logic to match the visual reference
        let midHeight = rect.height / 2
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // Draw a simple bezier wave
        path.addCurve(
            to: CGPoint(x: width, y: midHeight),
            control1: CGPoint(x: width * 0.25, y: midHeight - 15),
            control2: CGPoint(x: width * 0.75, y: midHeight + 15)
        )
        
        return path
    }
}
