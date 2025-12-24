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

    // Assuming WebRTCManager is defined elsewhere
    @StateObject private var webRTCManager = WebRTCManager()
    @State private var currentPhase: AppPhase = .home

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            // Switching logic remains the same, but views are now in their own files
            switch currentPhase {
            case .home:
                HomeView(webRTCManager: webRTCManager)

            case .searching:
                SearchingView(webRTCManager: webRTCManager)

            case .inCall:
                CallInProgressView(webRTCManager: webRTCManager)
            }

            VStack {
                Spacer()
                SignOutView()
                    .padding(.bottom, 30)
            }
        }
        // 🔥 SINGLE SOURCE OF TRUTH FOR CALL UI
        .onChange(of: webRTCManager.isInCall) { inCall in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPhase = inCall ? .inCall : .home
            }
        }
        // 🔥 SEARCHING STATE DRIVEN BY CONNECTION STATE
        .onChange(of: webRTCManager.connectionState) { state in
            withAnimation(.easeInOut(duration: 0.3)) {
                if state == "Searching" {
                    currentPhase = .searching
                }
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
