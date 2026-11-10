//
//  ShopSummaryViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine
import Foundation

final class ShopSummaryViewModel {
    
    // MARK: - Input
    enum Input {
        case viewDidLoad

        case logEvent(EventLabelType, Any)

    }
    
    // MARK: - Output
    enum Output {
        case update(ShopSummary)
    }
    
    // MARK: - Properties
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private(set) var shopId: Int
    private(set) var phonenumber: String = ""
    private(set) var cachedImages: [ShopImage] = []
    private(set) var shopName: String
    let backCategoryName: String?

    private let fetchShopSummaryUseCase: FetchShopSummaryUseCase
    
    private let logAnalyticsEventUseCase: LogAnalyticsEventUseCase
   
    // MARK: - Initializer
    init(fetchShopSummaryUseCase: FetchShopSummaryUseCase,
         logAnalyticsEventUseCase: LogAnalyticsEventUseCase,
         shopId: Int,
         shopName: String?,
         backCategoryName: String? = nil) {
        self.fetchShopSummaryUseCase = fetchShopSummaryUseCase
        self.shopId = shopId
        self.shopName = shopName ?? ""
        self.backCategoryName = backCategoryName
        self.logAnalyticsEventUseCase = logAnalyticsEventUseCase
    }
    
    // MARK: - Transform
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            guard let self else { return }
            switch input {
            case .viewDidLoad:
                self.fetchShopSummary(shopId: shopId)

            case let .logEvent(label, value):
                self.logAnalyticsEventUseCase.execute(label: label, value: value)

            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}

extension ShopSummaryViewModel {
    private func fetchShopSummary(shopId: Int) {
        fetchShopSummaryUseCase.execute(shopId: shopId).sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] shopSummary in
                guard let self else { return }
                self.phonenumber = shopSummary.phone
                self.shopName = shopSummary.name
                self.cachedImages = shopSummary.images
                self.outputSubject.send(.update(shopSummary))
            }
        ).store(in: &subscriptions)
    }
}
