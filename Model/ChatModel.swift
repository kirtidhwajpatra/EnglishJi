import Foundation
import FirebaseFirestore

struct ChatModel: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let lastMessage: String
    @ServerTimestamp var timestamp: Date?
    var unreadCounts: [String: Int]? // Map of UserID -> Count (Nullable to prevent decode failure)
    let profileImage: String
    
    // UI Helpers
    var timeAgo: String {
        guard let date = timestamp else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Helper to get unread count for current user
    func unreadCount(for userId: String) -> Int {
        return unreadCounts?[userId] ?? 0
    }
}
