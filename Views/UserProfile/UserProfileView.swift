//
//  UserProfileView.swift
//  EnglishJi
//
//  Created by Agent on 19/01/26.
//

import SwiftUI

struct UserProfileView: View {
    let user: UserProfile
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // 1. Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    
                    // Options/Report button could go here
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .rotationEffect(.degrees(90))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 2. Profile Header (Avatar + Online Status)
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        // Avatar
                        AsyncImage(url: URL(string: user.profileImageURL)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        )
                        
                        // Online Status Indicator
                        if user.isOnline {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 18, height: 18)
                            }
                            .offset(x: -4, y: -4)
                        }
                    }
                    
                    // Name & Bio
                    VStack(spacing: 8) {
                        Text(user.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(user.bio)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(4)
                    }
                }
                
                // 3. Action Buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .font(.headline)
                        .foregroundColor(Color.ejDarkerGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.ejLightGreen)
                        .cornerRadius(27)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Add Friend")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(27)
                    }
                }
                .padding(.horizontal, 20)
                
                // 4. Stats Row
                HStack(spacing: 12) {
                    ProfileStatCard(value: "\(user.stats.friends)", label: "Friends")
                    ProfileStatCard(value: "\(user.stats.gamesPlayed)", label: "Games", valueColor: .purple)
                    ProfileStatCard(value: "\(user.stats.streakDays)", label: "Day Streak", valueColor: .orange)
                }
                .padding(.horizontal, 20)
                
                // 5. Interests
                VStack(alignment: .leading, spacing: 16) {
                    Text("Interests")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                    
                    FlowLayout(spacing: 10) {
                        ForEach(user.interests, id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 6. Details Section (Location, Join Date)
                VStack(spacing: 0) {
                    ProfileDetailRow(icon: "mappin.and.ellipse", text: user.location)
                    Divider().padding(.leading, 50)
                    ProfileDetailRow(icon: "calendar", text: "Joined \(formattedDate(user.joinDate))")
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Subviews

struct ProfileStatCard: View {
    let value: String
    let label: String
    var valueColor: Color = .black
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(16)
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
