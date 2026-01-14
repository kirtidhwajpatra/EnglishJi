import SwiftUI

struct OnboardingAgeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress dots
            HStack(spacing: 4) {
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
            }
            .padding(.top, 20)
            
            HStack(spacing: 20) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Age")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.ejDarkerGreen)
                Text("Photo")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Location")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Picker("Age", selection: $viewModel.age) {
                ForEach(13...100, id: \.self) { age in
                    Text("\(age)")
                        .font(.custom("Futura", size: 40)) // Attempting to match style
                        .tag(age)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
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
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingAgeView(viewModel: OnboardingViewModel())
}
