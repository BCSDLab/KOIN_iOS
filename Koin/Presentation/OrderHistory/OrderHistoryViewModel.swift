//
//  OrderViewModel.swift
//  koin
//
//  Created by 김성민 on 9/10/25.
//

import Foundation
import Combine

final class OrderViewModel {
    // MARK: Input
    enum Input {
        case viewDidLoad
        case refresh
        case applyFilter(OrderFilter)
        case search(String)
        case selectOrder(Int)
        case tapReorder(Int)
    }

    // MARK: Output
    enum Event {
        case updateOrders([OrderItem])
        case updatePreparing([PreparingItem])
        case showEmpty(Bool)
        case errorOccurred(Error)
        case endRefreshing
        case navigateToOrderDetail(Int)
    }

    // 지난 주문 셀 뷰데이터
    struct OrderItem {
        let id: Int
        let stateText: String        // 배달완료 / 포장완료
        let dateText: String         // 예: 8월 16일 (토)
        let storeName: String        // 예: 맛있는 족발 - 병천점
        let menuName: String         // 예: 족발 + 막국수 set 외 1건
        let priceText: String        // 예: 32,500 원
        let imageURL: URL?
        let canReorder: Bool
    }

    // 준비중 셀 뷰데이터
    struct PreparingItem {
        let stateText: String        // 상단 상태 배지: 주문 확인 중/조리 중/배달 출발/배달 완료/수령 가능/주문 취소
        let id: Int
        let methodText: String       // 배달 / 포장
        let estimatedTimeText: String// 오전/오후 h시 m분 도착 예정 / 시간 미정
        let explanationText: String  // 상태 안내문
        let imageURL: URL?
        let storeName: String
        let menuName: String
        let priceText: String
    }

    // MARK: - Deps
    private let fetchHistory: FetchOrderHistoryUseCase
    private let orderService: OrderService

    // MARK: - State
    private var subscriptions = Set<AnyCancellable>()
    private var currentFilter: OrderFilter = .empty
    private var currentKeyword: String = ""

    init(fetchHistory: FetchOrderHistoryUseCase, orderService: OrderService) {
        self.fetchHistory = fetchHistory
        self.orderService = orderService
    }

    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Event, Never> {
        let subject = PassthroughSubject<Event, Never>()

        let trigger = input
            .filter {
                if case .viewDidLoad = $0 { return true }
                if case .refresh = $0 { return true }
                if case .applyFilter = $0 { return true }
                if case .search = $0 { return true }
                return false
            }

        // 지난 주문 파이프라인
        trigger
            .flatMap { [weak self] event -> AnyPublisher<[Order], Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "", code: -1)).eraseToAnyPublisher()
                }
                if case .applyFilter(let f) = event { self.currentFilter = f }
                if case .search(let text) = event {
                    self.currentKeyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
                }

                let query = self.currentFilter.toDomainQuery(keyword: self.currentKeyword)
                print("history query:", OrderHistoryQueryDTO(query).asParameters)

                return self.fetchHistory.execute(query: query)
            }
            .map { [weak self] orders -> Event in
                guard let self else { return .showEmpty(true) }
                let items = orders.map(self.mapToItem(_:))
                return items.isEmpty ? .showEmpty(true) : .updateOrders(items)
            }
            .catch { Just(Event.errorOccurred($0)) }
            .merge(with: Just(Event.endRefreshing))
            .sink { subject.send($0) }
            .store(in: &subscriptions)

        // 준비중 파이프라인
        trigger
            .flatMap { [weak self] _ -> AnyPublisher<[OrderInProgress], Error> in
                guard let self else {
                    return Fail(error: NSError(domain: "", code: -1)).eraseToAnyPublisher()
                }
                return self.orderService.fetchOrderInProgress()
            }
            .map { [weak self] list -> Event in
                print("preparing -> entities:", list.count)
                let vms = list.compactMap { self?.mapToPreparingItem($0) }
                return .updatePreparing(vms)
            }
            .catch { _ in Just(Event.updatePreparing([])) }
            .sink { subject.send($0) }
            .store(in: &subscriptions)

        // 재주문 , 상세 선택
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
    private func mapToItem(_ order: Order) -> OrderItem {
        let stateText: String = {
            switch order.status {
            case .delivered: return "배달완료"
            case .packaged, .pickedUp: return "포장완료"
            default: return ""
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

        let canReorder = (order.status == .delivered || order.status == .packaged)
            && order.openStatus == .operating

        return OrderItem(
            id: order.id,
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
    private func mapToPreparingItem(_ e: OrderInProgress) -> PreparingItem {
        let methodText = (e.type == .delivery) ? "배달" : "포장"
        let eta = (e.estimatedTime == "시간 미정") ? "시간 미정" : "\(e.estimatedTime) 도착 예정"

        let stateText: String = {
            switch e.type {
            case .delivery:
                switch e.status {
                case .confirming: return "주문 확인 중"
                case .cooking, .packaged, .pickedUp: return "조리 중"
                case .delivering: return "배달 출발"
                case .delivered: return "배달 완료"
                case .canceled: return "주문 취소"
                }
            case .takeout:
                switch e.status {
                case .confirming: return "주문 확인 중"
                case .cooking: return "조리 중"
                case .packaged, .pickedUp, .delivered: return "수령 가능"
                case .delivering: return "조리 중"
                case .canceled: return "주문 취소"
                }
            }
        }()

        let explanation: String = {
            switch e.type {
            case .delivery:
                switch e.status {
                case .confirming: return "사장님이 주문을 확인하고 있어요!"
                case .cooking: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .delivering: return "열심히 달려가는 중이에요!"
                case .delivered: return "배달이 완료되었어요. 감사합니다!"
                case .packaged, .pickedUp: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .canceled: return "주문이 취소되었어요."
                }
            case .takeout:
                switch e.status {
                case .confirming: return "사장님이 주문을 확인하고 있어요!"
                case .cooking: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .packaged, .pickedUp, .delivered: return "준비가 완료되었어요!"
                case .delivering: return "가게에서 열심히 음식을 조리하고 있어요!"
                case .canceled: return "주문이 취소되었어요."
                }
            }
        }()

        let priceText: String = {
            let nf = NumberFormatter()
            nf.locale = Locale(identifier: "ko_KR")
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 0
            nf.usesGroupingSeparator = true
            return "\(nf.string(from: NSNumber(value: e.totalAmount)) ?? "\(e.totalAmount)") 원"
        }()

        return PreparingItem(
            stateText: stateText,
            id: e.id,
            methodText: methodText,
            estimatedTimeText: eta,
            explanationText: explanation,
            imageURL: URL(string: e.orderableShopThumbnail),
            storeName: e.orderableShopName,
            menuName: e.orderTitle,
            priceText: priceText
        )
    }
}
