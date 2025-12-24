//
//  ProfileDetailCard.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 24/12/25.
//

import SwiftUI


struct UserProfileCard: View {
    let user: LearnerNode
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 15) {
                // Avatar
                AsyncImage(url: URL(string: user.image)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Color.gray }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack {
                        Circle()
                            .fill(user.status == .activeNow ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(user.status == .activeNow ? "Online" : "Recently Active")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Close X
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            HStack(spacing: 15) {
                Button(action: {}) {
                    Text("Follow")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                
                Button(action: {}) {
                    Text("Message")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.22, green: 0.08, blue: 0.55)) // Deep Purple
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(25)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.15), radius: 30, y: -5)
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}
