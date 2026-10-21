//
//  NoticeListTableRepresentable.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import Combine
import SwiftUI
import UIKit

struct NoticeListTableRepresentable: UIViewRepresentable {

    enum Event {
        case didTapKeyword(NoticeKeywordDto)
        case didTapAllKeyword
        case didTapPage(Int)
        case didScroll
        case didTapSearch
        case didTapAddKeyword
        case didTapManageKeyword
        case didTapArticle(noticeId: Int, boardId: Int)
        case didChangeAddButtonMinX(CGFloat)
        case didChangeContentOffsetY(CGFloat)
    }

    // MARK: - Properties
    let articles: [NoticeArticleDto]
    let pages: NoticeListPages
    let keywordList: [NoticeKeywordDto]
    let selectedKeyword: String?
    let isSelected: Bool
    let onEvent: (Event) -> Void

    // MARK: - UIViewRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(onEvent: onEvent)
    }

    func makeUIView(context: Context) -> NoticeListTableView {
        let tableView = NoticeListTableView(frame: .zero, style: .grouped).then {
            $0.backgroundColor = .white
            $0.separatorStyle = .none
        }
        context.coordinator.bind(tableView: tableView)
        return tableView
    }

    func updateUIView(_ tableView: NoticeListTableView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onEvent = onEvent

        let articleState = Coordinator.ArticleState(articles: articles, pages: pages)
        if coordinator.lastArticleState != articleState {
            tableView.configure(noticeArticleList: articles, pageInfos: pages, animated: isSelected)
            coordinator.lastArticleState = articleState
        }

        let keywordState = Coordinator.KeywordState(keywordList: keywordList, selectedKeyword: selectedKeyword)
        if coordinator.lastKeywordState != keywordState {
            let selectedKeywordDto = keywordList.first { $0.keyword == selectedKeyword }
            tableView.configure(keywordList: keywordList, selectedKeyword: selectedKeywordDto)
            coordinator.lastKeywordState = keywordState
        }
    }

    static func dismantleUIView(_ tableView: NoticeListTableView, coordinator: Coordinator) {
        coordinator.subscriptions.removeAll()
    }
}

extension NoticeListTableRepresentable {
    final class Coordinator {
        struct ArticleState: Equatable {
            let articles: [NoticeArticleDto]
            let pages: NoticeListPages
        }

        struct KeywordState: Equatable {
            let keywordList: [NoticeKeywordDto]
            let selectedKeyword: String?
        }

        var onEvent: (Event) -> Void
        var lastArticleState: ArticleState?
        var lastKeywordState: KeywordState?
        var subscriptions: Set<AnyCancellable> = []

        init(onEvent: @escaping (Event) -> Void) {
            self.onEvent = onEvent
        }

        func bind(tableView: NoticeListTableView) {
            tableView.keywordTapPublisher.sink { [weak self] keyword in
                self?.onEvent(.didTapKeyword(keyword))
            }.store(in: &subscriptions)

            tableView.keywordAllButtonTappedPublisher.sink { [weak self] in
                self?.onEvent(.didTapAllKeyword)
            }.store(in: &subscriptions)

            tableView.pageBtnPublisher.sink { [weak self] page in
                self?.onEvent(.didTapPage(page))
            }.store(in: &subscriptions)

            tableView.isScrolledPublisher.sink { [weak self] in
                self?.onEvent(.didScroll)
            }.store(in: &subscriptions)

            tableView.searchButtonTappedPublisher.sink { [weak self] in
                self?.onEvent(.didTapSearch)
            }.store(in: &subscriptions)

            tableView.keywordAddBtnTapPublisher.sink { [weak self] in
                self?.onEvent(.didTapAddKeyword)
            }.store(in: &subscriptions)

            tableView.manageKeyWordBtnTapPublisher.sink { [weak self] in
                self?.onEvent(.didTapManageKeyword)
            }.store(in: &subscriptions)

            tableView.tapNoticePublisher.sink { [weak self] noticeId, boardId in
                self?.onEvent(.didTapArticle(noticeId: noticeId, boardId: boardId))
            }.store(in: &subscriptions)

            tableView.addButtonMinXPublisher.sink { [weak self] addButtonMinX in
                self?.onEvent(.didChangeAddButtonMinX(addButtonMinX))
            }.store(in: &subscriptions)

            tableView.contentOffsetYPublisher.sink { [weak self] contentOffsetY in
                self?.onEvent(.didChangeContentOffsetY(contentOffsetY))
            }.store(in: &subscriptions)
        }
    }
}
