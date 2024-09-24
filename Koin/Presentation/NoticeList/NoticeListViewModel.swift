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
    }
    enum Output {
        case updateBoard([NoticeArticleDTO], NoticeListPages, NoticeListType)
        case updateUserKeywordList([NoticeKeywordDTO], Int)
        case isLogined(Bool)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let fetchMyKeywordUseCase: FetchNotificationKeywordUseCase
    private var noticeListType: NoticeListType = .all {
        didSet {
            getNoticeInfo(page: 1)
        }
    }
    private var keyword: String? = nil {
        didSet {
            getNoticeInfo(page: 0)
        }
    }
    
    init(fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase, fetchMyKeywordUseCase: FetchNotificationKeywordUseCase) {
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
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
        fetchNoticeArticlesUseCase.fetchArticles(boardId: noticeListType.rawValue, keyWord: keyword, page: page).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] articleInfo in
            guard let self = self else { return }
            self.outputSubject.send(.updateBoard(articleInfo.articles, articleInfo.pages,self.noticeListType))
        }).store(in: &subscriptions)
    }
    
    private func getUserKeywordList(keyword: NoticeKeywordDTO? = nil) {
        var keywordIndex = 0
        var keywordValue: NoticeKeywordDTO = NoticeKeywordDTO(id: 0, keyword: "")
        var count = 0
        var overallCount = 0
        if let keyword = keyword, self.keyword != keyword.keyword {
            if keyword.keyword == "모두보기" {
                overallCount += 1
            }
            else {
                overallCount = 0
            }
            if overallCount == 0 {
                keywordValue = keyword
                self.keyword = keyword.keyword
            }
        }
        else if self.keyword != nil {
            keywordValue = NoticeKeywordDTO(id: nil, keyword: self.keyword ?? "")
        }
        
        fetchUserKeyword(completion: { [weak self] keywords in
            for (index, value) in keywords.enumerated() {
                if value.keyword == keywordValue.keyword {
                    keywordIndex = index + 1
                    count += 1
                    break
                }
            }
            if count == 0 {
                keywordIndex = 0
                keywordValue = NoticeKeywordDTO(id: nil, keyword: "모두보기")
                self?.keyword = nil
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
}


