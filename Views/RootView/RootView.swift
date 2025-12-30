//
//  RootView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI

struct RootView: View {
    // Listens to the AuthManager state
    @StateObject private var authManager = AuthManager.shared
    
    // 1. Navigation State (Tracks which tab is active)
    @State private var currentTab: Tab = .home
    
    // 2. WebRTC Manager (Initialized once here to persist across tabs)
    @StateObject private var webRTCManager = WebRTCManager()
    
    var body: some View {
        Group {
            if authManager.user != nil {
                // User is logged in
                ZStack {
                    // 1. The Main Tab Navigation
                    CustomTabBarContainer(selection: $currentTab) {
                        
                        // The "Switchboard" logic
                        switch currentTab {
                        case .home:
                            HomeContainerView(webRTCManager: webRTCManager, selection: $currentTab)
                            
                        case .play:
                            NavigationStack {
                                GameSelectionView(showBackButton: false)
                            }
                            
                        case .discover:
                             LearnerRadarView(onClose: {}, onMessageTap: {
                                withAnimation {
                                    currentTab = .message
                                }
                            }, showCloseButton: false)
                            
                        case .message:
                            NavigationStack {
                                MessagesCardView()
                            }
                        }
                    }
                    .transition(AnyTransition.move(edge: .trailing))
                    
                    // 2. The Call Overlay (High Z-Index)
                    if webRTCManager.isInCall {
                        CallInProgressView(webRTCManager: webRTCManager)
                            .transition(.opacity)
                            .zIndex(100)
                    }
                }
                // Inject WebRTCManager so any tab can use it via @EnvironmentObject
                .environmentObject(webRTCManager)
                
            } else {
                // User is NOT logged in
                OnboardingContainerView()
                    .transition(AnyTransition.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: authManager.user) // Animate the switch
    }
}
