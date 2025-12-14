//
//  AudioSessionManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 14/12/25.
//

import AVFoundation

final class AudioSessionManager {

    static func configure() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [
                AVAudioSession.CategoryOptions.allowBluetooth,
                AVAudioSession.CategoryOptions.defaultToSpeaker
            ]
        )
        try? session.setActive(true)
    }
}
