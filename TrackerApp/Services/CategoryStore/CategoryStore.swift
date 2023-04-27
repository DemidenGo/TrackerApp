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
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    init(context: NSManagedObjectContext, delegate: CategoryStoreDelegate) {
        self.context = context
        self.delegate = delegate
    }

    convenience init(delegate: CategoryStoreDelegate) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error: appDelegate not found")
        }
        self.init(context: appDelegate.persistentContainer.viewContext, delegate: delegate)
    }

    private func clearUpdatedIndexes() {
        insertedIndexes = nil
        deletedIndexes = nil
    }

    private func makeCategoryName(from categoryCoreData: TrackerCategoryCoreData) throws -> String {
        guard let categoryName = categoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryName
        }
        return categoryName
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CategoryStore: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategory(insertedIndexes ?? IndexSet(), deletedIndexes ?? IndexSet())
        clearUpdatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

// MARK: - CategoryStoreProtocol

extension CategoryStore: CategoryStoreProtocol {

    func numberOfItems() -> Int {
        fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    func indexPath(for existingCategory: String) -> IndexPath? {
        let categories = fetchedResultsController.fetchedObjects?.map { try? makeCategoryName(from: $0) }
        guard let index = categories?.firstIndex(of: existingCategory) else { return nil }
        return IndexPath(row: index, section: 0)
    }

    func object(at indexPath: IndexPath) -> String? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        return try? makeCategoryName(from: categoryCoreData)
    }

    func save(_ category: String) throws -> IndexPath? {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category
        try context.save()
        return fetchedResultsController.indexPath(forObject: categoryCoreData)
    }

    func deleteCategory(at indexPath: IndexPath) throws {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(categoryCoreData)
        try context.save()
    }
}
