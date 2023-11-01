//
//  ChapterVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import Foundation
import CoreData

class ChapterDataService: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    private let persistenceController = PersistenceController.shared
    private let controller: NSFetchedResultsController<ChapterMO>
    public var alert = false
    public var alertMessage = ""
    
    @Published var chapters: [ChapterMO] = []
    @Published var message: String = ""
    @Published var statusValue: Int = 0
    @Published var isEditingMode: Bool = false
    
    private var edittingItem: ItemMO

    override init() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \ChapterMO.date, ascending: true)]
        controller = ChapterMO.resultsController(moc: persistenceController.viewContext,
                                                 sortDescriptors: sortDescriptors)

        self.edittingItem = ItemMO(context: controller.managedObjectContext)
        super.init()

        controller.delegate = self

        do {
            try controller.performFetch()
            alert = false
        } catch {
            alert =  true
            alertMessage = Errors.savingDataError
        }

        self.fetchChapters()
        self.addChapterIfNeeded()
        self.updateActivityIndicator()
    }
    
    private func fetchChapters() {
        if let fetchedObjects = controller.fetchedObjects {
            chapters = fetchedObjects
        } else {
            statusValue = 1
            addChapter()
        }
    }
    
    func addChapterIfNeeded() {
        deleteEmpty()
        if chapters.last?.safeDateContent.isToday == false || chapters.isEmpty {
            addChapter()
        }
        applyChanges()
    }
    
    private func addChapter() {
        let chapter = ChapterMO(context: controller.managedObjectContext)
        chapter.id = UUID()
        chapter.date = Date()
        applyChanges()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
        }
    }
    
    func deleteChapter(_ chapter: ChapterMO) {
        controller.managedObjectContext.delete(chapter)
        applyChanges()
        updateActivityIndicator()
    }
    
    func deleteEmpty() {
        for chapter in chapters {
            if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
                controller.managedObjectContext.delete(chapter)
            }
        }
        applyChanges()
    }

    func deleteAll() {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: ChapterMO.fetchRequest())
        do {
            try controller.managedObjectContext.execute(deleteRequest)
        } catch {
            print("Failed to delete chapters: \(error.localizedDescription)")
        }
        applyChanges()
    }

    private func applyChanges() {
        saveContext()
        fetchChapters()
    }
    
    private func saveContext() {
        do {
            try controller.managedObjectContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = Errors.savingDataError
        }
    }
}


extension ChapterDataService {
    
    // MARK: - Activity Indicator -

    func updateActivityIndicator() {
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
                
                 if chapter != chapters.last {
                     if lastDate!.getDaysNum(currentDate) == 1 {
                         lastDate = currentDate
                         if streak < 7 {
                             streak += 1
                         }
                     } else {
                         if lastDate!.getDaysNum(currentDate) > 2 {
                             if streak - lastDate!.getDaysNum(currentDate) >= 0 {
                                 streak -= lastDate!.getDaysNum(currentDate)
                             } else {
                                 streak = 0
                             }
                         }
                         lastDate = currentDate
                     }
                 } else if chapter == chapters.last && !chapter.itemsArray.isEmpty {
                     streak += 1
                 }
             }
        }
        print(streak)
        statusValue = streak
    }

    func getStatusImage() -> String {
        switch statusValue {
        case 0...7:
            return "\(statusValue)"
        default:
            return "inactive-long-time"
        }
    }
}

extension ChapterDataService {
    
    // MARK: - Edit -
    
    func getEditingStatus(memory: ItemMO) -> Bool {
        edittingItem == memory && isEditingMode
    }
    
    func changeMessage(chapter: ChapterMO, itemText: String) {
        if let foundItem = chapter.itemsArray.first(where: { $0.safeText == itemText }) {
            self.startEdit()
            self.message = foundItem.safeText
            edittingItem = foundItem
        }
    }
    
    private func startEdit() {
        self.isEditingMode = true
    }
    
    func endEdit() {
        self.message = ""
        self.edittingItem = ItemMO(context: controller.managedObjectContext)
        self.isEditingMode = false
    }

    func editItem(itemVM: ItemService, text: String) {
        itemVM.editItem(edittingItem, text: text)
        self.endEdit()
    }
}
//
//    func searchAsync(with searchText: String, completion: @escaping ([ChapterMO]) -> Void) {
//        DispatchQueue.global().async {
//            let searchResult: [ChapterMO]
//            if searchText.isEmpty {
//                searchResult = self.fetchedChapters
//            } else {
//                searchResult = self.fetchedChapters.filter { chapter in
//                    chapter.itemsArray.contains { item in
//                        item.safeText.localizedCaseInsensitiveContains(searchText)
//                    }
//                }
//            }
//            completion(searchResult)
//        }
//    }

//    @Published var searchResult: [ChapterMO] = []
//    private var searchText: String = ""

