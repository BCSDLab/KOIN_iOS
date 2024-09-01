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
    }
    enum Output {
        case updateHotKeyWord(keyWords: [String])
        case updateRecentSearchedWord(words: [RecentSearchedWordInfo])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase
    private let manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase
    
    init(fetchHotKeyWordUseCase: FetchHotSearchingKeyWordUseCase, manageRecentSearchedWordUseCase: ManageRecentSearchedWordUseCase) {
        self.fetchHotKeyWordUseCase = fetchHotKeyWordUseCase
        self.manageRecentSearchedWordUseCase = manageRecentSearchedWordUseCase
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
            self?.outputSubject.send(.updateHotKeyWord(keyWords: keyWords))
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
        outputSubject.send(.updateRecentSearchedWord(words: searchedWords))
    }
    
    private func deleteAllSearchedWords() {
        let words = manageRecentSearchedWordUseCase.fetch()
        for word in words {
            if let name = word.name, let date = word.searchedDate {
                manageRecentSearchedWordUseCase.changeWord(name: name, date: date, actionType: 1)
            }
        }
        self.outputSubject.send(.updateRecentSearchedWord(words: []))
    }
}


