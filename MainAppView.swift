//
//  ContentView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct MainAppView: View {
    @StateObject private var webRTCManager = WebRTCManager()
    @State private var currentTab: Tab = .home

    var body: some View {
        Group {
            if webRTCManager.isInCall {
                // 🔥 Call Mode: Full Screen Overlay
                CallInProgressView(webRTCManager: webRTCManager)
                    .transition(.opacity)
                    .zIndex(100)
            } else {
                // 🏠 Main App Mode: Tab Navigation
                CustomTabBarContainer(selection: $currentTab) {
                    // Switch Content based on selection
                    switch currentTab {
                    case .home:
                        HomeContainerView(webRTCManager: webRTCManager, selection: $currentTab)
                    case .play:
                        GameSelectionView(showBackButton: false)
                    case .discover:
                        LearnerRadarView(onClose: {}, onMessageTap: {
                            withAnimation {
                                currentTab = .message
                            }
                        }, showCloseButton: false)
                    case .message:
                        MessagesCardView()
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: webRTCManager.isInCall)
    }
}

#Preview {
    MainAppView()
}
