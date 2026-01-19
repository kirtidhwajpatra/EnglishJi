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
                OnboardingTitle("Enter your number")
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Country Code Box
                    Text("+91")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.ejDarkerGreen)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Phone Number Input
                    VStack(spacing: 8) {
                        TextField("999-999-9999", text: $viewModel.phoneNumber)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.ejDarkerGreen)
                            .keyboardType(.numberPad)
                            .textContentType(.telephoneNumber)
                        
                        Rectangle()
                            .fill(viewModel.phoneNumber.isEmpty ? Color.gray.opacity(0.3) : Color.ejDarkerGreen)
                            .frame(height: 1.5)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                OnboardingButton(
                    title: "Next",
                    isDisabled: viewModel.phoneNumber.count < 10,
                    action: { viewModel.sendOTP() }
                )
            }
        }
    }
}

#Preview {
    OnboardingPhoneView(viewModel: OnboardingViewModel())
}
