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
        return diningRepository.fetchDiningList(requestModel: FetchDiningListRequest(date: diningInfo.date.formatDateToYYMMDD()))
            .map { [weak self] diningList in
                return self?.removeNonOperatingItems(from: diningList) ?? []
            }
            .map { [weak self] diningList in
                self?.filterByDiningType(diningList, type: diningInfo.diningType) ?? []
            }
            .map { [weak self] diningList in
                self?.sortDiningList(diningList) ?? []
            }
            .map { diningList in
                diningList.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    private func removeNonOperatingItems(from diningList: [DiningDto]) -> [DiningDto] {
        return diningList.filter { $0.menu?.first != "미운영" }
    }
    
    private func filterByDiningType(_ diningList: [DiningDto], type: DiningType) -> [DiningDto] {
        return diningList.filter { $0.type == type }
    }
    
    private func sortDiningList(_ diningList: [DiningDto]) -> [DiningDto] {
        return diningList.sorted {
            let order1 = $0.place.rawValue.first.map { sortOrder(of: $0) } ?? Int.max
            let order2 = $1.place.rawValue.first.map { sortOrder(of: $0) } ?? Int.max
            if order1 == order2 {
                return ($0.place.rawValue) < ($1.place.rawValue)
            } else {
                return order1 < order2
            }
        }
    }
    
    private func sortOrder(of char: Character) -> Int {
        if char.isLetter {
            if char.isASCII {
                return 0
            } else {
                return 1
            }
        } else if char.isNumber {
            return 2
        } else {
            return 3
        }
    }
}
