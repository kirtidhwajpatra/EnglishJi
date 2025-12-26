import SwiftUI

struct CellView: View {

    let mark: TicTacToeView.Mark?
    let disabled: Bool
    let action: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            // ✅ THIS is the missing piece
            Rectangle()
                .fill(Color.clear)

            if let mark {
                SketchMark(mark: mark)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.25)) {
                            appeared = true
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // extra safety
        .onTapGesture {
            guard !disabled else { return }
            print("CELL TAPPED")
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }
    }
}
