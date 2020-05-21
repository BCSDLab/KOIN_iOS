//
//  StoreRowViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class StoreRowViewModel: Identifiable {
    var item: Store
    
    init(item: Store) {
        self.item = item
    }
    
    var id: Int {
        return item.id
    }
    
    var category: String {
        return item.category
    }
    
    var storeName: String {
        return item.name
    }
    
    var isDelivery: Bool {
        return item.delivery
    }
    
    var isCard: Bool {
        return item.payCard
    }
    
    var isBank: Bool {
        return item.payBank
    }
    
    var isEvent: Bool {
        return item.isEvent
    }
    
}

extension StoreRowViewModel: Hashable {
    static func == (lhs: StoreRowViewModel, rhs: StoreRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
