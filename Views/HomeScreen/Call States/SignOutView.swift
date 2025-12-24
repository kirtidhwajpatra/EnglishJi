//
//  SignOutView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI
import FirebaseAuth

struct SignOutView: View {

    // Assuming AuthManager is defined elsewhere in your project
    @ObservedObject var authManager = AuthManager.shared

    var body: some View {
        Button("Sign Out") {
            authManager.signOut()
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.red)
        .cornerRadius(25)
        .padding(.horizontal, 100)
    }
}
