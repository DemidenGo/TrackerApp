//
//  CategoriesViewModel.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 01.05.2023.
//

import Foundation

final class CategoriesViewModel {

    @Observable
    private(set) var categories: [CategoryViewModel]
    @Observable
    private var categoryForEdit: String?
    @Observable
    private var isNeedToShowAlert: Bool

    private var categoryStore: CategoryStoreProtocol
    private var trackerStore: TrackerStoreProtocol?
    private var categoryIndexPathToDelete: IndexPath?

    init(categoryStore: CategoryStoreProtocol = CategoryStore(),
         trackerStore: TrackerStoreProtocol? = nil) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        categories = []
        isNeedToShowAlert = false
        self.categoryStore.delegate = self
        getCategoriesFromStore()
    }

    private func getCategoriesFromStore() {
        categories = categoryStore.categories.map {
            CategoryViewModel(title: $0.title ?? "",
                              isSelected: $0.isCategorySelect)
        }
    }

    private func index(of category: String) -> Int {
        categories.firstIndex { $0.title == category } ?? 0
    }

    private func isNew(_ category: String) -> Bool {
        !categories.contains { $0.title == category }
    }

    private func addToStore(_ newCategory: String) {
        try? categoryStore.save(newCategory)
    }

    private func select(_ category: String) {
        let indexPath = IndexPath(row: index(of: category), section: 0)
        selectCategory(at: indexPath)
    }
}

//MARK: - CategoriesViewModelProtocol

extension CategoriesViewModel: CategoriesViewModelProtocol {

    var categoriesObservable: Observable<[CategoryViewModel]> { $categories }
    var categoryForEditObservable: Observable<String?> { $categoryForEdit }
    var isNeedToShowAlertObservable: Observable<Bool> { $isNeedToShowAlert }

    var selectedCategory: String? {
        categories.first(where: { $0.isSelected == true })?.title
    }

    var selectedCategoryIndexPath: IndexPath {
        let index = categories.firstIndex { $0.isSelected == true } ?? 0
        return IndexPath(row: index, section: 0)
    }

    func deleteCategoryFromStore(at indexPath: IndexPath) {
        isNeedToShowAlert = true
        categoryIndexPathToDelete = indexPath
    }

    func deleteConfirmed() {
        guard let indexPath = categoryIndexPathToDelete else { return }
        try? categoryStore.deleteCategory(at: indexPath)
        isNeedToShowAlert = false
        categoryIndexPathToDelete = nil
    }

    func selectCategory(at indexPath: IndexPath) {
        try? categoryStore.setSelected(at: indexPath)
    }

    func didCreate(_ category: String) {
        isNew(category) ? addToStore(category) : select(category)
    }

    func editCategory(at indexPath: IndexPath) {
        categoryForEdit = categories[indexPath.row].title
    }

    func change(categoryName: String, to newCategoryName: String) {
        guard let categoryIndex = categories.firstIndex(where: { $0.title == categoryName }) else { return }
        let categoryIndexPath = IndexPath(row: categoryIndex, section: 0)
        categoryStore.changeCategoryName(at: categoryIndexPath, to: newCategoryName)
        trackerStore?.updateTrackers(in: categoryName, to: newCategoryName)
    }
}

//MARK: - CategoryStoreDelegate

extension CategoriesViewModel: CategoryStoreDelegate {

    func didUpdateCategories() {
        getCategoriesFromStore()
    }
}
