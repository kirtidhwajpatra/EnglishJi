import SwiftUI

// MARK: - 1. Data Model
enum Tab: String, CaseIterable {
    case home = "Home"
    case play = "Play"
    case discover = "Discover" // Replaced "Online" based on context
    case message = "Message"
    
    // Icon names (Using SF Symbols for preview, easy to swap for Custom PDF Asset names)
    var iconName: String {
        switch self {
        case .home: return "Home"
        case .play: return "Play"
        case .discover: return "Discover"
        case .message: return "Message"
    }
}
}

// MARK: - 1.5 Visibility Preference Key
struct TabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue() || value
    }
}

extension View {
    func customTabBarHidden(_ hidden: Bool) -> some View {
        preference(key: TabBarHiddenPreferenceKey.self, value: hidden)
    }
}

// MARK: - 2. Main Container
struct CustomTabBarContainer<Content: View>: View {
    @Binding var selection: Tab
    @State private var tabs: [Tab] = Tab.allCases
    @State private var isTabBarHidden = false // Local state for visibility
    let content: Content
    
    init(selection: Binding<Tab>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Screen Content
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    // Spacer to prevent content overlapping tab bar
                    Color.clear.frame(height: 80)
                }
            
            // Floating/Fixed Footer
            CustomTabBar(selection: $selection, tabs: tabs)
                .offset(y: isTabBarHidden ? 150 : 0) // Slide down to hide
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTabBarHidden)
                .zIndex(999)
        }
        .ignoresSafeArea(.keyboard)
        .onPreferenceChange(TabBarHiddenPreferenceKey.self) { hidden in
            isTabBarHidden = hidden
        }
    }
}

// MARK: - 3. The Tab Bar Component
struct CustomTabBar: View {
    @Binding var selection: Tab
    let tabs: [Tab]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selection == tab,
                    badgeCount: (tab == .message ? 4 : 0), // Example badge logic
                    onTap: {
                        triggerHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20) // Internal icon padding
        .padding(.vertical, 14)   // Internal vertical padding
        .background(
            ZStack {
                Rectangle()
                    .fill(.thickMaterial) // "Milky" glass effect
                Rectangle()
                    .fill(Color.gray.opacity(0.1)) // Subtle gray tint
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous)) // Squircle Pill
        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 8) // Ambient shadow
        .padding(.horizontal, 22) // Detached from edges (approx 20-25pt)
        .padding(.bottom, 0) // Anchored near bottom (safe area handles spacing)
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - 4. Individual Tab Item with Micro-Interactions
struct TabBarItem: View {
    let tab: Tab
    let isSelected: Bool
    let badgeCount: Int
    let onTap: () -> Void
    
    // Local state for the "bounce" animation independent of selection
    @State private var isBouncing = false
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                // Icon Layer
                // Note: Use Image(tab.iconName) for Custom Assets (PDFs)
                // Using Image(systemName:) here for Preview functionality
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .scaleEffect(isSelected ? 1.15 : 1.09) // Scale up on selection
                    .offset(y: isSelected ? -1 : 0)       // Lift up on selection
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                    // The "Pop" Animation Logic
                    .scaleEffect(isBouncing ? 0.9 : 1.0) // Micro-compress effect
                
                // Badge Layer (Static - does not animate with icon)
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color(red: 0.9, green: 0.2, blue: 0.4)) // Pink/Red Badge
                        .clipShape(Circle())
                        .offset(x: 8, y: -10) // Position relative to icon center
                        // Ensure badge doesn't move with the icon's offset
                        .offset(y: isSelected ? 1.5 : 0) // Counteract the lift so badge stays fixed relative to bar
                }
            }
            .frame(height: 30) // Fixed height container for icon area
            
            // Label Layer
            Text(tab.rawValue)
                .font(.system(size: 14, weight: .regular, design: .default))
                .kerning(CGFloat(-0.2))
                .foregroundColor(isSelected ? .black : .gray)
                .opacity(isSelected ? 1.0 : 0.7)
        }
        .frame(maxWidth: .infinity) // Equal width distribution
        .contentShape(Rectangle()) // Make entire area tappable
        .onTapGesture {
            // 1. Trigger Architecture State Change
            onTap()
            
            // 2. Trigger Local "Bounce" Animation
            // Phase 1: Compress (Instant)
            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1.0)) {
                isBouncing = true
            }
            
            // Phase 2: Release (Spring)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 15)) {
                    isBouncing = false
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview
struct AppRootView_Preview: View {
    @State private var currentTab: Tab = .home
    
    var body: some View {
        CustomTabBarContainer(selection: $currentTab) {
            // Mock Content Screens
            ZStack {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()
                
                VStack {
                    Image(systemName: currentTab.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.3))
                    Text("\(currentTab.rawValue) Screen")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    AppRootView_Preview()
}
