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
    private var lostItemList: [LostItemList] = [
        LostItemList(id: 0, type: .found, category: "종류1", foundPlace: "장소", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: false, isFound: false),
        LostItemList(id: 0, type: .found, category: "종류1", foundPlace: "장소", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: true, isFound: false),
        LostItemList(id: 0, type: .found, category: "종류1", foundPlace: "장소", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: true, isFound: true),
        LostItemList(id: 0, type: .found, category: "종류1종류2", foundPlace: "장류~~~~~~2종류3종류4소", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: false, isFound: false),
        LostItemList(id: 0, type: .found, category: "종류1종류2종류3", foundPlace: "장소소1종류~~~~~~2종류3~~~~", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: false, isFound: false),
        LostItemList(id: 0, type: .found, category: "종류", foundPlace: "장소1종류~~~~~~2종류3종류4", foundDate: "2020-20-20", content: "내용!", author: "작성자", registeredAt: "04.04 토", isReported: false, isFound: false)
    ]
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
    
    func configure(lostItemList: [LostItemList]) {
        self.lostItemList = lostItemList
        reloadData()
    }
}

extension LostItemListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lostItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LostItemListTableViewCell.identifier, for: indexPath) as? LostItemListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(lostItemList: lostItemList[indexPath.row])
        return cell
    }
}

extension LostItemListTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lostItemList[indexPath.row].isReported {
            return
        }
        cellTappedPublisher.send(lostItemList[indexPath.row].id)
    }
}

extension LostItemListTableView {
    
    private func commonInit() {
        register(LostItemListTableViewCell.self, forCellReuseIdentifier: LostItemListTableViewCell.identifier)
        delegate = self
        dataSource = self
    }
}
