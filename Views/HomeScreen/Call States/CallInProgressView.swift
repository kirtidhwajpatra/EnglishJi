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
    @State private var animationWave = false

    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle animated elements
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)
                .blur(radius: 50)
            
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 150)
                .blur(radius: 50)

            // MARK: - Content
            VStack {
                Spacer().frame(height: 50)
                
                // Connection Status
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)

                Spacer()
                
                // Avatar Area with Ripple
                ZStack {
                    if !isMuted {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 220, height: 220)
                            .scaleEffect(animationWave ? 1.1 : 1.0)
                            .opacity(animationWave ? 0 : 1)
                            .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: animationWave)
                    }
                    
                    AsyncImage(url: URL(string: "https://i.pravatar.cc/300?img=32")) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                }
                .onAppear {
                    animationWave = true
                }
                
                Spacer().frame(height: 30)

                VStack(spacing: 8) {
                    Text("Language Partner")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(formattedDuration)
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()

                // Bottom Controls
                HStack(spacing: 50) {
                    
                    // Mute Button
                    Button {
                        isMuted.toggle()
                        webRTCManager.toggleMute(isMuted: isMuted)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isMuted ? Color.white : Color.white.opacity(0.1))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                    .font(.title2)
                                    .foregroundColor(isMuted ? .black : .white)
                            }
                            Text("Mute")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }

                    // End Call Button
                    Button {
                        endCall()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 80, height: 80) // Slightly larger
                                    .shadow(color: .red.opacity(0.5), radius: 10)
                                
                                Image(systemName: "phone.down.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Text("End")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Speaker Button (Mock for now)
                    Button {
                         UIImpactFeedbackGenerator(style: .light).impactOccurred()
                         // Toggle speaker logic here
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Text("Speaker")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
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

