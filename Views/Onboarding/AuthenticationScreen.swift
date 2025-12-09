import SwiftUI
import FirebaseAuth
import AuthenticationServices // For Apple Sign In

struct AuthenticationScreen: View {
    // MARK: - Properties
    private let backgroundColor = Color.specificHex("F2F2F7")
    private let titleColor = Color.specificHex("0F0039")
    private let primaryButtonColor = Color.specificHex("3A2984")
    
    @ObservedObject var manager: OnboardingManager
    
    // Animation State
    @State private var animateIn = false
    
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        ZStack {
            // 1. Background
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: -14) {
                    TypewriterTextWithDelay(fullText: "ONE FINAL", typingSpeed: 0.05, delay: 0)
                    TypewriterTextWithDelay(fullText: "STEP TO COMPLETE", typingSpeed: 0.05, delay: 0.6)
                }
                .font(.custom("Futura-CondensedExtraBold", size: 36))
                .foregroundColor(Color(hex: "#110037"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(height: 120)
                
                Spacer()
                
                // 3. Social Login Buttons
                VStack(spacing: 16) {
                    
                    // Google Button
                    SocialButton(
                        title: "Continue with Google",
                        iconName: "globe", // Placeholder for Google Icon
                        backgroundColor: Color.specificHex("120828"), // Dark Navy/Black
                        foregroundColor: .white,
                        isSystemIcon: true
                    ) {
                        triggerHaptic()
                                            authManager.signInWithGoogle { success in
                                                if success {
                                                    print("User Logged in! User ID: \(authManager.user?.uid ?? "Unknown")")
                                                    // Navigate to next screen here
                                                } else {
                                                    print("Login Failed: \(authManager.errorMessage)")
                                                }
                                            }
                                        }
                    
                    // Apple Button
                    SocialButton(
                        title: "Continue with Apple",
                        iconName: "applelogo",
                        backgroundColor: .black,
                        foregroundColor: .white,
                        isSystemIcon: true
                    ) {
                        // Apple Login Logic
                        triggerHaptic()
                    }
                    
                    // Divider Line
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .frame(width: 40)
                    }
                    .padding(.vertical, 10)
                    
                    // Phone Button (Outline Style)
                    SocialButton(
                        title: "Sign in with Phone",
                        iconName: "", // No icon
                        backgroundColor: .white,
                        foregroundColor: titleColor,
                        hasBorder: true
                    ) {
                        // Phone Login Logic
                        triggerHaptic()
                    }
                }
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animateIn)
                
                Spacer()
                
                // 4. Continue Button (Bottom)
                Button(action: {
                    triggerHaptic()
                    // Final Action
                }) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(primaryButtonColor)
                        .cornerRadius(28)
                        .shadow(color: primaryButtonColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(animateIn ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: animateIn)
            }
        }
        .onAppear {
            animateIn = true
        }
    }
    
    // Haptic Helper
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Reusable Social Button Component
struct SocialButton: View {
    let title: String
    let iconName: String
    let backgroundColor: Color
    let foregroundColor: Color
    var hasBorder: Bool = false
    var isSystemIcon: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon Logic
                if !iconName.isEmpty {
                    if iconName == "globe" {
                        // "Fake" Google G for demo purposes (Multi-color text)
                        // In production, use: Image("google_icon")
                        Text("G")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white) // Simplified for the dark button
                    } else {
                        Image(systemName: iconName)
                            .font(.system(size: 22))
                            .foregroundColor(foregroundColor)
                    }
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(hasBorder ? Color.black : Color.clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle()) // Adds press animation
    }
}

// MARK: - Custom Button Style for "Press" effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Private Color Helper
private extension Color {
    static func specificHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct AuthenticationScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationScreen(manager: OnboardingManager())
    }
}
