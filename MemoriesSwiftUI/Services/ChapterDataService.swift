//
//  ChapterVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import Foundation
import CoreData
import NaturalLanguage
import CoreML

class ChapterDataService: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    static let shared = ChapterDataService()
    
    private let persistenceController = PersistenceController.shared
    private let controller: NSFetchedResultsController<ChapterMO>
    
    public var alert = false
    public var alertMessage = ""
    
    @Published var chapters: [ChapterMO] = []
    @Published var message: String = ""
    @Published var isEditingMode: Bool = false
    
    @Published var statusValue: Int = 0
    
    private var edittingItem: ItemMO
    private var statusManager = StatusManager.shared
    
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
//        self.addTestChapters(range: 10...100)
//        self.deleteTestChapters(range: 10...100)
        self.addChapterIfNeeded()
        self.statusValue = StatusManager.shared.getStatusMO().safeValue
        
        print("init ChapterDataService")
    }
     
    private func fetchChapters() {
        if let fetchedObjects = controller.fetchedObjects {
            chapters = fetchedObjects
        } else {
            addChapter()
        }
    }
    
    func addChapterIfNeeded() {
        deleteEmpty()
        if chapters.last?.safeDateContent.isToday == false || chapters.isEmpty {
            addChapter()
            statusManager.updateIsChanged(newValue: false)
            print("тут")
        }
        applyChanges()
    }
    
    private func addChapter() {
        let chapter = ChapterMO(context: controller.managedObjectContext)
        chapter.id = UUID()
        chapter.date = Date()
        applyChanges()
    }
    
    func deleteChapter(_ chapter: ChapterMO) {
        controller.managedObjectContext.delete(chapter)
        applyChanges()
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
            try persistenceController.viewContext.execute(deleteRequest)
        } catch {
            print("Failed to delete chapters: \(error.localizedDescription)")
        }
        applyChanges()
    }

    private func applyChanges() {
        saveContext()
        fetchChapters()
        objectWillChange.send()
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [self] in
            objectWillChange.send()
            print("objectWillChange.send()")
        }
    }
}


extension ChapterDataService {
    
    // MARK: - StatusValue

    func updateStatusValue() {
        print(statusManager.getStatusMO().safeIsChanged)
        print(statusManager.getStatusMO().safeValue)

        
        var streak = statusManager.getStatusMO().safeValue
        let currentChapter: ChapterMO = chapters.last ?? ChapterMO()
        let currentDate: Date = currentChapter.safeDateContent
    
        guard chapters.count != 1 else {
            if !currentChapter.itemsArray.isEmpty && !statusManager.getStatusMO().safeIsChanged {
                streak = 1
                statusManager.updateStatus(newValue: streak, newIsChange: true)
                statusValue = streak
            }
            return
        }
            
        let secondChapter = chapters[chapters.count - 2]
        let secondDate = secondChapter.safeDateContent

        if !statusManager.getStatusMO().safeIsChanged {
            if secondDate.getDaysNum(currentDate) == 1 {
                if streak < 7 && !currentChapter.itemsArray.isEmpty {
                    streak += 1
                    statusManager.updateStatus(newValue: streak, newIsChange: true)
                    statusValue = streak
                }
            } else {
                if currentChapter.itemsArray.isEmpty {
                    if Int(streak) - secondDate.getDaysNum(currentDate) > 0 {
                        streak -= secondDate.getDaysNum(currentDate)
                    } else {
                        streak = -1
                    }
                    statusManager.updateStatus(newValue: streak, newIsChange: false)
                    statusValue = streak
                } else {
                    streak += 1
                    statusManager.updateStatus(newValue: streak, newIsChange: true)
                    statusValue = streak
                }
            }
        }
    }
}

extension ChapterDataService {
    
    // MARK: - Edit -
    
    func getEditingStatus(memory: ItemMO) -> Bool {
        edittingItem == memory && isEditingMode
    }
    
