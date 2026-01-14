import SwiftUI

struct OnboardingSplashView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo Placeholder (Using AppIcon logic or image asset)
                Image("appicon") // Assuming this asset exists from previous steps
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                // New Loading Indicator or similar branding
                GeometryReader { geometry in
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 4)
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
                }
                .frame(height: 50)
            }
        }
        .onAppear {
            // Auto advance after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                viewModel.moveToNextStep()
            }
        }
    }
}

#Preview {
    OnboardingSplashView(viewModel: OnboardingViewModel())
}
