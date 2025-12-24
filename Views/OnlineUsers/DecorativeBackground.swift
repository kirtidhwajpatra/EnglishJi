//
//  DecorativeBackground.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//
import SwiftUI

struct RadarGridBackground: View {
    var body: some View {
        ZStack {
            // Concentric Circles
            ForEach(0..<4) { i in
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    .scaleEffect(CGFloat(i) * 0.3 + 0.2)
            }
            
            // Map Lines (Abstract)
            Path { path in
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 900))
                path.move(to: CGPoint(x: 0, y: 300))
                path.addLine(to: CGPoint(x: 500, y: 500))
            }
            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        }
    }
}
