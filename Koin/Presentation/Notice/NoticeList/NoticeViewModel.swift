//
//  NoticeViewModel.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import Combine
import Foundation
import Observation

@MainActor
@Observable
final class NoticeViewModel: SwiftUIViewModelProtocol {

    // MARK: - Input
    enum Input {
        case onFirstAppear
        case onAppear
        case didTapTab(NoticeListType)
        case didSwipe(NoticeListType)
        case didTapSearch
        case didTapAddKeyword
        case didTapManageKeyword
        case didShowToast
        case didTapCloseTooltip
    }

    // MARK: - State
    private(set) var selectedNoticeType: NoticeListType
    private(set) var pageViewModels: [NoticeListType: NoticePageViewModel] = [:]
    private(set) var keywordList: [NoticeKeywordDto] = []
    private(set) var shouldShowTooltip = false
    private(set) var toastMessage: String?

    // MARK: - Properties
    private let fetchMyKeywordUseCase: FetchNotificationKeywordUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Initializer
    init(
        fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase,
        fetchMyKeywordUseCase: FetchNotificationKeywordUseCase,
        logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        noticeListType: NoticeListType = .all
    ) {
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.selectedNoticeType = noticeListType
        NoticeListType.allCases.forEach { type in
            pageViewModels[type] = NoticePageViewModel(
                noticeListType: type,
                fetchNoticeArticlesUseCase: fetchNoticeArticlesUseCase,
                logAnalyticsEventUseCase: logAnalyticsEventUseCase,
                onError: { [weak self] message in
                    self?.toastMessage = message
                }
            )
        }
    }

    // MARK: - Public
    func execute(_ input: Input) {
        switch input {
        case .onFirstAppear:
            loadAllPages()
        case .onAppear:
            fetchKeywordList()
        case let .didTapTab(type):
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.noticeTab, category: .click, value: type.displayName)
            selectedNoticeType = type
        case let .didSwipe(type):
            selectedNoticeType = type
        case .didTapSearch:
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.noticeSearch, category: .click, value: "검색")
        case .didTapAddKeyword:
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.addKeyword, category: .click, value: "키워드추가")
        case .didTapManageKeyword:
            logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.Notice.manageKeyword, category: .click, value: "키워드관리")
        case .didShowToast:
            toastMessage = nil
        case .didTapCloseTooltip:
            shouldShowTooltip = false
        }
    }

    func pageViewModel(for type: NoticeListType) -> NoticePageViewModel {
        guard let pageViewModel = pageViewModels[type] else {
            preconditionFailure("NoticePageViewModel for \(type) is not initialized")
        }
        return pageViewModel
    }
}

extension NoticeViewModel {
    private func loadAllPages() {
        NoticeListType.allCases.forEach { type in
            pageViewModel(for: type).execute(.load)
        }
    }
    
    private func fetchKeywordList() {
        fetchMyKeywordUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] keywords, _ in
                    self?.updateKeywordList(keywords)
                }
            )
            .store(in: &subscriptions)
    }

    private func updateKeywordList(_ keywords: [NoticeKeywordDto]) {
        keywordList = keywords

        let registeredKeywords = Set(keywords.map(\.keyword))
        pageViewModels.values.forEach { pageViewModel in
            if let keyword = pageViewModel.keyword,
               !registeredKeywords.contains(keyword) {
                pageViewModel.execute(.selectKeyword(nil))
            }
        }

        if keywords.isEmpty && !UserDefaults.standard.bool(forKey: "hasShownNoticeTooltip") {
            shouldShowTooltip = true
            UserDefaults.standard.set(true, forKey: "hasShownNoticeTooltip")
        }
    }
}
