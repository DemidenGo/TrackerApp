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
    var selectedCategoryIndexPath: IndexPath { get }
    func deleteCategoryFromStore(at indexPath: IndexPath)
    func selectCategory(at indexPath: IndexPath)
    func didCreate(_ category: String)
}
