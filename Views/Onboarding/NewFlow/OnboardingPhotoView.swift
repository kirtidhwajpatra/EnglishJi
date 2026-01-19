import SwiftUI
import PhotosUI

struct OnboardingPhotoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        OnboardingLayout(
            stepIndex: 5,
            direction: viewModel.navigationDirection,
            showProfileProgress: true,
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                Spacer()
                
                Text("Upload Picture")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.ejDarkerGreen)
                
                Text("You can always change it later")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    ZStack {
                        if let image = viewModel.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .stroke(Color.ejDarkerGreen.opacity(0.3), lineWidth: 1) // Thin stroke
                                .frame(width: 180, height: 180)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 40))
                                .foregroundColor(.ejDarkerGreen)
                        }
                    }
                }
                .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem)
                
                Spacer()
                
                OnboardingButton(
                    title: "Next",
                    action: { viewModel.moveToNextStep() }
                )
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        viewModel.profileImage = uiImage
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingPhotoView(viewModel: OnboardingViewModel())
}
