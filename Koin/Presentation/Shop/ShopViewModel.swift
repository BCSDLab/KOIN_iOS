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
        case sortOptionDidChange(ShopSortType)
        case filterOpenShops(Bool)
        case getShopInfo
        case getShopBenefits
        case getBeneficialShops(Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case logEventDirect(EventLabelType, EventParameter.EventCategory, Any)
        
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
     
    
    enum Output {
        case putImage(ShopCategoryDto)
        case changeFilteredShops([Shop], Int)
        case updateEventShops([EventDto])
        case updateShopBenefits(ShopBenefitsDto)
        case updateBeneficialShops([Shop])
        case showSearchedResult([Keyword])
        case navigateToShopData(Int, String, Int)
        case updateSortButtonTitle(String)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchShopListUseCase: FetchShopListUseCase
    private let fetchEventListUseCase: FetchEventListUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let searchShopUseCase: SearchShopUseCase
    private let fetchShopBenefitUseCase: FetchShopBenefitUseCase
    private let fetchBeneficialShopUseCase: FetchBeneficialShopUseCase

    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private var categories: [ShopCategory] = []
    private var lastCategoryId: Int?
    
    private var subscriptions: Set<AnyCancellable> = []
    private var shopList: [Shop] = []
    
    private var sortStandard: FetchShopListRequest = .init(sorter: .none, filter: [], query: nil)
    private(set) var selectedId: Int
    private(set) var currentSortType: ShopSortType = .basic

    init(fetchShopListUseCase: FetchShopListUseCase,
         fetchEventListUseCase: FetchEventListUseCase,
         fetchShopCategoryListUseCase: FetchShopCategoryListUseCase,
         searchShopUseCase: SearchShopUseCase,
         fetchShopBenefitUseCase: FetchShopBenefitUseCase,
         fetchBeneficialShopUseCase: FetchBeneficialShopUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         getUserScreenTimeUseCase: GetUserScreenTimeUseCase,
         selectedId: Int) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.searchShopUseCase = searchShopUseCase
        self.fetchShopBenefitUseCase = fetchShopBenefitUseCase
        self.fetchBeneficialShopUseCase = fetchBeneficialShopUseCase
        self.selectedId = selectedId
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
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
                    self.getShopInfo(id: self.selectedId)
                }
            case let .searchTextChanged(text):
                self.sortStandard.query = text
                self.getShopInfo(id: self.selectedId)
                self.searchShop(text)
                self.searchShops(text)
            case let .sortOptionDidChange(newSortType):
                self.currentSortType = newSortType
                self.sortStandard.sorter = newSortType.fetchSortType
                self.outputSubject.send(.updateSortButtonTitle(newSortType.title))
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
                
            case let .logEvent(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                self.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, screenActionType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
                
            case let .logEventDirect(label, category, value):
                self.logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
                
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)

            
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
                self?.categories = response.shopCategories
                self?.outputSubject.send(.putImage(response))
            }).store(in: &subscriptions)
    }
    
    private func categoryName(for id: Int) -> String {
        if id == 0 { return "전체보기" }
        return categories.first(where: { $0.id == id })?.name ?? "알 수 없음"
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

extension ShopViewModel {
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, screenActionType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration != nil {
            var durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            
            if eventLabelNeededDuration == .shopCategories || eventLabelNeededDuration == .shopCategoriesBack || eventLabelNeededDuration == .shopClick {
                durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            }
            
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }


}
