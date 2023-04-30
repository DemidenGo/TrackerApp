//
//  UserDefaults+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 30.04.2023.
//

import Foundation

extension UserDefaults {

     var hasLaunchBefore: Bool {
           get {
             return self.bool(forKey: #function)
           }
           set {
             self.set(newValue, forKey: #function)
           }
     }
}
