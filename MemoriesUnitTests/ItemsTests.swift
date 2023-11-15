////
////  ItemsTests.swift
////  MemoriesSwiftUITests
////
////  Created by Alina Potapova on 23.05.2023.
////
//
//import XCTest
//import CoreData
//@testable import MemoriesSwiftUI
//
//class ItemsTests: XCTestCase {
//    var chapter: ChapterMO!
//    var itemVM: ItemDataService!
//    var coreDataStack: CoreDataStack!
//    var inputImage: UIImage!
//
//    override func setUp() {
//        super.setUp()
//        coreDataStack = TestCoreDataStack()
//        chapter = ChapterDataService.init(moc: coreDataStack.mainContext).currentChapter
//        itemVM = ItemDataService(moc: coreDataStack.mainContext, chapter: chapter)
//        inputImage = UIImage(systemName: "person")
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        itemVM = nil
//        coreDataStack = nil
//        chapter = nil
//        inputImage = nil
//    }
//
//    func testAddItemParagraph() {
//        itemVM.addItemParagraph(chapter: chapter, text: "Test Text")
//        XCTAssertNotNil(itemVM.items[0], "Memory should not be nil")
//        XCTAssertNotNil(itemVM.items[0].id, "Id should not be nil")
//        XCTAssertEqual(itemVM.items[0].safeText, "Test Text" , "Texts should be equal")
//    }
//
//    func testAddItemMedia() {
//        itemVM.addItemMedia(chapter: chapter, attachments: [inputImage.pngData()].compactMap { $0 }, type: ItemType.photo.rawValue)
//        XCTAssertNotNil(itemVM.items[0], "Memory should not be nil")
//        XCTAssertNotNil(itemVM.items[0].id, "Id should not be nil")
//        XCTAssertEqual(itemVM.items[0].mediaAlbum?.attachmentsArray.first?.data, inputImage.pngData(), "Data should be equal")
//    }
//    
//    func testAddItemParagraphAndMedia() {
//        itemVM.addItemParagraphAndMedia(chapter: chapter, attachments: [inputImage.pngData()].compactMap { $0 }, text: "Test Item")
//        XCTAssertNotNil(itemVM.items[0], "Memory should not be nil")
//        XCTAssertNotNil(itemVM.items[0].id, "Id should not be nil")
//        XCTAssertEqual(itemVM.items[0].mediaAlbum?.attachmentsArray.first?.data, inputImage.pngData(), "Data should be equal")
//    }
//    
//    func testMemorySentiment() {
//        itemVM.addItemParagraph(chapter: chapter, text: "Все плохо")
//        let expectation = XCTestExpectation(description: "SetMemorySentiment")
//        itemVM.setMemorySentiment(itemVM.items[0])
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            XCTAssertNotNil(self.itemVM.items[0].sentiment, "Sentiment should not be nil")
//            XCTAssertEqual(self.itemVM.items[0].sentiment, "negative", "Sentiment should be equal")
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 2.0)
//    }
//    
//    func testEditItem() {
//        itemVM.addItemParagraph(chapter: chapter, text: "Test Text")
//        itemVM.editItem(itemVM.items[0], text: "Test Text 2")
//        
//        XCTAssertEqual(itemVM.items[0].safeText, "Test Text 2", "Texts should be equal")
//    }
//    
//    func testDeleteItem() {
//        itemVM.addItemParagraph(chapter: chapter, text: "Test Text")
//        itemVM.deleteItem(itemVM.items[0])
//        
//        XCTAssertTrue(itemVM.items.isEmpty)
//    }
//}
