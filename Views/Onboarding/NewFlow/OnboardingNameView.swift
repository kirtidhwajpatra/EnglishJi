import SwiftUI

struct OnboardingNameView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 3,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("What's your name?", subtitle: "This is how you'll appear to other learners on EnglishJi.")
                
                VStack(spacing: 20) {
                    OnboardingTextField(placeholder: "First Name", text: $viewModel.firstName, contentType: .givenName)
                    
                    OnboardingTextField(placeholder: "Last Name (Optional)", text: $lastName, contentType: .familyName)
                }
                .padding(.horizontal)
                
                Spacer()
                
                OnboardingButton(
                    title: "Continue",
                    isDisabled: viewModel.firstName.isEmpty,
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
}

#Preview {
    OnboardingNameView(viewModel: OnboardingViewModel())
}
