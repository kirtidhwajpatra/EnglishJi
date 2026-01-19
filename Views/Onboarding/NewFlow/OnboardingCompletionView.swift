import SwiftUI

struct OnboardingCompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 7,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.ejLightGreen)
                    .padding(.bottom, 20)
                
                OnboardingTitle("You're all set!", subtitle: "Welcome to EnglishJi.")
                
                Spacer()
                
                OnboardingButton(
                    title: "Start Learning",
                    isLoading: viewModel.isLoading,
                    action: { viewModel.completeOnboarding() }
                )
            }
        }
    }
}

#Preview {
    OnboardingCompletionView(viewModel: OnboardingViewModel())
}
