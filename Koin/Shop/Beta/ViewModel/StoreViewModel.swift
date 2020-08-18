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
    
    @Published var previousShowList = [StoreRowViewModel]()
    
    @Published var showList = [StoreRowViewModel]()
    
    let storeFetcher: StoreFetcher = StoreFetcher()

    var result = PassthroughSubject<[StoreRowViewModel], Never>()
    
    var changeCategory = PassthroughSubject<String, Never>()

    @Published var category: String = "" {
        didSet {
            if(!oldValue.isEmpty) {
                self.revert()
                if(!category.isEmpty) {
                    self.filter()
                }
                changeCategory.send(category)
            } else {
                self.filter()
                changeCategory.send(category)
            }
        }
    }

    private var disposables = Set<AnyCancellable>()

    deinit {
        disposables.removeAll()
    }
    
    func filter() {
         
        self.showList.removeAll { d in
            return d.category != self.category
        }
        
        self.result.send(self.showList)
    }
    
    func revert() {
        
        self.data.forEach { d in
            if (!self.showList.contains(d)) {
                self.showList.append(d)
            }
        }
        
        self.showList = self.showList.sorted(by: {$0.id < $1.id})
        
        self.result.send(self.showList)
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
                    /*var filteredResult: [StoreRowViewModel] = []
                    
                    stores.forEach { s in
                        if(s.category == self.category || self.category == "") {
                            filteredResult.append(s)
                        }
                    }*/
                    
                    self.data = stores
                    self.showList = stores
                    self.result.send(stores)
                })
                .store(in: &disposables)
    }
}
