//
//  ContentView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI
import AVFoundation
import FirebaseAuth


// MARK: - Root Content View
struct ContentView: View {

    @StateObject private var webRTCManager = WebRTCManager()
    @State private var currentPhase: AppPhase = .home

    // Shared Background for seamless feel
    var sharedBackground: some View {
        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1548783060-cc45d55e0c96?q=80&w=2787&auto=format&fit=crop")) { phase in
            if let image = phase.image {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Color.gray
            }
        }
        .ignoresSafeArea()
        .overlay(
            LinearGradient(
                colors: [.black.opacity(0.6), .black.opacity(0.2), .black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    var body: some View {
        ZStack {
            // 1. Persistent Background
            sharedBackground

            // 2. View Switching Logic
            if currentPhase == .inCall {
                // When in a call, we switch to the dedicated Call Screen
                CallInProgressView(webRTCManager: webRTCManager)
                    .transition(.opacity)
            } else {
                // For Home AND Searching, we stay on HomeView.
                // HomeView handles the expansion animation internally.
                HomeView(
                    webRTCManager: webRTCManager,
                    currentPhase: currentPhase,
                    onConnectTap: startMatchmaking,
                    onCancelTap: cancelSearch
                )
            }
            
            // REMOVED: Sign Out Button block deleted.
        }
        // 🔥 SINGLE SOURCE OF TRUTH FOR CALL UI
        .onChange(of: webRTCManager.isInCall) { inCall in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPhase = inCall ? .inCall : .home
            }
        }
        // 🔥 ERROR HANDLING / IDLE RESET
        .onChange(of: webRTCManager.connectionState) { state in
            withAnimation(.spring()) {
                // If the manager resets to idle (e.g. failed connection), go back to home
                if state == "Idle" && currentPhase == .searching {
                    currentPhase = .home
                }
            }
        }
    }
    
    // MARK: - LOGIC ACTIONS
    
    func startMatchmaking() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // 1. Animate UI immediately
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentPhase = .searching
        }
        
        // 2. Trigger Logic
        let userId = Auth.auth().currentUser?.uid ?? UUID().uuidString
        webRTCManager.startMatchmaking(userId: userId)
    }
    
    func cancelSearch() {
        webRTCManager.disconnect()
        // Animate back to home
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentPhase = .home
        }
    }
}


#Preview {
    ContentView()
}
