//
//  FetchCurrentDiningItemsUseCase.swift
//  koin
//
//  Created by 홍기정 on 10/18/26.
//

import Foundation

protocol FetchCurrentDiningItemsUseCase {
    func execute() async throws -> [DiningItem]
}

final class DefaultFetchCurrentDiningItemsUseCase: FetchCurrentDiningItemsUseCase {
    
    let repository: DiningRepository
    
    init(repository: DiningRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [DiningItem] {
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
        let targetTime = {
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)
            return String(format: "%02d:%02d", hour, minute)
        }()
        
        let mealType = try? await repository.fetchCoopShopList()
            .firstValue()
            .opens
            .filter {
                $0.dayOfWeek == dayOfWeek
            }
            .first {
                $0.contains(time: targetTime)
            }
            .map {
                $0.type.toDiningType()
            }
        return try await repository.fetchDiningList(date: Date()).firstValue()
            .filter { $0.type == mealType }
    }
}
