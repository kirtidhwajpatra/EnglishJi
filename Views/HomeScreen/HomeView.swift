//
//  HomeView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI
import FirebaseAuth
import AVFoundation

struct HomeView: View {

    @ObservedObject var webRTCManager: WebRTCManager
    
    // --- 1. INPUTS FROM PARENT ---
    let currentPhase: AppPhase
    let onConnectTap: () -> Void
    let onCancelTap: () -> Void
    
    // --- 2. LOCAL UI STATES ---
    @State private var showLearnerMap = false
    @State private var selectedTab: String = "Call"
    @State private var showProfile = false
    @State private var showMessages = false
    @State private var showGame = false
    @State private var showGameCenter = false


    // --- 3. COMPUTED HELPERS ---
    var isSearching: Bool { currentPhase == .searching }
    
    private var derivedFaceState: AIState {
        if currentPhase == .home { return .idle }
        if currentPhase == .searching {
            if webRTCManager.connectionState == "Connected" { return .connected }
            return .searching
        }
        return .idle
    }
    
    // --- 4. LAYOUT MATH (The Spacing Fix) ---
    
    // Height: 50% of screen (Home) vs 100% (Searching).
    // Reduced from 0.55 to 0.50 to prevent covering the Tabs.
    var cardHeight: CGFloat {
        isSearching ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.53
    }
    
    // Bottom Padding: Lift card 100px up to clear pills (Home) vs 0 (Searching)
    var cardBottomPadding: CGFloat { isSearching ? 0 : 160 }
    
    var cardCornerRadius: CGFloat { isSearching ? 0 : 50 }
    var cardHorizontalPadding: CGFloat { isSearching ? 0 : 25 }

    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - 1. BACKGROUND LAYER
            Color(red: 241/255, green: 241/255, blue: 241/255) // Hex #F1F1F1
            .ignoresSafeArea()

            // MARK: - 2. HEADER & TABS (Layer 0)
            // We shift this UP to fix the empty space issue
            if !isSearching {
                VStack(spacing: 0) {
                    // A. Header Row
                    HStack {
                        // 🔥 TITLE
                        Text("EnglishJi")
                             .font(.system(size: 28, weight: .bold, design: .rounded))
                             .foregroundColor(.black)
                        
                        Spacer()
                        
                        // 🔥 SEARCH ICON
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image("SearchIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .padding(15)
                        }

                        // 🔥 UPDATED PROFILE BUTTON
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showProfile = true
                        }) {
                            Text("VS")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 2)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    
                    // B. Subtext (Spacer) - REDUCED for tighter layout
                    Spacer().frame(height: 10)


                    // C. Tabs (Black Text)
                    HStack(spacing: 40) {
                        TabButton(text: "Call", selectedTab: $selectedTab)
                        TabButton(text: "Message", selectedTab: $selectedTab)
                    }
                    .padding(.top, 30) // Reduced from 20
                    .padding(.bottom, 10) // Reduced from 10 to pull card closer
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(0)
            }

            // MARK: - 3. THE EXPANDING CARD (Layer 1)
            VStack {
                // If not searching, spacer pushes card to bottom area
                if !isSearching { Spacer() }
                
                ZStack(alignment: .bottom) {
                    // A. White Background
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(isSearching ? 0 : 0.05), radius: 45, y: -5)
                    
                    // B. AI Face & SELECTORS
                    VStack(spacing: 20) {
                        // Move face up slightly when full screen to avoid overlap with debug text
                        if isSearching { Spacer().frame(height: 140) }
                        
                        AICompanionFace(state: .constant(derivedFaceState))
                            .scaleEffect(isSearching ? 1.6 : 2.1) // Reduced from 2.6 to 2.1
                            // 🔥 FIX CLUTTER: Push content down to account for scale
                            .padding(.bottom, isSearching ? 0 : 50)
                        
                        // 🔥 GENDER & OPTION SELECTORS (Home Only)
                        if !isSearching {
                            HStack(spacing: 4) {
                                // Gender Selector
                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Text("Female")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.black.opacity(0.8))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "F1f1f1")) // Light gray
                                    .cornerRadius(12)
                                }
                                
