import SwiftUI

struct FriendsListView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    
    // Theme Colors
    let darkText = Color(hex: "1F3B34")
    let playButtonGreen = Color(hex: "355E3B") // Deep forest green
    let lightGreyBg = Color(hex: "F2F2F7")
    
    // Dummy Data Model
    struct Friend: Identifiable {
        let id = UUID()
        let name: String
        let imageName: String // Using assets or placeholders
    }
    
    let friends = [
        Friend(name: "Henry Storey", imageName: "person.crop.circle"), // Replace with real asset names if available
        Friend(name: "Henry Storey", imageName: "person.crop.circle"),
        Friend(name: "Henry Storey", imageName: "person.crop.circle"),
        Friend(name: "Henry Storey", imageName: "person.crop.circle"),
        Friend(name: "Henry Storey", imageName: "person.crop.circle"),
        Friend(name: "Henry Storey", imageName: "person.crop.circle"),
        Friend(name: "Henry Storey", imageName: "person.crop.circle")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Header
            HStack {
                // Back Button (Circular Grey)
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.turn.up.left") // Matches "return" style icon
                        .font(.system(size: 18, weight: .regular))
                        .padding(14)
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Share Button (Circular Grey)
                Button(action: { }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .regular))
                        .padding(14)
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            // 2. Title
            Text("Chose a friend to play")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(darkText)
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            // 3. Search Bar (Underlined)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
                
                TextField("Search for a friend", text: $searchText)
                    .font(.system(size: 18))
            }
            .padding(.bottom, 8)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.4)),
                alignment: .bottom
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            
            // 4. List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(friends) { friend in
                        HStack(spacing: 16) {
                            // Avatar
                            Image("User1") // Using asset if possible, or fallback
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                                // Fallback if asset missing:
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .opacity(UIImage(named: "User1") == nil ? 1 : 0)
                                )
                            
                            // Name
                            Text(friend.name)
                                .font(.system(size: 19, weight: .regular))
                                .foregroundColor(darkText)
                            
                            Spacer()
                            
                            // "Play" Button
                            NavigationLink(destination: GameSelectionView(showBackButton: true)) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 10))
                                    Text("Play")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Color(hex: "DDEE88")) // Lime/Yellowish Text
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(playButtonGreen) // Dark Green BG
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(lightGreyBg)
                        .cornerRadius(32) // Very rounded
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 40)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    FriendsListView()
}
