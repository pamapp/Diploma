//
//  ChapterCellView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

struct ChapterCellView: View {
    @ObservedObject var itemViewModel: ItemVM
    private var chapterDate: String
    private var chapterNum: Int
    var searchText: String
    
//    @Binding var message: String
    @Binding var isKeyboardPresented: Bool

    
    var searchResult: [ItemMO] {
        if searchText.isEmpty {
            return itemViewModel.items
        } else {
            return itemViewModel.items.filter {
                $0.safeText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    let cellWidth = UIScreen.main.bounds.width - 32

    init(chapter: ChapterMO,
         searchText: String,
//         message: Binding<String>,
         isKeyboardPresented: Binding<Bool>) {
        self.itemViewModel = ItemVM(chapter: chapter)
        self.chapterDate = chapter.safeDateContent.getFormattedDateString(format: "d MMMM. EEEE")
        self.chapterNum = chapter.safeContainsNumber
        self.searchText = searchText
//        self._message = message
        self._isKeyboardPresented = isKeyboardPresented
        itemViewModel.fetchItems()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center) {
                Text(chapterDate)
                    .chapterDateStyle()
                Spacer()
            }.frame(width: cellWidth)
                .background(Color.c8)
                .cornerRadius(12)
            
                VStack(alignment: .leading, spacing: 16) {
                    if chapterNum != 0 {
                        ForEach(searchResult, id: \.self) { item in
                            MemoryCellView(memory: item,
                                           delete: { itemViewModel.deleteItem(item) },
                                           edit: {
//                                                message = item.safeText
                                                isKeyboardPresented = true
                                            })
                            .frame(width: self.cellWidth - 32)
                        }
                    } else {
                        MemoryEmptyCellView()
                            .frame(width: cellWidth - 32)
                    }
                }
                .padding(.vertical, 16)
                .frame(width: cellWidth)
                .background(Color.white)
                .cornerRadius(16)
                .shadowMemoryStatic()
        }
        .frame(width: cellWidth)
    }
}
