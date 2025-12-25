//
//  ProfileView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI

struct ProfileView: View {
    
    // Using simple Dismiss action if needed
    @Environment(\.dismiss) var dismiss
    

    
   var body: some View {
        ZStack(alignment: .top) {

            Color(ej_hex: "F2F2F7").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Top clearance
                    Spacer().frame(height: 96)

                    // MARK: - A. Profile Section
                    VStack(spacing: 18) {

                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 110, height: 110)

                            Image("veena")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 10, y: 5)

                            Text("🇺🇸")
                                .font(.system(size: 20))
                                .padding(5)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
                                .offset(x: 0, y: 82)
                        }

                        VStack(spacing: 6) {
                            Text("Veena Singh")
                                .font(.system(size: 24, weight: .bold))

                            Text("Focus: Casual Conversation")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(ej_hex: "8E8E93"))
                        }
                    }

                    // 🔥 separation from progress
                    Spacer().frame(height: 40)

                    // MARK: - B. Progress Section
                    VStack(spacing: 12) {

                        HStack {
                            HStack(spacing: 4) {
                                Text("09:17")
                                    .fontWeight(.semibold)
                                Image(systemName: "sun.max.fill")
                                    .font(.caption2)
                            }
                            .font(.caption)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.caption2)
                                Text("B2 Intermediate")
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(ej_hex: "E5E5EA"))
                                    .frame(height: 6)

                                Capsule()
                                    .fill(Color(ej_hex: "34C759"))
                                    .frame(width: geo.size.width * 0.55, height: 6)

                                Image(systemName: "airplane")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.black)
                                    .background(Color(ej_hex: "F2F2F7"))
                                    .clipShape(Circle())
                                    .padding(2)
                                    .offset(x: geo.size.width * 0.55 - 10)
                            }
                        }
                        .frame(height: 14)

                        Text("Next level in 14 days")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(Color(ej_hex: "34C759"))
                    }
                    .padding(.horizontal, 10)

                    // 🔥 separation from achievements
                    Spacer().frame(height: 46)

                    // MARK: - C. Achievements
                    VStack(spacing: 14) {

                        HStack(spacing: 12) {
                            StatsPill(
                                icon: "wind",
                                text: "12 Day Streak",
                                bgColor: "#E1E1E1",
                                iconColor: "007AFF"
                            )

                            StatsPill(
                                icon: "bolt.fill",
                                text: "No turbulence",
                                bgColor: "#E1E1E1",
                                iconColor: "FF9500"
                            )
                        }

                        StatsPill(
                            icon: "clock.fill",
                            text: "No delay",
                            bgColor: "#E1E1E1",
                            iconColor: "AF52DE"
                        )
                    }

                    // 🔥 separation before map
                    Spacer().frame(height: 46)

                    // MARK: - D. Map Section
                    ZStack(alignment: .topLeading) {
                        AsyncImage(
                            url: URL(string: "https://images.unsplash.com/photo-1524661135-423995f22d0b")
                        ) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color(ej_hex: "E5E5EA")
                            }
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 28))

                        HStack(spacing: 6) {
                            Circle().fill(Color.red).frame(width: 6, height: 6)
                            Text("Live discovery view")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(20)

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "viewfinder")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(16)
                    }

                    // MARK: - Bottom clearance for CTA
                    Spacer().frame(height: 140)
                }
                .padding(.horizontal, 24)
            }

            // MARK: - Sticky Top Pills
            VStack {
                HStack {
                    Button(action: {
                        dismiss() // 🔥 This closes the profile
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    
                    Spacer()
                        // ... rest of your styling
                    CapsulePill(text: "Setting")
                   
                    CapsulePill(text: "Online", color: "34C759", filled: true)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()
            }

            // MARK: - Sticky Bottom CTA
            VStack {
                Spacer()
                Button(action: {}) {
                    Text("Edit Profile")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 0)
            }
        }
    }

}

// MARK: - Helper: Stats Pill (Icon + Color Support)
struct StatsPill: View {
    let icon: String
    let text: String
    let bgColor: String
    let iconColor: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color(ej_hex: iconColor))

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.horizontal, 14)   // 👈 controls width
        .padding(.vertical, 9)      // 👈 controls height
        .background(Color(ej_hex: bgColor))
        .clipShape(Capsule())
    }
}


// MARK: - Helper: Top Capsule Pill
struct CapsulePill: View {
    let text: String
    var color: String = "FFFFFF"
    var filled: Bool = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(filled ? Color(ej_hex: "D0F8CE") : Color.white) // Light green bg if filled
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Color Extension
extension Color {
    init(ej_hex: String) {
        let hex = ej_hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ProfileView()
}
