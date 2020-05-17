//
//  SearchViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/28.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var dataSource: [SearchRowViewModel] = []
    
    private let searchFetcher: SearchFetchable
    private var disposables = Set<AnyCancellable>()
    
    init(
        searchFetcher: SearchFetchable
    ) {
        self.searchFetcher = searchFetcher
    }
    
    func fetchSearch() {
        print(query)
        searchFetcher.searchArticle(forQuery: query)
            .map { response in
                response.articles.map(SearchRowViewModel.init)
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
                case .finished:
                break
            }
    },
        receiveValue: { [weak self] result in
            guard let self = self else { return }
            self.dataSource = result
    })
            .store(in: &disposables)
    }
}
