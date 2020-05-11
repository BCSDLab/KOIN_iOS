//
//  CircleCellViewModel.swift
//  
//
//  Created by 정태훈 on 2020/05/09.
//

import Foundation
import SwiftUI
import Combine

class CircleCellViewModel: Identifiable {
    var item: CircleData
    let circleFetcher: CircleFetcher = CircleFetcher()
    
    
    
    init(item: CircleData) {
        self.item = item
    }
    
    var id: Int {
        return item.id
    }
    
    var title: String {
        return item.name
    }
    
    var content: String {
        return item.line_description
    }
    
    var logoImageUrl: String {
        return item.logo_url ?? ""
    }
    
    var backgroudImageUrl: String {
        return item.background_img_url ?? ""
    }
    
    var category: String {
        return item.category
    }
}

extension CircleCellViewModel: Hashable {
    static func == (lhs: CircleCellViewModel, rhs: CircleCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
