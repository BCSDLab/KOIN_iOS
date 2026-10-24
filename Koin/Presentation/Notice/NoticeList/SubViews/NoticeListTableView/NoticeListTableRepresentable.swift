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
        case pageButtonTapped(Int)
        case noticeRowTapped(noticeId: Int, boardId: Int)
        case searchButtonTapped
        case keywordAddTapped
        case keywordAllTapped
        case keywordTapped(keyword: NoticeKeywordDto)
        case keywordManageTapped
        case didScroll
        case keywordAddButtonDidMove(minX: CGFloat)
        case contentOffsetDidChange(offsetY: CGFloat)
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
            tableView.eventPublisher.sink { [weak self] event in
                guard let self else { return }
                switch event {
                case let .noticeRowTapped(noticeId, boardId):
                    onEvent(.noticeRowTapped(noticeId: noticeId, boardId: boardId))
                case .searchButtonTapped:
                    onEvent(.searchButtonTapped)
                case .keywordAddTapped:
                    onEvent(.keywordAddTapped)
                case .keywordAllTapped:
                    onEvent(.keywordAllTapped)
                case let .keywordTapped(keyword):
                    onEvent(.keywordTapped(keyword: keyword))
                case .keywordManageTapped:
                    onEvent(.keywordManageTapped)
                case .didScroll:
                    onEvent(.didScroll)
                case let .keywordAddButtonDidMove(minX):
                    onEvent(.keywordAddButtonDidMove(minX: minX))
                case let .contentOffsetDidChange(offsetY):
                    onEvent(.contentOffsetDidChange(offsetY: offsetY))
                case let .pageButtonTapped(page):
                    onEvent(.pageButtonTapped(page))
                case .nextPageButtonTapped:
                    break
                }
            }.store(in: &subscriptions)
        }
    }
}
