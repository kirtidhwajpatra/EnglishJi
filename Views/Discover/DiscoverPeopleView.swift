import SwiftUI

// MARK: - Scroll Tracking Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DiscoverPeopleView: View {
    // Navigation/State
    @State private var showFilters = false
    @State private var selectedFilter = "All"
    @State private var viewMode: ViewMode = .cards // Default to preferred Card style
    
    // Scroll & Visibility State
    @State private var showNavigation = true
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    enum ViewMode {
        case list, cards
    }
    
    // Expanded Mock Data with Real Unsplash Images and Richer Colors
    @State private var users: [DiscoverUser] = [
        DiscoverUser(
            name: "Tanmay Gupta",
            gender: .male,
            flag: "🇮🇳",
            bio: "Tech enthusiast & polyglot.\nBuilding fluent conversations 🚀",
            image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop", // Real Portrait
            blobColor: Color(hex: "FFB74D"), // Richer Orange
            accents: [Color(hex: "FFE0B2"), Color(hex: "FFCC80")] // Deep Apricot
        ),
        DiscoverUser(
            name: "Veena Singh",
            gender: .female,
            flag: "🇮🇳",
            bio: "Travel photographer 📸.\nExploring cultures through language.",
            image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop", // Real Portrait
            blobColor: Color(hex: "64B5F6"), // Richer Blue
            accents: [Color(hex: "BBDEFB"), Color(hex: "90CAF9")] // Deep Sky
        ),
        DiscoverUser(
            name: "Takeshi Tanaka",
            gender: .male,
            flag: "🇯🇵",
            bio: "Improving English for business.\nLet's discuss startups!",
            image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
            blobColor: Color(hex: "9E9E9E"), // Richer Grey
            accents: [Color(hex: "F5F5F5"), Color(hex: "E0E0E0")] // Deep Silver
        ),
        DiscoverUser(
            name: "Sophie Martin",
            gender: .female,
            flag: "🇫🇷",
            bio: "Art lover & foodie 🎨.\nLove to chat about cinema.",
            image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
            blobColor: Color(hex: "F06292"), // Richer Pink
            accents: [Color(hex: "F8BBD0"), Color(hex: "F48FB1")] // Deep Rose
        ),
        DiscoverUser(
            name: "Carlos Silva",
            gender: .male,
            flag: "🇧🇷",
            bio: "Football fanatic ⚽️.\nLearning English to travel.",
            image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            blobColor: Color(hex: "FFB74D"),
            accents: [Color(hex: "FFE0B2"), Color(hex: "FFCC80")]
        ),
        DiscoverUser(
            name: "Emily Chen",
            gender: .female,
            flag: "🇬🇧",
            bio: "Student exploring history.\nHappy to help!",
            image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop",
            blobColor: Color(hex: "BA68C8"), // Purple
            accents: [Color(hex: "E1BEE7"), Color(hex: "CE93D8")]
        ),
        DiscoverUser(
            name: "Liam O'Connor",
            gender: .male,
            flag: "🇦🇺",
            bio: "Surfer & Barista ☕️.\nTeaching slang down under.",
            image: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=400&fit=crop",
            blobColor: Color(hex: "FFD54F"),
            accents: [Color(hex: "FFF9C4"), Color(hex: "FFF59D")]
        ),
        DiscoverUser(
            name: "Anya Petrova",
            gender: .female,
            flag: "🇺🇦",
            bio: "Math student & Chess player ♟️.\nLogic and language.",
            image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            blobColor: Color(hex: "4FC3F7"),
            accents: [Color(hex: "E1F5FE"), Color(hex: "B3E5FC")]
        ),
        DiscoverUser(
            name: "Wei Zhang",
            gender: .male,
            flag: "🇨🇳",
            bio: "History buff & Tea lover 🍵.\nLet's swap stories.",
            image: "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=400&h=400&fit=crop",
            blobColor: Color(hex: "E57373"),
            accents: [Color(hex: "FFEBEE"), Color(hex: "FFCDD2")]
        ),
        DiscoverUser(
            name: "Sofia Rossi",
            gender: .female,
            flag: "🇮🇹",
            bio: "Architect in training 🏛️.\nPizza, Pasta, and Design.",
            image: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop",
            blobColor: Color(hex: "81C784"),
            accents: [Color(hex: "F1F8E9"), Color(hex: "DCEDC8")]
        ),
        DiscoverUser(
            name: "Ahmed Hassan",
            gender: .male,
            flag: "🇪🇬",
            bio: "Archeology student 🐪.\nUncovering the past.",
            image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            blobColor: Color(hex: "A1887F"),
            accents: [Color(hex: "D7CCC8"), Color(hex: "BCAAA4")]
        ),
        DiscoverUser(
            name: "Lars Jensen",
            gender: .male,
            flag: "🇸🇪",
            bio: "Minimalist Designer.\nCoffee and code.",
            image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            blobColor: Color(hex: "90A4AE"),
            accents: [Color(hex: "CFD8DC"), Color(hex: "B0BEC5")]
        )
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background depending on mode
            if viewMode == .cards {
                Color(hex: "FAFAF9").ignoresSafeArea() // Warm off-white
            } else {
                Color.white.ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header Placeholder to push content down when header is visible
                // But since we want to slide it up, we'll overlay it in ZStack and manipulate padding
                
                if viewMode == .cards {
                    // MARK: 3D CARD MODE
                     GeometryReader { fullGeo in
                        ScrollView(.vertical, showsIndicators: false) {
                            // Scroll Tracker
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                            }
                            .frame(height: 0)
                            
                            LazyVStack(spacing: 20) {
                                ForEach(users) { user in
                                    DiscoverCardContainer(user: user, parentHeight: fullGeo.size.height)
                                        .frame(height: 520)
                                }
                            }
                            .padding(.top, 80) // Initial padding for header
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                        }
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            handleScroll(value: value)
                        }
                    }
                    .transition(.opacity)
                } else {
                    // MARK: LIST MODE (Classic)
                    ScrollView {
                        // Scroll Tracker
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                        }
                        .frame(height: 0)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(users) { user in
                                UserRow(user: user)
                                Divider()
                                    .background(Color.gray.opacity(0.1))
                                    .padding(.leading, 100)
                                    .padding(.trailing, 24)
                            }
                        }
                        .padding(.top, 80) // Initial padding for header
                        .padding(.top, 10)
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        handleScroll(value: value)
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            
            // Header (Overlay)
            HStack {
                Text("Discover")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1F3B34"))
                
                Spacer()
                
                // View Mode Toggle
                HStack(spacing: 0) {
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewMode = .list 
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(viewMode == .list ? .white : .gray)
                            .frame(width: 36, height: 32)
                            .background(viewMode == .list ? Color(hex: "1F3B34") : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewMode = .cards 
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(viewMode == .cards ? .white : .gray)
                            .frame(width: 36, height: 32)
                            .background(viewMode == .cards ? Color(hex: "1F3B34") : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.trailing, 10)
                
                // Filter Icon
                Button(action: {
                    withAnimation(.spring()) {
                        showFilters.toggle()
                    }
                }) {
                     FilterIcon()
                        .frame(width: 24, height: 18)
                        .foregroundColor(Color(hex: "1F3B34"))
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color.white.opacity(viewMode == .cards ? 0.95 : 1)) // No Blur, just opacity
            .offset(y: showNavigation ? 0 : -150) // Slide up to hide
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showNavigation)
            
        }
        .customTabBarHidden(!showNavigation) // Hide Tab Bar based on scroll
    }
    
    // Scroll Logic
    func handleScroll(value: CGFloat) {
        let diff = value - lastScrollOffset
        
        // Lower threshold for better responsiveness
        if abs(diff) > 4 {
            if diff < 0 {
                // Scrolling Down -> Hide
                if showNavigation {
                    withAnimation { showNavigation = false }
                }
            } else {
                // Scrolling Up -> Show
                if !showNavigation {
                    withAnimation { showNavigation = true }
                }
            }
            lastScrollOffset = value
        }
    }
}

