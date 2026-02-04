//
//  LostItemDataRecentTableView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class LostItemDataRecentTableView: UITableView {
    
    // MARK: - Properties
    private var lostItemListData: [LostItemListData] = []
    private var isWaiting = true
    let cellTappedPublisher = PassthroughSubject<Int, Never>()
    let loadMoreListPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialzier
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(lostItemListData: [LostItemListData]) {
        self.lostItemListData = lostItemListData
        self.isWaiting = false
        reloadData()
    }
    
    func appendList(lostItemListData: [LostItemListData]) {
        self.lostItemListData.append(contentsOf: lostItemListData)
        self.isWaiting = false
        reloadData()
    }
}

extension LostItemDataRecentTableView {
    
    func updateState(foundDataId id: Int) {
        if let index = lostItemListData.firstIndex(where: { $0.id == id }) {
            lostItemListData[index].isFound = true
            reloadData()
        }
    }
    
    func updateState(reportedDataId id: Int) {
        if let index = lostItemListData.firstIndex(where: { $0.id == id }) {
            lostItemListData.remove(at: index)
            reloadData()
        }
    }
    
    func updateState(deletedId id: Int) {
        if let index = lostItemListData.firstIndex(where: { $0.id == id }) {
            lostItemListData.remove(at: index)
            reloadData()
        }
    }
    
    func updateState(updatedId id: Int, lostItemData: LostItemData) {
        if let index = lostItemListData.firstIndex(where: { $0.id == id }) {
            lostItemListData[index].category = lostItemData.category
            lostItemListData[index].foundPlace = lostItemData.foundPlace
            lostItemListData[index].foundDate = lostItemData.foundDate
            lostItemListData[index].content = lostItemData.content
            reloadData()
        }
    }
}

extension LostItemDataRecentTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellTappedPublisher.send(lostItemListData[indexPath.row].id)
    }
}

extension LostItemDataRecentTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lostItemListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemDataRecentTableViewCell.identifier, for: indexPath) as? LostItemDataRecentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(lostItemListData: lostItemListData[indexPath.row])
        return cell
    }
}

extension LostItemDataRecentTableView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height, !isWaiting {
            isWaiting = true
            loadMoreListPublisher.send()
        }
    }
}

extension LostItemDataRecentTableView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(LostItemDataRecentTableViewCell.self, forCellReuseIdentifier: LostItemDataRecentTableViewCell.identifier)
        
        separatorStyle = .none
        backgroundColor = .white
        sectionHeaderTopPadding = .zero
        sectionFooterHeight = .zero
        rowHeight = 54
    }
}
