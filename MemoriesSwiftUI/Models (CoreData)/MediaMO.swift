//
//  MediaData.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.03.2023.
//

import Foundation
import CoreData

@objc(MediaMO)
public class MediaMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var data: Data?
    @NSManaged public var album: MediaAlbumMO?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaMO> {
        return NSFetchRequest<MediaMO>(entityName: "MediaMO")
    }
    
    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate) -> NSFetchedResultsController<MediaMO>
    {
        let request =  NSFetchRequest<MediaMO>(entityName: "MediaMO")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    public var safeDateContent: Date {
        get { date ?? Date() }
        set { date = newValue }
    }
    
    public var safeDataContent: Data {
        get { data ?? Data() }
        set { data = newValue }
    }
}

extension MediaMO: Identifiable {
}
