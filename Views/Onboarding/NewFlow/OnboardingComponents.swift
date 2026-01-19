import SwiftUI

// MARK: - Onboarding Layout Wrapper
struct OnboardingLayout<Content: View>: View {
    let stepIndex: Int // Index in the data flow (1 to totalSteps)
    let totalSteps: Int
    let direction: OnboardingViewModel.NavigationDirection
    let showProgress: Bool
    let onBack: () -> Void
    let content: Content
    
    init(stepIndex: Int, totalSteps: Int = 6, direction: OnboardingViewModel.NavigationDirection, showProgress: Bool = true, onBack: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.stepIndex = stepIndex
        self.totalSteps = totalSteps
        self.direction = direction
        self.showProgress = showProgress
        self.onBack = onBack
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Adaptive Background with subtle gradient
            Group {
                Color(.systemBackground)
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.clear, Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Nav + Progress)
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color(.secondarySystemBackground)))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    if showProgress {
                        // Progress Indicator (Premium Pill style)
                        HStack(spacing: 6) {
                            ForEach(1...totalSteps, id: \.self) { index in
                                Capsule()
                                    .fill(index <= stepIndex ? Color.blue : Color(.systemGray4))
                                    .frame(width: index == stepIndex ? 24 : 8, height: 6)
                                    .animation(.spring(), value: stepIndex)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color(.secondarySystemBackground)))
                    }
                    
                    Spacer()
                    
                    Spacer().frame(width: 40) // Balance the back button
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Content with directional transition
                Group {
                    if direction == .forward {
                        content
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        content
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .id(stepIndex) // Force transition on step change
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Styled Components

struct OnboardingTitle: View {
    let text: String
    let subtitle: String?
    
    init(_ text: String, subtitle: String? = nil) {
        self.text = text
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(text)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
}

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 2)
            )
            .font(.system(size: 19, weight: .semibold, design: .rounded))
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct OnboardingButton: View {
    let title: String
    let isDisabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(title: String, isDisabled: Bool = false, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isDisabled ? Color(.systemGray4) : Color.blue)
            )
            .shadow(color: isDisabled ? .clear : Color.blue.opacity(0.35), radius: 15, x: 0, y: 8)
        }
        .disabled(isDisabled || isLoading)
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
}

// MARK: - Icons & Visuals

struct OnboardingIllustration: View {
    let systemName: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 140, height: 140)
            
            Image(systemName: systemName)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.vertical, 20)
    }
}
