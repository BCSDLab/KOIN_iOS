//
//  NoticeListTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import UIKit

final class NoticeListTableView: UITableView {
    // MARK: - Properties
    private var noticeArticleList: [NoticeArticleDTO] = []
    
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
        register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.identifier)
        dataSource = self
        delegate = self
    }
}

extension NoticeListTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeArticleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListTableViewCell.identifier, for: indexPath) as? NoticeListTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(articleModel: noticeArticleList[indexPath.row])
        return cell
    }
}

extension NoticeListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
