//
//  Interceptor.swift
//  koin
//
//  Created by 홍기정 on 2/12/26.
//

import Foundation
import Alamofire
import Combine

final class Interceptor: RequestInterceptor {
    
    // MARK: - Properties
    private let retryLimit = 1
    
    private let lock = NSLock()
    private var isRefreshing = false
    
    private var refreshSubscription: AnyCancellable?
    
    private var adaptRequests: [(urlRequest: URLRequest, completion: (Result<URLRequest, any Error>) -> Void)] = []
    private var retryRequests: [(error: Error, completion: @Sendable (RetryResult) -> Void)] = []
    
    // MARK: - Adapt
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        lock.lock()
        defer {
            lock.unlock()
        }
        
        if isRefreshing {
            adaptRequests.append((urlRequest: urlRequest, completion: completion))
        } else {
            adapt(urlRequest: urlRequest, completion: completion)
        }
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping @Sendable (RetryResult) -> Void) {
        
        guard let responseCode = request.response?.statusCode,
              responseCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        guard request.retryCount < retryLimit,
              let _ = KeychainWorker.shared.read(key: .refresh) else {
            KeychainWorker.shared.delete(key: .access)
            KeychainWorker.shared.delete(key: .refresh)
            completion(.doNotRetryWithError(error))
            return
        }
        
        lock.lock()
        defer {
            lock.unlock()
        }
        retryRequests.append((error: error, completion: completion))
        
        if !isRefreshing {
            self.isRefreshing = true
            refreshSubscription = refreshToken().sink { [weak self] shouldRetry in
                guard let self else { return }
                
                self.lock.lock()
                let adaptRequests = self.adaptRequests
                let retryRequests = self.retryRequests
                self.adaptRequests.removeAll()
                self.retryRequests.removeAll()
                self.isRefreshing = false
                self.lock.unlock()
                
                adaptRequests.forEach {
                    self.adapt(urlRequest: $0.urlRequest, completion: $0.completion)
                }
                retryRequests.forEach {
                    self.retry(error: $0.error, completion: $0.completion, shouldRetry: shouldRetry)
                }
            }
        }
    }
}

extension Interceptor {

    private func adapt(urlRequest: URLRequest, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = KeychainWorker.shared.read(key: .access) {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    private func retry(error: Error, completion: @escaping @Sendable (RetryResult) -> Void, shouldRetry: Bool) {
        
        if shouldRetry {
            completion(.retry)
        } else {
            completion(.doNotRetryWithError(error))
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
