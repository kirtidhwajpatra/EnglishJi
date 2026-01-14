import SwiftUI
import PhotosUI

struct OnboardingPhotoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress dots
            HStack(spacing: 4) {
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.ejDarkerGreen).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
            }
            .padding(.top, 20)
            
            HStack(spacing: 20) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Age")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Photo")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.ejDarkerGreen)
                Text("Location")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Upload Picture")
                .font(.headline)
                .foregroundColor(.ejDarkerGreen)
            
            Text("Because always change make..") // As per design text? Keeping exact text or fixing grammar? Keeping simpler placeholder for now
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: {
                showingImagePicker = true
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 190, height: 190)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 40))
                            .foregroundColor(.ejDarkerGreen)
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.profileImage = uiImage
                    }
                }
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem)
            
            Spacer()
            
            Button(action: {
                viewModel.moveToNextStep()
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.ejDarkerGreen)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Color.ejLightGreen)
                    .cornerRadius(30)
            }
            .padding(.bottom, 50)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    OnboardingPhotoView(viewModel: OnboardingViewModel())
}
