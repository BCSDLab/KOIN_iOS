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
        case applyFilter(OrderHistoryFilter)
        case search(String)
        case loadNextPage
        case selectOrder(Int)
        case tapReorder(Int)
    }

    // MARK: Output
    enum Event {
        case updateOrders([OrderItem])
        case appendOrders([OrderItem])
        case updatePreparing([PreparingItem])
        case showEmpty(Bool)
        case errorOccurred(Error)
        case endRefreshing
        case navigateToOrderDetail(Int)
    }

    struct OrderItem {
        let id: Int
        let paymentId: Int
        let stateText: String
        let dateText: String
        let storeName: String
        let menuName: String
        let priceText: String
        let imageURL: URL?
        let canReorder: Bool
    }

    struct PreparingItem {
        let stateText: String
        let id: Int
        let paymentId: Int
        let methodText: String
        let estimatedTimeText: String
        let explanationText: String
        let imageURL: URL?
        let storeName: String
        let menuName: String
        let priceText: String
        let status: OrderInProgressStatus
    }

    // MARK: - Deps
    private let fetchHistory: FetchOrderHistoryUseCase
    private let orderService: OrderService

    // MARK: - State
    private var subscriptions = Set<AnyCancellable>()
    private var currentFilter: OrderHistoryFilter = .empty
    private var currentKeyword: String = ""
    
    // MARK: - Pagination
    private var historyAccum: [OrderItem] = []
    private var currentPageIndex: Int = 1
    private var totalPages: Int = 1
    private var isLoadingPage: Bool = false
    private let pageSize: Int = 10

    init(fetchHistory: FetchOrderHistoryUseCase, orderService: OrderService) {
        self.fetchHistory = fetchHistory
        self.orderService = orderService
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Event, Never> {
        let subject = PassthroughSubject<Event, Never>()

        let historyTrigger = input
            .filter {
                switch $0 {
                case .viewDidLoad, .refresh, .applyFilter, .search, .loadNextPage: return true
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
            .flatMap { [weak self] event -> AnyPublisher<(OrdersPage, Bool), Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "OrderVM", code: -1)).eraseToAnyPublisher()
                }
                switch event {
                case .applyFilter(let f):
                    self.currentFilter = f
                    fallthrough

                case .viewDidLoad, .refresh, .search:
                    if case .search(let text) = event {
                        self.currentKeyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    self.currentPageIndex = 1
                    self.totalPages = 1
                    self.historyAccum = []
                    self.isLoadingPage = true

                    var query = self.currentFilter.toDomainQuery(keyword: self.currentKeyword)
                    query.page = self.currentPageIndex
                    query.size = self.pageSize
                    

                    return self.fetchHistory.execute(query: query)
                        .map { ($0, false) }
                        .eraseToAnyPublisher()

                case .loadNextPage:
                    guard !self.isLoadingPage, self.currentPageIndex < self.totalPages else {
                        return Empty<(OrdersPage, Bool), Error>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    self.isLoadingPage = true

                    var query = self.currentFilter.toDomainQuery(keyword: self.currentKeyword)
                    query.page = self.currentPageIndex + 1
                    query.size = self.pageSize

                    return self.fetchHistory.execute(query: query)
                        .map { ($0, true) }
                        .eraseToAnyPublisher()

                default:
                    return Empty<(OrdersPage, Bool), Error>(completeImmediately: true).eraseToAnyPublisher()
                }
            }
            .map { [weak self] (page, isAppend) -> Event in
                guard let self else { return .showEmpty(true) }
                self.currentPageIndex = page.currentPage
                self.totalPages = page.totalPage
                self.isLoadingPage = false

                let mapped = page.orders.map(self.mapToItem(_:))

                if isAppend {
                    self.historyAccum.append(contentsOf: mapped)
                    return .appendOrders(mapped)
                } else {
                    self.historyAccum = mapped
                    return mapped.isEmpty ? .showEmpty(true) : .updateOrders(mapped)
                }
            }
            .catch { [weak self] err in
                self?.isLoadingPage = false
                return Just(Event.errorOccurred(err))
            }
            .merge(with: Just(Event.endRefreshing))
            .sink { subject.send($0) }
            .store(in: &subscriptions)
        preparingTrigger
            .flatMap { [weak self] _ -> AnyPublisher<[OrderInProgress], Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "OrderVM", code: -2)).eraseToAnyPublisher()
                }
                return self.orderService.fetchOrderInProgress()
            }
            .map { [weak self] list -> Event in        
                let viewModels = list.compactMap { self?.mapToPreparingItem($0) }
                return .updatePreparing(viewModels)
            }
            .catch { _ in Just(Event.updatePreparing([])) }
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

    // MARK: - Mapping (History)
    private func mapToItem(_ order: OrderHistory) -> OrderItem {
        let stateText: String = {
            switch order.status {
            case .delivered: return "배달완료"
            case .pickedUp: return "포장완료"
            case .canceled: return "취소완료"
            }
        }()

        let dateText: String = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "ko_KR")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            f.dateFormat = "M월 d일 (E)"
            return f.string(from: order.orderDate)
        }()

        let priceText: String = {
            let nf = NumberFormatter()
            nf.locale = Locale(identifier: "ko_KR")
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 0
            nf.usesGroupingSeparator = true
            return "\(nf.string(from: NSNumber(value: order.totalAmount)) ?? "\(order.totalAmount)") 원"
        }()

        let canReorder = (order.status == .delivered || order.status == .pickedUp)
        && order.openStatus == order.openStatus

        return OrderItem(
            id: order.id,
            paymentId: order.paymentId,
            stateText: stateText,
            dateText: dateText,
            storeName: order.shopName,
            menuName: order.orderTitle,
            priceText: priceText,
            imageURL: order.shopThumbnail,
            canReorder: canReorder
        )
    }

    // MARK: - Mapping (Preparing)
    private func mapToPreparingItem(_ orderInProgress: OrderInProgress) -> PreparingItem {
        let methodText = (orderInProgress.type == .delivery) ? "배달" : "포장"
        
        let estimatedTime: String = {
            if orderInProgress.estimatedTime == "시간 미정" {
                return "시간 미정"
            }
            switch orderInProgress.type {
            case .delivery:
                return "\(orderInProgress.estimatedTime) 도착 예정"
            case .takeout:
                return "\(orderInProgress.estimatedTime) 수령 가능"
            }
        }()


        let stateText: String = {
            switch orderInProgress.type {
            case .delivery:
                switch orderInProgress.status {
                case .confirming: return "주문 확인 중"
                case .cooking: return "조리 중"
                case .delivering: return "배달 출발"
                case .delivered: return "배달 완료"
                case .canceled: return "주문 취소"
                default: return ""
                }
            case .takeout:
                switch orderInProgress.status {
                case .confirming: return "주문 확인 중"
                case .cooking: return "조리 중"
                case .packaged, .pickedUp: return "수령 가능"
                case .canceled: return "주문 취소"
                default: return ""
                }
            }
        }()

        let explanation: String = {
            switch orderInProgress.type {
            case .delivery:
                switch orderInProgress.status {
                case .confirming: return "사장님이 주문을 확인하고 있어요!"
                case .cooking: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .delivering: return "열심히 달려가는 중이에요!"
                case .delivered: return "배달이 완료되었어요. 감사합니다!"
                case .packaged, .pickedUp: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .canceled: return "주문이 취소되었어요."
                }
            case .takeout:
                switch orderInProgress.status {
                case .confirming: return "사장님이 주문을 확인하고 있어요!"
                case .cooking: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .packaged, .pickedUp, .delivered: return "준비가 완료되었어요!"
                case .delivering: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .canceled: return "주문이 취소되었어요."
                }
            }
        }()

        let priceText: String = {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: "ko_KR")
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.usesGroupingSeparator = true
            return "\(numberFormatter.string(from: NSNumber(value: orderInProgress.totalAmount)) ?? "\(orderInProgress.totalAmount)") 원"
        }()

        return PreparingItem(
            stateText: stateText,
            id: orderInProgress.id,
            paymentId: orderInProgress.paymentId,
            methodText: methodText,
            estimatedTimeText: estimatedTime,
            explanationText: explanation,
            imageURL: URL(string: orderInProgress.orderableShopThumbnail),
            storeName: orderInProgress.orderableShopName,
            menuName: orderInProgress.orderTitle,
            priceText: priceText,
            status: orderInProgress.status
        )
    }
}
