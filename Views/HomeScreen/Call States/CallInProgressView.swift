//
//  CallInProgressView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

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
