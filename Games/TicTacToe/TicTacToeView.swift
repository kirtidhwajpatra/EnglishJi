import SwiftUI

// MARK: - Main Coordinator
struct TicTacToeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TicTacToeViewModel()
    @State private var showingGame = false
    
    var body: some View {
        ZStack {
            TicTacToeTheme.background.ignoresSafeArea()
            
            if showingGame {
                GameScreen(viewModel: viewModel, onBack: {
                    showingGame = false
                    viewModel.resetGame()
                    viewModel.p1Score = 0
                    viewModel.p2Score = 0
                })
                .transition(.move(edge: .trailing))
            } else {
                MenuScreen(onStart: { mode in
                    viewModel.gameMode = mode
                    viewModel.resetGame()
                    withAnimation(.spring()) {
                        showingGame = true
                    }
                }, onDismiss: { dismiss() })
                .transition(.move(edge: .leading))
            }
        }
    }
}

// MARK: - 1. Menu Screen
struct MenuScreen: View {
    let onStart: (GameMode) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // Header with Back Button
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
            
            Text("TicTacToe")
                .font(.system(size: 45, weight: .black, design: .rounded))
                .foregroundStyle(TicTacToeTheme.accent)
                .shadow(color: TicTacToeTheme.accent.opacity(0.3), radius: 10, x: 0, y: 0)
            
            VStack(spacing: 16) {
                MenuButton(title: "Play with Friend") { onStart(.vsHuman) }
                MenuButton(title: "Play with Machine", isOutlined: true) { onStart(.vsMachine) }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct MenuButton: View {
    let title: String
    var isOutlined: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isOutlined ? .white.opacity(0.5) : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(isOutlined ? Color.clear : TicTacToeTheme.accent)
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.2), lineWidth: isOutlined ? 1 : 0)
                        )
                )
        }
    }
}

// MARK: - 2. Game Screen
struct GameScreen: View {
    @ObservedObject var viewModel: TicTacToeViewModel
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            TicTacToeTheme.background.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    
                    Spacer()
                    
                    // Score Board
                    HStack(spacing: 15) {
                        ScorePill(icon: TicTacToeTheme.player1Icon, score: viewModel.p1Score)
                        ScorePill(icon: TicTacToeTheme.player2Icon, score: viewModel.p2Score)
                    }
                }
                .padding()
                
                Spacer()
                
                // The Grid
                ZStack {
                    // Custom Drawn Grid Lines
                    GridLines()
                    
                    // The Cells
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 0) {
                        ForEach(0..<9) { index in
                            CellView(
                                player: viewModel.board[index],
                                isWinning: viewModel.winningIndices.contains(index)
                            ) {
                                viewModel.processMove(at: index)
                            }
                            .frame(height: 100) // Fixed height for square feel
                        }
                    }
                }
                .padding(20)
                
                Spacer()
                
                // Footer Placeholder (Balancing the UI)
                Color.clear.frame(height: 50)
            }
            .blur(radius: viewModel.gameState == .active ? 0 : 5) // Blur when game over
            
            // Result Overlay
            if viewModel.gameState != .active {
                ResultView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - 3. Components

struct GridLines: View {
    var body: some View {
        VStack(spacing: 100) { // Adjust based on cell height
            Divider().background(TicTacToeTheme.gridLine)
            Divider().background(TicTacToeTheme.gridLine)
        }
        .frame(height: 300)
        
        HStack(spacing: 0) {
            Spacer()
            Rectangle().fill(TicTacToeTheme.gridLine).frame(width: 1).frame(height: 300)
            Spacer()
            Rectangle().fill(TicTacToeTheme.gridLine).frame(width: 1).frame(height: 300)
            Spacer()
        }
        .padding(.horizontal, 20) // Adjust to inset lines slightly like designs
    }
}

struct CellView: View {
    let player: Player?
    let isWinning: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle().fill(Color.black.opacity(0.01)) // Tappable area
                
                if let player = player {
                    Text(player.icon)
                        .font(.system(size: 50))
                        .shadow(color: isWinning ? TicTacToeTheme.accent : .clear, radius: 10)
                        .scaleEffect(isWinning ? 1.2 : 1.0)
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain) // Removes default button fade
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: player)
        .animation(.easeInOut.repeatForever(autoreverses: true), value: isWinning)
    }
}

struct ResultView: View {
    @ObservedObject var viewModel: TicTacToeViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.resultEmoji)
                .font(.system(size: 60))
            
            Text(viewModel.resultMessage)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Reusing the grid display for the result screen (Optional, seen in screenshot)
            // But for minimalist UX, just the button is better:
            
            Button(action: { viewModel.resetGame() }) {
                Text("Play again")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Capsule().fill(TicTacToeTheme.accent))
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .transition(.opacity)
    }
}

struct ScorePill: View {
    let icon: String
    let score: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Text(icon).font(.subheadline)
                .font(.system(size: 28))
            Text("\(score)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}
