import SwiftUI

struct OnboardingAgeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 4,
            direction: viewModel.navigationDirection,
            showProfileProgress: true,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                Spacer()
                
                // Custom Wheel Picker
                ZStack {
                    // Selection Highlight
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 60)
                        .padding(.horizontal, 40)
                    
                    Picker("Age", selection: $viewModel.age) {
                        ForEach(16...100, id: \.self) { age in
                            Text("\(age)")
                                .font(.system(size: 32, weight: .bold)) // Large font
                                .foregroundColor(.ejDarkerGreen)
                                .tag(age)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                }
                
                Spacer()
                
                OnboardingButton(
                    title: "Next",
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
}

#Preview {
    OnboardingAgeView(viewModel: OnboardingViewModel())
}
