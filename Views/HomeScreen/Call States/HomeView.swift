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
        isSearching ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.54
    }
    
    // Bottom Padding: Lift card 100px up to clear pills (Home) vs 0 (Searching)
    var cardBottomPadding: CGFloat { isSearching ? 0 : 140 }
    
    var cardCornerRadius: CGFloat { isSearching ? 0 : 32 }
    var cardHorizontalPadding: CGFloat { isSearching ? 0 : 20 }

    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - 1. BACKGROUND LAYER
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

            // MARK: - 2. HEADER & TABS (Layer 0)
            // We shift this UP to fix the empty space issue
            if !isSearching {
                VStack(spacing: 0) {
                    // A. Header Row
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48, height: 48)
                            .overlay(Text("VS").font(.system(size: 18, weight: .bold)))
                            .shadow(radius: 4)
                            .padding(.trailing, 24)
                    }
                    // FIX: Reduced from 70 to 50 to remove excess top gap
                    .padding(.top, 0)
                    
                    // B. Subtext
                    // FIX: Removed large Spacer(), used tight padding instead
                    Text("350 Learners are practicing near you")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 20)
                        .padding(.bottom, 25)

                    // C. Tabs
                    HStack(spacing: 40) {
                        TabButton(text: "Call", selectedTab: $selectedTab)
                        TabButton(text: "Message", selectedTab: $selectedTab)
                    }
                    .padding(.bottom, 5) // Small buffer before the card starts
                    
                    Spacer() // This pushes the header to the top
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
                        .shadow(color: .black.opacity(isSearching ? 0 : 0.25), radius: 45, y: -5)
                    
                    // B. AI Face
                    VStack {
                        // Move face up slightly when full screen to avoid overlap with debug text
                        if isSearching { Spacer().frame(height: 140) }
                        
                        AICompanionFace(state: .constant(derivedFaceState))
                            .scaleEffect(isSearching ? 1.5 : 1.3)
                        
                        if isSearching { Spacer() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    // When Home: Padding 80 keeps face above Connect Button
                    .padding(.bottom, isSearching ? 0 : 90)
                    
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
                                        .fontWeight(.bold)
                                    
                                    // Audio Bars Icon
                                    HStack(spacing: 3) {
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 10)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 16)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 8)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.25, green: 0.10, blue: 0.55))
                                .cornerRadius(30)
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                // 🔥 LAYOUT FIXES APPLIED HERE
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
                    HStack(alignment: .center, spacing: 16) {
                        
                        Button(action: {
                            withAnimation(.spring()) { showLearnerMap = true }
                        }) {
                            AudioToggleView()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        SocialPillView(users: [
                            EnglishJiUser(name: "A", imageURL: "https://i.pravatar.cc/150?img=1"),
                            EnglishJiUser(name: "B", imageURL: "https://i.pravatar.cc/150?img=2"),
                            EnglishJiUser(name: "C", imageURL: "https://i.pravatar.cc/150?img=3")
                        ], totalCount: 45)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
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
    }
}

// Helper for cleaner Tab Code
struct TabButton: View {
    let text: String
    @Binding var selectedTab: String
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = text }
        } label: {
            Text(text)
                .font(.title2)
                .fontWeight(selectedTab == text ? .bold : .medium)
                .foregroundColor(.white)
                .opacity(selectedTab == text ? 1.0 : 0.6)
                .scaleEffect(selectedTab == text ? 1.05 : 1.0)
        }
    }
}
