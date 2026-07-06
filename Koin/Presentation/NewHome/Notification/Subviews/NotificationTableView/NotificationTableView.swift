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
    
    // MARK: - Publisher
    let deletePublisher = PassthroughSubject<Int, Never>()
    let tapNotificationPublisher = PassthroughSubject<NotificationItem, Never>()
    
    // MARK: - UI Components
    private let dummyFooterView = UIView().then {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
    }
    private let realFooterView = NotificationFooterView()
    
    // MARK: - Properties
    var isEmpty: Bool {
        notifications.isEmpty
    }
    
    private var notifications: [NotificationItem] = []
    
    private var contentSizeObserver: NSKeyValueObservation?
    private var lastBoundsSize: CGSize = .zero
    private var lastFooterHeight: CGFloat = 0
    private var isUpdatingFooterPosition = false
    
    // MARK: - Initialization
    init() {
        super.init(frame: .zero, style: .grouped)
        setUpStyles()
        setUpLayouts()
        setUpContentSizeObserver()
        contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        contentSizeObserver?.invalidate()
    }
    
    // MARK: - Public
    func update(notifications: [NotificationItem]) {
        self.notifications = notifications
        reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.updateDummyFooterHeightIfNeeded()
            self?.updateFooterPosition()
        }
    }
}

extension NotificationTableView {
    private func deleteNotification(id: Int, completion: (() -> Void)? = nil) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        notifications.remove(at: index)
        
        performBatchUpdates { [weak self] in
            self?.deleteRows(at: [indexPath], with: .automatic)
        } completion: { [weak self] _ in
            self?.updateDummyFooterHeightIfNeeded()
            self?.updateFooterPosition()
            completion?()
        }
    }
}

// MARK: - Footer Layout

extension NotificationTableView {
    
    private func updateDummyFooterHeightIfNeeded() {
        guard bounds.width > 0 else { return }

        let footerHeight = measuredRealFooterHeight()
        let didHeightChange = abs(lastFooterHeight - footerHeight) > 0.5
        let didWidthChange = abs(dummyFooterView.frame.width - bounds.width) > 0.5

        guard didHeightChange || didWidthChange else { return }

        lastFooterHeight = footerHeight

        dummyFooterView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: footerHeight
        )

        UIView.performWithoutAnimation {
            tableFooterView = dummyFooterView
            layoutIfNeeded()
        }
    }
    
    func updateFooterPosition() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard !isUpdatingFooterPosition else { return }
        
        isUpdatingFooterPosition = true
        defer { isUpdatingFooterPosition = false }
        
        layoutIfNeeded()
        
        let footerHeight = measuredRealFooterHeight()
        let visibleHeight = bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
        
        let contentHeight = contentSize.height
        
        realFooterView.frame.size = CGSize(
            width: bounds.width,
            height: footerHeight
        )
        
        if contentHeight < visibleHeight {
            realFooterView.frame.origin = CGPoint(x: 0, y: visibleHeight - footerHeight)
        } else {
            realFooterView.frame.origin = CGPoint(x: 0, y: contentHeight - footerHeight)
        }
        
        bringSubviewToFront(realFooterView)
    }
    
    private func measuredRealFooterHeight() -> CGFloat {
        let targetSize = CGSize(
            width: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let size = realFooterView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return max(1, size.height)
    }
}

extension NotificationTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard notifications.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFooterPosition()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard notifications.indices.contains(indexPath.row) else {
            return
        }
        
        tapNotificationPublisher.send(notifications[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard notifications.indices.contains(indexPath.row) else {
            return nil
        }

        let item = notifications[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.deleteNotification(id: item.id)
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

        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 72

        dataSource = self
        delegate = self

        register(
            NotificationTableViewCell.self,
            forCellReuseIdentifier: NotificationTableViewCell.identifier
        )
    }

    private func setUpLayouts() {
        dummyFooterView.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 1
        )
        tableFooterView = dummyFooterView

        addSubview(realFooterView)
        bringSubviewToFront(realFooterView)
    }

    private func setUpContentSizeObserver() {
        contentSizeObserver = observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            guard let self else { return }
            self.updateDummyFooterHeightIfNeeded()
            self.updateFooterPosition()
        }
    }
}
