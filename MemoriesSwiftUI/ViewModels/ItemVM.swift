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

class ItemVM: ObservableObject {
    private let viewContext = PersistenceController.shared.viewContext
    @Published var items: [ItemMO] = []
    
    var chapterVM: ChapterVM
    var chapter: ChapterMO
    
    public var alert = false
    public var alertMessage = ""
    
    init(chapter: ChapterMO) {
        self.chapter = chapter
        self.chapterVM = ChapterVM(moc: viewContext)
    }
    
    func fetchItems() {
        items = chapter.itemsArray
    }
    
    func save() {
        do {
            try viewContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = "Saving data error"
        }
    }
    
    
    func addItemParagraph(chapter: ChapterMO, text: String) {
        let item = ItemMO(context: viewContext)
        item.id = UUID()
        item.timestamp = Date()
        item.text = text
        item.type = "text"
        item.sentiment = ""
        item.chapter = chapter
        
        chapter.addToItems(item)
        save()
        fetchItems()
        setMemorySentiment(item)
    }
    
    func addItemMedia(chapter: ChapterMO, attachments: [Data], type: String) {
        if !attachments.isEmpty && attachments.count <= 3 {
            let item = ItemMO(context: viewContext)
            let mediaAlbum = MediaAlbumMO(context: viewContext)
            
            mediaAlbum.item = item
            
            for attachment in attachments {
                let media = MediaMO(context: viewContext)
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
            let item = ItemMO(context: viewContext)
            let mediaAlbum = MediaAlbumMO(context: viewContext)
            
            mediaAlbum.item = item
            
            
            for attachment in attachments {
                let media = MediaMO(context: viewContext)
                media.id = UUID()
                media.date = Date()
                media.data = attachment
                media.album = mediaAlbum
                mediaAlbum.addToAttachments(media)
            }
            
            item.id = UUID()
            item.timestamp = Date()
            item.mediaAlbum = mediaAlbum
            item.type = "textWithPhoto"
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

    func setMemorySentiment(_ item: ItemMO){
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
    
    func deleteAll() {
        for item in items {
            viewContext.delete(item)
        }
        save()
        fetchItems()
    }
    
    func deleteItem(_ item: ItemMO) {
        viewContext.delete(item)
        save()
        fetchItems()
        
        if chapter.itemsArray.isEmpty {
            chapterVM.deleteChapter(chapter)
        }
    }
    
}
