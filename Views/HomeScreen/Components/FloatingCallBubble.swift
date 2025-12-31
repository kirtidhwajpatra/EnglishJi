import SwiftUI

struct FloatingCallBubble: View {
    
    // MARK: - Data Dependencies
    @ObservedObject var webRTCManager: WebRTCManager
    var callDuration: String
    var onMaximize: () -> Void
    
    // MARK: - Drag State
    // 'offset' is the active drag distance
    // 'lastOffset' is the saved position where the bubble was dropped
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = CGSize(
        width: UIScreen.main.bounds.width - 120, // Default start X (Right side)
        height: UIScreen.main.bounds.height - 250 // Default start Y (Bottom area)
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Background Circle
                Circle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15)) // Dark Grey #262626
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .frame(width: 90, height: 90)
                    // Add a subtle pulse if the user is speaking (optional polish)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.5), lineWidth: webRTCManager.currentMicVolume > 0.05 ? 2 : 0)
                            .animation(.easeInOut, value: webRTCManager.currentMicVolume)
                    )

                VStack(spacing: 4) {
                    // 2. Timer
                    Text(callDuration)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    // 3. Mini Waveform
                    // We reuse the WaveformShape (defined in CallInProgressView.swift)
                    TimelineView(.animation) { context in
                        let time = context.date.timeIntervalSinceReferenceDate
                        let phase = CGFloat(time * 0.8)
                        
                        WaveformShape(phase: phase, amplitude: 1.0)
                            .stroke(
                                Color.white.opacity(0.8),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                            )
                            .frame(width: 50, height: 8)
                    }
                }
            }
            // Center the content within the 90x90 frame
            .frame(width: 90, height: 90)
            
            // Apply the drag offset
            .position(x: 45, y: 45) // Local centering
            .offset(x: lastOffset.width + offset.width, y: lastOffset.height + offset.height)
            
            // MARK: - Gestures
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update position while dragging
                        offset = value.translation
                    }
                    .onEnded { value in
                        // Calculate final position
                        var newX = lastOffset.width + value.translation.width
                        var newY = lastOffset.height + value.translation.height
                        
                        // Boundary Checks: Keep bubble inside the screen
                        let safePadding: CGFloat = 20
                        let bubbleSize: CGFloat = 90
                        
                        // Clamp X
                        newX = min(max(safePadding, newX), geometry.size.width - bubbleSize - safePadding)
                        // Clamp Y
                        newY = min(max(safePadding + 40, newY), geometry.size.height - bubbleSize - safePadding)
                        
                        // Animation snap to final position
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            lastOffset = CGSize(width: newX, height: newY)
                            offset = .zero
                        }
                    }
            )
            .onTapGesture {
                // Return to full screen
                onMaximize()
            }
        }
        // Important: Ignore safe area so it can float over tab bars/nav bars
        .ignoresSafeArea()
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        FloatingCallBubble(
            webRTCManager: WebRTCManager(),
            callDuration: "12:45",
            onMaximize: { print("Maximize tapped") }
        )
    }
}
