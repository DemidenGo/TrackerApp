//
//  Statistics.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 06.07.2023.
//

import Foundation

enum Statistics: Int, CaseIterable {
    case best, perfect, completed, average

    var localizedString: String {
        switch self {
        case .best: return L10n.Statistics.bestPeriodTitle
        case .perfect: return L10n.Statistics.perfectDaysTitle
        case .completed: return L10n.Statistics.trackersCompletedTitle
        case .average: return L10n.Statistics.averageValueTitle
        }
    }
}
