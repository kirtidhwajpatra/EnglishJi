//
//  MainHomeScreen.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI
import AVFoundation // Imported just for the idea of audio, though not strictly used in UI

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
                    HomeView(currentPhase: $currentPhase)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .searching:
                    SearchingView(currentPhase: $currentPhase)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                case .inCall:
                    CallInProgressView(currentPhase: $currentPhase)
                        .transition(.move(edge: .bottom))
                }
            }
            // Ensure animations run smoothly between state changes
            .animation(.easeInOut(duration: 0.4), value: currentPhase)
            
            SignOutView()
                .padding(.top, 700)
                
        }
    }
}

// MARK: - 1. Home Screen View

struct HomeView: View {
    @Binding var currentPhase: AppPhase

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
                startSearching()
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
        // Simple haptic feedback for button press
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation {
            currentPhase = .searching
        }
    }
}

// MARK: - 2. Searching Screen View

struct SearchingView: View {
    @Binding var currentPhase: AppPhase
    // State to animate dots or show different text over time
    @State private var searchStatusText = "Finding a conversation partner..."

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

            Text(searchStatusText)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()

            // Cancel Button
            Button("Cancel Search") {
                currentPhase = .home
            }
            .foregroundColor(.red)
            .padding(.bottom, 50)
        }
        .padding()
        .onAppear {
            simulateFindingMatch()
        }
    }

    /// Simulates backend matchmaking logic
    func simulateFindingMatch() {
        // Delay for 2 seconds to simulate searching, then transition to call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Ensure we are still on the searching screen before transitioning
            // (in case they hit cancel quickly)
            if currentPhase == .searching {
                searchStatusText = "Partner found! Connecting..."
                
                // Slight delay further before showing the call screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   currentPhase = .inCall
                }
            }
        }
    }
}

// MARK: - 3. Call Progress Screen View

struct CallInProgressView: View {
    @Binding var currentPhase: AppPhase
    
    @State private var isMuted = false
    @State private var isSpeakerOn = false
    @State private var callDurationSeconds = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            
            
            // Top Spacer to push content down
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

                Text("Maria S.") // Placeholder name
                    .font(.title)
                    .fontWeight(.bold)

                // Call Timer
                Text(formattedDuration)
                    .font(.title2)
                    .monospacedDigit() // Keeps numbers from jumping around
                    .foregroundColor(.gray)
            }

            Spacer()

            // Call Controls Container
            HStack(spacing: 40) {
                
                // Mute Button
                CallControlButton(icon: isMuted ? "mic.slash.fill" : "mic.fill",
                                  label: "Mute",
                                  isActive: isMuted) {
                    isMuted.toggle()
                }

                // End Call Button (Prominent)
                Button(action: endCall) {
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(25)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.4), radius: 10)
                }

                // Speaker Button
                CallControlButton(icon: isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                                  label: "Speaker",
                                  isActive: isSpeakerOn) {
                    isSpeakerOn.toggle()
                }
                
                
            }
            .padding(.bottom, 50)
            
            
        }
        .background(.white)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        
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
        currentPhase = .home
    }
}

// Helper component for square call buttons (Mute/Speaker)
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
                    // Change background color if active
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
    @ObservedObject var authManager = AuthManager.shared
    
    var body: some View {
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
        .padding(.horizontal, 100)

    }
    }



// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
