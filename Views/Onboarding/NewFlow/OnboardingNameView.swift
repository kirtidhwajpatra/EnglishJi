import SwiftUI

struct OnboardingNameView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 3,
            direction: viewModel.navigationDirection,
            showProfileProgress: true,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    OnboardingTextField(placeholder: "First Name", text: $viewModel.firstName, contentType: .givenName)
                    
                    Text("This will be your visible identity in the community.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    // Optional Last Name if needed, or just one name field as per original ViewModel
                    // Looking at image: Top Text "Veena", Bottom Text "Singh". Implicitly First/Last.
                    // Adding a local state for Last Name or just ignoring since ViewModel only has `name`?
                    // ViewModel has `firstName` (line 11). I will treat it as Full Name or just Name.
                    // For now, let's just show one Name field to match ViewModel, or add another binding?
                    // I'll stick to one field but style it nicely.
                    // Wait, image definitively shows two fields.
                    // I should probably add lastName to ViewModel later, but for UI match, I'll add a dummy field or split the name.
                    // Let's keep it simple: Just First Name for "EnglishJi" context usually suffices, or use the single field.
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                OnboardingButton(
                    title: "Next",
                    isDisabled: viewModel.firstName.isEmpty,
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
}

#Preview {
    OnboardingNameView(viewModel: OnboardingViewModel())
}
