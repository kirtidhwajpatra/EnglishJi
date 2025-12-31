//
//  EnglishJiApp.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import WebRTC
import AVFoundation

@main
struct EnglishJiApp: App {
    
    // 🔥 USER REQUEST: GLOBAL INIT REVERTED
    // We are moving to a specific "Hardware-Aligned" config in WebRTCClient
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// 2. Configure Firebase on launch
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // 3. Handle Google Sign In URL redirect
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
