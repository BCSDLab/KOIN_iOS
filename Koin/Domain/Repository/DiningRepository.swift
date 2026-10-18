//
//  DiningRepository.swift
//  koin
//
//  Created by 김나훈 on 6/7/24.
//

import Combine
import Foundation

protocol DiningRepository {
    func fetchDiningList(date: Date) -> AnyPublisher<[DiningItem], ErrorResponse>
    func fetchCoopShopList() -> AnyPublisher<CoopShopData, ErrorResponse>
    func shareMenuList(shareModel: ShareDiningMenu)
    func reportSoldout(diningId: Int, imageUrl: String) async throws -> Void
}
