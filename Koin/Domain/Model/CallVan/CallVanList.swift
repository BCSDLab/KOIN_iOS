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
    
    let currentParticipants: Int
    let maxParticipants: Int
    
    let mainState: CallVanState?
    let subState: CallVanState?
    
    let showChatButton: Bool
    let showCallButton: Bool    
}
