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
struct HomeContainerView: View {

    @ObservedObject var webRTCManager: WebRTCManager
    @Binding var selection: Tab
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
            .allowsHitTesting(false) // 🔥 FIX: Prevent background from blocking touches
        )
    }

    var body: some View {
        ZStack {
            // 1. Persistent Background
            sharedBackground

            // 2. View Switching Logic
            if currentPhase == .inCall {
                // Call View Logic Hoisted to Parent
                Color.clear
            } else {
                // For Home AND Searching, we stay on HomeView.
                // HomeView handles the expansion animation internally.
                HomeView(
                    webRTCManager: webRTCManager,
                    currentPhase: currentPhase,
                    onConnectTap: startMatchmaking,
                    onCancelTap: cancelSearch,
                    onMessageTap: { selection = .message },
                    onGameTap: { selection = .play }
                )
            }
            
            // 3. Call Summary Overlay
            if webRTCManager.showCallSummary {
                CallSummaryView(webRTCManager: webRTCManager)
                    .transition(.move(edge: .bottom))
                    .zIndex(2) // Ensure it sits on top
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
        // 🔥 FIX: Use Consistent User ID (UserManager) instead of random UUID
        // This ensures the Chat Room created matches the one in Chat List
        let userId = UserManager.shared.currentUserId
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
    CustomTabBarContainer(selection: .constant(.home)) {
        HomeContainerView(webRTCManager: WebRTCManager(), selection: .constant(.home))
    }
}
