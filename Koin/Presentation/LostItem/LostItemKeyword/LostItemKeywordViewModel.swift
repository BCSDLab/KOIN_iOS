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
        case deleteKeyword(Int)
        case subscribeKeyword(String)
        case notificationSwitchTapped(isOn: Bool)
    }
    enum Output {
        case showLoginModal
        case updateMyKeyword(LostItemKeywords)
        case updateKeywordSuggestion([String])
        case updateSubscription(isPermit: Bool)
        case updateCurrentCount(Int)
        case removeKeywordSuggestion(String)
        case removeMyKeyword(Int)
        case appendMyKeyword(LostItemKeyword)
        case showToastExceedCount
        case showToastKeywordLength
        case showToast(String)
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let subscribeKeywordUseCase: SubscribeLostItemKeywordUseCase
    private let fetchKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase
    private let fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase
    private let unsubscribeKeywordUseCase: UnsubscribeLostItemKeywordUseCase
    private let fetchNotiListUseCase: FetchNotiListUseCase
    private let changeNotiUseCase: ChangeNotiUseCase
    
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
        subscribeKeywordUseCase: SubscribeLostItemKeywordUseCase,
        fetchKeywordSuggestionUseCase: FetchLostItemKeywordSuggestionUseCase,
        fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase,
        unsubscribeKeywordUseCase: UnsubscribeLostItemKeywordUseCase,
        fetchNotiListUseCase: FetchNotiListUseCase,
        changeNotiUseCase: ChangeNotiUseCase
    ) {
        self.checkLoginUseCase = checkLoginUseCase
        self.subscribeKeywordUseCase = subscribeKeywordUseCase
        self.fetchKeywordSuggestionUseCase = fetchKeywordSuggestionUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
        self.unsubscribeKeywordUseCase = unsubscribeKeywordUseCase
        self.fetchNotiListUseCase = fetchNotiListUseCase
        self.changeNotiUseCase = changeNotiUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewWillAppear:
                fetchKeywordSuggestion()
                checkLogin() { [weak self] isLoggedIn in
                    if isLoggedIn {
                        self?.fetchMyKeyword()
                        self?.fetchNotificationPermission()
                    }
                }
            case .deleteKeyword(let id):
                deleteKeyword(id)
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
    
    private func checkLogin(completion: @escaping (Bool)->Void) {
        checkLoginUseCase.execute().sink { [weak self] isLoggedIn in
            guard let self else { return }
            self.isLoggedIn = isLoggedIn
            completion(isLoggedIn)
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
    
    private func deleteKeyword(_ id: Int) {
        unsubscribeKeywordUseCase.execute(id: id).sink(
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] in
                guard let self else { return }
                currentCount = max(0, currentCount-1)
                outputSubject.send(.removeMyKeyword(id))
            }
        ).store(in: &subscriptions)
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
        
        subscribeKeywordUseCase.execute(keyword: keyword).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] keyword in
                self?.outputSubject.send(.removeKeywordSuggestion(keyword.keyword))
                self?.outputSubject.send(.appendMyKeyword(keyword))
                self?.currentCount += 1
            }
        ).store(in: &subscriptions)
    }
    private func changeSubscription(isPermit: Bool) {
        guard isLoggedIn else {
            outputSubject.send(.showLoginModal)
            return
        }
        changeNotiUseCase.execute(method: isPermit ? .post : .delete, type: .lostItemKeyword).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in }
        ).store(in: &subscriptions)
    }
}
