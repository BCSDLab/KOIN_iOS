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
        register(ChatTextTableViewCell.self, forCellReuseIdentifier: ChatTextTableViewCell.identifier)
        //   register(ChatImageTableViewCell.self, forCellReuseIdentifier: ChatImageTableViewCell.identifier)
        register(ChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: ChatDateHeaderView.identifier)
    }
    
    func setChatHistory(item: [ChatMessage]) {
        self.chatHistory = item
        reloadData()
    }
}

extension ChatHistoryTableView: UITableViewDataSource {
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear // 배경 투명하게 설정
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8 // 셀 간격 설정
    }
}
