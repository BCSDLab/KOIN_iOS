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
    let tapNoticePublisher = PassthroughSubject<Int, Never>()
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let tapListLoadButtnPublisher = PassthroughSubject<Int, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    let isScrolledPublisher = PassthroughSubject<Void, Never>()
    private var scrollDirection: ScrollLog = .scrollToDown
    private var subscriptions = Set<AnyCancellable>()
    private var isForSearch: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func commonInit() {
        register(NoticeListTableViewKeyWordCell.self, forCellReuseIdentifier: NoticeListTableViewKeyWordCell.id)
        register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.identifier)
        register(NoticeListTableViewFooter.self, forHeaderFooterViewReuseIdentifier: NoticeListTableViewFooter.identifier)
        register(NoticeSearchTableViewFooter.self, forHeaderFooterViewReuseIdentifier: NoticeSearchTableViewFooter.id)
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
        let indexSet = IndexSet(integer: 1)
        reloadSections(indexSet, with: .automatic)
    }
    
    func updateSearchedResult(noticeArticleList: [NoticeArticleDTO]) {
        
        self.noticeArticleList.append(contentsOf: noticeArticleList)
        
        isForSearch = true
        let indexSet = IndexSet(integer: 1)
        reloadSections(indexSet, with: .automatic)
        let IndexPath = IndexPath(row: self.noticeArticleList.count - 1, section: 1)
        scrollToRow(at: IndexPath, at: .bottom, animated: true)
    }
    
    func updateKeywordList(keywordList: [NoticeKeywordDTO], keywordIdx: Int) {
        let index = IndexPath(row: 0, section: 0)
        if let cell = cellForRow(at: index) as? NoticeListTableViewKeyWordCell {
            cell.updateKeyWordsList(keywordList: keywordList, keywordIdx: keywordIdx)
        }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return noticeArticleList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !isForSearch {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListTableViewKeyWordCell.id, for: indexPath) as? NoticeListTableViewKeyWordCell
            else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.keywordAddBtnTapPublisher.sink { [weak self] in
                self?.keywordAddBtnTapPublisher.send()
            }.store(in: &cell.subscriptions)
            cell.keywordTapPublisher.sink { [weak self] keyword in                self?.keywordTapPublisher.send(keyword)
            }.store(in: &cell.subscriptions)
            cell.manageKeyWordBtnTapPublisher.sink { [weak self] in
                self?.manageKeyWordBtnTapPublisher.send()
            }.store(in: &cell.subscriptions)
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeListTableViewCell.identifier, for: indexPath) as? NoticeListTableViewCell
            else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(articleModel: noticeArticleList[indexPath.row])
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tapNoticePublisher.send(noticeArticleList[indexPath.row].id)
        }
    }
}

extension NoticeListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && !isForSearch {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoticeListTableViewFooter.identifier) as? NoticeListTableViewFooter
            else {
                return UITableViewHeaderFooterView()
            }
            view.configure(pageInfo: pageInfos)
            view.tapBtnPublisher.sink { [weak self] page in
                self?.pageBtnPublisher.send(page)
            }.store(in: &view.subscriptions)
            return view
        }
        else if section == 1 && isForSearch {
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NoticeSearchTableViewFooter.id) as? NoticeSearchTableViewFooter
            else {
                return UITableViewHeaderFooterView()
            }
           
            view.tapBtnPublisher.sink { [weak self] in
                guard let self = self else { return }
                let page = Int(self.noticeArticleList.count / 5)
                self.tapListLoadButtnPublisher.send(page)
            }.store(in: &view.subscriptions)
            
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && !isForSearch {
            return 66
        }
        else if indexPath.section == 0 && isForSearch {
            return 0
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !isForSearch && section == 1 {
            return 95
        }
        else if isForSearch && section == 1 && noticeArticleList.count / 5 < 5 {
            return 58
        }
        else {
            return 0
        }
    }
}
