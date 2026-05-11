//
//  LostItemKeywordViewModel.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import Foundation
import Combine

final class LostItemKeywordViewModel: ViewModelProtocol {
    
    enum Input {
        case viewWillAppear
        case deleteKeyword(String)
        case subscribeKeyword(String)
        case notificationSwitchTapped(isOn: Bool)
    }
    enum Output {
        case showLoginModal
        case updateMyKeyword([String])
        case updateKeywordSuggestion([String])
        case updateSubscription(isPermit: Bool)
        case updateCurrentCount(Int)
        case removeKeywordSuggestion(String)
        case appendMyKeyword(String)
        case showToastExceedCount
        case showToastKeywordLength
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase
    private let fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private var isLoggedIn = false
    let maxCount = 10
    private var currentCount = 0 {
        didSet {
            outputSubject.send(.updateCurrentCount(currentCount))
        }
    }
    
    // MARK: - Intializer
    init(
        checkLoginUseCase: CheckLoginUseCase,
        fetchKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase,
        fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase,
        fetchNotiListUseCase: FetchNotiListUseCase
    ) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchKeywordSuggestionUseCase = fetchKeywordSuggestionUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
        self.fetchNotiListUseCase = fetchNotiListUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewWillAppear:
                checkLogin()
                fetchMyKeyword()
                fetchKeywordSuggestion()
                fetchNotificationPermission()
            case .deleteKeyword(let keyword):
                deleteKeyword(keyword)
            case .subscribeKeyword(let keyword):
                subscribeKeyword(keyword)
            case .notificationSwitchTapped(let isOn):
                changeSubscription(isPermit: isOn)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemKeywordViewModel {
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink { [weak self] isLoggedIn in
            guard let self else { return }
            self.isLoggedIn = isLoggedIn
        }.store(in: &subscriptions)
    }
    
    private func fetchMyKeyword() {
        fetchMyKeywordUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] keywords in
                self?.currentCount = keywords.count
                self?.outputSubject.send(.updateMyKeyword(keywords))
            }
        ).store(in: &subscriptions)
    }
    private func fetchKeywordSuggestion() {
        fetchKeywordSuggestionUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] keywords in
                self?.outputSubject.send(.updateKeywordSuggestion(keywords))
            }
        ).store(in: &subscriptions)
    }
    private func fetchNotificationPermission() {
        fetchNotiListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] agreements in
                if let subscriptions = agreements.subscribes?.first(where: { $0.type == .lostItemKeyword }),
                   let isPermit = subscriptions.isPermit {
                    self?.outputSubject.send(.updateSubscription(isPermit: isPermit))
                }
            }
        ).store(in: &subscriptions)
    }
}

extension LostItemKeywordViewModel {
    
    private func deleteKeyword(_ keyword: String) {
        currentCount -= 1
        // TODO: - API 호출
    }
    private func subscribeKeyword(_ keyword: String) {
        guard isLoggedIn else {
            outputSubject.send(.showLoginModal)
            return
        }
        guard currentCount + 1 <= maxCount else {
            outputSubject.send(.showToastExceedCount)
            return
        }
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespaces)
        guard 2...10 ~= trimmedKeyword.count else {
            outputSubject.send(.showToastKeywordLength)
            return
        }
        outputSubject.send(.removeKeywordSuggestion(keyword))
        outputSubject.send(.appendMyKeyword(keyword))
        currentCount += 1
        // TODO: - API 호출
    }
    private func changeSubscription(isPermit: Bool) {
        guard isLoggedIn else {
            outputSubject.send(.showLoginModal)
            return
        }
        // TODO: - API 호출
    }
}
