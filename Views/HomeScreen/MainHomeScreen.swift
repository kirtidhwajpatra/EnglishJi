//
//  MainHomeScreen.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI
import AVFoundation
import FirebaseAuth

// MARK: - Models / State

/// Represents the current phase of the user journey through the app.
enum AppPhase {
    case home
    case searching
    case inCall
}

// MARK: - Main Content View (The Controller)

struct ContentView: View {
    // This state variable controls the entire flow of the application.
    @State private var currentPhase: AppPhase = .home
    @StateObject private var webRTCManager = WebRTCManager()
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            // Background Color
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Main Switcher Logic
            Group {
                switch currentPhase {
                case .home:
                    HomeView(currentPhase: $currentPhase, webRTCManager: webRTCManager)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .searching:
                    SearchingView(currentPhase: $currentPhase, webRTCManager: webRTCManager)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                case .inCall:
                    CallInProgressView(currentPhase: $currentPhase, webRTCManager: webRTCManager)
                        .transition(.move(edge: .bottom))
                }
            }
            // Ensure animations run smoothly between state changes
            .animation(.easeInOut(duration: 0.4), value: currentPhase)
            
            SignOutView()
                .padding(.top, 700)
                
        }
        // REAL LOGIC: React to WebRTC State Changes
        .onChange(of: webRTCManager.connectionState) { newState in
            print("UI Received State Update: \(newState)")
            
            if newState == "Connected" {
                currentPhase = .inCall
            }
            else if newState == "Disconnected" || newState == "Failed" {
                currentPhase = .home
            }
        }
    }
}

// MARK: - 1. Home Screen View

struct HomeView: View {
    @Binding var currentPhase: AppPhase
    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Header
            VStack(spacing: 10) {
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("English Talk")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Practice speaking with learners worldwide.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Connect Button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                    // ✅ Start matchmaking ONLY from here
                    let userId = AuthManager.shared.user?.uid ?? UUID().uuidString

                    withAnimation {
                        currentPhase = .searching
                    }

                    webRTCManager.startMatchmaking(userId: userId)
            }) {
                Text("Connect Now")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(50)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)

            Spacer().frame(height: 50)
        }
        .padding()
    }

    func startSearching() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let userId = AuthManager.shared.user?.uid ?? UUID().uuidString
        webRTCManager.startMatchmaking(userId: userId)

        withAnimation {
            currentPhase = .searching
        }
    }

}

// MARK: - 2. Searching Screen View

struct SearchingView: View {
    @Binding var currentPhase: AppPhase
    @ObservedObject var webRTCManager: WebRTCManager
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated radar/spinner icon
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 150, height: 150)
                
                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            }

            // REAL STATUS FROM MANAGER
            Text("\(webRTCManager.connectionState)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // DEBUG LOG
            ScrollView {
                Text("\(webRTCManager.debugLog)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(height: 150)
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)
            
            Spacer()

            // Cancel Button
            Button("Cancel Search") {
                webRTCManager.disconnect()
                currentPhase = .home
            }
            .foregroundColor(.red)
            .padding(.bottom, 50)
        }
        .padding()
        .onAppear {
            if webRTCManager.connectionState == "Idle" || webRTCManager.connectionState == "Disconnected" {
                let userId = AuthManager.shared.user?.uid ?? UUID().uuidString
//                webRTCManager.log("Searching screen shown")
            }
        }
    }
}

// MARK: - 3. Call Progress Screen View

struct CallInProgressView: View {
    @Binding var currentPhase: AppPhase
    @ObservedObject var webRTCManager: WebRTCManager
    
    @State private var isMuted = false
    @State private var isSpeakerOn = true
    @State private var callDurationSeconds = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Spacer().frame(height: 60)

            // Partner Info area
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.5))
                    .background(Circle().fill(Color.white))
                    .shadow(radius: 5)

                Text("Speaking with:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Language Partner")
                    .font(.title)
                    .fontWeight(.bold)

                Text(formattedDuration)
                    .font(.title2)
                    .monospacedDigit()
                    .foregroundColor(.gray)
            }

            Spacer()

            // Call Controls
            HStack(spacing: 40) {
                CallControlButton(icon: isMuted ? "mic.slash.fill" : "mic.fill",
                                  label: "Mute",
                                  isActive: isMuted) {
                    isMuted.toggle()
                    webRTCManager.toggleMute(isMuted: isMuted)
                }

                Button(action: endCall) {
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(25)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.4), radius: 10)
                }

                CallControlButton(icon: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                                  label: "Speaker",
                                  isActive: isSpeakerOn) {
                    isSpeakerOn.toggle()
                }
            }
            .padding(.bottom, 50)
        }
        .background(.white)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Call Logic Helpers

    var formattedDuration: String {
        let minutes = callDurationSeconds / 60
        let seconds = callDurationSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.callDurationSeconds += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func endCall() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        stopTimer()
        webRTCManager.disconnect()
    }
}

struct CallControlButton: View {
    let icon: String
    let label: String
    var isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .primary)
                    .frame(width: 60, height: 60)
                    .background(isActive ? Color.blue : Color.gray.opacity(0.15))
                    .clipShape(Circle())
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SignOutView: View {
    // Uses the Singleton accessed from your other file
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
        Button(action: {
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
        .padding(.horizontal, 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
