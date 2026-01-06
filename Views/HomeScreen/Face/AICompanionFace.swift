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
                    // Increased frame slightly to clear the new star shape
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(scannerRotation))
                    .onAppear {
                        scannerRotation = 0
                        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                            scannerRotation = 360
                        }
                    }
            }
            
            // 2. THE FACE BASE (Head) - REPLACED WITH SVG SHAPE
            SVGStarShape()
                // 🔥 GRADIENT FACE
                .fill(
                    Color(hex: "2C564C")
                )
                // Slightly larger frame than the circle to accommodate the shape's indentations
                .frame(width: 140, height: 140)
                // Shadow using the brand color
//                .shadow(color: Color(hex: "8958BD").opacity(0.4), radius: 10, y: 5)
                // 🔥 THE MAGIC: Head follows eyes (30% strength)
                .offset(x: lookOffset.width * 0.3, y: lookOffset.height * 0.3)
                // 🔥 EXTRA COOL: Slight tilt in the direction of look
                .rotationEffect(.degrees(Double(lookOffset.width) * 0.1))
            
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
            // Eyes also need to move with the head + their own movement
            .offset(x: lookOffset.width * 0.3, y: lookOffset.height * 0.3)
            .rotationEffect(.degrees(Double(lookOffset.width) * 0.1))
        }
        // MARK: - BEHAVIOR LOGIC
        .onReceive(lookTimer) { _ in
            performLookBehavior()
        }
        .onReceive(blinkTimer) { _ in
            performBlink()
        }
        .onChange(of: state) { newState in
            if newState != .searching {
                scannerRotation = 0
            }
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
        
        // Dynamic Timing
        let isSearching = state == .searching
        let range: CGFloat = isSearching ? 22 : 15
        
        let x = CGFloat.random(in: -range...range)
        let y = CGFloat.random(in: -range...range)
        
        // Smoother spring for the head follow effect
        let animation: Animation = isSearching
            ? .interpolatingSpring(stiffness: 170, damping: 15)
            : .interpolatingSpring(stiffness: 50, damping: 12)
            
        withAnimation(animation) {
            lookOffset = CGSize(width: x, height: y)
        }
        
        // Double Take Logic
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
            // 1. SCLERA
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
                .offset(lookOffset) // The pupil moves full distance
                .mask(
                    Circle().frame(width: 38, height: 38)
                )
            }
        }
        .scaleEffect(x: isBlinking ? 1.1 : 1.0, y: isBlinking ? 0.1 : 1.0)
    }
}

