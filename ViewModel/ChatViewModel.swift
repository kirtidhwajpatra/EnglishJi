//
//  ChatViewModel.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    
    // 1. DATA SOURCE
    @Published var messages: [Message] = []
    
    // 2. CONFIGURATION
    let chatRoomId: String
    
    // Pagination State
    private var oldestDocumentSnapshot: DocumentSnapshot?
    @Published var isLoadingMore = false
    private var canLoadMore = true
    
    // 🔥 DYNAMIC USER ID
    // Uses UserManager to ensure consistency across the app
    var currentUserId: String {
        return UserManager.shared.currentUserId
    }
    
    // 3. INITIALIZATION
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        
        // B. Determine who is chatting (Now it's safe to use 'self')
        let myId = self.currentUserId
        
        print("🚀 My ID: \(myId)")
        print("🔗 Connecting to Chat Room: \(self.chatRoomId)")
        
        // C. Start Listening to Firestore
        ChatService.shared.observeMessages(chatRoomId: chatRoomId) { [weak self] newMessages, lastDoc in
            guard let self = self else { return }
            
            // 💡 MERGE STRATEGY:
            // The listener returns the "Latest 20".
            // If we have "Older" messages loaded (pagination), we shouldn't overwrite them.
            // But we DO want to see new incoming messages.
            
            if self.messages.isEmpty {
                // First load: Just assign
                self.messages = newMessages
                self.oldestDocumentSnapshot = lastDoc // Save for pagination
            } else {
                // Subsequent updates (Real-time message coming in)
                // We only care about appending/updating the NEW stuff at the bottom.
                // We DON'T want to replace our "History" at the top with nothing.
                
                // 1. Find the intersection point or just append new ones
                // Simple approach: Take our existing messages, remove any deemed "invalid" if needed,
                // but mostly just UPSERT the new ones.
                
                var currentMessages = self.messages
                
                for newMessage in newMessages {
                    if let index = currentMessages.firstIndex(where: { $0.id == newMessage.id }) {
                        currentMessages[index] = newMessage // Update existing (e.g. timestamp confirmed)
                    } else {
                        // Append new message
                        // Check if it's already older than our last? No, listener is "latest".
                        // Logic: If it's not found, it's likely NEW.
                        currentMessages.append(newMessage)
                    }
                }
                
                // Sort everything again just to be safe
                self.messages = currentMessages.sorted(by: { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) })
                
                // Update pagination marker if we were empty? No, listener always gives latest 20.
                if self.oldestDocumentSnapshot == nil {
                     self.oldestDocumentSnapshot = lastDoc
                }
            }
            
            // Play received sound if the last message wasn't from me
            // 🔥 FIX: Check sender ID directly (isCurrentUser was removed)
            if let last = newMessages.last, last.senderId != self.currentUserId {
                    ChatAudioManager.shared.playReceivedSound()
            }
        }
        
        // D. Start Listening to Typing Status
        listenToTypingStatus()
    }
    
    // 4. ACTIONS
    func sendMessage(text: String) {
        // A. Create Local Message (Optimistic)
        let tempId = UUID().uuidString
        let newMessage = Message(
            id: tempId,
            text: text,
            senderId: currentUserId,
            timestamp: Date() // Local time immediately
        )
        
        // B. Update UI Immediately
        withAnimation {
            messages.append(newMessage)
        }
        
        // Local Feedback
        ChatAudioManager.shared.playSentSound()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // C. Send to Backend
        ChatService.shared.sendMessage(newMessage, chatRoomId: chatRoomId)
        
        // D. Update Chat List Metadata (Last Message, Unread Count)
        // We need to know who the RECEIVER is to increment their unread count.
        // Logic: RoomID is "chat_room_ID1_ID2". We remove "chat_room_" and our ID.
        var receiverId = "unknown"
        let idsString = chatRoomId.replacingOccurrences(of: "chat_room_", with: "")
        
        // IDs are sorted. So it's either "me_partner" or "partner_me".
        // Warning: IDs contain underscores.
        // Robust strategy: Remove my ID and the connecting underscore.
        
        print("🔍 ID Parsing: Room=\(chatRoomId), Me=\(currentUserId)")
        
        if idsString.hasPrefix(currentUserId + "_") {
             // format: ME_PARTNER
             receiverId = String(idsString.dropFirst(currentUserId.count + 1))
             print("   ✅ Found Prefix Match. Partner=\(receiverId)")
        } else if idsString.hasSuffix("_" + currentUserId) {
             // format: PARTNER_ME
             receiverId = String(idsString.dropLast(currentUserId.count + 1))
             print("   ✅ Found Suffix Match. Partner=\(receiverId)")
        } else {
             print("   ❌ NO MATCH found for ID in string: \(idsString)")
        }
        
        print("📨 Sender: \(currentUserId), Receiver: \(receiverId)")
        
        ChatService.shared.updateConversationMetadata(
            chatRoomId: chatRoomId,
            lastMessage: text,
            senderId: currentUserId,
            receiverId: receiverId,
            receiverName: "User" // You might want to pass the partner's real name here if available
        )
    }
    
    // MARK: - Typing Logic
    @Published var isPartnerTyping = false
    private var typingTimer: Timer?
    
    private func listenToTypingStatus() {
        ChatService.shared.observeTypingStatus(chatRoomId: chatRoomId) { [weak self] typingUserIds in
            guard let self = self else { return }
            // If anyone OTHER than me is typing, set true
            self.isPartnerTyping = typingUserIds.contains { $0 != self.currentUserId }
        }
    }
    
    func userDidType() {
        // 1. If not already typing, tell backend we started
        if typingTimer == nil {
            ChatService.shared.updateTypingStatus(chatRoomId: chatRoomId, userId: currentUserId, isTyping: true)
        }
        
        // 2. Reset timer (Debounce stop)
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.typingTimer = nil
            ChatService.shared.updateTypingStatus(chatRoomId: self.chatRoomId, userId: self.currentUserId, isTyping: false)
        }
    }

    func loadMoreMessages() {
        guard !isLoadingMore, let lastDoc = oldestDocumentSnapshot else { return }
        
        print("⏳ Loading more messages...")
        isLoadingMore = true
        
        ChatService.shared.fetchPreviousMessages(chatRoomId: chatRoomId, before: lastDoc) { [weak self] olderMessages, newLastDoc in
            guard let self = self else { return }
            self.isLoadingMore = false
            
            if olderMessages.isEmpty {
                self.canLoadMore = false
            } else {
                // Prepend older messages
                self.messages.insert(contentsOf: olderMessages, at: 0)
                self.oldestDocumentSnapshot = newLastDoc
            }
        }
    }
}