                                // Second Selector (Icon)
                                Button(action: {}) {
                                    Image(systemName: "chevron.down") // Or "slider.horizontal.3" if it was settings? Reference shows simple 'v'
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(width: 44, height: 40) // Square-ish
                                        .background(Color(hex: "F1f1f1"))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.top, 40) // Space between Face and Selectors
                        }
                        
                        
                        if isSearching { Spacer() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    // When Home: Padding pushes face UP from the Connect button area
                    // Reduced slightly to fit Selectors
                    .padding(.bottom, isSearching ? 0 : 10)
                    
                    // C. Bottom Content (Connect / Cancel)
                    VStack {
                        if isSearching {
                            // --- SEARCHING UI ---
                            VStack(spacing: 24) {
                                Text(webRTCManager.connectionState.uppercased())
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .tracking(1)
                                    .foregroundColor(.gray.opacity(0.8))
                                    .transition(.opacity)

                                Button(action: onCancelTap) {
                                    Text("Cancel Search")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red.opacity(0.9))
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 35)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            // Push cancel button up from very bottom
                            .padding(.bottom, 90)
                            
                        } else {
                            // --- HOME UI ---
                            Button(action: onConnectTap) {
                                HStack(spacing: 12) {
                                    Text("Connect")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                    
                                    // Audio Bars Icon
                                    HStack(spacing: 3) {
                                        RoundedRectangle(cornerRadius: 2).frame(width: 2, height: 10)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 2, height: 16)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 2, height: 8)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                // 🔥 BLACK BACKGROUND
                                .background(Color.black)
                                .cornerRadius(30)
                                
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                // 🔥 LAYOUT FIXES APPLIED HERE
                .overlay(
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .frame(height: cardHeight)
                .padding(.horizontal, cardHorizontalPadding)
                .padding(.bottom, cardBottomPadding)
                
                .edgesIgnoringSafeArea(isSearching ? .all : [])
                .zIndex(1) // Ensures Card is visually ON TOP of Header
            }

            // MARK: - 4. FOOTER (Floating Pills) (Layer 0)
            if !isSearching {
                VStack {
                    Spacer()
                    HStack(alignment: .center, spacing: 6) {
                        
                        Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showGameCenter = true
                            }) {
                                GamePillButton()
                            }
                            .buttonStyle(PlainButtonStyle())
                        
//                        Spacer().frame(width: 16)
                        
                        Button(action: {
                            withAnimation(.spring()) { showLearnerMap = true }
                        }) {
                            AudioToggleView()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 🔥 UPDATED: Social Pill Button
                        Button(action: {
                            // 1. Premium Haptic Feedback
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            // 2. Trigger Navigation
                            showMessages = true
                        }) {
                            SocialPillView(users: [
                                EnglishJiUser(name: "A", imageURL: "https://i.pravatar.cc/150?img=1"),
                                EnglishJiUser(name: "B", imageURL: "https://i.pravatar.cc/150?img=2"),
                                EnglishJiUser(name: "C", imageURL: "https://i.pravatar.cc/150?img=3")
                            ])
                        }
                        .buttonStyle(PlainButtonStyle())// Prevents default fade effect
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
                }
                .transition(.opacity)
                .zIndex(0)
            }
            
            // MARK: - 5. OVERLAYS
            if showLearnerMap {
                LearnerRadarView(onClose: {
                    withAnimation(.spring()) { showLearnerMap = false }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPhase)
        
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView()
        }
        
        .fullScreenCover(isPresented: $showMessages) {
            MessagesCardView()
        }
        
        .fullScreenCover(isPresented: $showGameCenter) {
                    GameSelectionView()
                }

    }
}

// Helper for cleaner Tab Code
// Helper for cleaner Tab Code
struct TabButton: View {
    let text: String
    @Binding var selectedTab: String
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = text }
        } label: {
            VStack(spacing: 4) {
                Text(text)
                    .font(.title2)
                    .fontWeight(selectedTab == text ? .medium : .regular) // Slightly bolder when active
                    // 🔥 BLACK TEXT
                    .foregroundColor(.black)
                    .opacity(selectedTab == text ? 1.0 : 0.6)
                    
                // 🔥 DOT INDICATOR
                if selectedTab == text {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 4, height: 4)
                        .transition(.scale) // Nice pop-in effect
                } else {
                    // Invisible spacer to keep height constant (prevents jumping)
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .scaleEffect(selectedTab == text ? 1.05 : 1.0)
        }
    }
}

