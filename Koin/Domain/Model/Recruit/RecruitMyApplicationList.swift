//
//  RecruitMyApplicationList.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyApplicationList {
    var recruits: [RecruitMyApplicationSummary]

    let totalCount: Int
    let totalPage: Int
    let currentPage: Int
}

extension RecruitMyApplicationList {
    var hasNextPage: Bool {
        currentPage < totalPage
    }

    var isEmpty: Bool {
        totalCount == 0
    }
}
