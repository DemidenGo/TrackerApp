//
//  Localization.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 26.06.2023.
//

import Foundation

enum L10n {
    // Onboarding messages
    enum Onboarding {
        static let firstMessage = NSLocalizedString("firstOnboardingMessage", comment: "Message for onboarding screen")
        static let secondMessage = NSLocalizedString("secondOnboardingMessage", comment: "Message for onboarding screen")
        static let loginButtonTitle = NSLocalizedString("loginTitle", comment: "Login button title")
    }
    // Trackers screens titles
    enum Trackers {
        static let trackersTitle = NSLocalizedString("trackersTitle", comment: "Trackers title")
        static let statisticsTitle = NSLocalizedString("statisticsTitle", comment: "Statistics title")
        static let searchFieldPlaceholder = NSLocalizedString("searchTitle", comment: "Search field placeholder")
        static let emptyStateTitle = NSLocalizedString("stubTitle", comment: "Empty state title")
        static let nothingFoundTitle = NSLocalizedString("nothingFoundTitle", comment: "Nothing found title")
        static let trackedDaysTitle = NSLocalizedString("numberOfDays", comment: "Number of tracked days")
        static let trackerCreationTitle = NSLocalizedString("trackerCreationTitle", comment: "Tracker creation title")
        static let regularTrackerTitle = NSLocalizedString("regularTrackerTitle", comment: "Regular tracker title")
        static let irregularTrackerTitle = NSLocalizedString("irregularTrackerTitle", comment: "Irregular tracker title")
        static let newRegularTrackerTitle = NSLocalizedString("newRegularTrackerTitle", comment: "New regular tracker title")
        static let trackerNamePlaceholder = NSLocalizedString("trackerNamePlaceholder", comment: "Tracker name placeholder")
        static let emojiTitle = NSLocalizedString("emojiTitle", comment: "Emoji title")
        static let colorTitle = NSLocalizedString("colorTitle", comment: "Color title")
        static let cancelTitle = NSLocalizedString("cancelTitle", comment: "Cancel button title")
        static let createTitle = NSLocalizedString("createTitle", comment: "Create button title")
        static let charLimitTitle = NSLocalizedString("charLimitTitle", comment: "Characters limit title")
        static let categoryTitle = NSLocalizedString("categoryTitle", comment: "Category button title")
        static let scheduleTitle = NSLocalizedString("scheduleTitle", comment: "Schedule button title")
        static let emptyCategoriesTitle = NSLocalizedString("emptyCategoriesTitle", comment: "Empty categories title")
        static let addCategoryTitle = NSLocalizedString("addCategoryTitle", comment: "Add category button title")
        static let newCategoryTitle = NSLocalizedString("newCategoryTitle", comment: "New category title")
        static let categoryNamePlaceholder = NSLocalizedString("categoryNamePlaceholder", comment: "Category name placeholder")
        static let doneTitle = NSLocalizedString("doneTitle", comment: "Done button title")
    }
    enum Weekdays {
        // Full style
        static let mondayTitle = NSLocalizedString("mondayTitle", comment: "Monday title")
        static let tuesdayTitle = NSLocalizedString("tuesdayTitle", comment: "Tuesday title")
        static let wednesdayTitle = NSLocalizedString("wednesdayTitle", comment: "Wednesday title")
        static let thursdayTitle = NSLocalizedString("thursdayTitle", comment: "Thursday title")
        static let fridayTitle = NSLocalizedString("fridayTitle", comment: "Friday title")
        static let saturdayTitle = NSLocalizedString("saturdayTitle", comment: "Saturday title")
        static let sundayTitle = NSLocalizedString("sundayTitle", comment: "Sunday title")
        // Short style
        static let mondayShortTitle = NSLocalizedString("mondayShortTitle", comment: "Monday short style title")
        static let tuesdayShortTitle = NSLocalizedString("tuesdayShortTitle", comment: "Tuesday short style title")
        static let wednesdayShortTitle = NSLocalizedString("wednesdayShortTitle", comment: "Wednesday short style title")
        static let thursdayShortTitle = NSLocalizedString("thursdayShortTitle", comment: "Thursday short style title")
        static let fridayShortTitle = NSLocalizedString("fridayShortTitle", comment: "Friday short style title")
        static let saturdayShortTitle = NSLocalizedString("saturdayShortTitle", comment: "Saturday short style title")
        static let sundayShortTitle = NSLocalizedString("sundayShortTitle", comment: "Sunday short style title")
        // Every day
        static let everyDayTitle = NSLocalizedString("everyDayTitle", comment: "Title for every day schedule")
    }
}