//
//  ContentView.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 18.02.2023.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    // MARK: - Variables
    
    @EnvironmentObject var quickActionSettings: QuickActionVM
    @EnvironmentObject var popUp: BottomPopUpVM
    @EnvironmentObject var chapterViewModel: ChapterVM
    
    @StateObject var audioPlayer = AudioPlayerVM()
    
    @State private var scrollToBottom = false
    @State private var isFloatingBtnPresented = false
    @State private var isSearchPresented = false
    @State private var isSearchKeyboardPresented = false
    @State private var isChapterAdded = false

    @State private var isStatsPresented = false
    @State private var isKeyboardPresented = true
    @State private var isLoadingPresented = true
    
//    @State private var disableKeyboard = false
    
    @State private var scrollViewSize: CGSize = .zero
    @State private var searchText: String = ""
        
    @Namespace var bottomID
    
    private let hieght: CGFloat = UI.screen_height / 2
    private let spaceName = "main_scroll"
    
    var chapter: ChapterMO?
    
    @State private var scrollToMemoryIndex: UUID? = nil // Добавьте это состояние

    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ChildSizeReader(size: $scrollViewSize) {
                                LazyVStack(spacing: 0) {
                                    Spacer(minLength: 16)
                                    HStack(alignment: .center) {
                                        Text("2023")
                                            .chapterYearStyle()
                                    }
                                    
                                    ForEach(searchText == "" ? chapterViewModel.chapters : chapterViewModel.searchResult, id: \.self) { chapter in
                                        ChapterCellView(chapter: chapter,
                                                        searchText: searchText,
                                                        audioPlayer: audioPlayer,
                                                        isKeyboardPresented: $isKeyboardPresented,
                                                        scrollToMemoryIndex: $scrollToMemoryIndex
                                        )
                                        Spacer(minLength: UI.chapters_spaces)
                                    }
                                    
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: isSearchPresented ? 0 : (isKeyboardPresented ? 50 : 85))
                                        .id(bottomID)
                                }
                                .modifier(FlipModifier())
                                .modifier(FloatingButtonModifier(isFloatingBtnPresented: $isFloatingBtnPresented, spaceName: spaceName))
                            }
                        }
                        .disabled(chapterViewModel.isEditingMode)
                        .coordinateSpace(name: spaceName)
                        .modifier(FlipModifier())
                        .onChange(of: chapterViewModel.isEditingMode) { newValue in
//                            disableKeyboard.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(scrollToMemoryIndex, anchor: .center)
                                }
                            }
                        }
                        .onChange(of: chapterViewModel.chapters.last?.safeContainsNumber) { newValue in
                            if isChapterAdded {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                                isChapterAdded = false
                            }
                            chapterViewModel.getConsecutiveDays()
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            if chapterViewModel.isEditingMode == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.linear(duration: 0.1)) {
                                        proxy.scrollTo(bottomID, anchor: .bottom)
                                    }
                                }
                            }
                        }
//                        .onChange(of: isKeyboardPresented) { newValue in
//                            if chapterViewModel.isEditingMode == false {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    withAnimation(.linear(duration: 0.1)) {
//                                        proxy.scrollTo(bottomID, anchor: .bottom)
//                                    }
//                                }
//                            }
//                        }
                        //.scrollToBottomOnChanges($scrollToBottom, isEditingMode: chapterViewModel.isEditingMode, proxy: proxy, bottomID: bottomID)
                        //.scrollToBottomOnChanges($isKeyboardPresented, isEditingMode: chapterViewModel.isEditingMode, proxy: proxy, bottomID: bottomID)
                        .onTapGesture {
                            self.endEditing()
                        }
                        .edgesIgnoringSafeArea(isKeyboardPresented ? .top : .bottom)
//                        .ignoresSafeArea(disableKeyboard ? .keyboard : [])
                    }
                }
