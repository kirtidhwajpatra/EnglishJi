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
            onBack: { viewModel.moveToPreviousStep() }
        ) {
            VStack {
                OnboardingTitle("Add a photo", subtitle: "Help others recognize you. You can change this later.")
                
                Spacer()
                
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
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                        } else {
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 180, height: 180)
                                .overlay(
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                        .foregroundColor(Color.blue)
                                )
                            
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Upload")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.profileImage = uiImage
                        }
                    }
                }
                
                Spacer()
                
                // Allow skipping layout if needed, but for now enforcing "Continue"
                OnboardingButton(
                    title: viewModel.profileImage == nil ? "Skip for now" : "Continue",
                    isDisabled: false, // Always enabled (skip or continue)
                    action: { viewModel.moveToNextStep() }
                )
            }
        }
    }
}

#Preview {
    OnboardingPhotoView(viewModel: OnboardingViewModel())
}
