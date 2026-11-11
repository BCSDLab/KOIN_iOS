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
    let deleteNotificationPublisher = PassthroughSubject<(id: Int, isSwipe: Bool), Never>()
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
    
    // 기본 삭제(commit editingStyle)로는 버튼 탭과 끝까지 밀기를 구분할 수 없어 같은 모양의 contextual action을 쓴다.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard notifications.indices.contains(indexPath.row) else { return nil }
        let id = notifications[indexPath.row].id
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, sourceView, completion in
            guard let self,
                  let row = notifications.firstIndex(where: { $0.id == id }) else {
                completion(false)
                return
            }
            // 버튼 탭이면 버튼 폭, 끝까지 밀기면 행 폭에 가깝게 늘어난 상태로 호출된다.
            let isSwipe = sourceView.bounds.width > tableView.bounds.width / 2
            deleteNotificationPublisher.send((id: id, isSwipe: isSwipe))
            notifications.remove(at: row)
            tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            if notifications.isEmpty {
                emptyNotificationPublisher.send()
            }
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
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

