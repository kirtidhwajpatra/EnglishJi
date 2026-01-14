import SwiftUI

struct RootView: View {
    // Listens to the AuthManager state
    @StateObject private var authManager = AuthManager.shared
    
    // 1. Navigation State (Tracks which tab is active)
    @State private var currentTab: Tab = .home
    
    // 2. WebRTC Manager (Initialized once here to persist across tabs)
    @StateObject private var webRTCManager = WebRTCManager()
    
    // 🔥 CALL STATE (Source of Truth)
    @State private var isCallActive = false        // Is a call currently active?
    @State private var isCallMinimized = false     // Is it full screen or bubble?
    @State private var callDurationSeconds = 0     // The counter
    @State private var callTimer: Timer?           // The timer object
    
    var body: some View {
        Group {
            if authManager.user != nil || authManager.isOnboardingCompleted {
                // User is logged in or completed onboarding
                ZStack {
                    // 1. THE MAIN TAB NAVIGATION (Bottom Layer)
                    CustomTabBarContainer(selection: $currentTab) {
                        
                        // The "Switchboard" logic
                        switch currentTab {
                        case .home:
                            HomeContainerView(webRTCManager: webRTCManager, selection: $currentTab)
                            
                        case .play:
                            NavigationStack {
                                PlayHubView()
                            }
                            
                        case .discover:
                            NavigationStack {
                                DiscoverPeopleView()
                            }
                            
                        case .message:
                            NavigationStack {
                                MessagesCardView()
                            }
                        }
                    }
                    .transition(AnyTransition.move(edge: .trailing))
                    
                    // 2. CALL OVERLAY (Floating Layer)
                    // We only show this if the WebRTC Manager says we are in a call
                    if webRTCManager.isInCall {
                        Group {
                            if isCallMinimized {
                                // A. The Floating Bubble (Draggable & Top)
                                FloatingCallBubble(
                                    webRTCManager: webRTCManager,
                                    callDuration: formattedDuration,
                                    onMaximize: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            isCallMinimized = false
                                        }
                                    }
                                )
                                .transition(.scale.combined(with: .opacity))
                                .zIndex(100)
                                
                            } else {
                                // B. The Full Screen Call View
                                CallInProgressView(
                                    webRTCManager: webRTCManager,
                                    callDuration: formattedDuration,
                                    onMinimize: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            isCallMinimized = true
                                        }
                                    },
                                    onEndCall: {
                                        endCall()
                                    }
                                )
                                .transition(.move(edge: .bottom))
                                .zIndex(99)
                            }
                        }
                    }
                }
                // Inject WebRTCManager so any tab can use it via @EnvironmentObject
                .environmentObject(webRTCManager)
                // Watch for call start signals from Manager (e.g. when matched)
                .onChange(of: webRTCManager.isInCall) { isInCall in
                    if isInCall {
                        startTimer()
                    } else {
                        // 🔥 FIX: Only end call (disconnect) if we were actually IN a call (UI-wise)
                        // This prevents initial load "false" state from triggering disconnect loops via HomeView
                        if isCallActive {
                             endCall()
                        }
                    }
                }
                
            } else {
                // User is NOT logged in
                OnboardingContainerView()
                    .transition(AnyTransition.move(edge: .leading))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isCallMinimized)
        .animation(.easeInOut, value: authManager.user) // Animate auth switch
    }
    
    // MARK: - Call Logic
    
    // Format seconds into MM:SS
    private var formattedDuration: String {
        let m = callDurationSeconds / 60
        let s = callDurationSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func startTimer() {
        // Reset and Start
        callDurationSeconds = 0
        isCallMinimized = false
        isCallActive = true // 🔥 FIX: Ensure UI shows
        
        callTimer?.invalidate()
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            callDurationSeconds += 1
        }
    }
    
    func endCall() {
        // 1. Kill Timer
        callTimer?.invalidate()
        callTimer = nil
        callDurationSeconds = 0
        isCallMinimized = false
        
        // 2. Disconnect WebRTC (if not already)
        // This avoids infinite loops since .disconnect() updates .isInCall which triggers onChange
        if webRTCManager.isInCall {
            webRTCManager.disconnect()
        }
    }
}
