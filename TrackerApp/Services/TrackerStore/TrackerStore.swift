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

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.title", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
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
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTracker(insertedSections, deletedSections, updatedIndexPaths, insertedIndexPaths, deletedIndexPaths)
        clearUpdatedIndexes()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
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

    func save(_ tracker: Tracker, in category: String) throws {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category)
        let categoryCoreData = try? context.fetch(request)
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = UIColorMarshalling.serialize(color: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.scheduleString = tracker.schedule.map({ $0.rawValue }).joined(separator: ",")
        trackerCoreData.category = categoryCoreData?.first
        try context.save()
    }

    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        try context.save()
    }

    func trackersFor(_ currentDate: String, searchRequest: String?) {
        if let searchRequest = searchRequest {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@ AND %K CONTAINS[n] %@", #keyPath(TrackerCoreData.scheduleString), currentDate, #keyPath(TrackerCoreData.name), searchRequest)
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
}
