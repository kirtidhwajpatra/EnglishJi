

import Foundation
import AudioToolbox

class ChatAudioManager {
    static let shared = ChatAudioManager()
    
    func playSentSound() {
        // ID 1004 is the native iOS "Sent Message" swoosh sound
        AudioServicesPlaySystemSound(1004)
    }
    
    func playReceivedSound() {
        // ID 1003 is the native iOS "Received Message" sound
        AudioServicesPlaySystemSound(1003)
    }
}
