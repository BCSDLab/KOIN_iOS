//
//  NotificationTableView.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class NotificationTableView: UITableView {
    
    private enum Layout {
        static let topInset: CGFloat = 12
        static let rowHeight: CGFloat = 80
        static let footerMinHeight: CGFloat = 55
        static let zeroTolerance: CGFloat = 0.5
    }
    
    // MARK: - Publisher
    let deletePublisher = PassthroughSubject<String, Never>()
    let tapNotificationPublisher = PassthroughSubject<NotificationItem, Never>()
    
    // MARK: - UI Components
    private let realFooterView = NotificationFooterView()
    
    // MARK: - Properties
    private var notifications: [NotificationItem] = []
    var isEmpty: Bool {
        notifications.isEmpty
    }
    private var lastBoundsSize: CGSize = .zero
    private var lastFooterHeight: CGFloat = 0
    private var isRecalculatingFooterHeight = false
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero, style: .grouped)
        setUpStyles()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(notifications: [NotificationItem]) {
        self.notifications = notifications
        updateFooterHeightCacheIfPossible()
        reloadData()
        setNeedsLayout()
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        reloadSections([0], with: .fade)
    }
    
    func deleteAll() {
        notifications.removeAll()
        reloadSections([0], with: .fade)
    }
}

extension NotificationTableView {
    private func didDeleteNotification(id: String, completion: (() -> Void)? = nil) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        notifications.remove(at: index)
        
        performBatchUpdates { [weak self] in
            self?.updateFooterHeightCacheIfPossible()
            self?.deleteRows(at: [indexPath], with: .automatic)
        } completion: { [weak self] _ in
            self?.setNeedsLayout()
            completion?()
        }
    }
    
    private func didSelectNotification(id: String) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            return
        }

        self.notifications[index].isRead = true
        
        reloadRows(
            at: [IndexPath(row: index, section: 0)],
            with: .fade
        )
    }
}

// MARK: - Layout

extension NotificationTableView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let didBoundsChange = abs(lastBoundsSize.width - bounds.width) > Layout.zeroTolerance
            || abs(lastBoundsSize.height - bounds.height) > Layout.zeroTolerance
        lastBoundsSize = bounds.size

        guard didBoundsChange || abs(lastFooterHeight) <= Layout.zeroTolerance else { return }
        recalculateFooterHeightIfNeeded()
    }

    private func recalculateFooterHeightIfNeeded() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard !isRecalculatingFooterHeight else { return }

        let desiredHeight = desiredFooterHeight(for: notifications.count)
        guard abs(lastFooterHeight - desiredHeight) > Layout.zeroTolerance else { return }

        isRecalculatingFooterHeight = true
        lastFooterHeight = desiredHeight

        UIView.performWithoutAnimation {
            beginUpdates()
            endUpdates()
            layoutIfNeeded()
        }

        isRecalculatingFooterHeight = false
    }

    private func updateFooterHeightCacheIfPossible() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        lastFooterHeight = desiredFooterHeight(for: notifications.count)
    }

    private func desiredFooterHeight(for rowCount: Int) -> CGFloat {
        guard rowCount > 0 else { return 0 }

        let visibleHeight = bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
        let rowsHeight = CGFloat(rowCount) * Layout.rowHeight
        let manualInsetHeight = contentInset.top + contentInset.bottom
        let occupiedHeight = rowsHeight + manualInsetHeight

        return max(Layout.footerMinHeight, visibleHeight - occupiedHeight)
    }
}

extension NotificationTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(item: notifications[indexPath.row])
        return cell
    }
}

extension NotificationTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        notifications.isEmpty ? .leastNormalMagnitude : lastFooterHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        max(lastFooterHeight, Layout.footerMinHeight)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !notifications.isEmpty else { return nil }
        return realFooterView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard notifications.indices.contains(indexPath.row) else {
            return
        }
        tapNotificationPublisher.send(notifications[indexPath.row])
        didSelectNotification(id: notifications[indexPath.row].id)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard notifications.indices.contains(indexPath.row) else {
            return nil
        }

        let item = notifications[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.didDeleteNotification(id: item.id)
            self.deletePublisher.send(item.id)
            completion(true)
        }
        deleteAction.image = .appImage(asset: .notificationTrash)
        deleteAction.backgroundColor = .appColor(.danger600)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: - Configure

extension NotificationTableView {

    private func setUpStyles() {
        backgroundColor = UIColor.ColorSystem.Neutral.gray0
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(top: Layout.topInset, left: 0, bottom: 0, right: 0)
        
        rowHeight = Layout.rowHeight
    
        dataSource = self
        delegate = self

        register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.identifier
        )
    }
}
