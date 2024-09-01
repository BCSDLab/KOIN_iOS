//
//  ShopViewModel.swift
//  Koin
//
//  Created by 김나훈 on 3/12/24.
//

import Combine

final class ShopViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
        case changeCategory(Int)
        case searchTextChanged(String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
        case changeSortStandard(Any)
        case getShopInfo
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredShops([Shop], Int)
        case updateSeletecButtonColor(FetchShopListRequest)
        case updateEventShops([EventDTO])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchShopListUseCase: FetchShopListUseCase
    private let fetchEventListUseCase: FetchEventListUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let searchShopUseCase: SearchShopUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private var shopList: [Shop] = []
    private var sortStandard: FetchShopListRequest = .init(sorter: .none, filter: []) {
        didSet {
            getShopInfo(id: selectedId)
        }
    }
    private (set) var selectedId: Int {
        didSet {
            getShopInfo(id: selectedId)
        }
    }
    
    init(fetchShopListUseCase: FetchShopListUseCase, fetchEventListUseCase: FetchEventListUseCase, fetchShopCategoryListUseCase: FetchShopCategoryListUseCase, searchShopUseCase: SearchShopUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, selectedId: Int) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.searchShopUseCase = searchShopUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.selectedId = selectedId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getShopCategory()
                self?.getEventShopList()
            case let .changeCategory(id):
                self?.changeCategory(id)
            case let .searchTextChanged(text):
                self?.searchShop(text)
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case let .changeSortStandard(standard):
                self?.changeSortStandard(standard)
            case .getShopInfo:
                self?.getShopInfo(id: self?.selectedId ?? 0)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopViewModel {
    
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
        fetchShopListUseCase.execute(requestModel: FetchShopListRequest(sorter: sortStandard.sorter, filter: sortStandard.filter))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.outputSubject.send(.updateSeletecButtonColor(self.sortStandard))
                if self.selectedId != 0 {
                    self.outputSubject.send(.changeFilteredShops(response.filter { $0.categoryIds.contains(self.selectedId) }, self.selectedId))
                } else {
                    self.outputSubject.send(.changeFilteredShops(response, self.selectedId))
                }
                self.shopList = response
            }).store(in: &subscriptions)
    }
    
    private func getEventShopList() {
        fetchEventListUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.outputSubject.send(.updateEventShops(response.events ?? []))
            }).store(in: &subscriptions)
    }
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let strongSelf = self else { return }
                self?.outputSubject.send(.putImage(response))
                self?.getShopInfo(id: strongSelf.selectedId)
            }).store(in: &subscriptions)
    }
    private func searchShop(_ text: String) {
        let filteredShops = searchShopUseCase.execute(text: text, shops: shopList, categoryId: selectedId)
        outputSubject.send(.changeFilteredShops(filteredShops, selectedId))
        
        makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopCategoriesSearch, category: .click, value: selectedId)
    }
    
    private func changeCategory(_ id: Int) {
        if selectedId == id { selectedId = 0 }
        else { selectedId = id }
        
        makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopCategories, category: .click, value: MakeParamsForLog().makeValueForLogAboutStoreId(id: selectedId))
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}
