//
//  StoreViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var data = [StoreRowViewModel]()
    let storeFetcher: StoreFetcher = StoreFetcher()

    var result = PassthroughSubject<[StoreRowViewModel], Never>()

    @Published var category: String = ""

    private var disposables = Set<AnyCancellable>()

    deinit {
        disposables.removeAll()
    }

    func load() {
        self.storeFetcher.getStore()
                .map { response in
                    response.shops.map {
                        StoreRowViewModel(item: $0)
                    }
                }
                .map(Array.removeDuplicates)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { value in
                    switch value {
                    case .failure:
                        self.data = []
                    case .finished:
                        break
                    }
                }, receiveValue: { stores in
                    self.data = stores
                    self.result.send(stores)
                })
                .store(in: &disposables)
    }
}
