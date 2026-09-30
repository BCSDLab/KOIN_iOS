//
//  RecruitListFilter.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitListFilter {
    var keyword: String?
    var state: RecruitState = .all
    var sort: RecruitListSort = .latestDescending
    var category: Set<RecruitCategory> = .init()
    var meetingType: RecruitMeetingType? = nil
    
    var page: Int = 1
    var limit: Int? = 10
}

extension RecruitListFilter {
    var nonDefaultItems: [String] {
        var items: [String] = []
        if state != .all {
            items.append(state.rawValue)
        }
        if sort != .latestDescending {
            items.append(sort.rawValue)
        }
        category.forEach {
            items.append($0.rawValue)
        }
        if let meetingType {
            items.append(meetingType.rawValue)
        }
        return items
    }
    
    mutating func remove(item rawValue: String) {
        if let _ = RecruitState(rawValue: rawValue) {
            self.state = .all
            return
        }
        if let _ = RecruitListSort(rawValue: rawValue) {
            self.sort = .latestDescending
            return
        }
        if let category = RecruitCategory(rawValue: rawValue) {
            self.category.remove(category)
            return
        }
        if let _ = RecruitMeetingType(rawValue: rawValue) {
            self.meetingType = nil
            return
        }
    }
}
