//
//  Date+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 22.03.2023.
//

import UIKit

let weekDayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.locale = Locale(identifier: "en")
    return formatter
}()

extension Date {
    var weekDayString: String { weekDayDateFormatter.string(from: self).lowercased() }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
