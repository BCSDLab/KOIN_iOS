//
//  ChatListModel+CallVanChat.swift
//  koin
//
//  Created by 홍기정 on 8/20/26.
//

extension ChatListModel {
    init(from chat: CallVanChat) {
        self.init(
            dates: chat.dates,
            messages: chat.messages.map { messages in
                messages.map { ChatMessageRowModel(from: $0) }
            }
        )
    }
}

extension ChatMessageRowModel {
    init(from message: CallVanChatMessage) {
        self.init(
            alignment: message.isMine ? .right : .left,
            content: message.isImage ? .image(message.content) : .text(message.content),
            senderNickname: message.senderNickname,
            timeText: message.time,
            showsProfile: message.showProfile,
            isLeftUser: message.isLeftUser,
            profileImage: message.profileImage
        )
    }
}
