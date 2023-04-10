//
//  TrackersStorageService.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 04.04.2023.
//

import UIKit

protocol TrackersStorageProtocol {
    func save(trackers: [TrackerCategory])
    func save(trackerRecords: Set<TrackerRecord>)
    func loadTrackers() -> [TrackerCategory]?
    func loadTrackerRecords() -> Set<TrackerRecord>?
}

final class TrackersUserDefaultsStorage: TrackersStorageProtocol {

    static let shared = TrackersUserDefaultsStorage()
    private let storage = UserDefaults.standard

    private enum Keys: String {
        case trackers
        case trackerRecords
    }

    private var trackers: [TrackerCategory]? {
        guard let encodedData = storage.data(forKey: Keys.trackers.rawValue) else {
            print("Error: unable to get trackers from storage")
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let decodedTrackers = try decoder.decode(Array<TrackerCategory>.self, from: encodedData)
            return decodedTrackers
        } catch {
            print("Error: unable to decode trackers from data: \(error.localizedDescription)")
            return nil
        }
    }

    private var trackerRecords: Set<TrackerRecord>? {
        guard let encodedData = storage.data(forKey: Keys.trackerRecords.rawValue) else {
            print("Error: unable to get tracker records from storage")
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let decodedTrackerRecords = try decoder.decode(Set<TrackerRecord>.self, from: encodedData)
            return decodedTrackerRecords
        } catch {
            print("Error: unable to decode tracker records from data: \(error.localizedDescription)")
            return nil
        }
    }

    func save(trackers: [TrackerCategory]) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(trackers)
            storage.set(encodedData, forKey: Keys.trackers.rawValue)
        } catch {
            preconditionFailure("Unable to encode trackers to data: \(error.localizedDescription)")
        }
    }

    func loadTrackers() -> [TrackerCategory]? {
        trackers
    }

    func save(trackerRecords: Set<TrackerRecord>) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(trackerRecords)
            storage.set(encodedData, forKey: Keys.trackerRecords.rawValue)
        } catch {
            preconditionFailure("Unable to encode tracker records to data: \(error.localizedDescription)")
        }
    }

    func loadTrackerRecords() -> Set<TrackerRecord>? {
        trackerRecords
    }
}

