//
//  ShopViewModel.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine
import Foundation

final class ShopViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case viewDidLoadB
        case changeCategory(Int)
        case searchTextChanged(String)
        case changeSortStandard(Any)
        case sortDidChange(FetchShopSortType)
        case filterOpenShops(Bool)
        case getShopInfo
        case getShopBenefits
        case getBeneficialShops(Int)
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredShops([Shop], Int)
        case updateEventShops([EventDTO])
        case updateShopBenefits(ShopBenefitsDTO)
        case updateBeneficialShops([Shop])
        case showSearchedResult([Keyword])
        case navigateToShopData(Int, String, Int)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchShopListUseCase: FetchShopListUseCase
    private let fetchEventListUseCase: FetchEventListUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let searchShopUseCase: SearchShopUseCase
    private let fetchShopBenefitUseCase: FetchShopBenefitUseCase
    private let fetchBeneficialShopUseCase: FetchBeneficialShopUseCase
    
    private var subscriptions: Set<AnyCancellable> = []
    private var shopList: [Shop] = []
    
    private var sortStandard: FetchShopListRequest = .init(sorter: .none, filter: [], query: nil)
    private(set) var selectedId: Int
    
    init(fetchShopListUseCase: FetchShopListUseCase,
         fetchEventListUseCase: FetchEventListUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         searchShopUseCase: SearchShopUseCase,
         fetchShopBenefitUseCase: FetchShopBenefitUseCase,
         fetchBeneficialShopUseCase: FetchBeneficialShopUseCase,
         selectedId: Int) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.searchShopUseCase = searchShopUseCase
        self.fetchShopBenefitUseCase = fetchShopBenefitUseCase
        self.fetchBeneficialShopUseCase = fetchBeneficialShopUseCase
        self.selectedId = selectedId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case .viewDidLoad:  // 주변 상점
                self.getShopCategory()
                self.getEventShopList()
            case let .changeCategory(id):
                if self.selectedId != id {
                    self.selectedId = id
                    self.getShopInfo(id: self.selectedId)
                }
            case let .searchTextChanged(text):
                self.sortStandard.query = text
                self.getShopInfo(id: self.selectedId)
                self.searchShop(text)
                self.searchShops(text)
            case let .changeSortStandard(standard):
                self.changeSortStandard(standard)
            case let .sortDidChange(sortType):
                self.sortStandard.sorter = sortType
                self.getShopInfo(id: self.selectedId)
            case .getShopInfo:
                self.getShopInfo(id: self.selectedId)
            case .getShopBenefits:
                self.fetchShopBenefits()
            case let .getBeneficialShops(id):
                self.fetchBeneficialShops(id: id)
            case let .filterOpenShops(isOpen):
                self.filterOpenShops(isOpen)
            case .viewDidLoadB:
                self.fetchShopBenefits()
                self.getEventShopList()
                self.fetchBeneficialShops(id: 1)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopViewModel {
    private func searchShops(_ text: String) {
        let shops = shopList.filter { $0.name.contains(text) }
        outputSubject.send(.changeFilteredShops(shops, selectedId))
    }
    
    private func fetchShopBenefits() {
        fetchShopBenefitUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateShopBenefits(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchBeneficialShops(id: Int) {
        fetchBeneficialShopUseCase.execute(id: id).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateBeneficialShops(response))
        }.store(in: &subscriptions)
    }
    
    private func changeSortStandard(_ standard: Any) {
        if let sortType = standard as? FetchShopSortType {
            if sortStandard.sorter == sortType {
                sortStandard.sorter = .none
            } else {
                sortStandard.sorter = sortType
            }
        } else if let filterType = standard as? FetchShopFilterType {
            if let index = sortStandard.filter.firstIndex(of: filterType) {
                sortStandard.filter.remove(at: index)
            } else {
                sortStandard.filter.append(filterType)
            }
        }
    }
    
    private func getShopInfo(id: Int) {
        fetchShopListUseCase.execute(requestModel: sortStandard)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                let shops = response
                if self.selectedId != 0 {
                    self.outputSubject.send(.changeFilteredShops(shops.filter { $0.categoryIds.contains(self.selectedId) }, self.selectedId))
                } else {
                    self.outputSubject.send(.changeFilteredShops(shops, self.selectedId))
                }
                self.shopList = response
            }).store(in: &subscriptions)
    }
    
    private func getEventShopList() {
        fetchEventListUseCase.execute()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.outputSubject.send(.updateEventShops(response.events ?? []))
                self.getShopInfo(id: self.selectedId)
            }).store(in: &subscriptions)
    }
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.outputSubject.send(.putImage(response))
            }).store(in: &subscriptions)
    }
    
    private func searchShop(_ text: String) {
        searchShopUseCase.execute(text: text).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showSearchedResult(response.keywords ?? []))
        }.store(in: &subscriptions)
    }
    
    private func changeCategory(_ id: Int) {
        if selectedId != id {
            selectedId = id
        }
    }
    
    private func filterOpenShops(_ isOpen: Bool) {
        if isOpen {
            if !sortStandard.filter.contains(.open) {
                sortStandard.filter.append(.open)
            }
        } else {
            if let index = sortStandard.filter.firstIndex(of: .open) {
                sortStandard.filter.remove(at: index)
            }
        }
        getShopInfo(id: selectedId)
    }
    
    func getShopId(at index: Int) -> Int {
        return shopList[index].id
    }
}
