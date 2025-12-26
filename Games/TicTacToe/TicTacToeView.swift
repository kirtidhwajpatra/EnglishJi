//
//  TicTacToeView.swift
//  EnglishJi
//

import SwiftUI

struct TicTacToeView: View {

    enum Mark: String {
        case x = "X"
        case o = "O"
    }

    // MARK: - Game State
    @State private var board: [Mark?] = Array(repeating: nil, count: 9)
    @State private var current: Mark = .x
    @State private var winner: Mark? = nil
    @State private var isDraw = false

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - Header
            Text(headerText)
                .font(.headline)
                .foregroundColor(.black.opacity(0.7))
                .animation(.easeInOut, value: headerText)

            // MARK: - Game Card
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 30, y: 10)

                VStack(spacing: 20) {

                    // Grid + Cells
                    ZStack {
                        SketchGrid().allowsHitTesting(false)


                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(90)), count: 3),
                            spacing: 0
                        ) {
                            ForEach(0..<9, id: \.self) { index in
                                CellView(
                                    mark: board[index],
                                    disabled: board[index] != nil || winner != nil
                                ) {
                                    placeMark(at: index)
                                }
                                .frame(width: 90, height: 90)
                            }
                        }
                    }
                    .padding(20)

                    // Result Text
                    if let winner {
                        ResultView(text: "Congratulations 🎉\n\(winner.rawValue) won the game")
                    } else if isDraw {
                        ResultView(text: "It’s a draw 🤝")
                    }

                    // Reset
                    if winner != nil || isDraw {
                        Button("Play Again") {
                            reset()
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.top, 4)
                    }
                }
                .padding(28)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 40)
        .background(Color(red: 247/255, green: 247/255, blue: 247/255))
    }

    // MARK: - Header Text
    private var headerText: String {
        if let winner {
            return "\(winner.rawValue) Wins"
        }
        if isDraw {
            return "Game Draw"
        }
        return "\(current.rawValue)’s Turn"
    }

    // MARK: - Game Logic
    private func placeMark(at index: Int) {
        guard board[index] == nil, winner == nil else { return }

        board[index] = current
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        checkGame()

        if winner == nil && !isDraw {
            current = current == .x ? .o : .x
        }
    }

    private func checkGame() {
        let wins = [
            [0,1,2],[3,4,5],[6,7,8],
            [0,3,6],[1,4,7],[2,5,8],
            [0,4,8],[2,4,6]
        ]

        for line in wins {
            if let a = board[line[0]],
               a == board[line[1]],
               a == board[line[2]] {
                winner = a
                return
            }
        }

        if board.allSatisfy({ $0 != nil }) {
            isDraw = true
        }
    }

    private func reset() {
        withAnimation(.easeInOut) {
            board = Array(repeating: nil, count: 9)
            current = .x
            winner = nil
            isDraw = false
        }
    }
}

#Preview {
    TicTacToeView()
}
