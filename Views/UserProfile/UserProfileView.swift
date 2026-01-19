//
//  UserProfileView.swift
//  EnglishJi
//
//  Created by Agent on 19/01/26.
//

import SwiftUI

struct UserProfileView: View {
    let user: DetailedUserProfile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Immersive Header Background
            LinearGradient(
                colors: [.ejDarkerGreen, .ejLightGreen.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .frame(height: 300)
            
            // Custom Nav Bar (Transparent)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold)) // Slightly bolder
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                Spacer()
                
                // Menu / Report
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(90))
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 10) //SafeArea padding usually handled by ZStack, but adding a bit for margin
            .zIndex(2) // Ensure it's above everything
            
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Spacer for Header visual
                    Spacer()
                        .frame(height: 140)
                    
                    // 2. Main Profile Card
                    VStack(spacing: 0) {
                        
                        // Avatar Overlapping
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(url: user.profileImageURL, size: 130)
                                .padding(.top, -65) // Half of height to overlap
                                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            
                            if user.isOnline {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 20)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                    .offset(x: -6, y: -6)
                                    .padding(.top, -65) // Match avatar
                            }
                        }
                        
                        // Name & Bio
                        VStack(spacing: 8) {
                            Text(user.name)
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            if !user.badges.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(user.badges, id: \.self) { badge in
                                        Text(badge)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(Color.ejLightGreen.opacity(0.3))
                                            .foregroundColor(.ejDarkerGreen)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            Text(user.bio)
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                                .lineLimit(3)
                        }
                        .padding(.top, 16)
                        
                        // 3. Social Interaction Buttons (Prominent)
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Label("Message", systemImage: "bubble.left.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.ejDarkerGreen)
                                    .cornerRadius(20)
                                    .shadow(color: Color.ejDarkerGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.black)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 40)
                        
                        Divider()
                            .padding(.horizontal, 40)
                            .padding(.bottom, 24)
                        
                        // 4. Quick Stats (Gamified)
                        HStack(spacing: 40) {
                            GamifiedStat(value: "\(user.stats.friends)", label: "Friends", icon: "person.2.fill")
                            GamifiedStat(value: "\(user.stats.gamesPlayed)", label: "Games", icon: "gamecontroller.fill")
                            GamifiedStat(value: "\(user.stats.streakDays)", label: "Streak", icon: "flame.fill", isHighlight: true)
                        }
                        .padding(.bottom, 32)
                        
                        // 5. Shared Interests
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Interests")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 24)
                            
                            FlowLayout(spacing: 12) {
                                ForEach(user.interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 18)
                                        .background(Color.gray.opacity(0.1)) // Safe color
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 50)
                        
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                }
            }
        }
        .background(Color(white: 0.95).ignoresSafeArea()) // Safe background color
    }
}

// MARK: - Components

struct AvatarView: View {
    let url: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(Color.white, lineWidth: 6)
        )
    }
}

struct GamifiedStat: View {
    let value: String
    let label: String
    let icon: String
    var isHighlight: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isHighlight ? Color.ejLightGreen.opacity(0.2) : Color.gray.opacity(0.05))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isHighlight ? .ejDarkerGreen : .gray)
            }
            
            VStack(spacing: 0) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}


// Simple FlowLayout implementation for tags
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        if rows.isEmpty { return .zero }
        return CGSize(width: proposal.width ?? 0, height: rows.last!.maxY)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        for row in rows {
            for element in row.elements {
                element.subview.place(at: CGPoint(x: bounds.minX + element.x, y: bounds.minY + element.y), proposal: .unspecified)
            }
        }
    }
    
    struct Row {
        var elements: [Element] = []
        var maxY: CGFloat = 0
    }
    
    struct Element {
        var subview: LayoutSubview
        var x: CGFloat
        var y: CGFloat
    }
    
    func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth {
                // New row
                currentY = (rows.last?.maxY ?? 0) + spacing
                rows.append(currentRow)
                currentRow = Row()
                currentX = 0
            }
            
            currentRow.elements.append(Element(subview: subview, x: currentX, y: currentY))
            currentRow.maxY = max(currentRow.maxY, currentY + size.height)
            currentX += size.width + spacing
        }
        
        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

#Preview {
    UserProfileView(user: .mock)
}
