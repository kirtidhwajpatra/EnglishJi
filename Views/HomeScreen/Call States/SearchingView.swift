//
//  SearchingView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

struct SearchingView: View {

    @ObservedObject var webRTCManager: WebRTCManager
    
    // Adapted to use manager directly for consistency with previous architecture,
    // or we can keep the onCancel for flexibility.
    // For now, I will wire the button directly to manager.disconnect() inside the view
    // to match how ContentView calls it, or simply use the closure if preferred.
    // Given the previous code, I'll inline the disconnect action for simplicity.
    
    var body: some View {
        ZStack {
            // Background to ensure white text is visible if parent doesn't provide one
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Glassy Card
                VStack(spacing: 30) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 120, height: 120)
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                    
                    Text(webRTCManager.connectionState == "Idle" ? "Searching..." : webRTCManager.connectionState)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    // Debug Log
                    if !webRTCManager.debugLog.isEmpty {
                        Text(webRTCManager.debugLog)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .cornerRadius(30)
                
                Spacer()
                
                Button(action: {
                    webRTCManager.disconnect()
                }) {
                    Text("Cancel Search")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 50)
            }
        }
    }
}
