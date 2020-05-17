//
//  CircleViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class CircleViewModel: ObservableObject {
    @Published var data = [CircleCellViewModel]()
    let circleFetcher: CircleFetcher = CircleFetcher()
    
    var page: Int = 0
    
    @Published var category: String = ""
    
    @Published var progress: Bool = true
    
    private var disposables = Set<AnyCancellable>()
    
    deinit {
        disposables.removeAll()
    }
    
    func load() {
        progress = true
        page += 1
        self.circleFetcher.getCircle(page: page)
            .map{ response in
                response.circles.map {
                    CircleCellViewModel(item: $0)
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
    }, receiveValue: { circles in
        self.data += circles
        self.progress = false
    })
        .store(in: &disposables)
    }
}

