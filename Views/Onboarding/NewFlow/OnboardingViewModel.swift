import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    // Flow State
    @Published var currentStep: OnboardingStep = .splash
    
    // User Data
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""
    @Published var firstName: String = ""
    @Published var age: Int = 18
    @Published var profileImage: UIImage?
    @Published var location: String = ""
    
    // UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    enum OnboardingStep: CaseIterable {
        case splash
        case intro
        case phone
        case otp
        case name
        case age
        case photo
        case location
        case completion
    }
    
    func moveToNextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else {
            return
        }
        withAnimation {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        }
    }
    
    func moveToPreviousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else {
            return
        }
        withAnimation {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }
    
    // MARK: - API Calls (Stubs for now)
    
    func sendOTP() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.moveToNextStep()
        }
    }
    
    func verifyOTP() {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.moveToNextStep()
        }
    }
    
    func completeOnboarding() {
        isLoading = true
        // Simulate final registration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            // Notify AuthManager or similar to switch root view
            AuthManager.shared.completeOnboarding()
        }
    }
}
