//
//  OnboardingManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI
import Combine

class OnboardingManager: ObservableObject {
    @Published var step: OnboardingStep = .screen1
    
    // user selections
    @Published var level: String = ""
    @Published var persona: String = ""
    @Published var name: String = ""
    @Published var ageColorHex: String = "#FFFFFF"
    @Published var speakingSpeed: Double = 0.5

    func goNext() {
        if let next = step.next {
            withAnimation(.easeInOut(duration: 0.35)) {
                step = next
            }
        }
    }
}
