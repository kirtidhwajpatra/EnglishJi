//
//  AnimatedCTAButton.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct AnimatedCTAButton<Content: View>: View {
    let delay: Double
    let action: () -> Void
    let content: () -> Content
    
    @State private var appear = false
    
    var body: some View {
        Button(action: {
            // HAPTIC FEEDBACK
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            action()
        }) {
            content()
                .scaleEffect(appear ? 1 : 1.6)      // zoomed-out → natural size
                .blur(radius: appear ? 0 : 14)      // blurred → sharp
                .opacity(appear ? 1 : 0)            // fade-in
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(delay),
                    value: appear
                )
        }
        .onAppear {
            appear = true
        }
    }
}

