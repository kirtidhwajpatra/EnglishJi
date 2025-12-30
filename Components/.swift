import SwiftUI

// MARK: - 1. Tab Enum
// (Rename the strings below to match your exact Asset names in Xcode)
enum Tab: String, CaseIterable {
    case home = "Home"
    case play = "Play"
    case discover = "Discover"
    case message = "Message"
    
    var iconName: String {
        switch self {
        case .home: return "ic_home"      // <--- REPLACE WITH YOUR PDF ASSET NAME
        case .play: return "ic_play"      // <--- REPLACE WITH YOUR PDF ASSET NAME
        case .discover: return "ic_feather"   // <--- REPLACE WITH YOUR PDF ASSET NAME
        case .message: return "ic_message"   // <--- REPLACE WITH YOUR PDF ASSET NAME
        }
    }
}

// MARK: - 2. Container
struct CustomTabBarContainer<Content: View>: View {
    @Binding var selection: Tab
    @State private var tabs: [Tab] = Tab.allCases
    let content: Content
    
    init(selection: Binding<Tab>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80) // Prevents content overlap
                }
            
            CustomTabBar(selection: $selection, tabs: tabs)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - 3. The Bar (With Spacing Fix)
struct CustomTabBar: View {
    @Binding var selection: Tab
    let tabs: [Tab]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selection == tab,
                    badgeCount: (tab == .message ? 4 : 0),
                    onTap: {
                        triggerHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selection = tab
                        }
                    }
                )
                // EXPANDS to fill available space equally
                .frame(maxWidth: .infinity)
            }
        }
        // PADDING FIX: Pushes the outer icons inward for "breathing room"
        .padding(.horizontal, 25)
        .padding(.vertical, 12)
        .background(
            Color.white
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
        // Ensures background covers the Home Bar area
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - 4. Tab Item (With Physics & PDF Support)
struct TabBarItem: View {
    let tab: Tab
    let isSelected: Bool
    let badgeCount: Int
    let onTap: () -> Void
    
    // Internal state for the "Micro-Bounce" animation
    @State private var isBouncing = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                
                // ICON LOGIC
                Image(tab.iconName)
                    .renderingMode(.template) // <--- CRITICAL for changing colors
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    // Color Logic
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                    
                    // SELECTION ANIMATION (Lift & Scale)
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .offset(y: isSelected ? -6 : 0)
                
                    // TAP PHYSICS (The Micro-Bounce)
                    .scaleEffect(isBouncing ? 0.9 : 1.0)
                
                // BADGE LOGIC
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color(red: 0.9, green: 0.2, blue: 0.4))
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                        // Keeps badge stable when icon lifts
                        .offset(y: isSelected ? 6 : 0)
                }
            }
            .frame(height: 30) // Stable container height
            
            // LABEL LOGIC
            Text(tab.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .black : .gray)
                .opacity(isSelected ? 1.0 : 0.7)
        }
        .contentShape(Rectangle()) // Makes the whole area tappable
        .onTapGesture {
            onTap()
            
            // PHYSICS ENGINE
            // 1. Compress (Instant)
            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1.0)) {
                isBouncing = true
            }
            
            // 2. Release (Spring back)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 15)) {
                    isBouncing = false
                }
            }
        }
    }
}
