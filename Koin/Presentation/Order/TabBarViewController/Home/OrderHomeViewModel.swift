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
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredOrderShops([OrderShop], Int)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var orderShopList: [OrderShop] = []
    private var sortStandard: FetchOrderShopListRequest = .init(sorter: .none, filter: [.isOpen]) {
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
    
    init(fetchShopCategoryListUseCase: FetchShopCategoryListUseCase, fetchOrderShopListUseCase: FetchOrderShopListUseCase, selectedId: Int) {
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.fetchOrderShopListUseCase = fetchOrderShopListUseCase
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
        fetchOrderShopListUseCase.execute(requestModel: FetchOrderShopListRequest(sorter: sortStandard.sorter, filter: sortStandard.filter))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                var filteredShops = response

                if self.sortStandard.filter.contains(.deliveryAvailable) {
                    filteredShops = filteredShops.filter { $0.isDeliveryAvailable }
                }

                if self.selectedId != 0 {
                    self.outputSubject.send(.changeFilteredOrderShops(filteredShops.filter { $0.categoryIds.contains(self.selectedId) }, self.selectedId))
                } else {
                    self.outputSubject.send(.changeFilteredOrderShops(filteredShops, self.selectedId))
                }
                self.orderShopList = response
            }).store(in: &subscriptions)
    }
}
