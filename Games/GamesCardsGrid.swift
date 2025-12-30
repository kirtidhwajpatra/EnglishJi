import SwiftUI

// MARK: - 1. Safe Data Model
struct GameItem: Identifiable, Hashable {
    let id = UUID()
    let rank: String
    let title: String
    let subtitle: String
    let iconName: String
    let buttonText: String
    // We exclude colors from Hashable to prevent bugs
    let startColor: Color
    let endColor: Color
    
    // Manual Hashable: Only hashes ID to ensure stability
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GameItem, rhs: GameItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 2. The Main Screen
struct GameSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var showBackButton: Bool = true // Added control
    
    // Data with "TicTacToe" (Exact String Match)
    // 🔥 FIXED: Made static to ensure IDs don't change on View re-init
    private static let games: [GameItem] = [
        GameItem(
            rank: "1",
            title: "TicTacToe", // ⚠️ MUST MATCH logic below
            subtitle: "Epic PvP Card Battle",
            iconName: "shield.swords.fill",
            buttonText: "Play",
            startColor: Color(red: 0.6, green: 0.4, blue: 0.2),
            endColor: Color(red: 0.4, green: 0.25, blue: 0.1)
        ),
        GameItem(
            rank: "2",
            title: "MONOPOLY GO!",
            subtitle: "Roll, Build, Dream",
            iconName: "building.2.fill",
            buttonText: "View",
            startColor: Color(red: 0.9, green: 0.3, blue: 0.3),
            endColor: Color(red: 0.7, green: 0.1, blue: 0.1)
        ),
        GameItem(
            rank: "3",
            title: "Hay Day",
            subtitle: "Farming simulation",
            iconName: "leaf.fill",
            buttonText: "Play",
            startColor: Color(red: 0.6, green: 0.3, blue: 0.8),
            endColor: Color(red: 0.4, green: 0.1, blue: 0.6)
        ),
        GameItem(
            rank: "4",
            title: "Among Us",
            subtitle: "Space betrayal",
            iconName: "figure.stand",
            buttonText: "View",
            startColor: Color(red: 1.0, green: 0.8, blue: 0.2),
            endColor: Color(red: 0.8, green: 0.6, blue: 0.0)
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Back Button
                    if showBackButton {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                       
                        
                        HStack {
                           
                            
                            Image(systemName: "gamecontroller.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                            
                            Text("Top Played Games")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
//                            Image(systemName: "chevron.right")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Self.games) { game in
                            // 🔥 FIXED: Using direct destination to guarantee navigation works
                            NavigationLink(destination: destinationView(for: game)) {
                                GameCard(game: game)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.black.ignoresSafeArea())
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
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 3. The Card Component (NO BUTTONS inside)
struct GameCard: View {
    let game: GameItem
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            LinearGradient(
                colors: [game.startColor, game.endColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Rank
            Text(game.rank)
                .font(.system(size: 100, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.15))
                .offset(x: -10, y: -25)
            
            // Content
            VStack(alignment: .leading) {
                // Icon
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: game.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                // Titles
                Text(game.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(game.subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .padding(.bottom, 12)
                
                // FAKE Button (Visual Only)
                Text(game.buttonText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background(Capsule().fill(.white.opacity(0.25)))
                    .padding(.top, 6)
            }
            .padding(16)
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contentShape(Rectangle()) // Ensures tap works everywhere
    }
}

#Preview {
    GameSelectionView()
}
