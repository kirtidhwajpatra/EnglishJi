//
//  HomeView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)

                Text("English Talk")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Practice speaking with learners worldwide.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                let userId = AuthManager.shared.user?.uid ?? UUID().uuidString
                webRTCManager.startMatchmaking(userId: userId)

            } label: {
                Text("Connect Now")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(50)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
            }
            .padding(.horizontal, 40)

            Spacer().frame(height: 50)
        }
        .padding()
    }
}
