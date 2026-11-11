//
//  NoticeListTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit
import Foundation

final class NoticeListTableView: UITableView {
    
    enum Event {
        case noticeRowTapped(noticeId: Int, boardId: Int)
        case searchButtonTapped
        case keywordAddTapped
        case keywordAllTapped
        case keywordTapped(keyword: NoticeKeywordDto)
        case keywordManageTapped
        case didScroll(String)
        case keywordAddButtonDidMove(minX: CGFloat)
        case contentOffsetDidChange(offsetY: CGFloat)
        case pageButtonTapped(Int)
        case nextPageButtonTapped(Int)
    }
    
    // MARK: - Properties
    private var noticeArticleList: [NoticeArticleDto] = [] 
    private var pageInfos: NoticeListPages = .init(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
    
    let eventPublisher = PassthroughSubject<Event, Never>()
    
    private var scrollStopReferenceY: CGFloat?
    private var lastUserOffsetY: CGFloat = 0
    private var lastObservedOffsetY: CGFloat = 0
    private var scrollStopWorkItem: DispatchWorkItem?
    private var subscriptions = Set<AnyCancellable>()
    private var isForSearch: Bool = false
    private var isLastSearchedPage: Bool = false
    private var headerCancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var headerView = NoticeListHeaderView()
    private lazy var footerView = NoticeListTableViewFooter()
    private lazy var searchFooterView = NoticeSearchTableViewFooter()
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit() {
        register(
            NoticeListTableViewCell.self,
            forCellReuseIdentifier: NoticeListTableViewCell.identifier
        )
        register(
            NoticeListTableViewFooter.self,
            forHeaderFooterViewReuseIdentifier: NoticeListTableViewFooter.identifier
        )
        register(
            NoticeSearchTableViewFooter.self,
            forHeaderFooterViewReuseIdentifier: NoticeSearchTableViewFooter.identifier
        )
        register(
            NoticeListHeaderView.self,
            forHeaderFooterViewReuseIdentifier: NoticeListHeaderView.identifier
        )
        dataSource = self
        delegate = self
        estimatedRowHeight = 110
        sectionHeaderHeight = 0
        sectionHeaderTopPadding = 0
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showsVerticalScrollIndicator = false
    }

    func configure(
        noticeArticleList: [NoticeArticleDto],
        pageInfos: NoticeListPages,
        animated: Bool
    ) {
        self.noticeArticleList = noticeArticleList
        self.pageInfos = pageInfos
        isForSearch = false
        let indexSet = IndexSet(integer: 0)
        reloadSections(indexSet, with: animated ? .automatic : .none)
    }
    
    func updateSearchedResult(
        noticeArticleList: [NoticeArticleDto],
        isLastPage: Bool,
        isNewKeyword: Bool
    ) {
        isForSearch = true
        isLastSearchedPage = isLastPage
        
        performBatchUpdates { [weak self] in
            guard let self else { return }
            
            if isNewKeyword {
                self.noticeArticleList = noticeArticleList
                reloadSections(IndexSet(integer: 0), with: .automatic)
            } else {
                let firstRow = self.noticeArticleList.count
                self.noticeArticleList.append(contentsOf: noticeArticleList)
                let lastRow = self.noticeArticleList.count - 1
                
                guard !noticeArticleList.isEmpty else { return }
                
                let insertedIndexpaths: [IndexPath] = (firstRow...lastRow).map {
                    IndexPath(row: $0, section: 0)
                }
                insertRows(at: insertedIndexpaths, with: .automatic)
            }
        } completion: { [weak self] _ in
            guard let self,
                  !self.noticeArticleList.isEmpty else {
                return
            }
            let lastIndexPath = IndexPath(row: self.noticeArticleList.count - 1, section: 0)
            scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    func configure(
        keywordList: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        headerView.updateKeyWordsList(keywordList: keywordList, selectedKeyword: selectedKeyword)
        reloadData()
    }
}

extension NoticeListTableView: UIScrollViewDelegate {
    // 명세 4-2: 사용자 스크롤 offset이 200ms 동안 변하지 않으면 정지로 본다(손가락을 댄 채 멈춘 경우 포함).
    // 직전 정지 위치와 50 이상 차이 날 때만 방향을 기록하고, 정지마다 기준점을 갱신한다.
    // 사용자 조작이 아닌 offset 변화(프로그램 스크롤·위치 복원)는 이동량에 넣지 않는다.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollStopWorkItem == nil {
            scrollStopReferenceY = scrollView.contentOffset.y
        }
        lastUserOffsetY = scrollView.contentOffset.y
        lastObservedOffsetY = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let offsetChange = offsetY - lastObservedOffsetY
        lastObservedOffsetY = offsetY
        eventPublisher.send(.contentOffsetDidChange(offsetY: scrollView.contentOffset.y))
        guard let reference = scrollStopReferenceY else { return }
        guard isUserScrolling else {
            // 자동 이동은 사용자 이동량과 200ms 기한을 유지한 채 좌표만 보정한다.
            scrollStopReferenceY = reference + offsetChange
            lastUserOffsetY += offsetChange
            return
        }
        lastUserOffsetY = offsetY
        scrollStopWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in self?.handleScrollStop() }
        scrollStopWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }

