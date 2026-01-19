import SwiftUI

struct ProfileView: View {
    // MARK: - Dependencies
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: ProfileField?
    
    // MARK: - Configuration
    private let isReadOnly: Bool
    
    // MARK: - Profile State
    @State private var isEditing = false
    
    // User Data
    @State private var name: String = "Veena Singh"
    @State private var bio: String = "Just making a balanced diet\nfor a better lifestyle🍊"
    @State private var profileImageURL: String = "https://i.pravatar.cc/300?img=5"
    @State private var friends: String = "72"
    @State private var minutes: String = "340"
    @State private var visitors: String = "45"
    @State private var location: String = "New Delhi, India"
    @State private var phoneNumber: String = "760-9963-811"
    @State private var email: String = "veenasingh@gmail.com"
    @State private var country: String = "India"
    @State private var gender: String = "Male"
    @State private var dob: String = "02/09/1995"
    
    // Interests logic
    @State private var interests: [InterestTag] = [
        InterestTag(text: "Reader", icon: "book.fill", colorHex: "E5FAF1", textColorHex: "00CB74"),
        InterestTag(text: "Foodie", icon: "cup.and.saucer.fill", colorHex: "FFF5E5", textColorHex: "FFA500"),
        InterestTag(text: "Sports", icon: "figure.run", colorHex: "F0EAF9", textColorHex: "800080"),
        InterestTag(text: "Explorer", icon: "map.fill", colorHex: "F2F2F7", textColorHex: "000000"),
        InterestTag(text: "Music", icon: "music.note", colorHex: "FFF0F3", textColorHex: "FFC0CB")
    ]
    @State private var newInterestText: String = ""

    enum ProfileField: Hashable {
        case name, bio, phone, email, country, gender, dob, location, newInterest
    }
    
    init(user: DiscoverUser? = nil) {
        if let user = user {
            self.isReadOnly = true
            _name = State(initialValue: user.name)
            _bio = State(initialValue: user.bio)
            _gender = State(initialValue: user.gender == .male ? "Male" : "Female")
            _profileImageURL = State(initialValue: user.image)
            _country = State(initialValue: "Online")
            _friends = State(initialValue: "\(Int.random(in: 10...300))")
            _minutes = State(initialValue: "\(Int.random(in: 50...1000))")
            _visitors = State(initialValue: "\(Int.random(in: 5...100))")
            
        } else {
            self.isReadOnly = false
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // 1. Custom Navigation Bar
                ProfileNavBar(onBack: { dismiss() })
                
                // 2. Upgrade Banner
                if !isEditing && !isReadOnly {
                    UpgradeBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // 3. Avatar & Name
                ProfileHeader(
                    name: $name,
                    bio: $bio,
                    imageURL: profileImageURL,
                    isEditing: isEditing,
                    focusedField: _focusedField
                )
                
                // 4. Stats Row
                StatsRow(friends: friends, minutes: minutes, visitors: visitors)
                    .opacity(isEditing ? 0.4 : 1.0)
                    .grayscale(isEditing ? 1.0 : 0.0)
                
                // 5. Interests Section
                InterestsSection(
                    interests: $interests,
                    newInterestText: $newInterestText,
                    isEditing: isEditing,
                    focusedField: _focusedField
                )
                
                // 6. Location
                LocationSection(location: $location, isEditing: isEditing, focusedField: _focusedField)
                
                // 7. Contact Info
                if !isReadOnly {
                    ContactInfoSection(
                        phone: $phoneNumber,
                        email: $email,
                        isEditing: isEditing,
                        focusedField: _focusedField
                    )
                }
                
                // 8. Demographics
                DemographicsSection(
                    country: $country,
                    gender: $gender,
                    dob: $dob,
                    isEditing: isEditing,
                    focusedField: _focusedField
                )
                
                // 9. Edit/Save Button
                if !isReadOnly {
                    Button {
                        HapticManager.shared.lightImpact()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEditing.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: isEditing ? "checkmark" : "sparkles")
                                .id(isEditing)
                                .transition(.scale.combined(with: .opacity).animation(.bouncy))
                            Text(isEditing ? "Save Changes" : "Edit Profile")
                                .transition(.push(from: .bottom))
                        }
                        .font(.headline)
                        .foregroundColor(isEditing ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isEditing ? Color.ejLightGreen : Color(hex: "1C1C1E"))
                        .cornerRadius(28)
                        .shadow(color: isEditing ? Color.ejLightGreen.opacity(0.3) : .clear, radius: 10, y: 5)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 10)
                }
            }
            .padding(.horizontal, 20)
            .animation(.default, value: isEditing)
        }
        .background(Color.white.ignoresSafeArea())
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Models
struct InterestTag: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var icon: String
    var colorHex: String
    var textColorHex: String
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
                        SettingsView() 
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
                .background(Color.ejLightGreen)
                .foregroundColor(Color.ejDarkerGreen)
                .cornerRadius(20)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(hex: "F1f1f1")) 
        .cornerRadius(16)
    }
}

