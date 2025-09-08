//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine

class ShopDetailViewModel {
    
    enum Input {
    case viewDidLoad
    }
    
    enum Output {
    case updateImagesUrls([String])
    case updateInfoView(OrderShop)
    case updateMenus()
    }
    
    // MARK: - Properties
    let outputSubject = PassthroughSubject<Output, Never>()
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Transform
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                // useCase로 데이터를 호출하고, viewController에 돌려주는 로직
                self?.outputSubject.send(.updateImagesUrls([
                    "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg",
                    "https://static.koreatech.in/upload/owners/2024/03/06/2d7687d6-57dd-4241-988a-26d2b2855030-1709732308684/20240304_182511.jpg"
                ]))
                self?.outputSubject.send(.updateInfoView(OrderShop(shopId: 0, orderableShopId: 0, name: "NAME", isDeliveryAvailable: true, isTakeoutAvailable: true, serviceEvent: true,minimumOrderAmount: 15000, ratingAverage: 4.8, reviewCount: 5, minimumDeliveryTip: 0, maximumDeliveryTip: 3000, isOpen: true, categoryIds: [], images: [OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: false),OrderImage(imageUrl: "https://static.koreatech.in/upload/market/2021/05/29/85d5a49a-ecd8-4223-8582-ae316f251e27-1622292361626.jpg",isThumbnail: true)], openStatus: "")))
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}
