//
//  SearchRowViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/01.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

class SearchRowViewModel: Identifiable {
    private let item: SearchResponse.SearchItem
    
    var id: Int {
        return item.id
    }
    
    var serviceName: String {
        return item.serviceName
    }
    
    var commentCount: Int {
        return item.commentCount ?? 0
    }
    
    var title: String {
        return item.title
    }
    
    var hit: Int {
        return item.hit
    }
    
    var nickname: String {
        return item.nickname
    }
    
    var createdAt: String {
        return item.createdAt
    }
    
    init(item: SearchResponse.SearchItem) {
        self.item = item
    }
    
}
extension SearchRowViewModel: Hashable {
    static func == (lhs: SearchRowViewModel, rhs: SearchRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
