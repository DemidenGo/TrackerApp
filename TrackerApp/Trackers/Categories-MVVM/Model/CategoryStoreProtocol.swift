//
//  categoryStoreProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.04.2023.
//

import Foundation

protocol CategoryStoreProtocol {
    var delegate: CategoryStoreDelegate? { get set }
    var categories: [TrackerCategoryCoreData] { get }
    func save(_ category: String) throws
    func deleteCategory(at indexPath: IndexPath) throws
    func setSelected(at indexPath: IndexPath) throws
    func objectTitle(at indexPath: IndexPath) -> String?
}
