//
//  TrackerStoreDelegate.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTracker(_ insertedSections: IndexSet, _ deletedSections: IndexSet, _ updatedIndexPaths: [IndexPath], _ insertedIndexPaths: [IndexPath], _ deletedIndexPaths: [IndexPath])
}
