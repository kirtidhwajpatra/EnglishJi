import SwiftUI

struct ProfileView: View {
    // MARK: - Dependencies
    @Environment(\.dismiss) var dismiss
    

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 1. Custom Navigation Bar
                ProfileNavBar(onBack: { dismiss() })
                
                // 2. Upgrade Banner
                UpgradeBanner()
                
                // 3. Avatar & Name
                ProfileHeader()
                
                // 4. Stats Row (Friends, Mins, Visitors)
                StatsRow()
                
                // 5. Interests Section
                InterestsSection()
                
                // 6. Location Placeholder
                LocationSection()
                
                // 7. Contact Info
                ContactInfoSection()
                
                // 8. Demographics
                DemographicsSection()
                
                // 9. Edit Button
                Button {
                    // Action
                } label: {
                    HStack {
                        Image(systemName: "sparkles") // Fixed symbol
                        Text("Edit Profile")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "1C1C1E")) // Dark Black/Gray
                    .cornerRadius(28)
        
                }
                .padding(.top, 10)
                .padding(.bottom, 40)
                .padding(.horizontal, 10)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - 1. Navigation Bar
struct ProfileNavBar: View {
    var onBack: () -> Void
    @State private var showSettings = false
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: onBack) {
                Image("returnkey")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    showSettings = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    
                    .sheet(isPresented: $showSettings) {
                                SettingsView() // The view you want to show
                            }
                }
                .padding(.trailing, 10)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 14)
    }
       
}

// MARK: - 2. Upgrade Banner
struct UpgradeBanner: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -2) {
                Text("Unlock all")
                    .foregroundColor(Color.black)
                Text("exclusive features.")
                    .foregroundColor(Color.black)
            }
            .font(.system(size: 18, weight: .regular, design: .rounded))
            
            Spacer()
            
            Button("Upgrade") { }
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .kerning(CGFloat(-0.4))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "DDEE88")) // Lime Green
                .foregroundColor(Color(hex: "1F3B34")) // Dark Text
                .cornerRadius(20)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(hex: "F1f1f1")) // Light Pink
        .cornerRadius(16)
    }
}

// MARK: - 3. Header
struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Gradient Border
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 88, height: 88)
                
                // Image
                AsyncImage(url: URL(string: "https://i.pravatar.cc/300?img=5")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            }
            
            VStack(spacing: 6) {
                Text("Veena Singh")
                    .font(.system(size: 28, weight: .regular, design: .rounded))
                    .kerning(CGFloat(-0.4))
                    .foregroundColor(.black)
                
                Text("Just making a balanced diet\nfor a better lifestyle🍊")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - 4. Stats Row
struct StatsRow: View {
    var body: some View {
        HStack(spacing: 6) {
            StatCard(value: "72", label: "Friends")
            StatCard(value: "340", label: "Min", valueColor: .purple)
            StatCard(value: "45", label: "Visitors", isNew: true)
        }
        .padding(.horizontal, 6)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    var valueColor: Color = .black
    var isNew: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 34, weight: .regular, design: .rounded))
                .kerning(CGFloat(-0.4))
                .foregroundColor(valueColor)
            
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color(hex: "f1f1f1")) // Very Light Gray
        .cornerRadius(16)
        .overlay(alignment: .topTrailing) {
            if isNew {
                Text("New")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.red)
                    .padding(14)
            }
        }
    }
}

// MARK: - 5. Interests
struct InterestsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Interest")
            
      
            VStack {
                HStack{
                    TagView(text: "Reader", icon: "book.fill", color: Color(hex: "E5FAF1"), textColor: Color(hex: "00CB74"))
                    TagView(text: "Foodie", icon: "cup.and.saucer.fill", color: Color(hex: "FFF5E5"), textColor: .orange)
                }
                
                // Row 2
                HStack {
                    TagView(text: "Sports", icon: "figure.run", color: Color(hex: "F0EAF9"), textColor: .purple)
                    TagView(text: "Explorer", icon: "map.fill", color: Color(hex: "F2F2F7"), textColor: .black)
                    TagView(text: "Sports", icon: "figure.run", color: Color(hex: "FFF0F3"), textColor: .pink)
                }
            }
            .padding()
            
            
            
        }
    }
}

struct TagView: View {
    let text: String
    let icon: String
    let color: Color
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .default))
                .kerning(CGFloat(-0.2))
        }
        .foregroundColor(textColor)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(color)
        .cornerRadius(8)
    }
}

// MARK: - 6. Location
struct LocationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Location")
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "F2F2F7"))
                .frame(height: 240) // Placeholder for Map
                .overlay(
                    Image(systemName: "map")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.3))
                )
            
                .padding(.vertical)
            
        }
        
    }
}

// MARK: - 7. Contact Info
struct ContactInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Details")
            
            VStack(spacing: 0) {
                // Phone
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "phone")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text("Phone")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    Text("760-9963-811")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                }
                .padding(.bottom, 16)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                
                // Email
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text("Email")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    Text("veenasingh@gmail.com")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
            
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

// MARK: - 8. Demographics
struct DemographicsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Details")
            
            HStack(alignment: .top) {
                DemographicItem(label: "Country", value: "India")
                Spacer()
                DemographicItem(label: "Gender", value: "Male")
                Spacer()
                DemographicItem(label: "Date of Birth", value: "02/09/1995")
            }
            .padding(.horizontal, 10)
            .padding()
        }
    }
}

struct DemographicItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .center, spacing: 6) {
                Text(label)
                    .font(.callout)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 22, weight: .regular, design: .rounded))
            }
           
        }
    }
}

// MARK: - Helpers
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .regular, design: .default)) // Reduced size slightly
                .foregroundColor(Color.black.opacity(0.8))
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 4)
    }
}

#Preview{
    ProfileView()
}

//// Color Extension for Hex
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (1, 1, 1, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
