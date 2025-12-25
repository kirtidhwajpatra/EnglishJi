//
//  Settings.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

//
//  SettingsView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // Theme Color (Emerald Green)
    let themeGreen = Color(ej_hex: "110037")
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - 1. BACKGROUND
            Color(ej_hex: "F2F2F7").ignoresSafeArea()
            
            // MARK: - 2. CONTENT
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- HEADER (Back Button + Premium Pill) ---
                    HStack(alignment: .center) {
                        // Back Button (Replaces "Profile" Text)
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        
                        Spacer()
                        
                        // Top "Get Premium" Pill
                        
                    }
                    .padding(.top, 20)
                    
                    // --- SECTION 1: GENERAL ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("General")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            // Personal Details
                            SettingsRow(icon: "person.fill", title: "Personal details", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Language
                            SettingsRow(icon: "globe", title: "Language", value: "English", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Rate Us
                            SettingsRow(icon: "star.fill", title: "Rate us", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Privacy Policy
                            SettingsRow(icon: "shield.fill", title: "Privacy Policy", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Terms
                            SettingsRow(icon: "doc.text.fill", title: "Terms Of Use", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Feedback
                            SettingsRow(icon: "envelope.fill", title: "Feedback", color: themeGreen)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // --- PREMIUM BANNER ---
                    Button(action: {}) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Get Premium")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Enjoy all the benefits of the app")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [Color(ej_hex: "110037"), Color(ej_hex: "110048")], // Rich Green Gradient
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: themeGreen.opacity(0.4), radius: 12, y: 6)
                    }
                    
                    // --- SECTION 2: ACCOUNT ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            // Delete Account
                            SettingsRow(icon: "trash.fill", title: "Delete account", color: themeGreen)
                            Divider().padding(.leading, 52)
                            
                            // Logout
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Logout", color: themeGreen)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Version / Footer Space
                    Spacer().frame(height: 50)
                    
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Reusable Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Optional Value Text
                if let val = value {
                    Text(val)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(ej_hex: "C7C7CC"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18) // Comfortable touch area
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
