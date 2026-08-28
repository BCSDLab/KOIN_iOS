//
//  FilterItemGroup.swift
//  koin
//
//  Created by 홍기정 on 8/27/26.
//

import Foundation

struct FilterGroupModel {
    
    enum Behavior {
        case single
        case multiple
    }
    
    let title: String
    let description: String?
    let hasAllButton: Bool
    let behavior: Behavior
    private(set) var items: [FilterItemModel] = []
    
    init(
        title: String,
        description: String? = nil,
        hasAllButton: Bool,
        items: [String],
        behavior: Behavior,
    ) {
        self.title = title
        self.description = description
        self.hasAllButton = hasAllButton
        self.behavior = behavior
        
        if hasAllButton {
            self.items.append(FilterItemModel(title: "전체"))
        }
        for item in items {
            self.items.append(FilterItemModel(title: item))
        }
        
        if !self.items.contains(where: { $0.isSelected }) {
            reset()
        }
    }
}

extension FilterGroupModel {
    var selectedItems: [FilterItemModel] {
        items.filter { $0.isSelected }
    }
}

extension FilterGroupModel {
    mutating func reset() {
        deselectAll(except: 0)
    }
    
    mutating func didTap(itemAt index: Int) {
        switch items[index].isSelected {
        case true:
            deselect(itemAt: index)
        case false:
            select(itemAt: index)
        }
    }
}

extension FilterGroupModel {
    mutating private func deselectAll(except selectedIndex: Int) {
        for index in items.indices {
            items[index].isSelected = index == selectedIndex
        }
    }
    
    mutating private func select(itemAt selectedIndex: Int) {
        let selectedItem = items[selectedIndex].title
        let didTapAll = selectedItem == "전체"
        
        if didTapAll {
            deselectAll(except: 0)
            return
        }
        
        switch behavior {
        case .single:
            deselectAll(except: selectedIndex)
        case .multiple:
            if items[0].title == "전체" {
                items[0].isSelected = false
            }
            items[selectedIndex].isSelected = true
        }
    }
    
    mutating private func deselect(itemAt deselectedIndex: Int) {
        let deselectedItem = items[deselectedIndex].title
        let didTapAll = deselectedItem == "전체"
        
        if didTapAll {
            return
        }
        switch behavior {
        case .single:
            return
        case .multiple:
            if 1 < selectedItems.count {
                items[deselectedIndex].isSelected = false
            }
        }
    }
}
