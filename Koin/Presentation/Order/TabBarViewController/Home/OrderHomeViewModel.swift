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
        case showSearchedResult([Keyword])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var orderShopList: [OrderShop] = []
    private var sortStandard: FetchOrderShopListRequest = .init(sorter: .none, filter: [.isOpen], minimumOrderAmount: nil) {
        didSet {
            getOrderShopInfo(id: selectedId)
        }
    }
    
    private (set) var selectedId: Int {
        didSet {
            getOrderShopInfo(id: selectedId)
        }
    }

    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let fetchOrderShopListUseCase: FetchOrderShopListUseCase
    private let searchOrderShopUseCase: SearchOrderShopUseCase
    
    init(fetchShopCategoryListUseCase: FetchShopCategoryListUseCase, fetchOrderShopListUseCase: FetchOrderShopListUseCase, searchOrderShopUseCase: SearchOrderShopUseCase, selectedId: Int) {
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.fetchOrderShopListUseCase = fetchOrderShopListUseCase
        self.searchOrderShopUseCase = searchOrderShopUseCase
        self.selectedId = selectedId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getShopCategory()
                self?.getOrderShopInfo(id: self?.selectedId ?? 1)
            case .getOrderShopInfo:
                self?.getOrderShopInfo(id: self?.selectedId ?? 1)
            case let .filtersDidChange(filters):
                let filterTypes = filters.compactMap { $0.fetchFilterType }
                self?.sortStandard.filter = filterTypes
            case let .sortDidChange(sort):
                self?.sortStandard.sorter = sort
            case let .categoryDidChange(id):
                self?.selectedId = id
            case let .searchTextChanged(text):
                self?.searchOrderShop(text)
                self?.searchOrderShops(text)
            case let .minPriceDidChange(price):
                self?.sortStandard.minimumOrderAmount = price
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

    private func getOrderShopInfo(id: Int) {
        fetchOrderShopListUseCase.execute(requestModel: FetchOrderShopListRequest(sorter: sortStandard.sorter, filter: sortStandard.filter, minimumOrderAmount: sortStandard.minimumOrderAmount))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                var filteredShops = response

                if self.sortStandard.filter.contains(.isOpen) {
                    filteredShops = filteredShops.filter { $0.isOpen }
                }

                if self.sortStandard.filter.contains(.deliveryAvailable) {
                    filteredShops = filteredShops.filter { $0.isDeliveryAvailable }
                }
                
                if let minPrice = self.sortStandard.minimumOrderAmount {
                    filteredShops = filteredShops.filter { $0.minimumOrderAmount ?? 0 <= minPrice }
                }

                if self.selectedId != 0 {
                    self.outputSubject.send(.changeFilteredOrderShops(filteredShops.filter { $0.categoryIds.contains(self.selectedId) }, self.selectedId))
                } else {
                    self.outputSubject.send(.changeFilteredOrderShops(filteredShops, self.selectedId))
                }
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
    }
    
    func getShopId(at index: Int) -> Int {
        return orderShopList[index].shopId
    }
}
