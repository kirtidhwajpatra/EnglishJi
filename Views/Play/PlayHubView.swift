import SwiftUI

struct PlayHubView: View {
    
    // Theme Colors
    // Friends: Pinkish
    let friendsColor = Color(hex: "F9A8D4")
    let friendsIconBg = Color(hex: "9D335D") // Darker Pink/Maroon for circle
    
    // Mate: Purple
    let mateColor = Color(hex: "C4B5FD")
    let mateIconBg = Color(hex: "5B4B8A") // Darker purple
    
    // System: Peach
    let systemColor = Color(hex: "FCA5A5")
    let systemIconBg = Color(hex: "923126") // Dark red/brown
    
    let darkText = Color(hex: "1F3B34") // Dark Green text
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                 
                Spacer()
                
                // 1. Header Text
                Text("Play Games with")
                    .font(.system(size: 28, weight: .regular)) // Slightly larger, regular weight
                    .foregroundColor(darkText)
                
                // 2. Options Grid
                HStack(spacing: 16) {
                    
                    // Option A: Friends
                    NavigationLink(destination: FriendsListView()) {
                        OptionCard(
                            bg: friendsColor,
                            circleColor: friendsIconBg,
                            label: "Friends",
                            textColor: .black
                        ) {
                            Image(systemName: "person.2")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Option B: Mate
                    // Centered content: Two overlapping circles
                    Button(action: {}) {
                        OptionCard(
                            bg: mateColor,
                            circleColor: .clear, // Custom content, no circle bg needed
                            label: "Mate",
                            textColor: .black,
                            customContent: true
                        ) {
                            ZStack {
                                // Left Avatar (Pink glow)
                                Image(systemName: "person.crop.circle.fill") // Placeholder
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.white) // Or actual image
                                    .background(Color.pink.opacity(0.3))
                                    .clipShape(Circle())
                                    .offset(x: -12)
                                
                                // Right Avatar (Blue/Green glow)
                                Image(systemName: "person.crop.circle.fill") // Placeholder
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.black)
                                    .background(Color.green.opacity(0.3))
                                    .clipShape(Circle())
                                    .offset(x: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .offset(x: 12)
                                    )
                                
                                // Red dot (Notification/Status)
                                Circle()
                                    .fill(Color.red.opacity(0.7))
                                    .frame(width: 10, height: 10)
                                    .offset(x: 24, y: -18)
                            }
                        }
                    }
                    
                    // Option C: System
                    NavigationLink(destination: GameSelectionView(showBackButton: true)) {
                        OptionCard(
                            bg: systemColor,
                            circleColor: systemIconBg,
                            label: "System",
                            textColor: .black
                        ) {
                            Image(systemName: "terminal.fill") // "System" icon
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .offset(x: 1, y: 1) // Optical adjustment
                                .overlay(
                                    // Add sparkle or extra detail if needed
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                        .offset(x: 10, y: -10)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color.white.ignoresSafeArea())
        }
    }
}

// MARK: - Generic Option Card
struct OptionCard<Content: View>: View {
    let bg: Color
    let circleColor: Color
    let label: String
    let textColor: Color
    var customContent: Bool = false
    let iconContent: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon Area
            if customContent {
                iconContent()
            } else {
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 56, height: 56)
                    
                    iconContent()
                }
            }
             
            Spacer()
            
            // Label
            Text(label)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(textColor)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160) // Taller square
        .background(bg)
        .cornerRadius(28) // Softer corners
    }
}

#Preview {
    PlayHubView()
}
