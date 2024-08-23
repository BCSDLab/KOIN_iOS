//
//  RecentSearchTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import UIKit

final class RecentSearchTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var recentSearchedDataList: [String] = ["근로장학", "학사공지", "ㅁㄴㅇㅁㄴㅁ"]
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(RecentSearchTableViewCell.self, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
    }
}

extension RecentSearchTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchedDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchTableViewCell.identifier, for: indexPath) as? RecentSearchTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(searchedData: recentSearchedDataList[indexPath.row])
        return cell
    }
}

extension RecentSearchTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
}
