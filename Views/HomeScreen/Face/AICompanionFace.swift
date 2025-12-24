import SwiftUI
import Combine

// MARK: - 1. STATES
enum AIState {
    case idle       // Casual looking around
    case searching  // Rapid scanning + Rotating ring
    case connected  // Happy / Success
}

// MARK: - 2. MAIN COMPONENT
struct AICompanionFace: View {
    @Binding var state: AIState
    
    // Animation States
    @State private var lookOffset: CGSize = .zero
    @State private var isBlinking = false
    @State private var scannerRotation = 0.0
    
    // Timers
    let lookTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    let blinkTimer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()
    
    // Theme Colors
    let faceColor = Color(red: 0.22, green: 0.08, blue: 0.55) // Deep Purple Brand
    
    var body: some View {
        ZStack {
            // 1. SCANNER RING (Only in Searching Mode)
            if state == .searching {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.cyan, .purple, .clear]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(scannerRotation))
                    .onAppear {
                        // 🔥 FIX: Always reset to 0 before starting animation
                        scannerRotation = 0
                        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                            scannerRotation = 360
                        }
                    }
            }
            
            // 2. THE FACE BASE (Head)
            Circle()
                .fill(faceColor)
                .frame(width: 110, height: 110)
                .shadow(color: faceColor.opacity(0.4), radius: 10, y: 5)
            
            // 3. THE EYES CONTAINER
            HStack(spacing: 8) {
                SmoothEyeView(
                    lookOffset: lookOffset,
                    isBlinking: isBlinking,
                    isHappy: state == .connected
                )
                
                SmoothEyeView(
                    lookOffset: lookOffset,
                    isBlinking: isBlinking,
                    isHappy: state == .connected
                )
            }
        }
        // MARK: - BEHAVIOR LOGIC
        .onReceive(lookTimer) { _ in
            performLookBehavior()
        }
        .onReceive(blinkTimer) { _ in
            performBlink()
        }
        .onChange(of: state) { newState in
            // 1. If we stop searching, RESET the rotation so it's ready for next time
            if newState != .searching {
                scannerRotation = 0
            }
            
            // 2. If connected, center the eyes
            if newState == .connected {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    lookOffset = .zero
                }
            }
        }
    }
    
    // MARK: - LOGIC FUNCTIONS
    
    func performLookBehavior() {
        guard state != .connected else { return }
        
        // Dynamic Timing: Searching is faster/jittery, Idle is lazy/smooth
        let isSearching = state == .searching
        let range: CGFloat = isSearching ? 18 : 10
        
        // Random Coordinate within the eye range
        let x = CGFloat.random(in: -range...range)
        let y = CGFloat.random(in: -range...range)
        
        let animation: Animation = isSearching
            ? .interpolatingSpring(stiffness: 170, damping: 15) // Snappy/Alert
            : .interpolatingSpring(stiffness: 50, damping: 10)  // Lazy/Gooey
            
        withAnimation(animation) {
            lookOffset = CGSize(width: x, height: y)
        }
        
        // Occasional "Double Take"
        if Bool.random() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let x2 = CGFloat.random(in: -range...range)
                withAnimation(animation) {
                    lookOffset = CGSize(width: x2, height: y)
                }
            }
        }
    }
    
    func performBlink() {
        guard state != .connected else { return }
        
        withAnimation(.easeOut(duration: 0.1)) {
            isBlinking = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                isBlinking = false
            }
        }
    }
}

// MARK: - 3. SMOOTH EYE SUB-COMPONENT
struct SmoothEyeView: View {
    var lookOffset: CGSize
    var isBlinking: Bool
    var isHappy: Bool
    
    var body: some View {
        ZStack {
            // 1. SCLERA (White Part)
            Circle()
                .fill(Color.white)
                .frame(width: 38, height: 38)
                .scaleEffect(y: isHappy ? 0.0 : 1.0)
            
            // 2. HAPPY ARC
            if isHappy {
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 25, height: 25)
                    .rotationEffect(.degrees(180))
                    .offset(y: 5)
            } else {
                // 3. PUPIL GROUP
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 14, height: 14)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 5, height: 5)
                        .offset(x: -3, y: -3)
                }
                .offset(lookOffset)
                .mask(
                    Circle().frame(width: 38, height: 38)
                )
            }
        }
        .scaleEffect(x: isBlinking ? 1.1 : 1.0, y: isBlinking ? 0.1 : 1.0)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AICompanionFace(state: .constant(.searching))
            .scaleEffect(2)
    }
}
