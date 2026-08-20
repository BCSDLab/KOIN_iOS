//
//  NotificationListView.swift
//  koin
//
//  Created by 홍기정 on 8/19/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class NotificationListView: UIView {
    
    // MARK: - Properties
    let refreshPublisher = PassthroughSubject<Void, Never>()
    let itemTappedPublisher = PassthroughSubject<String, Never>()
    let deletePublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let tableView = NotificationTableView()
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyView = NotificationEmptyView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func startLoading() {
        loadingIndicator.startAnimating()
    }
    
    func update(items: [NotificationRowModel]) {
        tableView.update(notifications: items)
        updateStateViews(isEmpty: items.isEmpty)
    }
    
    func markAllAsRead() {
        tableView.markAllAsRead()
    }
    
    func deleteAll() {
        tableView.deleteAll()
        updateStateViews(isEmpty: true)
    }
}

// MARK: - Bind

private extension NotificationListView {
    private func bind() {
        tableView.tapNotificationPublisher
            .sink { [weak self] id in
                self?.itemTappedPublisher.send(id)
            }
            .store(in: &subscriptions)
        
        tableView.deletePublisher
            .sink { [weak self] id in
                guard let self else { return }
                updateStateViews(isEmpty: tableView.isEmpty)
                deletePublisher.send(id)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - State

private extension NotificationListView {
    private func updateStateViews(isEmpty: Bool) {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState]
        ) { [weak self] in
            self?.tableView.backgroundView?.alpha = isEmpty ? 1 : 0
        }
    }
}

// MARK: - Configure

private extension NotificationListView {
    private func configureView() {
        setUpAddTargets()
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        
        loadingIndicator.do {
            $0.hidesWhenStopped = true
        }
        
        tableView.do {
            $0.refreshControl = refreshControl
            $0.backgroundView = emptyView
        }
        
        emptyView.do {
            $0.alpha = 0
        }
    }
    
    private func setUpLayouts() {
        [tableView, loadingIndicator].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setUpAddTargets() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh() {
        refreshPublisher.send()
    }
}
