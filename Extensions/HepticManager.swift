//
//  HepticManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 27/12/25.
//

import SwiftUI
import CoreHaptics

// MARK: - Design Theme
struct Theme {
    // High-end gradients similar to Apple's marketing materials
    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color.black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let xGradient = LinearGradient(
        colors: [.cyan, .blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let oGradient = LinearGradient(
        colors: [.orange, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let boardMaterial: Material = .ultraThinMaterial
    static let cornerRadius: CGFloat = 24
}

// MARK: - Haptic Feedback Helper
class HapticManager {
    static let shared = HapticManager()
    
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func successFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func drawFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
