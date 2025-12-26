//
//  Message.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//
//
//  Message.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let text: String
    let senderId: String
    @ServerTimestamp var timestamp: Date?
    
    // 🔥 FIX: Use the same dynamic logic as the ViewModel
    var isCurrentUser: Bool {
        #if targetEnvironment(simulator)
        return senderId == "user_simulator"
        #else
        return senderId == "user_iphone"
        #endif
    }
}
