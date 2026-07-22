//
//  HomeRepository.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Combine

protocol HomeRepository {
    func fetchWeather() -> AnyPublisher<Weather, ErrorResponse>
}

final class DefaultHomeRepository: HomeRepository {
    
    private let service: HomeService
    
    init(service: HomeService) {
        self.service = service
    }
    
    func fetchWeather() -> AnyPublisher<Weather, ErrorResponse> {
        return service.fetchWeather()
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}
