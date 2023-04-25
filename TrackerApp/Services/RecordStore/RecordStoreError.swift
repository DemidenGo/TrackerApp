//
//  RecordStoreError.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 24.04.2023.
//

import UIKit

enum RecordStoreError: Error {
    case requestedObjectNotFopund
    case decodingErrorInvalidTrackerID
    case decodingErrorInvalidDate
}