//
//  ChatViewModel.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    
    // 1. DATA SOURCE
    @Published var messages: [Message] = []
    
    // 2. CONFIGURATION
    private let chatRoomId: String
    
    // 🔥 AUTOMATIC ID SWITCHING
    // This trick allows you to chat between Simulator and Real iPhone instantly.
    var currentUserId: String {
        #if targetEnvironment(simulator)
        return "user_simulator" // The Simulator is always this person
        #else
        return "user_iphone"    // Your Physical Device is always this person
        #endif
    }
    
    // 3. INITIALIZATION
        init(partnerId: String) {
            
            // A. Generate the Unique Room ID (Assign this FIRST!)
            // We are hardcoding this for the Simulator vs. iPhone test.
            self.chatRoomId = "global_test_room_iphone_vs_sim"
            
            // B. Determine who is chatting (Now it's safe to use 'self')
            let myId = self.currentUserId
            
            print("🚀 My ID: \(myId)")
            print("🔗 Connecting to Chat Room: \(self.chatRoomId)")
            
            // C. Start Listening to Firestore
            ChatService.shared.observeMessages(chatRoomId: chatRoomId) { [weak self] newMessages in
                self?.messages = newMessages
                
                // Play received sound if the last message wasn't from me
                if let last = newMessages.last, !last.isCurrentUser {
                     ChatAudioManager.shared.playReceivedSound()
                }
            }
        }
    
    // 4. ACTIONS
    func sendMessage(text: String) {
        // Send using the dynamic ID (so the other device knows it wasn't them)
        ChatService.shared.sendMessage(text: text, chatRoomId: chatRoomId, senderId: currentUserId)
        
        // Local Feedback
        ChatAudioManager.shared.playSentSound()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
