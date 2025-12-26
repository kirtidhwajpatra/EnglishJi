import Foundation
import FirebaseFirestore

class ChatService {
    
    static let shared = ChatService()
    private let db = Firestore.firestore()
    
    // Update this function signature to accept 'senderId'
        func sendMessage(text: String, chatRoomId: String, senderId: String) {
            let message = Message(
                id: nil,
                text: text,
                senderId: senderId,
                timestamp: nil
            )
            
            // We use the 'collection' reference so we can attach a completion handler
            let collectionRef = db.collection("conversations")
                .document(chatRoomId)
                .collection("messages")
                
            do {
                // 🔥 ADDED: Completion handler to catch Network/Permission errors
                try collectionRef.addDocument(from: message) { error in
                    if let error = error {
                        print("❌ FIRESTORE WRITE ERROR: \(error.localizedDescription)")
                    } else {
                        print("✅ Message successfully saved to Cloud for Room: \(chatRoomId)")
                    }
                }
            } catch {
                print("❌ Encoding Error: \(error.localizedDescription)")
            }
        }
    
    // 2. LISTEN FOR MESSAGES (Now requires chatRoomId)
    func observeMessages(chatRoomId: String, completion: @escaping ([Message]) -> Void) {
        db.collection("conversations")
            .document(chatRoomId) // 🔥 Dynamic ID
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let messages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                completion(messages)
            }
    }
}
