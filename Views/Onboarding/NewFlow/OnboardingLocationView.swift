import SwiftUI

struct OnboardingLocationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var city: String = "New Delhi"
    @State private var country: String = "India"
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 6,
            direction: viewModel.navigationDirection,
            showProfileProgress: true,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                Spacer()
                
                VStack(spacing: 30) {
                    // City Selection
                    Menu {
                        Button("New Delhi") { city = "New Delhi" }
                        Button("Mumbai") { city = "Mumbai" }
                        Button("Bangalore") { city = "Bangalore" }
                        Button("Other") { city = "Other" }
                    } label: {
                        VStack(spacing: 8) {
                            HStack {
                                Text(city)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Divider()
                                .frame(height: 1.5)
                                .background(Color.ejDarkerGreen)
                        }
                    }
                    
                    // Country Selection
                    Menu {
                        Button("India") { country = "India" }
                        Button("USA") { country = "USA" }
                        Button("UK") { country = "UK" }
                    } label: {
                        VStack(spacing: 8) {
                            HStack {
                                Text(country)
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Divider()
                                .frame(height: 1.5)
                                .background(Color.ejDarkerGreen)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                OnboardingButton(
                    title: "Next",
                    action: {
                        viewModel.location = "\(city), \(country)"
                        viewModel.moveToNextStep()
                    }
                )
            }
        }
    }
}

#Preview {
    OnboardingLocationView(viewModel: OnboardingViewModel())
}
