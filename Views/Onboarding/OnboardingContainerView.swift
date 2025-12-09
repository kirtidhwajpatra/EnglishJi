//
//  OnboardingContainerView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject var manager = OnboardingManager()
    @StateObject var theme = ThemeManager()

    var body: some View {
        ZStack {
            switch manager.step {
            case .screen1:
                Screen01_ConfidenceView(manager: manager)
            case .screen2:
                Screen04_PersonaView(manager: manager)
            case .screen3:
                Screen05_NameView(manager: manager)
            case .screen4:
                Screen06_AgeColorView(manager: manager)
            case .screen5:
                LocationScreen(manager: manager)
            case .screen8:
                AuthenticationScreen(manager: manager)
            
            }
            
        }
        .accentColor(theme.accentColor)
        .animation(.easeInOut, value: manager.step)
    }
}
