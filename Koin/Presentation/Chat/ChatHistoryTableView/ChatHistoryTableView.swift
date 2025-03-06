//
//  ChatHistoryTableView.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import Combine
import UIKit

final class ChatHistoryTableView: UITableView {
    
    // MARK: - Properties
    private var chatSections: [(date: ChatDateInfo, messages: [ChatMessage])] = []
    let imageTapPublisher = PassthroughSubject<UIImage, Never>()

    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style = .grouped) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        delegate = self
        dataSource = self
        sectionHeaderTopPadding = 0
        separatorStyle = .none
        register(ChatImageTableViewCell.self, forCellReuseIdentifier: "ChatImageTableViewCell")
        register(ChatTextTableViewCell.self, forCellReuseIdentifier: ChatTextTableViewCell.identifier)
        register(ChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: ChatDateHeaderView.identifier)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        for section in 0..<self.numberOfSections {
            if let header = self.headerView(forSection: section) {
                let sectionRect = self.rect(forSection: section)
                var headerFrame = header.frame
                headerFrame.origin.y = sectionRect.origin.y
                header.frame = headerFrame
            }
        }
    }

    // MARK: - 데이터 세팅
    func setChatHistory(item: [ChatMessage]) {
        chatSections = groupMessagesByDate(messages: item)
        reloadData()
        scrollToBottom(animated: false)
    }

    private func groupMessagesByDate(messages: [ChatMessage]) -> [(date: ChatDateInfo, messages: [ChatMessage])] {
        var groupedMessages: [(date: ChatDateInfo, messages: [ChatMessage])] = []
        
        for message in messages {
            if let lastSection = groupedMessages.last, lastSection.date.day == message.chatDateInfo.day {
                // 같은 날짜(day)면 기존 섹션에 추가
                groupedMessages[groupedMessages.count - 1].messages.append(message)
            } else {
                // 새로운 날짜(day)면 새 섹션 추가
                groupedMessages.append((date: message.chatDateInfo, messages: [message]))
            }
        }
        
        return groupedMessages
    }

    func appendNewMessage(_ message: ChatMessage) {
        if let lastSection = chatSections.last, lastSection.date.day == message.chatDateInfo.day {
            // 같은 날짜(day)면 기존 섹션에 메시지 추가
            chatSections[chatSections.count - 1].messages.append(message)
        } else {
            // 새로운 날짜(day)면 새 섹션 추가
            chatSections.append((date: message.chatDateInfo, messages: [message]))
        }
        
        DispatchQueue.main.async {
            self.reloadData()
            self.scrollToBottom(animated: true)
        }
    }


}

// MARK: - UITableViewDataSource
extension ChatHistoryTableView: UITableViewDataSource {
    
    private func scrollToBottom(animated: Bool) {
        guard !chatSections.isEmpty else { return }
        
        let lastSection = chatSections.count - 1
        let lastRow = chatSections[lastSection].messages.count - 1
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        
        DispatchQueue.main.async {
            self.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSections[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatSections[indexPath.section].messages[indexPath.row]
        
        if message.isImage {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageTableViewCell", for: indexPath) as? ChatImageTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            cell.imageTapPublisher.sink { [weak self] image in
                self?.imageTapPublisher.send(image)
            }.store(in: &cell.cancellables)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTextTableViewCell.identifier, for: indexPath) as? ChatTextTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate (헤더)
extension ChatHistoryTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChatDateHeaderView.identifier) as? ChatDateHeaderView else {
            return nil
        }
        header.configure(date: chatSections[section].date)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
