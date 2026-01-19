import SwiftUI

struct OnboardingLocationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var city: String = "New Delhi"
    @State private var country: String = "India"
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 6,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("Where are you from?", subtitle: "We'll show you learners and activities near your area.")
                
                OnboardingIllustration(systemName: "hand.wave.fill", color: .orange)
                
                VStack(spacing: 20) {
                    // Country Selection
                    Menu {
                        Button("India") { country = "India" }
                        Button("USA") { country = "USA" }
                        Button("United Kingdom") { country = "UK" }
                        Button("Canada") { country = "Canada" }
                    } label: {
                        HStack {
                            Text("Country")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(country)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption2.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemBackground)))
                    }
                    
                    // City Selection
                    Menu {
                        Button("New Delhi") { city = "New Delhi" }
                        Button("Mumbai") { city = "Mumbai" }
                        Button("Bangalore") { city = "Bangalore" }
                        Button("Other") { city = "Other" }
                    } label: {
                        HStack {
                            Text("City")
                                .font(.body)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(city)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption2.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemBackground)))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                OnboardingButton(
                    title: "Continue",
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
