//
//  NoticePageViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import Combine
import Foundation
import Observation

@MainActor
@Observable
final class NoticePageViewModel: SwiftUIViewModelProtocol {

    // MARK: - Input
    enum Input {
        case load
        case selectKeyword(String?)
        case didTapAllKeyword
        case changePage(Int)
        case logScroll
    }

    // MARK: - State
    let noticeListType: NoticeListType
    private(set) var keyword: String?
    private(set) var articles: [NoticeArticleDto] = []
    private(set) var pages: NoticeListPages = .init(isPreviousPage: nil, pages: [], selectedIndex: 0, isNextPage: nil)
    private var hasLoggedScroll = false

    // MARK: - Properties
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let onError: (String) -> Void
    private var fetchCancellable: AnyCancellable?

    // MARK: - Initializer
    init(
        noticeListType: NoticeListType,
        fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        onError: @escaping (String) -> Void
    ) {
        self.noticeListType = noticeListType
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.onError = onError
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .load:
            fetchArticles(page: 1)
        case let .selectKeyword(keyword):
            selectKeyword(keyword)
        case .didTapAllKeyword:
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.noticeFilterAll, category: .click, value: "모두보기")
            selectKeyword(nil)
        case let .changePage(page):
            fetchArticles(page: page)
        case .logScroll:
            logScroll()
        }
    }
}

extension NoticePageViewModel {
    private func selectKeyword(_ keyword: String?) {
        self.keyword = keyword
        fetchArticles(page: 1)
    }

    private func fetchArticles(page: Int) {
        fetchCancellable?.cancel()
        fetchCancellable = fetchNoticeArticlesUseCase.execute(boardId: noticeListType.rawValue, keyWord: keyword, page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.onError(error.message)
                    }
                },
                receiveValue: { [weak self] articleInfo in
                    self?.articles = articleInfo.articles
                    self?.pages = articleInfo.pages
                }
            )
    }

    private func logScroll() {
        guard !hasLoggedScroll else { return }
        hasLoggedScroll = true
        logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.noticePage, category: .scroll, value: "공지사항")
    }
}
