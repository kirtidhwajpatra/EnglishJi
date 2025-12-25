//
//  ChatDetailView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI
import AudioToolbox

// MARK: - 1. Chat Audio Manager
class ChatAudioManager {
    static let shared = ChatAudioManager()
    
    func playSentSound() {
        AudioServicesPlaySystemSound(1004)
    }
    
    func playReceivedSound() {
        AudioServicesPlaySystemSound(1003)
    }
}

struct ChatDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatPartner: ChatModel
    
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    // Sample Conversation
    @State private var messages: [Message] = [
        Message(text: "Sweet 👍", isCurrentUser: false),
        Message(text: "Sooo, how long is this heat wave going to last?", isCurrentUser: false),
        Message(text: "Too hot to skate today 🥵", isCurrentUser: false),
        Message(text: "I would say it's a good day for that water park...", isCurrentUser: true),
        Message(text: "...But I'm pretty sure I'm still banned 😐", isCurrentUser: true),
        Message(text: "Wait, what?!", isCurrentUser: false),
        Message(text: "Is that real?", isCurrentUser: false),
        Message(text: "Graham, you must be kidding. How have you seriously not heard this story?", isCurrentUser: false),
        Message(text: "It's very real. Turns out the water slides are kids-only for a reason", isCurrentUser: true),
        Message(text: "Took the fire department over two hours to get him out 🚒", isCurrentUser: false)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - BACKGROUND
            Color(ej_hex: "F2F2F7").ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - HEADER
                ZStack(alignment: .center) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.indigo)
                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 4) {
                        AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(chatPartner.name)")) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        
                        Text(chatPartner.name)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.indigo)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(Color(ej_hex: "F2F2F7").opacity(0.95))
                
                // MARK: - CHAT AREA
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            Spacer().frame(height: 10)
                            
                            ForEach(Array(messages.enumerated()), id: \.element.id) { index, msg in
                                let isLast = isLastMessage(at: index)
                                // Calculate if we need extra spacing (New Sender Block)
                                let isNewBlock = index > 0 && messages[index - 1].isCurrentUser != msg.isCurrentUser
                                
                                MessageBubbleRow(
                                    message: msg,
                                    isLastFromSender: isLast,
                                    partnerName: chatPartner.name
                                )
                                .id(msg.id)
                                // 🔥 FIX 1: Add vertical spacing between different speakers
                                .padding(.top, isNewBlock ? 12 : 0)
                                
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8, anchor: msg.isCurrentUser ? .bottomTrailing : .bottomLeading)
                                                .combined(with: .opacity)
                                                .combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }
                            
                            Spacer().frame(height: 10)
                        }
                        .padding(.horizontal, 12)
                    }
                    .onAppear {
                        if let lastId = messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastId = messages.last?.id {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // MARK: - INPUT BAR
                HStack(alignment: .bottom, spacing: 12) {
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(ej_hex: "8E8E93"))
                            .frame(width: 36, height: 36)
                            .background(Color(ej_hex: "E5E5EA"))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 4)
                    
                    HStack {
                        TextField("Message", text: $messageText)
                            .focused($isFocused)
                            .padding(.vertical, 10)
                        
                        if !messageText.isEmpty {
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.indigo)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color(ej_hex: "E5E5EA"), lineWidth: 1)
                    )
                    
                    if messageText.isEmpty {
                        Button(action: {}) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(ej_hex: "8E8E93"))
                        }
                        .padding(.bottom, 10)
                        .transition(.scale)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(ej_hex: "F2F2F7"))
            }
        }
        .navigationBarHidden(true)
    }
    
    func isLastMessage(at index: Int) -> Bool {
        if index == messages.count - 1 { return true }
        return messages[index].isCurrentUser != messages[index + 1].isCurrentUser
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        ChatAudioManager.shared.playSentSound()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let newMsg = Message(text: messageText, isCurrentUser: true)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            messages.append(newMsg)
            messageText = ""
        }
    }
}

// MARK: - Message Bubble Row
struct MessageBubbleRow: View {
    let message: Message
    let isLastFromSender: Bool
    let partnerName: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            
            if message.isCurrentUser {
                // --- CURRENT USER ---
                
                // 🔥 FIX 2: Use Spacer(minLength: 60) to prevent touching left edge
                Spacer(minLength: 60)
                
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(ej_hex: "3F1A94"), // Deep Indigo
                                Color(ej_hex: "633CBE")  // Lighter Violet
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(ChatBubbleShape(isCurrentUser: true))
                    .padding(.trailing, 0)
                
            } else {
                // --- PARTNER ---
                if isLastFromSender {
                    AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(partnerName)")) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Color.gray
                        }
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                } else {
                    Color.clear.frame(width: 30, height: 30)
                }
                
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundColor(.black)
                    .background(Color(ej_hex: "E5E5EA"))
                    .clipShape(ChatBubbleShape(isCurrentUser: false))
                
                // 🔥 FIX 2: Prevent partner message from touching right edge
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Custom Bubble Shape
struct ChatBubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isCurrentUser ? .bottomLeft : .bottomRight,
                isCurrentUser ? .bottomRight : .bottomLeft
            ],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Data Model
struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
}

#Preview {
    ChatDetailView(chatPartner: ChatModel(
        name: "Daniel Murphy",
        message: "",
        time: "",
        unreadCount: 0,
        image: ""
    ))
}
