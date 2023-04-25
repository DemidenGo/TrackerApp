//
//  TrackerStoreErrors.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidTrackerID
    case decodingErrorInvalidTrackerName
    case decodingErrorInvalidTrackerColorHex
    case decodingErrorInvalidTrackerEmoji
    case decodingErrorInvalidTrackerScheduleString
    case hexDeserializationError
}