// MARK: - 3. Header
struct ProfileHeader: View {
    @Binding var name: String
    @Binding var bio: String
    var imageURL: String
    var isEditing: Bool
    @FocusState var focusedField: ProfileView.ProfileField?
    
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
                
                // Image or Placeholder
                AsyncImage(url: URL(string: imageURL)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                // Edit Overlay
                if isEditing {
                    ZStack {
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .onTapGesture {
                if isEditing {
                    HapticManager.shared.lightImpact()
                }
            }
            
            VStack(spacing: 6) {
                EditableField(
                    text: $name,
                    isEditing: isEditing,
                    placeholder: "Your Name",
                    font: .system(size: 28, weight: .regular, design: .rounded),
                    alignment: .center,
                    fieldId: .name,
                    focusedField: _focusedField
                )
                
                EditableField(
                    text: $bio,
                    isEditing: isEditing,
                    placeholder: "Short bio...",
                    font: .system(size: 14),
                    alignment: .center,
                    fieldId: .bio,
                    focusedField: _focusedField,
                    axis: .vertical
                )
            }
        }
    }
}

// MARK: - 4. Stats Row
struct StatsRow: View {
    var friends: String
    var minutes: String
    var visitors: String
    
    var body: some View {
        HStack(spacing: 6) {
            StatCard(value: friends, label: "Friends")
            StatCard(value: minutes, label: "Min", valueColor: .purple)
            StatCard(value: visitors, label: "Visitors", isNew: true)
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
    @Binding var interests: [InterestTag]
    @Binding var newInterestText: String
    var isEditing: Bool
    @FocusState var focusedField: ProfileView.ProfileField?
    
    // Jiggle Animation State
    @State private var isJiggling = false

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Interest")
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(interests) { interest in
                    ZStack(alignment: .topTrailing) {
                        TagView(text: interest.text, icon: interest.icon, color: Color(hex: interest.colorHex), textColor: Color(hex: interest.textColorHex))
                            .rotationEffect(.degrees(isEditing ? -1 : 0))
                            .animation(
                                isEditing ? Animation.linear(duration: 0.15).repeatForever(autoreverses: true) : .default,
                                value: isEditing
                            )
                        
                        if isEditing {
                            Button {
                                HapticManager.shared.lightImpact()
                                if let index = interests.firstIndex(where: { $0.id == interest.id }) {
                                    withAnimation {
                                        interests.remove(at: index)
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.white, .red)
                                    .font(.system(size: 20))
                                    .background(Circle().fill(.white))
                            }
                            .offset(x: 8, y: -8)
                            .transition(.scale)
                        }
                    }
                }
                
                if isEditing {
                    HStack {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Add Interest", text: $newInterestText)
                            .font(.system(size: 16))
                            .focused($focusedField, equals: .newInterest)
                            .submitLabel(.done)
                            .onSubmit {
                                if !newInterestText.isEmpty {
                                    withAnimation {
                                        interests.append(InterestTag(text: newInterestText, icon: "star.fill", colorHex: "F2F2F7", textColorHex: "000000"))
                                        newInterestText = ""
                                    }
                                }
                            }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundColor(.gray.opacity(0.5))
                    )
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
                .font(.system(size: 16, weight: .medium, design: .default))
                .kerning(CGFloat(-0.2))
                .lineLimit(1)
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
    @Binding var location: String
    var isEditing: Bool
    @FocusState var focusedField: ProfileView.ProfileField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Location")
            
            if isEditing {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    TextField("Location", text: $location)
                        .focused($focusedField, equals: .location)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color(hex: "F2F2F7"))
                .cornerRadius(12)
                .padding(.vertical)
                .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "F2F2F7"))
                    .frame(height: 240)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.3))
                            Text(location)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    )
                    .padding(.vertical)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - 7. Contact Info
struct ContactInfoSection: View {
    @Binding var phone: String
    @Binding var email: String
    var isEditing: Bool
    @FocusState var focusedField: ProfileView.ProfileField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Details")
            
