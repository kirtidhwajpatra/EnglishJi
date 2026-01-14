import SwiftUI

struct OnboardingLocationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var city: String = "New Delhi"
    @State private var country: String = "India"
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress dots
            HStack(spacing: 4) {
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
            }
            .padding(.top, 20)
            
            HStack(spacing: 20) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Age")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Photo")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Location")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.ejDarkerGreen)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                // Mock Pickers using Menu or just Text with chevron for now
                HStack {
                    Text(city)
                        .font(.title3)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .overlay(Divider(), alignment: .bottom)
                
                HStack {
                    Text(country)
                        .font(.title3)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .overlay(Divider(), alignment: .bottom)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                viewModel.location = "\(city), \(country)"
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
    OnboardingLocationView(viewModel: OnboardingViewModel())
}
