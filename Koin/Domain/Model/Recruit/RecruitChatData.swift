//
//  RecruitChatData.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import Foundation

struct RecruitChatData {
    let chatRoomId: Int
    let chatRoomName: String
    let chatRoomType: RecruitChatRoomType
    let currentMemberCount: Int?
    let maximumMemberCount: Int?
}

enum RecruitChatRoomType: String {
    case direct
    case team
}
