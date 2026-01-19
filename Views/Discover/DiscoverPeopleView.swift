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
            age: 24,
            image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop", // Real Portrait
            blobColor: Color(hex: "3C3C3C"), // Dark Grey Blob
            cardColor: Color(hex: "E3F2FD"), // Light Blue
            accents: [Color(hex: "FFE0B2"), Color(hex: "FFCC80")] // N/A for new design
        ),
        DiscoverUser(
            name: "Veena Singh",
            gender: .female,
            flag: "🇮🇳",
            bio: "Travel photographer 📸.\nExploring cultures through language.",
            age: 28,
            image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop", // Real Portrait
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "FCE4EC"), // Light Pink
            accents: [Color(hex: "BBDEFB"), Color(hex: "90CAF9")]
        ),
        DiscoverUser(
            name: "Takeshi Tanaka",
            gender: .male,
            flag: "🇯🇵",
            bio: "Improving English for business.\nLet's discuss startups!",
            age: 32,
            image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "F3E5F5"), // Light Purple
            accents: [Color(hex: "F5F5F5"), Color(hex: "E0E0E0")]
        ),
        DiscoverUser(
            name: "Sophie Martin",
            gender: .female,
            flag: "🇫🇷",
            bio: "Art lover & foodie 🎨.\nLove to chat about cinema.",
            age: 26,
            image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "E3F2FD"), // Light Blue
            accents: [Color(hex: "F8BBD0"), Color(hex: "F48FB1")]
        ),
        DiscoverUser(
            name: "Carlos Silva",
            gender: .male,
            flag: "🇧🇷",
            bio: "Football fanatic ⚽️.\nLearning English to travel.",
            age: 23,
            image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "FCE4EC"), // Light Pink
            accents: [Color(hex: "FFE0B2"), Color(hex: "FFCC80")]
        ),
        DiscoverUser(
            name: "Emily Chen",
            gender: .female,
            flag: "🇬🇧",
            bio: "Student exploring history.\nHappy to help!",
            age: 21,
            image: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "F3E5F5"), // Light Purple
            accents: [Color(hex: "E1BEE7"), Color(hex: "CE93D8")]
        ),
        DiscoverUser(
            name: "Liam O'Connor",
            gender: .male,
            flag: "🇦🇺",
            bio: "Surfer & Barista ☕️.\nTeaching slang down under.",
            age: 25,
            image: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "E3F2FD"), // Blue
            accents: [Color(hex: "FFF9C4"), Color(hex: "FFF59D")]
        ),
        DiscoverUser(
            name: "Anya Petrova",
            gender: .female,
            flag: "🇺🇦",
            bio: "Math student & Chess player ♟️.\nLogic and language.",
            age: 22,
            image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "FCE4EC"), // Pink
            accents: [Color(hex: "E1F5FE"), Color(hex: "B3E5FC")]
        ),
        DiscoverUser(
            name: "Wei Zhang",
            gender: .male,
            flag: "🇨🇳",
            bio: "History buff & Tea lover 🍵.\nLet's swap stories.",
            age: 29,
            image: "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "F3E5F5"), // Purple
            accents: [Color(hex: "FFEBEE"), Color(hex: "FFCDD2")]
        ),
        DiscoverUser(
            name: "Sofia Rossi",
            gender: .female,
            flag: "🇮🇹",
            bio: "Architect in training 🏛️.\nPizza, Pasta, and Design.",
            age: 27,
            image: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "E3F2FD"), // Blue
            accents: [Color(hex: "F1F8E9"), Color(hex: "DCEDC8")]
        ),
        DiscoverUser(
            name: "Ahmed Hassan",
            gender: .male,
            flag: "🇪🇬",
            bio: "Archeology student 🐪.\nUncovering the past.",
            age: 30,
            image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "FCE4EC"),
            accents: [Color(hex: "D7CCC8"), Color(hex: "BCAAA4")]
        ),
        DiscoverUser(
            name: "Lars Jensen",
            gender: .male,
            flag: "🇸🇪",
            bio: "Minimalist Designer.\nCoffee and code.",
            age: 28,
            image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            blobColor: Color(hex: "3C3C3C"),
            cardColor: Color(hex: "F3E5F5"),
            accents: [Color(hex: "CFD8DC"), Color(hex: "B0BEC5")]
        )
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                
                // Close Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Action can be added later
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.ejDarkerGreen)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
//                .padding(.bottom, 10)

                // Header
                Text("Find real humans\nbased on your taste🍊")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .kerning(-0.8)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.ejDarkerGreen)
