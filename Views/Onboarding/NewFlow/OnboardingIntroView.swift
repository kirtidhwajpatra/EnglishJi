import SwiftUI

struct OnboardingIntroView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // MARK: - Animation Configuration
    struct AnimationTheme {
        let words: [String] = ["Create", "momentum", "by", "choosing", "action", "daily."]
        // Using app theme colors for gradient
        let gradientColors: [Color] = [.ejDarkerGreen, .ejLightGreen, .ejDarkerGreen]
        let backgroundColors: [Color] = [.white, .white, .white]
        
        let font: Font = .custom("Futura-Bold", size: 60) // Matched to app font
        let lineSpacing: CGFloat = -15
        
        // Animation Physics
        let speedPerWord: Double = 0.5
        let blurStrength: CGFloat = 10
        
        // Scale Logic
        let startZoomScale: CGFloat = 3.5
        let standardScale: CGFloat = 1.0
    }
    
    let theme = AnimationTheme()
    
    @State private var visibleIndex: Int = -1
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 0, y: 1)
    @State private var animationID = UUID()
    
    // MARK: - Logic
    var rowHeight: CGFloat {
        // Approximate height calculation
        return 60 * 1.2 + theme.lineSpacing
    }
    
    // Scroll Logic
    var currentOffset: CGFloat {
        let centerIndex = CGFloat(theme.words.count - 1) / 2.0
        let targetIndex = visibleIndex < 0 ? 0 : CGFloat(visibleIndex)
        return (centerIndex - targetIndex) * rowHeight
    }
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 0,
            direction: viewModel.navigationDirection,
            onBack: nil
        ) {
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Create")
                    Text("momentum")
                    Text("by")
                    Text("choosing")
                    Text("action")
                    Text("daily.")
                }
                .font(.custom("Futura-Bold", size: 48))
                .fontWeight(.heavy)
                .foregroundColor(.ejDarkerGreen)
                .multilineTextAlignment(.center)
                
                Spacer()
                
                OnboardingButton(
                    title: "Get started",
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
    
    // MARK: - Calculations
    
    func calculateScale(for index: Int) -> CGFloat {
        if index == 0 {
            return visibleIndex < 0 ? theme.startZoomScale : theme.standardScale
        }
        return theme.standardScale
    }
    
    func calculateBlur(for index: Int) -> CGFloat {
        if index == visibleIndex { return 0 }
        if index == 0 && visibleIndex < 0 { return 30 }
        return index > visibleIndex ? theme.blurStrength * 2 : theme.blurStrength
    }
    
    func calculateOpacity(for index: Int) -> Double {
        if index == visibleIndex { return 1.0 }
        if index > visibleIndex { return 0 }
        return 0.2
    }
    
    // MARK: - Actions
    func startSequence() {
        let currentRunID = UUID()
        animationID = currentRunID
        
        withAnimation(.none) { visibleIndex = -1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.animationID == currentRunID else { return }
            
            for i in 0..<theme.words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * theme.speedPerWord)) {
                    guard self.animationID == currentRunID else { return }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        visibleIndex = i
                    }
                }
            }
        }
    }
    
    func startGradientAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
            gradientStart = UnitPoint(x: 1, y: 0)
            gradientEnd = UnitPoint(x: 0, y: 1)
        }
    }
}

#Preview {
    OnboardingIntroView(viewModel: OnboardingViewModel())
}
