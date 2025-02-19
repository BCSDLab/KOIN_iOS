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
    private var chatHistory: [ChatMessage] = []
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
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
        separatorStyle = .none
        register(ChatImageTableViewCell.self, forCellReuseIdentifier: ChatImageTableViewCell.identifier)
        register(ChatTextTableViewCell.self, forCellReuseIdentifier: ChatTextTableViewCell.identifier)
        register(ChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: ChatDateHeaderView.identifier)
    }
    
    func setChatHistory(item: [ChatMessage]) {
        self.chatHistory = item
        reloadData()
        scrollToBottom(animated: false)
    }
    
    func appendNewMessage(_ message: ChatMessage) {
            chatHistory.append(message)
            let newIndexPath = IndexPath(row: chatHistory.count - 1, section: 0)

            performBatchUpdates({
                insertRows(at: [newIndexPath], with: .bottom)
            }) { [weak self] _ in
                self?.scrollToBottom(animated: true)
            }
        }
}

extension ChatHistoryTableView: UITableViewDataSource {
    
    private func scrollToBottom(animated: Bool) {
        guard !chatHistory.isEmpty else { return }
        
        let lastIndexPath = IndexPath(row: chatHistory.count - 1, section: 0)
        DispatchQueue.main.async {
            self.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHistory.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatHistory[indexPath.row]
        if message.isImage {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatImageTableViewCell.identifier, for: indexPath) as? ChatImageTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
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

extension ChatHistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
