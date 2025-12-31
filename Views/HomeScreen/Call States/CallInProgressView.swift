import SwiftUI

struct CallInProgressView: View {

    @ObservedObject var webRTCManager: WebRTCManager
    
    // Data passed from RootView
    var callDuration: String
    
    // Actions passed from RootView
    var onMinimize: () -> Void
    var onEndCall: () -> Void

    // Local UI State
    @State private var isMuted = false
    @State private var isSpeakerOn = false
    
    // Configuration
    let partnerName: String = "Veena Singh"
    let partnerLocation: String = "Delhi, India"
    let partnerImageURL: String = "https://i.pravatar.cc/300?img=5"

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. Background
            Color.white.ignoresSafeArea()
            
            // 2. Content
            VStack(spacing: 0) {
                
                // --- Top Header (Minimize Button) ---
                HStack {
                    Button(action: onMinimize) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 60) // Adjust for Safe Area
                .padding(.leading, 24)
                
                Spacer().frame(height: 40)

                // --- 3. Avatar Section ---
                ZStack {
                    // Outer Glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)
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
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30)

                // --- 4. Info Section ---
                Text(partnerName)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.bottom, 8)

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(partnerLocation)
                        .font(.body)
                        .foregroundColor(.gray)
                }

                Spacer()

                // --- 5. Timer & Waveform Section ---
                VStack(spacing: 25) {
                    // Timer (Data from RootView)
                    Text(callDuration)
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.8))
                        .monospacedDigit()

                    // Controls Row
                    HStack(spacing: 30) {
                        // Mute Button
                        Button {
                            toggleMute()
                        } label: {
                            Circle()
                                .fill(isMuted ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                        .font(.title3)
                                        .foregroundColor(isMuted ? .red : .black)
                                )
                        }

                        // 🔥 Animated Waveform
                        TimelineView(.animation) { context in
                            let time = context.date.timeIntervalSinceReferenceDate
                            let phase = CGFloat(time * 0.8) // Gentle drift speed
                            
                            WaveformShape(
                                phase: phase,
                                amplitude: isMuted ? 0.0 : 1.0
                            )
                            .stroke(
                                Color(red: 0.2, green: 0.2, blue: 0.2),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                            .frame(width: 100, height: 16)
                            .animation(.easeInOut(duration: 0.6), value: isMuted)
                        }

                        // Speaker Button
                        Button {
                            toggleSpeaker()
                        } label: {
                            Circle()
                                .fill(isSpeakerOn ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.wave.3.fill")
                                        .font(.title3)
                                        .foregroundColor(isSpeakerOn ? .blue : .black)
                                )
                        }
                    }
                }
                .padding(.bottom, 50)

                // --- 6. End Call Button ---
                Button {
                    onEndCall()
                } label: {
                    Text("End Call")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(Color(red: 235/255, green: 85/255, blue: 85/255))
                        .cornerRadius(32.5)
                        .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Local Actions
    private func toggleMute() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        isMuted.toggle()
        webRTCManager.toggleMute(isMuted: isMuted)
    }

    private func toggleSpeaker() {
        isSpeakerOn.toggle()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        // Toggle logic here
    }
}

// MARK: - Waveform Shape Definition
// Keeping it here allows CallInProgressView and FloatingCallBubble (if in same file) to share it.
// If FloatingCallBubble is in a separate file, this needs to be public or in its own file.
struct WaveformShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat

    var animatableData: CGFloat {
        get { amplitude }
        set { amplitude = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2

        let xStep: CGFloat = 1
        let frequency = (CGFloat.pi * 2 * 4) / width // ~4 peaks
        let maxWaveHeight = height * 0.45

        for x in stride(from: 0, through: width, by: xStep) {
            let relativeX = x / width
            
            // Base sine wave
            let baseWave = sin(x * frequency - phase)
            
            // Hanning Window (tapers edges)
            let envelope = 0.5 * (1 - cos(2 * CGFloat.pi * relativeX))
            
            let waveY = baseWave * envelope * maxWaveHeight * amplitude
            let y = midY - waveY

            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

#Preview {
    CallInProgressView(
        webRTCManager: WebRTCManager(),
        callDuration: "03:45",
        onMinimize: {},
        onEndCall: {}
    )
}
