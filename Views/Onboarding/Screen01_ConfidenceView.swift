import SwiftUI

struct Screen01_ConfidenceView: View {
    @ObservedObject var manager: OnboardingManager

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#3F1A94")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // MARK: - HEADER WITH FIXED HEIGHT (NO SHIFTING)
                ZStack {
                    VStack(spacing: -18) {
                        TypewriterTextWithDelay(fullText: "LET'S TURN", typingSpeed: 0.03, delay: 0)
                        TypewriterTextWithDelay(fullText: "YOUR ENGLISH", typingSpeed: 0.03, delay: 0.3)
                        TypewriterTextWithDelay(fullText: "INTO", typingSpeed: 0.03, delay: 0.6)
                        TypewriterTextWithDelay(fullText: "CONFIDENCE", typingSpeed: 0.03, delay: 0.9)
                    }
                    .font(.custom("Futura-CondensedExtraBold", size: 42))
                    .foregroundColor(Color(hex: "#F1F1F1"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                }
                // FIXED SPACE RESERVED FOR THE HEADER
                .frame(height: 200)   // << adjust until perfect

                

                // MARK: - SUB ICONS
                HStack(spacing: 20) {
                    AnimatedSubIcon(
                        text: "Real talk",
                        iconName: "talk",
                        iconColor: Color(hex: "#FF69B4"),
                        delay: 0.9
                    )
                    
                    AnimatedSubIcon(
                        text: "Real people",
                        iconName: "people",
                        iconColor: Color(hex: "#40E0D0"),
                        delay: 1.3
                    )
                    
                    AnimatedSubIcon(
                        text: "Real progress",
                        iconName: "progress",
                        iconColor: Color(hex: "#7FFF00"),
                        delay: 1.6
                    )
                }

                Spacer()

                // MARK: - STATIC CARDS
                ZStack {
                    FloatingCardAnimated(
                        letter: "U",
                        fill: Color(hex: "#E2409E"),
                        rotation: -12,
                        offset: CGSize(width: -60, height: -55),
                        delay: 2
                    )
                    
                    FloatingCardAnimated(
                        letter: "V",
                        fill: Color(hex: "#FF9000"),
                        rotation: 12,
                        offset: CGSize(width: 60, height: 40),
                        delay: 3
                    )
                }


                Spacer()

                // MARK: - CONTINUE BUTTON
                AnimatedCTAButton(delay: 3.6) {        // adjust delay as needed
                    manager.goNext()
                } content: {
                    Text("Continue")
                        .font(.custom("Futura-Bold", size: 20))
                        .kerning(-0.5)
                        .foregroundColor(Color(hex: "#3F1A94"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(hex: "#F1F1F1"))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

            }
            .padding(.top, 30)
        }
    }
}

#Preview {
    Screen01_ConfidenceView(manager: OnboardingManager())
}
