//
//  DataModel.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

enum UserStatus {
    case activeNow
    case recentlyActive
    case offline
}

struct LearnerNode: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: String
    var status: UserStatus
    // We use normalized coordinates (0.0 to 1.0) so it scales on any screen
    var x: Double
    var y: Double
}
