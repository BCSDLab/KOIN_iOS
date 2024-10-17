//
//  CoreService.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Alamofire
import Combine

protocol CoreService {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, Error>
}

final class DefaultCoreService: CoreService {
    func fetchVersion() -> AnyPublisher<ForceUpdateResponse, any Error> {
        return request(.checkVersion)
    }

    private func request<T: Decodable>(_ api: CoreAPI) -> AnyPublisher<T, Error> {
        return AF.request(api)
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
