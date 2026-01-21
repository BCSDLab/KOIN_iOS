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
    private var lostItemListData: [LostItemListData] = []
    private var isWaiting = true
    let cellTappedPublisher = PassthroughSubject<Int, Never>()
    let loadMoreListPublisher = PassthroughSubject<Void, Never>()
    
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
    
    func update(_ lostItemListData: [LostItemListData]) {
        isWaiting = false
        self.lostItemListData = lostItemListData
        reloadData()
    }
    func append(_ lostItemListData: [LostItemListData]) {
        isWaiting = false
        lostItemListData.forEach {
            self.lostItemListData.append($0)
        }
        reloadData()
    }
}

extension LostItemListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lostItemListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemListTableViewCell.identifier, for: indexPath) as? LostItemListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(lostItemListData: lostItemListData[indexPath.row])
        return cell
    }
}

extension LostItemListTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lostItemListData[indexPath.row].isReported {
            return
        }
        cellTappedPublisher.send(lostItemListData[indexPath.row].id)
    }
}

extension LostItemListTableView: UIScrollViewDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height, !isWaiting {
            isWaiting = true
            loadMoreListPublisher.send()
        }
    }
}

extension LostItemListTableView {
    
    private func commonInit() {
        register(LostItemListTableViewCell.self, forCellReuseIdentifier: LostItemListTableViewCell.identifier)
        delegate = self
        dataSource = self
    }
}
