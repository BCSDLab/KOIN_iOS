//
//  HomeHeader.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import Foundation

struct HomeHeader: Equatable {
    let dateText: String
    let weather: Weather
    let userName: String?
    let message: String
}

struct Weather: Equatable {
    let temperature: Int
    let weatherText: String
    let imageUrl: String
}

extension HomeHeader {
    static func empty() -> HomeHeader {
        return HomeHeader(dateText: "", weather: Weather(temperature: 0, weatherText: "", imageUrl: ""), userName: nil, message: "")
    }
}
