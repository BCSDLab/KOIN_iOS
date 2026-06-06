//
//  FetchHomeHeaderUseCase.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Combine
import Foundation

protocol FetchHomeHeaderUseCase {
    func execute() -> AnyPublisher<HomeHeader, ErrorResponse>
}

final class DefaultFetchHomeHeaderUseCase: FetchHomeHeaderUseCase {
    
    private let homeRepository: HomeRepository
    private let userRepository: UserRepository
    
    init(homeRepository: HomeRepository, userRepository: UserRepository) {
        self.homeRepository = homeRepository
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<HomeHeader, ErrorResponse> {
        let dateText = dateText(from: Date())
        let message = "오늘도 잘 챙겨먹어요"
        
        return homeRepository.fetchWeather()
            .zip(userRepository.fetchUserData())
            .map { (weather, userDto) in
                HomeHeader(
                    dateText: dateText,
                    weather: weather,
                    userName: userDto.nickname ?? userDto.name ?? "익명",
                    message: message
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func dateText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
}
