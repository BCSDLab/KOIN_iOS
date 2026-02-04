//
//  LostItemRepository.swift
//  koin
//
//  Created by 홍기정 on 1/21/26.
//

import Foundation
import Combine

protocol LostItemRepository {
    func fetchLostItemList(requestModel: FetchLostItemListRequest) -> AnyPublisher<LostItemList, Error>
    func fetchLostItemData(id: Int) -> AnyPublisher<LostItemData, Error>
    func changeLostItemState(id: Int) -> AnyPublisher<Void, ErrorResponse>
    func deleteLostItem(id: Int) -> AnyPublisher<Void, Error>
    func updateLostItem(id: Int, requestModel: UpdateLostItemRequest) -> AnyPublisher<LostItemData, ErrorResponse>
    func fetchLostItemStats() -> AnyPublisher<LostItemStats, Error>
}
