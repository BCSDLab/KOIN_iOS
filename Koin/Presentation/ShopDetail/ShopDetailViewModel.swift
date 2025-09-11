//
//  ShopDetailViewModel.swift
//  koin
//
//  Created by 홍기정 on 9/5/25.
//

import Combine

final class ShopDetailViewModel {
    
    enum Input {
    case viewDidLoad
    }
    
    enum Output {
    case updateInfoView(OrderShopSummary)
    case updateMenus([OrderShopMenus])
    case updateMenusGroups(OrderShopMenusGroups)
    }
    
    // MARK: - Properties
    let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Transform
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                // useCase로 데이터를 호출하고, viewController에 돌려주는 로직
                self?.outputSubject.send(.updateInfoView(OrderShopSummary.dummy()))
                self?.outputSubject.send(.updateMenus(OrderShopMenus.dummy()))
                self?.outputSubject.send(.updateMenusGroups(OrderShopMenusGroups.dummy()))
            }
        }
        .store(in: &subscriptions)
        return outputSubject.eraseToAnyPublisher()
    }
}
