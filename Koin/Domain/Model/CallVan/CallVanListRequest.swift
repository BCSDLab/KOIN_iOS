//
//  CallVanListRequest.swift
//  koin
//
//  Created by 홍기정 on 3/15/26.
//

import Foundation

struct CallVanListRequest {
    var mineOrJoined: CallVanMineOrJoined = .all
    var sort: CallVanListSort = .latestDesc
    var state: CallVanRecruitmentState = .all
    var departure: Set<CallVanPlace> = [.all]
    var arrival: Set<CallVanPlace> = [.all]
    var departureKeyword: String? = nil
    var arrivalKeyword: String? = nil
    
    var title: String? = nil
    var page: Int = 1
    var limit: Int = 10
}

enum CallVanListSort: String, CallVanFilterState {
    case departureAsc = "출발시각역순"
    case departureDesc = "출발시각순"
    case latestAsc = "과거순"
    case latestDesc = "최신순"
}

enum CallVanMineOrJoined: String, CallVanFilterState {
    case all = "전체"
    case mine = "내 게시물"
    case joined = "참여중인 게시물"
}
