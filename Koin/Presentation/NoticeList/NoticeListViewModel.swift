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
        case getUserKeyWordList(NoticeKeyWordDTO? = nil)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case updateBoard([NoticeArticleDTO], NoticeListPages, NoticeListType)
        case updateUserKeyWordList([NoticeKeyWordDTO], Int)
        case isLogined(Bool)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let fetchMyKeyWordUseCase: FetchNotificationKeyWordUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var noticeListType: NoticeListType = .전체공지 {
        didSet {
            getNoticeInfo(page: 1)
        }
    }
    private var keyWord: String? = nil {
        didSet {
            getNoticeInfo(page: 0)
        }
    }
    
    init(fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase, fetchMyKeyWordUseCase: FetchNotificationKeyWordUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase) {
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.fetchMyKeyWordUseCase = fetchMyKeyWordUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .changeBoard(noticeListType):
                self?.changeBoard(noticeListType: noticeListType)
            case let .changePage(page):
                self?.getNoticeInfo(page: page)
            case let .getUserKeyWordList(keyWord):
                self?.getUserKeyWordList(keyWord: keyWord)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeListViewModel {
    private func changeBoard(noticeListType: NoticeListType) {
        self.noticeListType = noticeListType
    }
    
    private func getNoticeInfo(page: Int) {
        fetchNoticeArticlesUseCase.fetchArticles(boardId: noticeListType.rawValue, keyWord: keyWord, page: page).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] articleInfo in
            guard let self = self else { return }
            self.outputSubject.send(.updateBoard(articleInfo.articles, articleInfo.pages,self.noticeListType))
        }).store(in: &subscriptions)
    }
    
    private func getUserKeyWordList(keyWord: NoticeKeyWordDTO? = nil) {
        var keyWordIndex = 0
        var keyWordValue: NoticeKeyWordDTO = NoticeKeyWordDTO(id: 0, keyWord: "")
        var count = 0
        var overallCount = 0
        if let keyWord = keyWord, self.keyWord != keyWord.keyWord {
            if keyWord.keyWord == "모두보기" {
                makeLogAnalyticsEvent(label: EventParameter.EventLabel.Campus.noticeFilterAll, category: .click, value: "모두보기")
                overallCount += 1
            }
            else {
                overallCount = 0
            }
            if overallCount == 0 {
                keyWordValue = keyWord
                self.keyWord = keyWord.keyWord
            }
        }
        else if self.keyWord != nil {
            keyWordValue = NoticeKeyWordDTO(id: nil, keyWord: self.keyWord ?? "")
        }
        
        fetchUserKeyWord(completion: { [weak self] keyWords in
            for (index, value) in keyWords.enumerated() {
                if value.keyWord == keyWordValue.keyWord {
                    keyWordIndex = index + 1
                    count += 1
                    break
                }
            }
            if count == 0 {
                keyWordIndex = 0
                keyWordValue = NoticeKeyWordDTO(id: nil, keyWord: "모두보기")
                self?.keyWord = nil
            }
            self?.outputSubject.send(.updateUserKeyWordList(keyWords, keyWordIndex))
        })
    }
    
    private func fetchUserKeyWord(completion: @escaping ([NoticeKeyWordDTO]) -> Void) {
        fetchMyKeyWordUseCase.fetchNotificationKeyWordWithLogin(keyWordForFilter: nil).sink(receiveCompletion: { [weak self] response in
            guard let self = self else { return }
            if case let .failure(error) = response {
                Log.make().error("\(error)")
                let result = self.fetchMyKeyWordUseCase.fetchNotificationKeyWordWithoutLogin()
                if result.isEmpty { self.outputSubject.send(.isLogined(false)) }
                completion(result)
            }
        }, receiveValue: { [weak self] keyWords in
            if keyWords.isEmpty { self?.outputSubject.send(.isLogined(true)) }
            completion(keyWords)
        }).store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


