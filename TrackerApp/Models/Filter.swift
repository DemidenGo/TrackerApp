//
//  Filters.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 05.07.2023.
//

import Foundation

enum Filter: Int, CaseIterable {
    case all, today, completed, uncompleted

    var localizedString: String {
        switch self {
        case .all:
            return L10n.Trackers.allTrackersTitle
        case .today:
            return L10n.Trackers.todayTrackersTitle
        case .completed:
            return L10n.Trackers.completedTrackersTitle
        case .uncompleted:
            return L10n.Trackers.uncompletedTrackersTitle
        }
    }
}
