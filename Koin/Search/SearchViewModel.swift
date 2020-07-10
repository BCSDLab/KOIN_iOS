//
//  SearchViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/28.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class SearchViewModel: ObservableObject {
    static let clearCode = String.Element(Unicode.Scalar(7))
    let clearPublisher = PassthroughSubject<Bool, Never>()
    
    @Published var query: String = ""
    @Published var dataSource: [SearchRowViewModel] = []
    @State var isSearched: Bool = false
    
    private let searchFetcher: SearchFetchable
    private var disposables = Set<AnyCancellable>()
    
    var searchResult = PassthroughSubject<Bool, Never>()
    
    init(
        searchFetcher: SearchFetchable
    ) {
        self.searchFetcher = searchFetcher
    }
    
    func clear() {
        self.query = ""
        self.clearPublisher.send(true)
    }
    
    func fetchSearch(query: String) {
        self.query = query
        searchFetcher.searchArticle(forQuery: query)
            .map { response in
                response.articles.map {
                    return SearchRowViewModel(item: $0, query: self.query)
                }
        }
        .print()
        .map(Array.removeDuplicates)
        .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { [weak self] value in
            guard let self = self else { return }
            switch value {
                case .failure:
                    self.dataSource = []
                self.searchResult.send(false)
                case .finished:
                break
            }
    },
        receiveValue: { [weak self] result in
            guard let self = self else { return }
            var list: [SearchRowViewModel] = []
            for r in result {
                if (r.tableId == 5 || r.tableId == 7) {
                     list.append(r)
                }
            }
            self.dataSource = list
            self.isSearched = true
            self.searchResult.send(true)
    })
            .store(in: &disposables)
    }
}
