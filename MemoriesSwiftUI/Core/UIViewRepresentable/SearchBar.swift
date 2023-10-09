//
//  SearchBar.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 12.05.2023.
//

import SwiftUI
                                                    
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    @Binding var keyboard: Bool
    @ObservedObject var chapterViewModel: ChapterVM

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor(Color.cW)
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor(Color.c2)
        searchBar.delegate = context.coordinator
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Отмена"
        
        let attributes = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        
        return searchBar
    }

    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        searchBar.text = text
        
        if keyboard {
            searchBar.becomeFirstResponder()
        } else if !isFirstResponder {
            searchBar.resignFirstResponder()
            searchBar.text = ""
        } else {
            searchBar.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFirstResponder: $isFirstResponder, keyboard: $keyboard, chapterViewModel: chapterViewModel)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        @Binding var keyboard: Bool
        @ObservedObject var chapterViewModel: ChapterVM

        init(text: Binding<String>, isFirstResponder: Binding<Bool>, keyboard: Binding<Bool>, chapterViewModel: ChapterVM) {
            _text = text
            _isFirstResponder = isFirstResponder
            _keyboard = keyboard
            self.chapterViewModel = chapterViewModel
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            
            if searchText.isEmpty {
               chapterViewModel.searchAsync(with: "") { [weak self] searchResult in
                   DispatchQueue.main.async {
                       self?.chapterViewModel.searchResult = searchResult
                   }
               }
           } else {
               chapterViewModel.searchAsync(with: searchText) { [weak self] searchResult in
                   DispatchQueue.main.async {
                       self?.chapterViewModel.searchResult = searchResult
                   }
               }
           }
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            keyboard = true
        }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            keyboard = false
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            isFirstResponder = false
        }
        
        func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
            text = ""
        }
    }
}