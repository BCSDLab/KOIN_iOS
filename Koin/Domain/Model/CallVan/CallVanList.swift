//
//  CallVanList.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import Foundation

struct CallVanList {
    let posts: [CallVanListPost]
    let totalCount: Int
    let currentPage: Int
    let totalPage: Int
}

struct CallVanListPost {
    let postId: Int
    
    let departure: String
    let arrival: String
    
    let departureDate: String
    let departureDay: String
    let departureTime: String
    let authorNickname: String
    
    var currentParticipants: Int
    let maxParticipants: Int
    
    var mainState: CallVanState?
    var subState: CallVanState?
    
    var showChatButton: Bool
    var showCallButton: Bool
}
