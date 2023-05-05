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
    
    @State var scrollToBottom = false
    @State var showFloatingButton = false

    
    @State private var searchText: String = ""
    @State private var isSearchPresented = false
    @State var isKeyboardPresented = true
    @State var showStats = false
    
    @Namespace var bottomID
    
    let hieght: CGFloat = UIScreen.main.bounds.height / 2
    
    let spaceName = "scroll"

    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
    
    var chapter: ChapterMO?
    
    var searchResult: [ChapterMO] {
        if searchText.isEmpty {
            return chapterViewModel.chapters
        } else {
            return chapterViewModel.chapters.filter { chapter in
                chapter.itemsArray.contains { item in
                    item.safeText.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    // MARK: - Body
    
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
                                        ChapterCellView(chapter: chapter, searchText: searchText)
                                        Spacer(minLength: 32)
                                    }
                                    //когда их мало, не работает
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 54)
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
                                                showFloatingButton = false
                                            }
                                        } else {
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation {
                                                    showFloatingButton = true
                                                }
//                                            }
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.linear(duration: 0.1)) {
                                    proxy.scrollTo(bottomID, anchor: .bottom)
                                }
                            }
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
                .background(Color.cW)
                .keyboardToolbar(view: {
                    VStack(spacing: 0) {
                        if showFloatingButton {
                            HStack {
                                Spacer()
                                Button(action: {
                                    scrollToBottom.toggle()
                                }, label: {
                                    Image("scroll-to-bottom")
                                        .font(.system(size: 25))
                                        .foregroundColor(.black)
                                    
                                })
                                .transition(.scale)
                                .padding(.trailing, 26)
                                .padding(.bottom, 26)
                            }
                            
                        }
                        
                        InputAccesseryView (
                            chapter: chapterViewModel.getCurrentChapter(), audioPlayer: audioPlayer, chapterVM: chapterViewModel, isKeyboardPresented: $isKeyboardPresented
                        )
                        .shadowInputControl()
                        .background(
                            BlurView(style: .extraLight, intensity: 0.1)
                                .edgesIgnoringSafeArea(.bottom)
                                .padding(.top, 10)
                        )
                        .onTapGesture {
                            withAnimation {
                                isKeyboardPresented = true
                            }
                        }
                    }
                })
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        self.showStats.toggle()
                        DispatchQueue.main.async {
                            self.endEditing()
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color.cW)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(chapterViewModel.getStatusImage())
                            )
                            .padding(.bottom, 10)
                    }
                    .fullScreenCover(isPresented: $showStats) {
                        GeometryReader{ proxy in
                            let topEdge = proxy.safeAreaInsets.top
//
                            StatsView(chapterModel: chapterViewModel, topEdge: topEdge)
                                .ignoresSafeArea(.all,edges: .top)
                        }
                    },
                trailing:
                    Button(action: {
                        self.isSearchPresented.toggle()
                    }) {
                        Image("search")
                    }
            )
            .navigationBarTitle("Апрель", displayMode: .inline)
            .onAppear {
//                chapterViewModel.addTestSet()
                chapterViewModel.addChapter()
//                chapterViewModel.deleteAll()
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
}


private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
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

//Drafts:
//                    .onReceive(keyboardPublisher) { value in
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            withAnimation(.easeInOut) {
//                                isKeyboardPresented = value
//                            }
//                        }
//                    }
//                chapter = chapterViewModel.getCurrentChapter()
//               UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
//                chapterViewModel.deleteLast()
//                chapterViewModel.deleteAll()
//            .searchable(text: $searchText) { isSearching in
//                // Метод вызывается при начале или завершении поиска
//                if !isSearching {
//                    // Скрыть строку поиска при завершении поиска
//                    self.isSearchPresented = false
//                }
//            }
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            UIApplication.shared.windows.first?.rootViewController?.view.endEditing(true)
//                            UIApplication.shared.windows.first?.rootViewController?.view.subviews.last?.becomeFirstResponder()
//                        }
//                    }
//                    .onAppear {
////                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            isKeyboardPresented = true
////                        }
//                    }
//VStack {
//    Spacer()
//    BlurView(style: .extraLight, intensity: 0.15)
//        .frame(height: 85) // надо считать
//}
//.edgesIgnoringSafeArea(.bottom)
//
//if isKeyboardPresented {
//    withAnimation {
//        Color.black
//            .opacity(0.2)
//            .edgesIgnoringSafeArea(.all)
//            .onTapGesture {
//                self.endEditing()
//            }
//            .scrollDismissesKeyboard(.interactively)
////                            .animation(.linear(duration: 2), value: true)
//    }
//}
//
//VStack {
//    Spacer()
////                    InputAccessory()
//    InputAccesseryView(viewModel: viewItemModel, isKeyboardPresented: $isKeyboardPresented, chapter: viewModel.getCurrentChapter())
//        .shadow(color: isKeyboardPresented ? .chapterShadowColor : .clear, radius: 20)
//        .onReceive(keyboardPublisher) { value in
//           isKeyboardPresented = value
//            print(isKeyboardPresented)
//        }
//}

extension View {
    func searchable(text: Binding<String>, isPresented: Binding<Bool>) -> some View {
        overlay(
            Group {
                if isPresented.wrappedValue {
                    VStack {
                        SearchBar(text: text, isFirstResponder: isPresented)
                        Spacer()
                    }

                } else {
                    EmptyView()
                }
            }
        )
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
//        searchBar.barPosition = .top
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        searchBar.text = text
        if isFirstResponder {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFirstResponder: $isFirstResponder)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool

        init(text: Binding<String>, isFirstResponder: Binding<Bool>) {
            _text = text
            _isFirstResponder = isFirstResponder
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            isFirstResponder = false
        }
    }
}
