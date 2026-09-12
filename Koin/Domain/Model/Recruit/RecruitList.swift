//
//  RecruitList.swift
//  koin
//
//  Created by 홍기정 on 8/29/26.
//

import Foundation

struct RecruitList {
    var recruits: [RecruitSummary]
    
    var totalCount: Int
    let totalPage: Int
    let currentPage: Int
}

extension RecruitList {
    mutating func delete(id: Int) {
        recruits.removeAll(where: { $0.id == id })
        totalCount -= 1
    }
}
