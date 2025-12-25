//
//  AudioToggleView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

struct AudioToggleView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 64)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack(spacing: 3) {
                // Fake Waveform Bars
                RoundedRectangle(cornerRadius: 2).fill(.black).frame(width: 3, height: 12)
                RoundedRectangle(cornerRadius: 2).fill(.black).frame(width: 3, height: 20)
                RoundedRectangle(cornerRadius: 2).fill(.black).frame(width: 3, height: 10)
            }
            
            // The Green "Active" Dot
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .offset(x: 12, y: 8)
        }
    }
}
