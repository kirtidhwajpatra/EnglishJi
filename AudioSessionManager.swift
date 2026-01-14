
import AVFoundation
import WebRTC

/// Centralized manager for all audio session configuration and routing.
/// Handles WebRTC audio setup, interruptions, and route changes.
final class AudioSessionManager: NSObject {
    
    static let shared = AudioSessionManager()
    
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private var isAudioEnabled: Bool = false
    
    // MARK: - Configuration
    
    private struct AudioConfig {
        static let sampleRate: Double = 48000.0
        static let ioBufferDuration: TimeInterval = 0.005 // 5ms for low latency
    }
    
    override private init() {
        super.init()
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public API
    
    /// Configures the audio session for VoIP usage.
    /// Should be called before starting any WebRTC connection.
    func configureAudioSession() {
        rtcAudioSession.lockForConfiguration()
        defer { rtcAudioSession.unlockForConfiguration() }
        
        do {
            // Configure strictly for VoIP to avoid issues with standard media playback modes
            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                           with: [.allowBluetooth, .allowBluetoothA2DP, .duckOthers])
            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat)
            try rtcAudioSession.setPreferredSampleRate(AudioConfig.sampleRate)
            try rtcAudioSession.setPreferredIOBufferDuration(AudioConfig.ioBufferDuration)
            
            // Force speaker output by default for video calls/loudspeaker mode
            // Note: In a real app, you might want to toggle this based on proximity or user choice.
            try rtcAudioSession.overrideOutputAudioPort(.speaker)
            
            print("[AudioSessionManager] Configuration applied: PlayAndRecord, VoiceChat, 48kHz")
        } catch {
            print("[AudioSessionManager] ❌ Configuration failed: \(error.localizedDescription)")
        }
    }
    
    /// Activates the shared WebRTC audio session.
    func activateSession() {
        guard !isAudioEnabled else { return }
        
        rtcAudioSession.lockForConfiguration()
        defer { rtcAudioSession.unlockForConfiguration() }
        
        do {
            try rtcAudioSession.setActive(true)
            rtcAudioSession.add(self) // Listen for WebRTC-specific audio events
            isAudioEnabled = true
            print("[AudioSessionManager] Session activated")
        } catch {
            print("[AudioSessionManager] ❌ Failed to activate session: \(error.localizedDescription)")
        }
    }
    
    /// Deactivates the audio session.
    func deactivateSession() {
        guard isAudioEnabled else { return }
        
        rtcAudioSession.lockForConfiguration()
        defer { rtcAudioSession.unlockForConfiguration() }
        
        do {
            try rtcAudioSession.setActive(false)
            rtcAudioSession.remove(self)
            isAudioEnabled = false
            print("[AudioSessionManager] Session deactivated")
        } catch {
             print("[AudioSessionManager] ❌ Failed to deactivate session: \(error.localizedDescription)")
        }
    }
    
    /// Toggles the microphone mute state.
    func setMicrophoneMuted(_ muted: Bool) {
         // This is typically handled by WebRTC tracks, but if we need hardware level control:
         // AVAudioSession doesn't have a simple "mute input" without stopping the graph.
         // We rely on WebRTCManager to mute the local track.
    }
    
    // MARK: - Interruptions & Routing
    
    private func setupNotificationObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        center.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            print("[AudioSessionManager] ⚠️ Interruption began")
            // System usually handles pausing connection automatically
        case .ended:
            print("[AudioSessionManager] ✅ Interruption ended")
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                // Re-activate if necessary
                activateSession()
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        
        print("[AudioSessionManager] Route changed: \(reason)")
        
        // Detect if headphones were unplugged
        if reason == .oldDeviceUnavailable {
             // Potentially fallback to speaker
            configureAudioSession()
        }
    }
}

// MARK: - RTCAudioSessionDelegate

extension AudioSessionManager: RTCAudioSessionDelegate {
    func audioSessionDidStartPlayOrRecord(_ session: RTCAudioSession) {
        // Enforce our config whenever WebRTC takes control
        print("[AudioSessionManager] WebRTC started play/record. Enforcing config.")
        configureAudioSession()
    }
    
    func audioSessionDidStopPlayOrRecord(_ session: RTCAudioSession) {
        print("[AudioSessionManager] WebRTC stopped play/record.")
    }
}
