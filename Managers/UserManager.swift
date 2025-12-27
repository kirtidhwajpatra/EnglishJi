import Foundation
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    
    // 🔥 CENTRALIZED USER ID LOGIC
    // Ensures WebRTC (Call) and Chat (List/Detail) ALWAYS use the same ID.
    var currentUserId: String {
        // 1. If Real Firebase Auth exists, use it.
        // 🔥 DISABLE AUTH FOR NOW to fix Simulator Mismatch
        // The user wants to see chats for 'user_simulator_XXXX', but Auth returns 'iRZPC...'
        // if let authId = Auth.auth().currentUser?.uid {
        //    return authId
        // }
        
        // 2. Otherwise, use Persistent Simulator/Guest ID from UserDefaults
        // 2. Otherwise, use Persistent Simulator/Guest ID from UserDefaults
        // 🔥 RESETTING IDENTITY TO v3 to clear legacy 'user_gen' IDs
        let key = "current_user_id_v3"
        if let stored = UserDefaults.standard.string(forKey: key) {
            return stored
        }
        
        // 3. Generate New Persistent ID
        #if targetEnvironment(simulator)
        let newId = "user_simulator_\(Int.random(in: 1000...9999))"
        #else
        let newId = "user_iphone_\(Int.random(in: 1000...9999))"
        #endif
        
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
}
