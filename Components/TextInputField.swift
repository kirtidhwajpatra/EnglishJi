import SwiftUI

struct NameInputScreen: View {
    // MARK: - Properties
    // Using file-private colors to ensure zero conflicts
    private let backgroundColor = Color.specificHex("#F1F1F1")
    private let activeColor = Color.specificHex("0F0039")
    private let accentColor = Color.specificHex("4F378B") // Slightly lighter purple for glow
    
    // Form State
    @State private var firstName: String = ""
    @State private var middleName: String = ""
    @State private var lastName: String = ""
    
    // Focus State
    @FocusState private var focusedField: Field?
    
    enum Field {
        case first, middle, last
    }
    
    var body: some View {
        ZStack {
            // 1. Background
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // 2. The Input Stack
                VStack(spacing: 8) {
                    
                    // First Name
                    PremiumTextField(
                        text: $firstName,
                        placeholder: "First Name",
                        isActive: focusedField == .first
                    )
                    .focused($focusedField, equals: .first)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .middle }
                    
                    // Middle Name
                    PremiumTextField(
                        text: $middleName,
                        placeholder: "Middle Name",
                        isActive: focusedField == .middle
                    )
                    .focused($focusedField, equals: .middle)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .last }
                    
                    // Last Name
                    PremiumTextField(
                        text: $lastName,
                        placeholder: "Last Name",
                        isActive: focusedField == .last
                    )
                    .focused($focusedField, equals: .last)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                }
                .padding(.horizontal, 24)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - World Class Text Component WITH CUSTOM CARET
struct PremiumTextField: View {
    @Binding var text: String
    var placeholder: String
    var isActive: Bool
    
    @FocusState private var focused: Bool
    @State private var showCaret: Bool = true
    
    // Caret settings
    private let caretWidth: CGFloat = 2.4
    private let caretHeight: CGFloat = 28
    private let caretColor = Color.specificHex("#0F0039")
    
    var body: some View {
        ZStack {
            // Background card
            Rectangle()
                .fill(Color.white)
                .cornerRadius(4)
                .frame(width: 264, height: 50)
                .overlay(
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)
                        .opacity(0.2),
                    alignment: .bottom
                    
                )
                .scaleEffect(isActive ? 1 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
                .overlay(
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)
                        .opacity(focused ? 1 : 0.3)
                        .scaleEffect(x: focused ? 1 : 0, y: 1, anchor: .center)
                        .animation(.easeInOut(duration: 0.25), value: focused),
                    alignment: .bottom
                )
            
            // CENTERED TEXT + CARET
            HStack(spacing: 0) {
                Spacer()   // push to center
                
                HStack(spacing: 0) {
                    // Actual text (centered)
                    Text(text)
                        .font(.system(size: 32))
                        .kerning(-1)
                        .foregroundColor(Color.specificHex("#110037"))
                    
                    // Caret (only when focused)
                    if focused {
                        Rectangle()
                            .fill(caretColor)
                            .frame(width: caretWidth, height: caretHeight)
                            .opacity(showCaret ? 1 : 0)
                            .animation(.easeInOut(duration: 0.25), value: showCaret)
                            .onAppear { startCaretBlink() }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()   // keep centered
            }
            .frame(width: 264, height: 50)
            
            // Invisible TextField
            TextField("", text: $text)
                .focused($focused)
                .font(.system(size: 32))
                .kerning(-1)
                .multilineTextAlignment(.center)
                .foregroundColor(.clear)
                .accentColor(.clear)
                .frame(width: 264, height: 50)
                .background(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 32))
                                .kerning(-1)
                                .foregroundColor(Color.gray.opacity(0.25))
                        }
                    }
                )
        }
        .frame(height: 60)
    }
    
    // MARK: - Caret Animation
    private func startCaretBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { _ in
            if focused {
                withAnimation { showCaret.toggle() }
            } else {
                showCaret = false
            }
        }
    }
}



// MARK: - Private Helper
private extension Color {
    static func specificHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct NameInputScreen_Previews: PreviewProvider {
    static var previews: some View {
        NameInputScreen()
    }
}
