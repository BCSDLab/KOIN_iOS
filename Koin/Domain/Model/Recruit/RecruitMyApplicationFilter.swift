//
//  RecruitMyApplicationFilter.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyApplicationFilter: Equatable {
    var status: RecruitMyApplicationStatus? = nil
    var sort: RecruitListSort = .latestDescending
    var page: Int = 1
    var limit: Int? = 10
}
