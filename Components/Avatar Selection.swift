//
//  Avatar Selection.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 08/12/25.
//


import SwiftUI
import PhotosUI
import Combine

// MARK: - Gender Enum
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
}

// MARK: - Avatar Generator (Stable API)
struct AvatarGenerator {
    static func generateAvatarURL(
        style: String = "personas",
        gender: Gender,
        age: Int,
        index: Int
    ) -> URL? {
        let seed = "\(gender.rawValue)-age\(age)-\(index)"
        return URL(string: "https://api.dicebear.com/7.x/\(style)/png?seed=\(seed)&size=512&backgroundColor=transparent")
    }
}

// MARK: - Remote Image Loader (SAFE)
@MainActor
class RemoteImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    private var task: URLSessionDataTask?

    func load(from url: URL) {
        task?.cancel()

        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = img
            }
        }
        task?.resume()
    }

    func cancel() {
        task?.cancel()
    }
}

// MARK: - Remote Image View
struct RemoteImageView: View {
    let url: URL?
    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            if let url = url { loader.load(from: url) }
        }
        .onChange(of: url) { new in
            if let newURL = new { loader.load(from: newURL) }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// MARK: - Color HEX Extension (SAFE)
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - MAIN PROFILE PICTURE SCREEN (FINAL)
struct EnhancedProfilePictureScreen: View {

    // Inputs
    var userAge: Int = 20

    // Styles
    private let style = "personas"    // Best gender-aware avatar style

    // Avatar count
    private let avatarCount = 12

    // Strong vibrant colors
    private let bgColorOptions = [
        "FF6B6B", "FFA41B", "FFD93D", "6BCB77",
        "4D96FF", "843BFF", "FF66C4", "00E5FF"
    ]

    // States
    @State private var selectedGender: Gender = .male
    @State private var selectedIndex: Int = 1
    @State private var selectedColor: String = "FFD93D"
    @State private var customColor: Color = .white
    @State private var usingCustomColor = false

    @State private var customImage: UIImage? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Avatar Preview
            ZStack {
                Circle()
                    .fill(usingCustomColor ? customColor : Color(hexString: selectedColor))
                    .frame(width: 240, height: 210)
                    .shadow(color: .black.opacity(0.1), radius: 20)

                if let img = customImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210)
                        .clipShape(Circle())
                } else {
                    RemoteImageView(
                        url: AvatarGenerator.generateAvatarURL(
                            style: style,
                            gender: selectedGender,
                            age: userAge,
                            index: selectedIndex
                        )
                    )
                    .frame(width: 210)
                    .clipShape(Circle())
                }
            }

            // MARK: - Gender Toggle
            HStack(spacing: 0) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedGender = gender
                            customImage = nil
                            haptic.impactOccurred()
                        }
                    }) {
                        Text(gender.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedGender == gender ? .white : .black.opacity(0.5))
                            .frame(width: 100, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedGender == gender ? Color(hexString: "0F0039") : .clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(24)

            // MARK: - Avatar Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {

                    // UPLOAD BUTTON
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        VStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .shadow(radius: 4)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.black.opacity(0.7))
                                )

                        }
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                withAnimation { customImage = img }
                            }
                        }
                    }

                    // AVATAR OPTIONS
                    ForEach(1...avatarCount, id: \.self) { i in
                        Button {
                            withAnimation(.spring()) {
                                selectedIndex = i
                                customImage = nil
                                haptic.impactOccurred()
                            }
                        } label: {
                            RemoteImageView(
                                url: AvatarGenerator.generateAvatarURL(
                                    style: style,
                                    gender: selectedGender,
                                    age: userAge,
                                    index: i
                                )
                            )
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hexString: "0F0039"),
                                            lineWidth: selectedIndex == i && customImage == nil ? 3 : 0)
                            )
                        }
                    }
                }
                .padding(.horizontal, 30)
            }

            // MARK: - Suggested Colors
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {

                        ColorPicker("Pick Background", selection: $customColor)
                            .labelsHidden()
                            .onChange(of: customColor) { _ in
                                usingCustomColor = true
                            }

                        if usingCustomColor {
                            Button("Reset to Suggested Colors") {
                                usingCustomColor = false
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(bgColorOptions, id: \.self) { hex in
                        Circle()
                            .fill(Color(hexString: hex))
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.3),
                                            lineWidth: selectedColor == hex ? 2 : 0)
                            )
                            .onTapGesture {
                                usingCustomColor = false
                                selectedColor = hex
                                haptic.impactOccurred()
                            }
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - Manual Color Picker
            
        }
    }
}

// MARK: - Preview
struct EnhancedProfilePictureScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedProfilePictureScreen(userAge: 18)
            .previewDevice("iPhone 15 Pro")
    }
}
