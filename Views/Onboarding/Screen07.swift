import SwiftUI

struct LocationScreen: View {
    // MARK: - 1. State Management
    // These variables hold the data selected by the user
    @State private var selectedCountry: String = ""
    @State private var selectedCity: String = ""
    
    // Sample Data
    private let countries = ["India", "USA", "Canada", "United Kingdom", "Australia"]
    private let cities = ["New Delhi", "Mumbai", "Bangalore", "Chandigarh", "Pune"]
    
    // UI Colors (Safe Local Definitions)
    private let backgroundColor = Color(hex: "F2F2F7")
    private let activeColor = Color(hex: "0F0039")
    private let buttonColor = Color(hex: "3A2984")
    
    @ObservedObject var manager: OnboardingManager
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor.ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                
                VStack(spacing: -14) {
                    TypewriterTextWithDelay(fullText: "WHAT SHOULD", typingSpeed: 0.05, delay: 0)
                    TypewriterTextWithDelay(fullText: " WE CALL YOU?", typingSpeed: 0.05, delay: 0.6)
                }
                .font(.custom("Futura-CondensedExtraBold", size: 36))
                .foregroundColor(Color(hex: "#110037"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(height: 120)
                
                
                
                Spacer()

                // MARK: - 2. Calling the Component
                VStack(spacing: 30) {
                    
                    // Country Selector
                    LocationSelectorField(
                        title: "Country",
                        options: countries,
                        selectedValue: $selectedCountry // Use $ to pass the binding
                    )
                    // ZIndex ensures the dropdown floats ABOVE the city field
                    .zIndex(2)
                    
                    // City Selector
                    LocationSelectorField(
                        title: "City",
                        options: cities,
                        selectedValue: $selectedCity // Use $ to pass the binding
                    )
                    .zIndex(1)
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                // Continue Button
                AnimatedCTAButton(delay: 1.0) {
                    manager.goNext()
                } content: {
                    Text("Continue")
                        .font(.system(size: 20, weight: .medium))                        .kerning(-0.2)
                        .foregroundColor(Color(hex: "#F1F1F1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "#3F1A94"))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

    
                // Disable button until both are selected
                .opacity((selectedCountry.isEmpty || selectedCity.isEmpty) ? 0.6 : 1.0)
                .disabled(selectedCountry.isEmpty || selectedCity.isEmpty)
            }
        }
        // Dismiss menus when tapping background
        .onTapGesture {
            // Optional: You could add logic here to close dropdowns if you exposed that state
        }
    }
}

// MARK: - Preview
struct LocationScreen_Previews: PreviewProvider {
    static var previews: some View {
        LocationScreen(manager: OnboardingManager())
    }
}
