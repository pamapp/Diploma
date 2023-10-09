//
//  ChapterVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import Foundation
import CoreData

class ChapterVM: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var message: String = ""
    @Published var statusValue: Int = 0
    @Published var searchResult: [ChapterMO] = []
    @Published var isEditingMode: Bool = false

    private let controller : NSFetchedResultsController<ChapterMO>
    private var searchText: String = ""
    private var fetchedChapters: [ChapterMO] {
        guard let fetchedObjects = controller.fetchedObjects else { return [] }
        return fetchedObjects
    }
    
    public var edittingItem: ItemMO
    public var alert = false
    public var alertMessage = ""
    
    public var currentChapter: ChapterMO {
        if !fetchedChapters.isEmpty {
            return fetchedChapters.last!
        }
        return chapters.last!
    }

    init(moc: NSManagedObjectContext) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \ChapterMO.date, ascending: true)]
        controller = ChapterMO.resultsController(moc: moc, sortDescriptors: sortDescriptors)
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
        
        if fetchedChapters.isEmpty {
            statusValue = 1

            let chapter = ChapterMO(context: controller.managedObjectContext)
            chapter.id = UUID()
            chapter.date = Date()
            saveContext()
        }
        
        addChapter()
//        getConsecutiveDays()
        
//        //вот это возможно плохо
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if self.shouldAddNewChapter() {
//                DispatchQueue.main.async { [weak self] in
//                    self?.addChapter()
//                    self?.getConsecutiveDays()
//                }
//            }
//        }
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

    var chapters: [ChapterMO] {
        return fetchedChapters
    }

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

    func editItem(itemVM: ItemVM, text: String) {
        itemVM.editItem(edittingItem, text: text)
        self.endEdit()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
        }
    }

    func searchAsync(with searchText: String, completion: @escaping ([ChapterMO]) -> Void) {
        DispatchQueue.global().async {
            let searchResult: [ChapterMO]
            if searchText.isEmpty {
                searchResult = self.fetchedChapters
            } else {
                searchResult = self.fetchedChapters.filter { chapter in
                    chapter.itemsArray.contains { item in
                        item.safeText.localizedCaseInsensitiveContains(searchText)
                    }
                }
            }
            completion(searchResult)
        }
    }

    func addChapter() {
        deleteEmpty()

        if fetchedChapters.last?.safeDateContent.isToday == false {
            let chapter = ChapterMO(context: controller.managedObjectContext)
            chapter.id = UUID()
            chapter.date = Date()
            saveContext()
        }
    }
    
    func shouldAddNewChapter() -> Bool {
        guard let lastChapter = chapters.last else {
            return true
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentDay = calendar.component(.day, from: currentDate)
        let lastChapterDay = calendar.component(.day, from: lastChapter.safeDateContent)
        
        return currentDay != lastChapterDay
    }
    
    func deleteLast() {
        guard let lastChapter = fetchedChapters.last else { return }
        controller.managedObjectContext.delete(lastChapter)
        saveContext()
    }

    func deleteAll() {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: ChapterMO.fetchRequest())
        do {
            try controller.managedObjectContext.execute(deleteRequest)
        } catch {
            print("Failed to delete chapters: \(error.localizedDescription)")
        }
        saveContext()
    }

    func deleteEmpty() {
        for chapter in fetchedChapters {
            if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
                controller.managedObjectContext.delete(chapter)
            }
        }
        saveContext()
    }

    func deleteChapter(_ chapter: ChapterMO) {
        controller.managedObjectContext.delete(chapter)
        saveContext()
        
        getConsecutiveDays()
    }
    
    func getConsecutiveDays() {
        var streak = 0
        var lastDate: Date?

        for chapter in fetchedChapters {
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
                    if lastDate!.getDaysNum(currentDate) > 2 {
                        if streak - lastDate!.getDaysNum(currentDate) >= 0 {
                            streak -= lastDate!.getDaysNum(currentDate)
                        } else {
                            if chapter.itemsArray.isEmpty {
                                streak = -1
                            } else {
                                streak = 0
                            }
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
