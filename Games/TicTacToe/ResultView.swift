//
//  ResultView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 26/12/25.
//

import SwiftUI


struct ResultView: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .multilineTextAlignment(.center)
            .foregroundColor(.black)
            .padding()
            .transition(.opacity.combined(with: .scale))
            .animation(.easeInOut, value: text)
    }
}
