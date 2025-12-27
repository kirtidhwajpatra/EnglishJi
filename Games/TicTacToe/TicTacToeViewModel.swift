import SwiftUI
import Combine

class TicTacToeViewModel: ObservableObject {
    @Published var board: [Player?] = Array(repeating: nil, count: 9)
    @Published var activePlayer: Player = .p1
    @Published var gameState: GameState = .active
    @Published var winningIndices: Set<Int> = []
    
    // Scores
    @Published var p1Score = 0
    @Published var p2Score = 0
    
    var gameMode: GameMode = .vsHuman
    
    private let winPatterns: Set<Set<Int>> = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]
    
    // MARK: - Game Action
    func processMove(at index: Int) {
        guard board[index] == nil, case .active = gameState else { return }
        
        // 1. Human Move
        makeMove(index: index, player: activePlayer)
        
        // 2. Check Result
        if case .active = gameState, gameMode == .vsMachine, activePlayer == .p2 {
            // 3. Machine Move (Delayed for realism)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeAIMove()
            }
        }
    }
    
    private func makeMove(index: Int, player: Player) {
        board[index] = player
        HapticManager.shared.lightImpact()
        
        if checkForWin(player: player) {
            gameState = .won(player)
            if player == .p1 { p1Score += 1 } else { p2Score += 1 }
            HapticManager.shared.successFeedback()
        } else if !board.contains(nil) {
            gameState = .draw
            HapticManager.shared.drawFeedback()
        } else {
            activePlayer = player.next
        }
    }
    
    // MARK: - AI Logic
    private func makeAIMove() {
        // Simple AI: 1. Try to Win, 2. Block Opponent, 3. Random
        let availableMoves = board.indices.filter { board[$0] == nil }
        guard let move = findBestMove(availableMoves: availableMoves) else { return }
        makeMove(index: move, player: .p2)
    }
    
    private func findBestMove(availableMoves: [Int]) -> Int? {
        // A. Check for winning move
        for i in availableMoves {
            if wouldWin(index: i, player: .p2) { return i }
        }
        // B. Check for blocking move
        for i in availableMoves {
            if wouldWin(index: i, player: .p1) { return i }
        }
        // C. Center or Random
        if availableMoves.contains(4) { return 4 }
        return availableMoves.randomElement()
    }
    
    private func wouldWin(index: Int, player: Player) -> Bool {
        var tempBoard = board
        tempBoard[index] = player
        return winPatterns.contains { pattern in
            pattern.allSatisfy { tempBoard[$0] == player }
        }
    }
    
    private func checkForWin(player: Player) -> Bool {
        for pattern in winPatterns {
            if pattern.allSatisfy({ board[$0] == player }) {
                winningIndices = pattern
                return true
            }
        }
        return false
    }
    
    func resetGame() {
        board = Array(repeating: nil, count: 9)
        activePlayer = .p1
        gameState = .active
        winningIndices = []
    }
    
    // Helper Text
    var resultMessage: String {
        switch gameState {
        case .won(let player):
            // Customize based on Single Player or Multiplayer
            if gameMode == .vsMachine && player == .p2 { return "You lose!" }
            return player == .p1 ? "You win!" : "Player 2 Wins!"
        case .draw: return "Draw!"
        case .active: return ""
        }
    }
    
    var resultEmoji: String {
        switch gameState {
        case .won(let player):
            if gameMode == .vsMachine && player == .p2 { return "😓" }
            return "🎉"
        case .draw: return "🤝"
        case .active: return ""
        }
    }
}