    func changeMessage(chapter: ChapterMO, item: ItemMO) {
        if let foundItem = chapter.itemsArray.first(where: { $0 == item }) {
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

    func editItem(itemVM: ItemDataService, text: String) {
        itemVM.editItem(edittingItem, text: text)
        self.endEdit()
    }
}

extension ChapterDataService {
    
    func addTestChapters(range: ClosedRange<Int>) {
        for num in range {
            let chapter = ChapterMO(context: controller.managedObjectContext)
            chapter.id = UUID()
            
            let currentDate = Date()
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -num, to: currentDate)
           
            chapter.date = yesterday
            
            for hour in 1...3 {
                let yesterdayHour = calendar.date(byAdding: .hour, value: -hour, to: currentDate)

                let item = ItemMO(context: controller.managedObjectContext)
                item.id = UUID()
                item.timestamp = yesterdayHour
                item.text = getRandomPhrase() + getNumbersPhrase()
                item.type = ItemType.text.rawValue
                item.sentiment = ""
                item.chapter = chapter
                chapter.addToItems(item)
            }
            
            applyChanges()
        }
    }
    
    
    func deleteTestChapters(range: ClosedRange<Int>) {
        for num in range {
            let currentDate = Date()
            let calendar = Calendar.current
            _ = calendar.date(byAdding: .day, value: -num, to: currentDate)

            guard let yesterday = calendar.date(byAdding: .day, value: -num, to: currentDate) else {
                print("here 1")
                return
            }
            if let foundItem = chapters.first(where: { getDayFromDate($0.safeDateContent) == getDayFromDate(yesterday) })
            {
                print("here")
                deleteChapter(foundItem)
            }
        }
    }
    
    func getDayFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: date)
        print(dayComponent)
        return dayComponent
    }
    
    func searchAsync(with searchText: String, completion: @escaping ([ChapterMO]) -> Void) {
        DispatchQueue.global().async {
            let searchResult: [ChapterMO]
            if searchText.isEmpty {
                searchResult = self.chapters
            } else {
                searchResult = self.chapters.filter { chapter in
                    chapter.itemsArray.contains { item in
                        item.safeText.localizedCaseInsensitiveContains(searchText)
                    }
                }
            }
            completion(searchResult)
        }
    }

}


// Массив фраз
let phrases = [
    "Жизнь прекрасна!",
    "Скучаю по тебе...",
    "Смех продлевает жизнь.",
    "Печаль без конца.",
    "Сегодня день радости!",
    "Всё будет хорошо.",
    "Серые будни...",
    "Счастье в мелочах.",
    "Грусть в глазах.",
    "Лучше улыбнись!",
    "Дождливый день.",
    "Светлое будущее.",
    "Плачу от смеха.",
    "Тоска в сердце.",
    "Улыбнись и мир улыбнется тебе.",
    "Счастье ближе, чем кажется.",
    "Суета и шум.",
    "Пустота внутри.",
    "Радуга после дождя.",
    "Скучаю по прошлому.",
    "Подними голову, дружище!",
    "Скучно одиноко.",
    "Улыбка дарит тепло.",
    "Тяжелое сердце.",
    "Солнце всегда за горизонтом.",
    "Ветер перемен.",
    "Счастье в мелочах.",
    "Суета и пустяки.",
    "Грусть прошлого.",
    "Новый день, новые надежды."
]

// Массив чисел
let numbersString = [
    "43",
    "3",
    "234.",
    "11.",
    "1234",
    "765",
    "098",
    "4321",
]

// Функция для получения случайной фразы из массива
func getRandomPhrase() -> String {
    let randomIndex = Int(arc4random_uniform(UInt32(phrases.count)))
    return phrases[randomIndex]
}

func getNumbersPhrase() -> String {
    let randomIndex = Int(arc4random_uniform(UInt32(numbersString.count)))
    return numbersString[randomIndex]
}


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

//func updateActivityIndicator() {
//    var streak = 0
//    var lastDate: Date?
//    print(chapters.count)
//
//    for chapter in chapters {
//        if let currentDate = chapter.date {
//            print("\(chapter.safeDateContent) \(String(describing: chapter.itemsArray.first?.safeText))")
//            
//            if lastDate == nil {
//                if !chapter.itemsArray.isEmpty {
//                    lastDate = currentDate
//                    streak += 1
//                 }
//                 print("lastDate \(streak)")
//
//                 continue
//            }
//            
//            if lastDate!.getDaysNum(currentDate) == 1 {
//                if streak < 7 && !chapter.itemsArray.isEmpty {
//                    streak += 1
//                }
//                lastDate = currentDate
//                print("1 day: \(streak)")
//            } else {
//                if streak - lastDate!.getDaysNum(currentDate) >= 0 {
//                    streak -= lastDate!.getDaysNum(currentDate)
//                } else {
//                    if chapter.itemsArray.isEmpty {
//                        streak = -1
//                    } else {
//                        streak = 0
//                    }
//                }
//                print("\(lastDate!.getDaysNum(currentDate)) days: \(streak)")
//                
//                lastDate = currentDate
//            }
//        }
//    }
//    statusValue = streak
//}

