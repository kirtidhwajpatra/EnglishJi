import SwiftUI

// MARK: - Safe Data Model
struct GameItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let bgColor: Color
    let circleColor: Color
    let isNew: Bool? // Optional badge
    
    // Manual Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GameItem, rhs: GameItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Main Screen
struct GameSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var showBackButton: Bool = true
    
    // Theme Colors
    let darkText = Color.ejDarkerGreen // Dark Green text
    
    // Static Data matching the screenshot
    private static let games: [GameItem] = [
        GameItem(
            title: "TicTacToe",
            bgColor: Color(hex: "EF553B"), // Red-ish
            circleColor: Color(hex: "952B1E"), // Dark Red circle
            isNew: true
        ),
        GameItem(
            title: "Ludo",
            bgColor: Color(hex: "5B3D93"), // Purple
            circleColor: Color(hex: "8B5CF6"), // Lighter Purple circle
            isNew: false
        ),
        GameItem(
            title: "Bagh Chal",
            bgColor: Color(hex: "F4C236"), // Yellow/Gold
            circleColor: Color(hex: "D99023"), // Darker Gold circle
            isNew: false
        ),
        GameItem(
            title: "Reunite",
            bgColor: Color(hex: "25528A"), // Dark Blue
            circleColor: Color(hex: "89CFF0"), // Light Blue circle
            isNew: true
        ),
        GameItem(
            title: "Chess",
            bgColor: Color(hex: "EA4C9D"), // Pink
            circleColor: Color(hex: "9D2660"), // Dark Pink circle
            isNew: false
        ),
        GameItem(
            title: "TicTacToe", // Green Variant
            bgColor: Color(hex: "27634C"), // Dark Green
            circleColor: Color(hex: "4ADE80"), // Light Green circle
            isNew: false
        )
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 1. Header
                HStack {
                    // Back Button (Circular Grey)
                    if showBackButton {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.turn.up.left")
                                .font(.system(size: 18, weight: .regular))
                                .padding(14)
                                .background(Color(hex: "F2F2F7"))
                                .clipShape(Circle())
                                .foregroundColor(.black)
                        }
                    } else {
                        Spacer().frame(width: 46) // Balance spacing if hidden
                    }
                    
                    Spacer()
                    
                    // Avatars on Right (Overlapping)
                    ZStack {
                        // Left Avatar (Pink)
                         Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(Color.pink.opacity(0.3))
                            .clipShape(Circle())
                            .offset(x: -12)
                        
                        // Right Avatar (Green)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                            .background(Color.green.opacity(0.3))
                            .clipShape(Circle())
                            .offset(x: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .offset(x: 12)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // 2. Title
                Text("Chose your game")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(darkText)
                    .padding(.top, 24)
                    .padding(.bottom, 30) // Space before grid
                
                // 3. Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(Self.games) { game in
                            NavigationLink(destination: destinationView(for: game)) {
                                GameCard(game: game)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .background(Color.white.ignoresSafeArea())
        }
    }
    
    // Helper to determine destination
    @ViewBuilder
    private func destinationView(for game: GameItem) -> some View {
        if game.title == "TicTacToe" {
            TicTacToeView()
                .navigationBarBackButtonHidden(true)
        } else {
            if #available(iOS 17.0, *) {
                ContentUnavailableView("Coming Soon", systemImage: "gamecontroller.fill")
                    .preferredColorScheme(.dark)
            } else {
                Text("Coming Soon")
                    .foregroundColor(.black) // Change to black for white bg
            }
        }
    }
}

// MARK: - Card Component
struct GameCard: View {
    let game: GameItem
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 32)
                .fill(game.bgColor)
            
            // Center Circle
            Circle()
                .fill(game.circleColor)
                .frame(width: 80, height: 80)
                .offset(y: -15) // Slightly above center
            
            // Title at Bottom
            VStack {
                Spacer()
                Text(game.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 24)
            }
            
            // "New" Badge
            if let isNew = game.isNew, isNew {
                VStack {
                    HStack {
                        Spacer()
                        Text("New")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.ejDarkerGreen) // Dark Text
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.ejLightGreen) // Lime Green
                            .cornerRadius(12)
                            .padding([.top, .trailing], 16)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 180) // Square-ish aspect ratio
        .shadow(color: game.bgColor.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    GameSelectionView()
}
