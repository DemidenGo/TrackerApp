//
//  AnalyticsServiceProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.06.2023.
//

import Foundation

protocol AnalyticsServiceProtocol {
    func report(event: String, params : [AnyHashable : Any])
}
