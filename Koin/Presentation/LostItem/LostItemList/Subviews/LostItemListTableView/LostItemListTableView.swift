//
//  LostItemListTableView.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import Combine

final class LostItemListTableView: UITableView {
    
    // MARK: - Properties
    private var lostItemArticle: [LostItemArticle] = []
    let cellTappedPublisher = PassthroughSubject<Int, Never>()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(lostItemArticle: [LostItemArticle]) {
        self.lostItemArticle = lostItemArticle
        reloadData()
    }
}

extension LostItemListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lostItemArticle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemListTableViewCell.identifier, for: indexPath) as? LostItemListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(lostItemArticle: lostItemArticle[indexPath.row])
        return cell
    }
}

extension LostItemListTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lostItemArticle[indexPath.row].isReported {
            return
        }
        cellTappedPublisher.send(lostItemArticle[indexPath.row].id)
    }
}

extension LostItemListTableView {
    
    private func commonInit() {
        register(LostItemListTableViewCell.self, forCellReuseIdentifier: LostItemListTableViewCell.identifier)
        delegate = self
        dataSource = self
    }
}
