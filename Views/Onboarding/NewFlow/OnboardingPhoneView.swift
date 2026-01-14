import SwiftUI

struct OnboardingPhoneView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Enter your number")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            HStack {
                Text("+91") // Hardcoded for now, or use picker
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                TextField("760-996-3811", text: $viewModel.phoneNumber)
                    .keyboardType(.numberPad)
                    .font(.title3)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Trigger OTP send
                viewModel.sendOTP()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Next")
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
            .disabled(viewModel.phoneNumber.isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingPhoneView(viewModel: OnboardingViewModel())
}
