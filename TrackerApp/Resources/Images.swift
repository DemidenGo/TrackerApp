//
//  Images.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 26.06.2023.
//

import Foundation

enum Images {
    // Onboarding background images
    enum Onboarding {
        static let firstPage = "Onboarding-Background-1"
        static let secondPage = "Onboarding-Background-2"
    }
    // TabBar items images
    enum TabBar {
        static let firstItem = "TrackersTabBarItem"
        static let firstItemSelected = "TrackersTabBarItemSelected"
        static let secondItem = "StatisticsTabBarItem"
        static let secondItemSelected = "StatisticsTabBarItemSelected"
    }
    // Trackers screen images
    enum Trackers {
        static let addButton = "AddButton"
        static let emptyState = "StarIcon"
        static let nothingFound = "NothingFoundIcon"
        static let plus = "plus"
        static let checkmark = "checkmark"
        static let pin = "pin.fill"
    }
    // Statistics screen images
    enum Statistics {
        static let stubImage = "StubImage"
    }
}
