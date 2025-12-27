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
    
    // Explicit Init for creating local messages
    init(id: String? = nil, text: String, senderId: String, timestamp: Date? = nil) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
    }
    

}
