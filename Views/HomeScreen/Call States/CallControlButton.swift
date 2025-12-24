//
//  CallControlButton.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI

struct CallControlButton: View {

    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isActive ? .white : .primary)
                    .frame(width: 60, height: 60)
                    .background(isActive ? Color.blue : Color.gray.opacity(0.15))
                    .clipShape(Circle())

                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
