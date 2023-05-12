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
    
    @ObservedObject var chapterViewModel: ChapterVM
    @ObservedObject var audioPlayer = AudioPlayerVM()
    
    @State private var scrollToBottom = false
    @State private var isFloatingBtnPresented = false
    @State private var isSearchPresented = false
    @State private var isSearchKeyboardPresented = false

    @State private var isStatsPresented = false
    @State private var isKeyboardPresented = true
    
    @State private var wholeSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    @State private var searchText: String = ""
    
    @Namespace var bottomID
    
    private let hieght: CGFloat = UI.screen_height / 2
    
    private let spaceName = "scroll"
    
    var chapter: ChapterMO?
    
    var searchResult: [ChapterMO] {
        if searchText.isEmpty {
            return chapterViewModel.chapters
        } else {
            return chapterViewModel.chapters.filter { chapter in
                chapter.itemsArray.contains { item in

                    item.safeText.localizedCaseInsensitiveContains(searchText)
                    || item.safeText.localizedCaseInsensitiveContains(searchText)
                }
            }

        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Divider()
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ChildSizeReader(size: $scrollViewSize) {
                                VStack {
                                    Spacer(minLength: 16)
                                    HStack(alignment: .center) {
                                        Text("2023")
                                            .chapterYearStyle()
                                    }
                                    
                                    ForEach(searchResult, id: \.self) { chapter in
                                        ChapterCellView(chapter: chapter,
                                                        searchText: searchText,
//                                                        message: $message,
                                                        isKeyboardPresented: $isKeyboardPresented)
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
                        .coordinateSpace(name: spaceName)
                        .onChange(of: chapterViewModel.chapters.last?.safeContainsNumber) {newValue in
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                            chapterViewModel.getConsecutiveDays()
                        }
                        .onChange(of: isKeyboardPresented) { newValue in
//                            if !isSearchPresented {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.linear(duration: 0.1)) {
                                        proxy.scrollTo(bottomID, anchor: .bottom)
                                    }
                                }
//                            }
                        }
                        .onChange(of: isSearchPresented) { newValue in
//                            if isSearchPresented == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.linear(duration: 0.1)) {
                                        proxy.scrollTo(bottomID, anchor: .bottom)
                                    }
                                }
//                            }
                        }
                        .onChange(of: isSearchKeyboardPresented) { newValue in
//                            if isSearchPresented == false {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.linear(duration: 0.1)) {
                                        proxy.scrollTo(bottomID, anchor: .bottom)
                                    }
                                }
//                            }
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
                        }
                        .onAppear {
                            if isKeyboardPresented == true {
                                withAnimation {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                .searchable(text: $searchText, isPresented: $isSearchPresented, keyboard: $isSearchKeyboardPresented)
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
                            
                            InputAccesseryView (
                                chapter: chapterViewModel.getCurrentChapter(),
                                audioPlayer: audioPlayer,
                                chapterVM: chapterViewModel,
                                isKeyboardPresented: $isKeyboardPresented
                            )
                            .transition(.opacity)
                            .shadowInputControl()
                            .background(
                                BlurView(style: .extraLight, intensity: 0.1)
                                    .edgesIgnoringSafeArea(.bottom)
                                    .padding(.top, 10)
                            )
//                            .animation(.linear(duration: 0.2))
                        }
                    }
                })
            }
            .navigationBarItems(
                leading:
                    navLeadingBtn
                        .fullScreenCover(isPresented: $isStatsPresented) {
                            GeometryReader{ proxy in
                                let topEdge = proxy.safeAreaInsets.top
                                StatsView(chapterModel: chapterViewModel, topEdge: topEdge)
                                    .ignoresSafeArea(.all,edges: .top)
                            }
                        }
                ,trailing:
                    navTrailingBtn
            )
//            .navigationBarHidden(isSearchPresented ? true : false)
            .navigationBarTitle("Май", displayMode: .inline)
            .onAppear {
                chapterViewModel.addChapter()
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
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.cW)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(chapterViewModel.getStatusImage())
                )
                .padding(.bottom, 10)
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
