//
//  AnalyticsService.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.06.2023.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService: AnalyticsServiceProtocol {
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "54b2a2dd-2536-4b6c-aabf-c7dd91871bf5") else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
