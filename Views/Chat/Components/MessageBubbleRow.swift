//
//  MessageBubbleRow.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI

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
