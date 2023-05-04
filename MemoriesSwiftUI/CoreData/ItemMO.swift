//
//  Item.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import Foundation
import CoreData
import SwiftUI
import CryptoKit

@objc(ItemMO)
public class ItemMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var text: String?
    @NSManaged public var type: String?
    @NSManaged public var sentiment: String?
    @NSManaged public var mediaAlbum: MediaAlbumMO?
    @NSManaged public var chapter: ChapterMO?
}

extension ItemMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemMO> {
        return NSFetchRequest<ItemMO>(entityName: "ItemMO")
    }

    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate) -> NSFetchedResultsController<ItemMO>
    {
        let request =  NSFetchRequest<ItemMO>(entityName: "ItemMO")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    public var safeTimestampContent: Date {
        get { timestamp ?? Date() }
        set { timestamp = newValue }
    }
    
    public var safeID: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    public var safeText: String {
        get { text ?? String() }
        set { text = newValue }
    }
    
    public var safeType: String {
        get { type ?? String() }
        set { type = newValue }
    }
    
    public var safeSentimentColor: Color {
        switch sentiment {
        case "positive":
            return .c3
        case "negative":
            return .c5
        default:
            return .c4
        }
    }
    
    public var safeSentimentValue: Double {
        switch sentiment {
        case "positive":
            return 10.0
        case "negative":
            return 1.0
        default:
            return 5.0
        }
    }

}

extension ItemMO : Identifiable {
}

