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
        /// DELIVERY 또는 TAKE_OUT  파라미터를 필수로 사용해야합니다.
        /// DELIVERY  파라미터로 우선 시도합니다.
        /// 성공시
            /// 반환 타입을 Cart 에서 (Cart, isFromDelivery: Bool) 튜플로 바꿉니다.
            /// UI 에서 어떤 파라미터로 성공했는지 알아야하기 때문입니다.
        /// 실패시
            /// (1) 파라미터로 인한 오류일 경우 (case 400) - TAKE_OUT 파라미터로 재시도합니다
            /// (2) 인증 정보 오류일 경우 (case 401) - 재시도 하지 않습니다.
            /// (3) 정의되지 않은 경우 (default) - 재시도 하지 않습니다.
        
        repository.fetchCart(parameter: .delivery)  /// DELIVERY 파라미터로 우선 시도합니다.
            .map {                                  /// 성공시
                return ($0, isFromDelivery: true)   /// 반환 타입을 Cart 에서 (Cart, isFromDelivery: Bool) 튜플로 바꿉니다.
            }
            .catch { [weak self] error -> AnyPublisher<(Cart, isFromDelivery: Bool), Error> in /// 실패시
                switch error.asAFError?.responseCode {
                case 400:                                                   /// (1) 파라미터로 인한 오류일 경우
                    guard let self = self else {                            /// self?.repository를 self.repository로 바꾸기 위한 guard let 구문입니다.
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                    return self.repository.fetchCart(parameter: .takeOut)   /// TAKE_OUT  파라미터로 재시도합니다.
                        .map {
                            return ($0, isFromDelivery: false)              /// 반환 타입을 Cart 에서 (Cart, isFromDelivery: Bool) 튜플로 바꿉니다.
                        }
                        .eraseToAnyPublisher()
                case 401:                                                   /// (2) 인증 정보 오류일 경우
                    return Fail(error: error).eraseToAnyPublisher()         /// 재시도 하지 않습니다
                default:                                                    /// (3) 정의되지 않은 경우
                    return Fail(error: error).eraseToAnyPublisher()         /// 재시도 하지 않습니다
                }
            }
            .eraseToAnyPublisher()
    }
}

