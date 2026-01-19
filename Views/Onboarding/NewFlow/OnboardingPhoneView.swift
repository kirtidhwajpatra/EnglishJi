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
                
                // Google Sign In
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .overlay(
                            // Placeholder G Logo - In a real app this would be an Image asset
                            Text("G")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .red, .yellow, .green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .padding(.bottom, 20)
                
                // OR Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .frame(maxWidth: 200)
                .padding(.bottom, 20)
                
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
                
                Text("By clicking Next, you agree to our [Terms of Service](https://englishji.com/terms) and [Privacy Policy](https://englishji.com/privacy).")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    OnboardingPhoneView(viewModel: OnboardingViewModel())
}
