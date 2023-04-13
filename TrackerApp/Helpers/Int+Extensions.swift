//
//  Int+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 22.03.2023.
//

import UIKit

extension Int {
    var days: String {
        if (11...14).contains(self % 100) {
            return String(self) + " дней"
        }
        switch (self % 10) {
        case 1:
            return String(self) + " день"
        case 2, 3, 4:
            return String(self) + " дня"
        default:
            return String(self) + " дней"
        }
    }
}
