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
    let onMessageTap: () -> Void
    let onGameTap: () -> Void
    
    // --- 2. LOCAL UI STATES ---
    @State private var showLearnerMap = false
    @State private var selectedTab: String = "Call"
    @State private var showProfile = false
    
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
    
    // --- 4. LAYOUT MATH ---
    // 🔥 FIX 1: Reduced Height from 0.55 to 0.50
    // This prevents the card from being too tall and hitting the tab bar.
    var cardHeight: CGFloat {
        // Increased to 0.72 to match the taller look in the design
        isSearching ? UIScreen.main.bounds.height : UIScreen.main.bounds.height * 0.58
    }
    
    var cardCornerRadius: CGFloat { isSearching ? 0 : 40 }
    var cardHorizontalPadding: CGFloat { isSearching ? 0 : 24 }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                // MARK: - 1. BACKGROUND LAYER
                Color(red: 255/255, green: 255/255, blue: 255/255)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                // 🔥 DEBUG OVERLAY (User Request)
                DebugAudioView(webRTC: webRTCManager)
                    .position(x: 80, y: 60)
                    .zIndex(999)

                // MARK: - 2. HEADER
                if !isSearching {
                    VStack(spacing: 0) {
                        HStack(spacing: 4) {
                            Spacer()
                            
                            // Search Icon
                            AnimatedSearchView()

                            // Profile Icon
                            HandDrawnFaceIcon(onTap: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    showProfile = true
                                }
                            })
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    .zIndex(0)
                }

                // MARK: - 3. THE MAIN CARD (Layer 1)
                VStack(spacing: 0) {
                    
                    // MOVED TITLE HERE
                    if !isSearching {
                        Text("Find a partner to\npractice your English")
                            .font(.system(size: 22, weight: .regular)) // Reduced to 22 for better balance
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "1F3B34"))
                            .padding(.bottom, 25)
                            .padding(.top, 50)
                    }
                    ZStack(alignment: .bottom) {
                        // A. Card Background
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(Color(hex: "D6E978")) // Light Green
//                            .shadow(color: .black.opacity(0.04), radius: 25, y: 10)
                        
                        // B. CONTENT STACK
                        VStack(spacing: 0) {
                            
                            // 1. AI FACE
                            Spacer()
                            AICompanionFace(state: .constant(derivedFaceState))
                                .scaleEffect(isSearching ? 1.6 : 1.9) // Adjusted scale
                                .padding(.bottom, 20)
                            Spacer()
                            
                            // 2. HOME CONTENT (Hidden when searching)
                            if !isSearching {
                                VStack(spacing: 14) {
                                    
                                    // Connection Icon
//                                    VStack(spacing: 4) {
//                                        Image("PenSignature")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 32, height: 32)
//                                            .foregroundColor(.gray.opacity(0.6))
//                                        //                                        .padding(.bottom, )
//                                            .padding(.top, 20)
                                        
                                        // Subtitle Text Removed (Moved to top)
//                                        Text("Find a partner to\npractice your English")
//                                            .font(.system(size: 20, weight: .regular))
//                                            .multilineTextAlignment(.center)
//                                            .foregroundColor(Color(hex: "1F3B34")) // Dark Green Text
//                                            .padding(.bottom, 20)
                                        
//                                    }
                                    
                                    // Custom Filters
                                    HStack(spacing: 0) {
                                        // 1. Gender
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            HStack(spacing: 4) {
                                                Text("Gender")
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 10))
                                            }
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(Color(hex: "1F3B34"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        Divider()
                                            .frame(height: 20)
                                            .overlay(Color(hex: "1F3B34").opacity(0.2))
                                        
                                        // 2. Level
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            HStack(spacing: 4) {
                                                Text("Level")
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 10))
                                            }
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(Color(hex: "1F3B34"))
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        Divider()
                                            .frame(height: 20)
                                            .overlay(Color(hex: "1F3B34").opacity(0.2))
                                        
                                        // 3. Country
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            HStack(spacing: 4) {
                                                Text("Country")
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 10))
                                            }
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(Color(hex: "1F3B34"))
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal, 30) // Increased padding
                                    .padding(.bottom, 25) // More space above button
                                    
                                    
                                    // "Search" Button
                                    Button(action: onConnectTap) {
                                        HStack(spacing: 10) {
                                            Image("MagicSearch") // Make sure the filename in Assets matches this
                                                        .renderingMode(.template) // This turns the dark SVG white
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 22, height: 20)
                                            
                                            Text("Search")
                                                .font(.system(size: 20, weight: .regular, design: .default))
                                                .foregroundStyle(Color(red: 241/255, green: 241/255, blue: 241/255))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color.black)
                                        .cornerRadius(28)
                                    }
                                    .padding(.horizontal, 40)
                                    
                                    // Old Filter Button Removed
//                                    Button(action: {
//                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    }) {
//                                        HStack(spacing: 4) {
//                                            Image("Filter")
//                                            Text("Filter")
//                                                .font(.system(size: 16, weight: .regular) )
//                                                
//                                        }
//                                        .font(.system(size: 14, weight: .medium))
//                                        .foregroundColor(.gray)
//                                        .padding(.vertical, 10)
//                                    }
                                }
                                .padding(.bottom, 40) // More bottom padding inside card for the button
                            }
                            
                            // 3. SEARCHING CONTENT
                            if isSearching {
                                VStack(spacing: 24) {
                                    Text(webRTCManager.connectionState.uppercased())
                                        .font(.caption)
                                        .fontWeight(.heavy)
                                        .tracking(1)
                                        .foregroundColor(.gray.opacity(0.8))
                                    
                                    Button(action: onCancelTap) {
                                        Text("Cancel Search")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red.opacity(0.9))
                                            .padding(.vertical, 14)
                                            .padding(.horizontal, 35)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.bottom, 80)
                            }
                        }
                    }
                    .frame(height: cardHeight)
                    .padding(.horizontal, cardHorizontalPadding)
                    // 🔥 FIX 2: Increased Bottom Padding to 110
                    // This pushes the whole card UP, clearing the Tab Bar area.
                    .padding(.bottom, isSearching ? 80 : -28)
                    .edgesIgnoringSafeArea(isSearching ? .all : [])
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
            .ignoresSafeArea(.keyboard)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPhase)
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}
