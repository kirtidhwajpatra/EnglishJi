//
//  AudioSessionManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 17/12/25.
//

import WebRTC
import AVFoundation

final class AudioSessionManager {

    static func configure() {
        let session = RTCAudioSession.sharedInstance()
        // session.useManualAudio = false // Default is false (Let WebRTC manage activation)
        session.lockForConfiguration()
        do {
            // 🔥 Configure, but don't Activate. Let WebRTC activate when the track starts.
            try session.setCategory(AVAudioSession.Category.playAndRecord, with: [.allowBluetooth, .defaultToSpeaker, .allowAirPlay, .allowBluetoothA2DP, .mixWithOthers])
            try session.setMode(AVAudioSession.Mode.videoChat)
            print("✅ AudioSessionManager: Configured RTCAudioSession preferences (Passive)")
        } catch {
            print("❌ AudioSessionManager: Failed to configure audio session: \(error)")
        }
        session.unlockForConfiguration()
    }
    
    static func setSpeaker(enabled: Bool) {
        let session = RTCAudioSession.sharedInstance()
        session.lockForConfiguration()
        do {
            // 💡 Switch MODE instead of Port Override to save the Mic
            let mode = enabled ? AVAudioSession.Mode.videoChat : AVAudioSession.Mode.voiceChat
            try session.setMode(mode)
            print("🔊 AudioSessionManager: Mode set to \(enabled ? "VideoChat (Speaker)" : "VoiceChat (Ear)")")
        } catch {
            print("❌ AudioSessionManager: Failed to set speaker: \(error)")
        }
        session.unlockForConfiguration()
    }
}
