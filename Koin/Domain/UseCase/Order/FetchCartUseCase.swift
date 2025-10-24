//
//  FetchCartUseCase.swift
//  koin
//
//  Created by 홍기정 on 9/16/25.
//

import Combine

protocol FetchCartUseCase {
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error>
}

final class DefaultFetchCartUseCase: FetchCartUseCase {
    
    private let repository: OrderShopRepository
    
    init(repository: OrderShopRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> {
        /// DELIVERY 파라미터로 우선 시도합니다
        /// 잘못된 파라미터 오류시, TAKE_OUT 파라미터로 재시도합니다
        /// 두 파라미터 모두 실패시, 장바구니 정보 호출 실패합니다.
        /// 어떤 파라미터로 호출하여 설정했는지 알기 위해, 반환타입을 튜플로 바꿉니다.
        repository.fetchCart(parameter: .delivery)
            .map {
                return ($0, isFromDelivery: true)
            }
            .catch { [weak self] error -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                switch error.asAFError?.responseCode {
                case 400:
                    return repository.fetchCart(parameter: .takeOut)
                        .map {
                            return ($0, isFromDelivery: false)
                        }.eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