// MARK: - 4. THE CUSTOM SVG SHAPE (UPDATED)
struct SVGStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Updated ViewBox dimensions from your new SVG
        let refWidth: CGFloat = 278.0
        let refHeight: CGFloat = 276.0
        
        // Calculate scaling factors to fit the shape perfectly within the given rect
        let scaleX = rect.width / refWidth
        let scaleY = rect.height / refHeight
        
        // Create a transform matrix to apply scaling
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

        // Helper function to apply the transform to a point easily
        func p(_ x: Double, _ y: Double) -> CGPoint {
            return CGPoint(x: x, y: y).applying(transform)
        }

        // --- Path Data Converted from New SVG ---
        // M 117.124 10.3377
        path.move(to: p(117.124, 10.3377))
        
        // C 128.182 -3.44442 149.158 -3.44441 160.217 10.3377
        path.addCurve(to: p(160.217, 10.3377), control1: p(128.182, -3.44442), control2: p(149.158, -3.44441))
        
        // C 167.461 19.3665 179.567 22.921 190.542 19.2421
        path.addCurve(to: p(190.542, 19.2421), control1: p(167.461, 19.3665), control2: p(179.567, 22.921))
        
        // C 207.297 13.6265 224.943 24.967 226.794 42.5399
        path.addCurve(to: p(226.794, 42.5399), control1: p(207.297, 13.6265), control2: p(224.943, 24.967))
        
        // C 228.008 54.0521 236.27 63.587 247.492 66.4261
        path.addCurve(to: p(247.492, 66.4261), control1: p(228.008, 54.0521), control2: p(236.27, 63.587))
        
        // C 264.622 70.7599 273.336 89.8404 265.393 105.625
        path.addCurve(to: p(265.393, 105.625), control1: p(264.622, 70.7599), control2: p(273.336, 89.8404))
        
        // C 260.19 115.965 261.985 128.453 269.891 136.909
        path.addCurve(to: p(269.891, 136.909), control1: p(260.19, 115.965), control2: p(261.985, 128.453))
        
        // C 281.959 149.816 278.974 170.579 263.759 179.563
        path.addCurve(to: p(263.759, 179.563), control1: p(281.959, 149.816), control2: p(278.974, 170.579))
        
        // C 253.791 185.449 248.55 196.925 250.629 208.313
        path.addCurve(to: p(250.629, 208.313), control1: p(253.791, 185.449), control2: p(248.55, 196.925))
        
        // C 253.803 225.696 240.067 241.548 222.409 240.88
        path.addCurve(to: p(222.409, 240.88), control1: p(253.803, 225.696), control2: p(240.067, 241.548))
        
        // C 210.842 240.443 200.228 247.264 195.821 257.968
        path.addCurve(to: p(195.821, 257.968), control1: p(210.842, 240.443), control2: p(200.228, 247.264))
        
        // C 189.093 274.307 168.967 280.217 154.473 270.109
        path.addCurve(to: p(154.473, 270.109), control1: p(189.093, 274.307), control2: p(168.967, 280.217))
        
        // C 144.979 263.487 132.362 263.487 122.867 270.109
        path.addCurve(to: p(122.867, 270.109), control1: p(144.979, 263.487), control2: p(132.362, 263.487))
        
        // C 108.374 280.217 88.2476 274.307 81.52 257.968
        path.addCurve(to: p(81.52, 257.968), control1: p(108.374, 280.217), control2: p(88.2476, 274.307))
        
        // C 77.1126 247.264 66.499 240.443 54.9313 240.88
        path.addCurve(to: p(54.9313, 240.88), control1: p(77.1126, 247.264), control2: p(66.499, 240.443))
        
        // C 37.2738 241.548 23.5374 225.696 26.7115 208.313
        path.addCurve(to: p(26.7115, 208.313), control1: p(37.2738, 241.548), control2: p(23.5374, 225.696))
        
        // C 28.7909 196.925 23.5498 185.449 13.5819 179.563
        path.addCurve(to: p(13.5819, 179.563), control1: p(28.7909, 196.925), control2: p(23.5498, 185.449))
        
        // C -1.63368 170.579 -4.61889 149.816 7.44916 136.909
        path.addCurve(to: p(7.44916, 136.909), control1: p(-1.63368, 170.579), control2: p(-4.61889, 149.816))
        
        // C 15.355 128.453 17.1506 115.965 11.9472 105.625
        path.addCurve(to: p(11.9472, 105.625), control1: p(15.355, 128.453), control2: p(17.1506, 115.965))
        
        // C 4.00435 89.8404 12.7181 70.7599 29.8486 66.4261
        path.addCurve(to: p(29.8486, 66.4261), control1: p(4.00435, 89.8404), control2: p(12.7181, 70.7599))
        
        // C 41.0709 63.587 49.333 54.0521 50.5461 42.5399
        path.addCurve(to: p(50.5461, 42.5399), control1: p(41.0709, 63.587), control2: p(49.333, 54.0521))
        
        // C 52.3979 24.967 70.044 13.6265 86.7981 19.2421
        path.addCurve(to: p(86.7981, 19.2421), control1: p(52.3979, 24.967), control2: p(70.044, 13.6265))
        
        // C 97.7739 22.921 109.879 19.3665 117.124 10.3377
        path.addCurve(to: p(117.124, 10.3377), control1: p(97.7739, 22.921), control2: p(109.879, 19.3665))
        
        path.closeSubpath()

        return path
    }
}
// MARK: - 5. HELPER EXTENSIONS
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AICompanionFace(state: .constant(.idle))
            .scaleEffect(2)
    }
}
