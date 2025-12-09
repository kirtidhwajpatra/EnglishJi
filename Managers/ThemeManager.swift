//
//  ThemeManager.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("accentColor") var accentColorHex: String = "#FFFFFF"

    var accentColor: Color {
        Color(hex: accentColorHex)
    }
}
