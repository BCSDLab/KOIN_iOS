//
//  OrderHomeViewModel.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import Combine

final class OrderHomeViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case getOrderShopInfo
        case filtersDidChange(Set<ShopFilter>)
        case sortDidChange(FetchOrderShopSortType)
        case categoryDidChange(Int)
        case searchTextChanged(String)
        case minPriceDidChange(Int?)
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredOrderShops([OrderShop], Int)
        case changeFilteredShops([OrderShop], Int)
        case updateEventShops([OrderShopEvent])
        case showSearchedResult([Keyword])
        case errorOccurred(Error)
        case updateFloatingButton(OrderInProgress)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var orderShopList: [OrderShop] = []
    
    private var sortStandard: FetchOrderShopListRequest = .init(sorter: .none, filter: [.isOpen], categoryFilter: nil, minimumOrderAmount: nil)
    private(set) var selectedId: Int

    private let fetchOrderEventShopUseCase: FetchOrderEventShopUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let fetchOrderShopListUseCase: FetchOrderShopListUseCase
    private let searchOrderShopUseCase: SearchOrderShopUseCase
    private let fetchOrderTrackingUseCase: FetchOrderTrackingUseCase

    init(fetchOrderEventShopUseCase: FetchOrderEventShopUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         fetchOrderShopListUseCase: FetchOrderShopListUseCase,
         fetchOrderTrackingUseCase: FetchOrderTrackingUseCase,
         searchOrderShopUseCase: SearchOrderShopUseCase,
         selectedId: Int) {
        self.fetchOrderEventShopUseCase = fetchOrderEventShopUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.fetchOrderShopListUseCase = fetchOrderShopListUseCase
        self.searchOrderShopUseCase = searchOrderShopUseCase
        self.fetchOrderTrackingUseCase = fetchOrderTrackingUseCase
        self.selectedId = selectedId
        self.sortStandard.categoryFilter = selectedId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case .viewDidLoad:
                self.getShopCategory()
                self.getEventShopList()
                self.getFloatingButtonStatus()
            case .getOrderShopInfo:
                self.getOrderShopInfo(id: self.selectedId)
            case let .filtersDidChange(filters):
                let filterTypes = filters.compactMap { $0.fetchFilterType }
                self.sortStandard.filter = filterTypes
                self.getOrderShopInfo(id: self.selectedId)
            case let .sortDidChange(sort):
                self.sortStandard.sorter = sort
                self.getOrderShopInfo(id: self.selectedId)
            case let .categoryDidChange(id):
                self.selectedId = id
                self.sortStandard.categoryFilter = id
                self.getOrderShopInfo(id: self.selectedId)
            case let .minPriceDidChange(price):
                self.sortStandard.minimumOrderAmount = price
                self.getOrderShopInfo(id: self.selectedId)
            case let .searchTextChanged(text):
                self.searchOrderShop(text)
                self.searchOrderShops(text)
            }
        }.store(in: &subscriptions)

        return outputSubject.eraseToAnyPublisher()
    }
}

extension OrderHomeViewModel {
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard self != nil else { return }
                self?.outputSubject.send(.putImage(response))
            })
            .store(in: &subscriptions)
    }
    
    private func getEventShopList() {
        fetchOrderEventShopUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] events in
                self?.outputSubject.send(.updateEventShops(events))
                self?.getOrderShopInfo(id: self?.selectedId ?? 1)
            }).store(in: &subscriptions)
    }

    private func getOrderShopInfo(id: Int) {
        fetchOrderShopListUseCase.execute(requestModel: self.sortStandard)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                    self?.outputSubject.send(.errorOccurred(error))
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                self.outputSubject.send(.changeFilteredOrderShops(response, self.selectedId))
                self.orderShopList = response
            }).store(in: &subscriptions)
    }
    
    private func searchOrderShop(_ text: String) {
        searchOrderShopUseCase.execute(text: text).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showSearchedResult(response.keywords ?? []))
        }.store(in: &subscriptions)
    }
    
    private func searchOrderShops(_ text: String) {
        let orderShops = orderShopList.filter { $0.name.contains(text) }
        outputSubject.send(.changeFilteredShops(orderShops, selectedId))
        self.orderShopList = orderShops
    }
    
    func getShopId(at index: Int) -> Int {
        return orderShopList[index].shopId
    }

    func getOrderableShopId(at index: Int) -> Int {
        return orderShopList[index].orderableShopId
    }
    
    private func getFloatingButtonStatus() {
        fetchOrderTrackingUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] trackingInfo in
                self?.outputSubject.send(.updateFloatingButton(trackingInfo))
            })
            .store(in: &subscriptions)
    }
}
