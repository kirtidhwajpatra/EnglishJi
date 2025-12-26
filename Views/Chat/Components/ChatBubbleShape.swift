//
//  ChatBubbleShape.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI


// MARK: - Custom Bubble Shape
struct ChatBubbleShape: Shape {
    let isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isCurrentUser ? .bottomLeft : .bottomRight,
                isCurrentUser ? .bottomRight : .bottomLeft
            ],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}