// MARK: - [CARD MODE] 3D Card Container
struct DiscoverCardContainer: View {
    let user: DiscoverUser
    let parentHeight: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .global)
            let midY = frame.midY
            let screenHeight = UIScreen.main.bounds.height
            let screenCenter = screenHeight / 2
            
            // Distance from center
            let distance = abs(midY - screenCenter)
            let maxDistance = screenHeight / 2
            
            // Physics (Scale & Opacity only, NO BLUR)
            let scale = max(0.9, 1.0 - (distance / maxDistance) * 0.15)
            let rotation = (midY - screenCenter) / 20
            let opacity = max(0.6, 1.0 - (distance / maxDistance) * 0.5)
            // Blur removed as requested
            
            let isFocused = distance < 120
            
            DiscoverCard(user: user, isFocused: isFocused)
                .rotation3DEffect(
                    .degrees(Double(-rotation)),
                    axis: (x: 1, y: 0, z: 0)
                )
                .scaleEffect(scale)
                .opacity(opacity)
                .onChange(of: isFocused) { newValue in
                    if newValue {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
        }
    }
}

// MARK: - [CARD MODE] Visual Design
struct DiscoverCard: View {
    let user: DiscoverUser
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 36)
                .fill(
                    LinearGradient(
                        colors: user.accents ?? [.white, .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Shadows Removed
                
            
            VStack(spacing: 24) {
                // Profile Image (Async for Real Photos)
                ZStack {
                    AsyncImage(url: URL(string: user.image)) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.1)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(user.image) // Fallback
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 170, height: 170) // Full size
                    .background(Color.white) // Prevent see-through on load
                    .clipShape(ScallopedProfileShape()) // Clip to shape
                    // No border, no shadows
                    
                    // Flag Badge
                    Text(user.flag)
                        .font(.system(size: 36))
                        .offset(x: 55, y: -55)
                        // No Shadow
                }
                .padding(.top, 50)
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isFocused)
                
                // Info
                VStack(spacing: 12) {
                    Text(user.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "1F3B34"))
                    
                    Text(user.bio)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "1F3B34").opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineLimit(3)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                // Action Button (Send) - High Contrast
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1F3B34")) // Dark Green
                            .frame(width: 80, height: 80)
                            // No Shadow
                        
                        PaperPlaneIcon()
                            .frame(width: 42, height: 42)
                            .offset(x: -2, y: 4)
                            .foregroundColor(Color(hex: "DDEE88")) // Lime Green
                            .scaleEffect(1.1)
                    }
                }
                .buttonStyle(BouncyButtonStyle())
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - [LIST MODE] Classic Row Design
struct UserRow: View {
    let user: DiscoverUser
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Avatar with Scalloped (Wavy) Background
            ZStack(alignment: .topLeading) {
                ScallopedProfileShape()
                    .fill(user.blobColor)
                    .frame(width: 75, height: 75)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Unified Image Logic
                AsyncImage(url: URL(string: user.image)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                         Image(user.image) // Fallback
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(width: 75, height: 75)
                .clipShape(ScallopedProfileShape())
                
                Text(user.flag)
                    .font(.system(size: 14))
                    .padding(5)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: -2, y: 0)
            }
            .padding(.vertical, 12)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color(hex: "1F3B34"))
                    
                    Image(systemName: user.gender == .male ? "mars" : "venus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(user.gender == .male ? .blue : .pink)
                }
                
                Text(user.bio)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray)
                    .lineSpacing(2)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Action Button
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "DDEE88"))
                        .frame(width: 46, height: 46)
                    
                    PaperPlaneIcon()
                        .frame(width: 25, height: 25)
                        .offset(x: 1, y: 3)
                        .scaleEffect(1.0)
                }
            }
            .buttonStyle(BouncyButtonStyle())
            .offset(x: 0, y: -8)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

// MARK: - Shape & Models

struct ScallopedProfileShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let bumps = 8
        let amplitude = radius * 0.08
        
        var path = Path()
        
        // Increase resolution: 0.5 degree steps instead of 1 degree
        // 720 steps ensures smooth curves on Retina displays
        for i in stride(from: 0, through: 360, by: 0.5) {
            let angle = i * .pi / 180
            let r = radius + amplitude * cos(Double(bumps) * angle)
            
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct DiscoverUser: Identifiable {
    let id = UUID()
    let name: String
    let gender: Gender
    let flag: String
    let bio: String
    let image: String
    let blobColor: Color
    var accents: [Color]?
    
    enum Gender { case male, female }
}

#Preview {
    DiscoverPeopleView()
}
