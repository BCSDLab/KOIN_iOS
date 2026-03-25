//
//  CallVanNotificationTableView.swift
//  koin
//
//  Created by 홍기정 on 3/4/26.
//

import UIKit
import Combine

final class CallVanNotificationTableView: UITableView {
    
    // MARK: - Properties
    private var notifications: [CallVanNotification] = []
    let cellTapPublisher = PassthroughSubject<(postId: Int, notificationId: Int), Never>()
    let deleteNotificationPublisher = PassthroughSubject<Int, Never>()
    let emptyNotificationPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Intiailizer
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(notifications: [CallVanNotification]) {
        self.notifications = notifications
        reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func markAllNotificationsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

extension CallVanNotificationTableView {
    
    private func commonInit() {
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 81
        
        delegate = self
        dataSource = self
        register(CallVanNotificationTableViewCell.self, forCellReuseIdentifier: CallVanNotificationTableViewCell.identifier)
    }
    
}

extension CallVanNotificationTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTapPublisher.send((postId: notifications[indexPath.row].postId, notificationId: notifications[indexPath.row].id))
        deselectRow(at: indexPath, animated: true)
        notifications[indexPath.row].isRead = true
        reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteNotificationPublisher.send(notifications[indexPath.row].id)
        notifications.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if notifications.count == 0 {
            emptyNotificationPublisher.send()
        }
    }
}

extension CallVanNotificationTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CallVanNotificationTableViewCell.identifier, for: indexPath) as? CallVanNotificationTableViewCell else {
            return UITableViewCell()
        }
        let isLastCell = indexPath.row == notifications.count - 1
        cell.configure(notification: notifications[indexPath.row], shouldHideSeparator: isLastCell)
        return cell
    }
}

