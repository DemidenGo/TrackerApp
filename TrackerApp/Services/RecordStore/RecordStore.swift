//
//  TrackerRecordStore.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 19.04.2023.
//

import UIKit
import CoreData

final class RecordStore: NSObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Error: appDelegate not found")
        }
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
}

// MARK: - RecordStoreProtocol

extension RecordStore: RecordStoreProtocol {

    func save(_ record: TrackerRecord) throws {
        let requestTracker = NSFetchRequest<TrackerCoreData>(entityName: Constants.trackerCoreData)
        requestTracker.returnsObjectsAsFaults = false
        requestTracker.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), record.id)
        let trackerCoreData = try? context.fetch(requestTracker)
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.tracker = trackerCoreData?.first
        try context.save()
    }

    func delete(_ record: TrackerRecord) throws {
        let requestRecord = NSFetchRequest<TrackerRecordCoreData>(entityName: Constants.trackerRecordCoreData)
        requestRecord.returnsObjectsAsFaults = false
        requestRecord.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerID), record.id, #keyPath(TrackerRecordCoreData.date), record.date as CVarArg)
        guard let recordCoreData = try? context.fetch(requestRecord).first else {
            throw RecordStoreError.requestedObjectNotFopund
        }
        context.delete(recordCoreData)
        try context.save()
    }
}
