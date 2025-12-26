//
//  SketchMark.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 26/12/25.
//

import SwiftUI

struct SketchMark: View {

    let mark: TicTacToeView.Mark

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            if mark == .x {
                drawX(context: &context, center: center)
            } else {
                drawO(context: &context, center: center)
            }
        }
        .frame(width: 70, height: 70)
        .rotationEffect(.degrees(Double.random(in: -3...3)))
        .opacity(0.9)
    }

    private func drawX(context: inout GraphicsContext, center: CGPoint) {
        let o: CGFloat = 18
        let jitter = CGFloat.random(in: -2...2)

        var p1 = Path()
        p1.move(to: CGPoint(x: center.x - o, y: center.y - o + jitter))
        p1.addLine(to: CGPoint(x: center.x + o, y: center.y + o))

        var p2 = Path()
        p2.move(to: CGPoint(x: center.x + o, y: center.y - o))
        p2.addLine(to: CGPoint(x: center.x - o, y: center.y + o + jitter))

        context.stroke(p1, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        context.stroke(p2, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }

    private func drawO(context: inout GraphicsContext, center: CGPoint) {
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - 18,
            y: center.y - 18,
            width: 36,
            height: 36
        ))

        context.stroke(
            path,
            with: .color(.black),
            style: StrokeStyle(lineWidth: 3, lineCap: .round)
        )
    }
}

