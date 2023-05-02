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
}

//MARK: - CategoriesViewModelProtocol

extension CategoriesViewModel: CategoriesViewModelProtocol {

    var categoriesObservable: Observable<[CategoryViewModel]> {
        $categories
    }

    var selectedCategory: String? {
        categories.first(where: { $0.isSelected == true })?.title
    }

    func isNew(_ category: String) -> Bool {
        !categories.contains { $0.title == category }
    }

    func index(of category: String) -> Int? {
        categories.firstIndex { $0.title == category } ?? 0
    }

    func addToStore(_ newCategory: String) {
        try? categoryStore?.save(newCategory)
    }

    func deleteCategoryFromStore(at indexPath: IndexPath) {
        try? categoryStore?.deleteCategory(at: indexPath)
    }

    func selectCategory(at indexPath: IndexPath) {
        try? categoryStore?.setSelected(at: indexPath)
    }
}

//MARK: - CategoryStoreDelegate

extension CategoriesViewModel: CategoryStoreDelegate {

    func didUpdateCategories() {
        getCategoriesFromStore()
    }
}
