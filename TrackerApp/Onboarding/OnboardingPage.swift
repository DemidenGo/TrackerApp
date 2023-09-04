//
//  OnboardingPage.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 03.05.2023.
//

import Foundation

enum OnboardingPage: CaseIterable {
    
    case first
    case second

    var index: Int {
        switch self {
        case .first:
            return 0
        case .second:
            return 1
        }
    }

    var next: OnboardingPage {
        switch self {
        case .first:
            return .second
        case .second:
            return .first
        }
    }

    var previous: OnboardingPage {
        switch self {
        case .first:
            return .second
        case .second:
            return .first
        }
    }

    var onboardingMessage: String {
        switch self {
        case .first:
            return L10n.Onboarding.firstMessage
        case .second:
            return L10n.Onboarding.secondMessage
        }
    }

    var backgroundImage: String {
        switch self {
        case .first:
            return Images.Onboarding.firstPage
        case .second:
            return Images.Onboarding.secondPage
        }
    }

    var loginButtonTitle: String { L10n.Onboarding.loginButtonTitle }
}
