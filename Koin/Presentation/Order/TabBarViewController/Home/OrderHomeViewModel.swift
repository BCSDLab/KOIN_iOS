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
            print("OrderHomeViewModel transform input:", input)
            switch input {
            case .viewDidLoad:
                print("OrderHomeViewModel: viewDidLoad input received")
                self?.getShopCategory()
                self?.getOrderShopInfo(id: self?.selectedId ?? 0)
            case .getOrderShopInfo:
                print("OrderHomeViewModel: viewDidLoad input received")
                self?.getOrderShopInfo(id: self?.selectedId ?? 0)
            case let .filtersDidChange(filters):
                let filterTypes = filters.compactMap { $0.fetchFilterType }
                self?.sortStandard.filter = filterTypes
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
        print("OrderHomeViewModel: getOrderShopInfo called")
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
