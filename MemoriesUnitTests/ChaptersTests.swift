//
//  ChaptersTests.swift
//  ChaptersTests
//
//  Created by Alina Potapova on 18.02.2023.
//

import XCTest
import CoreData
@testable import MemoriesSwiftUI

class ChaptersTests: XCTestCase {
    var chapterVM: ChapterVM!
    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        coreDataStack = TestCoreDataStack()
        chapterVM = ChapterVM.init(moc: coreDataStack.mainContext)
    }

    override func tearDown() {
        super.tearDown()
        chapterVM = nil
        coreDataStack = nil
    }

    func testCurrentChapter() {
        let chapter = chapterVM.currentChapter
        XCTAssertNotNil(chapter, "Folder should not be nil")
        XCTAssertNotNil(chapter.id, "Id should not be nil")
    }

    func testAddChapter() {
        chapterVM.addChapter()
        XCTAssertNotNil(chapterVM.chapters[0], "Folder should not be nil")
        XCTAssertNotNil(chapterVM.chapters[0].id, "Id should not be nil")
        XCTAssertNotNil(chapterVM.chapters[0].date, "Id should not be nil")
    }

    func testRemoveChapter() {
        chapterVM.addChapter()
        XCTAssertNotNil(chapterVM.chapters[0], "Folder should not be nil")
        chapterVM.deleteChapter(chapterVM.chapters[0])
        XCTAssertTrue(chapterVM.chapters.isEmpty)
    }
    
    func testChangeMessage() {
        chapterVM.addChapter()
        
        let chapter = chapterVM.chapters[0]
        let item = ItemMO(context: coreDataStack.mainContext)
        item.chapter = chapter
        item.safeText = "Test Item"
        chapter.addToItems(item)
        
        chapterVM.changeMessage(chapter: chapter, itemText: "Test Item")
        XCTAssertTrue(chapterVM.isEditingMessage, "isEditingMessage should be true")
        XCTAssertEqual(chapterVM.message, "Test Item", "Message should be 'Test Item'")
        XCTAssertEqual(chapterVM.edittingItem, item, "edittingItem should be the selected item")
    }
 
    func testEditItem() {
        chapterVM.addChapter()
        let chapter = chapterVM.chapters[0]
        let item = ItemMO(context: coreDataStack.mainContext)
        item.safeText = "Test Item"
        item.chapter = chapter
        chapter.addToItems(item)
        
        chapterVM.changeMessage(chapter: chapter, itemText: "Test Item")
        
        let itemVM = ItemVM(moc: coreDataStack.mainContext, chapter: chapter)
        chapterVM.editItem(itemVM: itemVM, text: "Updated Item")
        
        XCTAssertEqual(item.safeText, "Updated Item", "Item text should be updated")
        XCTAssertFalse(chapterVM.isEditingMessage, "isEditingMessage should be false")
    }
        
    func testSearchAsync() async throws {
        chapterVM.addChapter()
        let chapter = chapterVM.chapters[0]
        
        let item1 = ItemMO(context: coreDataStack.mainContext)
        item1.chapter = chapter
        item1.safeText = "Test Item 1"
        
        let item2 = ItemMO(context: coreDataStack.mainContext)
        item2.chapter = chapter
        item2.safeText = "Test Item 2"
        
        chapter.addToItems(item1)
        chapter.addToItems(item2)
        
        let expectation = XCTestExpectation(description: "SearchAsync")
        
        chapterVM.searchAsync(with: "Item 1") { [weak self] searchResult in
            self?.chapterVM.searchResult = searchResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(chapterVM.searchResult.count, 1, "Search result count should be 1")
        XCTAssertEqual(chapterVM.searchResult.first?.itemsArray.filter { $0.safeText.localizedCaseInsensitiveContains("Item 1") }.first?.safeText, "Test Item 1", "Search result item text should be 'Test Item 1'")
        XCTAssertEqual(chapterVM.searchResult.first?.itemsArray.filter { $0.safeText.localizedCaseInsensitiveContains("Item 1") }.count, 1, "Search result item count should be 1")
    }
    
    func testShouldAddNewChapter() {
        // Test case: When chapter exists
        XCTAssertFalse(chapterVM.shouldAddNewChapter(), "Shouldn't add new chapter when chapter exist")

        // Test case: Last chapter is from a different day
        chapterVM.chapters.first?.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(chapterVM.shouldAddNewChapter(), "Should add new chapter when last chapter is from a different day")

        // Test case: Last chapter is from the same day
        chapterVM.chapters.first?.date = Date()
        XCTAssertFalse(chapterVM.shouldAddNewChapter(), "Shouldn't add new chapter when last chapter is from the same day")
    }

    func testDeleteLast() {
        chapterVM.deleteLast()
        XCTAssertTrue(chapterVM.chapters.isEmpty, "Should delete the last chapter")
    }

    func testDeleteEmpty() {
        chapterVM.addChapter()
        chapterVM.chapters.first?.date = Date()
        chapterVM.deleteEmpty()
        
        XCTAssertFalse(chapterVM.chapters.isEmpty, "Should delete empty chapter")

        let chapter = chapterVM.chapters[0]
        let item = ItemMO(context: coreDataStack.mainContext)
        item.text = "Test Item"
        item.chapter = chapter
        chapter.addToItems(item)
        chapterVM.deleteEmpty()
        
        XCTAssertEqual(chapterVM.chapters.count, 1, "Shouldn't delete empty chapters")
        XCTAssertEqual(chapterVM.chapters.first, chapter, "Should keep the non-empty chapter")
    }

    func testDeleteChapter() {
        chapterVM.addChapter()
        chapterVM.deleteChapter(chapterVM.chapters[0])
        XCTAssertTrue(chapterVM.chapters.isEmpty, "Should delete the specified chapter")
    }
    
    func testStreakLevel() {
        let _ = "Топ пример пример пример топ слов топ топ топ слов"
//        itemVM.addItemParagraph(chapter: chapterVM.currentChapter, text: string)
    }
}
