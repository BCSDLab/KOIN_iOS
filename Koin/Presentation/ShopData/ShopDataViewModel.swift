//
//  ShopDataViewModel.swift
//  koin
//
//  Created by 김나훈 on 3/13/24.
//

import Combine
import Foundation

final class ShopDataViewModel: ViewModelProtocol {
        
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private let shopId: Int
    private let shopName: String
    private let categoryId: Int?
    private let fetchShopDataUseCase: FetchShopDataUseCase
    private let fetchShopMenuListUseCase: FetchShopMenuListUseCase
    private let fetchShopEventListUseCase: FetchShopEventListUseCase
    private let fetchShopReviewListUseCase: FetchShopReviewListUseCase
    private let fetchMyReviewUseCase: FetchMyReviewUseCase
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase
    private let getUserScreenTimeUseCase: GetUserScreenTimeUseCase
    private(set) var eventItem: [ShopEvent] = []
    private(set) var menuItem: [MenuCategory] = []
    private var fetchStandard: (ReviewSortType, Bool) = (.latest, false) {
        didSet {
            if fetchStandard.1 { fetchMyReviewList() }
            else { fetchShopReviewList() }
        }
    }
    enum Input {
        case viewDidLoad
        case fetchShopEventList
        case fetchShopMenuList
        case fetchShopReviewList
        case getUserScreenAction(Date, ScreenActionType, EventParameter.EventLabelNeededDuration? = nil)
        case deleteReview(Int, Int)
        case changeFetchStandard(ReviewSortType?, Bool?)
        case updateReviewCount
        case logEvent(EventLabelType, EventParameter.EventCategory, Any, String? = nil, EventParameter.EventLabelNeededDuration? = nil)
    }
    enum Output {
        case showShopData(ShopData)
        case showShopMenuList([MenuCategory])
        case showShopEventList([ShopEvent])
        case showShopReviewList([Review], Int, String, ReviewSortType, Bool)
        case showShopReviewStatistics(StatisticsDTO)
        case showToast(String, Bool)
        case updateReviewCount(Int)
        case disappearReview(Int, Int)
    }
    
    init(fetchShopDataUseCase: FetchShopDataUseCase, fetchShopMenuListUseCase: FetchShopMenuListUseCase, fetchShopEventListUseCase: FetchShopEventListUseCase, fetchShopReviewListUseCase: FetchShopReviewListUseCase, fetchMyReviewUseCase: FetchMyReviewUseCase, deleteReviewUseCase: DeleteReviewUseCase, logAnalyticsEventUseCase: LogAnalyticsEventUseCase, getUserScreenTimeUseCase: GetUserScreenTimeUseCase, shopId: Int, shopName: String, categoryId: Int?) {
        self.fetchShopDataUseCase = fetchShopDataUseCase
        self.fetchShopMenuListUseCase = fetchShopMenuListUseCase
        self.fetchShopEventListUseCase = fetchShopEventListUseCase
        self.fetchShopReviewListUseCase = fetchShopReviewListUseCase
        self.fetchMyReviewUseCase = fetchMyReviewUseCase
        self.deleteReviewUseCase = deleteReviewUseCase
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
        self.getUserScreenTimeUseCase = getUserScreenTimeUseCase
        self.shopId = shopId
        self.shopName = shopName
        self.categoryId = categoryId
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let strongSelf = self else { return }
            switch input {
            case .viewDidLoad:
                self?.fetchShopData()
                self?.fetchShopMenuList()
                self?.updateReviewCount()
            case let .logEvent(label, category, value, currentPage, eventLabelNeededDuration):
                self?.makeLogAnalyticsEvent(label: label, category: category, value: value, currentPage: currentPage, eventLabelNeededDuration: eventLabelNeededDuration)
            case .fetchShopEventList:
                self?.fetchShopEventList()
            case .fetchShopMenuList:
                self?.fetchShopMenuList()
            case .fetchShopReviewList:
                if strongSelf.fetchStandard.1 {
                    self?.fetchMyReviewList()
                } else {
                    self?.fetchShopReviewList()
                }
            case let .changeFetchStandard(type, isMine):
                self?.changeFetchStandard(type, isMine)
            case let .deleteReview(reviewId, shopId):
                self?.deleteReview(reviewId, shopId)
            case .updateReviewCount:
                self?.updateReviewCount()
                self?.fetchShopReviewList()
            case let .getUserScreenAction(time, screenActionType, eventLabelNeededDuration):
                self?.getScreenAction(time: time, screenActionType: screenActionType, eventLabelNeededDuration: eventLabelNeededDuration)
            }
        }.store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopDataViewModel {
    private func updateReviewCount() {
        fetchShopReviewListUseCase.execute(requestModel: FetchShopReviewRequest(shopId: shopId, page: 1, sorter: fetchStandard.0)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.updateReviewCount(response.review.count))
            self?.outputSubject.send(.showShopReviewStatistics(response.reviewStatistics))
        }.store(in: &subscriptions)
    }
    
