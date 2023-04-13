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
    formatter.locale = Locale(identifier: "ru")
    return formatter
}()

extension Date {
    var weekDayString: String { weekDayDateFormatter.string(from: self) }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}
