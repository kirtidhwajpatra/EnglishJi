//
//  HomeView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @ObservedObject var webRTCManager: WebRTCManager
    
    @State private var showLearnerMap = false
    
    // For tabs
    @State private var selectedTab: String = "Call"

    var body: some View {
        ZStack {
            // MARK: - 1. Background
            // Using a high-quality snowy/nature image similar to mock
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1548783060-cc45d55e0c96?q=80&w=2787&auto=format&fit=crop")) { phase in
                switch phase {
                case .empty:
                    Color.gray
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray // Fallback
                @unknown default:
                    Color.gray
                }
            }
            .ignoresSafeArea()
            .overlay(
                // Dark gradient overlay for text readability
                LinearGradient(
                    colors: [
                        .black.opacity(0.6),
                        .black.opacity(0.2),
                        .black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )

            // MARK: - 2. Content
            VStack(spacing: 0) {
                
                // --- Header ---
                HStack {
                    Spacer()
                    // Profile / VS Circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("VS")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        )
                        .shadow(radius: 4)
                        .padding(.trailing, 20)
                        .padding(.top, 10) // Adjust for status bar if needed handled by safe area
                }
                
                Spacer().frame(height: 20)

                // --- Subtext ---
                Text("350 Learners are practicing near you")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 30)

                // --- Tabs (Call | Message) ---
                HStack(spacing: 40) {
                    Button {
                        selectedTab = "Call"
                    } label: {
                        Text("Call")
                            .font(.title2)
                            .fontWeight(selectedTab == "Call" ? .bold : .regular)
                            .foregroundColor(.white)
                            .opacity(selectedTab == "Call" ? 1.0 : 0.6)
                    }

                    Button {
                        selectedTab = "Message"
                    } label: {
                        Text("Message")
                            .font(.title2)
                            .fontWeight(selectedTab == "Message" ? .bold : .regular)
                            .foregroundColor(.white)
                            .opacity(selectedTab == "Message" ? 1.0 : 0.6)
                    }
                }
                .padding(.bottom, 20)

                // --- Main Card ---
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .frame(maxWidth: .infinity)
                    // Take up significant vertical space
                    .frame(height: UIScreen.main.bounds.height * 0.55)
                    .overlay(
                        VStack {
                            Spacer()
                            
                            // Connect Button
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                let userId = AuthManager.shared.user?.uid ?? UUID().uuidString
                                webRTCManager.startMatchmaking(userId: userId)
                            } label: {
                                HStack(spacing: 12) {
                                    Text("Connect")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    // Audio wave icon imitation
                                    HStack(spacing: 3) {
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 10)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 16)
                                        RoundedRectangle(cornerRadius: 2).frame(width: 3, height: 8)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.25, green: 0.10, blue: 0.55)) // Deep Purple
                                .cornerRadius(25)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                        }
                    )
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // --- Bottom Floating Area ---
                HStack(alignment: .center, spacing: 8) {
                    
                    // Left Circle Button (Audio config?)
                    Button(action: {
                                            withAnimation(.spring()) {
                                                showLearnerMap = true // <--- TRIGGER
                                            }
                                        }) {
                                            AudioToggleView()
                                        }
                                        .buttonStyle(PlainButtonStyle())
                    
                    // Right Avatar Stack
                    SocialPillView(users: [
                        EnglishJiUser(name: "A", imageURL: "https://i.pravatar.cc/150?img=1"),
                        EnglishJiUser(name: "B", imageURL: "https://i.pravatar.cc/150?img=2"),
                        EnglishJiUser(name: "C", imageURL: "https://i.pravatar.cc/150?img=3")
                    ], totalCount: 45)// Container
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
               
                
            }
        }
        
        
        if showLearnerMap {
                        LearnerRadarView(onClose: {
                            withAnimation(.spring()) {
                                showLearnerMap = false
                            }
                        })
                        .transition(.opacity.combined(with: .scale(scale: 0.9))) // Nice zoom effect
                        .zIndex(100) // Ensure it sits on top
                    }
      
        
    }
    
    
}
