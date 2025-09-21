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
        case selectOrder(Int)
        case tapReorder(Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, EventParameter.EventLabelNeededDuration? = nil)
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
    }

    // MARK: - properties
    private let fetchHistory: FetchOrderHistoryUseCase
    private let orderService: OrderService
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase

    private var subscriptions = Set<AnyCancellable>()
    private var currentQuery = OrderHistoryQuery()
    private var currentKeyword: String = ""
    
    private var historyAccum: [OrderHistory] = []
    private var currentPageIndex: Int = 1
    private var totalPages: Int = 1
    private var isLoadingPage: Bool = false
    private let pageSize: Int = 10

    init(fetchHistory: FetchOrderHistoryUseCase, orderService: OrderService, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, getUserScreenTimeUseCase: GetUserScreenTimeUseCase) {
        self.fetchHistory = fetchHistory
        self.orderService = orderService
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        let subject = PassthroughSubject<Output, Never>()

        let historyTrigger = input
            .filter {
                switch $0 {
                case .viewDidLoad, .refresh, .applyQuery, .search, .loadNextPage: return true
                default: return false
                }
            }

        let preparingTrigger = input
            .filter {
                switch $0 {
                case .viewDidLoad, .refresh: return true
                default: return false
                }
            }
        historyTrigger
            .flatMap { [weak self] Input -> AnyPublisher<(OrdersPage, Bool), Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "OrderVM", code: -1)).eraseToAnyPublisher()
                }
                switch Input {
                case .applyQuery(let query):
                    self.currentQuery = query
                    self.currentQuery.page = 1
                    self.currentQuery.size = self.pageSize
                    self.currentPageIndex = 1
                    self.historyAccum = []
                    self.isLoadingPage = true
                    
                    return self.fetchHistory.execute(query: self.currentQuery)
                        .map{($0,false)}
                        .eraseToAnyPublisher()
        
                case .viewDidLoad, .refresh, .search:
                    if case .search(let text) = Input {
                        self.currentQuery.keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    self.currentQuery.page = 1
                    self.currentQuery.size = self.pageSize
                    self.currentPageIndex = 1
                    self.totalPages = 1
                    self.historyAccum = []
                    self.isLoadingPage = true

                    return self.fetchHistory.execute(query: self.currentQuery)
                        .map { ($0, false) }
                        .eraseToAnyPublisher()

                case .loadNextPage:
                    guard !self.isLoadingPage, self.currentPageIndex < self.totalPages else {
                        return Empty<(OrdersPage, Bool), Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    self.isLoadingPage = true
                    
                    self.currentQuery.page = self.currentPageIndex + 1
                    self.currentQuery.size = self.pageSize


                    return self.fetchHistory.execute(query: self.currentQuery)
                        .map { ($0, true) }
                        .eraseToAnyPublisher()

                default:
                    return Empty<(OrdersPage, Bool), Error>(completeImmediately: true).eraseToAnyPublisher()
                }
            }
            .map { [weak self] (page, isAppend) -> Output in
                guard let self else { return .showEmpty(true) }
                self.currentPageIndex = page.currentPage
                self.totalPages = page.totalPage
                self.isLoadingPage = false

                let list = page.orders

                if isAppend {
                    self.historyAccum.append(contentsOf: list)
                    return .appendOrders(list)
                } else {
                    self.historyAccum = list
                    return list.isEmpty ? .showEmpty(true) : .updateOrders(list)
                }
            }
            .catch { [weak self] err in
                self?.isLoadingPage = false
                return Just(Output.errorOccurred(err))
            }
            .merge(with: Just(Output.endRefreshing))
            .sink { subject.send($0) }
            .store(in: &subscriptions)
        preparingTrigger
            .flatMap { [weak self] _ -> AnyPublisher<[OrderInProgress], Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "OrderVM", code: -2)).eraseToAnyPublisher()
                }
                return self.orderService.fetchOrderInProgress()
            }
            .map { Output.updatePreparing($0) }
            .catch { _ in Just(Output.updatePreparing([])) }
            .sink { subject.send($0) }
            .store(in: &subscriptions)
        input
            .sink { event in
                switch event {
                case .selectOrder(let id):
                    subject.send(.navigateToOrderDetail(id))
                case .tapReorder:
                    break
                default:
                    break
                }
            }
            .store(in: &subscriptions)

        return subject.eraseToAnyPublisher()
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

extension DateFormatter {
    static let orderKR: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "M월 d일 (E)"
        return f
    }()
}

extension NumberFormatter {
    static let krCurrencyNoFraction: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ko_KR")
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        nf.usesGroupingSeparator = true
        return nf
    }()
}
