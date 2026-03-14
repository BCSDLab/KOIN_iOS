//
//  CallVanListRequest.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanListRequest {
    var sort: CallVanListSort = .latestDesc
    var state: CallVanRecruitmentState = .all
    var departure: [CallVanPlace] = [.all]
    var arrival: [CallVanPlace] = [.all]
    var departureKeyword: String? = nil
    var arrivalKeyword: String? = nil
    
    var title: String?
    var page: Int = 1
    var limit: Int = 10
}

enum CallVanListSort: String, CallVanFilterState {
    case departureAsc = "출발시각역순"
    case departureDesc = "출발시각순"
    case latestAsc = "과거순"
    case latestDesc = "최신순"
}
