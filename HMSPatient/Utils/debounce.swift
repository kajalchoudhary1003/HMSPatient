//
//  debounce.swift
//  HMSPatient
//
//  Created by pushker yadav on 18/07/24.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Doctor] = []
    @Published var isSearching = false
    private var searchCancellable: AnyCancellable?
    
    init() {
        setupSearch()
    }
    
    private func setupSearch() {
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(with: searchText)
            }
    }
    
    private func performSearch(with searchText: String) {
        if !searchText.isEmpty {
            isSearching = true
            DataController.shared.searchDoctors(query: searchText) { result in
                DispatchQueue.main.async {
                    self.searchResults = result
                }
            }
        } else {
            isSearching = false
            searchResults = []
        }
    }
}
