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
                    Color.ejDarkerGreen
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
            HStack(spacing: 4) {
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
                        .frame(width: 20, height: 20)
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
        let refWidth: CGFloat = 255.0
        let refHeight: CGFloat = 251.0
        
        let scaleX = rect.width / refWidth
        let scaleY = rect.height / refHeight
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

        func p(_ x: Double, _ y: Double) -> CGPoint {
            return CGPoint(x: x, y: y).applying(transform)
        }

        path.move(to: p(88.6603, 23.5841))
        path.addCurve(to: p(164.609, 23.5841), control1: p(104.211, -7.86256), control2: p(149.058, -7.86256))
        path.addCurve(to: p(222.789, 72.4028), control1: p(196.735, 9.49041), control2: p(231.09, 38.3175))
        path.addLine(to: p(224.871, 73.0121))
        path.addCurve(to: p(237.725, 145.913), control1: p(257.687, 82.6165), control2: p(265.278, 125.664))
        path.addCurve(to: p(237.18, 149.003), control1: p(236.747, 146.632), control2: p(236.507, 147.993))
        path.addCurve(to: p(200.168, 213.11), control1: p(256.146, 177.454), control2: p(234.29, 215.309))
        path.addLine(to: p(198.003, 212.971))
        path.addCurve(to: p(126.635, 238.947), control1: p(194.145, 247.84), control2: p(152.003, 263.178))
        path.addCurve(to: p(55.2663, 212.971), control1: p(101.266, 263.178), control2: p(59.1239, 247.84))
        path.addCurve(to: p(17.292, 147.198), control1: p(20.2573, 215.227), control2: p(-2.16616, 176.388))
        path.addCurve(to: p(30.4803, 72.4028), control1: p(-10.9765, 126.422), control2: p(-3.1889, 82.2567))
        path.addCurve(to: p(88.6603, 23.5841), control1: p(22.1794, 38.3175), control2: p(56.5342, 9.4904))
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
