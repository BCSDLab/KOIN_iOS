//
//  LandListTableView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine

final class LandListTableView: UITableView {

    // MARK: - Properties
    let rowTappedPublisher = PassthroughSubject<LandRow, Never>()
    private var rows: [LandRow] = []

    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListTableView {
    func configure(rows: [LandRow]) {
        self.rows = rows
        reloadData()
    }
}

extension LandListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LandListTableViewCell.identifier, for: indexPath) as? LandListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(row: rows[indexPath.row])
        return cell
    }
}

extension LandListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowTappedPublisher.send(rows[indexPath.row])
    }
}

extension LandListTableView {
    private func commonInit() {
        register(LandListTableViewCell.self, forCellReuseIdentifier: LandListTableViewCell.identifier)
        dataSource = self
        delegate = self
        setUpStyles()
    }
    
    private func setUpStyles() {
        separatorStyle = .none
        backgroundColor = .appColor(.neutral0)
        rowHeight = UITableView.automaticDimension
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        footerView.backgroundColor = .appColor(.neutral100)
        tableFooterView = footerView
    }
}
