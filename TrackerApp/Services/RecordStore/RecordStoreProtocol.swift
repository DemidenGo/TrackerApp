//
//  RecordStoreProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 24.04.2023.
//

import UIKit

protocol RecordStoreProtocol {
    func save(_ record: TrackerRecord) throws
    func delete(_ record: TrackerRecord) throws
}
