//
//  OrderHistoryViewModel.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

final class OrderHistoryViewModel {
    // MARK: Input
    enum Input {
        case viewDidLoad
        case refresh
        case applyQuery(OrderHistoryQuery)
        case search(String)
        case loadNextPage
        
//        case selectOrder(Int)
//        case tapReorder(Int)
//        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, EventParameter.EventLabelNeededDuration? = nil)
    }

    // MARK: Output
    enum Output {
        case updateOrders([OrderHistory])
        case appendOrders([OrderHistory])
        case updatePreparing([OrderInProgress])
        case showEmpty(Bool)
        case errorOccurred(Error)
        case endRefreshing
        case navigateToOrderDetail(Int)
        case scrollToTop
    }

    // MARK: - properties
    private let fetchHistory: FetchOrderHistoryUseCase
    private let orderService: OrderService
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase

    private var subscriptions = Set<AnyCancellable>()
    private let outputSubject = PassthroughSubject<Output, Never>()

    private var currentQuery = OrderHistoryQuery()
    private var currentKeyword: String = ""
    
    private var historyAccum: [OrderHistory] = []
    private var currentPageIndex: Int = 1
    private var totalPages: Int = 1
    private var isLoadingPage: Bool = false
    private let pageSize: Int = 10

    init(fetchHistory: FetchOrderHistoryUseCase, orderService: OrderService, logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
        getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    ) {
        self.fetchHistory = fetchHistory
        self.orderService = orderService
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink{ [weak self] input in
                guard let self else { return }
                
                switch input {
                case .viewDidLoad:
                    self.fetchOrderPrepare()
                    self.fetchOrderHistory()
                    
                case .refresh:
                    self.fetchOrderPrepare()
                    self.fetchOrderHistory()
                    
                case .applyQuery(let query):
                    var query = query
                    if query.keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                        query.keyword = self.currentQuery.keyword
                    }
                    self.currentQuery = query
                    
                    self.outputSubject.send(.scrollToTop)
                    self.fetchOrderHistory()
                    
                case .search(let text):
                    self.search(text)
                    self.outputSubject.send(.scrollToTop)
                    
                case .loadNextPage:
                    self.fetchNextPage()
                    
//                case .selectOrder(let id):
//                    self.outputSubject.send(.navigateToOrderDetail(id))
                    
//                case .tapReorder(_):
//                    <#code#>
//                case .logEvent(_, _, _, _, _):
//                    <#code#>
                }
// 나중에 연결

                
            }.store(in: &subscriptions)
            
        return outputSubject.eraseToAnyPublisher()
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, durationType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if durationType != nil {
            let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: nil, currentPage: nil, durationTime: "\(durationTime)")
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
}

extension OrderHistoryViewModel{
    
    private func fetchOrderHistory() {
        currentQuery.page = 1
        currentQuery.size = pageSize
        currentPageIndex = 1
        totalPages = 1
        historyAccum = []
        isLoadingPage = true

        fetchHistory.execute(query: currentQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingPage = false
                if case let .failure(error) = completion {
                    self.outputSubject.send(.errorOccurred(error))
                }
                self.outputSubject.send(.endRefreshing)
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.currentPageIndex = page.currentPage
                self.totalPages = page.totalPage

                let list = page.orders
                self.historyAccum = list
                self.outputSubject.send(list.isEmpty ? .showEmpty(true) : .updateOrders(list))
            }
            .store(in: &subscriptions)
    }

    private func fetchNextPage() {
        guard !isLoadingPage, currentPageIndex < totalPages else { return }
        isLoadingPage = true
        currentQuery.page = currentPageIndex + 1
        currentQuery.size = pageSize

        fetchHistory.execute(query: currentQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingPage = false
                if case let .failure(error) = completion {
                    self.outputSubject.send(.errorOccurred(error))
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.currentPageIndex = page.currentPage
                self.totalPages = page.totalPage
                let list = page.orders
                self.historyAccum.append(contentsOf: list)
                self.outputSubject.send(.appendOrders(list))
            }
            .store(in: &subscriptions)
    }
    
    private func fetchOrderPrepare() {
         orderService.fetchOrderInProgress()
             .receive(on: DispatchQueue.main)
             .sink { [weak self] completion in
                 guard let self else { return }
                 if case .failure = completion {
                     self.outputSubject.send(.updatePreparing([]))
                 }
             } receiveValue: { [weak self] inProgress in
                 self?.outputSubject.send(.updatePreparing(inProgress))
             }
             .store(in: &subscriptions)
     }
    
    private func fetchFilter(period: OrderHistoryPeriod? = nil,
                             status: OrderHistoryStatus? = nil,
                             type: OrderHistoryType? = nil,
                             keyword: String = ""){
        currentQuery.apply(period: period , status: status , type: type, keyword: keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        fetchOrderHistory()
        fetchNextPage()
    }
    
    private func search(_ text: String){
        let keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuery.apply(keyword: keyword)
        fetchOrderHistory()
        fetchNextPage()
    }
    
    private func resetFilter(){
        currentQuery.resetFilter()
        currentQuery.keyword = ""
        fetchOrderHistory()
        fetchNextPage()
    }
}

