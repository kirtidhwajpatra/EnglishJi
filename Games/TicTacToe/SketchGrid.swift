import SwiftUI

import SwiftUI

struct SketchGrid: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            let lines: [(CGPoint, CGPoint)] = [
                (CGPoint(x: w/3, y: 10), CGPoint(x: w/3 + 4, y: h - 10)),
                (CGPoint(x: 2*w/3, y: 10), CGPoint(x: 2*w/3 - 4, y: h - 10)),
                (CGPoint(x: 10, y: h/3), CGPoint(x: w - 10, y: h/3 + 3)),
                (CGPoint(x: 10, y: 2*h/3), CGPoint(x: w - 10, y: 2*h/3 - 3))
            ]

            for (start, end) in lines {
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)

                context.stroke(
                    path,
                    with: .color(.black.opacity(0.8)),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }
        }
        .frame(width: 270, height: 270)
        .allowsHitTesting(false)   // 🔥 THIS IS THE KEY LINE
    }
}
