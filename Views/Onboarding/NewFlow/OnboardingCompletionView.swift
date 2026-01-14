import SwiftUI

struct OnboardingCompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Yeee.. Let's smash 💃")
                .font(.custom("Futura-Bold", size: 28))
                .fontWeight(.bold)
                .foregroundColor(.ejDarkerGreen)
            
            Spacer()
            
            // Logo
            Image("appicon")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
                .frame(height: 50)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.completeOnboarding()
        }
    }
}

#Preview {
    OnboardingCompletionView(viewModel: OnboardingViewModel())
}
