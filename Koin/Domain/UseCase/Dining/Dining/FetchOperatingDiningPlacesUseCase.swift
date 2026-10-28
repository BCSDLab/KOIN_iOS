//
//  FetchOperatingDiningPlacesUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/18/26.
//

import Foundation

protocol FetchOperatingDiningPlacesUseCase {
    func execute() async throws -> [(place: DiningPlace, id: Int?)]
}

final class DefaultFetchOperatingDiningPlacesUseCase: FetchOperatingDiningPlacesUseCase {
    
    let repository: DiningRepository
    
    init(repository: DiningRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [(place: DiningPlace, id: Int?)] {
        let calendar = Calendar.current
        let now = Date()
        let dayOfWeek: DayOfWeek = {
            let weekday = calendar.component(.weekday, from: now)
            switch weekday {
            case 1:
                return .sunday
            case 7:
                return .saturday
            default:
                return.weekday
            }
        }()
        let currentTime = {
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            return String(format: "%02d:%02d", hour, minute)
        }()
        let currentDiningType = try? await repository.fetchCoopShopList()
            .firstValue()
            .opens
            .filter {
                $0.dayOfWeek == dayOfWeek
            }
            .first {
                $0.contains(time: currentTime)
            }
            .map {
                $0.type.toDiningType()
            }
        let operatingDiningItems = try await repository.fetchDiningList(date: Date()).firstValue()
            .filter { $0.type == currentDiningType }
            .filter { $0.place != .secondCampus }
        
        let diningPlaces: [(DiningPlace, id: Int?)] = DiningPlace.allCases
            .filter {
                $0 != .secondCampus
            }
            .map { place in
                let operatingDiningItem: DiningItem? = operatingDiningItems.first {
                    $0.place == place
                    && $0.isSoldOut == false
                }
                return (place, operatingDiningItem?.id)
            }
        
        return diningPlaces
    }
}
