//
//  RecentSearchedLostItemTableView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class RecentSearchedLostItemTableView: UITableView {
    
    // MARK: - Properties
    private var keywords: [RecentSearchedLostItem] = []
    private var subscriptions: Set<AnyCancellable> = []
    let deleteRecentSearchedLostItemPublisher = PassthroughSubject<RecentSearchedLostItem, Never>()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .grouped)
        dataSource = self
        rowHeight = UITableView.automaticDimension
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keywords: [RecentSearchedLostItem]) {
        self.keywords = keywords
        reloadData()
    }
}

extension RecentSearchedLostItemTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RecentSearchedLostItemTableViewCell()
        cell.configure(keyword: keywords[indexPath.row])
        cell.deleteButtonTappedPublisher.sink { [weak self] keyword in
            guard let self else { return }
            deleteRecentSearchedLostItemPublisher.send(keyword)
            keywords = keywords.filter {
                $0 != keyword
            }
            reloadData()
        }.store(in: &subscriptions)
        return cell
    }
}
