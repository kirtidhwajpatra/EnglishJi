import SwiftUI

struct OnboardingOTPView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Int?
    
    // OTP length
    let otpLength = 6
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 2,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("Verification code", subtitle: "Enter the 6-digit code sent to\n\(viewModel.phoneNumber)")
                
                ZStack {
                    // Hidden background TextField
                    TextField("", text: $viewModel.otpCode)
                        .keyboardType(.numberPad)
                        .focused($isKeyboardFocused)
                        .opacity(0)
                        .onChange(of: viewModel.otpCode) { newValue in
                            if newValue.count > otpLength {
                                viewModel.otpCode = String(newValue.prefix(otpLength))
                            }
                            if newValue.count == otpLength {
                                // Auto submit or just unfocus
                                isKeyboardFocused = false
                            }
                        }
                    
                    // Visual OTP Boxes
                    HStack(spacing: 12) {
                        ForEach(0..<otpLength, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 50, height: 64)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(boxColor(for: index), lineWidth: 2)
                                    )
                                
                                if viewModel.otpCode.count > index {
                                    let char = String(Array(viewModel.otpCode)[index])
                                    Text(char)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .onTapGesture {
                    isKeyboardFocused = true
                }
                
                Button(action: {
                    viewModel.sendOTP() // Reuse send function for resend
                }) {
                    Text("Resend code")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.top, 30)
                }
                
                Spacer()
                
                OnboardingButton(
                    title: "Verify",
                    isDisabled: viewModel.otpCode.count < otpLength,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.verifyOTP() }
                )
            }
        }
        .onAppear {
            isKeyboardFocused = true
        }
    }
    
    @FocusState private var isKeyboardFocused: Bool
    
    private func boxColor(for index: Int) -> Color {
        if viewModel.otpCode.count == index && isKeyboardFocused {
            return .blue
        }
        return .clear
    }
}

#Preview {
    OnboardingOTPView(viewModel: OnboardingViewModel())
}
