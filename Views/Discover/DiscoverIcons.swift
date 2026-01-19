import SwiftUI

// MARK: - Paper Plane Icon
struct PaperPlaneIcon: View {
    var body: some View {
        ZStack {
            // Main Body
            Path { path in
                path.move(to: CGPoint(x: 0.79, y: 4.58))
                path.addLine(to: CGPoint(x: 13.60, y: 0.35))
                path.addCurve(to: CGPoint(x: 14.25, y: 1.04), control1: CGPoint(x: 14.02, y: 0.21), control2: CGPoint(x: 14.41, y: 0.63))
                path.addLine(to: CGPoint(x: 9.79, y: 11.99))
                path.addCurve(to: CGPoint(x: 9.16, y: 12.30), control1: CGPoint(x: 9.69, y: 12.24), control2: CGPoint(x: 9.42, y: 12.37))
                path.addLine(to: CGPoint(x: 6.99, y: 11.67))
                path.addCurve(to: CGPoint(x: 6.47, y: 11.80), control1: CGPoint(x: 6.80, y: 11.61), control2: CGPoint(x: 6.61, y: 11.67))
                path.addLine(to: CGPoint(x: 4.94, y: 13.37))
                path.addCurve(to: CGPoint(x: 4.05, y: 13.01), control1: CGPoint(x: 4.61, y: 13.70), control2: CGPoint(x: 4.05, y: 13.47))
                path.addLine(to: CGPoint(x: 4.05, y: 9.21))
                path.addCurve(to: CGPoint(x: 3.90, y: 8.84), control1: CGPoint(x: 4.05, y: 9.07), control2: CGPoint(x: 3.99, y: 8.94))
                path.addLine(to: CGPoint(x: 0.58, y: 5.43))
                path.addCurve(to: CGPoint(x: 0.79, y: 4.58), control1: CGPoint(x: 0.31, y: 5.16), control2: CGPoint(x: 0.42, y: 4.70))
                path.closeSubpath()
            }
            .fill(Color.ejLightGreen) // Dark Green Fill 
           
            
            
            // Accent Line
            Path { path in
                path.move(to: CGPoint(x: 3.03, y: 9.53))
                path.addLine(to: CGPoint(x: 8.99, y: 4.75))
            }
            .stroke(Color.ejDarkerGreen, style: StrokeStyle(lineWidth: 0.87, lineCap: .round)) // Lime stroke
        }
        .frame(width: 18, height: 18)
        
        .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Filter Icon
struct FilterIcon: View {
    var body: some View {
        ZStack {
            // Horizontal lines
            Path { path in
                path.move(to: CGPoint(x: 0.62, y: 8.63))
                path.addLine(to: CGPoint(x: 12.42, y: 8.63))
                path.move(to: CGPoint(x: 12.41, y: 2.32))
                path.addLine(to: CGPoint(x: 0.61, y: 2.32))
            }
            .stroke(Color(hex: "232323"), style: StrokeStyle(lineWidth: 1.22, lineCap: .round))
            
            // Knobs (Rectangles)
            // Knob 1 (Left, Bottom)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: "222222"))
                .frame(width: 1.6, height: 4.6)
                .position(x: 4.17, y: 8.63)
            
            // Knob 2 (Right, Top)
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(hex: "222222"))
                .frame(width: 1.5, height: 4.6)
                .position(x: 9.06, y: 2.32)
        }
        .frame(width: 15, height: 12)
        .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Cancel Icon (X)
struct CancelIcon: View {
    var body: some View {
        ZStack {
            // Dark Stroke X
            Path { path in
                path.move(to: CGPoint(x: 1, y: 0.77))
                path.addLine(to: CGPoint(x: 10.18, y: 9.95))
                path.move(to: CGPoint(x: 10.18, y: 0.77))
                path.addLine(to: CGPoint(x: 1, y: 9.95))
            }
            .stroke(Color.ejDarkerGreen, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
            
            // White Accent line (Subtle detail from SVG)
            Path { path in
                path.move(to: CGPoint(x: 9.39, y: 0.21))
                path.addLine(to: CGPoint(x: 0.21, y: 9.39))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: 0.6, lineCap: .round))
        }
        .frame(width: 11, height: 11)
        .aspectRatio(contentMode: .fit)
    }
}

// MARK: - Bouncy Button Style
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    // Simple haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
    }
}
