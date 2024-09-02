//
//  HomeViewModel.swift
//  Koin
//
//  Created by 김나훈 on 3/10/24.
//

import Alamofire
import Combine

final class HomeViewModel: ViewModelProtocol {
    
    // MARK: - Input
    
    enum Input {
        case viewDidLoad
        case categorySelected(DiningPlace)
        case getBusInfo(BusPlace, BusPlace, BusType)
        case getDiningInfo
        case getNoticeInfo
        case logEvent(EventLabelType, EventParameter.EventCategory, Any)
    }
    
    // MARK: - Output
    
    enum Output {
        case updateDining(DiningItem?, DiningType, Bool)
        case updateBus(BusCardInformation)
        case updateHotArticles([NoticeArticleDTO])
        case putImage(ShopCategoryDTO)
        case moveBusItem
    }
    
    // MARK: - Properties
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private let fetchDiningListUseCase: FetchDiningListUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let dateProvider: DateProvider
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    private let fetchBusInformationListUseCase: FetchBusInformationListUseCase
    private let fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase
    private var subscriptions: Set<AnyCancellable> = []
    private (set) var moved = false
    
    // MARK: - Initialization
    init(fetchDiningListUseCase: FetchDiningListUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, fetchShopCategoryUseCase: FetchShopCategoryListUseCase, fetchBusInformationListUseCase: FetchBusInformationListUseCase, fetchHotNoticeArticlesUseCase: FetchHotNoticeArticlesUseCase, dateProvder: DateProvider) {
        self.fetchDiningListUseCase = fetchDiningListUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.fetchShopCategoryListUseCase = fetchShopCategoryUseCase
        self.fetchHotNoticeArticlesUseCase = fetchHotNoticeArticlesUseCase
        self.fetchBusInformationListUseCase = fetchBusInformationListUseCase
        self.dateProvider = dateProvder
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getBusInformation(.koreatech, .terminal, .shuttleBus)
                self?.getShopCategory()
            case let .categorySelected(place):
                self?.getDiningInformation(diningPlace: place)
            case let .getBusInfo(from, to, type):
                self?.getBusInformation(from, to, type)
            case .getDiningInfo:
                self?.getDiningInformation()
            case let .logEvent(label, category, value):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value)
            case .getNoticeInfo:
                self?.getHotNoticeArticles()
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
    
}

extension HomeViewModel {
    // TODO: 아직 버스 리팩토링이 완료되지 않았으므로 여기서 Alamofire 호출.
    private func getBusInformation(_ from: BusPlace, _ to: BusPlace, _ type: BusType) {
        
        fetchBusInformationListUseCase.execute(departedPlace: from, arrivedPlace: to).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            if let filteredResponse = response.filter({ $0.busTitle == type }).first {
                if !self.moved {
                    outputSubject.send(.moveBusItem)
                    self.moved = true
                }
                self.outputSubject.send(.updateBus(filteredResponse))
            }
        }.store(in: &subscriptions)
        
    }
    
    private func getDiningInformation(diningPlace: DiningPlace = .cornerA) {
        
        let dateInfo = dateProvider.execute(date: Date())
        
        fetchDiningListUseCase.execute(diningInfo: dateInfo).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            let result = response.filter { $0.place == diningPlace }.first
            self?.outputSubject.send(.updateDining(result, dateInfo.diningType, dateInfo.date.formatDateToYYMMDD() == Date().formatDateToYYMMDD()))
        }.store(in: &subscriptions)
    }
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute().sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.putImage(response))
        }.store(in: &subscriptions)
    }
    
    private func getHotNoticeArticles() {
        fetchHotNoticeArticlesUseCase.execute(noticeId: nil).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] articles in
            self?.outputSubject.send(.updateHotArticles(articles))
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any) {
        logAnalyticsEventUseCase.execute(label: label, category: category, value: value)
    }
}


