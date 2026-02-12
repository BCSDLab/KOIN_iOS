//
//  Retrier.swift
//  koin
//
//  Created by 홍기정 on 2/12/26.
//

import Foundation
import Alamofire
import Combine

final class Interceptor: RequestInterceptor {
    
    private let retryLimit = 1
    private var subscriptions: Set<AnyCancellable> = []
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping @Sendable (RetryResult) -> Void) {

        guard let responseCode = error.asAFError?.responseCode,
              responseCode == 401,
              request.retryCount < retryLimit,
              let _ = KeychainWorker.shared.read(key: .refresh) else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        refreshToken().sink( receiveValue: { isRefreshed in
            completion(isRefreshed ? .retry : .doNotRetryWithError(error))
        }).store(in: &subscriptions)
    }
}

extension Interceptor {
    
    private func refreshToken() -> AnyPublisher<Bool, Never> {
        return requestWithResponse(api: UserAPI.refreshToken(RefreshTokenRequest(refreshToken: KeychainWorker.shared.read(key: .refresh) ?? "")))
            .map { (tokenDto: TokenDto) in
                KeychainWorker.shared.create(key: .access, token: tokenDto.token)
                KeychainWorker.shared.create(key: .refresh, token: tokenDto.refreshToken)
                return true
            }
            .catch { _ -> Just<Bool> in
                KeychainWorker.shared.delete(key: .access)
                KeychainWorker.shared.delete(key: .refresh)
                return Just(false)
            }
            .eraseToAnyPublisher()
    }
    
    private func requestWithResponse<T: Decodable>(api: URLRequestConvertible) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
