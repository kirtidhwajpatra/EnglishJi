import SwiftUI

struct DiscoverUser: Identifiable {
    let id = UUID()
    let name: String
    let gender: Gender
    let flag: String
    let bio: String
    let age: Int
    let image: String
    let blobColor: Color
    let cardColor: Color
    var accents: [Color]?
    
    enum Gender { case male, female }
}
