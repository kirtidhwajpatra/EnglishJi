//
//  MessagesCardView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI
import AudioToolbox

// MARK: - 1. Sensory Feedback Manager
class SensoryFeedbackManager {
    static let shared = SensoryFeedbackManager()
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
   

    init() {
        hapticGenerator.prepare()
    }

    func triggerScrollTick() {
        // System "Tick" Sound (ID 1104) - Subtle and native
        AudioServicesPlaySystemSound(1104)
        hapticGenerator.impactOccurred(intensity: 0.6) // Slightly crisper haptic
    }
}

// MARK: - 2. Custom Button Style
struct BouncyCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
    }
}

// MARK: - 3. Main View
struct MessagesCardView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // Sample Data
    @StateObject private var viewModel = ChatListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(hex: "F2F2F7").ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // --- HEADER ---
                    HStack(alignment: .bottom) {
                        // Left Side: Title + ID Debug
                        VStack(alignment: .leading, spacing: 4) {
                             Text("Messages")
                                 .font(.largeTitle)
                                 .fontWeight(.bold)
                                 .foregroundColor(.black)
                             
                             // 🔥 DEBUG ID
                             Text("ID: \(viewModel.currentUserId.prefix(15))...")
                                 .font(.caption2)
                                 .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Right Side: Icons
                        HStack(spacing: 16) {
                            CircleIconButton(icon: "camera.fill")
                            CircleIconButton(icon: "square.and.pencil")
                        }
                        .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // --- LAZY LIST ---
                    // DECREASED SPACING from 16 to 10
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.conversations) { chat in
                            MessageCard(chat: chat, currentUserId: viewModel.currentUserId)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Increased for Tab Bar
                }
            }
        }
        }
        .preferredColorScheme(.light)
        
    }
}


// MARK: - 4. Message Card Component (THE MAGIC HAPPENS HERE)
struct MessageCard: View {
    let chat: ChatModel
    let currentUserId: String
    @State private var hasAppeared = false
    @State private var showChatDetail = false
    
    var body: some View {
        Button(action: {
            showChatDetail = true
            // 🔥 Mark as Read when tapping
            if let chatId = chat.id {
                ChatService.shared.markAsRead(chatRoomId: chatId, userId: currentUserId)
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Avatar
                AsyncImage(url: URL(string: chat.profileImage)) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color(hex: "E5E5EA")
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    // MOVED SPACER so badge is next to name
                    HStack(alignment: .center, spacing: 6) {
                        Text(chat.name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                        
                        if chat.unreadCount(for: currentUserId) > 0 {
                            Text("\(chat.unreadCount(for: currentUserId))")
                                .font(.system(size: 13, weight: .bold)) // Slightly larger
                                .foregroundColor(.white)
                                .padding(.horizontal, 10) // Wider pill
                                .padding(.vertical, 4)
                                .background(Color(hex: "D64692")) // Pink color from reference
                                .clipShape(Capsule())
                        }
                        
                        Spacer() // Spacer now pushes time to the right
                        
                        Text(chat.timeAgo)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "8E8E93"))
                    }
                    
                    Text(chat.lastMessage)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "636366"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
            
            // 🔥 ENTRY ANIMATION 🔥
            .scaleEffect(hasAppeared ? 1.0 : 0.92)
            .opacity(hasAppeared ? 1.0 : 0.5)
            .blur(radius: hasAppeared ? 0 : 2)
        }
        .buttonStyle(BouncyCardButtonStyle())
        
        // 🔥 LOGIC FOR RE-TRIGGERING ANIMATION & SOUND
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                hasAppeared = true
            }
            // Trigger Sound
            SensoryFeedbackManager.shared.triggerScrollTick()
        }
        .onDisappear {
            hasAppeared = false
        }
        
        // 🔥 NAVIGATION (Keeps Tab Bar Visible)
        .background(
            NavigationLink(isActive: $showChatDetail) {
                if let roomId = chat.id {
                    ChatDetailView(chatPartner: chat, roomId: roomId)
                } else {
                     ChatDetailView(chatPartner: chat, roomId: "error_room")
                }
            } label: {
                EmptyView()
            }
            .hidden()
        )
    }
}

// Helper Buttons
struct CircleIconButton: View {
    let icon: String
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}







#Preview {
    MessagesCardView()
}
