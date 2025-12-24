//
//  SocialPill.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

struct EnglishJiUser: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: String
}

struct SocialPillView: View {
    // We pass the users in here so this component is reusable
    let users: [EnglishJiUser]
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. Overlapping Avatars
            HStack(spacing: -15) {
                // We use prefix(3) to show only top 3
                ForEach(Array(users.prefix(3).enumerated()), id: \.offset) { index, user in
                    AsyncImage(url: URL(string: user.imageURL)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 45, height: 45) // Matches reference size
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 3) // The "Cutout" effect
                    )
                    .zIndex(Double(users.count - index)) // Stack order
                }
            }
            
            // 2. The Count and Chevron
            HStack(spacing: 4) {
                Text("+\(totalCount)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
        // Shadow to separate it from the background
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ZStack {
        Color.gray
        SocialPillView(users: [
            EnglishJiUser(name: "A", imageURL: "https://i.pravatar.cc/150?img=1"),
            EnglishJiUser(name: "B", imageURL: "https://i.pravatar.cc/150?img=2"),
            EnglishJiUser(name: "C", imageURL: "https://i.pravatar.cc/150?img=3")
        ], totalCount: 45)
    }
}
