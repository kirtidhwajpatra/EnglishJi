//
//  TicTacToeGameScreen.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 26/12/25.
//

import SwiftUI

struct TicTacToeGameScreen: View {

    let onClose: () -> Void

    var body: some View {
        ZStack {
            // Clean paper-like background
            Color(red: 247/255, green: 247/255, blue: 247/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // 🔝 Minimal Top Bar
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(14)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 6)
                    }

                    Spacer()

                    Text("Tic Tac Toe")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.8))

                    Spacer()

                    // balance
                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()

                // 🎮 THE GAME (pure & isolated)
                TicTacToeView()
                    .padding(.bottom, 40)

                Spacer()
            }
        }
    }
}

