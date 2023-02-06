//
//  Search Bar.swift
//  
//
//  Created by Morris Richman on 2/5/23.
//

import Foundation
import SwiftUI
import Combine
import MapKit

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var onCommit: (_ value: String) -> Void

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        var onCommit: (_ value: String) -> Void

        init(text: Binding<String>, onCommit: @escaping (_ value: String) -> Void) {
            _text = text
            self.onCommit = onCommit
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("resign keyboard")
            searchBar.resignFirstResponder()
            onCommit(searchBar.text ?? "")
        }
        
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, onCommit: onCommit)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.becomeFirstResponder()
        searchBar.returnKeyType = .search
        return searchBar
    }
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
