//
//  TrackerStoreProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import UIKit

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func name(of section: Int) -> String?
    func categoryStringForTracker(at indexPath: IndexPath) -> String?
    func object(at indexPath: IndexPath) -> Tracker?
    func save(_ tracker: Tracker, in category: String, isPinned: Bool) throws
    func deleteTracker(at indexPath: IndexPath) throws -> Int
    func trackersFor(_ currentDate: String, searchRequest: String?)
    func completedTrackersFor(_ IDs: [String?], on currentDate: String)
    func uncompletedTrackersFor(_ IDs: [String?], on currentDate: String)
    func records(for trackerIndexPath: IndexPath) -> Set<TrackerRecord>
    func pinTracker(at indexPath: IndexPath) throws
    func unpinTracker(at indexPath: IndexPath) throws
    func checkTrackerIsPinned(at indexPath: IndexPath) -> Bool
    func updateTrackers(in category: String, to newCategory: String)
}
