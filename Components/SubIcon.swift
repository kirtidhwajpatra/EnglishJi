//
//  SubIcon.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//
import SwiftUI

struct AnimatedSubIcon: View {
    let text: String
    let iconName: String
    let iconColor: Color
    let delay: Double
    
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 6) {
            Image(iconName)
                .renderingMode(.template)
                .foregroundColor(iconColor)
            
            Text(text)
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(Color(hex: "#F1F1F1"))
        .blur(radius: appear ? 0 : 10)              // blur → clear
        .offset(y: appear ? 0 : 12)                 // rise animation
        .opacity(appear ? 1 : 0)                    // fade-in
        .animation(
            .easeOut(duration: 0.6)
            .delay(delay),
            value: appear
        )
        .onAppear { appear = true }
    }
}