//
//
////
////  ChapterVM.swift
////  MemoriesSwiftUI
////
////  Created by Alina Potapova on 18.02.2023.
////
//
//import Foundation
//import CoreData
//
//class ChapterDataService: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
//    static let shared = ChapterDataService()
//    
//    private var statusManager = StatusManager.shared
//    
//    private let persistenceController = PersistenceController.shared
//    private let controller: NSFetchedResultsController<ChapterMO>
//    
//    public var alert = false
//    public var alertMessage = ""
//    
//    @Published var chapters: [ChapterMO] = []
//    @Published var message: String = ""
////    @Published var statusValue: Int = 0
//    @Published var isEditingMode: Bool = false
//    
//    private var edittingItem: ItemMO
//    
//    override init() {
//        let sortDescriptors = [NSSortDescriptor(keyPath: \ChapterMO.date, ascending: true)]
//        controller = ChapterMO.resultsController(moc: persistenceController.viewContext,
//                                                 sortDescriptors: sortDescriptors)
//
//        self.edittingItem = ItemMO(context: controller.managedObjectContext)
//        super.init()
//
//        controller.delegate =  self
//
//        do {
//            try controller.performFetch()
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = Errors.savingDataError
//        }
//
//        self.fetchChapters()
//        self.addChapterIfNeeded()
//        print("init ChapterDataService")
//    }
//    
//    private func fetchChapters() {
//        if let fetchedObjects = controller.fetchedObjects {
//            chapters = fetchedObjects
//        } else {
////            statusValue = 1
//            addChapter()
//        }
//    }
//    
//    func addChapterIfNeeded() {
//        deleteEmpty()
//        if let lastChapter = chapters.last {
//            if lastChapter.safeDateContent.isToday == false {
//                addChapter()
//            }
//        } else {
//            addChapter()
//        }
//        applyChanges()
//    }
//    
//    private func addChapter() {
//        let chapter = ChapterMO(context: controller.managedObjectContext)
//        chapter.id = UUID()
//        chapter.date = Date()
//        applyChanges()
//        updateStatusValue()
//        print("addChapter \(statusManager.getStatusMO().safeValue)")
//    }
//    
//    func deleteChapter(_ chapter: ChapterMO) {
//        controller.managedObjectContext.delete(chapter)
//        applyChanges()
//    }
//    
//    func deleteEmpty() {
//        for chapter in chapters {
//            if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
//                controller.managedObjectContext.delete(chapter)
//            }
//        }
//        applyChanges()
//    }
//
//    func deleteAll() {
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: ChapterMO.fetchRequest())
//        do {
//            try controller.managedObjectContext.execute(deleteRequest)
//        } catch {
//            print("Failed to delete chapters: \(error.localizedDescription)")
//        }
//        applyChanges()
//    }
//
//    private func applyChanges() {
//        saveContext()
//        fetchChapters()
//        objectWillChange.send()
//    }
//    
//    private func saveContext() {
//        do {
//            try controller.managedObjectContext.save()
//            alert = false
//        } catch {
//            alert =  true
//            alertMessage = Errors.savingDataError
//        }
//    }
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        DispatchQueue.main.async { [self] in
//            objectWillChange.send()
//            print("я тут, я свой")
//        }
//    }
//}
//
//

//
//extension ChapterDataService {
//    
//    // MARK: - Edit -
//    
//    func getEditingStatus(memory: ItemMO) -> Bool {
//        edittingItem == memory && isEditingMode
//    }
//    
//    func changeMessage(chapter: ChapterMO, itemText: String) {
//        if let foundItem = chapter.itemsArray.first(where: { $0.safeText == itemText }) {
//            self.startEdit()
//            self.message = foundItem.safeText
//            edittingItem = foundItem
//        }
//    }
//    
//    private func startEdit() {
//        self.isEditingMode = true
//    }
//    
//    func endEdit() {
//        self.message = ""
//        self.edittingItem = ItemMO(context: controller.managedObjectContext)
//        self.isEditingMode = false
//    }
//
//    func editItem(itemVM: ItemDataService, text: String) {
//        itemVM.editItem(edittingItem, text: text)
//        self.endEdit()
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//extension ChapterDataService {
//    func addTestChapter1() {
//        let chapter = ChapterMO(context: controller.managedObjectContext)
//        chapter.id = UUID()
//        
//        // Получить текущую дату и временную зону
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate)
//        
//        // Установить дату 'date' во вчерашний день
//        chapter.date = yesterday
//        
//        let item = ItemMO(context: controller.managedObjectContext)
//        item.id = UUID()
//        item.timestamp = yesterday
//        item.text = "Какой-то текстик. Вохможно длинный, возможно нет))"
//        item.type = ItemType.text.rawValue
//        item.sentiment = ""
//        item.chapter = chapter
//        
//        chapter.addToItems(item)
//        
//        applyChanges()
//    }
//    
//    func addTestChapter2() {
//        let chapter = ChapterMO(context: controller.managedObjectContext)
//        chapter.id = UUID()
//        
//        // Получить текущую дату и временную зону
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -2, to: currentDate)
//        
//        // Установить дату 'date' во вчерашний день
//        chapter.date = yesterday
//        
//        let item = ItemMO(context: controller.managedObjectContext)
//        item.id = UUID()
//        item.timestamp = yesterday
//        item.text = "В английском языке существует понятие спеллинг - произнесение слова по буквам, потому что иногда хуй проссышь, как именно пишется данное слово. Скажем, light и lite произносятся одинаково, но пишутся по-разному. Поэтому с появлением телефонной связи и раций военные начали придумывать более или менее универсальный алфавит, чтобы произносить буквы заранее определенными словами."
//        item.type = ItemType.text.rawValue
//        item.sentiment = ""
//        item.chapter = chapter
//        chapter.addToItems(item)
//        
//        let item2 = ItemMO(context: controller.managedObjectContext)
//        item2.id = UUID()
//        item2.timestamp = yesterday
//        item2.text = "Some staff that doesn't have any reasons to be rigth here, but it quite long to check spaces in scroll view, so LET IT BE!"
//        item2.type = ItemType.text.rawValue
//        item2.sentiment = ""
//        item2.chapter = chapter
//        
//        chapter.addToItems(item2)
//        
//        applyChanges()
//    }
//    
//    func addTestChapter3() {
//        let chapter = ChapterMO(context: controller.managedObjectContext)
//        chapter.id = UUID()
//        
//        // Получить текущую дату и временную зону
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -3, to: currentDate)
//        
//        // Установить дату 'date' во вчерашний день
//        chapter.date = yesterday
//        
//        let item = ItemMO(context: controller.managedObjectContext)
//        item.id = UUID()
//        item.timestamp = yesterday
//        item.text = "Самару и Саратов? Австрию и Австралию? Астрахань и Архангельск? Швецию и Швейцарию? Волгоград и Вологду? Апробовать и апробировать? Одеть и надеть?"
//        item.type = ItemType.text.rawValue
//        item.sentiment = ""
//        item.chapter = chapter
//        
//        chapter.addToItems(item)
//        
//        applyChanges()
//    }
//    
//    func addTestChapter4() {
//        let chapter = ChapterMO(context: controller.managedObjectContext)
//        chapter.id = UUID()
//        
//        // Получить текущую дату и временную зону
//        let currentDate = Date()
//        let calendar = Calendar.current
//        let yesterday = calendar.date(byAdding: .day, value: -4, to: currentDate)
//        
//        // Установить дату 'date' во вчерашний день
//        chapter.date = yesterday
//        
//        let item = ItemMO(context: controller.managedObjectContext)
//        item.id = UUID()
//        item.timestamp = yesterday
//        item.text = "Какой-то странный Саратов, некоторые говорят норм, а некоторые утверждают, что херня полнейшая. ХМММ..."
//        item.type = ItemType.text.rawValue
//        item.sentiment = ""
//        item.chapter = chapter
//        
//        chapter.addToItems(item)
//        
//        applyChanges()
//    }
//}
//
//
////
////    func searchAsync(with searchText: String, completion: @escaping ([ChapterMO]) -> Void) {
////        DispatchQueue.global().async {
////            let searchResult: [ChapterMO]
////            if searchText.isEmpty {
////                searchResult = self.fetchedChapters
////            } else {
////                searchResult = self.fetchedChapters.filter { chapter in
////                    chapter.itemsArray.contains { item in
////                        item.safeText.localizedCaseInsensitiveContains(searchText)
////                    }
////                }
////            }
////            completion(searchResult)
////        }
////    }
//
////    @Published var searchResult: [ChapterMO] = []
////    private var searchText: String = ""
//
////func updateActivityIndicator() {
////    var streak = 0
////    var lastDate: Date?
////    print(chapters.count)
////
////    for chapter in chapters {
////        if let currentDate = chapter.date {
////            print("\(chapter.safeDateContent) \(String(describing: chapter.itemsArray.first?.safeText))")
////
////            if lastDate == nil {
////                if !chapter.itemsArray.isEmpty {
////                    lastDate = currentDate
////                    streak += 1
////                 }
////                 print("lastDate \(streak)")
////
////                 continue
////            }
////
////            if lastDate!.getDaysNum(currentDate) == 1 {
////                if streak < 7 && !chapter.itemsArray.isEmpty {
////                    streak += 1
////                }
////                lastDate = currentDate
////                print("1 day: \(streak)")
////            } else {
////                if streak - lastDate!.getDaysNum(currentDate) >= 0 {
////                    streak -= lastDate!.getDaysNum(currentDate)
////                } else {
////                    if chapter.itemsArray.isEmpty {
////                        streak = -1
////                    } else {
////                        streak = 0
////                    }
////                }
////                print("\(lastDate!.getDaysNum(currentDate)) days: \(streak)")
////
////                lastDate = currentDate
////            }
////        }
////    }
////    statusValue = streak
////}
