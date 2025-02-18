//
//  NoticeListTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit

final class NoticeListTableView: UITableView {
    // MARK: - Properties
    private var noticeArticleList: [NoticeArticleDTO] = []
    private var pageInfos: NoticeListPages = .init(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
    let pageBtnPublisher = PassthroughSubject<Int, Never>()
    let tapNoticePublisher = PassthroughSubject<(Int, Int), Never>()
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let tapListLoadButtnPublisher = PassthroughSubject<Int, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    let isScrolledPublisher = PassthroughSubject<Void, Never>()
    private var scrollDirection: ScrollLog = .scrollToDown
    private var subscriptions = Set<AnyCancellable>()
    private var isForSearch: Bool = false
    private var isLastSearchedPage: Bool = false
    private var headerCancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var headerView = NoticeListHeaderView().then { _ in
    }
    private lazy var footerView = NoticeListTableViewFooter().then { _ in
    }
    private lazy var searchFooterView = NoticeSearchTableViewFooter().then { _ in
    }
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit() {
        register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.identifier)
        register(NoticeListTableViewFooter.self, forHeaderFooterViewReuseIdentifier: NoticeListTableViewFooter.identifier)
        register(NoticeSearchTableViewFooter.self, forHeaderFooterViewReuseIdentifier: NoticeSearchTableViewFooter.identifier)
        register(NoticeListHeaderView.self, forHeaderFooterViewReuseIdentifier: NoticeListHeaderView.identifier)
        dataSource = self
        delegate = self
        estimatedRowHeight = 110
        sectionHeaderHeight = 0
        sectionHeaderTopPadding = 0
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func updateNoticeList(noticeArticleList: [NoticeArticleDTO], pageInfos: NoticeListPages) {
        self.noticeArticleList = noticeArticleList
        self.pageInfos = pageInfos
        isForSearch = false
        let indexSet = IndexSet(integer: 0)
        reloadSections(indexSet, with: .automatic)
    }
    
    func updateSearchedResult(noticeArticleList: [NoticeArticleDTO], isLastPage: Bool, isNewKeyword: Bool) {
        if isNewKeyword {
            self.noticeArticleList = []
        }
        self.noticeArticleList.append(contentsOf: noticeArticleList)
        isForSearch = true
        isLastSearchedPage = isLastPage
        let indexSet = IndexSet(integer: 0)
        reloadSections(indexSet, with: .automatic)
        let IndexPath = IndexPath(row: self.noticeArticleList.count - 1, section: 0)
        scrollToRow(at: IndexPath, at: .bottom, animated: true)
    }
    
    func updateKeywordList(keywordList: [NoticeKeywordDTO], keywordIdx: Int) {
        if let headerView = self.headerView(forSection: 0) as? NoticeListHeaderView {
            headerView.updateKeyWordsList(keywordList: keywordList, keywordIdx: keywordIdx)
        }
        reloadData()
    }
}

extension NoticeListTableView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetY = self.contentOffset.y
        let screenHeight = self.frame.height
        if scrollDirection == .scrollToDown && contentOffsetY > screenHeight * 0.7 && scrollDirection != .scrollChecked {
            scrollDirection = .scrollChecked
            isScrolledPublisher.send()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview)
        if velocity.y > 0 {
            scrollDirection = .scrollToTop
        }
        else {
            if scrollDirection != .scrollChecked {
                scrollDirection = .scrollToDown
            }
        }
    }
}

extension NoticeListTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeArticleList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerCancellables.removeAll()
        headerView.keywordAddBtnTapPublisher.sink { [weak self] in
            self?.keywordAddBtnTapPublisher.send()
        }.store(in: &headerCancellables)
        headerView.keywordTapPublisher.sink { [weak self] keyword in                self?.keywordTapPublisher.send(keyword)
        }.store(in: &headerCancellables)
        headerView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.manageKeyWordBtnTapPublisher.send()
        }.store(in: &headerCancellables)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListTableViewCell.identifier, for: indexPath) as? NoticeListTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(articleModel: noticeArticleList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapNoticePublisher.send((noticeArticleList[indexPath.row].id, noticeArticleList[indexPath.row].boardId))
    }
}

extension NoticeListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !isForSearch {
            footerView.subscriptions.removeAll()
            footerView.configure(pageInfo: pageInfos)
            footerView.tapBtnPublisher.sink { [weak self] page in
                self?.pageBtnPublisher.send(page)
            }.store(in: &footerView.subscriptions)
            return footerView
        }
        else {
            searchFooterView.subscriptions.removeAll()
            searchFooterView.tapBtnPublisher
                .sink { [weak self] in
                    guard let self = self else { return }
                    let page = (self.noticeArticleList.count) / 5
                    self.tapListLoadButtnPublisher.send(page + 1)
                }.store(in: &searchFooterView.subscriptions)
            
            return searchFooterView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if noticeArticleList.first?.boardId == 14 {
            return 120
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !isForSearch {
            return 95
        }
        else if isForSearch && !isLastSearchedPage {
            return 58
        }
        else {
            return 0
        }
    }
}
