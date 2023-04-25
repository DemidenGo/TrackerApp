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
    func object(at indexPath: IndexPath) -> Tracker?
    func save(_ tracker: Tracker, in category: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func trackersFor(_ currentDate: String, searchRequest: String?)
    func records(for trackerIndexPath: IndexPath) -> Set<TrackerRecord>
}
