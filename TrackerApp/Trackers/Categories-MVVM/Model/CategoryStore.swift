//
//  TrackerCategoryStore.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 19.04.2023.
//

import UIKit
import CoreData

final class CategoryStore: NSObject {

    weak var delegate: CategoryStoreDelegate?
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.sortCategoriesKey, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K != %@",
                                             #keyPath(TrackerCategoryCoreData.title), L10n.Trackers.pinnedTitle)
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error: appDelegate not found")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }

    private func makeCategoryName(from categoryCoreData: TrackerCategoryCoreData) throws -> String {
        guard let categoryName = categoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryName
        }
        return categoryName
    }

    private func deselectPreviousCategory() throws {
        let categoryCoreData = fetchedResultsController.fetchedObjects ?? []
        guard let previousSelectedCategory = categoryCoreData.first(where: { $0.isCategorySelect == true }) else {
            return
        }
        previousSelectedCategory.isCategorySelect = false
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}

// MARK: - CategoryStoreProtocol

extension CategoryStore: CategoryStoreProtocol {

    var categories: [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    func save(_ category: String) throws {
        try deselectPreviousCategory()
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category
        categoryCoreData.isCategorySelect = true
        try context.save()
    }

    func deleteCategory(at indexPath: IndexPath) throws {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(categoryCoreData)
        try context.save()
    }

    func setSelected(at indexPath: IndexPath) throws {
        try deselectPreviousCategory()
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        categoryCoreData.isCategorySelect = true
        try context.save()
    }

    func objectTitle(at indexPath: IndexPath) -> String? {
        let trackerCategoryCoreData = fetchedResultsController.object(at: indexPath)
        return try? makeCategoryName(from: trackerCategoryCoreData)
    }
}
