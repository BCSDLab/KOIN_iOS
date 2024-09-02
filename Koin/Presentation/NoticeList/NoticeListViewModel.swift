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
        case getUserKeyWordList
        case changeKeyWord(NoticeKeyWordDTO)
    }
    enum Output {
        case updateBoard([NoticeArticleDTO], NoticeListPages, NoticeListType)
        case updateUserKeyWordList([NoticeKeyWordDTO], NoticeListType)
        case updateSelectedKeyWord(String)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private let fetchMyKeyWordUseCase: FetchNotificationKeyWordUseCase
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
    
    init(fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase, fetchMyKeyWordUseCase: FetchNotificationKeyWordUseCase) {
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
        self.fetchMyKeyWordUseCase = fetchMyKeyWordUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .changeBoard(noticeListType):
                self?.changeBoard(noticeListType: noticeListType)
            case let .changePage(page):
                self?.getNoticeInfo(page: page)
            case .getUserKeyWordList:
                self?.getUserKeyWordList()
            case let .changeKeyWord(keyWord):
                self?.changeKeyWord(keyWord: keyWord)
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
    
    private func getUserKeyWordList() {
        fetchMyKeyWordUseCase.fetchNotificationKeyWordWithLogin(keyWordForFilter: nil).sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                let result = self.fetchMyKeyWordUseCase.fetchNotificationKeyWordWithoutLogin()
                outputSubject.send(.updateUserKeyWordList(result, noticeListType))
            }
        }, receiveValue: { [weak self] keyWords in
            guard let self = self else { return }
            self.outputSubject.send(.updateUserKeyWordList(keyWords, noticeListType))
        }).store(in: &subscriptions)
    }
    
    private func changeKeyWord(keyWord: NoticeKeyWordDTO) {
        if keyWord.id == -1 {
            self.keyWord = nil
        }
        else {
            self.keyWord = keyWord.keyWord
        }
        outputSubject.send(.updateSelectedKeyWord(keyWord.keyWord))
    }
}


