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
    let chats: [ChatModel] = [
        ChatModel(name: "Daniel Murphy", message: "Hey, I just wanted to check if we're still on for tomorrow...", time: "10:24 am", unreadCount: 2, image: "person1"),
        ChatModel(name: "Sophia Bennett", message: "It was so nice catching up the other day! ❤️", time: "10:24 am", unreadCount: 12, image: "person2"),
        ChatModel(name: "Michael Torres", message: "I've been thinking about the project updates...", time: "10:24 am", unreadCount: 4, image: "person3"),
        ChatModel(name: "Ava Mitchell", message: "Yess 🤞", time: "10:24 am", unreadCount: 1, image: "person4"),
        ChatModel(name: "Liam Robinson", message: "Can you send the files?", time: "Yesterday", unreadCount: 0, image: "person5"),
        ChatModel(name: "Emma Watson", message: "Dinner tonight?", time: "Yesterday", unreadCount: 0, image: "person6"),
        ChatModel(name: "Noah Carter", message: "Sounds good to me.", time: "Mon", unreadCount: 0, image: "person7"),
        ChatModel(name: "Olivia Davis", message: "See you there!", time: "Mon", unreadCount: 0, image: "person8"),
        ChatModel(name: "James Rodriguez", message: "Got it, thanks.", time: "Sun", unreadCount: 0, image: "person9"),
        ChatModel(name: "Isabella Garcia", message: "Heading out now.", time: "Sun", unreadCount: 0, image: "person10"),
        ChatModel(name: "William Martinez", message: "Call me when you can.", time: "Sat", unreadCount: 0, image: "person11")
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(ej_hex: "F2F2F7").ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // --- HEADER ---
                    HStack(alignment: .bottom) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        
                        Spacer()
                        
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
                        ForEach(chats) { chat in
                            MessageCard(chat: chat)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - 4. Message Card Component (THE MAGIC HAPPENS HERE)
struct MessageCard: View {
    let chat: ChatModel
    @State private var hasAppeared = false
    @State private var showChatDetail = false
    
    var body: some View {
        Button(action: {
            showChatDetail = true
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Avatar
                AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(chat.name)")) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color(ej_hex: "E5E5EA")
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
                        
                        if chat.unreadCount > 0 {
                            Text("\(chat.unreadCount)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        
                        Spacer() // Spacer now pushes time to the right
                        
                        Text(chat.time)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(ej_hex: "8E8E93"))
                    }
                    
                    Text(chat.message)
                        .font(.system(size: 15))
                        .foregroundColor(Color(ej_hex: "636366"))
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
        
        .fullScreenCover(isPresented: $showChatDetail) {
            ChatDetailView(chatPartner: chat)
        }
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

struct ChatModel: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let time: String
    let unreadCount: Int
    let image: String
}


#Preview {
    MessagesCardView()
}
