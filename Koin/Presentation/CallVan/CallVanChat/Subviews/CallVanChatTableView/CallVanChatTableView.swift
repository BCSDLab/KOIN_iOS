//
//  CallVanChatTableView.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import Then

final class CallVanChatTableView: UITableView {
    
    // MARK: - Properties
    private var dates: [String] = []
    private var messages: [[CallVanChatMessage]] = []
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .grouped)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(callVanChat: CallVanChat) {
        self.dates = callVanChat.dates
        self.messages = callVanChat.messages
        reloadData()
    }
}

extension CallVanChatTableView {
    
    private func commonInit() {
        allowsSelection = false
        sectionHeaderHeight = 0
        sectionHeaderTopPadding = 0
        sectionFooterHeight = 51
        rowHeight = UITableView.automaticDimension
        
        delegate = self
        dataSource = self
        register(CallVanChatLeftCell.self, forCellReuseIdentifier: CallVanChatLeftCell.identifier)
        register(CallVanChatRightCell.self, forCellReuseIdentifier: CallVanChatRightCell.identifier)
        register(CallVanChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: CallVanChatDateHeaderView.identifier)
    }
}

extension CallVanChatTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CallVanChatDateHeaderView.identifier) as? CallVanChatDateHeaderView else {
            return nil
        }
        headerView.configure(date: dates[section])
        return headerView
    }
}

extension CallVanChatTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        
        if message.isMine {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CallVanChatRightCell.identifier, for: indexPath) as? CallVanChatRightCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CallVanChatLeftCell.identifier, for: indexPath) as? CallVanChatLeftCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            return cell
        }
    }
}
