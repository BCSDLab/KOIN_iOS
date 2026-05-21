//
//  LostItemListViewModel.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import Foundation
import Combine

final class LostItemListViewModel {
    
    enum Input {
        case checkLogin
        case load
        case reset
        case loadMore
        case updateTitle(String?)
        case updateFilter(FetchLostItemListRequest)
        case updateKeyword(String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    enum Output {
        case update([LostItemListData])
        case append([LostItemListData])
        case updateKeywords([LostItemKeyword])
    }
    
    // MARK: - Properties
    private let checkLoginUseCase: CheckLoginUseCase
    private let fetchLostItemListUseCase: FetchLostItemListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscription: Set<AnyCancellable> = []
    
    private(set) var isLoggedIn: Bool = false {
        didSet {
            isLoggedIn ? fetchMyKeyword() : outputSubject.send(.updateKeywords([]))
        }
    }
    var filterState = FetchLostItemListRequest()
    
    
    // MARK: - Initializer
    init(checkLoginUseCase: CheckLoginUseCase,
         fetchLostItemListUseCase: FetchLostItemListUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         fetchMyKeywordUseCase: FetchLostItemMyKeywordUseCase
    ) {
        self.checkLoginUseCase = checkLoginUseCase
        self.fetchLostItemListUseCase = fetchLostItemListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchMyKeywordUseCase = fetchMyKeywordUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .load:
                self.load()
            case .reset:
                self.filterState = .init()
                self.load()
            case .loadMore:
                self.loadMore()
            case .checkLogin:
                self.checkLogin()
            case .updateTitle(let title):
                self.update(title: title)
            case .updateFilter(let filter):
                self.update(filter: filter)
            case .updateKeyword(let keyword):
                self.update(keyword: keyword)
            case let .logEvent(label, category, value):
                self.logEvent(label: label, category: category, value: value)
            }
        }.store(in: &subscription)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension LostItemListViewModel {
    
    private func logEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
    
    private func checkLogin() {
        checkLoginUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] isLoggedIn in
                self?.isLoggedIn = isLoggedIn
            }
        ).store(in: &subscription)
    }
    
    private func fetchMyKeyword() {
        fetchMyKeywordUseCase.execute().sink(
            receiveCompletion: { _ in},
            receiveValue: { [weak self] keywords in
                self?.outputSubject.send(.updateKeywords(keywords.keywords))
            }
        ).store(in: &subscription)
    }
    
    private func update(filter: FetchLostItemListRequest) {
        // 필터 적용
        filterState.type = filter.type
        filterState.category = filter.category
        filterState.foundStatus = filter.foundStatus
        filterState.author = filter.author
        // API 호출
        load()
    }
    private func update(title: String?) {
        // 타이틀 적용
        filterState.title = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        // API 호출
        load()
    }
    private func update(keyword: String) {
        // 키워드 적용
        filterState.title = keyword
        // API 호출
        load()
    }
    private func reset() {
        // 필터 초기화
        filterState = .init()
        // API 호출
        load()
    }
    
    private func load() {
        // 첫페이지부터 시작
        filterState.page = 1
        // API 호출
        fetchLostItemListUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] lostItemList in
                self?.outputSubject.send(.update(lostItemList.articles))
            }
        ).store(in: &subscription)
    }
    
    private func loadMore() {
        // 필터 적용
        filterState.page += 1
        // API 호출
        fetchLostItemListUseCase.execute(requestModel: filterState).sink(
            receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.filterState.page -= 1
                }
            },
            receiveValue: { [weak self] lostItemList in
                guard let self, self.filterState.page == lostItemList.currentPage else {
                    return
                }
                self.outputSubject.send(.append(lostItemList.articles))
            }
        ).store(in: &subscription)
    }
}
