import SwiftUI

struct DiscoverPeopleView: View {
    // Navigation/State
    @State private var showFilters = false
    @State private var selectedFilter = "All"
    
    // Mock Data based on Request
    @State private var users: [DiscoverUser] = [
        DiscoverUser(
            name: "Tanmay Gupta",
            gender: .male,
            flag: "🇮🇳",
            bio: "Tech enthusiast & polyglot. Building fluent conversations 🚀",
            image: "User1",
            blobColor: Color(hex: "F8C568") // Orange
        ),
        DiscoverUser(
            name: "Veena Singh",
            gender: .female,
            flag: "🇮🇳",
            bio: "Travel photographer 📸. Exploring cultures through language.",
            image: "User2",
            blobColor: Color(hex: "D8E6F5") // Light Blue
        ),
        DiscoverUser(
            name: "Takeshi Tanaka",
            gender: .male,
            flag: "🇯🇵",
            bio: "Improving English for business. Let's discuss startups!",
            image: "User3",
            blobColor: Color(hex: "333333") // Dark Grey
        ),
        DiscoverUser(
            name: "Sophie Martin",
            gender: .female,
            flag: "🇫🇷",
            bio: "Art lover & foodie 🎨. Love to chat about cinema.",
            image: "User4",
            blobColor: Color(hex: "E5E5EA") // Light Grey
        ),
        DiscoverUser(
            name: "Carlos Silva",
            gender: .male,
            flag: "🇧🇷",
            bio: "Football fanatic ⚽️. Learning English to travel the world.",
            image: "User1",
            blobColor: Color(hex: "F8C568") // Reuse Orange
        ),
        DiscoverUser(
            name: "Emily Chen",
            gender: .female,
            flag: "🇬🇧",
            bio: "Student exploring history and literature. Happy to help!",
            image: "User2",
            blobColor: Color(hex: "D8E6F5") // Reuse Light Blue
        )
    ]
    
    let filters = ["All", "Gender", "Nearby", "Level", "Country", "City"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            HStack {
                Spacer()
                Text("Find real humans🍊")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "1F3B34"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        showFilters.toggle()
                        // Haptic feedback for toggle
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }) {
                    ZStack {
                        // Circle Button
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                            .background(Circle().fill(Color.white))
                            .frame(width: 44, height: 44)
                        
                        // Icon switch
                        if showFilters {
                            CancelIcon()
                                .frame(width: 16, height: 16) // Increased from 12
                                .scaleEffect(1.4) // Slightly larger for visibility)
                        } else {
                            FilterIcon()
                                .frame(width: 24, height: 18) // Increased from 18x14
                                .scaleEffect(1.4)
                        }
                    }
                }
                .buttonStyle(BouncyButtonStyle()) // Added Bouncy Effect
            }
            .padding(.horizontal, 24) // Match design spacing
            .padding(.vertical, 14)
            .background(Color.white)
            
            // 2. Filters (Collapsible)
            if showFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { filter in
                            Button(action: { 
                                selectedFilter = filter
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                            }) {
                                HStack(spacing: 4) {
                                    Text(filter)
                                        .font(.system(size: 14, weight: .regular))
                                    if filter != "All" {
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedFilter == filter ? Color(hex: "F2F2F7") : Color.white) // Subtle selection state
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundColor(Color(hex: "1F3B34"))
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // 3. User List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(users) { user in
                        UserRow(user: user)
                        // Custom Divider logic: leading padding to align with text
                        Divider()
                            .background(Color.gray.opacity(0.1))
                            .padding(.leading, 100) // Adjusted for smaller avatar (was 120)
                            .padding(.trailing, 24)
                    }
                }
                .padding(.top, 10)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Components

struct UserRow: View {
    let user: DiscoverUser
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Avatar with Scalloped (Wavy) Background
            ZStack(alignment: .topLeading) {
                // Background
                ScallopedProfileShape()
                    .fill(user.blobColor) // Design specific color
                    .frame(width: 75, height: 75) // Slightly larger to accommodate waves
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Image (Masked)
                Image(user.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 75, height: 75)
                    .clipShape(ScallopedProfileShape())
                    // Fallback visual
                    .overlay(
                        Color.clear
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35)
                                    .foregroundColor(.white.opacity(0.5))
                                    .offset(y: 5)
                            )
                            .opacity(UIImage(named: user.image) == nil ? 1 : 0)
                    )
                
                // Flag Badge (Top Left)
                // Position adjustment for the wavy shape
                Text(user.flag)
                    .font(.system(size: 14))
                    .padding(5)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: -2, y: 0) // Adjusted for wavy edge
            }
            .padding(.vertical, 12)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.system(size: 22, weight: .regular)) // Large, readable
                        .foregroundColor(Color(hex: "1F3B34"))
                    
                    // Gender Symbol
                    Image(systemName: user.gender == .male ? "mars" : "venus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(user.gender == .male ? .blue : .pink)
                }
                
                Text(user.bio)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.gray)
                    .lineSpacing(2)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Action Button
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "DDEE88")) // Lime Green
                        .frame(width: 46, height:46) // Increased from 44 to 56 for Main CTA
                    
                    PaperPlaneIcon() // Custom Icon
                         // Increased from 20 to 28
                        .offset(x: 1, y: 3) // Adjusted Optical center
                        .frame(width: 45, height: 45)
                        .scaleEffect(1.6)
                }
            }
            .offset(x: 0, y: -8) // Slightly lower for alignment
            .buttonStyle(BouncyButtonStyle()) // Bouncy Touch
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

// Custom Scalloped Shape (Wavy Circle)
struct ScallopedProfileShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let bumps = 8 // Number of lobes/waves
        let amplitude = radius * 0.08 // Depth of the wave as % of radius
        
        var path = Path()
        
        for i in 0..<360 {
            let angle = Double(i) * .pi / 180
            // r = R + A * cos(N * theta)
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

// Data Models
struct DiscoverUser: Identifiable {
    let id = UUID()
    let name: String
    let gender: Gender
    let flag: String
    let bio: String
    let image: String
    let blobColor: Color
    
    enum Gender { case male, female }
}

#Preview {
    DiscoverPeopleView()
}
