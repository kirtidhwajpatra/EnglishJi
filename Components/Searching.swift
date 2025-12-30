import SwiftUI

// MARK: - 1. The Search Icon Shape (From previous step)
struct SearchIcon: View {
    let strokeColor = Color(red: 0.40, green: 0.40, blue: 0.40)
    
    var body: some View {
        ZStack {
            // Circle
            Path { path in
                path.addEllipse(in: CGRect(x: 0.73, y: 0.73, width: 15.74, height: 15.74))
            }
            .stroke(strokeColor, lineWidth: 1.47)
            
            // Handle
            Path { path in
                path.move(to: CGPoint(x: 12.54, y: 12.85))
                path.addCurve(
                    to: CGPoint(x: 19.66, y: 19.99),
                    control1: CGPoint(x: 13.05, y: 13.72),
                    control2: CGPoint(x: 17.12, y: 18.26)
                )
            }
            .stroke(strokeColor, style: StrokeStyle(lineWidth: 1.57, lineCap: .round))
        }
        .frame(width: 21, height: 21)
        .scaleEffect(CGSize(width: 1.2, height: 1.2))
    }
}

// MARK: - 2. The Animated Search Container
struct AnimatedSearchView: View {
    @State private var isSearching = false
    @State private var searchText = ""
    
    // 1. Focus State: Controls the keyboard programmatically
    @FocusState private var isFocused: Bool
    
    private let animationPhysics: Animation = .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Right-Align Logic: Spacer pushes icon right when inactive
            if !isSearching {
                Spacer()
            }
            
            // The Icon
            SearchIcon()
                .scaleEffect(isSearching ? 1.15 : 1.0)
                .frame(width: 24, height: 24)
                .onTapGesture {
                    withAnimation(animationPhysics) {
                        isSearching.toggle()
                        if !isSearching {
                            searchText = ""
                            isFocused = false // Dismiss keyboard
                        }
                    }
                }
                .layoutPriority(1)
            
            // The Search Field
            if isSearching {
                VStack(spacing: 8) {
                    TextField("Search...", text: $searchText)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        // 2. Bind Focus: This connects the field to the variable
                        .focused($isFocused)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                // 3. Auto-Open Keyboard: When this view appears, trigger focus
                .onAppear {
                    isFocused = true
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 50)
        // 4. THE STICKY FIX: Prevents the layout from jumping up when keyboard opens
//        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// MARK: - Preview Logic
struct AnimatedSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) { // Align top to simulate a header
            Color(white: 0.95).ignoresSafeArea()
            
            VStack {
                // The Search Bar
                AnimatedSearchView()
                    .background(Color.white) // Optional: Just to see it clearly in preview
                
                Spacer() // Pushes everything to the top
            }
        }
    }
}
