import SwiftUI

struct OnboardingCompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 7,
            direction: viewModel.navigationDirection,
            showProgress: false,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                Spacer()
                
                OnboardingIllustration(systemName: "sparkles", color: .yellow)
                
                OnboardingTitle("You're all set!", subtitle: "Welcome to EnglishJi. Let's start practicing your English with learners worldwide.")
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 20)
                }
                
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
