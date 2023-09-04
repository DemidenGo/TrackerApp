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
    var categoryForEditObservable: Observable<String?> { get }
    var isNeedToShowAlertObservable: Observable<Bool> { get }
    var selectedCategory: String? { get }
    var selectedCategoryIndexPath: IndexPath { get }
    func deleteCategoryFromStore(at indexPath: IndexPath)
    func deleteConfirmed()
    func selectCategory(at indexPath: IndexPath)
    func didCreate(_ category: String)
    func editCategory(at indexPath: IndexPath)
    func change(categoryName: String, to newName: String)
}
