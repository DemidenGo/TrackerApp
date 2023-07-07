//
//  StatisticsService.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 07.07.2023.
//

import Foundation

final class StatisticsService: StatisticsServiceProtocol {

    private enum Keys: String {
        case trackCount
    }

    static let shared = StatisticsService()

    private let userDefaults: UserDefaults

    var statistics: [Int] { [bestPeriod, perfectDays, trackCount, averageValue] }

    private var bestPeriod: Int { 0 }
    private var perfectDays: Int { 0 }
    private var averageValue: Int { 0 }

    private var trackCount: Int {
        get { return userDefaults.integer(forKey: Keys.trackCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.trackCount.rawValue) }
    }

    init() { self.userDefaults = UserDefaults.standard }

    func track() {
        trackCount += 1
    }

    func untrack() {
        trackCount -= 1
    }
}
