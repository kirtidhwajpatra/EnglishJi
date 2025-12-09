//
//  OnboardingStep.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import Foundation

enum OnboardingStep: Int, CaseIterable {
    case screen1
    case screen2
    case screen3
    case screen4
    case screen5
    case screen8

    var next: OnboardingStep? {
        let all = OnboardingStep.allCases
        let index = self.rawValue + 1
        return index < all.count ? all[index] : nil
    }
}
