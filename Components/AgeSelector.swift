import SwiftUI
import UIKit

// MARK: - Main Screen
struct AgeSelectionScreen: View {

    private let backgroundColor = SafeColor.fromHex("#F1F1F1")
    private let cardColor = SafeColor.fromHex("#F1F1F1")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {

                ZStack {
                    cardColor

                    VStack(spacing: 0) {
                        AgeSelectorReel()
                            .padding(.vertical, 20)

                        ZStack {
                            SafeColor.fromHex("#110037")
                            Text("We’ll match you with\nlearners your age.")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                    }
                }
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(hex: "#110037"), lineWidth: 12)
                )
                .padding(.horizontal, 44)
                .frame(height: 500)
            }
        }
    }
}

// MARK: - Age Selector Component
struct AgeSelectorReel: View {

    private let range = 17...60
    private let activeColor = SafeColor.fromHex("0F0039")

    @State private var currentAgeValue: Double = 20
    @State private var lastHapticIndex: Int = 20
    @State private var isDragging: Bool = false
    @State private var dragStartAge: Double? = nil

    var selectedAge: Int { Int(round(currentAgeValue)) }

    var body: some View {
        ZStack {

            GeometryReader { geo in
                let midY = geo.size.height / 2

                VStack(spacing: 0) {
                    ForEach(range, id: \.self) { age in
                        numberView(for: age)
                            .frame(height: dynamicRowHeight(for: age))
                            .onTapGesture { smoothScroll(to: age) }
                    }
                }
                .offset(y: midY - selectedItemCenterOffset())
            }
            .clipped()

            // Drag gestures
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        handleDragChange(translation: value.translation.height)
                    }
                    .onEnded { value in
                        isDragging = false
                        handleDragEnd(predictedEnd: value.predictedEndTranslation.height)
                    }
            )

            // Arrows
            HStack {
                arrowButton(icon: "arrowtriangle.right.fill") {}
                Spacer()
                arrowButton(icon: "arrowtriangle.left.fill") {}
            }
            .padding(.horizontal, 10)
            .allowsHitTesting(!isDragging)
        }
        .background(
            Color.white.opacity(1)
                .frame(height: 70)
        )
    }

    // MARK: - Number Style
    private func numberView(for age: Int) -> some View {
        let distance = abs(Double(age) - currentAgeValue)
        let style = interpolatedStyle(distance: distance)

        return Text("\(age)")
            .font(.custom("Futura-CondensedExtraBold", size: 60))
            .kerning(-2)
            .foregroundColor(activeColor)
            .scaleEffect(style.scale)
            .opacity(style.opacity)
            .blur(radius: style.blur)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private func arrowButton(icon: String, action: @escaping () -> Void) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .black))
            .foregroundColor(activeColor)
            .padding(10)
    }

    // MARK: - Dynamic Spacing
    private func dynamicRowHeight(for age: Int) -> CGFloat {
        let distance = abs(Double(age) - currentAgeValue)

        switch distance {
        case 0: return 70     // center
        case 1: return 62
        case 2: return 54
        case 3: return 46
        default: return 38    // far
        }
    }

    private func selectedItemCenterOffset() -> CGFloat {
        var total: CGFloat = 0

        for age in range {
            if age < selectedAge {
                total += dynamicRowHeight(for: age)
            }
        }

        return total + dynamicRowHeight(for: selectedAge) / 2
    }

    // MARK: - Style Interpolation
    private func interpolatedStyle(distance: Double)
    -> (scale: CGFloat, opacity: Double, blur: CGFloat)
    {
        switch distance {
        case 0:
            return (1.0, 1.0, 0)
        case 1:
            return (0.85, 0.55, 0)
        case 2:
            return (0.7, 0.35, 0.4)
        case 3:
            return (0.55, 0.2, 0.8)
        default:
            return (0.45, 0.1, 1.5)
        }
    }

    // MARK: - Drag Logic
    private func handleDragChange(translation: CGFloat) {
        if dragStartAge == nil { dragStartAge = currentAgeValue }

        guard let start = dragStartAge else { return }

        let delta = Double(-translation / 55)
        let newValue = start + delta
        let clamped = min(max(newValue, Double(range.lowerBound)), Double(range.upperBound))

        withAnimation(.interactiveSpring()) {
            currentAgeValue = clamped
        }

        triggerHapticIfNeeded(for: clamped)
    }

    private func handleDragEnd(predictedEnd: CGFloat) {
        dragStartAge = nil

        let velocity = Double(-predictedEnd / 55) * 0.2
        let endValue = currentAgeValue + velocity
        smoothScroll(to: Int(round(endValue)))
    }

    private func smoothScroll(to age: Int) {
        let clamped = min(max(age, range.lowerBound), range.upperBound)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
            currentAgeValue = Double(clamped)
        }

        triggerHapticIfNeeded(for: Double(clamped))
    }

    private func triggerHapticIfNeeded(for value: Double) {
        let nearest = Int(round(value))
        if nearest != lastHapticIndex {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            lastHapticIndex = nearest
        }
    }
}

// MARK: - Safe Color Helper
struct SafeColor {
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

struct AgeSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AgeSelectionScreen()
    }
}
