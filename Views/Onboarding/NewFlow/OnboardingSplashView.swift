import SwiftUI

struct OnboardingSplashView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("appicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.moveToNextStep()
            }
        }
    }
}

#Preview {
    OnboardingSplashView(viewModel: OnboardingViewModel())
}
