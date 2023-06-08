//
//  StatsTests.swift
//  MemoriesSwiftUITests
//
//  Created by Alina Potapova on 29.05.2023.
//

import XCTest
import CoreData
@testable import MemoriesSwiftUI

class StatsTests: XCTestCase {
    var chapterVM: ChapterVM!
    var statsVM: StatsVM!
    var itemVM: ItemVM!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        chapterVM = ChapterVM.init(moc: coreDataStack.mainContext)
        itemVM = ItemVM.init(moc: coreDataStack.mainContext, chapter: chapterVM.currentChapter)
        statsVM = StatsVM(chapterModel: chapterVM)
    }
    
    override func tearDown() {
        super.tearDown()
        statsVM = nil
        coreDataStack = nil
        itemVM = nil
        chapterVM = nil
    }
    
    func testTopWords() {
        let string = "Топ пример пример пример топ слов топ топ топ слов"
        itemVM.addItemParagraph(chapter: chapterVM.currentChapter, text: string)
    }
    
    func testTopEmoji() {
        let string = "Топ пример пример пример топ слов топ топ топ слов"
        itemVM.addItemParagraph(chapter: chapterVM.currentChapter, text: string)
    }
    
    func testMoodDynamics() {
        let string = "Топ пример пример пример топ слов топ топ топ слов"
        itemVM.addItemParagraph(chapter: chapterVM.currentChapter, text: string)
    }
}
