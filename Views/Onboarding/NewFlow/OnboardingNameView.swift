import SwiftUI

struct OnboardingNameView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress dots (Mockup shows them)
            HStack(spacing: 4) {
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
            }
            .padding(.top, 20)
            
            HStack(spacing: 20) {
                Text("Name")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.ejDarkerGreen)
                Text("Age")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Photo")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Location")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                TextField("First Name", text: $viewModel.firstName)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .overlay(Divider(), alignment: .bottom)
                
                TextField("Middle Name", text: $middleName)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .overlay(Divider(), alignment: .bottom)
                
                TextField("Last Name", text: $lastName)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .overlay(Divider(), alignment: .bottom)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                viewModel.moveToNextStep()
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.ejDarkerGreen)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Color.ejLightGreen)
                    .cornerRadius(30)
            }
            .padding(.bottom, 50)
            .disabled(viewModel.firstName.isEmpty)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingNameView(viewModel: OnboardingViewModel())
}
