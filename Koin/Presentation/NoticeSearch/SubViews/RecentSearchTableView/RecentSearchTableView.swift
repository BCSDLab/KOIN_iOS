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
   
    private var recentSearchedDataList: [RecentSearchedWordInfo] = []
    let tapDeleteButtonPublisher = PassthroughSubject<(String, Date), Never>()
    
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
    
    func updateRecentSearchedWords(words: [RecentSearchedWordInfo]) {
        self.recentSearchedDataList = words
        reloadData()
    }
}

extension RecentSearchTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchedDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchTableViewCell.identifier, for: indexPath) as? RecentSearchTableViewCell else {
            return UITableViewCell()
        }
        guard indexPath.row < recentSearchedDataList.count else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let searchedData = recentSearchedDataList[indexPath.row]
        cell.configure(searchedData: searchedData.name ?? "")
        
        cell.tapDeleteButtonPublisher.sink { [weak self] in
            if let name = searchedData.name,
               let date = searchedData.searchedDate {
                self?.tapDeleteButtonPublisher.send((name, date))
            }
        }.store(in: &cell.subscriptions)
        
        return cell
    }
}

extension RecentSearchTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
}
