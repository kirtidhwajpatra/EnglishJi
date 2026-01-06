import SwiftUI

// MARK: - 1. Animatable Mouth (Wider & Less Deep)
struct AnimatableMouth: Shape {
    var happinessFactor: Double // 0.0 to 1.0
    
    var animatableData: Double {
        get { happinessFactor }
        set { happinessFactor = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // --- BASE COORDINATES (Neutral) ---
        let startBase = CGPoint(x: 24.90, y: 22.46)
        let endBase = CGPoint(x: 18.29, y: 25.70)
        let c1Base = CGPoint(x: 23.81, y: 23.87)
        let c2Base = CGPoint(x: 21.89, y: 26.09)
        
        // --- ANIMATION CALCULATIONS ---
        
        // 1. Horizontal Expansion (Widen the smile)
        // We push the start point RIGHT (+) and end point LEFT (-)
        let widthExpand = 3.0 * happinessFactor
        
        let startCurrent = CGPoint(
            x: startBase.x + widthExpand,
            y: startBase.y
        )
        let endCurrent = CGPoint(
            x: endBase.x - widthExpand,
            y: endBase.y
        )
        
        // 2. Vertical Expansion (Deepen the smile)
        // Reduced from 12.0 to 5.0 for a subtler look
        let depthExpand = 5.0 * happinessFactor
        
        // 3. Control Point Stretch
        // Control points need to move outward AND down
        let c1Current = CGPoint(
            x: c1Base.x + (widthExpand * 0.8), // Move out slightly less than the anchor
            y: c1Base.y + depthExpand
        )
        let c2Current = CGPoint(
            x: c2Base.x - (widthExpand * 0.8),
            y: c2Base.y + depthExpand
        )
        
        var path = Path()
        path.move(to: startCurrent)
        path.addCurve(to: endCurrent, control1: c1Current, control2: c2Current)
        return path
    }
}

// MARK: - 2. Animatable Hair (Subtle "Perk Up")
struct AnimatableHair: Shape {
    var excitementFactor: Double // 0.0 to 1.0
    
    var animatableData: Double {
        get { excitementFactor }
        set { excitementFactor = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // We lift the entire middle section of the hair slightly up (Y decreases)
        // to simulate an "eyebrow raise" or excitement.
        let lift = 1.0 * excitementFactor
        
        var path = Path()
        path.move(to: CGPoint(x: 3.96, y: 3.20 + (lift * 0.2))) // Start stays mostly anchored
        
        // Curve 1
        path.addCurve(
            to: CGPoint(x: 18.99, y: 11.53 + lift),
            control1: CGPoint(x: 7.71, y: 5.67 + (lift * 0.5)),
            control2: CGPoint(x: 15.95, y: 10.80 + lift)
        )
        
        // Curve 2 (The loop back - With the smooth corner fix)
        path.addCurve(
            to: CGPoint(x: 18.99, y: 6.09 + lift),
            control1: CGPoint(x: 21.5, y: 11.8 + lift), // Using the smoothed control point
            control2: CGPoint(x: 20.26, y: 8.21 + lift)
        )
        
        // Curve 3 (The tail)
        path.addCurve(
            to: CGPoint(x: 32.61, y: 14.71 + (lift * 0.5)), // Tail lifts slightly
            control1: CGPoint(x: 22.15, y: 8.32 + lift),
            control2: CGPoint(x: 29.29, y: 13.16 + lift)
        )
        
        return path
    }
}

// MARK: - 3. Main View
struct HandDrawnFaceIcon: View {
    // 1. Add this property to receive the external action
    var onTap: (() -> Void)? = nil
    
    @State private var isTapped = false
    
    var body: some View {
        ZStack {
            // ... (Your existing Circle & Gradient code stays here) ...
            Circle()
                .fill(Color(hex: "D6E978"))
                .opacity(1.0)
            
            // ... (Your existing Mouth & Hair code stays here) ...
            AnimatableMouth(happinessFactor: isTapped ? 1.0 : 0.0)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            AnimatableHair(excitementFactor: isTapped ? 1.0 : 0.0)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .bevel))
        }
        .frame(width: 42, height: 39)
        .scaleEffect(CGSize(width: 1.3, height: 1.3))
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .contentShape(Circle())
        .onTapGesture {
            // 2. TRIGGER EXTERNAL ACTION HERE
            onTap?()
            
            // 3. Trigger Internal Animation
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.interpolatingSpring(stiffness: 180, damping: 12)) {
                isTapped.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                 withAnimation(.interpolatingSpring(stiffness: 120, damping: 15)) {
                     isTapped = false
                 }
            }
        }
    }
}

struct HandDrawnFaceIcon_Previews: PreviewProvider {
    static var previews: some View {
        HandDrawnFaceIcon()
            .padding()
    }
}
