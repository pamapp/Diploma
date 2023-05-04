//
//  MediaAlbum.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.03.2023.
//

import Foundation
import CoreData

@objc(MediaAlbumMO)
public class MediaAlbumMO: NSManagedObject {
    @NSManaged public var item: ItemMO?
    @NSManaged public var attachments: NSSet?
    
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaAlbumMO> {
        return NSFetchRequest<MediaAlbumMO>(entityName: "MediaAlbumMO")
    }
    
    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate) -> NSFetchedResultsController<MediaAlbumMO>
    {
        let request =  NSFetchRequest<MediaAlbumMO>(entityName: "MediaAlbumMO")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    public var attachmentsArray: [MediaMO] {
        let itemsSet = attachments as? Set<MediaMO> ?? []
        
        return itemsSet.sorted {
            $0.safeDateContent < $1.safeDateContent
        }
    }
}

extension MediaAlbumMO {
    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: MediaMO)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: MediaMO)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)
}

extension MediaAlbumMO: Identifiable {
    
}
