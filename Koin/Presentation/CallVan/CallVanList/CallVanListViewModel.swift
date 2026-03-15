//
//  CallVanListViewModel.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import Foundation
import Combine

final class CallVanListViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case checkLoginToParticapate
        case loadMoreList
        case updateFilterTitle(String?)
        case updateFilterState(CallVanListRequest)
    }
    enum Output {
        case resetList([CallVanListPost])
        case appendList([CallVanListPost])
        case didCheckLoginToParticapate(Bool)
        case updateBellWithNotification
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchCallVanListUseCase: FetchCallVanListUseCase
    private let fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var filterState = CallVanListRequest()
    
    // MARK: - Intializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchCallVanListUseCase: FetchCallVanListUseCase,
         fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchCallVanListUseCase = fetchCallVanListUseCase
        self.fetchCallVanNotificationListUseCase = fetchCallVanNotificationListUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .checkLoginToParticapate:
                checkLoginToParticapate()
            case .viewDidLoad:
                loadList()
                fetchNotification()
            case .loadMoreList:
                loadMoreList()
            case let .updateFilterTitle(title):
                updateFilterTitle(title)
            case let .updateFilterState(filterState):
                updateFilterState(filterState)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanListViewModel {
    
    private func checkLoginToParticapate() {
        checkLoginUseCase.execute().sink(receiveValue: { [weak self] isLoggedIn in
            guard let self else { return }
            outputSubject.send(.didCheckLoginToParticapate(isLoggedIn))
        }).store(in: &subscriptions)
    }
    
    private func fetchNotification() {
        fetchCallVanNotificationListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] notifications in
                if 0 < notifications.count {
                    self?.outputSubject.send(.updateBellWithNotification)
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func updateFilterTitle(_ title: String?) {
        filterState.title = title
        filterState.page = 1
        loadList()
    }
    
    private func updateFilterState(_ filterState: CallVanListRequest) {
        self.filterState.sort = filterState.sort
        self.filterState.state = filterState.state
        self.filterState.departure = filterState.departure
        self.filterState.arrival = filterState.arrival
        self.filterState.page = 1
        loadList()
    }
    
    private func loadList() {
        fetchCallVanListUseCase.execute(request: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanList in
                guard let self else { return }
                filterState.page = callVanList.currentPage
                outputSubject.send(.resetList(callVanList.posts))
            }
        ).store(in: &subscriptions)
    }
    
    private func loadMoreList() {
        filterState.page += 1
        fetchCallVanListUseCase.execute(request: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] callVanList in
                guard let self else { return }
                if filterState.page == callVanList.currentPage {
                    outputSubject.send(.appendList(callVanList.posts))
                } else {
                    filterState.page = callVanList.currentPage
                    outputSubject.send(.appendList([]))
                }
            }
        ).store(in: &subscriptions)
    }
}
