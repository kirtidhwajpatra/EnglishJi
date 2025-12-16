//
//  MainHomeScreen.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 09/12/25.
//

import SwiftUI
import AVFoundation
import FirebaseAuth

// MARK: - App Phase
enum AppPhase {
    case home
    case searching
    case inCall
}

// MARK: - Root Content View

struct ContentView: View {

    @StateObject private var webRTCManager = WebRTCManager()
    @State private var currentPhase: AppPhase = .home

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            switch currentPhase {
            case .home:
                HomeView(webRTCManager: webRTCManager)

            case .searching:
                SearchingView(webRTCManager: webRTCManager)

            case .inCall:
                CallInProgressView(webRTCManager: webRTCManager)
            }

            VStack {
                Spacer()
                SignOutView()
                    .padding(.bottom, 30)
            }
        }
        // 🔥 SINGLE SOURCE OF TRUTH FOR CALL UI
        .onChange(of: webRTCManager.isInCall) { inCall in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPhase = inCall ? .inCall : .home
            }
        }
        // 🔥 SEARCHING STATE DRIVEN BY CONNECTION STATE
        .onChange(of: webRTCManager.connectionState) { state in
            withAnimation(.easeInOut(duration: 0.3)) {
                if state == "Searching" {
                    currentPhase = .searching
                }
            }
        }
    }
}

//
// MARK: - Home View
//

struct HomeView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "waveform.circle.fill")
                    .resizable()
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

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                let userId = AuthManager.shared.user?.uid ?? UUID().uuidString
                webRTCManager.startMatchmaking(userId: userId)

            } label: {
                Text("Connect Now")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(50)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
            }
            .padding(.horizontal, 40)

            Spacer().frame(height: 50)
        }
        .padding()
    }
}

//
// MARK: - Searching View
//

struct SearchingView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 150, height: 150)

                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            }

            Text(webRTCManager.connectionState)
                .font(.headline)
                .foregroundColor(.secondary)

            ScrollView {
                Text(webRTCManager.debugLog)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(height: 150)
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)

            Spacer()

            Button("Cancel Search") {
                webRTCManager.disconnect()
            }
            .foregroundColor(.red)
            .padding(.bottom, 50)
        }
        .padding()
    }
}

//
// MARK: - Call In Progress View
//

struct CallInProgressView: View {

    @ObservedObject var webRTCManager: WebRTCManager

    @State private var isMuted = false
    @State private var callDurationSeconds = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Spacer().frame(height: 60)

            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.5))

                Text("Speaking with")
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

            HStack(spacing: 40) {

                CallControlButton(
                    icon: isMuted ? "mic.slash.fill" : "mic.fill",
                    label: "Mute",
                    isActive: isMuted
                ) {
                    isMuted.toggle()
                    webRTCManager.toggleMute(isMuted: isMuted)
                }

                Button {
                    endCall()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(25)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.4), radius: 10)
                }
            }
            .padding(.bottom, 50)
        }
        .background(Color.white)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private var formattedDuration: String {
        let m = callDurationSeconds / 60
        let s = callDurationSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            callDurationSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func endCall() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        stopTimer()
        webRTCManager.disconnect()
    }
}

//
// MARK: - Reusable Call Button
//

struct CallControlButton: View {

    let icon: String
    let label: String
    let isActive: Bool
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

//
// MARK: - Sign Out View
//

struct SignOutView: View {

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

//
// MARK: - Preview
//

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
