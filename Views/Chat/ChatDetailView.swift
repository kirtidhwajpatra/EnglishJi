import SwiftUI

struct ChatDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatPartner: ChatModel
    let roomId: String
    
    // 🔥 Initialize ViewModel with the Partner ID
    @StateObject private var viewModel: ChatViewModel
    
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    // Custom Init to inject the partner ID into the ViewModel
    init(chatPartner: ChatModel, roomId: String) {
        self.chatPartner = chatPartner
        self.roomId = roomId
        
        // We initialize the StateObject with the partner's ID (using their Name as ID for now)
        // Note: In a real app, 'ChatModel' should have a unique .id string, not just .name
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatRoomId: roomId))
    }
    
    var body: some View {
        // ... (Keep the rest of your Body code exactly the same) ...
        ZStack(alignment: .top) {
            Color(hex: "F2F2F7").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                // ... (The rest of your ScrollView logic remains unchanged) ...
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            Spacer().frame(height: 10)
                            
                            // 🔥 LOADING INDICATOR (Pagination)
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding(.bottom, 10)
                            }
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, msg in
                                
                                // 🔥 PAGINATION TRIGGER (Top of list)
                                if index == 0 {
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                viewModel.loadMoreMessages()
                                            }
                                    }
                                    .frame(height: 0)
                                }
                                
                                // 🔥 TIMESTAMP SEPARATOR
                                if shouldShowTimeSeparator(at: index) {
                                    TimeSeparatorView(date: msg.timestamp ?? Date())
                                        .padding(.vertical, 12)
                                }

                                // ... (Your existing loop code) ...
                                let isCurrentUser = (msg.senderId == viewModel.currentUserId)
                                let isLast = isLastMessage(at: index)
                                let isNewBlock = index > 0 && (viewModel.messages[index - 1].senderId == viewModel.currentUserId) != isCurrentUser
                                
                                MessageBubbleRow(
                                    message: msg,
                                    isCurrentUser: isCurrentUser, // Pass Explicitly
                                    isLastFromSender: isLast,
                                    partnerName: chatPartner.name
                                )
                                .id(msg.id)
                                .padding(.top, isNewBlock ? 12 : 0)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8, anchor: isCurrentUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }
                            
                            // 🔥 TYPING INDICATOR
                            if viewModel.isPartnerTyping {
                                HStack(alignment: .bottom, spacing: 8) {
                                    // 1. Partner Avatar
                                    AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(chatPartner.name)")) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    
                                    // 2. Typing Bubble
                                    TypingIndicatorView()
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12) // Match LazyVStack padding
                                .padding(.vertical, 4)
                                .transition(.opacity)
                                .id("TypingBubble") // Allow scrolling to it
                            }

                            Spacer().frame(height: 10)
                            
                            // 🔥 DEBUG ROOM ID
                            Text("Room: \(viewModel.chatRoomId.suffix(10))")
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 12)
                    }
                    .onAppear { scrollToBottom(proxy: proxy) }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scrollToBottom(proxy: proxy) }
                    }
                    // 🔥 Detect Typing
                    .onChange(of: messageText) { _ in
                        viewModel.userDidType()
                    }
                    .onChange(of: viewModel.isPartnerTyping) { isTyping in
                         // Scroll to bottom if typing starts
                         if isTyping {
                             withAnimation {
                                 proxy.scrollTo("TypingBubble", anchor: .bottom)
                             }
                         }
                    }
                    .onChange(of: isFocused) { focused in
                        if focused {
                            // Delay slightly to allow keyboard to appear
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation {
                                    scrollToBottom(proxy: proxy)
                                }
                            }
                        }
                    }
                }
                
                inputBarView
            }
        }
        .navigationBarHidden(true)
    }
    
    // ... (Keep your existing helper functions and subviews) ...
    // Note: If you deleted them, I can paste the full file again.
    
    // MARK: - Helpers
    private func shouldShowTimeSeparator(at index: Int) -> Bool {
        // Always show for first message
        if index == 0 { return true }
        
        // Compare with previous
        let currentMsg = viewModel.messages[index]
        let previousMsg = viewModel.messages[index - 1]
        
        guard let current = currentMsg.timestamp, let previous = previousMsg.timestamp else { return false }
        
        let diff = current.timeIntervalSince(previous)
        return diff > 900 // 15 Minutes (900 seconds)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastId = viewModel.messages.last?.id {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
    
    private func isLastMessage(at index: Int) -> Bool {
        if index == viewModel.messages.count - 1 { return true }
        return viewModel.messages[index].senderId != viewModel.messages[index + 1].senderId
    }

    // MARK: - Subviews
    struct TimeSeparatorView: View {
        let date: Date
        
        var body: some View {
            Text(formatDate(date))
                .font(.system(size: 11, weight: .medium)) // Small, subtle
                .foregroundColor(Color(hex: "8E8E93"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.05)) // Very light pill bg
                .clipShape(Capsule())
        }
        
        func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            if Calendar.current.isDateInToday(date) {
                formatter.dateFormat = "'Today' h:mm a"
            } else if Calendar.current.isDateInYesterday(date) {
                formatter.dateFormat = "'Yesterday' h:mm a"
            } else {
                formatter.dateFormat = "MMM d, h:mm a"
            }
            return formatter.string(from: date)
        }
    }
    
    struct TypingIndicatorView: View {
        @State private var offset: CGFloat = 0
        
        var body: some View {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundColor(Color(hex: "8E8E93"))
                        .offset(y: offset)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(0.1 * Double(i)),
                            value: offset
                        )
                }
            }
            .padding(12)
            .background(Color(hex: "E5E5EA"))
            .clipShape(ChatBubbleShape(isCurrentUser: false))
            .onAppear {
                offset = -5
            }
        }
    }
    
    // MARK: - Subviews (Keep Header and InputBar exactly as they were)
    var headerView: some View {
        ZStack(alignment: .center) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            VStack(spacing: 4) {
                AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(chatPartner.name)")) { phase in
                    if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill) }
                    else { Color.gray.opacity(0.3) }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                Text(chatPartner.name).font(.caption).foregroundColor(.black.opacity(0.6))
            }
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "video")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(Color(hex: "F2F2F7").opacity(0.95))
    }
    
    var inputBarView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: "E5E5EA"))
                    .clipShape(Circle())
            }
            .padding(.bottom, 4)
            
            HStack {
                TextField("iMessage", text: $messageText)
                    .focused($isFocused)
                    .padding(.vertical, 10)
                
                if !messageText.isEmpty {
                    Button(action: {
                        viewModel.sendMessage(text: messageText)
                        messageText = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color(hex: "E5E5EA"), lineWidth: 1))
            
            if messageText.isEmpty {
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "8E8E93"))
                }
                .padding(.bottom, 10)
                .transition(.scale)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "F2F2F7"))
    }
}
