import SwiftUI

struct OnboardingAgeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 4,
            direction: viewModel.navigationDirection,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("How old are you?", subtitle: "We use this to find partners in a similar age group.")
                
                Spacer()
                
                Picker("Age", selection: $viewModel.age) {
                    ForEach(13...100, id: \.self) { age in
                        Text("\(age)")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                OnboardingButton(
                    title: "Continue",
                    isDisabled: false,
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
}

#Preview {
    OnboardingAgeView(viewModel: OnboardingViewModel())
}
