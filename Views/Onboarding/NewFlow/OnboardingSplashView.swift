import SwiftUI

struct OnboardingSplashView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("appicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Spacer()
                
                ProgressView()
                    .scaleEffect(1.2)
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
