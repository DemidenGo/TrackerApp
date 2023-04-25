//
//  categoryStoreProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import UIKit

protocol CategoryStoreProtocol {
    func numberOfItems() -> Int
    func indexPath(for existingCategory: String) -> IndexPath?
    func object(at indexPath: IndexPath) -> String?
    func save(_ category: String) throws -> IndexPath?
    func deleteCategory(at indexPath: IndexPath) throws
}
