//
//  LostItemDataTableView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class LostItemDataTableView: UITableView {
    
    // MARK: - Properties
    private var lostItemData: LostItemData?
    private var lostItemListData: [LostItemListData] = []
    let imageTapPublisher = PassthroughSubject<IndexPath, Never>()
    let listButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let editButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let cellTappedPublisher = PassthroughSubject<Int, Never>()
    let chatButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let changeStateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let reportButtonTappedPublisher = PassthroughSubject<Void, Never>()
    private var subscription: Set<AnyCancellable> = []
    
    // MARK: - Initialzier
    init() {
        super.init(frame: .zero, style: .grouped)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(lostItemData: LostItemData, lostItemListData: [LostItemListData]) {
        self.lostItemData = lostItemData
        self.lostItemListData = lostItemListData
        reloadData()
    }
    
    func changeState() {
        if let cell = cellForRow(at: IndexPath(row: 0, section: 0)) as? LostItemDataTableViewContentCell {
            cell.changeState()
        }
    }
}

extension LostItemDataTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        cellTappedPublisher.send(lostItemListData[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let headerView = LostItemDataTableViewContentHeaderView()
            guard let lostItemData else { return nil }
            headerView.configure(lostItemData: lostItemData)
            return headerView
        case 1:
            let headerView = LostItemDataTableViewRecentHeaderView()
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        default:
            return 47
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 100
        default:
            return 54
        }
    }
    
}

extension LostItemDataTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return lostItemListData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = LostItemDataTableViewContentCell()
            cell.configure(lostItemData: lostItemData)
            cell.imageTapPublisher.sink { [weak self] indexPath in
                self?.imageTapPublisher.send(indexPath)
            }.store(in: &subscription)
            cell.listButtonTappedPublisher.sink { [weak self] in
                self?.listButtonTappedPublisher.send()
            }.store(in: &subscription)
            cell.deleteButtonTappedPublisher.sink { [weak self] in
                self?.deleteButtonTappedPublisher.send()
            }.store(in: &subscription)
            cell.editButtonTappedPublisher.sink { [weak self] in
                self?.editButtonTappedPublisher.send()
            }.store(in: &subscription)
            cell.changeStateButtonTappedPublisher.sink { [weak self] in
                self?.changeStateButtonTappedPublisher.send()
            }.store(in: &subscription)
            cell.chatButtonTappedPublisher.sink { [weak self] in
                self?.chatButtonTappedPublisher.send()
            }.store(in: &subscription)
            cell.reportButtonTappedPublisher.sink { [weak self] in
                self?.reportButtonTappedPublisher.send()
            }.store(in: &subscription)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemDataTableViewRecentCell.identifier, for: indexPath) as? LostItemDataTableViewRecentCell else {
                return UITableViewCell()
            }
            cell.configure(lostItemListData: lostItemListData[indexPath.row])
            return cell
        }
    }
}

extension LostItemDataTableView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(LostItemDataTableViewRecentCell.self, forCellReuseIdentifier: LostItemDataTableViewRecentCell.identifier)
        
        separatorStyle = .none
        backgroundColor = .white
        sectionHeaderTopPadding = .zero
        sectionFooterHeight = .zero
    }
}
