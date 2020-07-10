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
    
    var query: String = ""
    
    var id: Int {
        return item.id
    }
    
    var tableId: Int {
        return item.tableId
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
    
    func commentDateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    
    var attributedTitle: NSMutableAttributedString {
        let range = (title as NSString).range(of: query)
        let attributedString = NSMutableAttributedString(string:title)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 23/255, green: 92/255, blue: 142/255, alpha: 1.0) , range: range)
        
        return attributedString
    }
    
    var createdAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        return commentDateToString(string_date: item.createdAt ?? dateString)
    }
    
    init(item: SearchResponse.SearchItem, query: String) {
        self.item = item
        self.query = query
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