            VStack(spacing: 0) {
                // Phone
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "phone")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text("Phone")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    EditableField(
                        text: $phone,
                        isEditing: isEditing,
                        placeholder: "Phone",
                        font: .system(size: 22, weight: .regular, design: .rounded),
                        alignment: .center,
                        fieldId: .phone,
                        focusedField: _focusedField,
                        keyboardType: .phonePad
                    )
                }
                .padding(.bottom, 16)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                
                // Email
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "envelope")
                            .font(.callout)
                            .foregroundColor(.gray)
                        Text("Email")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    EditableField(
                        text: $email,
                        isEditing: isEditing,
                        placeholder: "Email",
                        font: .system(size: 22, weight: .regular, design: .rounded),
                        alignment: .center,
                        fieldId: .email,
                        focusedField: _focusedField,
                        keyboardType: .emailAddress
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

// MARK: - 8. Demographics
struct DemographicsSection: View {
    @Binding var country: String
    @Binding var gender: String
    @Binding var dob: String
    var isEditing: Bool
    @FocusState var focusedField: ProfileView.ProfileField?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Demographics")
            
            HStack(alignment: .top) {
                EditableDemographicItem(label: "Country", value: $country, isEditing: isEditing, fieldId: .country, focusedField: $focusedField)
                Spacer()
                EditableDemographicItem(label: "Gender", value: $gender, isEditing: isEditing, fieldId: .gender, focusedField: $focusedField)
                Spacer()
                EditableDemographicItem(label: "Date of Birth", value: $dob, isEditing: isEditing, fieldId: .dob, focusedField: $focusedField)
            }
            .padding(.horizontal, 10)
            .padding()
        }
        .padding(.bottom, 40)
    }
}

struct EditableDemographicItem: View {
    let label: String
    @Binding var value: String
    var isEditing: Bool
    var fieldId: ProfileView.ProfileField
    @FocusState.Binding var focusedField: ProfileView.ProfileField?
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(label)
                .font(.callout)
                .foregroundColor(.gray)
            
            EditableField(
                text: $value,
                isEditing: isEditing,
                placeholder: label,
                font: .system(size: 20, weight: .regular, design: .rounded),
                alignment: .center,
                fieldId: fieldId,
                focusedField: _focusedField
            )
            .frame(maxWidth: 100)
        }
    }
}

// MARK: - Generic Editable Field Component
struct EditableField: View {
    @Binding var text: String
    var isEditing: Bool
    var placeholder: String
    var font: Font
    var alignment: TextAlignment = .leading
    var fieldId: ProfileView.ProfileField
    @FocusState.Binding var focusedField: ProfileView.ProfileField?
    var axis: Axis = .horizontal
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        ZStack {
            // Read-Only View (Bottom layer)
            Text(text.isEmpty ? placeholder : text)
                .font(font)
                .foregroundColor(text.isEmpty ? .gray : .black)
                .multilineTextAlignment(alignment)
                .lineSpacing(2)
                .opacity(isEditing ? 0 : 1) // Fade out when editing
            
            // Editable View (Top layer)
            if isEditing {
                TextField(placeholder, text: $text, axis: axis)
                    .font(font)
                    .multilineTextAlignment(alignment)
                    .focused($focusedField, equals: fieldId)
                    .keyboardType(keyboardType)
                    .submitLabel(.done)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.08)) 
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(focusedField == fieldId ? Color.ejLightGreen : Color.clear, lineWidth: 1.5)
                    )
                    .opacity(isEditing ? 1 : 0) // Fade in
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}

// MARK: - Helpers
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .regular, design: .default)) 
                .foregroundColor(Color.black.opacity(0.8))
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 4)
    }
}

// Blur View Helper for iOS
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview{
    ProfileView()
}
