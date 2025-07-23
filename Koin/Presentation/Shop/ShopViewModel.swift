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
        case getShopInfo
        case getShopBenefits
        case getBeneficialShops(Int)
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, String? = nil, ScreenActionType? = nil, EventParameter.EventLabelNeededDuration? = nil)
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
        case changeFilteredShops([Shop], Int)
//        case updateSeletecButtonColor(FetchShopListRequest)
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
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private let fetchShopBenefitUseCase: FetchShopBenefitUseCase
    private let fetchBeneficialShopUseCase: FetchBeneficialShopUseCase
    private let assignAbTestUseCase: AssignAbTestUseCase = DefaultAssignAbTestUseCase(abTestRepository: DefaultAbTestRepository(service: DefaultAbTestService()))
    
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
    
    private(set) var userAssignType: UserAssignType = .callFloating
    
    init(fetchShopListUseCase: FetchShopListUseCase, fetchEventListUseCase: FetchEventListUseCase, fetchShopCategoryListUseCase: FetchShopCategoryListUseCase, searchShopUseCase: SearchShopUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, getUserScreenTimeUseCase: GetUserScreenTimeUseCase, fetchShopBenefitUseCase: FetchShopBenefitUseCase, fetchBeneficialShopUseCase: FetchBeneficialShopUseCase, selectedId: Int) {
        self.fetchShopListUseCase = fetchShopListUseCase
        self.fetchEventListUseCase = fetchEventListUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
        self.searchShopUseCase = searchShopUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.fetchShopBenefitUseCase = fetchShopBenefitUseCase
        self.fetchBeneficialShopUseCase = fetchBeneficialShopUseCase
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
                self?.searchShops(text)
            case let .changeSortStandard(standard):
                self?.changeSortStandard(standard)
            case .getShopInfo:
                self?.getShopInfo(id: self?.selectedId ?? 0)
            case .getShopBenefits:
                self?.fetchShopBenefits()
            case let .getBeneficialShops(id):
                self?.fetchBeneficialShops(id: id)
            case let .logEvent(label, category, value, previousPage, currentPage, durationType, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationType: durationType, eventLabelNeededDuration: eventLabelNeededDuration)
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            case .viewDidLoadB:
                self?.fetchShopBenefits()
                self?.getEventShopList()
                self?.fetchBeneficialShops(id: 1)
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopViewModel {
    
    func assignShopAbTest(shopId: Int, shopName: String, categoryId: Int) {
        assignAbTestUseCase.execute(requestModel: AssignAbTestRequest(title: "business_call")).sink(receiveCompletion: { [weak self] completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
                self?.outputSubject.send(.navigateToShopData(shopId, shopName, categoryId))
            }
        }, receiveValue: { [weak self] abTestResult in
            self?.userAssignType = abTestResult.variableName
            print(abTestResult)
            self?.outputSubject.send(.navigateToShopData(shopId, shopName, categoryId))
        }).store(in: &subscriptions)
    }
    
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
        fetchShopListUseCase.execute(requestModel: FetchShopListRequest(sorter: sortStandard.sorter, filter: sortStandard.filter))
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
//                self.outputSubject.send(.updateSeletecButtonColor(self.sortStandard))
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
        searchShopUseCase.execute(text: text).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showSearchedResult(response.keywords ?? []))
        }.store(in: &subscriptions)
        
        makeLogAnalyticsEvent(label: EventParameter.EventLabel.Business.shopCategoriesSearch, category: .click, value: selectedId)
    }
    
    private func changeCategory(_ id: Int) {
        if selectedId == id { selectedId = 0 }
        else { selectedId = id }
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, durationType: ScreenActionType? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        let categoryName = MakeParamsForLog().makeValueForLogAboutStoreId(id: selectedId)
        if let currentPage = currentPage {
            if eventLabelNeededDuration == .shopCategories {
                let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
                let selectedNewShopName = categoryName == currentPage ? MakeParamsForLog().makeValueForLogAboutStoreId(id: 0) : currentPage
                logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: selectedNewShopName, previousPage: categoryName, currentPage: selectedNewShopName, durationTime: "\(durationTime)")
            }
            else {
                let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
                logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
            }
        }
        else {
            if label.rawValue == EventParameter.EventLabel.Business.shopCan.rawValue {
                let categoryName = MakeParamsForLog().makeValueForLogAboutStoreId(id: selectedId)
                let newValue = "\(value)_\(categoryName)"
                logAnalyticsEventUseCase.execute(label: label, category: category, value: newValue)
            }
            else {
                logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
            }
        }
    }
    
    private func getScreenAction(time: Date, screenActionType: ScreenActionType, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        getUserScreenTimeUseCase.getUserScreenAction(time: time, screenActionType: screenActionType, screenEventLabel: eventLabelNeededDuration)
    }
}
