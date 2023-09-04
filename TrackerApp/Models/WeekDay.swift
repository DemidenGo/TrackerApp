//
//  Schedule.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.03.2023.
//

import UIKit

enum WeekDay: String, CaseIterable, Codable {

    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var localizedString: String {
        switch self {
        case .monday: return L10n.Weekdays.mondayTitle
        case .tuesday: return L10n.Weekdays.tuesdayTitle
        case .wednesday: return L10n.Weekdays.wednesdayTitle
        case .thursday: return L10n.Weekdays.thursdayTitle
        case .friday: return L10n.Weekdays.fridayTitle
        case .saturday: return L10n.Weekdays.saturdayTitle
        case .sunday: return L10n.Weekdays.sundayTitle
        }
    }

    var localizedStringInShortStyle: String {
        switch self {
        case .monday: return L10n.Weekdays.mondayShortTitle
        case .tuesday: return L10n.Weekdays.tuesdayShortTitle
        case .wednesday: return L10n.Weekdays.wednesdayShortTitle
        case .thursday: return L10n.Weekdays.thursdayShortTitle
        case .friday: return L10n.Weekdays.fridayShortTitle
        case .saturday: return L10n.Weekdays.saturdayShortTitle
        case .sunday: return L10n.Weekdays.sundayShortTitle
        }
    }
}
