//
//  TempCommunityRowViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/12.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
/*
struct TempCommunityRowViewModel: Identifiable {
    private var item: TempArticle
    func dateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    
    var id: Int {
        return item.id
    }
    
    var title: String {
        return item.title
    }
    
    var commentCount: Int {
        return item.commentCount ?? 0
    }
    
    var hit: Int {
        return item.hit
    }
    
    var nickname: String {
        return item.nickname
    }
    
    var createdAt: String {
        return dateToString(string_date: item.createdAt)
    }
    
    init(item: TempArticle) {
        self.item = item
    }
}

extension TempCommunityRowViewModel: Hashable {
    static func == (lhs: TempCommunityRowViewModel, rhs: TempCommunityRowViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
*/
