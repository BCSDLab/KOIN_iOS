//
//  HomeService.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation
import Combine

protocol HomeService {
    func fetchWeather() -> AnyPublisher<WeatherDto, ErrorResponse>
}

final class DefaultHomeService: HomeService {
    
    private let networkService = NetworkService.shared
    
    func fetchWeather() -> AnyPublisher<WeatherDto, ErrorResponse> {
        return networkService.requestWithResponse(api: HomeAPI.fetchWeather)
    }
}
