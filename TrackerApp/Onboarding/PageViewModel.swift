//
//  PageModel.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 03.05.2023.
//

import Foundation

enum Pages: CaseIterable {
    
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

    static var loginButtonTapAction: (() -> Void)?
}
