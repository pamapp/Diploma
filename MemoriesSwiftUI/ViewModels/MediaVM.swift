//
//  MediaVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 02.03.2023.
//
//
//import SwiftUI
//import CoreData
//import Foundation
//
//class MediaViewModel: ObservableObject {
//    private let viewContext = PersistenceController.shared.viewContext
//    @Published var mediaItems: [MediaMO] = []
//    var album: MediaAlbumMO
//
//    public var alert = false
//    public var alertMessage = ""
//
//    init(mediaAlbum: MediaAlbumMO) {
//        self.album = mediaAlbum
//    }
//
//    func fetchItems() {
//        mediaItems = album.attachmentsArray
//    }
//
//    func save() {
//        do {
//            try viewContext.save()
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = "Saving data error"
//        }
//    }
//
//    func addMedia(data: Data) {
//        let mediaItem = MediaMO(context: viewContext)
//        mediaItem.id = UUID()
//        mediaItem.date = Date()
//        mediaItem.album = album
//
//        album.addToAttachments(mediaItem)
//        save()
//        fetchItems()
//
//    }
//
//    func deleteAll() {
//        for item in mediaItems {
//            viewContext.delete(item)
//        }
//        save()
//        fetchItems()
//    }
//}
//
//
//class MediaAlbumViewModel: ObservableObject {
//    private let viewContext = PersistenceController.shared.viewContext
//    @Published var mediaAlbum: MediaAlbumMO = .init()
//    var memory: ItemMO
//
//    public var alert = false
//    public var alertMessage = ""
//
//    init(memory: ItemMO) {
//        self.memory = memory
//    }
//
//    func fetchItems() {
//        mediaAlbum = memory.mediaAlbum!
//    }
//
//    func save() {
//        do {
//            try viewContext.save()
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = "Saving data error"
//        }
//    }
//
//    func addMediaAlbum() {
//        let mediaItem = MediaAlbumMO(context: viewContext)
//        mediaItem.item = memory
//        save()
//        fetchItems()
//
//    }
//
//    func deleteAll() {
//        viewContext.delete(mediaAlbum)
//        save()
//        fetchItems()
//    }
//}


//
//class MediaAlbumModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate{
//    private let controller: NSFetchedResultsController<MediaAlbumMO>
//    public var alert = false
//    public var alertMessage = ""
//
//    init(moc: NSManagedObjectContext, item: ItemMO) {
//        let sortDescriptors = [NSSortDescriptor(keyPath: \MediaAlbumMO.id, ascending: true)]
//        controller = MediaAlbumMO.resultsController(moc: moc, sortDescriptors: sortDescriptors, predicate: NSPredicate(format: "item = %@", item))
//        super.init()
//
//        controller.delegate = self
//
//        do {
//            try controller.performFetch()
//            alert = false
//        } catch{
//            alert =  true
//            alertMessage = "Saving data error"
//        }
//    }
//
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        objectWillChange.send()
//    }
//
//    func saveContext(){
//        do {
//            try controller.managedObjectContext.save()
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = "Saving data error"
//        }
//    }
//
//    func addMediaAlbum(item: ItemMO) {
//        let mediaAlbum = MediaAlbumMO(context: controller.managedObjectContext)
//        mediaAlbum.item = item
//        saveContext()
//    }
//}
