import SwiftUI

// MARK: - Onboarding Layout Wrapper
struct OnboardingLayout<Content: View>: View {
    let stepIndex: Int
    let direction: OnboardingViewModel.NavigationDirection
    let showProfileProgress: Bool
    let onBack: (() -> Void)?
    let content: Content
    
    init(
        stepIndex: Int,
        direction: OnboardingViewModel.NavigationDirection,
        showProfileProgress: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.stepIndex = stepIndex
        self.direction = direction
        self.showProfileProgress = showProfileProgress
        self.onBack = onBack
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Design is strictly white clean
            
            VStack(spacing: 0) {
                // Header Area
                ZStack {
                    if let onBack = onBack {
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            Spacer()
                        }
                    }
                    
                    if showProfileProgress {
                        OnboardingProfileProgress(currentStep: stepForProgress(stepIndex))
                    }
                }
                .frame(height: 60)
                
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
                .id(stepIndex)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // Map overall step index to profile progress step (0-3)
    // 3=Name, 4=Age, 5=Photo, 6=Location
    func stepForProgress(_ index: Int) -> Int {
        return max(0, index - 3)
    }
}

// MARK: - Profile Progress Header
struct OnboardingProfileProgress: View {
    let currentStep: Int // 0: Name, 1: Age, 2: Photo, 3: Location
    let steps = ["Name", "Age", "Photo", "Location"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                VStack(spacing: 4) {
                    Circle()
                        .fill(index <= currentStep ? Color.ejDarkerGreen : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                    
                    Text(steps[index])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(index <= currentStep ? .ejDarkerGreen : .gray)
                }
                .frame(maxWidth: .infinity)
                
                // Connector Line
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Components

struct OnboardingTitle: View {
    let text: String
    let subtitle: String?
    
    init(_ text: String, subtitle: String? = nil) {
        self.text = text
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(text)
                .font(.custom("Futura-Bold", size: 32)) // Trying to match the heavy font
                .fontWeight(.bold) // Fallback
                .foregroundColor(.ejDarkerGreen)
                .multilineTextAlignment(.center)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
}

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 18))
                }
                TextField("", text: $text)
                    .foregroundColor(.black)
                    .font(.system(size: 18))
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
            }
            .padding(.vertical, 8)
            
            Divider()
                .frame(height: 1.5)
                .background(text.isEmpty ? Color.gray.opacity(0.3) : Color.ejDarkerGreen)
        }
        .padding(.horizontal, 4)
    }
}

struct OnboardingButton: View {
    let title: String
    let isDisabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(title: String = "Next", isDisabled: Bool = false, isLoading: Bool = false, action: @escaping () -> Void) {
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
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black) // Design shows black/dark text on lime
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isDisabled ? Color.gray.opacity(0.3) : Color.ejLightGreen)
            .cornerRadius(30)
        }
        .disabled(isDisabled || isLoading)
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
    }
}
