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
    
    private let lock = NSLock()
    @Published private var isRefreshing = false
    
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        lock.lock()
        defer {
            lock.unlock()
        }
        
        switch isRefreshing {
        case true:
            $isRefreshing
                .filter { $0 == false }
                .first()
                .sink { _ in
                    var urlRequest = urlRequest
                    if let token = KeychainWorker.shared.read(key: .access) {
                        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    }
                    completion(.success(urlRequest))
                }
                .store(in: &subscriptions)
        case false:
            var urlRequest = urlRequest
            if let token = KeychainWorker.shared.read(key: .access) {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            completion(.success(urlRequest))
        }
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping @Sendable (RetryResult) -> Void) {

        guard let responseCode = request.response?.statusCode,
              responseCode == 401,
              request.retryCount < retryLimit,
              let _ = KeychainWorker.shared.read(key: .refresh) else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        lock.lock()
        defer {
            lock.unlock()
        }
        
        switch isRefreshing {
        case true:
            $isRefreshing
                .filter { $0 == false }
                .first()
                .sink { _ in
                    completion(.retry)
                }
                .store(in: &subscriptions)
        case false:
            isRefreshing = true
            refreshToken().sink( receiveValue: { [weak self] isRefreshed in
                guard let self else { return }
                
                lock.lock()
                isRefreshing = false
                lock.unlock()
                
                completion(isRefreshed ? .retry : .doNotRetryWithError(error))
            }).store(in: &subscriptions)
        }
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
