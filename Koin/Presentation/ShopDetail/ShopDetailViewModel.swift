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
    case updateMenus([OrderShopMenusGroup])
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
                self?.outputSubject.send(.updateImagesUrls(ShopDetailDummyModels.urls))
                self?.outputSubject.send(.updateInfoView(ShopDetailDummyModels.orderShop))
                self?.outputSubject.send(.updateMenus(ShopDetailDummyModels.orderShopMenusGroup))
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}
