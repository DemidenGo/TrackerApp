//
//  TrackersStore.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 19.04.2023.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {

    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private lazy var insertedIndexPaths: [IndexPath] = []
    private lazy var deletedIndexPaths: [IndexPath] = []
    private lazy var updatedIndexPaths: [IndexPath] = []
    private lazy var insertedSections = IndexSet()
    private lazy var deletedSections = IndexSet()
    private lazy var updatedSections = IndexSet()

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.sortTrackersByCategoryKey,
                                                         ascending: true,
                                                         selector: #selector(NSString.localizedStandardCompare(_:))),
                                        NSSortDescriptor(key: Constants.sortTrackersByNameKey,
                                                         ascending: true,
                                                         selector: #selector(NSString.localizedStandardCompare(_:)))]
        fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.scheduleString), "\(Date().startOfDay.weekDayString)")
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
                                                    cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()

    init(context: NSManagedObjectContext, delegate: TrackerStoreDelegate) {
        self.context = context
        self.delegate = delegate
    }

    convenience init(delegate: TrackerStoreDelegate) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error: appDelegate not found")
        }
        self.init(context: appDelegate.persistentContainer.viewContext, delegate: delegate)
    }

    private func clearUpdatedIndexes() {
        insertedIndexPaths = []
        deletedIndexPaths = []
        updatedIndexPaths = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
        updatedSections = IndexSet()
    }

    private func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerID else {
            throw TrackerStoreError.decodingErrorInvalidTrackerID
        }
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingErrorInvalidTrackerName
        }
        guard let colorHex = trackerCoreData.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidTrackerColorHex
        }
        guard let color = UIColorMarshalling.deserialize(hexString: colorHex) else {
            throw TrackerStoreError.hexDeserializationError
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidTrackerEmoji
        }
        guard let scheduleString = trackerCoreData.scheduleString else {
            throw TrackerStoreError.decodingErrorInvalidTrackerScheduleString
        }
        let scheduleStringArray = scheduleString.components(separatedBy: ",")
        let scheduleArray = scheduleStringArray.map { WeekDay(rawValue: $0) ?? .friday }
        let schedule = Set(scheduleArray)
        return Tracker(id: id,
                       name: name,
                       color: color,
                       emoji: emoji,
                       schedule: schedule)
    }

    private func makeRecord(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerID = recordCoreData.tracker?.trackerID else {
            throw RecordStoreError.decodingErrorInvalidTrackerID
        }
        guard let date = recordCoreData.date else {
            throw RecordStoreError.decodingErrorInvalidDate
        }
        return TrackerRecord(id: trackerID, date: date)
    }

    private func retrieveTrackerCoreDataEntity(for tracker: Tracker) -> TrackerCoreData {
        let requestTracker = NSFetchRequest<TrackerCoreData>(entityName: Constants.trackerCoreData)
        requestTracker.returnsObjectsAsFaults = false
        requestTracker.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), tracker.id)
        let trackerCoreData: TrackerCoreData
        if let existingTrackerCoreData = try? context.fetch(requestTracker).first {
            trackerCoreData = existingTrackerCoreData
        } else {
            trackerCoreData = TrackerCoreData(context: context)
        }
        return trackerCoreData
    }

    private func retrieveCategoryCoreDataEntity(for category: String) -> TrackerCategoryCoreData? {
        let requestCategory = NSFetchRequest<TrackerCategoryCoreData>(entityName: Constants.trackerCategoryCoreData)
        requestCategory.returnsObjectsAsFaults = false
        requestCategory.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category)
        return try? context.fetch(requestCategory).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTracker(insertedSections, deletedSections,updatedSections, updatedIndexPaths, insertedIndexPaths, deletedIndexPaths)
        clearUpdatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        case .update:
            updatedSections.insert(sectionIndex)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexPaths.append(indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexPaths.append(indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newindexPath = newIndexPath {
                deletedIndexPaths.append(indexPath)
                insertedIndexPaths.append(newindexPath)
            }
        default:
            break
        }
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {

    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? makeTracker(from: trackerCoreData)
    }

    func name(of section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }

    func categoryStringForTracker(at indexPath: IndexPath) -> String? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.initialCategory
    }

    func save(_ tracker: Tracker, in category: String, isPinned: Bool) throws {
        let trackerCoreData = retrieveTrackerCoreDataEntity(for: tracker)
        let categoryCoreData = retrieveCategoryCoreDataEntity(for: isPinned ? L10n.Trackers.pinnedTitle : category)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = UIColorMarshalling.serialize(color: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.scheduleString = tracker.schedule.map({ $0.rawValue }).joined(separator: ",")
        trackerCoreData.initialCategory = category
        trackerCoreData.category = categoryCoreData
        try context.save()
    }

    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        try context.save()
    }

    func trackersFor(_ currentDate: String, searchRequest: String?) {
        if let searchRequest = searchRequest {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@ AND %K CONTAINS[c] %@", #keyPath(TrackerCoreData.scheduleString), currentDate, #keyPath(TrackerCoreData.name), searchRequest)
        } else {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.scheduleString), currentDate)
        }
        try? fetchedResultsController.performFetch()
    }

    func records(for trackerIndexPath: IndexPath) -> Set<TrackerRecord> {
        let trackerCoreData = fetchedResultsController.object(at: trackerIndexPath)
        guard let trackerRecordsCoreData = trackerCoreData.records as? Set<TrackerRecordCoreData> else {
            return Set<TrackerRecord>()
        }
        do {
            let trackerRecords = try trackerRecordsCoreData.map { try makeRecord(from: $0) }
            return Set(trackerRecords)
        } catch {
            return Set<TrackerRecord>()
        }
    }

    func pinTracker(at indexPath: IndexPath) throws {
        let pinnedTrackerCoreData = fetchedResultsController.object(at: indexPath)
        let pinnedCategoryCoreData: TrackerCategoryCoreData
        if let existingCategoryCoreData = retrieveCategoryCoreDataEntity(for: L10n.Trackers.pinnedTitle) {
            pinnedCategoryCoreData = existingCategoryCoreData
        } else {
            pinnedCategoryCoreData = TrackerCategoryCoreData(context: context)
            pinnedCategoryCoreData.title = L10n.Trackers.pinnedTitle
            pinnedCategoryCoreData.isCategorySelect = false
        }
        pinnedTrackerCoreData.category = pinnedCategoryCoreData
        try context.save()
    }

    func unpinTracker(at indexPath: IndexPath) throws {
        let unpinnedTrackerCoreData = fetchedResultsController.object(at: indexPath)
        guard let initialCategoryString = unpinnedTrackerCoreData.initialCategory else { return }
        let initialCategoryCoreData = retrieveCategoryCoreDataEntity(for: initialCategoryString)
        unpinnedTrackerCoreData.category = initialCategoryCoreData
        try context.save()
    }

    func checkTrackerIsPinned(at indexPath: IndexPath) -> Bool {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category?.title == L10n.Trackers.pinnedTitle ? true : false
    }
}
