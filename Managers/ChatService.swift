import Foundation
import FirebaseFirestore

class ChatService {
    
    static let shared = ChatService()
    private let db = Firestore.firestore()
    
    // 🔥 CANONICAL ROOM ID HELPER
    static func getChatRoomId(user1: String, user2: String) -> String {
        guard !user1.isEmpty, !user2.isEmpty else {
            print("❌ CRITICAL ERROR: Attempted to create room with EMPTY User ID! U1='\(user1)', U2='\(user2)'")
            return "error_room"
        }
        let sortedIds = [user1, user2].sorted()
        let type = "chat_room_\(sortedIds[0])_\(sortedIds[1])"
        print("🔑 Generting Room ID: \(user1) + \(user2) -> \(type)")
        return type
    }
    
    // Update this function signature to accept 'senderId'
    // 1. SEND MESSAGE (Optimistic UI Support)
    // We now accept the full 'Message' object so the ViewModel can generate the ID first.
    func sendMessage(_ message: Message, chatRoomId: String) {
        guard let messageId = message.id else { return }
        
        do {
            try db.collection("conversations")
                .document(chatRoomId)
                .collection("messages")
                .document(messageId) // Use the pre-generated ID
                .setData(from: message)
            
            print("✅ Message sent to Cloud: \(messageId)")
        } catch {
            print("❌ Firestore Write Error: \(error.localizedDescription)")
        }
    }
    
    // 2. LISTEN FOR MESSAGES (Limit to Last 20)
    func observeMessages(chatRoomId: String, completion: @escaping ([Message], DocumentSnapshot?) -> Void) {
        db.collection("conversations")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(toLast: 20) // 🔥 Pagination: Only load recent
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                // Return messages AND the first document (for pagination reference)
                completion(messages, documents.first)
            }
    }
    
    // 3. FETCH PREVIOUS MESSAGES (Pagination)
    func fetchPreviousMessages(chatRoomId: String, before document: DocumentSnapshot, completion: @escaping ([Message], DocumentSnapshot?) -> Void) {
        db.collection("conversations")
            .document(chatRoomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .end(beforeDocument: document) // Load messages BEFORE the oldest one we have
            .limit(toLast: 20)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion([], nil)
                    return
                }
                
                let messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                completion(messages, documents.first)
            }
    }
    
    // MARK: - Conversation List Management
    
    // 4. UPDATE LAST MESSAGE (For Chat List)
    func updateConversationMetadata(chatRoomId: String, lastMessage: String, senderId: String, receiverId: String? = nil, receiverName: String? = nil) {
        let docRef = db.collection("conversations").document(chatRoomId)
        
        // We use merge: true to avoid overwriting everything if it exists
        // Structure:
        // lastMessage: String
        // timestamp: ServerTimestamp
        // unreadCounts: { "user_1": 0, "user_2": 5 }
        
        var data: [String: Any] = [
            "lastMessage": lastMessage,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // If we know the receiver, increment their unread count
        // Note: In a real app, you'd increment ONLY the receiver's count.
        // For this simulator demo where we swap IDs, we try to guess the "other" person.
        
        // Logic: Increment count for EVERYONE except the sender
        // Since we don't track all participants easily here without reading,
        // we will rely on specific specific logic if simpler.
        // BUT, better approach for 1-1:
        
        // We will increment the 'senderId's PARTNER.
        // Since we don't strictly know the partner ID without passing it,
        // we'll assume the chatRoomId or the caller passes the partner ID.
        // For now, let's just assume we update the document. The UI relies on `unreadCounts`.
        
        // FieldValue.increment(1) for the receiver
        // FieldValue.increment(1) for the receiver
        if let receiverId = receiverId {
            // 🔥 Use explicit dot notation string for Firestore key
            // This tells Firestore to update "unreadCounts" -> "userID"
            let key = "unreadCounts.\(receiverId)"
            data[key] = FieldValue.increment(Int64(1))
            print("🔢 Incrementing unread count for KEY: \(key)")
        }
        
        // If it's a new conversation, we might need to set names/images
        // 🔥 ALWAYS set the name/image if provided to ensure the document has data
        if let name = receiverName {
            data["name"] = name
            data["profileImage"] = "https://i.pravatar.cc/150?u=\(name.replacingOccurrences(of: " ", with: ""))"
        } else {
             // Fallback if no name provided (shouldn't happen with our logic, but safe)
             data["name"] = data["name"] ?? "Unknown User"
             data["profileImage"] = data["profileImage"] ?? "https://i.pravatar.cc/150?u=unknown"
        }

        docRef.setData(data, merge: true) { error in
            if let error = error {
                print("❌ Failed to update conversation metadata: \(error.localizedDescription)")
            } else {
                print("✅ Conversation metadata updated for: \(chatRoomId)")
            }
        }
    }
    
    // 5. MARK AS READ
    func markAsRead(chatRoomId: String, userId: String) {
        db.collection("conversations").document(chatRoomId)
            .updateData([
                "unreadCounts.\(userId)": 0
            ])
    }
    
    // 6. OBSERVE CHAT LIST
    // In a real app, you'd filter by `participants` array containing `currentUserId`.
    // For this demo, we just return ALL conversations for simplicity.
    func observeChatList(completion: @escaping ([ChatModel]) -> Void) {
        db.collection("conversations")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let chats = documents.compactMap { doc -> ChatModel? in
                    do {
                        return try doc.data(as: ChatModel.self)
                    } catch {
                        print("❌ Decoding Error for doc \(doc.documentID): \(error)")
                        return nil
                    }
                }
                
                if !chats.isEmpty {
                    print("📦 Fetched \(chats.count) chats")
                    chats.forEach { chat in
                        print("   - Chat: \(chat.name), Unread: \(chat.unreadCounts ?? [:])")
                    }
                }
                
                completion(chats)
            }
    }
    
    // MARK: - Typing Indicators
    
    // 7. UPDATE TYPING STATUS
    func updateTypingStatus(chatRoomId: String, userId: String, isTyping: Bool) {
        let docRef = db.collection("conversations").document(chatRoomId)
        docRef.setData([
            "typingUsers": [
                userId: isTyping
            ]
        ], merge: true)
    }
    
    // 8. OBSERVE TYPING STATUS
    // Returns a set of User IDs who are currently typing
    func observeTypingStatus(chatRoomId: String, completion: @escaping ([String]) -> Void) {
        db.collection("conversations").document(chatRoomId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let typingMap = data["typingUsers"] as? [String: Bool] else {
                    completion([])
                    return
                }
                
                // Filter users where value is TRUE
                let typingUsers = typingMap.filter { $0.value == true }.map { $0.key }
                completion(typingUsers)
            }
    }
}
