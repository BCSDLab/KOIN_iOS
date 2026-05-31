//
//  ShopBenefitTableView.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit
import Combine

final class ShopBenefitTableView: UITableView {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<([String], IndexPath), Never>()
    let detailExpandedPublisher = PassthroughSubject<Void, Never>()
    private var events: [ShopEvent] = []
    
    // MARK: - Initialzier
    init() {
        super.init(frame: .zero, style: .grouped)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(events: [ShopEvent]) {
        self.events = events
        reloadData()
    }
}

extension ShopBenefitTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleExpanded(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        toggleExpanded(at: indexPath)
    }
    
    private func toggleExpanded(at indexPath: IndexPath) {
        events[indexPath.row].isExpanded.toggle()
        if events[indexPath.row].isExpanded {
            detailExpandedPublisher.send()
        }
        guard let cell = cellForRow(at: indexPath) as? ShopBenefitTableViewCell else {
            return
        }
        cell.configure(event: events[indexPath.row])
        performBatchUpdates(nil)
    }
}

extension ShopBenefitTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopBenefitTableViewCell.identifier, for: indexPath) as? ShopBenefitTableViewCell else {
            return UITableViewCell()
        }
        let onCurrentPageChanged: (Int)->Void = { [weak self] currentPage in
            self?.events[indexPath.row].currentPage = currentPage
        }
        let onImageTapped: ([String], IndexPath)->Void = { [weak self] (imageUrls, indexPath) in
            self?.imageTapPublisher.send((imageUrls, indexPath))
        }
        cell.configure(event: events[indexPath.row], animated: false)
        cell.configure(
            onCurrentPageChanged: onCurrentPageChanged,
            onImageTapped: onImageTapped
        )
        return cell
    }
}

extension ShopBenefitTableView {
    
    private func commonInit() {
        register(ShopBenefitTableViewCell.self, forCellReuseIdentifier: ShopBenefitTableViewCell.identifier)
        delegate = self
        dataSource = self
        rowHeight = UITableView.automaticDimension
        allowsMultipleSelection = true
        separatorStyle = .none
        backgroundColor = .clear
        tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableFooterView = UIView(frame: .init(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
    }
}
