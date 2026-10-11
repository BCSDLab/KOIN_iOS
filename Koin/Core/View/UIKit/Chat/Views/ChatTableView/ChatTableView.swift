//
//  ChatTableView.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import Combine
import Then

final class ChatTableView: UITableView {
    
    // MARK: - Properties
    let imageTappedPublisher = PassthroughSubject<String, Never>()
    private var dates: [String] = []
    private var messages: [[ChatMessageRowModel]] = []
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .grouped)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(model: ChatListModel) {
        self.dates = model.dates
        self.messages = model.messages
        reloadData()
    }
}

extension ChatTableView {
    
    private func commonInit() {
        allowsSelection = false
        sectionHeaderHeight = 0
        sectionHeaderTopPadding = 0
        sectionFooterHeight = 51
        rowHeight = UITableView.automaticDimension
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        keyboardDismissMode = .interactiveWithAccessory
        delegate = self
        dataSource = self
        register(ChatLeftCell.self, forCellReuseIdentifier: ChatLeftCell.identifier)
        register(ChatRightCell.self, forCellReuseIdentifier: ChatRightCell.identifier)
        register(ChatDateHeaderView.self, forHeaderFooterViewReuseIdentifier: ChatDateHeaderView.identifier)
    }
}

extension ChatTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChatDateHeaderView.identifier) as? ChatDateHeaderView else {
            return nil
        }
        headerView.configure(date: dates[section])
        return headerView
    }
}

extension ChatTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        
        switch message.alignment {
        case .right:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatRightCell.identifier, for: indexPath) as? ChatRightCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            bind(cell)
            return cell
        case .left:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatLeftCell.identifier, for: indexPath) as? ChatLeftCell else {
                return UITableViewCell()
            }
            cell.configure(message: message)
            bind(cell)
            return cell
        }
    }
    
    private func bind(_ cell: ChatLeftCell) {
        cell.imageTappedPublisher.sink { [weak self] imageUrl in
            self?.imageTappedPublisher.send(imageUrl)
        }.store(in: &cell.subscriptions)
    }
    
    private func bind(_ cell: ChatRightCell) {
        cell.imageTappedPublisher.sink { [weak self] imageUrl in
            self?.imageTappedPublisher.send(imageUrl)
        }.store(in: &cell.subscriptions)
    }
}
