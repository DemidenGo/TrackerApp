//
//  Constants.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 27.06.2023.
//

import Foundation

enum Constants {
    // Content
    static let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    static let baseColorName = "Color "
    // Sort descriptor keys
    static let sortCategoriesKey = "title"
    static let sortTrackersByCategoryKey = "category.title"
    static let sortTrackersByNameKey = "name"
    // CoreData entities
    static let trackerCategoryCoreData = "TrackerCategoryCoreData"
    static let trackerCoreData = "TrackerCoreData"
    static let trackerRecordCoreData = "TrackerRecordCoreData"
}
