import SwiftUI

struct OnboardingOTPView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Int?
    
    // OTP length
    let otpLength = 6
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Enter OTP")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 10) {
                ForEach(0..<otpLength, id: \.self) { index in
                    OTPTextField(text: $viewModel.otpCode, index: index, focusedField: $focusedField)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.verifyOTP()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Submit")
                    }
                }
                .font(.headline)
                .foregroundColor(.ejDarkerGreen)
                .padding(.vertical, 16)
                .padding(.horizontal, 40)
                .background(Color.ejLightGreen)
                .cornerRadius(30)
            }
            .padding(.bottom, 50)
            .disabled(viewModel.otpCode.count < otpLength || viewModel.isLoading)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            focusedField = 0
        }
    }
}

// Helper View for Individual OTP Digit
struct OTPTextField: View {
    @Binding var text: String
    let index: Int
    @FocusState.Binding var focusedField: Int?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 45, height: 50)
            
            if text.count > index {
                let startIndex = text.index(text.startIndex, offsetBy: index)
                let char = String(text[startIndex])
                Text(char)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .onTapGesture {
            focusedField = index
        }
        // Hidden text field to handle input
        .background(
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: index)
                .opacity(0) // Hide the actual text field
                .onChange(of: text) { newValue in
                    if newValue.count > 6 {
                        text = String(newValue.prefix(6))
                    }
                    // Auto-advance focus logic could be added here if not using single hidden field
                }
        )
    }
}

#Preview {
    OnboardingOTPView(viewModel: OnboardingViewModel())
}
