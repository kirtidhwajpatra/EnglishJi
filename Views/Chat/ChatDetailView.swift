import SwiftUI

struct ChatDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatPartner: ChatModel
    
    // 🔥 Initialize ViewModel with the Partner ID
    @StateObject private var viewModel: ChatViewModel
    
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    // Custom Init to inject the partner ID into the ViewModel
    init(chatPartner: ChatModel) {
        self.chatPartner = chatPartner
        
        // We initialize the StateObject with the partner's ID (using their Name as ID for now)
        // Note: In a real app, 'ChatModel' should have a unique .id string, not just .name
        _viewModel = StateObject(wrappedValue: ChatViewModel(partnerId: chatPartner.name))
    }
    
    var body: some View {
        // ... (Keep the rest of your Body code exactly the same) ...
        ZStack(alignment: .top) {
            Color(ej_hex: "F2F2F7").ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                // ... (The rest of your ScrollView logic remains unchanged) ...
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            Spacer().frame(height: 10)
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, msg in
                                // ... (Your existing loop code) ...
                                let isLast = isLastMessage(at: index)
                                let isNewBlock = index > 0 && viewModel.messages[index - 1].isCurrentUser != msg.isCurrentUser
                                
                                MessageBubbleRow(
                                    message: msg,
                                    isLastFromSender: isLast,
                                    partnerName: chatPartner.name
                                )
                                .id(msg.id)
                                .padding(.top, isNewBlock ? 12 : 0)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8, anchor: msg.isCurrentUser ? .bottomTrailing : .bottomLeading).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }
                            Spacer().frame(height: 10)
                        }
                        .padding(.horizontal, 12)
                    }
                    .onAppear { scrollToBottom(proxy: proxy) }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { scrollToBottom(proxy: proxy) }
                    }
                }
                
                inputBarView
            }
        }
        .navigationBarHidden(true)
    }
    
    // ... (Keep your existing helper functions and subviews) ...
    // Note: If you deleted them, I can paste the full file again.
    
    // MARK: - Helpers (Ensure these are still here)
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastId = viewModel.messages.last?.id {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
    
    private func isLastMessage(at index: Int) -> Bool {
        if index == viewModel.messages.count - 1 { return true }
        return viewModel.messages[index].isCurrentUser != viewModel.messages[index + 1].isCurrentUser
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
        .background(Color(ej_hex: "F2F2F7").opacity(0.95))
    }
    
    var inputBarView: some View {
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
            .overlay(Capsule().stroke(Color(ej_hex: "E5E5EA"), lineWidth: 1))
            
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
