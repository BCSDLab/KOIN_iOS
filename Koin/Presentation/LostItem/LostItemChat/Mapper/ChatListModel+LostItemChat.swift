import UIKit

extension ChatListModel {
    init(from history: [LostItemChatMessage]) {
        var dates: [String] = []
        var sections: [[ChatMessageRowModel]] = []
        var previousMessage: LostItemChatMessage?

        for message in history {
            let info = message.chatDateInfo
            let date = "\(info.year)년 \(info.month)월 \(info.day)일"
            let isSameDate = dates.last == date
            let showsProfile = !message.isMine && (!isSameDate
                || previousMessage?.isMine != false
                || previousMessage?.senderNickname != message.senderNickname)
            let row = ChatMessageRowModel(
                alignment: message.isMine ? .right : .left,
                content: message.isImage ? .image(message.content) : .text(message.content),
                senderNickname: message.senderNickname,
                timeText: String(format: "%02d:%02d", info.hour, info.minute),
                showsProfile: showsProfile,
                isLeftUser: false,
                profileImage: UIImage.appImage(asset: .callVanProfile0),
                unreadCount: nil
            )
            if isSameDate {
                sections[sections.count - 1].append(row)
            } else {
                dates.append(date)
                sections.append([row])
            }
            previousMessage = message
        }

        self.init(
            dates: dates.reversed(),
            messages: sections.map { Array($0.reversed()) }.reversed()
        )
    }
}
