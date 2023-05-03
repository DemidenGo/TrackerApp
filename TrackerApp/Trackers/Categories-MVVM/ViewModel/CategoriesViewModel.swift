//
//  CategoriesViewModel.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 01.05.2023.
//

import Foundation

final class CategoriesViewModel {

    @Observable
    private(set) var categories: [CategoryViewModel] = []

    private var categoryStore: CategoryStoreProtocol?

    init(categoryStore: CategoryStoreProtocol = CategoryStore()) {
        self.categoryStore = categoryStore
        self.categoryStore?.delegate = self
        getCategoriesFromStore()
    }

    private func getCategoriesFromStore() {
        guard let categoryStore = categoryStore else { return }
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
        try? categoryStore?.save(newCategory)
    }

    private func select(_ category: String) {
        let indexPath = IndexPath(row: index(of: category), section: 0)
        selectCategory(at: indexPath)
    }
}

//MARK: - CategoriesViewModelProtocol

extension CategoriesViewModel: CategoriesViewModelProtocol {

    var categoriesObservable: Observable<[CategoryViewModel]> {
        $categories
    }

    var selectedCategory: String? {
        categories.first(where: { $0.isSelected == true })?.title
    }

    var selectedCategoryIndexPath: IndexPath {
        let index = categories.firstIndex { $0.isSelected == true } ?? 0
        return IndexPath(row: index, section: 0)
    }

    func deleteCategoryFromStore(at indexPath: IndexPath) {
        try? categoryStore?.deleteCategory(at: indexPath)
    }

    func selectCategory(at indexPath: IndexPath) {
        try? categoryStore?.setSelected(at: indexPath)
    }

    func didCreate(_ category: String) {
        isNew(category) ? addToStore(category) : select(category)
    }
}

//MARK: - CategoryStoreDelegate

extension CategoriesViewModel: CategoryStoreDelegate {

    func didUpdateCategories() {
        getCategoriesFromStore()
    }
}
