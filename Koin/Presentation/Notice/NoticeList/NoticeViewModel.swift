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
        case changeSelectedNoticeType(NoticeListType)
        case didShowToast
        case didTapCloseTooltip
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
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
        case let .changeSelectedNoticeType(type):
            selectedNoticeType = type
        case .didShowToast:
            toastMessage = nil
        case .didTapCloseTooltip:
            shouldShowTooltip = false
        case let .logEvent(label, category, value):
            makeLogAnalyticsEvent(label: label, category: category, value: value)
        }
    }
}

extension NoticeViewModel {
    private func updateKeywordList(_ keywords: [NoticeKeywordDto]) {
        keywordList = keywords
        deselectKeywordIfNeeded(keywords)
        handleTooltipVisibility()
    }
    
    private func deselectKeywordIfNeeded(_ keywords: [NoticeKeywordDto]) {
        let keywords = Set(keywords.map(\.keyword))
        pageViewModels.values.forEach { pageViewModel in
            if let keyword = pageViewModel.keyword,
               !keywords.contains(keyword) {
                pageViewModel.execute(.selectKeyword(nil))
            }
        }
    }
    
    private func handleTooltipVisibility() {
        if keywordList.isEmpty && !UserDefaults.standard.bool(forKey: "hasShownNoticeTooltip") {
            shouldShowTooltip = true
            UserDefaults.standard.set(true, forKey: "hasShownNoticeTooltip")
        }
    }
}

extension NoticeViewModel {
    private func loadAllPages() {
        NoticeListType.allCases.forEach { type in
            pageViewModels[type]?.execute(.load)
        }
    }
    
    private func fetchKeywordList() {
        Task {
            do {
                let (keywords, _) = try await fetchMyKeywordUseCase.execute().firstValue()
                updateKeywordList(keywords)
            } catch {
                
            }
        }
    }

    private func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
