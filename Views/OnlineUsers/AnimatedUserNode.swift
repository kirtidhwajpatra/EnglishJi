//
//  AnimatedUserNode.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//
import SwiftUI

struct UserNodeView: View {
    let user: LearnerNode
    let isSelected: Bool
    
    // Derived properties for animation
    var nodeSize: CGFloat {
        if isSelected { return 90 }
        switch user.status {
        case .activeNow: return 75
        case .recentlyActive: return 45
        case .offline: return 0 // Hidden
        }
    }
    
    var shadowRadius: CGFloat {
        user.status == .activeNow ? 10 : 2
    }
    
    var body: some View {
        ZStack {
            // Pulse Effect for Active Users
            if user.status == .activeNow {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    .frame(width: nodeSize * 1.6, height: nodeSize * 1.6)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            
            // The Image
            AsyncImage(url: URL(string: user.image)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.gray
                }
            }
            .frame(width: nodeSize, height: nodeSize)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: isSelected ? 4 : 2)
            )
            .shadow(color: .black.opacity(0.2), radius: shadowRadius, y: 5)
            
            // Status Indicator Dot (if active)
            if user.status == .activeNow {
                Circle()
                    .fill(Color.green)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: nodeSize/2 * 0.7, y: -nodeSize/2 * 0.7)
            }
        }
        // Spring animation when properties change
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: user.status)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isSelected)
    }
}
