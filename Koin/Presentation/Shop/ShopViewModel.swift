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
        case searchTextChanged(String)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredShops([ShopDTO], Int)
        case updateEventShops([EventDTO])
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchShopListUseCase: FetchShopListUseCase
    private let fetchEventListUseCase: FetchEventListUseCase
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let searchShopUseCase: SearchShopUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private var shopDTO: ShopsDTO = ShopsDTO(count: 0, shops: [])
    private (set) var selectedId: Int {
        didSet {
            getShopInfo(id: selectedId)
        }
    }
  
    init(fetchShopListUseCase: FetchShopListUseCase, fetchEventListUseCase: FetchEventListUseCase, fetchShopCategoryListUseCase: FetchShopCategoryListUseCase, searchShopUseCase: SearchShopUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, getUserScreenTimeUseCase: GetUserScreenTimeUseCase, selectedId: Int) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.searchShopUseCase = searchShopUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
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
            case let .logEvent(label, category, value, currentPage, durationType, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value,currentPage: currentPage, durationType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopViewModel {
    
    private func getShopInfo(id: Int) {
        fetchShopListUseCase.execute(id: id)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.outputSubject.send(.changeFilteredShops(response.shops ?? [], self.selectedId))
                self.shopDTO = response
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
        let filteredShops = searchShopUseCase.execute(text: text, shop: shopDTO)
        outputSubject.send(.changeFilteredShops(filteredShops.shops ?? [], selectedId))
        
        makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopCategoriesSearch, category: .click, value: selectedId)
    }
    
    private func changeCategory(_ id: Int) {
        if selectedId == id { selectedId = 0 }
        else { selectedId = id }
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, currentPage: String? = nil, durationType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if let currentPage = currentPage,
           let durationType = durationType {
            let previousPage = MakeParamsForLog().makeValueForLogAboutStoreId(id: selectedId)
            
            if eventLabelNeededDuration == .shopClick {
                let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
                logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
            }
            
            else if eventLabelNeededDuration == .shopCategories {
                let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
                let selectedNewShopName = previousPage == currentPage ? MakeParamsForLog().makeValueForLogAboutStoreId(id: 0) : currentPage
                logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: selectedNewShopName, durationTime: "\(durationTime)")
            }
        }
        else {
            logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }
}
