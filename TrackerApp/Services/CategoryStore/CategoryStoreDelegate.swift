//
//  CategoryStoreDelegate.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import UIKit

protocol CategoryStoreDelegate: AnyObject {
    func didUpdateCategory(_ insertedIndexes: IndexSet, _ deletedIndexes: IndexSet)
}
