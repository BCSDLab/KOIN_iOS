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
        case changeCategory(Int)
        case sortOptionDidChange(ShopSortType)
        case filterOpenShops(Bool)

        case logEvent(EventLabelType, Any)

    }

    enum Output {
        case putImage(ShopCategoryDto)
        case changeFilteredShops([Shop], Int)
        case updateEventShops([EventDto])
        case updateSortButtonTitle(String)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchShopListUseCase: FetchShopListUseCase
    private let fetchEventListUseCase: FetchEventListUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase

    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var categories: [ShopCategory] = []
    var selectedCategoryName: String { categoryName(for: selectedId) }
    
    private var subscriptions: Set<AnyCancellable> = []

    private var sortStandard: FetchShopListRequest = .init(sorter: .none, filter: [], query: nil)
    private(set) var selectedId: Int
    private(set) var currentSortType: ShopSortType = .basic

    init(fetchShopListUseCase: FetchShopListUseCase,
         fetchEventListUseCase: FetchEventListUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         selectedId: Int = 1) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.selectedId = selectedId
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self = self else { return }
            switch input {
            case .viewDidLoad:
                self.getShopCategory()
                self.getEventShopList()
            case let .changeCategory(id):
                if self.selectedId != id {
                    self.selectedId = id
                    self.getShopInfo()
                }
            case let .sortOptionDidChange(newSortType):
                self.currentSortType = newSortType
                self.sortStandard.sorter = newSortType.fetchSortType
                self.outputSubject.send(.updateSortButtonTitle(newSortType.title))
                self.getShopInfo()
            case let .filterOpenShops(isOpen):
                self.filterOpenShops(isOpen)

            case let .logEvent(label, value):
                self.logAnalyticsEventUseCase.execute(label: label, value: value)

            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopViewModel {
    private func getShopInfo() {
        fetchShopListUseCase.execute(requestModel: sortStandard).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                let shops = response
                if self.selectedId != 0 {
                    self.outputSubject.send(.changeFilteredShops(shops.filter { $0.categoryIds.contains(self.selectedId) }, self.selectedId))
                } else {
                    self.outputSubject.send(.changeFilteredShops(shops, self.selectedId))
                }
            }
        ).store(in: &subscriptions)
    }
    
    private func getEventShopList() {
        fetchEventListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.outputSubject.send(.updateEventShops(response.events ?? []))
                self.getShopInfo()
            }
        ).store(in: &subscriptions)
    }
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute().sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] response in
                self?.categories = response.shopCategories
                self?.outputSubject.send(.putImage(response))
            }
        ).store(in: &subscriptions)
    }
    
    func categoryName(for id: Int) -> String {
        if id == 0 { return "전체보기" }
        return categories.first(where: { $0.id == id })?.name ?? "알 수 없음"
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
        getShopInfo()
    }
}
