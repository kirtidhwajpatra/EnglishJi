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
                OnboardingTitle("Enter OTP")
                
                Spacer()
                
                ZStack {
                    // Hidden Input
                    TextField("", text: $viewModel.otpCode)
                        .keyboardType(.numberPad)
                        .focused($isKeyboardFocused)
                        .opacity(0)
                        .onChange(of: viewModel.otpCode) { newValue in
                            if newValue.count > otpLength {
                                viewModel.otpCode = String(newValue.prefix(otpLength))
                            }
                        }
                    
                    // Visual Circles
                    HStack(spacing: 12) {
                        ForEach(0..<otpLength, id: \.self) { index in
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                
                                if viewModel.otpCode.count > index {
                                    let char = String(Array(viewModel.otpCode)[index])
                                    Text(char)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.ejDarkerGreen)
                                }
                            }
                        }
                    }
                }
                .onTapGesture { isKeyboardFocused = true }
                
                Spacer()
                
                OnboardingButton(
                    title: "Submit",
                    isDisabled: viewModel.otpCode.count < otpLength,
                    isLoading: viewModel.isLoading,
                    action: { viewModel.verifyOTP() }
                )
            }
        }
        .onAppear { isKeyboardFocused = true }
    }
    
    @FocusState private var isKeyboardFocused: Bool
}

#Preview {
    OnboardingOTPView(viewModel: OnboardingViewModel())
}
