//
//  OrderHomeViewModel.swift
//  koin
//
//  Created by 이은지 on 6/19/25.
//

import UIKit
import Combine

final class OrderHomeViewModel: ViewModelProtocol {
    
    enum Input {
        case viewDidLoad
    }
    
    enum Output {
        case putImage(ShopCategoryDTO)
    }
    
    private let outputSubject = PassthroughSubject<Output, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let fetchShopCategoryListUseCase: FetchShopCategoryListUseCase
    
    
    init(fetchShopCategoryListUseCase: FetchShopCategoryListUseCase) {
        self.fetchShopCategoryListUseCase = fetchShopCategoryListUseCase
    }
    
    func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] input in
            switch input {
            case .viewDidLoad:
                self?.getShopCategory()
            }
        }.store(in: &subscriptions)
        
        return outputSubject.eraseToAnyPublisher()
    }
}

extension OrderHomeViewModel {
    
    private func getShopCategory() {
        fetchShopCategoryListUseCase.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    Log.make().error("\(error)")
                }
            }, receiveValue: { [weak self] response in
                guard self != nil else { return }
                self?.outputSubject.send(.putImage(response))
            })
            .store(in: &subscriptions)
    }

}
