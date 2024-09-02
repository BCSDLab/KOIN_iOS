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
        case fetchSearchedResult(String)
        case changePage(Int)
    }
    enum Output {
        case updateHotKeyWord([String])
        case updateRecentSearchedWord([RecentSearchedWordInfo])
        case updateSearchedrsult([NoticeArticleDTO], NoticeListPages)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase
    private let manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase
    private let fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase
    private var keyWord: String = ""
    
    init(fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase, manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase, fetchNoticeArticlesUseCase: FetchNoticeArticlesUseCase) {
        self.fetchHotKeyWordUseCase = fetchHotKeyWordUseCase
        self.manageRecentSearchedWordUseCase = manageRecentSearchedWordUseCase
        self.fetchNoticeArticlesUseCase = fetchNoticeArticlesUseCase
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
            case let .fetchSearchedResult(keyWord):
                self?.fetchSearchedResult(page: 0, keyWord: keyWord)
            case let .changePage(page):
                self?.fetchSearchedResult(page: page, keyWord: self?.keyWord ?? "")
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension NoticeSearchViewModel {
    private func getHotKeyWord(count: Int) {
        fetchHotKeyWordUseCase.execute(count: count).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] keyWords in
            self?.outputSubject.send(.updateHotKeyWord(keyWords))
        }).store(in: &subscriptions)
    }
    
    private func searchWord(word: String, searchedDate: Date, actionType: Int) {
        manageRecentSearchedWordUseCase.changeWord(name: word, date: searchedDate, actionType: actionType)
        if actionType == 1 {
            fetchRecentSearchedWord()
        }
    }
    
    private func fetchRecentSearchedWord() {
        let searchedWords = manageRecentSearchedWordUseCase.fetch()
        outputSubject.send(.updateRecentSearchedWord(searchedWords))
    }
    
    private func deleteAllSearchedWords() {
        let words = manageRecentSearchedWordUseCase.fetch()
        for word in words {
            if let name = word.name, let date = word.searchedDate {
                manageRecentSearchedWordUseCase.changeWord(name: name, date: date, actionType: 1)
            }
        }
        self.outputSubject.send(.updateRecentSearchedWord([]))
    }
    
    private func fetchSearchedResult(page: Int, keyWord: String) {
        self.keyWord = keyWord
        fetchNoticeArticlesUseCase.fetchArticles(boardId: nil, keyWord: keyWord, page: page).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        }, receiveValue: { [weak self] articleInfo in
            guard let self = self else { return }
            self.outputSubject.send(.updateSearchedrsult(articleInfo.articles, articleInfo.pages))
        }).store(in: &subscriptions)
    }
}


