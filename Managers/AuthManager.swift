//
//  AuthManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 08/12/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import Combine

class AuthManager: NSObject, ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String = ""
    
    // Singleton instance
    static let shared = AuthManager()
    
    override init() {
        super.init()
        // Listen to auth changes (persists login state)
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        // 1. Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Root View Controller not found")
            return
        }
        
        // 2. Start the Google Sign In flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(false)
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            // 3. Create Firebase Credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            // 4. Authenticate with Firebase
            Auth.auth().signIn(with: credential) { res, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Error signing out")
        }
    }
}
