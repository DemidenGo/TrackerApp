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
            return "Отслеживайте только то, что хотите"
        case .second:
            return "Даже если это не литры воды и йога"
        }
    }

    var backgroundImage: String {
        switch self {
        case .first:
            return "Onboarding-Background-1"
        case .second:
            return "Onboarding-Background-2"
        }
    }

    var loginButtonTitle: String { "Вот это технологии!" }
}
