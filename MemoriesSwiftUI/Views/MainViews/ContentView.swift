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
    @EnvironmentObject var chapterViewModel: ChapterVM
    
    @ObservedObject var audioPlayer = AudioPlayerVM()
    
    @State private var scrollToBottom = false
    @State private var isFloatingBtnPresented = false
    @State private var isSearchPresented = false
    @State private var isSearchKeyboardPresented = false

    @State private var isStatsPresented = false
    @State private var isKeyboardPresented = true
    
    @State private var isLoadingPresented = true

    @State private var wholeSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    @State private var searchText: String = ""
    
    @Namespace var bottomID
    
    private let hieght: CGFloat = UI.screen_height / 2
    
    private let spaceName = "main_scroll"
    
    var chapter: ChapterMO?
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ChildSizeReader(size: $scrollViewSize) {
                                ZStack {
                                    VStack {
                                        Spacer(minLength: 16)
                                        HStack(alignment: .center) {
                                            Text("2023")
                                                .chapterYearStyle()
                                        }
                                        
                                        ForEach(searchText == "" ? chapterViewModel.chapters : chapterViewModel.searchResult, id: \.self) { chapter in
                                            ChapterCellView(chapter: chapter,
                                                            searchText: searchText,
                                                            isKeyboardPresented: $isKeyboardPresented)
                                            .environmentObject(chapterViewModel)
                                            .environmentObject(quickActionSettings)

                                            Spacer(minLength: UI.chapters_spaces)
                                        }
                                        
                                        //когда их мало, не работает
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: isSearchPresented ? 0 : 54)
                                            .id(bottomID)
                                    }
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.preference(
                                                key: ViewOffsetKey.self,
                                                value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                                            )
                                        }
                                    )
                                    .onPreferenceChange(
                                        ViewOffsetKey.self,
                                        perform: { value in
                                            if value >= scrollViewSize.height - wholeSize.height - UIScreen.main.bounds.height * 3 {
                                                withAnimation {
                                                    isFloatingBtnPresented = false
                                                }
                                            } else {
                                                withAnimation {
                                                    isFloatingBtnPresented = true
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .coordinateSpace(name: spaceName)
                        .onChange(of: chapterViewModel.chapters.last?.safeContainsNumber) {newValue in
                            withAnimation(.linear(duration: 0.1)) {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                            chapterViewModel.getConsecutiveDays()
                        }
                        .onChange(of: isKeyboardPresented) { newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isSearchPresented) { newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
                        }
                        .onAppear {
                            if isKeyboardPresented == true {
                                withAnimation(.linear(duration: 0.1)) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        proxy.scrollTo(bottomID, anchor: .bottom)
                                    }
                                }
                            } else {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                        .onTapGesture {
                            self.endEditing()
                        }
                    }
                }
                .background(Color.cW)
                .keyboardToolbar(view: {
                    VStack(spacing: 0) {
                        if !isSearchPresented {
                            if isFloatingBtnPresented {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        scrollToBottom.toggle()
                                    }, label: {
                                        Image(UI.Buttons.scroll_to_bottom)
                                            .font(.system(size: 25))
                                            .foregroundColor(.black)
                                        
                                    })
                                    .transition(.scale)
                                    .padding(.trailing, 26)
                                    .padding(.bottom, 26)
                                }
                            }
                            
                            InputAccessoryView (
                                chapter: chapterViewModel.currentChapter,
                                audioPlayer: audioPlayer,
                                chapterVM: chapterViewModel,
                                isKeyboardPresented: $isKeyboardPresented
                            )
                            .environmentObject(chapterViewModel)
                            .transition(.opacity)
                            .shadowInputControl()
                            .background(
                                BlurView(style: .extraLight, intensity: 0.1)
                                    .edgesIgnoringSafeArea(.bottom)
                                    .padding(.top, 10)
                            )
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
                        GeometryReader{ proxy in
                            let topEdge = proxy.safeAreaInsets.top
                            StatsView(chapterModel: chapterViewModel, topEdge: topEdge)
                                .ignoresSafeArea(.all,edges: .top)
                                .environmentObject(quickActionSettings)
                        }
                    }
                ,trailing:
                    navTrailingBtn
            )
            .navigationBarTitle("Май", displayMode: .inline)
            .onAppear {
                if chapterViewModel.shouldAddNewChapter() {
                    chapterViewModel.addChapter()
                }
                chapterViewModel.getConsecutiveDays()
            }
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
        withAnimation(.easeInOut) {
            isKeyboardPresented = false
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
