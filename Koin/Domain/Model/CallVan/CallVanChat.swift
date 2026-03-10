//
//  CallVanChat.swift
//  koin
//
//  Created by 홍기정 on 3/8/26.
//

import UIKit

struct CallVanChat {
    let roomName: String
    let dates: [String]
    let messages: [[CallVanChatMessage]]
}

struct CallVanChatMessage {
    let userId: Int
    let senderNickname: String
    let content: String
    let date: String
    var time: String
    let isImage: Bool
    let isLeftUser: Bool
    let isMine: Bool
    let index: Int
    let showProfile: Bool
    let profileImage: UIImage?
}
