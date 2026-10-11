//
//  RecruitMyPostFilter.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import Foundation

struct RecruitMyPostFilter: Equatable {
    var state: RecruitState = .all
    var sort: RecruitListSort = .latestDescending
    var page: Int = 1
    var limit: Int? = 10
}
