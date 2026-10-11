//
//  FilterItemModel.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import Foundation

struct FilterItemModel {
    
    let title: String
    var isSelected: Bool
    
    init(
        title: String,
        isSelected: Bool = false
    ) {
        self.title = title
        self.isSelected = isSelected
    }
}
