
//
//  ChatViewModel.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

final class ChatViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var messages: [Message] = []
    @Published var isLoadingMore = false
    @Published var isPartnerTyping = false
    
    let chatRoomId: String
    private var oldestDocumentSnapshot: DocumentSnapshot?
    private var canLoadMore = true
    private var typingTimer: Timer?
    
    var currentUserId: String {
        return UserManager.shared.currentUserId
    }
    
    // MARK: - Initialization
    
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        setupObservers()
    }
    
    deinit {
        typingTimer?.invalidate()
    }
    
    // MARK: - Data Observation
    
    private func setupObservers() {
        print("[ChatViewModel] Connecting to room: \(chatRoomId)")
        
        // Message Listener
        ChatService.shared.observeMessages(chatRoomId: chatRoomId) { [weak self] newMessages, lastDoc in
            guard let self = self else { return }
            self.handleIncomingMessages(newMessages, lastDoc: lastDoc)
        }
        
        // Typing Status Listener
        ChatService.shared.observeTypingStatus(chatRoomId: chatRoomId) { [weak self] typingUserIds in
            guard let self = self else { return }
            self.isPartnerTyping = typingUserIds.contains { $0 != self.currentUserId }
        }
    }
    
    private func handleIncomingMessages(_ newMessages: [Message], lastDoc: DocumentSnapshot?) {
        if messages.isEmpty {
            messages = newMessages
            oldestDocumentSnapshot = lastDoc
        } else {
            // Merge strategy: Update existing or append new
            var currentMessages = messages
            
            for newMessage in newMessages {
                if let index = currentMessages.firstIndex(where: { $0.id == newMessage.id }) {
                    currentMessages[index] = newMessage
                } else {
                    currentMessages.append(newMessage)
                }
            }
            
            messages = currentMessages.sorted { ($0.timestamp ?? Date()) < ($1.timestamp ?? Date()) }
            
            if oldestDocumentSnapshot == nil {
                 oldestDocumentSnapshot = lastDoc
            }
        }
        
        // Sound effect for incoming messages from partner
        if let last = newMessages.last, last.senderId != currentUserId {
            ChatAudioManager.shared.playReceivedSound()
        }
    }
    
    // MARK: - User Actions
    
    func sendMessage(text: String) {
        let tempId = UUID().uuidString
        let newMessage = Message(
            id: tempId,
            text: text,
            senderId: currentUserId,
            timestamp: Date()
        )
        
        // Optimistic UI Update
        withAnimation {
            messages.append(newMessage)
        }
        
        // Haptics & Sound
        ChatAudioManager.shared.playSentSound()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Network Request
        ChatService.shared.sendMessage(newMessage, chatRoomId: chatRoomId)
        
        updateConversationMetadata(text: text)
    }
    
    func loadMoreMessages() {
        guard !isLoadingMore, let lastDoc = oldestDocumentSnapshot else { return }
        
        isLoadingMore = true
        print("[ChatViewModel] Loading older messages...")
        
        ChatService.shared.fetchPreviousMessages(chatRoomId: chatRoomId, before: lastDoc) { [weak self] olderMessages, newLastDoc in
            guard let self = self else { return }
            self.isLoadingMore = false
            
            if olderMessages.isEmpty {
                self.canLoadMore = false
            } else {
                self.messages.insert(contentsOf: olderMessages, at: 0)
                self.oldestDocumentSnapshot = newLastDoc
            }
        }
    }
    
    // MARK: - Typing Logic
    
    func userDidType() {
        if typingTimer == nil {
            ChatService.shared.updateTypingStatus(chatRoomId: chatRoomId, userId: currentUserId, isTyping: true)
        }
        
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.typingTimer = nil
            ChatService.shared.updateTypingStatus(chatRoomId: self.chatRoomId, userId: self.currentUserId, isTyping: false)
        }
    }
    
    // MARK: - Helpers
    
    private func updateConversationMetadata(text: String) {
        // Extract receiver ID from chatRoomId (format: ID1_ID2)
        let idsString = chatRoomId.replacingOccurrences(of: "chat_room_", with: "")
        var receiverId = "unknown"
        
        if idsString.hasPrefix(currentUserId + "_") {
             receiverId = String(idsString.dropFirst(currentUserId.count + 1))
        } else if idsString.hasSuffix("_" + currentUserId) {
             receiverId = String(idsString.dropLast(currentUserId.count + 1))
        }
        
        ChatService.shared.updateConversationMetadata(
            chatRoomId: chatRoomId,
            lastMessage: text,
            senderId: currentUserId,
            receiverId: receiverId,
            receiverName: "User" // Note: Real app should resolve name from UserCache
        )
    }
}
