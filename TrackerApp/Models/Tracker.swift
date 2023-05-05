//
//  Tracker.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 16.03.2023.
//

import UIKit

struct Tracker: Codable {
    let id: String
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
}
