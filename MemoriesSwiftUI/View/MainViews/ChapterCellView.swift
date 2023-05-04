//
//  ChapterCellView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI

struct ChapterCellView: View {
    @ObservedObject var itemViewModel: ItemViewModel
    private var chapterDate: String
    private var chapterNum: Int
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
    
    let cellWidth = UIScreen.main.bounds.width - 32
    
    init(chapter: ChapterMO, searchText: String) {
        self.itemViewModel = ItemViewModel(chapter: chapter)
        self.chapterDate = chapter.safeDateContent.getFormattedDateString(format: "d MMMM. EEEE")
        self.chapterNum = chapter.safeContainsNumber
        self.searchText = searchText
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
                        MemoryCellView(memory: item)
                            .frame(width: cellWidth - 32)
                            .gesture(
                                DragGesture()
                                    .onEnded { value in
                                        if value.translation.width < -50 {
                                            withAnimation {
                                                itemViewModel.deleteItem(item: item)
                                            }
                                        }
                                    }
                            )
                        
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
        .onAppear {
//            itemViewModel.deleteAll()
//            viewModel.deleteLast()
//            viewModel.addItem(chapter: chapter)
        }
    }
}

struct SwipeItem<Content: View, Left: View, Right: View>: View {
    var content: () -> Content
    var left: () -> Left
    var right: () -> Right
//    var itemHeight: CGFloat
    
    @State var hoffset: CGFloat = 0
    @State var anchor: CGFloat = 0
    
    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 3 }
    var swipeThreshold: CGFloat { screenWidth / 15 }
    
    @State var rightPast = false
    @State var leftPast = false
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder left: @escaping () -> Left,
         @ViewBuilder right: @escaping () -> Right) {
        self.content = content
        self.left = left
        self.right = right
//        self.itemHeight = itemHeight
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    hoffset = anchor + value.translation.width
                    
                    if abs(hoffset) > anchorWidth {
                        if leftPast {
                            hoffset = anchorWidth
                        } else if rightPast {
                            hoffset = -anchorWidth
                        }
                    }
                    
                    if anchor > 0 {
                        leftPast = hoffset > anchorWidth - swipeThreshold
                    } else {
                        leftPast = hoffset > swipeThreshold
                    }
                    
                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeThreshold
                    } else {
                        rightPast = hoffset < -swipeThreshold
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else if leftPast {
                        anchor = anchorWidth
                    } else {
                        anchor = 0
                    }
                    
                    hoffset = anchor
                }
            }
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                left()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
                
                content()
                    .frame(width: geo.size.width)
                    .zIndex(0)
                        
                
                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
            }
        }
        .offset(x: -anchorWidth + hoffset)
        .frame(height: 300)
        .contentShape(Rectangle())
        .gesture(drag)
        .clipped()
    }
}


//                        SwipeItem(content: {
//                            MemoryCellView(memory: item)
//                                .frame(width: cellWidth - 32)
//                                 },
//                                 left: {
//                                    ZStack {
//                                        Rectangle()
//                                            .fill(Color.orange)
//
//                                        Image(systemName: "pencil.circle")
//                                            .foregroundColor(.white)
//                                            .font(.largeTitle)
//                                    }
//                                 },
//                                 right: {
//                                    ZStack {
//                                        Rectangle()
//                                            .fill(Color.red)
//
//                                        Image(systemName: "trash.circle")
//                                            .foregroundColor(.white)
//                                            .font(.largeTitle)
//                                    }
//                                 })


//                            .gesture(
//                                DragGesture()
//                                    .onEnded { value in
//                                        if value.translation.width < -100 {
//                                            withAnimation {
//                                                itemViewModel.deleteItem(item: item)
//                                            }
//                                        }
//                                    }
//                            )
    
