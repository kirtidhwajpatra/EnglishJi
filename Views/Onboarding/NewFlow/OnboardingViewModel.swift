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
    
    enum NavigationDirection {
        case forward
        case backward
    }
    
    @Published var navigationDirection: NavigationDirection = .forward
    
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
        navigationDirection = .forward
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        }
    }
    
    func moveToPreviousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else {
            return
        }
        navigationDirection = .backward
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
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
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        AuthManager.shared.signInWithGoogle { [weak self] success in
            guard let self = self else { return }
            self.isLoading = false
            
            if success {
                print("Google Sign In Successful")
                // On success, we assume the user is authenticated. 
                // We might want to fetch their profile or just assume they are "new" and need to complete onboarding?
                // Or if they are returning, we might skip onboarding. 
                // For this flow, let's assume we proceed to next step OR complete if they are already fully registered.
                // But typically onboarding is for NEW users.
                // Let's assume we move to Name step if name is missing, or completion.
                // For now, mirroring previous logic:
                 AuthManager.shared.completeOnboarding()
            } else {
                print("Google Sign In Failed")
                self.errorMessage = AuthManager.shared.errorMessage
            }
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
