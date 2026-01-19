//
//  Settings.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 25/12/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // Theme Colors
    let limeGreen = Color.ejLightGreen
    let darkText = Color.ejDarkerGreen
    
    @State private var isCallExperienceExpanded = true // Expanded by default
    
    // Call Experience Models
    @State private var callLength = "Unlimited" // Example state
    @State private var conversationStyle = "Casual"
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - 1. BACKGROUND
            Color.white.ignoresSafeArea() // White background based on design
            
            // MARK: - 2. CONTENT
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- HEADER ---
                    HStack(alignment: .center) {
                        // Back Button
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color(hex: "F2F2F7")) // Grey circle
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Share/Action Button
                        Button(action: { }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(.black)
                                .padding(12)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 4)
                    
                    // --- SETTINGS LIST ---
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // GROUP 1: Main Settings (Combined Card)
                        VStack(spacing: 0) {
                            
                            // 1. Profile
                            SettingsRowItem(icon: "person", title: "Profile", isFirst: true)
                            Divider().padding(.leading, 52).opacity(0.5)
                            
                            // 2. Call experience (Expandable)
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        isCallExperienceExpanded.toggle()
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "phone")
                                            .font(.system(size: 20, weight: .light))
                                            .foregroundColor(.black)
                                            .frame(width: 24)
                                        
                                        HStack(alignment: .top, spacing: 4) {
                                            Text("Call experience")
                                                .font(.system(size: 17, weight: .regular))
                                                .foregroundColor(.black)
                                            
                                            // Pro Badge
                                            Text("Pro")
                                                .font(.system(size: 9, weight: .bold)) // Smaller font
                                                .foregroundColor(darkText)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(limeGreen) // Lime Green
                                                .cornerRadius(4)
                                                .offset(y: -5)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .background(Color(hex: "F2F2F7"))
                                }
                                
                                if isCallExperienceExpanded {
                                    VStack(spacing: 0) {
                                        Divider().padding(.leading, 52).opacity(0.5)
                                        SettingsSubRow(label: "Preferred call length")
                                        Divider().padding(.leading, 52).opacity(0.5)
                                        SettingsSubRow(label: "Conversation Style")
                                        Divider().padding(.leading, 52).opacity(0.5)
                                        SettingsSubRow(label: "Audio Quality")
                                        Divider().padding(.leading, 52).opacity(0.5)
                                        SettingsSubRow(label: "Auto Reconnect")
                                    }
                                    .background(Color(hex: "F2F2F7"))
                                }
                            }
                            
                            Divider().padding(.leading, 52).opacity(0.5)
                            
                            // 3. Match & Discovery
                            SettingsRowItem(icon: "person.2", title: "Match & Discovery")
                            Divider().padding(.leading, 52).opacity(0.5)
                            
                            // 4. Notifications
                            SettingsRowItem(icon: "bell", title: "Notifications")
                            Divider().padding(.leading, 52).opacity(0.5)
                            
                            // 5. Premium
                            SettingsRowItem(icon: "checkmark.seal", title: "Premium", isLast: true)
                        }
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(RoundedRectangle(cornerRadius: 24)) // Combined Card Shape
                    
                    // --- GROUP 2 ---
                    // Design Middle Screen: Privacy separate
                    SettingsLinkRow(icon: "lock.shield", title: "Privacy & Safety", isStandalone: true)
                    
                    // --- GROUP 3 ---
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 0) {
                             SettingsRowItem(icon: "textformat", title: "Language & Accessibility", isFirst: true)
                             Divider().padding(.leading, 52).opacity(0.5)
                             SettingsRowItem(icon: "chart.bar", title: "Usage & Progress", isLast: true)
                        }
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // --- GROUP 4 ---
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 0) {
                             SettingsRowItem(icon: "message", title: "Support", isFirst: true)
                             Divider().padding(.leading, 52).opacity(0.5)
                             SettingsRowItem(icon: "person.circle", title: "Account", isLast: true)
                        }
                        .background(Color(hex: "F2F2F7"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // --- SIGN OUT BUTTON ---
                    Button(action: {
                        AuthManager.shared.signOut()
                    }) {
                        HStack {
                            Text("Sign out")
                                .font(.system(size: 17, weight: .medium))
                            Image(systemName: "rectangle.portrait.and.arrow.right") // Or similar
                                .font(.system(size: 14))
                        }
                        .foregroundColor(darkText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(limeGreen)
                        .cornerRadius(30)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    
                    
                    // Footer Text
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text("Privacy policy")
                            Text("Terms of use")
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                        
                        Text("@MrSwiftUI\nVersion: 13.4")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                }
                .padding(.horizontal, 20)
            }
        }
}
}

// MARK: - Helper Components

// A standalone row wrapped in a rounded rect (like "Privacy & Safety")
struct SettingsLinkRow: View {
    let icon: String
    let title: String
    var badge: String? = nil
    var isStandalone: Bool = false
    
    // Theme Colors
    let limeGreen = Color.ejLightGreen
    let darkText = Color.ejDarkerGreen
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.black)
                    .frame(width: 24)
                
                HStack(alignment: .top, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(darkText)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(limeGreen)
                            .cornerRadius(4)
                            .offset(y: -4)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 16) // Taller row
            .padding(.horizontal, 16)
            .background(Color(hex: "F2F2F7"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// An item inside a grouped list (VStack)
struct SettingsRowItem: View {
    let icon: String
    let title: String
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.black)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color(hex: "F2F2F7")) // Matches group bg
        }
    }
}

// Sub-row for expanded "Call experience"
struct SettingsSubRow: View {
    let label: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .padding(.leading, 52) // Indent to align with text above
            
            Spacer()
            
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 14)
        .padding(.trailing, 16)
    }
}

#Preview {
    SettingsView()
}
