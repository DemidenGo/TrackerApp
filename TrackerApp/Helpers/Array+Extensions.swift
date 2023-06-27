//
//  Array+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.03.2023.
//

import UIKit

extension Array<String> {

    var sortByWeekDaysString: String {
        var sortedArrayOfDays = ["", "", "", "", "", "", ""]
        for value in self {
            switch value {
            case L10n.Weekdays.mondayShortTitle: sortedArrayOfDays[0] = value
            case L10n.Weekdays.tuesdayShortTitle: sortedArrayOfDays[1] = value
            case L10n.Weekdays.wednesdayShortTitle: sortedArrayOfDays[2] = value
            case L10n.Weekdays.thursdayShortTitle: sortedArrayOfDays[3] = value
            case L10n.Weekdays.fridayShortTitle: sortedArrayOfDays[4] = value
            case L10n.Weekdays.saturdayShortTitle: sortedArrayOfDays[5] = value
            case L10n.Weekdays.sundayShortTitle: sortedArrayOfDays[6] = value
            default: preconditionFailure("The elements of the array must all be day names")
            }
        }
        sortedArrayOfDays.removeAll { $0 == "" }
        return sortedArrayOfDays.count == 7 ? L10n.Weekdays.everyDayTitle : sortedArrayOfDays.joined(separator: ", ")
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
