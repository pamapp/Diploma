//
//  ItemVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import NaturalLanguage
import Foundation
import CoreData
import CoreML
import SwiftUI

enum ItemType: String {
    case text = "text"
    case textWithPhoto = "textWithPhoto"
    case photo = "photo"
    case audio = "audio"
}

class ItemVM: ObservableObject {
    @Published var alert: Bool = false
    @Published var alertMessage: String = ""
    @Published var items: [ItemMO] = []
    @Published var sentiment: String = ""
    
    private let controller :  NSFetchedResultsController<ItemMO>
    private var chapterVM: ChapterVM
    private var chapter: ChapterMO
    
    init(moc: NSManagedObjectContext, chapter: ChapterMO) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \ItemMO.timestamp, ascending: true)]
        controller = ItemMO.resultsController(moc: moc, sortDescriptors: sortDescriptors, predicate: NSPredicate(format: "chapter = %@", chapter))
        
        self.chapter = chapter
        self.chapterVM = ChapterVM(moc: moc)

        fetchItems()
    }
    
    private func fetchItems() {
        items = chapter.itemsArray
    }
    
    private func save() {
        do {
            try controller.managedObjectContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = Errors.savingDataError
        }
    }
    
    func addItemParagraph(chapter: ChapterMO, text: String) {
        let item = ItemMO(context: controller.managedObjectContext)
        item.id = UUID()
        item.timestamp = Date()
        item.text = text
        item.type = ItemType.text.rawValue
        item.sentiment = ""
        item.chapter = chapter
        
        chapter.addToItems(item)
        save()
        fetchItems()
        setMemorySentiment(item)
    }
    
    func addItemMedia(chapter: ChapterMO, attachments: [Data], type: String) {
        if !attachments.isEmpty && attachments.count <= 3 {
            let item = ItemMO(context: controller.managedObjectContext)
            let mediaAlbum = MediaAlbumMO(context: controller.managedObjectContext)
            
            mediaAlbum.item = item
            
            for attachment in attachments {
                let media = MediaMO(context: controller.managedObjectContext)
                media.id = UUID()
                media.date = Date()
                media.data = attachment
                media.album = mediaAlbum
                mediaAlbum.addToAttachments(media)
            }
            
            item.id = UUID()
            item.timestamp = Date()
            item.mediaAlbum = mediaAlbum
            item.type = type
            item.sentiment = "neutral"
            item.chapter = chapter
            
            chapter.addToItems(item)
            save()
            fetchItems()
        } else {
            self.alert =  true
            self.alertMessage = "You can't add more than 3 photos"
        }
    }
    
    
    func addItemParagraphAndMedia(chapter: ChapterMO, attachments: [Data], text: String) {
        if !attachments.isEmpty && attachments.count <= 3 {
            let item = ItemMO(context: controller.managedObjectContext)
            let mediaAlbum = MediaAlbumMO(context: controller.managedObjectContext)
            
            mediaAlbum.item = item
            
            
            for attachment in attachments {
                let media = MediaMO(context: controller.managedObjectContext)
                media.id = UUID()
                media.date = Date()
                media.data = attachment
                media.album = mediaAlbum
                mediaAlbum.addToAttachments(media)
            }
            
            item.id = UUID()
            item.timestamp = Date()
            item.mediaAlbum = mediaAlbum
            item.type = ItemType.textWithPhoto.rawValue
            item.text = text
            item.sentiment = ""
            item.chapter = chapter
            
            chapter.addToItems(item)
            save()
            fetchItems()
            setMemorySentiment(item)
        } else {
            self.alert =  true
            self.alertMessage = "You can't add more than 3 photos"
        }
    }

    func setMemorySentiment(_ item: ItemMO) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mlModel = try SentimentClassifier(configuration: MLModelConfiguration()).model
                let customModel = try NLModel(mlModel: mlModel)
                
                DispatchQueue.main.async {
                    item.sentiment = customModel.predictedLabel(for: item.safeText) ?? ""
                    self.save()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alert =  true
                    self.alertMessage = "Can't load model"
                }
            }
        }
    }
    
    func editItem(_ item: ItemMO, text: String) {
        if item.isEditable {
            item.text = text
            save()
            fetchItems()
        }
    }
    
    func deleteAll() {
        for item in items {
            controller.managedObjectContext.delete(item)
        }
        save()
        fetchItems()
    }
    
    func deleteItem(_ item: ItemMO) {
        controller.managedObjectContext.delete(item)
        save()
        fetchItems()
        
        if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
            chapterVM.deleteChapter(chapter)
        }
    }
}
