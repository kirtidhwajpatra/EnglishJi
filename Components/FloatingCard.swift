import SwiftUI

struct FloatingCardAnimated: View {
    var letter: String
    var fill: Color
    var rotation: Double
    var offset: CGSize
    var delay: Double
    
    @State private var appear = false
    @State private var breathe = false
    
    var body: some View {
        Text(letter)
            .font(.custom("Futura-CondensedMedium", size: 120))
            .foregroundColor(.white.opacity(0.2))
            .frame(width: 170, height: 170)
            .background(fill)
            .compositingGroup()

            .cornerRadius(24)
        
            // HIGH BLUR → ZERO BLUR TRANSITION
            .blur(radius: appear ? 0 : 18)
        
            // POP-IN SCALE
            .scaleEffect(appear ? 1 : 0.5)
        
            .rotationEffect(.degrees(rotation))
        
            // FLOATING EFFECT (gentle breathing)
            .offset(
                x: offset.width + (breathe ? 4 : -4),
                y: offset.height + (breathe ? -3 : 3)
            )
        
            .opacity(appear ? 1 : 0)
        
            // POP SPRING ANIMATION
            .animation(
                .spring(response: 0.55, dampingFraction: 0.65, blendDuration: 0)
                    .delay(delay),
                value: appear
            )
        
            // FLOATING LOOP
            .animation(
                .easeInOut(duration: 3.0).repeatForever(),
                value: breathe
            )
        
            .onAppear {
                // First enable pop + blur removal
                appear = true
                
                // Then start floating after pop finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
                    breathe = true
                }
            }
    }
}
