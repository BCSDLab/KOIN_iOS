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
        case viewWillAppear
        case refresh
        case checkLoginToPost
        case checkLoginToParticapate(Int)
        case loadMoreList
        case updateFilterTitle(String?)
        case updateFilterState(CallVanListRequest)

        case participate(Int)
        case quit(Int)
        case close(Int)
        case reopen(Int)
        case complete(Int)
        
        case logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any)
    }
    enum Output {
        case resetList([CallVanListPost])
        case appendList([CallVanListPost])
        case updateListItem(CallVanListPost, Int)
        case deleteListItem(Int)
        case didCheckLoginToParticapate(Bool, Int)
        case didCheckLoginToPost(Bool)
        case updateBell(alert: Bool)
        case showToast(String)
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchCallVanListUseCase: FetchCallVanListUseCase
    private let fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase
    private let participateCallVanUseCase: ParticipateCallVanUseCase
    private let quitCallVanUseCase: QuitCallVanUseCase
    private let closeCallVanUseCase: CloseCallVanUseCase
    private let reopenCallVanUseCase: ReopenCallVanUseCase
    private let completeCallVanUseCase: CompleteCallVanUseCase
    private let fetchCallVanSummaryUseCase: FetchCallVanSummaryUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var filterState = CallVanListRequest()
    
    // MARK: - Intializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchCallVanListUseCase: FetchCallVanListUseCase,
         fetchCallVanNotificationListUseCase: FetchCallVanNotificationListUseCase,
         participateCallVanUseCase: ParticipateCallVanUseCase,
         quitCallVanUseCase: QuitCallVanUseCase,
         closeCallVanUseCase: CloseCallVanUseCase,
         reopenCallVanUseCase: ReopenCallVanUseCase,
         completeCallVanUseCase: CompleteCallVanUseCase,
         fetchCallVanSummaryUseCase: FetchCallVanSummaryUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    ) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchCallVanListUseCase = fetchCallVanListUseCase
        self.fetchCallVanNotificationListUseCase = fetchCallVanNotificationListUseCase
        self.participateCallVanUseCase = participateCallVanUseCase
        self.quitCallVanUseCase = quitCallVanUseCase
        self.closeCallVanUseCase = closeCallVanUseCase
        self.reopenCallVanUseCase = reopenCallVanUseCase
        self.completeCallVanUseCase = completeCallVanUseCase
        self.fetchCallVanSummaryUseCase = fetchCallVanSummaryUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case let .checkLoginToParticapate(postId):
                checkLoginToParticapate(postId)
            case .checkLoginToPost:
                checkLoginToPost()
            case .viewDidLoad:
                loadList()
            case .viewWillAppear:
                fetchNotification()
            case .loadMoreList:
                loadMoreList()
            case let .updateFilterTitle(title):
                updateFilterTitle(title)
            case let .updateFilterState(filterState):
                updateFilterState(filterState)
            case let .participate(postId):
                participate(postId)
            case let .quit(postId):
                quit(postId)
            case let .close(postId):
                close(postId)
            case let .reopen(postId):
                reopen(postId)
            case let .complete(postId):
                complete(postId)
            case .refresh:
                refresh()
            case let .logEvent(label, category, value):
                logEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension CallVanListViewModel {
    
    private func checkLoginToParticapate(_ postId: Int) {
        checkLoginUseCase.execute().sink(receiveValue: { [weak self] isLoggedIn in
            guard let self else { return }
            outputSubject.send(.didCheckLoginToParticapate(isLoggedIn, postId))
        }).store(in: &subscriptions)
    }
    
    private func checkLoginToPost() {
        checkLoginUseCase.execute().sink(receiveValue: { [weak self] isLoggedIn in
            guard let self else { return }
            outputSubject.send(.didCheckLoginToPost(isLoggedIn))
        }).store(in: &subscriptions)
    }
    
    private func fetchNotification() {
        fetchCallVanNotificationListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] notifications in
                let alert = notifications.filter { !$0.isRead }.count != 0
                self?.outputSubject.send(.updateBell(alert: alert))
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
    
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            guard let self else { return }
            filterState.page = 1
            loadList()
            fetchNotification()
        }
    }
    
    private func loadList() {
        fetchCallVanListUseCase.execute(request: filterState).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] callVanList in
                guard let self else { return }
                filterState.page = callVanList.currentPage
                outputSubject.send(.resetList(callVanList.posts))
            }
        ).store(in: &subscriptions)
    }
    
    private func reloadList(_ postId: Int) {
        fetchCallVanSummaryUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { [weak self] callVanListPost in
                self?.outputSubject.send(.updateListItem(callVanListPost, postId))
            }
        ).store(in: &subscriptions)
    }
    
    private func loadMoreList() {
        filterState.page += 1
        fetchCallVanListUseCase.execute(request: filterState).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.filterState.page -= 1
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
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
    
    private func participate(_ postId: Int) {
        participateCallVanUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.reloadList(postId)
                case .failure(let error):
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in}
        ).store(in: &subscriptions)
    }
    
    private func quit(_ postId: Int) {
        quitCallVanUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.reloadList(postId)
                case .failure(let error):
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in}
        ).store(in: &subscriptions)
    }
    
    private func close(_ postId: Int) {
        closeCallVanUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.reloadList(postId)
                case .failure(let error):
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in}
        ).store(in: &subscriptions)
    }
    
    private func reopen(_ postId: Int) {
        reopenCallVanUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.reloadList(postId)
                case .failure(let error):
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in}
        ).store(in: &subscriptions)
    }
    private func complete(_ postId: Int) {
        completeCallVanUseCase.execute(postId: postId).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.outputSubject.send(.deleteListItem(postId))
                case .failure(let error):
                    self?.outputSubject.send(.showToast(error.message))
                }
            },
            receiveValue: { _ in}
        ).store(in: &subscriptions)
    }
    
    private func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
