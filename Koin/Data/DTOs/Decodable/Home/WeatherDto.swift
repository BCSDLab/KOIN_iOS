//
//  WeatherDto.swift
//  koin
//
//  Created by 홍기정 on 6/6/26.
//

import Foundation

struct WeatherDto: Decodable {
    let temperature: Int
    let weather: String
    let weatherID: Int
    let weatherIconURL: String

    enum CodingKeys: String, CodingKey {
        case temperature, weather
        case weatherID = "weather_id"
        case weatherIconURL = "weather_icon_url"
    }
}

extension WeatherDto {
    func toDomain() -> Weather {
        return Weather(
            temperature: temperature,
            weatherText: weather,
            imageUrl: weatherIconURL
        )
    }
}
