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
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor(Color.cW)
        searchBar.showsCancelButton = true
        searchBar.tintColor = UIColor(Color.c2)
        searchBar.delegate = context.coordinator
        
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
        Coordinator(text: $text, isFirstResponder: $isFirstResponder, keyboard: $keyboard)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        @Binding var keyboard: Bool

        init(text: Binding<String>, isFirstResponder: Binding<Bool>, keyboard: Binding<Bool>) {
            _text = text
            _isFirstResponder = isFirstResponder
            _keyboard = keyboard
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
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
