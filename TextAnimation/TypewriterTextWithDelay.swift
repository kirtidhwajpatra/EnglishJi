//
//  TypewriterText.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct TypewriterTextWithDelay: View {
    let fullText: String
    let typingSpeed: Double
    let delay: Double
    
    @State private var revealedCount = 0
    @State private var hasStarted = false
    
    var characters: [String] {
        fullText.map { String($0) }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(characters.indices, id: \.self) { index in
                Text(characters[index])
                    .opacity(index < revealedCount ? 1 : 0)
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                startTyping()
            }
        }
    }
    
    private func startTyping() {
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if revealedCount < characters.count {
                revealedCount += 1
            } else {
                timer.invalidate()
            }
        }
    }
}


