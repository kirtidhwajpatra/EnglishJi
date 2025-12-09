//
//  Screen04_PersonaView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct Screen04_PersonaView: View {
    @ObservedObject var manager: OnboardingManager
    @State private var selectedPersona: String?
    
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F1F1F1") // Dark Purple
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - PROGRESS BAR
                HStack(spacing: 6) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(index < 1 ? Color(hex: "#110037") : Color.black.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                // MARK: - HEADER
                VStack(spacing: -14) {
                    TypewriterTextWithDelay(fullText: "WHAT'S", typingSpeed: 0.05, delay: 0)
                    TypewriterTextWithDelay(fullText: "YOUR AGE?", typingSpeed: 0.05, delay: 0.8)
                }
                .font(.custom("Futura-CondensedExtraBold", size: 36))
                .foregroundColor(Color(hex: "#110037"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(height: 120)
                
                // MARK: - AGE Selector
                VStack {
                    AgeSelectionScreen()
                    
                                    }
                
                Spacer()
                
                // MARK: - CONTINUE BUTTON
                AnimatedCTAButton(delay: 1.0) {
                    manager.goNext()
                } content: {
                    Text("Continue")
                        .font(.system(size: 20, weight: .medium))                        .kerning(-0.2)
                        .foregroundColor(Color(hex: "#F1F1F1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "#3F1A94"))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    Screen04_PersonaView(manager: OnboardingManager())
}
