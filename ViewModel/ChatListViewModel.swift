import SwiftUI
import Combine

class ChatListViewModel: ObservableObject {
    @Published var conversations: [ChatModel] = []
    
    // 🔥 AUTOMATIC ID SWITCHING (Consistent with UserManager)
    var currentUserId: String {
        return UserManager.shared.currentUserId
    }
    
    init() {
        print("👤 ChatListViewModel Init. My ID: \(currentUserId)")
        fetchConversations()
    }
    
    func fetchConversations() {
        print("📡 ChatListViewModel: Fetching conversations...")
        ChatService.shared.observeChatList { [weak self] chats in
            guard let self = self else { return }
            
            // 🔥 FILTER: Only show chats that actually involve ME.
            // This hides "Legacy" chats created with random temporary IDs.
            let myChats = chats.filter { chat in
                guard let roomId = chat.id else { return false }
                return roomId.contains(self.currentUserId)
            }
            
            print("✅ ChatListViewModel: Received \(chats.count) total, \(myChats.count) are mine.")
            self.conversations = myChats
        }
    }
    
    func markAsRead(_ chat: ChatModel) {
        guard let chatId = chat.id else { return }
        ChatService.shared.markAsRead(chatRoomId: chatId, userId: currentUserId)
    }
}
