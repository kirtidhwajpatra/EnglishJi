import SwiftUI
import Combine

// MARK: - Data Model
struct BannerItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let icon: String
}

struct MotivationalBannerView: View {
    
    // MARK: - Configuration
    private let items: [BannerItem] = [
        BannerItem(text: "You're not alone — learning together!", icon: "paperplane"),
        BannerItem(text: "A safe space to speak our heart out!", icon: "bolt.fill"),
        BannerItem(text: "Every conversation builds confidence!", icon: "sparkles"),
        BannerItem(text: "Real people are practicing right now!", icon: "waveform.circle.fill")
    ]
    
    // MARK: - State
    @State private var currentIndex: Int = 0
    @State private var timer = Timer.publish(every: 8.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            content(for: items[currentIndex])
                .id(items[currentIndex].id)
                .transition(.asymmetric(
                    insertion: .opacity.animation(.easeInOut(duration: 1.5).delay(0.5)),
                    removal: .opacity.animation(.easeInOut(duration: 1.5))
                ))
        }
        .frame(height: 20) // Prevents layout shifts
        .onReceive(timer) { _ in
            cycleNext()
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func content(for item: BannerItem) -> some View {
        HStack(spacing: 6) {
            Image(systemName: item.icon)
                .font(.system(size: 10, weight: .light))
            
            Text(item.text)
                .font(.caption)
                .fontWeight(.regular)
        }
        // Unified color for both Icon and Text
        // "Secondary" gives it that gray look, opacity makes it very subtle
        .foregroundStyle(.secondary.opacity(0.7))
    }
    
    // MARK: - Logic
    private func cycleNext() {
        withAnimation {
            currentIndex = (currentIndex + 1) % items.count
        }
    }
}

#Preview {
    MotivationalBannerView()
}
