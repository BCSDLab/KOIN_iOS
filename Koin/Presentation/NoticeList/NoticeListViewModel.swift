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
        case getUserKeywordList(NoticeKeywordDTO? = nil)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case checkAuth
        case checkLogin
    }
    enum Output {
        case updateBoard([NoticeArticleDTO], NoticeListPages, NoticeListType)
        case updateUserKeywordList([NoticeKeywordDTO], Int)
        case isLogined(Bool)
        case showIsLogined(Bool)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let fetchMyKeywordUseCase: FetchNotificationKeywordUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let checkAuthUseCase = DefaultCheckAuthUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: DefaultUserRepository(service: DefaultUserService()))
    private(set) var auth: UserType = .student
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
    
    init(fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase, fetchMyKeywordUseCase: FetchNotificationKeywordUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .changeBoard(noticeListType):
                self?.changeBoard(noticeListType: noticeListType)
            case let .changePage(page):
                self?.getNoticeInfo(page: page)
            case let .getUserKeywordList(keyword):
                self?.getUserKeywordList(keyword: keyword)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .checkAuth:
                self?.checkAuth()
            case .checkLogin:
                self?.checkLogin()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeListViewModel {
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink { [weak self] in
            self?.outputSubject.send(.showIsLogined($0))
        }.store(in: &subscriptions)
    }
    
    func checkAuth() {
        
        checkAuthUseCase.execute().sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] response in
            self?.auth = response.userType
        }).store(in: &subscriptions)
        
    }
    private func changeBoard(noticeListType: NoticeListType) {
        self.noticeListType = noticeListType
    }
    
    private func getNoticeInfo(page: Int) {
        fetchNoticeArticlesUseCase.execute(boardId: noticeListType.rawValue, keyWord: keyword, page: page, type: nil).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] articleInfo in
            guard let self = self else { return }
            print(articleInfo)
            self.outputSubject.send(.updateBoard(articleInfo.articles, articleInfo.pages,self.noticeListType))
        }).store(in: &subscriptions)
    }
    
    private func getUserKeywordList(keyword: NoticeKeywordDTO? = nil) {
        var keywordIndex = 0
        if let keyword = keyword {
            if keyword.id != -1 {
                self.keyword = keyword.keyword
            }
            else {
                self.keyword = nil
            }
        }
        
        fetchUserKeyword(completion: { [weak self] keywords in
            for (index, value) in keywords.enumerated() {
                if value.keyword == self?.keyword {
                    keywordIndex = index + 1
                    break
                }
            }
            self?.outputSubject.send(.updateUserKeywordList(keywords, keywordIndex))
        })
    }
    
    private func fetchUserKeyword(completion: @escaping ([NoticeKeywordDTO]) -> Void) {
        fetchMyKeywordUseCase.execute().sink(receiveCompletion: { response in
            if case let .failure(error) = response {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] fetchResult in
            if fetchResult.0.isEmpty {
                self?.outputSubject.send(.isLogined(fetchResult.1))
            }
            completion(fetchResult.0)
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


