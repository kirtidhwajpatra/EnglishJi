//
//  SearchingView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

struct SearchingView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 150, height: 150)

                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            }

            Text(webRTCManager.connectionState)
                .font(.headline)
                .foregroundColor(.secondary)

            ScrollView {
                Text(webRTCManager.debugLog)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(height: 150)
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)

            Spacer()

            Button("Cancel Search") {
                webRTCManager.disconnect()
            }
            .foregroundColor(.red)
            .padding(.bottom, 50)
        }
        .padding()
    }
}
