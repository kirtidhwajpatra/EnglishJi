import SwiftUI
import Combine

struct LearnerRadarView: View {
    var onClose: () -> Void
    
    // MARK: - State
    @State private var users: [LearnerNode] = []
    @State private var selectedUser: LearnerNode? = nil
    @State private var appearAnimation = false
    
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 1. SOLID BACKGROUND (Fixes the transparency issue)
            Color(red: 0.1, green: 0.1, blue: 0.15) // Dark Modern Background
                .ignoresSafeArea()
            
            // 2. The Grid Effect
            RadarGridBackground()
                .opacity(0.3) // Make grid subtle
            
            // 3. The Interactive Nodes
            GeometryReader { geo in
                ForEach(users) { user in
                    UserNodeView(user: user, isSelected: selectedUser?.id == user.id)
                        .position(
                            x: user.x * geo.size.width,
                            y: user.y * geo.size.height
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedUser = user
                            }
                        }
                }
            }
            .padding(20)
            
            // 4. Header (Back Button & Title)
            VStack {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white) // White icon
                            .padding()
                            .background(Color.white.opacity(0.1)) // Glassy bg
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Live Learners")
                        .font(.headline)
                        .foregroundColor(.white)
                        .tracking(1) // Letter spacing for premium feel
                    
                    Spacer()
                    
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.horizontal)
                .padding(.top, 60) // Safe area spacing
                
                Spacer()
            }
            .padding(.top, -60)
            
            // 5. User Detail Card (Pop up)
            if let user = selectedUser {
                VStack {
                    Spacer()
                    UserProfileCard(user: user) {
                        withAnimation(.spring()) {
                            selectedUser = nil
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(100)
                }
            }
        }
        .onAppear {
            generateInitialUsers()
            withAnimation(.spring(duration: 1.0)) {
                appearAnimation = true
            }
        }
        .onReceive(timer) { _ in
            simulateRealTimeUpdates()
        }
    }
    
    // ... (Keep your existing generateInitialUsers and simulateRealTimeUpdates logic here)
    // If you need the logic again, let me know, but it should be in your file already.
    func generateInitialUsers() {
        users = [
            LearnerNode(name: "Jessica", image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200", status: .activeNow, x: 0.5, y: 0.4),
            LearnerNode(name: "David", image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200", status: .activeNow, x: 0.2, y: 0.3),
            LearnerNode(name: "Ana", image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200", status: .recentlyActive, x: 0.8, y: 0.2),
            LearnerNode(name: "Raj", image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200", status: .offline, x: 0.7, y: 0.7),
            LearnerNode(name: "Sarah", image: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200", status: .activeNow, x: 0.3, y: 0.8)
        ]
    }
    
    func simulateRealTimeUpdates() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            if let index = users.indices.randomElement() {
                users[index].x += Double.random(in: -0.05...0.05)
                users[index].y += Double.random(in: -0.05...0.05)
                users[index].x = max(0.1, min(0.9, users[index].x))
                users[index].y = max(0.2, min(0.8, users[index].y)) // Keep away from edges
            }
        }
    }
}


// MARK: - PREVIEW
#Preview {
    // We wrap it in a ZStack to ensure the dark theme context is clear
    ZStack {
        Color.black.ignoresSafeArea()
        
        LearnerRadarView(onClose: {
            print("Close Action Tapped")
        })
    }
}
