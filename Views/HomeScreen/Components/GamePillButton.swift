//
//  GamePillButton.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 26/12/25.
//

import SwiftUI

struct GamePillButton: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "scribble")
                .font(.system(size: 24, weight: .medium))
            
//            Text("Play")
//                .font(.system(size: 15, weight: .medium))
        }
        .foregroundColor(Color(hex: "1C1C1E"))
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.white)
        )
        
        .overlay(
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    
        
    }
}

