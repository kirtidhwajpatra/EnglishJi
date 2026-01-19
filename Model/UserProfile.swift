//
//  UserProfile.swift
//  EnglishJi
//
//  Created by Agent on 19/01/26.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    let name: String
    let profileImageURL: String
    let bio: String
    let location: String
    let interests: [String]
    let stats: UserStats
    let isOnline: Bool
    let joinDate: Date
    
    // For preview/mock data
    static let mock = UserProfile(
        id: "user_123",
        name: "Aarav Sharma",
        profileImageURL: "https://i.pravatar.cc/300?img=11",
        bio: "Language enthusiast 📚 | Learning English purely for travel purposes ✈️",
        location: "Mumbai, India",
        interests: ["Travel", "Movies", "Cricket", "Food"],
        stats: UserStats(friends: 142, gamesPlayed: 56, streakDays: 12),
        isOnline: true,
        joinDate: Date().addingTimeInterval(-86400 * 365) // Joined 1 year ago
    )
}

struct UserStats: Codable {
    let friends: Int
    let gamesPlayed: Int
    let streakDays: Int
}
