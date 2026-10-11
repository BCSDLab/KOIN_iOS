//
//  FetchDiningListUseCase.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Combine
import Foundation

protocol FetchDiningListUseCase {
    func execute(diningInfo: CurrentDiningTime) -> AnyPublisher<[DiningItem], ErrorResponse>
}

final class DefaultFetchDiningListUseCase: FetchDiningListUseCase {
    
    private let diningRepository: DiningRepository
    
    init(diningRepository: DiningRepository) {
        self.diningRepository = diningRepository
    }
    
    func execute(diningInfo: CurrentDiningTime) -> AnyPublisher<[DiningItem], ErrorResponse> {
        return diningRepository.fetchDiningList(date: diningInfo.date)
            .map { [weak self] diningList in
                return self?.removeNonOperatingItems(from: diningList) ?? []
            }
            .map { [weak self] diningList in
                self?.filterByDiningType(diningList, type: diningInfo.diningType) ?? []
            }
            .map { [weak self] diningList in
                self?.sortDiningList(diningList) ?? []
            }
            .eraseToAnyPublisher()
    }
    
    private func removeNonOperatingItems(from diningList: [DiningItem]) -> [DiningItem] {
        return diningList.filter { $0.menu.first != "미운영" }
    }
    
    private func filterByDiningType(_ diningList: [DiningItem], type: DiningType) -> [DiningItem] {
        return diningList.filter { $0.type == type }
    }
    
    private func sortDiningList(_ diningList: [DiningItem]) -> [DiningItem] {
        return diningList.sorted { $0.place.sortOrder < $1.place.sortOrder }
    }
}
