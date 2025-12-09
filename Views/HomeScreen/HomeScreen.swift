//
//  HomeScreen.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI

struct HomeScreen: View {
    // Access the shared AuthManager
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome Home!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("You are securely logged in.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // SIGN OUT BUTTON
                Button(action: {
                    // This single line triggers the logout
                    // The RootView will detect this and automatically switch back to Login screen
                    authManager.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
