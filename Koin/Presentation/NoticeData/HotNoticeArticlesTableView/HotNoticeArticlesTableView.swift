//
//  HotNoticeArticlesTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import UIKit

final class HotNoticeArticlesTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var popularNoticeArticles: [NoticeArticleDTO] = []
    let tapHotArticlePublisher = PassthroughSubject<Int, Never>()
    
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
        register(HotNoticeArticlesTableViewCell.self, forCellReuseIdentifier: HotNoticeArticlesTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func updatePopularArticles(notices: [NoticeArticleDTO]) {
        self.popularNoticeArticles = notices
        reloadData()
    }
}

extension HotNoticeArticlesTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularNoticeArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:      HotNoticeArticlesTableViewCell.identifier, for: indexPath) as? HotNoticeArticlesTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(articleModel: popularNoticeArticles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapHotArticlePublisher.send(popularNoticeArticles[indexPath.row].id)
    }
}

extension HotNoticeArticlesTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
}