//                .ignoresSafeArea(disableKeyboard ? .keyboard : [])
                .background(Color.theme.cW)
                .keyboardToolbar(view: {
                    VStack(spacing: 0) {
                        if !isSearchPresented {
                            InputAccessoryView (
                                chapter: chapterViewModel.currentChapter,
                                audioPlayer: audioPlayer,
                                isKeyboardPresented: $isKeyboardPresented,
                                isFloatingBtnPresented: $isFloatingBtnPresented,
                                isChapterAdded: $isChapterAdded,
                                scrollToBottom: $scrollToBottom
                            )
                            .transition(.opacity)
                        }
                    }
                })
                .searchable(text: $searchText,
                            isPresented: $isSearchPresented,
                            keyboard: $isSearchKeyboardPresented,
                            chapterViewModel: chapterViewModel)
            }
            .navigationBarItems(
                leading:
                    navLeadingBtn
                    .fullScreenCover(isPresented: $isStatsPresented) {
                        GeometryReader { proxy in
                            let topEdge = proxy.safeAreaInsets.top
                            StatisticsView(chapterModel: chapterViewModel, topEdge: topEdge)
                                .ignoresSafeArea(.all, edges: .top)
                        }
                    }
                ,trailing:
                    navTrailingBtn
            )
            .navigationBarTitle(Date().getFormattedDateString("LLLL"), displayMode: .inline)
            .toolbarBackground(Color.theme.cW, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if chapterViewModel.shouldAddNewChapter() {
                    chapterViewModel.addChapter()
                }
                chapterViewModel.getConsecutiveDays()
            }
        }
        .modifier(PopUpModifier(popUpVM: popUp, type: ""))
    }

    private func endEditing() {
        if chapterViewModel.isEditingMode == false {
            UIApplication.shared.endEditing()
            withAnimation(.easeInOut) {
                isKeyboardPresented = false
            }
        }
    }

    private func beginEditing() {
        UIApplication.shared.beginEditing()
        withAnimation(.easeInOut) {
            isKeyboardPresented = true
        }
    }

    private var navLeadingBtn: some View {
        Button(action: {
            DispatchQueue.main.async {
                self.endEditing()
            }
            self.isStatsPresented.toggle()
        }) {
            Image(chapterViewModel.getStatusImage())
                .padding(.bottom, 14)
        }
    }

    private var navTrailingBtn: some View {
        Button(action: {
            if isSearchPresented {
                DispatchQueue.main.async {
                    self.isSearchPresented.toggle()
                    isSearchKeyboardPresented = false
                    self.endEditing()
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.endEditing()
                        isSearchKeyboardPresented = true
                        self.isSearchPresented.toggle()
                    }
                }
            }
        }) {
            Image(UI.Icons.search)
        }
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content().background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}



//
//                            ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapterViewModel.currentChapter).addItemMedia(chapter: chapterViewModel.currentChapter, attachments: [UIImage(named: "image") ?? UIImage()], type: .photo)
//                            ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapterViewModel.currentChapter).addItemParagraphAndMedia(chapter: chapterViewModel.currentChapter, attachments: [UIImage(named: "image") ?? UIImage()], text: "Some staff that doesn't have any reasons to be rigth here, but it quite long to check spaces in scroll view, so LET IT BE!")
//                            ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapterViewModel.currentChapter).addItemParagraph(chapter: chapterViewModel.currentChapter, text: "В английском языке существует понятие спеллинг - произнесение слова по буквам, потому что иногда хуй проссышь, как именно пишется данное слово. Скажем, light и lite произносятся одинаково, но пишутся по-разному. Поэтому с появлением телефонной связи и раций военные начали придумывать более или менее универсальный алфавит, чтобы произносить буквы заранее определенными словами.")
//                            ItemVM(moc: PersistenceController.shared.viewContext, chapter: chapterViewModel.currentChapter).addMultipleItemsAndMedia(chapter: chapterViewModel.currentChapter, image: UIImage(named: "image") ?? UIImage(), type: .photo, count: 50)
//                            chapterViewModel.deleteAll()
