import SwiftUI

struct OnboardingPhoneView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 1,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("Enter your number", subtitle: "We'll send you a verification code to keep your account safe.")
                
                HStack(spacing: 12) {
                    Text("🇮🇳 +91")
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .frame(height: 56)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    
                    OnboardingTextField(
                        placeholder: "Mobile Number",
                        text: $viewModel.phoneNumber,
                        contentType: .telephoneNumber,
                        keyboardType: .numberPad
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                OnboardingButton(
                    title: viewModel.isLoading ? "Sending..." : "Continue",
                    isDisabled: viewModel.phoneNumber.count < 10 || viewModel.isLoading,
                    action: { viewModel.sendOTP() }
                )
            }
        }
    }
}

#Preview {
    OnboardingPhoneView(viewModel: OnboardingViewModel())
}
