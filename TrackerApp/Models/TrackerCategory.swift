//
//  TrackerCategory.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 16.03.2023.
//

import UIKit

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}
