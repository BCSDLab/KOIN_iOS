//
//  NoticeSearchViewModel.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import Foundation

final class NoticeSearchViewModel: ViewModelProtocol {
    
    enum Input {
        case getHotKeyWord(Int)
        case searchWord(String, Date, Int)
        case fetchRecentSearchedWord
        case deleteAllSearchedWords
        case fetchSearchedResult(Int, String?)
    }
    enum Output {
        case updateHotKeyWord([String])
        case updateRecentSearchedWord([RecentSearchedWordInfo])
        case updateSearchedrsult([NoticeArticleDTO], Bool)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchHotKeywordUseCase: FetchHotSearchingKeywordUseCase
    private let manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase
    private let searchNoticeArticlesUseCase: SearchNoticeArticlesUseCase
    private let fetchRecentSearchedWordUseCase: FetchRecentSearchedWordUseCase
    private var keyWord = ""
    
    init(fetchHotKeywordUseCase: FetchHotSearchingKeywordUseCase, manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase, searchNoticeArticlesUseCase: SearchNoticeArticlesUseCase, fetchRecentSearchedWordUseCase: FetchRecentSearchedWordUseCase) {
        self.fetchHotKeywordUseCase = fetchHotKeywordUseCase
        self.manageRecentSearchedWordUseCase = manageRecentSearchedWordUseCase
        self.searchNoticeArticlesUseCase = searchNoticeArticlesUseCase
        self.fetchRecentSearchedWordUseCase = fetchRecentSearchedWordUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case let .getHotKeyWord(count):
                self?.getHotKeyWord(count: count)
            case let .searchWord(word, searchedDate, actionType):
                self?.searchWord(word: word, searchedDate: searchedDate, actionType: actionType)
            case .fetchRecentSearchedWord:
                self?.fetchRecentSearchedWord()
            case .deleteAllSearchedWords:
                self?.deleteAllSearchedWords()
            case let .fetchSearchedResult(page, keyWord):
                self?.fetchSearchedResult(page: page, keyWord: keyWord)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeSearchViewModel {
    private func getHotKeyWord(count: Int) {
        fetchHotKeywordUseCase.execute(count: count).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] keyWords in
            self?.outputSubject.send(.updateHotKeyWord(keyWords))
        }).store(in: &subscriptions)
    }
    
    private func searchWord(word: String, searchedDate: Date, actionType: Int) {
        manageRecentSearchedWordUseCase.execute(name: word, date: searchedDate, actionType: actionType)
        if actionType == 1 {
            fetchRecentSearchedWord()
        }
    }
    
    private func fetchRecentSearchedWord() {
        let searchedWords = fetchRecentSearchedWordUseCase.execute()
        outputSubject.send(.updateRecentSearchedWord(searchedWords))
    }
    
    private func deleteAllSearchedWords() {
        let words = fetchRecentSearchedWordUseCase.execute()
        for word in words {
            if let name = word.name, let date = word.searchedDate {
                manageRecentSearchedWordUseCase.execute(name: name, date: date, actionType: 1)
            }
        }
        self.outputSubject.send(.updateRecentSearchedWord([]))
    }
    
    private func fetchSearchedResult(page: Int, keyWord: String?) {
        let requestModel = SearchNoticeArticleRequest(query: keyWord ?? self.keyWord, boardId: nil, page: page, limit: 5)
        if let keyWord = keyWord {
            self.keyWord = keyWord
        }
        searchNoticeArticlesUseCase.execute(requestModel: requestModel).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] articles in
            if articles.currentPage == articles.totalPage {
                self?.outputSubject.send(.updateSearchedrsult(articles.articles ?? [], true))
            }
            else {
                self?.outputSubject.send(.updateSearchedrsult(articles.articles ?? [], false))
            }
        }).store(in: &subscriptions)
    }
}