//                    .lineSpacing(-(24 )
                    .padding(.top, 0)
                    .padding(.bottom, 20)
                
                // Filter Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        FilterPill(title: "All", isSelected: false)
                        FilterPill(title: "Gender", isSelected: false, hasArrow: true)
                        FilterPill(title: "Nearby", isSelected: false)
                        FilterPill(title: "Level", isSelected: false, hasArrow: true)
                        FilterPill(title: "Country", isSelected: false)
                        FilterPill(title: "City", isSelected: false)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 30)
                
                // Horizontal Carousel
                GeometryReader { fullGeo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -18) { // Changed to HStack for stability
                            ForEach(users) { user in
                                DiscoverCardContainer(user: user, parentWidth: fullGeo.size.width)
                                    .frame(width: fullGeo.size.width * 0.72, height: fullGeo.size.height)
                            }
                        }
                        .scrollTargetLayoutIfAvailable()
                        .padding(.horizontal, fullGeo.size.width * 0.14) // (100 - 72) / 2 = 14% padding to center
                    }
                    .scrollTargetBehaviorIfAvailable()
                }
                .frame(height: 440) // Reduced Height Further
                
                Spacer()
                
               
            }
        }
    }
}

// MARK: - Carousel Item Container
struct DiscoverCardContainer: View {
    let user: DiscoverUser
    let parentWidth: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .global)
            let midX = frame.midX
            let screenWidth = UIScreen.main.bounds.width
            let screenCenter = screenWidth / 2
            
            // Distance from center
            let distance = abs(midX - screenCenter)
            let maxDistance = screenWidth / 2
            
            // Physics
            let scale = max(0.4, 1.0 - (distance / maxDistance) * 0.2)
            let opacity = max(0.9, 1.0 - (distance / maxDistance) * 0.3)
            
            DiscoverCard(user: user)
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: distance)
        }
    }
}

// MARK: - Visual Card
struct DiscoverCard: View {
    let user: DiscoverUser
    
    var body: some View {
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 48) // Rounded corners to match image
                .fill(user.cardColor)
            
            VStack(spacing: 0) {
                Spacer() 
                
                ZStack(alignment: .center) { // Center alignment for perfect concentric circles
                    // Blob Background (No Image)
                    ScallopedProfileShape(customAmplitude: 5)
                        .fill(user.blobColor) // Dark Blob
                        .frame(width: 200, height: 200) // Slightly smaller than 220 to fit better
                        // Removed User Image as requested
                    
                    // Badges Layer
                    ZStack {
                        // Flag Badge
                        Text(user.flag)
                            .font(.system(size: 22))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white))
                            .overlay(
                                Circle()
                                    .stroke(user.cardColor, lineWidth: 4) // Border same color as card background -> cutout effect
                            )
                            .offset(x: 64, y: -78) // Manual offset from center
                        
                        
                    }
                }
                .frame(height: 220)
                
                Spacer().frame(height: 15)
                
                // Name & Age
                HStack(spacing: 8) {
                    Text("  \(user.name), \(user.age)")
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .foregroundColor(Color.ejDarkerGreen)
                        .padding(.bottom, 8)
                    
                    // Green Dot
                    Circle()
                        .fill(Color(hex: "4CAF50"))
                        .frame(width: 08, height: 08)
                        .overlay(Circle().stroke(Color.white, lineWidth: 0.5))
                        .offset(x: -5, y: -18) // Should be bottom right
                }
                
                
                
                // Bio
                Text("Exploring the platform & trying to\nbuild the fluency...")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.ejDarkerGreen.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20) // Reduced padding
                
                // Buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Follow")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.ejDarkerGreen)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .stroke(Color.ejDarkerGreen, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.ejDarkerGreen)
                                .frame(width: 48, height: 48)
                            
                            PaperPlaneIcon()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.ejLightGreen)
                                .offset(x: 1, y: 02)
                                .scaleEffect(1.6)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 30) // Reduced padding
            }
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    var hasArrow: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.ejDarkerGreen)
            
            if hasArrow {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color.ejDarkerGreen.opacity(0.6))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Shape & Models

struct ScallopedProfileShape: Shape {
    var customAmplitude: CGFloat? = nil
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let bumps = 10 // Increased edges (bumps)
        let amplitude = customAmplitude ?? (radius * 0.05)
        
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
    let age: Int
    let image: String
    let blobColor: Color
    let cardColor: Color
    var accents: [Color]?
    
    enum Gender { case male, female }
}

#Preview {
    DiscoverPeopleView()
}

// MARK: - Extensions
extension View {
    @ViewBuilder
    func scrollTargetBehaviorIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetBehavior(.viewAligned)
        } else {
            self // Fallback for older iOS versions
        }
    }
    
    @ViewBuilder
    func scrollTargetLayoutIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            self.scrollTargetLayout()
        } else {
            self // Fallback for older iOS versions
        }
    }
}
