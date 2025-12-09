//
//  RootView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI

struct RootView: View {
    // Listens to the AuthManager state
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.user != nil {
                // User is logged in
                ContentView()
                    .transition(.move(edge: .trailing)) // Smooth slide animation
            } else {
                // User is NOT logged in
                OnboardingContainerView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: authManager.user) // Animate the switch
    }
}
