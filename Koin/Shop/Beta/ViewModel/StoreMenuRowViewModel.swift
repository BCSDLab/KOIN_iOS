//
//  StoreMenuRowViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class StoreMenuRowViewModel: Identifiable {
    var item: Menus

    init(item: Menus) {
        self.item = item
    }

    var id: Int {
        return item.id
    }

    var name: String {
        return item.name
    }

    var priceType: [PriceType] {
        return item.priceType
    }

}

extension StoreMenuRowViewModel: Hashable {
    static func ==(lhs: StoreMenuRowViewModel, rhs: StoreMenuRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
