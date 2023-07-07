//
//  StatisticsServiceProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 07.07.2023.
//

import Foundation

protocol StatisticsServiceProtocol {
    var statistics: [Int] { get }
    func track()
    func untrack()
}
