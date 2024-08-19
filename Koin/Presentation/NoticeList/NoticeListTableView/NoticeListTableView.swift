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
    private var pageInfos: NoticeListPages = .init(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
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
        register(NoticeListTableViewHeader.self, forHeaderFooterViewReuseIdentifier: NoticeListTableViewHeader.identifier)
        register(NoticeListTableViewFooter.self, forHeaderFooterViewReuseIdentifier: NoticeListTableViewFooter.identifier)
        dataSource = self
        delegate = self
        rowHeight = UITableView.automaticDimension
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        sectionHeaderTopPadding = 0
    }
    
    func updateNoticeList(noticeArticleList: [NoticeArticleDTO], pageInfos: NoticeListPages) {
        self.noticeArticleList = noticeArticleList
        self.pageInfos = pageInfos
        reloadData()
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoticeListTableViewHeader.identifier) as? NoticeListTableViewHeader
        else {
            return UITableViewHeaderFooterView()
        }

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoticeListTableViewFooter.identifier) as? NoticeListTableViewFooter
        else {
            return UITableViewHeaderFooterView()
        }
        view.configure(pageInfo: pageInfos)
        return view
    }
}

extension NoticeListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }
}
