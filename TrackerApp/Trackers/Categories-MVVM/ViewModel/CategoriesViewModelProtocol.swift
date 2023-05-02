//
//  CategoriesViewModelProtocol.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 02.05.2023.
//

import Foundation

protocol CategoriesViewModelProtocol {
    var categories: [CategoryViewModel] { get }
    var categoriesObservable: Observable<[CategoryViewModel]> { get }
    var selectedCategory: String? { get }
    func isNew(_ category: String) -> Bool
    func index(of category: String) -> Int?
    func addToStore(_ newCategory: String)
    func deleteCategoryFromStore(at indexPath: IndexPath)
    func selectCategory(at indexPath: IndexPath)
}
