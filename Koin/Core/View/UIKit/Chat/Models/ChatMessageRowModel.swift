//
//  ChatMessageRowModel.swift
//  koin
//
//  Created by 홍기정 on 8/20/26.
//

import UIKit

struct ChatMessageRowModel {
    let alignment: ChatMessageAlignment
    let content: ChatMessageContent
    let senderNickname: String
    let timeText: String
    let showsProfile: Bool
    let isLeftUser: Bool
    let profileImage: UIImage?
}

enum ChatMessageAlignment {
    case left
    case right
}

enum ChatMessageContent {
    case text(String)
    case image(String)
}
