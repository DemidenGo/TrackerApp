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
            case "Пн":
                sortedArrayOfDays[0] = value
            case "Вт":
                sortedArrayOfDays[1] = value
            case "Ср":
                sortedArrayOfDays[2] = value
            case "Чт":
                sortedArrayOfDays[3] = value
            case "Пт":
                sortedArrayOfDays[4] = value
            case "Сб":
                sortedArrayOfDays[5] = value
            case "Вс":
                sortedArrayOfDays[6] = value
            default:
                preconditionFailure("The elements of the array must all be day names")
            }
        }
        sortedArrayOfDays.removeAll { $0 == "" }
        return sortedArrayOfDays.count == 7 ? "Каждый день" : sortedArrayOfDays.joined(separator: ", ")
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
