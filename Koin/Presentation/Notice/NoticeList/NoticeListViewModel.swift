//
//  NoticeListViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/14/24.
//

import Combine
import Foundation

final class NoticeListViewModel: ViewModelProtocol {
    
    enum Input {
        case changeBoard(NoticeListType)
        case changePage(Int)
        case getUserKeywordList(NoticeKeywordDto? = nil)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateBoard([NoticeArticleDto], NoticeListPages, NoticeListType)
        case updateUserKeywordList([NoticeKeywordDto], NoticeKeywordDto?)
        case showToolTip
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let fetchMyKeywordUseCase: FetchNotificationKeywordUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private(set) var isLoggedIn: Bool = false
    private(set) var noticeListType: NoticeListType = .all {
        didSet {
            getNoticeInfo(page: 1)
        }
    }
    private var keyword: String? = nil {
        didSet {
            getNoticeInfo(page: 1)
        }
    }
    
    init(fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase, fetchMyKeywordUseCase: FetchNotificationKeywordUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, noticeListType: NoticeListType = .all) {
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.noticeListType = noticeListType
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .changeBoard(noticeListType):
                self?.noticeListType = noticeListType
            case let .changePage(page):
                self?.getNoticeInfo(page: page)
            case let .getUserKeywordList(keyword):
                self?.getUserKeywordList(keyword: keyword)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeListViewModel {

    private func getNoticeInfo(page: Int) {
        fetchNoticeArticlesUseCase.execute(boardId: noticeListType.rawValue, keyWord: keyword, page: page).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] articleInfo in
                guard let self = self else { return }
                self.outputSubject.send(.updateBoard(articleInfo.articles, articleInfo.pages,self.noticeListType))
            }
        ).store(in: &subscriptions)
    }
    
    private func getUserKeywordList(keyword: NoticeKeywordDto? = nil) {
        if let keyword = keyword {
            self.keyword = keyword.keyword
        } else {
            self.keyword = nil
        }
        
        var selectedKeyword: NoticeKeywordDto?
        
        fetchUserKeyword(completion: { [weak self] keywords in
            for (index, value) in keywords.enumerated() {
                if value.keyword == self?.keyword {
                    selectedKeyword = value
                }
            }
            self?.outputSubject.send(.updateUserKeywordList(keywords, selectedKeyword))
        })
    }
    
    private func fetchUserKeyword(completion: @escaping ([NoticeKeywordDto]) -> Void) {
        fetchMyKeywordUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] fetchResult in
                self?.isLoggedIn = fetchResult.1
                if fetchResult.0.isEmpty {
                    self?.outputSubject.send(.showToolTip)
                }
                completion(fetchResult.0)
            }
        ).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


