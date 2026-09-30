//
//  ChatListModel+RecruitChat.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import UIKit

extension ChatListModel {
    init(from data: RecruitChatMessages) {
        self.init(
            dates: data.dates,
            messages: data.messages.map { messages in
                messages.map { ChatMessageRowModel(from: $0) }
            }
        )
    }
}

extension ChatMessageRowModel {
    init(from message: RecruitChatMessage) {
        self.init(
            alignment: message.isMine ? .right : .left,
            content: message.isImage ? .image(message.content) : .text(message.content),
            senderNickname: message.userNickname,
            timeText: message.displayTime,
            showsProfile: message.showProfile,
            isLeftUser: false,
            profileImage: message.profileImage.flatMap { UIImage.appImage(asset: $0) }
        )
    }
}
