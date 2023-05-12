//
//  ChapterVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import Foundation
import CoreData

class ChapterVM: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    private let controller : NSFetchedResultsController<ChapterMO>
    public var alert = false
    public var alertMessage = ""

    @Published var statusValue: Int = 0
    
    init(moc: NSManagedObjectContext) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \ChapterMO.date, ascending: true)]
        controller = ChapterMO.resultsController(moc: moc, sortDescriptors: sortDescriptors)
        super.init()

        controller.delegate = self

        do {
            try controller.performFetch()
            alert = false
        } catch {
            alert =  true
            alertMessage = "Saving data error"
        }
    }
    
    func saveContext() {
        do {
            try controller.managedObjectContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = "Saving data error"
        }
    }

    var chapters: [ChapterMO] {
        if controller.fetchedObjects?.isEmpty == true {
            statusValue = 1
            
            let chapter1 = ChapterMO(context: controller.managedObjectContext)
            chapter1.id = UUID()
            chapter1.date = Date()
            saveContext()
        }
        return controller.fetchedObjects ?? []
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }

    func addChapter() {
        deleteEmpty()
        
        if chapters.last?.safeDateContent.isToday == false {
            let chapter = ChapterMO(context: controller.managedObjectContext)
            chapter.id = UUID()
            chapter.date = Date()
            saveContext()
        }
        
        getConsecutiveDays()
    }

    func getCurrentChapter() -> ChapterMO {
        return chapters.last!
    }

    func deleteLast() {
        controller.managedObjectContext.delete(chapters.last!)
        saveContext()
        getConsecutiveDays()
    }

    func deleteAll() {
        for chapter in chapters {
            controller.managedObjectContext.delete(chapter)
        }
        saveContext()
        getConsecutiveDays()
    }
    
    func deleteEmpty() {
        for chapter in chapters {
            if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
                controller.managedObjectContext.delete(chapter)
            }
        }
        saveContext()
        getConsecutiveDays()
    }
    
    func deleteChapter(_ chapter: ChapterMO) {
        controller.managedObjectContext.delete(chapter)
        saveContext()
        getConsecutiveDays()
    }
    
    func getConsecutiveDays() {
        var streak = 0
        var lastDate: Date?

        for chapter in chapters {
            if let currentDate = chapter.date {
                if lastDate == nil {
                    if !chapter.itemsArray.isEmpty {
                        lastDate = currentDate
                        streak += 1
                    }
                    continue
                }
                
                if lastDate!.getDaysNum(currentDate) == 1 {
                    lastDate = currentDate
                    if streak < 7 {
                        streak += 1
                    }
                } else {
                    if lastDate!.getDaysNum(currentDate) % 2 == 1 {
                        if streak > 0 {
                            streak -= 1
                        } else {
                            streak = 0
                        }
                    }
                    lastDate = currentDate
                }
            }
        }
        
        statusValue = streak
    }

    func getStatusImage() -> String {
        switch statusValue {
        case 0:
            return "0"
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "3"
        case 4:
            return "4"
        case 5:
            return "5"
        case 6:
            return "6"
        case 7:
            return "week"
        default:
            return "inactive-long-time"
        }
    }
}

//
//
//class ChapterViewModel: ObservableObject {
//    private let viewContext = PersistenceController.shared.viewContext
//    @Published var chapters: [ChapterMO] = []
//    public var alert = false
//    public var alertMessage = ""
//
//    init() {
//        fetchChapterData()
//    }
//
//    func fetchChapterData() {
//        let request = NSFetchRequest<ChapterMO>(entityName: "ChapterMO")
//
//        do {
//            chapters = try viewContext.fetch(request)
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = "DEBUG: Some error occured while fetching"
//        }
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
//    func addChapter() {
//        if chapters.last?.safeDateContent.isToday == false || chapters.isEmpty {
//            let chapter = ChapterMO(context: viewContext)
//            chapter.id = UUID()
//            chapter.date = Date()
//
//            save()
//            self.fetchChapterData()
//        }
//    }
//
//    func getCurrentChapter() -> ChapterMO {
//        return chapters.last!
//    }
//
//    func deleteAll() {
//        for chapter in chapters {
//            viewContext.delete(chapter)
//        }
//        save()
//        self.fetchChapterData()
//    }
//}

//
//func addTestSet() {
//    let chapter = ChapterMO(context: controller.managedObjectContext)
//    chapter.id = UUID()
//    chapter.date = Date().addingTimeInterval(-86000)
//
////        saveContext()
//
//    let item = ItemMO(context: controller.managedObjectContext)
//    item.id = UUID()
//    item.timestamp = Date().addingTimeInterval(-86000)
//    item.text = "text"
//    item.type = "text"
//    item.chapter = chapter
//
////        updateStatus()
//
//    chapter.addToItems(item)
//
//    saveContext()
////
////        let chapter1 = ChapterMO(context: controller.managedObjectContext)
////        chapter1.id = UUID()
////        chapter1.date = Date().addingTimeInterval(-172000)
////
////        let item1 = ItemMO(context: controller.managedObjectContext)
////        item1.id = UUID()
////        item1.timestamp = Date().addingTimeInterval(-172000)
////        item1.text = "text1"
////        item1.type = "text"
////        item1.chapter = chapter1
////
////        chapter1.addToItems(item1)
////
////        saveContext()
////
////        updateStatus()
////
////        let chapter2 = ChapterMO(context: controller.managedObjectContext)
////        chapter2.id = UUID()
////        chapter2.date = Date().addingTimeInterval(-258000)
////
////        let item2 = ItemMO(context: controller.managedObjectContext)
////        item2.id = UUID()
////        item2.timestamp = Date().addingTimeInterval(-258000)
////        item2.text = "text2"
////        item2.type = "text"
////        item2.chapter = chapter2
////
////        chapter2.addToItems(item2)
////
////        saveContext()
////
////        updateStatus()
////
////        let chapter3 = ChapterMO(context: controller.managedObjectContext)
////        chapter3.id = UUID()
////        chapter3.date = Date().addingTimeInterval(-344000)
////
////        let item3 = ItemMO(context: controller.managedObjectContext)
////        item3.id = UUID()
////        item3.timestamp = Date().addingTimeInterval(-344000)
////        item3.text = "text3"
////        item3.type = "text"
////        item3.chapter = chapter3
////
////        chapter3.addToItems(item3)
////
////        saveContext()
////
////        updateStatus()
//}
