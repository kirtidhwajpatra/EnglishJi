import SwiftUI

// MARK: - Main View
struct TicTacToeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TicTacToeViewModel()
    
    // Simulate Loading State
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isLoading {
                LoadingScreen()
                    .transition(.opacity)
                    .onAppear {
                        // Fake loading delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                GameContent(viewModel: viewModel, onDismiss: { dismiss() })
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - 1. Loading Screen
struct LoadingScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.turn.up.left") // "return" style
                        .font(.system(size: 20))
                        .padding(12)
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                Spacer()
                
                // Avatars
                HStack(spacing: -10) {
                     Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue) // Placeholder
                        .background(Color.white)
                        .clipShape(Circle())
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.purple) // Placeholder
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            .padding()
            
            Spacer()
            
            // App Icon Style
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(hex: "EF553B")) // Red color
                    .frame(width: 140, height: 140)
                    .shadow(color: Color(hex: "EF553B").opacity(0.3), radius: 15, y: 10)
                
                Circle()
                    .fill(Color(hex: "952B1E")) // Darker red
                    .frame(width: 60, height: 60)
                    .offset(y: -10)
                
                Text("TicTacToe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .offset(y: 40)
                
                // New Badge
                Text("New")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.ejDarkerGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.ejLightGreen)
                    .cornerRadius(12)
                    .position(x: 140-20, y: 20) // Approximate
                    .offset(x: -70 + 20, y: -70 + 20) // Adjusting to frame
            }
            
            Spacer()
            
            Text("Loading...")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - 2. Game Content
struct GameContent: View {
    @ObservedObject var viewModel: TicTacToeViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            // Header
            HStack(alignment: .top) {
                Button(action: onDismiss) {
                    Image(systemName: "arrow.turn.up.left")
                        .font(.system(size: 20))
                        .padding(12)
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Scoreboard Card
                HStack(spacing: 0) {
                    // Player 1
                    VStack {
                        Image(systemName: "person.crop.circle.fill") // Avatar
                             .resizable()
                             .frame(width: 32, height: 32)
                             .foregroundColor(.purple)
                        Text("\(viewModel.p1Score)")
                            .font(.system(size: 24, weight: .regular))
                    }
                    .frame(width: 60)
                    
                    Divider().frame(height: 40)
                    
                    // Player 2
                    VStack {
                        Image(systemName: "person.crop.circle.fill") // Avatar
                             .resizable()
                             .frame(width: 32, height: 32)
                             .foregroundColor(.black)
                        Text("\(viewModel.p2Score)")
                            .font(.system(size: 24, weight: .regular))
                    }
                    .frame(width: 60)
                }
                .padding(.vertical, 8)
                .background(Color(hex: "F2F2F7"))
                .cornerRadius(16)
            }
            .padding()
            
            Spacer()
            
            // Win Message
            if case .won(let player) = viewModel.gameState {
                VStack(spacing: 4) {
                    Text("Congratulations🎉")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text(player == .p1 ? "Veena" : "Opponent") // Placeholder name
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.black)
                }
                .padding(.bottom, 20)
                .transition(.scale)
            } else if case .draw = viewModel.gameState {
                Text("Draw!")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
            }
            
            // Game Board (Paper Style)
            ZStack {
                // Background Lines
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F2F2F7").opacity(0.5)) // Light paper bg
                    .frame(width: 340, height: 360)
                
                VStack(spacing: 38) { // Horizontal lines
                    ForEach(0..<9) { _ in
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                    }
                }
                .frame(width: 340, height: 340)
                .clipped()
                
                // Grid Lines (Main Black Lines)
                VStack(spacing: 110) { // Horizontal dividers
                     Rectangle().fill(Color.black.opacity(0.8)).frame(height: 1.5).frame(width: 250)
                     Rectangle().fill(Color.black.opacity(0.8)).frame(height: 1.5).frame(width: 250)
                }
                
                HStack(spacing: 110) { // Vertical dividers
                    Rectangle().fill(Color.black.opacity(0.8)).frame(width: 1.5).frame(height: 250)
                    Rectangle().fill(Color.black.opacity(0.8)).frame(width: 1.5).frame(height: 250)
                }
                
                // Tokens
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: 0), count: 3), spacing: 0) {
                    ForEach(0..<9) { index in
                        ZStack {
                            Rectangle().fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.processMove(at: index)
                                }
                            
                            if let player = viewModel.board[index] {
                                Text(player == .p1 ? "🍄" : "🌼") // User specific icons
                                    .font(.system(size: 50))
                            }
                        }
                        .frame(width: 100, height: 100)
                    }
                }
            }
            .frame(width: 350, height: 350)
            
            Spacer()
            
            // Bottom Controls
            if viewModel.gameState == .active {
                // Active Turn Indicator
                HStack(spacing: 20) {
                    CircleIcon(icon: "🍄", isActive: viewModel.activePlayer == .p1)
                    CircleIcon(icon: "🌼", isActive: viewModel.activePlayer == .p2)
                }
            } else {
                // Play Again Button
                Button(action: {
                    viewModel.resetGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.ejDarkerGreen)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.ejLightGreen) // Lime Green
                    .cornerRadius(30)
                }
            }
            
            Spacer()
        }
    }
}

struct CircleIcon: View {
    let icon: String
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                .overlay(
                    Circle().stroke(isActive ? Color.green : Color.clear, lineWidth: 2)
                )
            
            Text(icon)
                .font(.system(size: 24))
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.spring(), value: isActive)
    }
}

#Preview {
    TicTacToeView()
}
