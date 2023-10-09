//
//  ChapterCellView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

struct ChapterCellView: View {
    let persistenceController = PersistenceController.shared
    let cellWidth = UIScreen.main.bounds.width - 32
    
    @EnvironmentObject var chapterViewModel: ChapterVM
    @EnvironmentObject var quickActionSettings: QuickActionVM
    @EnvironmentObject var popUp: PopUpVM

    @ObservedObject var audioPlayer: AudioPlayerVM
    @ObservedObject var itemViewModel: ItemVM
    
    @Binding var isKeyboardPresented: Bool
    @Binding var scrollToMemoryIndex: UUID? // Добавьте это состояние

    
    private var chapterDate: String
    private var chapterNum: Int
    
    var chapter: ChapterMO
    var searchText: String
    
    var searchResult: [ItemMO] {
        if searchText.isEmpty {
            return itemViewModel.items
        } else {
            return itemViewModel.items.filter {
                $0.safeText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(chapter: ChapterMO,
         searchText: String,
         audioPlayer: AudioPlayerVM,
         isKeyboardPresented: Binding<Bool>,
         scrollToMemoryIndex: Binding<UUID?>) {
        self.chapter = chapter
        self.itemViewModel = ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapter)
        self.chapterDate = chapter.safeDateContent.getFormattedDateString("d MMMM. EEEE")
        self.chapterNum = chapter.safeContainsNumber
        self.searchText = searchText
        self.audioPlayer = audioPlayer
        self._isKeyboardPresented = isKeyboardPresented
        self._scrollToMemoryIndex = scrollToMemoryIndex
    }
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center) {
                Text(chapterDate)
                    .chapterDateStyle()
                Spacer()
            }
            .frame(width: cellWidth)
            .background(Color.c8)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 16) {
                if chapterNum != 0 {
                    ForEach(searchResult, id: \.self) { item in
                        MemoryCellView(memory: item,
                                       audioPlayer: audioPlayer,
                                       delete: { itemViewModel.deleteItem(item) },
                                       edit: {
                                            chapterViewModel.changeMessage(chapter: chapter, itemText: item.safeText)
                                            scrollToMemoryIndex = item.id
                                            isKeyboardPresented = true
                        })
                        .id(item.id)
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
