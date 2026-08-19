//
//  LostItemChatHistoryTableView.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import Combine
import UIKit

final class LostItemChatHistoryTableView: UITableView {
    
    // MARK: - Properties
    private var chatSections: [(date: LostItemChatDateInfo, messages: [LostItemChatMessage])] = []
    let imageTapPublisher = PassthroughSubject<String, Never>()

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
        register(LostItemChatImageTableViewCell.self, forCellReuseIdentifier: LostItemChatImageTableViewCell.identifier)
        register(LostItemChatTextTableViewCell.self, forCellReuseIdentifier: LostItemChatTextTableViewCell.identifier)
        register(LostItemChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: LostItemChatDateHeaderView.identifier)
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
    func setChatHistory(item: [LostItemChatMessage]) {
        chatSections = groupMessagesByDate(messages: item)
        reloadData()
        scrollToBottom(animated: false)
    }

    private func groupMessagesByDate(messages: [LostItemChatMessage]) -> [(date: LostItemChatDateInfo, messages: [LostItemChatMessage])] {
        var groupedMessages: [(date: LostItemChatDateInfo, messages: [LostItemChatMessage])] = []
        
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

    func appendNewMessage(_ message: LostItemChatMessage) {
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
extension LostItemChatHistoryTableView: UITableViewDataSource {
    
    private func scrollToBottom(animated: Bool) {
        guard !chatSections.isEmpty else { return }
        
        let lastSection = chatSections.count - 1
        let lastRow = chatSections[lastSection].messages.count - 1
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        
        layoutIfNeeded()
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemChatImageTableViewCell.identifier, for: indexPath) as? LostItemChatImageTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            cell.imageTapPublisher.sink { [weak self] imageUrl in
                self?.imageTapPublisher.send(imageUrl)
            }.store(in: &cell.cancellables)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemChatTextTableViewCell.identifier, for: indexPath) as? LostItemChatTextTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate (헤더)
extension LostItemChatHistoryTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: LostItemChatDateHeaderView.identifier) as? LostItemChatDateHeaderView else {
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
