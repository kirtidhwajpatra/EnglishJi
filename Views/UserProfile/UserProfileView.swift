//
//  UserProfileView.swift
//  EnglishJi
//
//  Created by Agent on 19/01/26.
//

import SwiftUI

struct UserProfileView: View {
    let user: DetailedUserProfile
    var namespace: Namespace.ID? = nil // Optional for preview compatibility
    var matchID: String? = nil
    @Binding var isPresented: Bool // Replaces dismiss environment for custom transition handling
    
    // Design Reference Colors
    // Adaptive Background: Light Blue in Light Mode, Dark Slate/Black in Dark Mode
    // Design Reference Colors
    // Adaptive Background: Light Blue in Light Mode, Dark Slate/Black in Dark Mode
    private var cardBackground: Color {
        // Use standard systemBackground for Dark Mode compliance, or explicit dark color.
        Color(uiColor: .systemBackground)
    }
    
    // Light Blue shim for Light Mode? The user wanted specific "Light Blue".
    // I will use a ZStack with .systemBackground and a blue tint if colorScheme is light.
    @Environment(\.colorScheme) var colorScheme
    
    private var actualCardBackground: Color {
        colorScheme == .dark ? Color(hex: "121212") : Color(hex: "E3F2FD")
    }
    
    private let blobColor = Color(hex: "3C3C3C")      // Dark Blob (Okay in both?)
    private var primaryText: Color { .primary }
    private var secondaryText: Color { .secondary }
    private let accentGreen = Color(hex: "034836") // Keep brand
    
    var body: some View {
        ZStack {
            // Main Background
            actualCardBackground
                .ignoresSafeArea()
                .matchedGeometryEffect(id: "card_bg_\(matchID ?? "")", in: namespace ?? Namespace().wrappedValue, isSource: true)
            
            VStack(spacing: 0) {
                // 1. Navigation / Close
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary) // Adaptive
                            .padding(12)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .transition(.opacity.animation(.easeInOut(duration: 0.2).delay(0.1)))
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // ... (Scalloped Image - No Changes Needed if blob is dark) ...
                        // 2. Scalloped Profile Image
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                ScallopedProfileShape(customAmplitude: 6)
                                    .fill(blobColor)
                                    .frame(width: 220, height: 220)
                                    .matchedGeometryEffect(id: "avatar_blob_\(matchID ?? "")", in: namespace ?? Namespace().wrappedValue, isSource: true)
                                
                                AsyncImage(url: URL(string: user.profileImageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 200, height: 200)
                                        .clipShape(ScallopedProfileShape(customAmplitude: 5))
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                        .frame(width: 200, height: 200)
                                }
                                .matchedGeometryEffect(id: "avatar_img_\(matchID ?? "")", in: namespace ?? Namespace().wrappedValue, isSource: true)
                            }
                            
                            // Flag Badge
                            Text("🇺🇸")
                                .font(.system(size: 32))
                                .padding(8)
                                .background(Circle().fill(Color(uiColor: .systemBackground))) // Adaptive
                                .offset(x: 10, y: 20)
                        }
                        .padding(.top, 20)
                        
                        // 3. Name & Age
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(user.name), 24")
                                .font(.system(size: 28, weight: .regular, design: .default))
                                .foregroundColor(primaryText)
                                .matchedGeometryEffect(id: "user_name_\(matchID ?? "")", in: namespace ?? Namespace().wrappedValue, isSource: true)
                            
                            if user.isOnline {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                    .overlay(Circle().stroke(Color(uiColor: .systemBackground), lineWidth: 1))
                            }
                        }
                        .padding(.top, 24)
                        
                        // Bio Tagline
                        Text("Exploring the platform & trying to\nbuild the fluency...")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 8)
                            .padding(.horizontal, 40)
                        
                        // 4. Interest Pills (Adaptive Text)
                        HStack(spacing: 8) {
                            ForEach(user.interests.prefix(3), id: \.self) { interest in
                                Text(interest)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.primary) // Adaptive
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .stroke(Color.primary, lineWidth: 1) // Adaptive border
                                    )
                                    //.background(Capsule().fill(Color.white.opacity(0.5)))
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                        
                        // Second row
                         HStack(spacing: 8) {
                             Text("Riding")
                                 .font(.system(size: 13))
                                 .foregroundColor(.primary)
                                 .padding(.vertical, 6)
                                 .padding(.horizontal, 16)
                                 .background(Capsule().stroke(Color.primary, lineWidth: 1))
                             
                             Text("Beach 🏖️")
                                 .font(.system(size: 13))
                                 .foregroundColor(.primary)
                                 .padding(.vertical, 6)
                                 .padding(.horizontal, 16)
                                 .background(Capsule().stroke(Color.primary, lineWidth: 1))
                         }
                         .padding(.bottom, 32)
                        
                        // Divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, 32)
                        
                        // 5. Stats Row
                        HStack(spacing: 0) {
                            Spacer()
                            StatColumn(value: "\(user.stats.friends)", label: "Friends", color: .primary)
                            Spacer()
                            StatColumn(value: "340", label: "Min", color: Color(hex: "A376F8"))
                            Spacer()
                            StatColumn(value: "670", label: "Win", color: Color(hex: "4CAF50"))
                            Spacer()
                        }
                        .padding(.vertical, 24)
                        
                        // 6. Location Card
                        ZStack(alignment: .bottomTrailing) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground)) // Adaptive
                                .frame(height: 120)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            Text(user.location)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.primary)
                                .padding(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        
                        // 7. Action Buttons
                        HStack(spacing: 16) {
                            // Following Button
                            Button(action: {}) {
                                Text("Following")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(colorScheme == .dark ? .white : accentGreen)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .overlay(
                                        Capsule()
                                            .stroke(colorScheme == .dark ? .white : accentGreen, lineWidth: 1.5)
                                    )
                            }
                            
                            // Message Button
                            Button(action: {}) {
                                Circle()
                                    .fill(accentGreen)
                                    .frame(width: 54, height: 54)
                                    .overlay(
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "D5F147"))
                                    )
                            }
                        }
                        .padding(.bottom, 40)
                        
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Subviews

struct StatColumn: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}


//
//#Preview {
//    UserProfileView(user: .mock)
//}
