//
//  OnboardingContainerView.swift
//  EnglishJi
//
//  Created by Mr SwiftUI on 06/12/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .splash:
                OnboardingSplashView(viewModel: viewModel)
            case .intro:
                OnboardingIntroView(viewModel: viewModel)
            case .phone:
                OnboardingPhoneView(viewModel: viewModel)
            case .otp:
                OnboardingOTPView(viewModel: viewModel)
            case .name:
                OnboardingNameView(viewModel: viewModel)
            case .age:
                OnboardingAgeView(viewModel: viewModel)
            case .photo:
                OnboardingPhotoView(viewModel: viewModel)
            case .location:
                OnboardingLocationView(viewModel: viewModel)
            case .completion:
                OnboardingCompletionView(viewModel: viewModel)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.spring(), value: viewModel.currentStep)
    }
}

#Preview {
    OnboardingContainerView()
}
