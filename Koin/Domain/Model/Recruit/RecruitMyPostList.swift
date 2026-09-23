//
//  RecruitMyPostList.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyPostList {
    var recruits: [RecruitMyPostSummary]

    var totalCount: Int
    let totalPage: Int
    let currentPage: Int
}

extension RecruitMyPostList {
    mutating func delete(id: Int) {
        let previousCount = recruits.count
        recruits.removeAll(where: { $0.id == id })
        if recruits.count < previousCount {
            totalCount -= 1
        }
    }
    
    var hasNextPage: Bool {
        return currentPage < totalPage
    }
    
    var isEmpty: Bool {
        return totalCount == 0
    }
}
