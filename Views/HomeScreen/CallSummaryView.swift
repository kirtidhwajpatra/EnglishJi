import SwiftUI

struct CallSummaryView: View {
    @ObservedObject var webRTCManager: WebRTCManager
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    // Partner info derived from Manager
    var partnerId: String {
        webRTCManager.lastCallPartnerId
    }
    
    // Generate Room ID using canonical helper
    var roomId: String {
        return ChatService.getChatRoomId(user1: webRTCManager.myUserId, user2: partnerId)
    }

    var body: some View {
        ZStack {
            Color(hex: "F2F2F7").ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "phone.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Call Ended")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("How was your conversation?")
                        .foregroundColor(.secondary)
                }
                
                // Message Input
                VStack(alignment: .leading) {
                    Text("Send a follow-up message:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    TextEditor(text: $messageText)
                        .frame(height: 100)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .focused($isFocused)
                }
                .padding(.horizontal, 24)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: sendMessage) {
                        HStack {
                            Text("Send Message")
                                .fontWeight(.semibold)
                            Image(systemName: "paperplane.fill")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(messageText.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .disabled(messageText.isEmpty)
                    
                    Button(action: skip) {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    // Actions
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let senderId = webRTCManager.myUserId
        let receiverId = partnerId
        
        // Safety Check
        guard roomId != "error_room", !receiverId.isEmpty else {
            print("❌ Cannot send message. Invalid Room or Partner ID.")
            return
        }
        
        // 1. Send Message
        let message = Message(
            id: UUID().uuidString,
            text: messageText,
            senderId: senderId,
            timestamp: Date()
        )
        ChatService.shared.sendMessage(message, chatRoomId: roomId)
        
        // 2. Update List Metadata
        // Note: For 'receiverName', in a real app you'd fetch it.
        // Here we just use a generic name or what we know.
        let receiverName = (receiverId == "user_iphone") ? "Real iPhone User" : "Simulator User"
        
        ChatService.shared.updateConversationMetadata(
            chatRoomId: roomId,
            lastMessage: messageText,
            senderId: senderId,
            receiverId: receiverId,
            receiverName: receiverName
        )
        
        // 3. Dismiss
        dismiss()
    }
    
    func skip() {
        dismiss()
    }
    
    func dismiss() {
        withAnimation {
            webRTCManager.showCallSummary = false
        }
    }
}