    private func deleteReview(_ reviewId: Int, _ shopId: Int) {
        deleteReviewUseCase.execute(reviewId: reviewId, shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
            }
        } receiveValue: { [weak self] _ in
            self?.outputSubject.send(.showToast("리뷰가 삭제되었습니다.", true))
            self?.outputSubject.send(.disappearReview(reviewId, shopId))
            self?.updateReviewCount()
        }.store(in: &subscriptions)
        
    }
    
    private func changeFetchStandard(_ type: ReviewSortType?, _ isMine: Bool?) {
        if let type = type {
            fetchStandard.0 = type
        }
        if let isMine = isMine {
            fetchStandard.1 = isMine
        }
    }
    
    private func fetchMyReviewList() {
        fetchMyReviewUseCase.execute(requestModel: FetchMyReviewRequest(sorter: fetchStandard.0), shopId: shopId).sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.outputSubject.send(.showToast(error.message, false))
                self?.fetchStandard.1 = false
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.outputSubject.send(.showShopReviewList(response, self.shopId, self.shopName, self.fetchStandard.0, self.fetchStandard.1))
            self.updateReviewCount()
        }.store(in: &subscriptions)
    }
    
    private func fetchShopReviewList() {
        fetchShopReviewListUseCase.execute(requestModel: FetchShopReviewRequest(shopId: shopId, page: 1, sorter: fetchStandard.0)).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            self.outputSubject.send(.showShopReviewList(response.review, self.shopId, self.shopName, self.fetchStandard.0, self.fetchStandard.1))
            self.outputSubject.send(.showShopReviewStatistics(response.reviewStatistics))
            self.updateReviewCount()
        }.store(in: &subscriptions)
    }
    
    private func fetchShopData() {
        fetchShopDataUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.outputSubject.send(.showShopData(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopMenuList() {
        fetchShopMenuListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.menuItem = response
            self?.outputSubject.send(.showShopMenuList(response))
        }.store(in: &subscriptions)
    }
    
    private func fetchShopEventList() {
        fetchShopEventListUseCase.execute(shopId: shopId).sink { completion in
            if case let .failure(error) = completion {
                Log.make().error("\(error)")
            }
        } receiveValue: { [weak self] response in
            self?.eventItem = response
            self?.outputSubject.send(.showShopEventList(response))
        }.store(in: &subscriptions)
    }
    
    private func makeLogAnalyticsEvent(label: EventLabelType, category: EventParameter.EventCategory, value: Any, previousPage: String? = nil, currentPage: String? = nil, eventLabelNeededDuration: EventParameter.EventLabelNeededDuration? = nil) {
        if eventLabelNeededDuration == .shopCall {
            let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: currentPage, durationTime: "\(durationTime)")
        }
        else if eventLabelNeededDuration == .shopDetailViewBack {
            let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: false)
            let categoryName = MakeParamsForLog().makeValueForLogAboutStoreId(id: categoryId ?? 0)
            logAnalyticsEventUseCase.executeWithDuration(label: label, category: category, value: value, previousPage: previousPage, currentPage: categoryName, durationTime: "\(durationTime)")
        }
        else if let eventLabel = eventLabelNeededDuration?.rawValue, eventLabel.contains("shopDetailViewReviewBack") {
            let durationTime = getUserScreenTimeUseCase.returnUserScreenTime(isEventTime: true)
            let categoryName = MakeParamsForLog().makeValueForLogAboutStoreId(id: categoryId ?? 0)
            var currentPage = currentPage
            if eventLabelNeededDuration == .shopDetailViewReviewBackByCategory {
                currentPage = categoryName
            }
            if durationTime != 0 {
                logAnalyticsEventUseCase.executeWithDuration(
                    label: label,
                    category: category,
                    value: value,
                    previousPage: "리뷰",
                    currentPage: currentPage,
                    durationTime: "\(durationTime)"
                )
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