    private var isUserScrolling: Bool { isTracking || isDragging || isDecelerating }

    private func handleScrollStop() {
        scrollStopWorkItem = nil
        guard let reference = scrollStopReferenceY else { return }
        let delta = lastUserOffsetY - reference
        // 조작이 끝났으면 다음 드래그 시작 위치를 새 기준점으로 삼는다.
        scrollStopReferenceY = isUserScrolling ? lastUserOffsetY : nil
        guard abs(delta) >= 50 else { return }
        eventPublisher.send(.didScroll(delta > 0 ? "아래로" : "위로"))
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
        headerView.searchButtonTappedPublisher.sink { [weak self] in
            self?.eventPublisher.send(.searchButtonTapped)
        }.store(in: &headerCancellables)
        headerView.keywordAddBtnTapPublisher.sink { [weak self] in
            self?.eventPublisher.send(.keywordAddTapped)
        }.store(in: &headerCancellables)
        headerView.keywordAllButtonTappedPublisher.sink { [weak self] in
            self?.eventPublisher.send(.keywordAllTapped)
        }.store(in: &headerCancellables)
        headerView.keywordTapPublisher.sink { [weak self] keyword in
            self?.eventPublisher.send(.keywordTapped(keyword: keyword))
        }.store(in: &headerCancellables)
        headerView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.eventPublisher.send(.keywordManageTapped)
        }.store(in: &headerCancellables)
        headerView.noticeKeywordScrollView.addButtonMinXPublisher.sink { [weak self] minX in
            self?.eventPublisher.send(.keywordAddButtonDidMove(minX: minX))
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
        eventPublisher.send(.noticeRowTapped(
            noticeId: noticeArticleList[indexPath.row].id,
            boardId: noticeArticleList[indexPath.row].boardId
        ))
    }
}

extension NoticeListTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !isForSearch {
            footerView.subscriptions.removeAll()
            footerView.configure(pageInfo: pageInfos)
            footerView.tapBtnPublisher.sink { [weak self] page in
                self?.eventPublisher.send(.pageButtonTapped(page))
            }.store(in: &footerView.subscriptions)
            return footerView
        }
        else {
            searchFooterView.subscriptions.removeAll()
            searchFooterView.tapBtnPublisher
                .sink { [weak self] in
                    guard let self = self else { return }
                    let page = (self.noticeArticleList.count) / 5
                    self.eventPublisher.send(.nextPageButtonTapped(page + 1))
                }.store(in: &searchFooterView.subscriptions)
            
            return searchFooterView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isForSearch {
            return 0
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
